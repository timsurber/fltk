/*
 * Configuration file for the Fast Light Tool Kit (FLTK).
 *
 * Tailored for the Zig example build targeting Linux/X11 with minimal
 * external library requirements.
 */

#include <FL/fl_config.h>

#define FLTK_DATADIR ""
#define FLTK_DOCDIR ""

#define BORDER_WIDTH 2

#define HAVE_GL 1
#define HAVE_GL_GLU_H 1
#define HAVE_GLXGETPROCADDRESSARB 1

#define USE_COLORMAP 1

#define HAVE_XINERAMA 0
#define USE_XFT 0
#define USE_PANGO 0
#define HAVE_XFIXES 0
#define HAVE_XCURSOR 0
#define HAVE_XRENDER 0
#define HAVE_X11_XREGION_H 0

#define HAVE_GL_OVERLAY 0

#ifdef __APPLE__
#include <mac_endianness.h>
#else
#define WORDS_BIGENDIAN 0
#endif

#define U16 unsigned short
#define U32 unsigned int
#define U64 unsigned long long

#define HAVE_DIRENT_H 1
#undef HAVE_SYS_NDIR_H
#undef HAVE_SYS_DIR_H
#undef HAVE_NDIR_H
#define HAVE_SCANDIR 1
#define HAVE_SCANDIR_POSIX 1

#define HAVE_VSNPRINTF 1
#define HAVE_SNPRINTF 1

#define HAVE_STRINGS_H 1
#define HAVE_STRCASECMP 1
#undef HAVE_STRLCAT
#undef HAVE_STRLCPY

#define HAVE_LOCALE_H 1
#define HAVE_LOCALECONV 1

#define HAVE_SYS_SELECT_H 1
#undef HAVE_SYS_STDTYPES_H

#define USE_POLL 1

#define HAVE_SETENV 1
#define HAVE_TRUNC 1

#define HAVE_LIBPNG 1
#define HAVE_LIBZ 1
#define HAVE_LIBJPEG 1

#define HAVE_PNG_H 1
#define HAVE_PNG_GET_VALID 1
#define HAVE_PNG_SET_TRNS_TO_ALPHA 1

#define HAVE_PTHREAD 1
#define HAVE_PTHREAD_H 1
#define HAVE_PTHREAD_MUTEX_RECURSIVE 1

#undef HAVE_ALSA_ASOUNDLIB_H

#define HAVE_LONG_LONG 1
#define FLTK_LLFMT "%lld"
#define FLTK_LLCAST (long long)

#define HAVE_DLFCN_H 1
#define HAVE_DLSYM 1

#undef FL_NO_PRINT_SUPPORT

#ifdef _WIN32
#define USE_GDIPLUS 0
#endif

#undef FL_CFG_NO_FILESYSTEM_SUPPORT
