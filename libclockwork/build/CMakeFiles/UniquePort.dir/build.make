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
CMAKE_SOURCE_DIR = /Users/martin/projects/latproc/github/latproc/libclockwork

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/martin/projects/latproc/github/latproc/libclockwork/build

# Include any dependencies generated for this target.
include CMakeFiles/UniquePort.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/UniquePort.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/UniquePort.dir/flags.make

CMakeFiles/UniquePort.dir/uniqueport.cpp.o: CMakeFiles/UniquePort.dir/flags.make
CMakeFiles/UniquePort.dir/uniqueport.cpp.o: ../uniqueport.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /Users/martin/projects/latproc/github/latproc/libclockwork/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/UniquePort.dir/uniqueport.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/UniquePort.dir/uniqueport.cpp.o -c /Users/martin/projects/latproc/github/latproc/libclockwork/uniqueport.cpp

CMakeFiles/UniquePort.dir/uniqueport.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/UniquePort.dir/uniqueport.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /Users/martin/projects/latproc/github/latproc/libclockwork/uniqueport.cpp > CMakeFiles/UniquePort.dir/uniqueport.cpp.i

CMakeFiles/UniquePort.dir/uniqueport.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/UniquePort.dir/uniqueport.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /Users/martin/projects/latproc/github/latproc/libclockwork/uniqueport.cpp -o CMakeFiles/UniquePort.dir/uniqueport.cpp.s

CMakeFiles/UniquePort.dir/uniqueport.cpp.o.requires:
.PHONY : CMakeFiles/UniquePort.dir/uniqueport.cpp.o.requires

CMakeFiles/UniquePort.dir/uniqueport.cpp.o.provides: CMakeFiles/UniquePort.dir/uniqueport.cpp.o.requires
	$(MAKE) -f CMakeFiles/UniquePort.dir/build.make CMakeFiles/UniquePort.dir/uniqueport.cpp.o.provides.build
.PHONY : CMakeFiles/UniquePort.dir/uniqueport.cpp.o.provides

CMakeFiles/UniquePort.dir/uniqueport.cpp.o.provides.build: CMakeFiles/UniquePort.dir/uniqueport.cpp.o

# Object files for target UniquePort
UniquePort_OBJECTS = \
"CMakeFiles/UniquePort.dir/uniqueport.cpp.o"

# External object files for target UniquePort
UniquePort_EXTERNAL_OBJECTS =

UniquePort: CMakeFiles/UniquePort.dir/uniqueport.cpp.o
UniquePort: CMakeFiles/UniquePort.dir/build.make
UniquePort: libclockwork.a
UniquePort: /usr/local/lib/libzmq.dylib
UniquePort: /usr/local/lib/libmosquitto.so
UniquePort: /usr/local/lib/libboost_system.dylib
UniquePort: /usr/local/lib/libboost_program_options.dylib
UniquePort: /usr/local/lib/libboost_filesystem.dylib
UniquePort: CMakeFiles/UniquePort.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable UniquePort"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/UniquePort.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/UniquePort.dir/build: UniquePort
.PHONY : CMakeFiles/UniquePort.dir/build

CMakeFiles/UniquePort.dir/requires: CMakeFiles/UniquePort.dir/uniqueport.cpp.o.requires
.PHONY : CMakeFiles/UniquePort.dir/requires

CMakeFiles/UniquePort.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/UniquePort.dir/cmake_clean.cmake
.PHONY : CMakeFiles/UniquePort.dir/clean

CMakeFiles/UniquePort.dir/depend:
	cd /Users/martin/projects/latproc/github/latproc/libclockwork/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/martin/projects/latproc/github/latproc/libclockwork /Users/martin/projects/latproc/github/latproc/libclockwork /Users/martin/projects/latproc/github/latproc/libclockwork/build /Users/martin/projects/latproc/github/latproc/libclockwork/build /Users/martin/projects/latproc/github/latproc/libclockwork/build/CMakeFiles/UniquePort.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/UniquePort.dir/depend

