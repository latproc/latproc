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

#ifndef cwlang_MessagingInterface_h
#define cwlang_MessagingInterface_h

#include <string>
#include <boost/thread.hpp>
#include <sstream>
#include <map>
#include <zmq.hpp>
#include <set>
#include "Message.h"
#include "value.h"
#include "symboltable.h" 
#include "cJSON.h"

#include "MessageEncoding.h"

enum Protocol { eCLOCKWORK, eRAW, eZMQ };

bool safeRecv(zmq::socket_t &sock, char *buf, int buflen, bool block, size_t &response_len, uint64_t timeout = -1);
bool sendMessage(const char *msg, zmq::socket_t &sock, std::string &response);


class MessagingInterface : public Receiver {
public:
    MessagingInterface(int num_threads, int port, Protocol proto = eZMQ);
    MessagingInterface(std::string host, int port, Protocol proto = eZMQ);
    ~MessagingInterface();
    static zmq::context_t *getContext();
    static void setContext(zmq::context_t *);
    static int uniquePort(unsigned int range_start = 7600, unsigned int range_end = 7799);
    char *send(const char *msg);
    char *send(const Message &msg);
    bool send_raw(const char *msg);
    void setCurrent(MessagingInterface *mi) { current = mi; }
    static MessagingInterface *getCurrent();
    static MessagingInterface *create(std::string host, int port, Protocol proto = eZMQ);
    char *sendCommand(std::string cmd, std::list<Value> *params);
    char *sendCommand(std::string cmd, Value p1 = SymbolTable::Null,
                     Value p2 = SymbolTable::Null,
                     Value p3 = SymbolTable::Null);
    char *sendState(std::string cmd, std::string name, std::string state_name);
    
    //Receiver interface
    virtual bool receives(const Message&, Transmitter *t);
    virtual void handle(const Message&, Transmitter *from, bool needs_receipt = false );
    zmq::socket_t *getSocket() { return socket; }
    static bool aborted() { return abort_all; }
    static void abort() { abort_all = true; }
    
private:
    static zmq::context_t *zmq_context;
    void connect();
    static MessagingInterface *current;
	Protocol protocol;
    zmq::socket_t *socket;
    static std::map<std::string, MessagingInterface *>interfaces;
    bool is_publisher;
    std::string url;
	int connection;
	std::string hostname;
	int port;
    pthread_t owner_thread;
    static bool abort_all;
};


class EventResponder {
public:
    ~EventResponder(){}
    virtual void operator()(const zmq_event_t &event_, const char* addr_) = 0;
};

class SocketMonitor : public zmq::monitor_t {
public:
    SocketMonitor(zmq::socket_t &s, const char *snam);
    void operator()();
    virtual void on_monitor_started();
    virtual void on_event_connected(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_connect_delayed(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_connect_retried(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_listening(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_bind_failed(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_accepted(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_accept_failed(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_closed(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_close_failed(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_disconnected(const zmq_event_t &event_, const char* addr_);
    virtual void on_event_unknown(const zmq_event_t &event_, const char* addr_);
    bool disconnected();
    void abort();
    void addResponder(uint16_t event, EventResponder *responder);
    void removeResponder(uint16_t event, EventResponder *responder);
    
protected:
    std::multimap<int, EventResponder*> responders;
    zmq::socket_t &sock;
    bool disconnected_;
    const char *socket_name;
    bool aborted;
};

class CommunicationPoll {
public:
    CommunicationPoll *instance() {
        if (!instance_) instance_ = new CommunicationPoll; return instance_;
    }
    
    
private:
    CommunicationPoll *instance_;
    CommunicationPoll();
    CommunicationPoll(const CommunicationPoll &);
    CommunicationPoll &operator=(const CommunicationPoll &);
};

class SingleConnectionMonitor : public SocketMonitor {
public:
    SingleConnectionMonitor(zmq::socket_t &s, const char *snam);
    virtual void on_event_disconnected(const zmq_event_t &event_, const char* addr_);
    void setEndPoint(const char *endpt);
    std::string &endPoint() { return sock_addr; }
    
private:
    std::string sock_addr;
    SingleConnectionMonitor(const SingleConnectionMonitor&);
    SingleConnectionMonitor &operator=(const SingleConnectionMonitor&);
};

class MachineShadow {
    SymbolTable properties;
    std::set<std::string> states;
    std::string state;
public:
    void setProperty(const std::string, Value &val);
    Value &getValue(const char *prop);
    void setState(const std::string);
};

class ConnectionManager {
public:
    ConnectionManager();
    virtual ~ConnectionManager() {}
    virtual bool setupConnections() =0;
    virtual bool checkConnections() =0;
    virtual bool checkConnections(zmq::pollitem_t *items, int num_items, zmq::socket_t &cmd) =0;
    
    void setProperty(std::string machine, std::string prop, Value val);
    void setState(std::string machine, std::string new_state);
    virtual int numSocks() =0;
    void abort();
protected:
    bool aborted;
    std::map<std::string, MachineShadow *> machines;
};

class SubscriptionManager : public ConnectionManager {
public:
    enum RunStatus { e_waiting_cmd, e_waiting_response };
    enum Status{e_startup, e_disconnected, e_waiting_connect,
        e_settingup_subscriber, e_waiting_subscriber, e_waiting_setup, e_done };
    
    SubscriptionManager(const char *chname, const char *remote_host = "localhost", int remote_port = 5555);
    void setSetupMonitor(SingleConnectionMonitor *monitor);
    
    void init();
    
    bool requestChannel();
    
    bool setupConnections();
    
    bool checkConnections();
    
    void usePublisher();
    
    bool checkConnections(zmq::pollitem_t *items, int num_items, zmq::socket_t &cmd);
    virtual int numSocks() { return 2; }
    int configurePoll(zmq::pollitem_t *);

    zmq::socket_t *publisher;
    zmq::socket_t subscriber;
    zmq::socket_t setup;
    Status setupStatus() const { return _setup_status; }
    void setSetupStatus( Status new_status );
    uint64_t state_start;
    RunStatus run_status;
    int subscriber_port;
    std::string current_channel;
    std::string subscriber_host;
    std::string channel_name;
    SingleConnectionMonitor monit_subs;
    SingleConnectionMonitor *monit_pubs;
    SingleConnectionMonitor *monit_setup;
protected:
    Status _setup_status;
};

class CommandManager : public ConnectionManager {
public:
    enum Status{e_waiting_cmd, e_waiting_response, e_startup, e_disconnected, e_waiting_connect, e_done };
    CommandManager(const char *host);
    void init();
    bool setupConnections();
    bool checkConnections();
    bool checkConnections(zmq::pollitem_t *items, int num_items, zmq::socket_t &cmd);
    virtual int numSocks() { return 1; }
    
    std::string host_name;
    zmq::socket_t *setup;
    SingleConnectionMonitor *monit_setup;
    Status setup_status;
    Status run_status;
};

#endif
