/*
 Copyright (C) 2014 Martin Leadbeater, Michael O'Connor
 
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

#ifndef __clockwork__MessageEncoding__
#define __clockwork__MessageEncoding__

#include <iostream>
#include <string>
#include "cJSON.h"
#include "MessageEncoding.h"
#include "value.h"
#include "symboltable.h"

struct MessageEncoding {
    static char *encodeCommand(std::string cmd, std::list<Value> *params);
    static char *encodeCommand(std::string cmd, Value p1 = SymbolTable::Null,
                               Value p2 = SymbolTable::Null,
                               Value p3 = SymbolTable::Null);
    static char *encodeError(const char *error);
    static bool getCommand(const char *msg, std::string &cmd, std::list<Value> **params);
    static bool getState(const char *msg, std::string &cmd, std::list<Value> **params);

	static Value valueFromJSONObject(cJSON *obj, cJSON *cjType);
};

#endif /* defined(__clockwork__MessageEncoding__) */