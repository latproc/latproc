# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The program to use to edit the cache.
CMAKE_EDIT_COMMAND = /usr/local/bin/ccmake

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/martin/latproc/hmi

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/martin/latproc/hmi/build

# Include any dependencies generated for this target.
include CMakeFiles/loader_control.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/loader_control.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/loader_control.dir/flags.make

CMakeFiles/loader_control.dir/src/loader_control.cxx.o: CMakeFiles/loader_control.dir/flags.make
CMakeFiles/loader_control.dir/src/loader_control.cxx.o: ../src/loader_control.cxx
	$(CMAKE_COMMAND) -E cmake_progress_report /Users/martin/latproc/hmi/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/loader_control.dir/src/loader_control.cxx.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/loader_control.dir/src/loader_control.cxx.o -c /Users/martin/latproc/hmi/src/loader_control.cxx

CMakeFiles/loader_control.dir/src/loader_control.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/loader_control.dir/src/loader_control.cxx.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /Users/martin/latproc/hmi/src/loader_control.cxx > CMakeFiles/loader_control.dir/src/loader_control.cxx.i

CMakeFiles/loader_control.dir/src/loader_control.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/loader_control.dir/src/loader_control.cxx.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /Users/martin/latproc/hmi/src/loader_control.cxx -o CMakeFiles/loader_control.dir/src/loader_control.cxx.s

CMakeFiles/loader_control.dir/src/loader_control.cxx.o.requires:
.PHONY : CMakeFiles/loader_control.dir/src/loader_control.cxx.o.requires

CMakeFiles/loader_control.dir/src/loader_control.cxx.o.provides: CMakeFiles/loader_control.dir/src/loader_control.cxx.o.requires
	$(MAKE) -f CMakeFiles/loader_control.dir/build.make CMakeFiles/loader_control.dir/src/loader_control.cxx.o.provides.build
.PHONY : CMakeFiles/loader_control.dir/src/loader_control.cxx.o.provides

CMakeFiles/loader_control.dir/src/loader_control.cxx.o.provides.build: CMakeFiles/loader_control.dir/src/loader_control.cxx.o

CMakeFiles/loader_control.dir/src/loader_panel.cxx.o: CMakeFiles/loader_control.dir/flags.make
CMakeFiles/loader_control.dir/src/loader_panel.cxx.o: ../src/loader_panel.cxx
	$(CMAKE_COMMAND) -E cmake_progress_report /Users/martin/latproc/hmi/build/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/loader_control.dir/src/loader_panel.cxx.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/loader_control.dir/src/loader_panel.cxx.o -c /Users/martin/latproc/hmi/src/loader_panel.cxx

CMakeFiles/loader_control.dir/src/loader_panel.cxx.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/loader_control.dir/src/loader_panel.cxx.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /Users/martin/latproc/hmi/src/loader_panel.cxx > CMakeFiles/loader_control.dir/src/loader_panel.cxx.i

CMakeFiles/loader_control.dir/src/loader_panel.cxx.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/loader_control.dir/src/loader_panel.cxx.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /Users/martin/latproc/hmi/src/loader_panel.cxx -o CMakeFiles/loader_control.dir/src/loader_panel.cxx.s

CMakeFiles/loader_control.dir/src/loader_panel.cxx.o.requires:
.PHONY : CMakeFiles/loader_control.dir/src/loader_panel.cxx.o.requires

CMakeFiles/loader_control.dir/src/loader_panel.cxx.o.provides: CMakeFiles/loader_control.dir/src/loader_panel.cxx.o.requires
	$(MAKE) -f CMakeFiles/loader_control.dir/build.make CMakeFiles/loader_control.dir/src/loader_panel.cxx.o.provides.build
.PHONY : CMakeFiles/loader_control.dir/src/loader_panel.cxx.o.provides

CMakeFiles/loader_control.dir/src/loader_panel.cxx.o.provides.build: CMakeFiles/loader_control.dir/src/loader_panel.cxx.o

# Object files for target loader_control
loader_control_OBJECTS = \
"CMakeFiles/loader_control.dir/src/loader_control.cxx.o" \
"CMakeFiles/loader_control.dir/src/loader_panel.cxx.o"

# External object files for target loader_control
loader_control_EXTERNAL_OBJECTS =

loader_control: CMakeFiles/loader_control.dir/src/loader_control.cxx.o
loader_control: CMakeFiles/loader_control.dir/src/loader_panel.cxx.o
loader_control: CMakeFiles/loader_control.dir/build.make
loader_control: libClockwork.a
loader_control: /usr/local/lib/libboost_system.dylib
loader_control: /usr/local/lib/libboost_thread.dylib
loader_control: /usr/local/lib/libfltk_images.a
loader_control: /usr/local/lib/libfltk_forms.a
loader_control: /usr/local/lib/libfltk_gl.a
loader_control: /usr/local/lib/libfltk.a
loader_control: /usr/local/lib/libmodbus.dylib
loader_control: /usr/local/lib/libfltk.a
loader_control: /usr/local/lib/libmodbus.dylib
loader_control: CMakeFiles/loader_control.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable loader_control"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/loader_control.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/loader_control.dir/build: loader_control
.PHONY : CMakeFiles/loader_control.dir/build

CMakeFiles/loader_control.dir/requires: CMakeFiles/loader_control.dir/src/loader_control.cxx.o.requires
CMakeFiles/loader_control.dir/requires: CMakeFiles/loader_control.dir/src/loader_panel.cxx.o.requires
.PHONY : CMakeFiles/loader_control.dir/requires

CMakeFiles/loader_control.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/loader_control.dir/cmake_clean.cmake
.PHONY : CMakeFiles/loader_control.dir/clean

CMakeFiles/loader_control.dir/depend:
	cd /Users/martin/latproc/hmi/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/martin/latproc/hmi /Users/martin/latproc/hmi /Users/martin/latproc/hmi/build /Users/martin/latproc/hmi/build /Users/martin/latproc/hmi/build/CMakeFiles/loader_control.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/loader_control.dir/depend

