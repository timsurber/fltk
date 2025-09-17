/* FL/fl_config.h - FLTK public configuration for Zig build */
#ifndef _FL_fl_config_h_
#define _FL_fl_config_h_

#define FL_ABI_VERSION 10404

#undef FLTK_HAVE_CAIRO
#undef FLTK_HAVE_CAIROEXT
#undef FLTK_HAVE_PANGO
#undef FLTK_HAVE_PANGOCAIRO
#define FLTK_USE_CAIRO 0
#define FLTK_USE_PANGO 0
#define FLTK_HAVE_FORMS 1

#define FLTK_USE_X11 1
#define FLTK_USE_STD 0
#define FLTK_USE_WAYLAND 0
#define FLTK_USE_SVG 0

#endif /* _FL_fl_config_h_ */
