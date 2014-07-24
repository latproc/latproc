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

#include <assert.h>
#include "MessagingInterface.h"
#include <iostream>
#include <exception>
#include <math.h>
#include <zmq.hpp>
#include "Logger.h"
#include "DebugExtra.h"
#include "cJSON.h"
#ifdef DYNAMIC_VALUES
#include "dynamic_value.h"
#endif
#include "symboltable.h"
#include "options.h"
#include "anet.h"
#include "MessageLog.h"
#include "Dispatcher.h"
#include "MessageEncoding.h"

MessagingInterface *MessagingInterface::current = 0;
zmq::context_t *MessagingInterface::zmq_context = 0;
std::map<std::string, MessagingInterface *>MessagingInterface::interfaces;

zmq::context_t *MessagingInterface::getContext() { return zmq_context; }

// monitoring thread
static void *req_socket_monitor (void *ctx)
{
    zmq_event_t event;
    int rc;
    
    void *s = zmq_socket (ctx, ZMQ_PAIR);
    assert (s);
    
    rc = zmq_connect (s, "inproc://monitor.req");
    assert (rc == 0);
    while (true) {
        zmq_msg_t msg;
        zmq_msg_init (&msg);
        rc = zmq_recvmsg (s, &msg, 0);
        if (rc == -1 && zmq_errno() == ETERM) break;
        assert (rc != -1);
        memcpy (&event, zmq_msg_data (&msg), sizeof (event));
        switch (event.event) {
            case ZMQ_EVENT_CONNECTED:
                // handle socket connected event
                break;
            case ZMQ_EVENT_CLOSED:
                // handle socket closed event
                break;
        }
    }
    zmq_close (s);
    return NULL;
}

// REP socket monitor thread
static void *rep_socket_monitor (void *ctx)
{
    zmq_event_t event;
    int rc;
    
    void *s = zmq_socket (ctx, ZMQ_PAIR);
    assert (s);
    
    rc = zmq_connect (s, "inproc://monitor.rep");
    assert (rc == 0);
    while (true) {
        zmq_msg_t msg;
        zmq_msg_init (&msg);
        rc = zmq_recvmsg (s, &msg, 0);
        if (rc == -1 && zmq_errno() == ETERM) break;
        assert (rc != -1);
        memcpy (&event, zmq_msg_data (&msg), sizeof (event));
        switch (event.event) {
            case ZMQ_EVENT_LISTENING:
                break;
            case ZMQ_EVENT_ACCEPTED:
                break;
            case ZMQ_EVENT_CLOSE_FAILED:
                break;
            case ZMQ_EVENT_CLOSED:
                break;
            case ZMQ_EVENT_DISCONNECTED:
                break;
        }
        zmq_msg_close (&msg);
    }
    zmq_close (s);
    return NULL;
}


void MessagingInterface::setContext(zmq::context_t *ctx) {
    zmq_context = ctx;
    assert(zmq_context);
    
  /*
    // register a monitor endpoint for all socket events
    int rc = zmq_socket_monitor (req, "inproc://monitor.req", ZMQ_EVENT_ALL);
    assert (rc == 0);
    
    // spawn a monitoring thread
    rc = pthread_create (&threads [0], NULL, req_socket_monitor, ctx);
    assert (rc == 0);
   */
}

MessagingInterface *MessagingInterface::getCurrent() {
    if (MessagingInterface::current == 0) {
        MessagingInterface::current = new MessagingInterface(1, publisher_port());
        usleep(200000); // give current subscribers time to notice us
    }
    return MessagingInterface::current;
}

MessagingInterface *MessagingInterface::create(std::string host, int port, Protocol proto) {
    std::stringstream ss;
    ss << host << ":" << port;
    std::string id = ss.str();
    if (interfaces.count(id) == 0) {
        MessagingInterface *res = new MessagingInterface(host, port, proto);
        interfaces[id] = res;
        return res;
    }
    else
        return interfaces[id];
}

MessagingInterface::MessagingInterface(int num_threads, int port, Protocol proto) 
		: Receiver("messaging_interface"), protocol(proto), socket(0),is_publisher(false), connection(-1) {
    owner_thread = pthread_self();
	if (protocol == eCLOCKWORK || protocol == eZMQ) {
	    socket = new zmq::socket_t(*MessagingInterface::getContext(), ZMQ_PUB);
	    is_publisher = true;
	    std::stringstream ss;
	    ss << "tcp://*:" << port;
	    url = ss.str();
        socket->bind(url.c_str());
	}
	else {
		connect();
	}
}

MessagingInterface::MessagingInterface(std::string host, int remote_port, Protocol proto) 
		:Receiver("messaging_interface"), protocol(proto), socket(0),is_publisher(false),
            connection(-1), hostname(host), port(remote_port), owner_thread(0) {
	if (protocol == eCLOCKWORK || protocol == eZMQ) {
        owner_thread = pthread_self();
	    if (host == "*") {
	        socket = new zmq::socket_t(*MessagingInterface::getContext(), ZMQ_PUB);
	        is_publisher = true;
	        std::stringstream ss;
	        ss << "tcp://*:" << port;
	        url = ss.str();
	        socket->bind(url.c_str());
	    }
	    else {
	        std::stringstream ss;
	        ss << "tcp://" << host << ":" << port;
	        url = ss.str();
	        connect();
	    }
	}
	else {
		connect();
	}
}

void MessagingInterface::connect() {
	if (protocol == eCLOCKWORK || protocol == eZMQ) {
        assert( pthread_equal(owner_thread, pthread_self()) );
	    socket = new zmq::socket_t(*MessagingInterface::getContext(), ZMQ_REQ);
	    is_publisher = false;
	    socket->connect(url.c_str());
	    int linger = 0;
	    socket->setsockopt (ZMQ_LINGER, &linger, sizeof (linger));
	}
	else {
		char error[ANET_ERR_LEN];
    	connection = anetTcpConnect(error, hostname.c_str(), port);
    	if (connection == -1) {
        	MessageLog::instance()->add(error);

    	    std::cerr << error << "\n";
    	}
	}
}

MessagingInterface::~MessagingInterface() {
	int retries = 3;
	while  (retries-- && connection != -1) { 
		int err = close(connection);
		if (err == -1 && errno == EINTR) continue;
		connection = -1;
	}
    if (MessagingInterface::current == this) MessagingInterface::current = 0;
    delete socket;
}

bool MessagingInterface::receives(const Message&, Transmitter *t) {
    return true;
}
void MessagingInterface::handle(const Message&msg, Transmitter *from, bool needs_receipt ) {
    char *response = send(msg);
    if (response)
        free(response);
}


char *MessagingInterface::send(const char *txt) {
    //if (owner_thread) assert( pthread_equal(owner_thread, pthread_self()) );

    if (!is_publisher){
        DBG_MESSAGING << "sending message " << txt << " on " << url << "\n";
    }
    else {
        DBG_MESSAGING << "sending message " << txt << "\n";
    }
    size_t len = strlen(txt);
    
    // We try to send a few times and if an exception occurs we try a reconnect
    // but is this useful without a sleep in between?
    // It seems unlikely the conditions will have changed between attempts.
    int retries=4;
    while (--retries>0) {
        try {
            zmq::message_t msg(len);
            strncpy ((char *) msg.data(), txt, len);
            socket->send(msg);
            break;
        }
        catch (std::exception e) {
            if (zmq_errno())
                std::cerr << "Exception when sending " << url << ": " << zmq_strerror(zmq_errno()) << "\n";
            else
                std::cerr << "Exception when sending " << url << ": " << e.what() << "\n";
            delete socket;
            connect();
        }
    }
    if (!is_publisher) {
        try {
            zmq::pollitem_t items[] = { { *socket, 0, ZMQ_POLLIN, 0 } };
            zmq::poll( &items[0], 1, 500);
            if (items[0].revents & ZMQ_POLLIN) {
                zmq::message_t reply;
                if (socket->recv(&reply)) {
                    len = reply.size();
                    char *data = (char *)malloc(len+1);
                    memcpy(data, reply.data(), len);
                    data[len] = 0;
                    std::cout << url << ": " << data << "\n";
                    return data;
                }
            }
            std::cerr << "timeout: abandoning message " << txt << "\n";
            delete socket;
            connect();
        }
        catch (std::exception e) {
            if (zmq_errno())
                std::cerr << "Exception when receiving response " << url << ": " << zmq_strerror(zmq_errno()) << "\n";
            else
                std::cerr << "Exception when receiving response " << url << ": " << e.what() << "\n";
        }
    }
    return 0;
}

char *MessagingInterface::send(const Message&msg) {
    char *text = MessageEncoding::encodeCommand(msg.getText(), msg.getParams());
    char *res = send(text);
    free(text);
    return res;
}

bool MessagingInterface::send_raw(const char *msg) {
    char error[ANET_ERR_LEN];
	int retry=2;
    size_t len = strlen(msg);
	while (retry--) {
	    size_t written = anetWrite(connection, (char *)msg, len);
	    if (written != len) {
	        snprintf(error, ANET_ERR_LEN, "error sending message: %s", msg );
	        MessageLog::instance()->add(error);
			close(connection);
			connect();
	    }
		else return true;
	}
	if (!retry) return false;
    return true;
}
char *MessagingInterface::sendCommand(std::string cmd, std::list<Value> *params) {
    char *request = MessageEncoding::encodeCommand(cmd, params);
    char *response = send(request);
    free(request);
    return response;
}

/* TBD, this may need to be optimised, one approach would be to use a 
 templating system; a property message looks like this:
 
 { "command":    "PROPERTY", "params":   
    [
         { "type":  "NAME", "value":    $1 },
         { "type":   "NAME", "value":   $2 },
         { "type":  TYPEOF($3), "value":  $3 }
     ] }
 
 */

char *MessagingInterface::sendCommand(std::string cmd, Value p1, Value p2, Value p3)
{
    std::list<Value>params;
    params.push_back(p1);
    params.push_back(p2);
    params.push_back(p3);
    return sendCommand(cmd, &params);
}

char *MessagingInterface::sendState(std::string cmd, std::string name, std::string state_name)
{
    cJSON *msg = cJSON_CreateObject();
    cJSON_AddStringToObject(msg, "command", cmd.c_str());
    cJSON *cjParams = cJSON_CreateArray();
    cJSON_AddStringToObject(cjParams, "name", name.c_str());
    cJSON_AddStringToObject(cjParams, "state", state_name.c_str());
    cJSON_AddItemToObject(msg, "params", cjParams);
    char *request = cJSON_PrintUnformatted(msg);
    cJSON_Delete(msg);
    char *response = send(request);
    free (request);
    return response;
}
