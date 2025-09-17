/* config.h.  Generated from config.h.in by CMake.  */
/*
 * Configuration file for the Fast Light Tool Kit (FLTK). This file is used
 * internally in the FLTK library and is not publicly available (not installed).
 *
 * Copyright 1998-2025 by Bill Spitzak and others.
 *
 * This library is free software. Distribution and use rights are outlined in
 * the file "COPYING" which should have been included with this file.  If this
 * file is missing or damaged, see the license at:
 *
 *     https://www.fltk.org/COPYING.php
 *
 * Please see the following page on how to report bugs and issues:
 *
 *     https://www.fltk.org/bugs.php
 */

/*
 * Note: CMake syntax in input file (examples):
 *
 *   For instance in config.h.in (remove brackets for real syntax):
 *   ----------------------------------------------------------------
 *   [#]cmakedefine01  HAVE_GL
 *   [#]cmakedefine    HAVE_SNPRINTF  1
 *
 *   The former defines HAVE_GL either as 0 or 1.
 *
 *   The latter either doesn't define HAVE_SNPRINTF or defines it as 1.
 *   The value (1 in the example) can be an arbitrary number or string.
 */

/*
 * Always include the public build configuration header
 */

#include <FL/fl_config.h>

/*
 * Where to find files...
 */

#define FLTK_DATADIR "/usr/local/share/fltk"
#define FLTK_DOCDIR "/usr/local/share/doc/fltk"

/*
 * BORDER_WIDTH:
 *
 * Thickness of FL_UP_BOX and FL_DOWN_BOX.  Current 1,2, and 3 are
 * supported.
 *
 * 3 is the historic FLTK look.
 * 2 is the default and looks like Microsoft Windows, KDE, and Qt.
 * 1 is a plausible future evolution...
 *
 * Note that this may be simulated at runtime by redefining the boxtypes
 * using Fl::set_boxtype().
 */

#define BORDER_WIDTH 2

/*
 * HAVE_GL:
 *
 * Do you have OpenGL? Set this to 0 if you don't have or plan to use
 * OpenGL, and FLTK will be smaller.
 */

#define HAVE_GL 0

/*
 * HAVE_GL_GLU_H:
 *
 * Do you have the OpenGL Utility Library header file?
 * (many broken Mesa RPMs do not...)
 */

#define HAVE_GL_GLU_H 0

/*
 * HAVE_GLXGETPROCADDRESSARB:
 *
 * Do you have the OpenGL glXGetProcAddressARB() function?
 */

#define HAVE_GLXGETPROCADDRESSARB 0

/*
 * USE_COLORMAP:
 *
 * Setting this to zero will save a good deal of code (especially for
 * fl_draw_image), but FLTK will only work on TrueColor visuals.
 */

#define USE_COLORMAP 1

/*
 * HAVE_XINERAMA
 *
 * Do we have the Xinerama library to support multi-head displays?
 */

#define HAVE_XINERAMA 0

/*
 * USE_XFT
 *
 * Use the Xft library to draw anti-aliased text.
 */

#define USE_XFT 0

/*
 * USE_PANGO
 *
 * Use the pango library to draw UTF-8 text.
 */

#define USE_PANGO 0

/*
 * HAVE_XFIXES:
 *
 * Do we have the X fixes extension?
 */

#define HAVE_XFIXES 0

/*
 * HAVE_XCURSOR:
 *
 * Do we have the X cursor library?
 */

#define HAVE_XCURSOR 0

/*
 * HAVE_XRENDER:
 *
 * Do we have the X render library?
 */

#define HAVE_XRENDER 0

/*
 * HAVE_X11_XREGION_H:
 *
 * Do we have the X11 Xregion.h header file ?
 */

/* #undef HAVE_X11_XREGION_H */

/*
 * HAVE_GL_OVERLAY:
 *
 * It is possible your GL has an overlay even if X does not.  If so,
 * set this to 1.
 */

#define HAVE_GL_OVERLAY 0

/*
 * WORDS_BIGENDIAN:
 *
 * Byte order of your machine: 1 = big-endian, 0 = little-endian.
 */

#ifdef __APPLE__
#include <mac_endianness.h>
#else
#define WORDS_BIGENDIAN 0
#endif

/*
 * U16, U32, U64:
 *
 * Types used by fl_draw_image.  One of U32 or U64 must be defined.
 * U16 is optional but FLTK will work better with it!
 */

#define U16 unsigned short
#define U32 unsigned
#define U64 unsigned long

/*
 * HAVE_DIRENT_H, HAVE_SYS_NDIR_H, HAVE_SYS_DIR_H, HAVE_NDIR_H,
 * HAVE_SCANDIR, HAVE_SCANDIR_POSIX:
 *
 * Where is <dirent.h> (used only by fl_file_chooser and scandir).
 */

/* #undef HAVE_DIRENT_H */
/* #undef HAVE_SYS_NDIR_H */
/* #undef HAVE_SYS_DIR_H */
/* #undef HAVE_NDIR_H */
/* #undef HAVE_SCANDIR */
/* #undef HAVE_SCANDIR_POSIX */

/*
 * Possibly missing sprintf-style functions:
 */

#define HAVE_VSNPRINTF 1
#define HAVE_SNPRINTF 1

/*
 * String functions and headers...
 */

/* #undef HAVE_STRINGS_H */
/* #undef HAVE_STRCASECMP */
/* #undef HAVE_STRLCAT */
/* #undef HAVE_STRLCPY */

/*
 * Do we have POSIX locale support?
 */

#define HAVE_LOCALE_H 1
#define HAVE_LOCALECONV 1

/*
 * HAVE_SYS_SELECT_H:
 *
 * Whether or not select() call has its own header file.
 */

/* #undef HAVE_SYS_SELECT_H */

/*
 * HAVE_SYS_STDTYPES_H:
 *
 * Whether or not we have the <sys/stdtypes.h> header file.
 */

/* #undef HAVE_SYS_STDTYPES_H */

/*
 * USE_POLL:
 *
 * Use the poll() call provided on Linux and Irix instead of select()
 */

#define USE_POLL 0

/*
 * HAVE_SETENV:
 *
 * Whether or not POSIX setenv() is available from stdlib.h.
 */

/* #undef HAVE_SETENV */

/*
 * HAVE_TRUNC:
 *
 * Whether or not POSIX trunc() is available from math.h.
 */

#define HAVE_TRUNC 1

/*
 * Do we have various image libraries?
 */

#define HAVE_LIBPNG 0
#define HAVE_LIBZ 0
#define HAVE_LIBJPEG 0

/*
 * Which header file do we include for libpng?
 *   ifdef HAVE_PNG_H : <png.h>
 *   else             : <libpng/png.h>
 * There is no other choice.
 */

#define HAVE_PNG_H 0

/*
 * Do we have the png_xyz() functions?
 */

#define HAVE_PNG_GET_VALID 0
#define HAVE_PNG_SET_TRNS_TO_ALPHA 0


/*
 * Do we have POSIX threading?
 */

/* #undef HAVE_PTHREAD */
/* #undef HAVE_PTHREAD_H */

/*
 * Do we have PTHREAD_MUTEX_RECURSIVE?
 */

/* #undef HAVE_PTHREAD_MUTEX_RECURSIVE */

/*
 * Do we have the ALSA library?
 */

/* #undef HAVE_ALSA_ASOUNDLIB_H */

/*
 * Do we have the long long type?
 */

#define HAVE_LONG_LONG 1

#ifdef HAVE_LONG_LONG
#  define FLTK_LLFMT	"%lld"
#  define FLTK_LLCAST	(long long)
#else
#  define FLTK_LLFMT	"%ld"
#  define FLTK_LLCAST	(long)
#endif /* HAVE_LONG_LONG */

/*
 * Do we have the dlsym() function and header?
 */

/* #undef HAVE_DLFCN_H */
/* #undef HAVE_DLSYM */

/*
 * Do we want print support?
 */

/* #undef FL_NO_PRINT_SUPPORT */

/*
 * Do we use GDI+ to get antialiased graphics?
 */

#ifdef _WIN32
#define USE_GDIPLUS 0
#endif

/*
 * Do we want filename handling and a filechooser?
 */

/* #undef FL_CFG_NO_FILESYSTEM_SUPPORT */
