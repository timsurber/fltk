const std = @import("std");

fn addFiles(list: *std.ArrayList([]const u8), files: []const []const u8) void {
    for (files) |file| {
        list.append(file) catch @panic("oom");
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const upstream = b.dependency("fltk", .{});

    const img_support = b.option(
        bool,
        "img_support",
        "Build FLTK with image support. Links static zlib, libpng and libjpg",
    ) orelse true;

    const opengl_support = b.option(
        bool,
        "opengl_support",
        "Build FLTK with opengl support",
    ) orelse true;

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
            addFiles(&cpp_sources, &fltk_driver_x11_cpp_srcs);
            addFiles(&c_sources, &fltk_driver_x11_c_srcs);
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
    lib.addIncludePath(upstream.path("GL"));

    const header_dir_opts = std.Build.Step.Compile.HeaderInstallation.Directory.Options{
        .include_extensions = &.{ ".h", ".H" },
    };
    lib.installHeadersDirectory(upstream.path("FL"), "FL", header_dir_opts);
    lib.installHeadersDirectory(upstream.path("GL"), "GL", header_dir_opts);
    lib.installHeader(upstream.path("forms.h"), "forms.h");
    lib.installHeader(upstream.path("mac_endianness.h"), "mac_endianness.h");

    lib.root_module.addCMacro("FL_LIBRARY", "1");
    lib.root_module.addCMacro("_FILE_OFFSET_BITS", "64");
    lib.root_module.addCMacro("_LARGEFILE64_SOURCE", "1");
    lib.root_module.addCMacro("_LARGEFILE_SOURCE", "1");
    lib.root_module.addCMacro("_REENTRANT", "1");
    lib.root_module.addCMacro("_THREAD_SAFE", "1");

    const img_support_u8: u8 = @as(u8, @intFromBool(img_support));
    const use_x11_u8: u8 = @as(u8, @intFromBool(os_tag == .linux));
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
            .HAVE_GL = opengl_support,
            // TODO when to enable these?
            .HAVE_GL_GLU_H = os_tag == .linux,
            .HAVE_GLXGETPROCADDRESSARB = os_tag == .linux,
            .HAVE_XINERAMA = 0,
            .USE_XFT = 0,
            .USE_PANGO = 0,
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
            .HAVE_LIBPNG = img_support_u8,
            .HAVE_LIBZ = img_support_u8,
            .HAVE_LIBJPEG = img_support_u8,
            .HAVE_PNG_H = img_support_u8,
            .HAVE_PNG_GET_VALID = img_support_u8,
            .HAVE_PNG_SET_TRNS_TO_ALPHA = img_support_u8,
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
            .FLTK_USE_X11 = use_x11_u8,
        },
    );
    lib.root_module.addConfigHeader(fl_config_h);
    lib.installConfigHeader(fl_config_h);

    if (img_support) {
        const zlib_dep = b.dependency("zlib", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(zlib_dep.artifact("z"));

        const libjpeg_dep = b.dependency("libjpeg", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(libjpeg_dep.artifact("jpeg"));

        const libpng_dep = b.dependency("libpng", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(libpng_dep.artifact("png"));

        addFiles(&cpp_sources, &fltk_img_cpp_srcs);
    }

    if (opengl_support) {
        addFiles(&cpp_sources, &fltk_gl_cpp_srcs);
        addFiles(&cpp_sources, &fltk_driver_gl_cpp_srcs);
        if (os_tag == .linux) {
            addFiles(&cpp_sources, &fltk_driver_gl_x11_cpp_srcs);
        }
    }

    const cpp_flags = [_][]const u8{"-std=c++11"};
    const c_flags = [_][]const u8{"-std=c11"};

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

const fltk_gl_cpp_srcs = [_][]const u8{
    "src/Fl_Gl_Choice.cxx",
    "src/Fl_Gl_Device_Plugin.cxx",
    "src/Fl_Gl_Overlay.cxx",
    "src/Fl_Gl_Window.cxx",
    "src/freeglut_geometry.cxx",
    "src/freeglut_stroke_mono_roman.cxx",
    "src/freeglut_stroke_roman.cxx",
    "src/freeglut_teapot.cxx",
    "src/gl_draw.cxx",
    "src/gl_start.cxx",
    "src/glut_compatibility.cxx",
    "src/glut_font.cxx",
};

const fltk_postscript_cpp_srcs = [_][]const u8{
    "src/drivers/PostScript/Fl_PostScript.cxx",
    "src/drivers/PostScript/Fl_PostScript_image.cxx",
};

const fltk_driver_x11_cpp_srcs = [_][]const u8{
    "src/drivers/Posix/Fl_Posix_Printer_Driver.cxx",
    "src/drivers/X11/Fl_X11_Screen_Driver.cxx",
    "src/drivers/X11/Fl_X11_Window_Driver.cxx",
    "src/drivers/Posix/Fl_Posix_System_Driver.cxx",
    "src/drivers/Unix/Fl_Unix_System_Driver.cxx",
    "src/drivers/Unix/Fl_Unix_Screen_Driver.cxx",
    "src/drivers/Xlib/Fl_Xlib_Copy_Surface_Driver.cxx",
    "src/drivers/Xlib/Fl_Xlib_Image_Surface_Driver.cxx",
    "src/drivers/X11/fl_X11_platform_init.cxx",
    "src/Fl_x.cxx",
    "src/fl_dnd_x.cxx",
    "src/Fl_Native_File_Chooser_FLTK.cxx",
    "src/Fl_Native_File_Chooser_GTK.cxx",
    "src/Fl_get_key.cxx",
    "src/Fl_Native_File_Chooser_Kdialog.cxx",
    "src/Fl_Native_File_Chooser_Zenity.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_font_x.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_arci.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_color.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_image.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_line_style.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_rect.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_vertex.cxx",
};

const fltk_driver_x11_c_srcs = [_][]const u8{
    "src/xutf8/keysym2Ucs.c",
    "src/scandir_posix.c",
    "src/xutf8/utf8Utils.c",
    "src/xutf8/utf8Input.c",
    "src/xutf8/utf8Wrap.c",
};

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

const fltk_driver_gl_cpp_srcs = [_][]const u8{
    "src/drivers/OpenGL/Fl_OpenGL_Display_Device.cxx",
    //the following file doesn't contribute any code:
    "src/drivers/OpenGL/Fl_OpenGL_Graphics_Driver.cxx",
    "src/drivers/OpenGL/Fl_OpenGL_Graphics_Driver_arci.cxx",
    "src/drivers/OpenGL/Fl_OpenGL_Graphics_Driver_color.cxx",
    "src/drivers/OpenGL/Fl_OpenGL_Graphics_Driver_font.cxx",
    "src/drivers/OpenGL/Fl_OpenGL_Graphics_Driver_line_style.cxx",
    "src/drivers/OpenGL/Fl_OpenGL_Graphics_Driver_rect.cxx",
    "src/drivers/OpenGL/Fl_OpenGL_Graphics_Driver_vertex.cxx",
};

const fltk_driver_gl_x11_cpp_srcs = [_][]const u8{
    "src/drivers/X11/Fl_X11_Gl_Window_Driver.cxx",
};

const linux_system_libs = [_][]const u8{
    "pthread",
    "dl",
    "m",
    "X11",
    "Xext",
    "GL",
    "GLU",
    "glew",
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
