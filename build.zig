const std = @import("std");

const base_cpp_files = [_][]const u8{
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

const x11_driver_base = [_][]const u8{
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
};

const img_cpp_files = [_][]const u8{
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

const jpeg_srcs = [_][]const u8{
    "jpeg/jmemnobs.c",
    "jpeg/jaricom.c",
    "jpeg/jcomapi.c",
    "jpeg/jutils.c",
    "jpeg/jerror.c",
    "jpeg/jmemmgr.c",
    "jpeg/jcapimin.c",
    "jpeg/jcapistd.c",
    "jpeg/jcarith.c",
    "jpeg/jctrans.c",
    "jpeg/jcparam.c",
    "jpeg/jdatadst.c",
    "jpeg/jcinit.c",
    "jpeg/jcmaster.c",
    "jpeg/jcmarker.c",
    "jpeg/jcmainct.c",
    "jpeg/jcprepct.c",
    "jpeg/jccoefct.c",
    "jpeg/jccolor.c",
    "jpeg/jcsample.c",
    "jpeg/jchuff.c",
    "jpeg/jcdctmgr.c",
    "jpeg/jfdctfst.c",
    "jpeg/jfdctflt.c",
    "jpeg/jfdctint.c",
    "jpeg/jdapimin.c",
    "jpeg/jdapistd.c",
    "jpeg/jdarith.c",
    "jpeg/jdtrans.c",
    "jpeg/jdatasrc.c",
    "jpeg/jdmaster.c",
    "jpeg/jdinput.c",
    "jpeg/jdmarker.c",
    "jpeg/jdhuff.c",
    "jpeg/jdmainct.c",
    "jpeg/jdcoefct.c",
    "jpeg/jdpostct.c",
    "jpeg/jddctmgr.c",
    "jpeg/jidctfst.c",
    "jpeg/jidctflt.c",
    "jpeg/jidctint.c",
    "jpeg/jdsample.c",
    "jpeg/jdcolor.c",
    "jpeg/jquant1.c",
    "jpeg/jquant2.c",
    "jpeg/jdmerge.c",
};

const zlib_srcs = [_][]const u8{ "zlib/adler32.c", "zlib/compress.c", "zlib/crc32.c", "zlib/deflate.c", "zlib/gzclose.c", "zlib/gzlib.c", "zlib/gzread.c", "zlib/gzwrite.c", "zlib/inflate.c", "zlib/infback.c", "zlib/inftrees.c", "zlib/inffast.c", "zlib/trees.c", "zlib/uncompr.c", "zlib/zutil.c" };

const png_srcs = [_][]const u8{ "png/png.c", "png/pngerror.c", "png/pngget.c", "png/pngmem.c", "png/pngpread.c", "png/pngread.c", "png/pngrio.c", "png/pngrtran.c", "png/pngrutil.c", "png/pngset.c", "png/pngtrans.c", "png/pngwio.c", "png/pngwrite.c", "png/pngwtran.c", "png/pngwutil.c" };

const x11_driver_extras = [_][]const u8{
    "src/Fl_Native_File_Chooser_Kdialog.cxx",
    "src/Fl_Native_File_Chooser_Zenity.cxx",
};

const xlib_font_driver = [_][]const u8{
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_font_x.cxx",
};

const xlib_core_driver = [_][]const u8{
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_arci.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_color.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_image.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_line_style.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_rect.cxx",
    "src/drivers/Xlib/Fl_Xlib_Graphics_Driver_vertex.cxx",
};

const postscript_cpp_files = [_][]const u8{
    "src/drivers/PostScript/Fl_PostScript.cxx",
    "src/drivers/PostScript/Fl_PostScript_image.cxx",
};

const winapi_driver_cpp = [_][]const u8{
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

const winapi_c_files = [_][]const u8{
    "src/scandir_win32.c",
    "src/fl_call_main.c",
};

const base_c_files = [_][]const u8{
    "src/flstring.c",
    "src/numericsort.c",
    "src/vsnprintf.c",
    "src/xutf8/is_right2left.c",
    "src/xutf8/is_spacing.c",
    "src/xutf8/case.c",
};

const x11_c_files = [_][]const u8{
    "src/xutf8/keysym2Ucs.c",
    "src/scandir_posix.c",
    "src/xutf8/utf8Utils.c",
    "src/xutf8/utf8Input.c",
    "src/xutf8/utf8Wrap.c",
};

fn appendUnique(list: *std.ArrayList([]const u8), value: []const u8) void {
    for (list.items) |existing| {
        if (std.mem.eql(u8, existing, value)) return;
    }
    list.appendAssumeCapacity(value);
}

fn addFiles(list: *std.ArrayList([]const u8), files: []const []const u8) void {
    for (files) |file| {
        appendUnique(list, file);
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const fltk_dep = b.dependency("fltk", .{});

    const os_tag = target.result.os.tag;
    if (os_tag != .linux and os_tag != .windows) {
        @panic("zig build currently supports only Linux (X11) and Windows (WinAPI) targets");
    }

    var cpp_sources = std.ArrayList([]const u8).init(b.allocator);
    defer cpp_sources.deinit();

    var c_sources = std.ArrayList([]const u8).init(b.allocator);
    defer c_sources.deinit();

    var estimated_cpp = base_cpp_files.len + postscript_cpp_files.len;
    var estimated_c = base_c_files.len;

    switch (os_tag) {
        .linux => {
            estimated_cpp += x11_driver_base.len + x11_driver_extras.len + xlib_font_driver.len + xlib_core_driver.len;
            estimated_c += x11_c_files.len;
        },
        .windows => {
            estimated_cpp += winapi_driver_cpp.len;
            estimated_c += winapi_c_files.len;
        },
        else => unreachable,
    }

    const use_images = true;

    if (use_images) {
        estimated_cpp += img_cpp_files.len;
        estimated_c += jpeg_srcs.len;
        estimated_c += zlib_srcs.len;
        estimated_c += png_srcs.len;
    }

    cpp_sources.ensureTotalCapacity(estimated_cpp) catch @panic("oom");
    c_sources.ensureTotalCapacity(estimated_c) catch @panic("oom");

    addFiles(&cpp_sources, &base_cpp_files);
    addFiles(&cpp_sources, &postscript_cpp_files);
    if (use_images) {
        addFiles(&cpp_sources, &img_cpp_files);
        addFiles(&c_sources, &jpeg_srcs);
        addFiles(&c_sources, &zlib_srcs);
        addFiles(&c_sources, &png_srcs);
    }
    addFiles(&c_sources, &base_c_files);

    switch (os_tag) {
        .linux => {
            addFiles(&cpp_sources, &x11_driver_base);
            addFiles(&cpp_sources, &x11_driver_extras);
            addFiles(&cpp_sources, &xlib_font_driver);
            addFiles(&cpp_sources, &xlib_core_driver);
            addFiles(&c_sources, &x11_c_files);
        },
        .windows => {
            addFiles(&cpp_sources, &winapi_driver_cpp);
            addFiles(&c_sources, &winapi_c_files);
        },
        else => unreachable,
    }

    const lib = b.addStaticLibrary(.{
        .name = "fltk",
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibC();
    lib.linkLibCpp();

    lib.root_module.addIncludePath(fltk_dep.path("."));
    lib.root_module.addIncludePath(fltk_dep.path("src"));
    lib.root_module.addIncludePath(fltk_dep.path("GL"));
    lib.root_module.addIncludePath(fltk_dep.path("jpeg"));
    lib.root_module.addIncludePath(fltk_dep.path("png"));
    lib.root_module.addIncludePath(fltk_dep.path("zlib"));
    lib.root_module.addIncludePath(b.path("zig-config"));

    lib.root_module.addCMacro("FL_LIBRARY", "1");
    lib.root_module.addCMacro("_FILE_OFFSET_BITS", "64");
    lib.root_module.addCMacro("_LARGEFILE64_SOURCE", "1");
    lib.root_module.addCMacro("_LARGEFILE_SOURCE", "1");
    lib.root_module.addCMacro("_REENTRANT", "1");
    lib.root_module.addCMacro("_THREAD_SAFE", "1");

    const cxx_flags = [_][]const u8{"-std=c++11"};
    const c_flags = [_][]const u8{"-std=c11"};

    for (cpp_sources.items) |file| {
        lib.root_module.addCSourceFile(.{
            .file = fltk_dep.path(file),
            .flags = &cxx_flags,
            .language = .cpp,
        });
    }

    for (c_sources.items) |file| {
        lib.root_module.addCSourceFile(.{
            .file = fltk_dep.path(file),
            .flags = &c_flags,
            .language = .c,
        });
    }

    b.installArtifact(lib);

    const build_step = b.step("fltk", "Build the FLTK static library");
    build_step.dependOn(&lib.step);
}
