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
CMAKE_SOURCE_DIR = /Users/martin/latproc/modbus

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/martin/latproc/modbus/build

# Include any dependencies generated for this target.
include CMakeFiles/mbmon.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/mbmon.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/mbmon.dir/flags.make

CMakeFiles/mbmon.dir/src/mbmon.cpp.o: CMakeFiles/mbmon.dir/flags.make
CMakeFiles/mbmon.dir/src/mbmon.cpp.o: ../src/mbmon.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /Users/martin/latproc/modbus/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/mbmon.dir/src/mbmon.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/mbmon.dir/src/mbmon.cpp.o -c /Users/martin/latproc/modbus/src/mbmon.cpp

CMakeFiles/mbmon.dir/src/mbmon.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/mbmon.dir/src/mbmon.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /Users/martin/latproc/modbus/src/mbmon.cpp > CMakeFiles/mbmon.dir/src/mbmon.cpp.i

CMakeFiles/mbmon.dir/src/mbmon.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/mbmon.dir/src/mbmon.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /Users/martin/latproc/modbus/src/mbmon.cpp -o CMakeFiles/mbmon.dir/src/mbmon.cpp.s

CMakeFiles/mbmon.dir/src/mbmon.cpp.o.requires:
.PHONY : CMakeFiles/mbmon.dir/src/mbmon.cpp.o.requires

CMakeFiles/mbmon.dir/src/mbmon.cpp.o.provides: CMakeFiles/mbmon.dir/src/mbmon.cpp.o.requires
	$(MAKE) -f CMakeFiles/mbmon.dir/build.make CMakeFiles/mbmon.dir/src/mbmon.cpp.o.provides.build
.PHONY : CMakeFiles/mbmon.dir/src/mbmon.cpp.o.provides

CMakeFiles/mbmon.dir/src/mbmon.cpp.o.provides.build: CMakeFiles/mbmon.dir/src/mbmon.cpp.o

CMakeFiles/mbmon.dir/src/plc_interface.cpp.o: CMakeFiles/mbmon.dir/flags.make
CMakeFiles/mbmon.dir/src/plc_interface.cpp.o: ../src/plc_interface.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /Users/martin/latproc/modbus/build/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/mbmon.dir/src/plc_interface.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/mbmon.dir/src/plc_interface.cpp.o -c /Users/martin/latproc/modbus/src/plc_interface.cpp

CMakeFiles/mbmon.dir/src/plc_interface.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/mbmon.dir/src/plc_interface.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /Users/martin/latproc/modbus/src/plc_interface.cpp > CMakeFiles/mbmon.dir/src/plc_interface.cpp.i

CMakeFiles/mbmon.dir/src/plc_interface.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/mbmon.dir/src/plc_interface.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /Users/martin/latproc/modbus/src/plc_interface.cpp -o CMakeFiles/mbmon.dir/src/plc_interface.cpp.s

CMakeFiles/mbmon.dir/src/plc_interface.cpp.o.requires:
.PHONY : CMakeFiles/mbmon.dir/src/plc_interface.cpp.o.requires

CMakeFiles/mbmon.dir/src/plc_interface.cpp.o.provides: CMakeFiles/mbmon.dir/src/plc_interface.cpp.o.requires
	$(MAKE) -f CMakeFiles/mbmon.dir/build.make CMakeFiles/mbmon.dir/src/plc_interface.cpp.o.provides.build
.PHONY : CMakeFiles/mbmon.dir/src/plc_interface.cpp.o.provides

CMakeFiles/mbmon.dir/src/plc_interface.cpp.o.provides.build: CMakeFiles/mbmon.dir/src/plc_interface.cpp.o

CMakeFiles/mbmon.dir/src/monitor.cpp.o: CMakeFiles/mbmon.dir/flags.make
CMakeFiles/mbmon.dir/src/monitor.cpp.o: ../src/monitor.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /Users/martin/latproc/modbus/build/CMakeFiles $(CMAKE_PROGRESS_3)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/mbmon.dir/src/monitor.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/mbmon.dir/src/monitor.cpp.o -c /Users/martin/latproc/modbus/src/monitor.cpp

CMakeFiles/mbmon.dir/src/monitor.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/mbmon.dir/src/monitor.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /Users/martin/latproc/modbus/src/monitor.cpp > CMakeFiles/mbmon.dir/src/monitor.cpp.i

CMakeFiles/mbmon.dir/src/monitor.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/mbmon.dir/src/monitor.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /Users/martin/latproc/modbus/src/monitor.cpp -o CMakeFiles/mbmon.dir/src/monitor.cpp.s

CMakeFiles/mbmon.dir/src/monitor.cpp.o.requires:
.PHONY : CMakeFiles/mbmon.dir/src/monitor.cpp.o.requires

CMakeFiles/mbmon.dir/src/monitor.cpp.o.provides: CMakeFiles/mbmon.dir/src/monitor.cpp.o.requires
	$(MAKE) -f CMakeFiles/mbmon.dir/build.make CMakeFiles/mbmon.dir/src/monitor.cpp.o.provides.build
.PHONY : CMakeFiles/mbmon.dir/src/monitor.cpp.o.provides

CMakeFiles/mbmon.dir/src/monitor.cpp.o.provides.build: CMakeFiles/mbmon.dir/src/monitor.cpp.o

# Object files for target mbmon
mbmon_OBJECTS = \
"CMakeFiles/mbmon.dir/src/mbmon.cpp.o" \
"CMakeFiles/mbmon.dir/src/plc_interface.cpp.o" \
"CMakeFiles/mbmon.dir/src/monitor.cpp.o"

# External object files for target mbmon
mbmon_EXTERNAL_OBJECTS =

mbmon: CMakeFiles/mbmon.dir/src/mbmon.cpp.o
mbmon: CMakeFiles/mbmon.dir/src/plc_interface.cpp.o
mbmon: CMakeFiles/mbmon.dir/src/monitor.cpp.o
mbmon: CMakeFiles/mbmon.dir/build.make
mbmon: /usr/local/lib/libboost_system.dylib
mbmon: /usr/local/lib/libboost_thread.dylib
mbmon: libClockwork.a
mbmon: /usr/local/lib/libfltk_images.a
mbmon: /usr/local/lib/libfltk_forms.a
mbmon: /usr/local/lib/libfltk_gl.a
mbmon: /usr/local/lib/libfltk.a
mbmon: /usr/local/lib/libmodbus.dylib
mbmon: /usr/local/lib/libfltk.a
mbmon: /usr/local/lib/libmodbus.dylib
mbmon: CMakeFiles/mbmon.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable mbmon"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/mbmon.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/mbmon.dir/build: mbmon
.PHONY : CMakeFiles/mbmon.dir/build

CMakeFiles/mbmon.dir/requires: CMakeFiles/mbmon.dir/src/mbmon.cpp.o.requires
CMakeFiles/mbmon.dir/requires: CMakeFiles/mbmon.dir/src/plc_interface.cpp.o.requires
CMakeFiles/mbmon.dir/requires: CMakeFiles/mbmon.dir/src/monitor.cpp.o.requires
.PHONY : CMakeFiles/mbmon.dir/requires

CMakeFiles/mbmon.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/mbmon.dir/cmake_clean.cmake
.PHONY : CMakeFiles/mbmon.dir/clean

CMakeFiles/mbmon.dir/depend:
	cd /Users/martin/latproc/modbus/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/martin/latproc/modbus /Users/martin/latproc/modbus /Users/martin/latproc/modbus/build /Users/martin/latproc/modbus/build /Users/martin/latproc/modbus/build/CMakeFiles/mbmon.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/mbmon.dir/depend

