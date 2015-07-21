/*
  Copyright (C) 2012 Martin Leadbeater, Michael O'Connor

  This file is part of Latproc

  Latproc is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.
  
  Latproc is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Latproc; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#include <iostream>
#include "IOComponent.h"
#include "ControlSystemMachine.h"
#include "LatprocConfig.h"
#include "zmq.h"

ControlSystemMachine::ControlSystemMachine() : state(s_unknown) {
	std::cout << "ControlSystem version " << Latproc_VERSION_MAJOR << "." << Latproc_VERSION_MINOR << "\n";
	int major, minor, patch;
	zmq_version (&major, &minor, &patch); 
	std::cout << "ZMQ version " << major << "." << minor << "." << patch << "\n";
}
