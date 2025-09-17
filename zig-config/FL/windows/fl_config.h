/* FL/fl_config.h.  Generated from fl_config.h.in by CMake.  */
/*
 * Build configuration file for the Fast Light Tool Kit (FLTK). This
 * configuration file is publicly accessible by user programs (installed).
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

#ifndef _FL_fl_config_h_
#define _FL_fl_config_h_

/** \defgroup version_numbers Version Numbers

  FLTK defines some constants to help the programmer to
  find out, for which FLTK version a program is compiled.

  The following constants are defined:
  @{
*/

/**
  The major release version of this FLTK library.
  \see FL_VERSION
*/
#define FL_MAJOR_VERSION 1

/**
  The minor release version for this library.

  FLTK remains mostly source-code compatible between minor version changes.
*/
#define FL_MINOR_VERSION 4

/**
  The patch version for this library.

  FLTK remains binary compatible between patch versions.
*/
#define FL_PATCH_VERSION 4

/**
  The FLTK ABI (Application Binary Interface) version number as an \em int.

  FL_ABI_VERSION is an \em int that describes the major, minor, and patch
  ABI version numbers in the same format as FL_API_VERSION.

  The ABI version number \p FL_ABI_VERSION is usually the same as the
  API version \p FL_API_VERSION with the last two digits set to '00'.

  FLTK retains the ABI (Application Binary Interface) during patch
  releases of the same major and minor versions. Examples:

  \verbatim
    FLTK Version  FL_API_VERSION  FL_ABI_VERSION  FL_VERSION (deprecated)
      1.3.0          10300           10300           1.0300
      1.3.4          10304           10300           1.0304
  \endverbatim

  Version 1.2.3 is actually stored as 10203 to allow for more than 9 minor
  and patch releases.

  The FL_MAJOR_VERSION, FL_MINOR_VERSION, and FL_PATCH_VERSION constants
  give the integral values for the major, minor, and patch releases
  respectively.

  To enable new ABI-breaking features in patch releases you can configure
  FLTK to use a higher FL_ABI_VERSION. The highest allowed version is

    FL_ABI_VERSION = FL_API_VERSION + 1

  to allow for "next version" ABI features when FLTK is built from git or
  from a snapshot (pre-release version).

  \see README.abi-version.txt
*/

#define FL_ABI_VERSION 10400

/** @} */

// End of doxygen group 'version_numbers'. More is added to the group in
// in file FL/Enumerations.H

/*
 * FLTK_HAVE_CAIRO
 *
 * Do we have Fl_Cairo_Window support?
*/

/* #undef FLTK_HAVE_CAIRO */


/*
 * FLTK_HAVE_CAIROEXT
 *
 * Do we have the Cairo library available and want extended Cairo use in FLTK ?
 * This implies to link cairo.lib in all FLTK based apps.
*/

/* #undef FLTK_HAVE_CAIROEXT */


/*
 * FLTK_HAVE_FORMS
 *
 * Do we have the Forms compatibility library available?
*/

/* #undef FLTK_HAVE_FORMS */


/*
 * FLTK_USE_X11
 *
 * Do we use X11 for the current platform?
 *
 */

/* #undef FLTK_USE_X11 */


/*
 * FLTK_USE_CAIRO
 *
 * Do we use Cairo to draw to the display?
 *
 */

#define FLTK_USE_CAIRO 0


/*
 * FLTK_USE_WAYLAND
 *
 * Do we use Wayland for the current platform?
 *
 */

/* #undef FLTK_USE_WAYLAND */


/*
 * FLTK_USE_SVG
 *
 * Do we want FLTK to read and write SVG-formatted files ?
 *
 */

#define FLTK_USE_SVG 1


#endif /* _FL_fl_config_h_ */
