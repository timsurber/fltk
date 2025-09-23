const std = @import("std");

fn addFiles(list: *std.ArrayList([]const u8), files: []const []const u8) void {
    for (files) |file| {
        list.append(file) catch @panic("oom");
    }
}

const WaylandProtocol = struct {
    source: std.Build.LazyPath,
    header: std.Build.LazyPath,
};

fn getWaylandProtocolsDir(b: *std.Build) []const u8 {
    const allocator = b.allocator;

    if (b.findProgram(&.{"pkg-config"}, &.{}) catch null) |pkg_config| {
        if (std.process.Child.run(.{
            .allocator = allocator,
            .argv = &.{ pkg_config, "--variable=pkgdatadir", "wayland-protocols" },
        }) catch null) |result| {
            defer allocator.free(result.stdout);
            defer allocator.free(result.stderr);

            switch (result.term) {
                .Exited => |code| {
                    if (code == 0) {
                        const trimmed = std.mem.trim(u8, result.stdout, " \r\n\t");
                        if (trimmed.len != 0) {
                            return allocator.dupe(u8, trimmed) catch @panic("oom");
                        }
                    }
                },
                else => {},
            }
        }
    }

    const fallbacks = [_][]const u8{
        "/usr/share/wayland-protocols",
        "/usr/local/share/wayland-protocols",
    };

    for (fallbacks) |candidate| {
        var dir = std.fs.cwd().openDir(candidate, .{}) catch continue;
        dir.close();
        return allocator.dupe(u8, candidate) catch @panic("oom");
    }

    @panic("Unable to locate wayland-protocols pkgdatadir. Install wayland-protocols or make it discoverable via pkg-config.");
}

fn generateWaylandProtocol(
    b: *std.Build,
    scanner: []const u8,
    xml: std.Build.LazyPath,
    basename: []const u8,
) WaylandProtocol {
    const header_run = b.addSystemCommand(&.{scanner});
    header_run.addArg("client-header");
    header_run.addFileArg(xml);
    const header = header_run.addOutputFileArg(b.fmt("{s}-client-protocol.h", .{basename}));

    const source_run = b.addSystemCommand(&.{scanner});
    source_run.addArg("private-code");
    source_run.addFileArg(xml);
    const source = source_run.addOutputFileArg(b.fmt("{s}-protocol.c", .{basename}));

    return .{ .source = source, .header = header };
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const upstream = b.dependency("fltk", .{});
    // cairo crashes when built in debug mode
    const dep_optimize: std.builtin.OptimizeMode = switch (optimize) {
        .Debug => .ReleaseFast,
        else => optimize,
    };

    const os_tag = target.result.os.tag;
    if (os_tag != .linux and os_tag != .windows) {
        @panic("zig build for FLTK currently supports only Linux (X11) and Windows (WinAPI) targets");
    }

    var cpp_sources = std.ArrayList([]const u8).init(b.allocator);
    defer cpp_sources.deinit();

    var c_sources = std.ArrayList([]const u8).init(b.allocator);
    defer c_sources.deinit();

    addFiles(&cpp_sources, &fltk_cpp_srcs);
    addFiles(&cpp_sources, &fltk_postscript_cpp_srcs);
    addFiles(&c_sources, &fltk_c_srcs);

    const lib = b.addLibrary(.{
        .name = "fltk",
        .linkage = .static,
        .root_module = b.createModule(.{ .target = target, .optimize = optimize, .link_libc = true, .link_libcpp = true }),
    });

    switch (os_tag) {
        .linux => {
            addFiles(&cpp_sources, &fltk_driver_linux_cpp_srcs);
            addFiles(&c_sources, &fltk_driver_linux_c_srcs);
            for (linux_system_libs) |name| lib.root_module.linkSystemLibrary(name, .{});
        },
        .windows => {
            addFiles(&cpp_sources, &fltk_driver_winapi_cpp_srcs);
            addFiles(&c_sources, &fltk_driver_winapi_c_srcs);
            for (windows_system_libs) |name| lib.root_module.linkSystemLibrary(name, .{});
        },
        else => unreachable,
    }

    lib.addIncludePath(upstream.path("."));
    lib.addIncludePath(upstream.path("src"));

    const header_dir_opts = std.Build.Step.Compile.HeaderInstallation.Directory.Options{
        .include_extensions = &.{ ".h", ".H" },
    };
    lib.installHeadersDirectory(upstream.path("FL"), "FL", header_dir_opts);
    lib.installHeader(upstream.path("mac_endianness.h"), "mac_endianness.h");

    lib.root_module.addCMacro("FL_LIBRARY", "1");
    lib.root_module.addCMacro("_FILE_OFFSET_BITS", "64");
    lib.root_module.addCMacro("_LARGEFILE64_SOURCE", "1");
    lib.root_module.addCMacro("_LARGEFILE_SOURCE", "1");
    lib.root_module.addCMacro("_REENTRANT", "1");
    lib.root_module.addCMacro("_THREAD_SAFE", "1");
    lib.root_module.addCMacro("LIBDECOR_PLUGIN_API_VERSION", "1");
    lib.root_module.addCMacro("LIBDECOR_PLUGIN_DIR", "\"\"");
    lib.root_module.addCMacro("USE_SYSTEM_LIBDECOR", "0");

    const config_h = b.addConfigHeader(
        .{
            .style = .{ .cmake = upstream.path("configh.cmake.in") },
            .include_path = "config.h",
        },
        .{
            .CONFIG_H = "config.h",
            .CONFIG_H_IN = "configh.cmake.in",
            .PREFIX_DATA = if (os_tag == .linux) "/usr/local/share/fltk" else "c:/Program Files/fltk",
            .PREFIX_DOC = if (os_tag == .linux) "/usr/local/share/doc/fltk" else "c:/Program Files/fltk",
            .HAVE_GL = false,
            .HAVE_GL_GLU_H = false,
            .HAVE_GLXGETPROCADDRESSARB = false,
            .HAVE_XINERAMA = 0,
            .USE_XFT = os_tag == .linux,
            .USE_PANGO = os_tag == .linux,
            .HAVE_XFIXES = 0,
            .HAVE_XCURSOR = 0,
            .HAVE_XRENDER = 0,
            .HAVE_X11_XREGION_H = os_tag == .linux,
            .HAVE_GL_OVERLAY = os_tag == .linux,
            .U16 = "unsigned short",
            .U32 = "unsigned",
            .U64 = "unsigned long",
            .HAVE_DIRENT_H = os_tag == .linux,
            .HAVE_SCANDIR = os_tag == .linux,
            .HAVE_SCANDIR_POSIX = os_tag == .linux,
            .HAVE_VSNPRINTF = os_tag == .linux,
            .HAVE_SNPRINTF = os_tag == .linux,
            .HAVE_STRINGS_H = os_tag == .linux,
            .HAVE_STRCASECMP = os_tag == .linux,
            .HAVE_PTHREAD = os_tag == .linux,
            .HAVE_PTHREAD_H = os_tag == .linux,
            .HAVE_LOCALE_H = 1,
            .HAVE_LOCALECONV = 1,
            .HAVE_SYS_SELECT_H = os_tag == .linux,
            .HAVE_SETENV = os_tag == .linux,
            .HAVE_TRUNC = 1,
            .HAVE_LIBPNG = true,
            .HAVE_LIBZ = true,
            .HAVE_LIBJPEG = true,
            .HAVE_PNG_H = true,
            .HAVE_PNG_GET_VALID = true,
            .HAVE_PNG_SET_TRNS_TO_ALPHA = true,
            .HAVE_PTHREAD_MUTEX_RECURSIVE = os_tag == .linux,
            .HAVE_LONG_LONG = 1,
            .HAVE_DLFCN_H = os_tag == .linux,
            .HAVE_DLSYM = os_tag == .linux,
        },
    );
    lib.root_module.addConfigHeader(config_h);
    lib.installConfigHeader(config_h);

    const fl_config_h = b.addConfigHeader(
        .{
            .style = .{ .cmake = upstream.path("fl_config.cmake.in") },
            .include_path = "FL/fl_config.h",
        },
        .{
            .FL_ABI_VERSION = "10400",
            .FLTK_USE_CAIRO = false,
            .FLTK_USE_X11 = os_tag == .linux,
            .FLTK_HAVE_CAIRO = false,
            .FLTK_USE_WAYLAND = os_tag == .linux,
        },
    );
    lib.root_module.addConfigHeader(fl_config_h);
    lib.installConfigHeader(fl_config_h);

    const zlib_dep = b.dependency("zlib", .{
        .target = target,
        .optimize = dep_optimize,
    });
    lib.linkLibrary(zlib_dep.artifact("z"));

    const libjpeg_dep = b.dependency("libjpeg", .{
        .target = target,
        .optimize = dep_optimize,
    });
    lib.linkLibrary(libjpeg_dep.artifact("jpeg"));

    const libpng_dep = b.dependency("libpng", .{
        .target = target,
        .optimize = dep_optimize,
    });
    lib.linkLibrary(libpng_dep.artifact("png"));

    addFiles(&cpp_sources, &fltk_img_cpp_srcs);

    const cpp_flags = [_][]const u8{"-std=c++11"};
    const c_flags = [_][]const u8{
        "-std=c11",
        "-D_GNU_SOURCE=1",
        "-DHAVE_MEMFD_CREATE=1",
        "-DHAVE_MKOSTEMP=1",
        "-DHAVE_POSIX_FALLOCATE=1",
    };

    if (os_tag == .linux) {
        const wayland_scanner = b.findProgram(&.{"wayland-scanner"}, &.{}) catch {
            @panic("wayland-scanner is required to build FLTK with Wayland support");
        };

        const protocols_dir = getWaylandProtocolsDir(b);

        const xdg_shell_xml_path = std.fs.path.join(b.allocator, &.{ protocols_dir, "stable", "xdg-shell", "xdg-shell.xml" }) catch @panic("oom");
        const xdg_shell = generateWaylandProtocol(b, wayland_scanner, .{ .cwd_relative = xdg_shell_xml_path }, "xdg-shell");

        const xdg_decoration_xml_path = std.fs.path.join(b.allocator, &.{ protocols_dir, "unstable", "xdg-decoration", "xdg-decoration-unstable-v1.xml" }) catch @panic("oom");
        const xdg_decoration = generateWaylandProtocol(b, wayland_scanner, .{ .cwd_relative = xdg_decoration_xml_path }, "xdg-decoration");

        const gtk_shell = generateWaylandProtocol(b, wayland_scanner, upstream.path("libdecor/build/gtk-shell.xml"), "gtk-shell");

        const text_input_xml_path = std.fs.path.join(b.allocator, &.{ protocols_dir, "unstable", "text-input", "text-input-unstable-v3.xml" }) catch @panic("oom");
        const text_input = generateWaylandProtocol(b, wayland_scanner, .{ .cwd_relative = text_input_xml_path }, "text-input");

        const protocol_outputs = [_]WaylandProtocol{ xdg_shell, xdg_decoration, gtk_shell, text_input };
        for (protocol_outputs) |proto| {
            lib.addIncludePath(proto.header.dirname());
            lib.addCSourceFile(.{ .file = proto.source, .flags = &c_flags, .language = .c });
        }

        lib.addIncludePath(upstream.path("libdecor/src"));
        lib.addIncludePath(upstream.path("libdecor/src/plugins"));
    }

    lib.addCSourceFiles(.{ .root = upstream.path(""), .files = cpp_sources.items, .flags = &cpp_flags, .language = .cpp });
    lib.addCSourceFiles(.{ .root = upstream.path(""), .files = c_sources.items, .flags = &c_flags, .language = .c });
    b.installArtifact(lib);
}
const fltk_cpp_srcs = [_][]const u8{
    "src/Fl.cxx",
    "src/Fl_Adjuster.cxx",
    "src/Fl_Bitmap.cxx",
    "src/Fl_Browser.cxx",
    "src/Fl_Browser_.cxx",
    "src/Fl_Browser_load.cxx",
    "src/Fl_Box.cxx",
    "src/Fl_Button.cxx",
    "src/Fl_Chart.cxx",
    "src/Fl_Check_Browser.cxx",
    "src/Fl_Check_Button.cxx",
    "src/Fl_Choice.cxx",
    "src/Fl_Clock.cxx",
    "src/Fl_Color_Chooser.cxx",
    "src/Fl_Copy_Surface.cxx",
    "src/Fl_Counter.cxx",
    "src/Fl_Device.cxx",
    "src/Fl_Dial.cxx",
    "src/Fl_Double_Window.cxx",
    "src/Fl_File_Browser.cxx",
    "src/Fl_File_Chooser.cxx",
    "src/Fl_File_Chooser2.cxx",
    "src/Fl_File_Icon.cxx",
    "src/Fl_File_Input.cxx",
    "src/Fl_Flex.cxx",
    "src/Fl_Graphics_Driver.cxx",
    "src/Fl_Grid.cxx",
    "src/Fl_Group.cxx",
    "src/Fl_Help_View.cxx",
    "src/Fl_Image.cxx",
    "src/Fl_Image_Surface.cxx",
    "src/Fl_Input.cxx",
    "src/Fl_Input_.cxx",
    "src/Fl_Input_Choice.cxx",
    "src/Fl_Int_Vector.cxx",
    "src/Fl_Light_Button.cxx",
    "src/Fl_Menu.cxx",
    "src/Fl_Menu_.cxx",
    "src/Fl_Menu_Bar.cxx",
    "src/Fl_Menu_Button.cxx",
    "src/Fl_Menu_Window.cxx",
    "src/Fl_Menu_add.cxx",
    "src/Fl_Menu_global.cxx",
    "src/Fl_Message.cxx",
    "src/Fl_Multi_Label.cxx",
    "src/Fl_Native_File_Chooser.cxx",
    "src/Fl_Overlay_Window.cxx",
    "src/Fl_Pack.cxx",
    "src/Fl_Paged_Device.cxx",
    "src/Fl_Pixmap.cxx",
    "src/Fl_Positioner.cxx",
    "src/Fl_Preferences.cxx",
    "src/Fl_Printer.cxx",
    "src/Fl_Progress.cxx",
    "src/Fl_Repeat_Button.cxx",
    "src/Fl_Return_Button.cxx",
    "src/Fl_Roller.cxx",
    "src/Fl_Round_Button.cxx",
    "src/Fl_Scheme.cxx",
    "src/Fl_Scheme_Choice.cxx",
    "src/Fl_Screen_Driver.cxx",
    "src/Fl_Scroll.cxx",
    "src/Fl_Scrollbar.cxx",
    "src/Fl_Shared_Image.cxx",
    "src/Fl_Shortcut_Button.cxx",
    "src/Fl_Single_Window.cxx",
    "src/Fl_Slider.cxx",
    "src/Fl_Spinner.cxx",
    "src/Fl_Sys_Menu_Bar.cxx",
    "src/Fl_System_Driver.cxx",
    "src/Fl_Table.cxx",
    "src/Fl_Table_Row.cxx",
    "src/Fl_Tabs.cxx",
    "src/Fl_Terminal.cxx",
    "src/Fl_Text_Buffer.cxx",
    "src/Fl_Text_Display.cxx",
    "src/Fl_Text_Editor.cxx",
    "src/Fl_Tile.cxx",
    "src/Fl_Tiled_Image.cxx",
    "src/Fl_Timeout.cxx",
    "src/Fl_Tooltip.cxx",
    "src/Fl_Tree.cxx",
    "src/Fl_Tree_Item_Array.cxx",
    "src/Fl_Tree_Item.cxx",
    "src/Fl_Tree_Prefs.cxx",
    "src/Fl_String.cxx",
    "src/Fl_Valuator.cxx",
    "src/Fl_Value_Input.cxx",
    "src/Fl_Value_Output.cxx",
    "src/Fl_Value_Slider.cxx",
    "src/Fl_Widget.cxx",
    "src/Fl_Widget_Surface.cxx",
    "src/Fl_Window.cxx",
    "src/Fl_Window_Driver.cxx",
    "src/Fl_Window_fullscreen.cxx",
    "src/Fl_Window_hotspot.cxx",
    "src/Fl_Window_iconize.cxx",
    "src/Fl_Wizard.cxx",
    "src/Fl_XBM_Image.cxx",
    "src/Fl_XPM_Image.cxx",
    "src/Fl_abort.cxx",
    "src/Fl_add_idle.cxx",
    "src/Fl_arg.cxx",
    "src/Fl_compose.cxx",
    "src/Fl_display.cxx",
    "src/Fl_get_system_colors.cxx",
    "src/Fl_grab.cxx",
    "src/Fl_lock.cxx",
    "src/Fl_own_colormap.cxx",
    "src/Fl_visual.cxx",
    "src/filename_absolute.cxx",
    "src/filename_expand.cxx",
    "src/filename_ext.cxx",
    "src/filename_isdir.cxx",
    "src/filename_list.cxx",
    "src/filename_match.cxx",
    "src/filename_setext.cxx",
    "src/fl_arc.cxx",
    "src/fl_ask.cxx",
    "src/fl_boxtype.cxx",
    "src/fl_color.cxx",
    "src/fl_contrast.cxx",
    "src/fl_cursor.cxx",
    "src/fl_curve.cxx",
    "src/fl_diamond_box.cxx",
    "src/fl_draw.cxx",
    "src/fl_draw_arrow.cxx",
    "src/fl_draw_pixmap.cxx",
    "src/fl_encoding_latin1.cxx",
    "src/fl_encoding_mac_roman.cxx",
    "src/fl_engraved_label.cxx",
    "src/fl_file_dir.cxx",
    "src/fl_font.cxx",
    "src/fl_gleam.cxx",
    "src/fl_gtk.cxx",
    "src/fl_labeltype.cxx",
    "src/fl_open_uri.cxx",
    "src/fl_oval_box.cxx",
    "src/fl_overlay.cxx",
    "src/fl_oxy.cxx",
    "src/fl_plastic.cxx",
    "src/fl_read_image.cxx",
    "src/fl_rect.cxx",
    "src/fl_round_box.cxx",
    "src/fl_rounded_box.cxx",
    "src/fl_set_font.cxx",
    "src/fl_scroll_area.cxx",
    "src/fl_shadow_box.cxx",
    "src/fl_shortcut.cxx",
    "src/fl_show_colormap.cxx",
    "src/fl_string_functions.cxx",
    "src/fl_symbols.cxx",
    "src/fl_utf8.cxx",
    "src/fl_vertex.cxx",
    "src/print_button.cxx",
    "src/screen_xywh.cxx",
};

const fltk_c_srcs = [_][]const u8{
    "src/flstring.c",
    "src/numericsort.c",
    "src/vsnprintf.c",
    "src/xutf8/is_right2left.c",
    "src/xutf8/is_spacing.c",
    "src/xutf8/case.c",
};

const fltk_img_cpp_srcs = [_][]const u8{
    "src/fl_images_core.cxx",
    "src/fl_write_png.cxx",
    "src/Fl_BMP_Image.cxx",
    "src/Fl_File_Icon2.cxx",
    "src/Fl_GIF_Image.cxx",
    "src/Fl_Anim_GIF_Image.cxx",
    "src/Fl_Help_Dialog.cxx",
    "src/Fl_ICO_Image.cxx",
    "src/Fl_JPEG_Image.cxx",
    "src/Fl_PNG_Image.cxx",
    "src/Fl_PNM_Image.cxx",
    "src/Fl_Image_Reader.cxx",
    "src/Fl_SVG_Image.cxx",
    "src/nanosvg.cxx",
    "src/drivers/SVG/Fl_SVG_File_Surface.cxx",
};

const fltk_postscript_cpp_srcs = [_][]const u8{
    "src/drivers/PostScript/Fl_PostScript.cxx",
    "src/drivers/PostScript/Fl_PostScript_image.cxx",
};
///////////////////
/// DRIVER
//////////////////

const fltk_driver_winapi_cpp_srcs = [_][]const u8{
    "src/drivers/WinAPI/Fl_WinAPI_System_Driver.cxx",
    "src/drivers/WinAPI/Fl_WinAPI_Screen_Driver.cxx",
    "src/drivers/WinAPI/Fl_WinAPI_Window_Driver.cxx",
    "src/drivers/WinAPI/Fl_WinAPI_Printer_Driver.cxx",
    "src/drivers/GDI/Fl_GDI_Graphics_Driver.cxx",
    "src/drivers/GDI/Fl_GDI_Graphics_Driver_arci.cxx",
    "src/drivers/GDI/Fl_GDI_Graphics_Driver_color.cxx",
    "src/drivers/GDI/Fl_GDI_Graphics_Driver_font.cxx",
    "src/drivers/GDI/Fl_GDI_Graphics_Driver_image.cxx",
    "src/drivers/GDI/Fl_GDI_Graphics_Driver_line_style.cxx",
    "src/drivers/GDI/Fl_GDI_Graphics_Driver_rect.cxx",
    "src/drivers/GDI/Fl_GDI_Graphics_Driver_vertex.cxx",
    "src/drivers/GDI/Fl_GDI_Copy_Surface_Driver.cxx",
    "src/drivers/GDI/Fl_GDI_Image_Surface_Driver.cxx",
    "src/Fl_win32.cxx",
    "src/fl_dnd_win32.cxx",
    "src/Fl_Native_File_Chooser_WIN32.cxx",
    "src/Fl_get_key_win32.cxx",
    "src/drivers/WinAPI/fl_WinAPI_platform_init.cxx",
};

const fltk_driver_winapi_c_srcs = [_][]const u8{
    "src/scandir_win32.c",
    "src/fl_call_main.c",
};

//wayland + x11
const fltk_driver_linux_cpp_srcs = [_][]const u8{
    "src/drivers/Wayland/Fl_Wayland_Screen_Driver.cxx",
    "src/drivers/Wayland/Fl_Wayland_Window_Driver.cxx",
    "src/drivers/Wayland/Fl_Wayland_Graphics_Driver.cxx",
    "src/drivers/Wayland/Fl_Wayland_Copy_Surface_Driver.cxx",
    "src/drivers/Wayland/Fl_Wayland_Image_Surface_Driver.cxx",
    "src/drivers/Wayland/fl_wayland_clipboard_dnd.cxx",
    "src/drivers/Wayland/fl_wayland_platform_init.cxx",

    "src/drivers/Posix/Fl_Posix_System_Driver.cxx",
    "src/drivers/Posix/Fl_Posix_Printer_Driver.cxx",
    "src/drivers/Unix/Fl_Unix_Screen_Driver.cxx",
    "src/drivers/Unix/Fl_Unix_System_Driver.cxx",
    "src/drivers/Cairo/Fl_Cairo_Graphics_Driver.cxx",
    "src/Fl_Native_File_Chooser_FLTK.cxx",
    "src/Fl_Native_File_Chooser_GTK.cxx",
    "src/Fl_Native_File_Chooser_Kdialog.cxx",
    "src/Fl_Native_File_Chooser_Zenity.cxx",
    "src/drivers/Cairo/Fl_X11_Cairo_Graphics_Driver.cxx",
    "src/drivers/X11/Fl_X11_Screen_Driver.cxx",
    "src/drivers/X11/Fl_X11_Window_Driver.cxx",
    "src/drivers/Xlib/Fl_Xlib_Copy_Surface_Driver.cxx",
    "src/drivers/Xlib/Fl_Xlib_Image_Surface_Driver.cxx",
    "src/Fl_x.cxx",
    "src/fl_dnd_x.cxx",
    "src/Fl_get_key.cxx",
};

const fltk_driver_linux_c_srcs = [_][]const u8{
    "libdecor/build/fl_libdecor.c",
    "libdecor/build/fl_libdecor-plugins.c",
    "libdecor/src/os-compatibility.c",
    "libdecor/src/desktop-settings.c",
    "libdecor/src/plugins/common/libdecor-cairo-blur.c",
};

const linux_system_libs = [_][]const u8{
    "pthread",
    "dl",
    "m",
    "X11",
    "Xext",
    "Xft",
    "fontconfig",
    "pangocairo-1.0",
    "cairo",
    "wayland-cursor",
    "wayland-client",
    "xkbcommon",
};

const windows_system_libs = [_][]const u8{
    "gdi32",
    "user32",
    "shell32",
    "ole32",
    "oleaut32",
    "uuid",
    "comctl32",
    "comdlg32",
    "advapi32",
    "ws2_32",
    "winspool",
};
