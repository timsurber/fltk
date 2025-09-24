#  Zig build for [Fast Light Tool Kit (FLTK)](https://github.com/fltk/fltk). 
The Fast Light Tool Kit (FLTK) is a cross-platform C++ GUI toolkit for UNIX®/Linux® (X11 or Wayland), Microsoft® Windows®, and macOS®.

This allows to build FLTK with the Zig build system. You can easily cross-compile an FLTK application on Linux for Windows without setting up a cross-compile toolchain

All dependencies except platform specific system libraries are statically linked. 

These are not language bindings.

## Supported Features

Legends:
- ✅ Working
- 🏃 Planned

Platform support status:

- ✅ Linux (X11 and Wayland)
- ✅ Windows (WinAPI)
- 🏃 Mac OSX (Cocoa)

Supported Features:
- ✅ All FLTK basic features
- ✅ Image support
- ❌ Drawing with Cairo
- ❌ OpenGL

### Usage

Required dependencies for compiling for Linux on Debian based Systems
```libx11-dev libxext-dev libxrender-dev libwayland-dev libcairo2-dev wayland-protocols libxkbcommon-dev libxft-dev libpango1.0-dev```

See example usage here:
https://github.com/timsurber/fltk_zig_example

