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

/*
    This program will ping the iod every second, as long as it has a connection
    to its device and that device is responding.
 */
#include <iostream>
#include "anet.h"
#include <boost/thread.hpp>
#include <sys/time.h>
#include <signal.h>
#include <errno.h>
#include <cassert>
#include <boost/thread/condition.hpp>
#include <boost/thread/mutex.hpp>
#include <sys/socket.h>
#include <zmq.hpp>
#include "regular_expressions.h"
#include <functional>
#include <boost/bind.hpp>

struct DeviceStatus {
    enum State {e_unknown, e_disconnected, e_connected, e_up, e_failed, e_timeout };
    State status;
    
    DeviceStatus() : status(e_unknown) { }
};


void usage(int argc, const char * argv[]) {
    std::cout << "Usage: " << argv[0]
        << " --host hostname --port port --property property_name [--client] [--name device_name]\n";
}

struct Options {
    Options() : is_server(true), port_(10240), host_(0), name_(0), machine_(0), property_(0), pattern_(0), iod_host_(0),
                got_host(false), got_port(true), got_property(false), got_pattern(false)  {
        setIODHost("localhost");
    }
    ~Options() {
        if (host_) free(host_);
        if (name_) free(name_);
        if (machine_) free(machine_);
        if (property_) free(property_);
    }
    bool valid() const { return got_port && got_host && got_property && got_pattern && name_ != 0 && iod_host_ != 0; }
    
    void clientMode(bool which = true) { is_server = !which; }
    void serverMode(bool which = true) { is_server = which; }
    
    bool server() const { return is_server; }
    bool client() const { return !is_server; }

    int port() const { return port_; }
    void setPort(int p) { port_ = p; got_port = true; }
    
    char *host() const { return host_; }
    void setHost(const char *h) {
        if (host_) free(host_);
        host_ = strdup(h); got_host = true;
    }
    
    const char *name() const { return name_; }
    void setName(const char *n) { if(name_) free(name_); name_ = strdup(n); }
    
    const char *property() const { return property_; }
    const char *machine() const { return machine_; }
    
    const char *iodHost() const { return iod_host_; }
    void setIODHost(const char *h) { if (iod_host_) free(iod_host_); iod_host_ = strdup(h); }
    
    // properties are provided in dot form, we split it into machine and property for the iod
    void setProperty(const char* machine_property) {
        if (machine_) free(machine_);
        if (property_) free(property_);
        if (!machine_property) {
            machine_ = 0;
            property_ = 0;
        }
        else {
            char *buf = strdup(machine_property);
            char *dot = (strchr(buf, '.'));
            if (!dot) {
                std::cerr << "Warning: property should be in the form 'machine.property'\n";
                free(buf);
                return;
            }
            *dot++ = 0; // terminate the machine name at the dot
            machine_ = strdup(buf);
            property_ = strdup(dot);
            free(buf);
            got_property = true;
        }
    }
    
    const char *pattern() { return pattern_; }
    void setPattern(const char *p) {
        if (pattern_) free(pattern_);
        pattern_ = strdup(p);
        compiled_pattern = create_pattern(pattern_);
        got_pattern = (compiled_pattern->compilation_result == 0) ? true : false;
        if (!got_pattern)
            std::cerr << compiled_pattern->compilation_error << "\n";
    
    }
    rexp_info *regexpInfo() { return compiled_pattern;}
    rexp_info *regexpInfo() const { return compiled_pattern;}

    
protected:
    bool is_server;    // if true, listen for connections, otherwise, connect to a device
    int port_;          // network port number
    char *host_;        // host name
    char *name_;        // device name
    char *machine_;     //  fsm in iod
    char *property_;    // property in the iod fsm
    char *pattern_;     // pattern used to detect a complete message
    rexp_info *compiled_pattern;
    char *iod_host_;
    
    // validation
    bool got_host;
    bool got_port;
    bool got_property;
    bool got_pattern;
};

struct IODInterface{
    
    void sendMessage(const char *message) {
        boost::mutex::scoped_lock lock(interface_mutex);

        try {
            const char *msg = (message) ? message : "";
            size_t len = strlen(msg);
            zmq::message_t request (len);
            memcpy ((void *) request.data (), msg, len);
            socket->send (request);
            zmq::message_t reply;
            socket->recv(&reply);
            len = reply.size();
            char *data = (char *)malloc(len+1);
            memcpy(data, reply.data(), len);
            data[len] = 0;
            std::cout << data << "\n";
            free(data);
        }
        catch(std::exception e) {
            std::cerr <<e.what() << "\n";
        }
    }
    
    void setProperty(const std::string &machine, const std::string &property, const std::string &val) {
        std::stringstream ss;
        ss << "PROPERTY " << machine << " " << property << " " << val << "\n";
        sendMessage(ss.str().c_str());
    }
    
    IODInterface(const Options &opts) : context(0), socket(0), options(opts) {
        try {
            std::stringstream ss;
            ss << "tcp://" << options.iodHost() << ":" << 5555;
            context = new zmq::context_t(1);
            socket = new zmq::socket_t (*context, ZMQ_REQ);
            socket->connect(ss.str().c_str());
        }
        catch (std::exception e) {
            std::cerr << e.what() << "\n";
        }
    }
    
    zmq::context_t *context;
    zmq::socket_t *socket;
    boost::mutex interface_mutex;
    const Options &options;
};


static struct timeval last_send;
static std::string last_message;

struct MatchFunction {
    MatchFunction(const Options &opts, IODInterface &iod) :options(opts), iod_interface(iod) {
        instance_ = this;
    }
    static MatchFunction *instance() { return instance_; }
    static int match_func(const char *match, int index, void *data)
    {
        std::cout << "match: " << index << " " << match << "\n";
        if (index == 0) {
            size_t *n = (size_t*)data;
            *n += strlen(match);
        }
        if (numSubexpressions(instance()->options.regexpInfo()) == 0 || index>0) {
            struct timeval now;
            gettimeofday(&now, 0);
            if (last_message != match || last_send.tv_sec +5 <  now.tv_sec) {
                instance()->iod_interface.setProperty(instance()->options.machine(), instance()->options.property(), match);
            }
        }
        return 0;
    }
protected:
    static MatchFunction *instance_;
    const Options &options;
    IODInterface &iod_interface;
private:
    MatchFunction(const MatchFunction&);
    MatchFunction &operator=(const MatchFunction&);
};
MatchFunction *MatchFunction::instance_;


struct ConnectionThread {

    void operator()() {
        try {
        gettimeofday(&last_active, 0);
        MatchFunction *match = new MatchFunction(options, iod_interface);
        
        if (options.server()) {
            listener = anetTcpServer(msg_buffer, options.port(), options.host());
            if (listener == -1) {
                std::cerr << msg_buffer << "...aborting\n";
                device_status.status = DeviceStatus::e_failed;
                updateProperty();
                done = true;
                return;
            }
        }
        
        const int buffer_size = 100;
        char buf[buffer_size];
        size_t offset = 0;
        
        device_status.status = DeviceStatus::e_disconnected;
        updateProperty();
        while (!done) {
            
            // connect or accept connection
            if (device_status.status == DeviceStatus::e_disconnected && options.client()) {
                connection = anetTcpConnect(msg_buffer, options.host(), options.port());
                if (connection == -1) {
                    std::cerr << msg_buffer << "\n";
                    continue;
                }
                device_status.status = DeviceStatus::e_connected;
                updateProperty();
            }
           
            fd_set read_ready;
            FD_ZERO(&read_ready);
            int nfds = 0;
            if (device_status.status == DeviceStatus::e_connected
                || device_status.status == DeviceStatus::e_up
                || device_status.status == DeviceStatus::e_timeout
                ) {
                FD_SET(connection, &read_ready);
                nfds = connection+1;
            }
            else if (options.server()) {
                FD_SET(listener, &read_ready);
                nfds = listener+1;
            }
                
            struct timeval select_timeout;
            select_timeout.tv_sec = 2;
            select_timeout.tv_usec = 0;
            int err = select(nfds, &read_ready, NULL, NULL, &select_timeout);
            if (err == -1) {
                if (errno != EINTR)
                    std::cerr << "socket: " << strerror(errno) << "\n";
            }
            else if (err == 0) {
                if (device_status.status == DeviceStatus::e_connected || device_status.status == DeviceStatus::e_up) {
                    device_status.status = DeviceStatus::e_timeout;
                    updateProperty();
                    std::cerr << "select timeout\n";
                }
            }
            
            
            if (device_status.status == DeviceStatus::e_disconnected && FD_ISSET(listener, &read_ready)) {
                // Accept and setup a connection
                int port;
                char hostip[16]; // dot notation
                connection = anetAccept(msg_buffer, listener, hostip, &port);

                if (anetTcpKeepAlive(msg_buffer, connection) == -1) {
                    std::cerr << msg_buffer << "\n";
                    close(connection);
                    continue;
                }
                
                if (anetTcpNoDelay(msg_buffer, connection) == -1) {
                    std::cerr << msg_buffer << "\n";
                    close(connection);
                    continue;
                }
                
                if (anetNonBlock(msg_buffer, connection) == -1) {
                    std::cerr << msg_buffer << "\n";
                    close(connection);
                    continue;
                }
                device_status.status = DeviceStatus::e_connected;
                updateProperty();
            }
            else if (connection != -1 && FD_ISSET(connection, &read_ready)) {
                if (offset < buffer_size-1) {
                    size_t n = read(connection, buf+offset, buffer_size - offset - 1);
                    if (n == -1) { 
                        if (!done && errno != EINTR && errno != EAGAIN) { // stop() may cause a read error that we ignore
                            std::cerr << "error: " << strerror(errno) << " reading from connection\n";
                            close(connection);
                            device_status.status = DeviceStatus::e_disconnected;
                            
                        }
                    }
                    else if (n) {
                        device_status.status = DeviceStatus::e_up;
                        updateProperty();

                        buf[offset+n] = 0;
                        {
                            boost::mutex::scoped_lock lock(connection_mutex);
                            gettimeofday(&last_active, 0);
                            last_msg = buf;
                        }
                    }
                    else {
                        close(connection);
                        device_status.status = DeviceStatus::e_disconnected;
                        updateProperty();
                        std::cerr << "connection lost\n";
                        connection = -1;
                    }
                    
                    // recalculate offset as we step through matches
                    offset = 0;
                    each_match(options.regexpInfo(), buf, &MatchFunction::match_func, &offset);
                    size_t len = strlen(buf);
#if 0
                        std::cout << "buf: ";
                        for (int i=0; i<=len; ++i) {
                            std::cout << std::setw(2) << std::setfill('0') << std::hex << (int)buf[i] << " ";
                        }
                        std::cout << "\n";
                        std::cout << "     ";

                        for (int i=0; i<offset; ++i) {
                            std::cout << std::hex << "   ";
                        }
                        std::cout << "^\n";
#endif
                        if (offset)  {
                            memmove(buf, buf+offset, len+1-offset);
                        }
                    offset = strlen(buf);
                }
                else {
                    std::cerr << "buffer full\n";
                }
            }
        }
        }catch (std::exception e) {
            std::cerr << e.what() << "\n";
        }
    }
    
    ConnectionThread(Options &opts, DeviceStatus &status, IODInterface &iod)
            : done(false), connection(-1), options(opts), device_status(status), iod_interface(iod)
    {
        assert(options.valid());
        msg_buffer =new char[ANET_ERR_LEN];
        gettimeofday(&last_active, 0);
        last_property_update.tv_sec = 0;
        last_property_update.tv_usec = 0;
        last_status.status = DeviceStatus::e_unknown;
    }
    
    void stop() {
        done = true;
        if (device_status.status == DeviceStatus::e_connected || device_status.status == DeviceStatus::e_up) {
            done = true;
            close(connection);
        }
    }
    
    void last_message(std::string &msg, struct timeval &msg_time) {
        boost::mutex::scoped_lock lock(connection_mutex);
        msg = last_msg;
        msg_time = last_active;
    }
    
    void updateProperty() {
        struct timeval now;
        gettimeofday(&now, 0);
        if (last_status.status != device_status.status || now.tv_sec >= last_property_update.tv_sec + 5) {
            last_property_update.tv_sec = now.tv_sec;
            last_property_update.tv_usec = now.tv_usec;
            last_status.status = device_status.status;
            switch(device_status.status) {
                case DeviceStatus::e_disconnected:
                    iod_interface.setProperty(options.name(), "status", "disconnected");
                    break;
                case DeviceStatus::e_connected:
                    iod_interface.setProperty(options.name(), "status", "connected");
                    break;
                case DeviceStatus::e_timeout:
                    iod_interface.setProperty(options.name(), "status", "timeout");
                    break;
                case DeviceStatus::e_unknown:
                    iod_interface.setProperty(options.name(), "status", "unknown");
                    break;
                case DeviceStatus::e_up:
                    iod_interface.setProperty(options.name(), "status", "running");
                    break;
                case DeviceStatus::e_failed:
                    iod_interface.setProperty(options.name(), "status", "failed");
                    break;
            }
        }
    }
    bool done;
    int listener;
    int connection;
    std::string last_msg;
    Options &options;
    DeviceStatus &device_status;
    IODInterface &iod_interface;
    char *msg_buffer;
    struct timeval last_active;
    DeviceStatus last_status;
    struct timeval last_property_update;
    boost::mutex connection_mutex;
};


bool done = false;

static void finish(int sig)
{
    struct sigaction sa;
    sa.sa_handler = SIG_DFL;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGTERM, &sa, 0);
    sigaction(SIGINT, &sa, 0);
    done = true;
}

bool setup_signals()
{
    struct sigaction sa;
    sa.sa_handler = finish;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if (sigaction(SIGTERM, &sa, 0) || sigaction(SIGINT, &sa, 0)) {
        return false;
    }
    return true;
}


int main(int argc, const char * argv[])
{
    last_send.tv_sec = 0;
    last_send.tv_usec = 0;
    
    Options options;
    try {
    
    for (int i=1; i<argc; i++) {
        if (strcmp(argv[i], "--port") == 0 && i < argc-1) {
            long port;
            char *next;
            port = strtol(argv[++i], &next, 10);
            if (!*next) options.setPort(port & 0xffff);
        }
        else if (strcmp(argv[i], "--host") == 0 && i < argc-1) {
            options.setHost(argv[++i]);
        }
        else if (strcmp(argv[i], "--name") == 0 && i < argc-1) {
            options.setName(argv[++i]);
        }
        else if (strcmp(argv[i], "--property") == 0 && i < argc-1) {
            options.setProperty(argv[++i]);
        }
        else if (strcmp(argv[i], "--pattern") == 0 && i < argc-1) {
            options.setPattern(argv[++i]);
        }
        else if (strcmp(argv[i], "--client") == 0) {
            options.clientMode();
        }
        else {
            std::cerr << "Warning: parameter " << argv[i] << " not understood\n";
        }
    }
    if (!options.valid()) {
        usage(argc, argv);
        exit(EXIT_FAILURE);
    }
    
    DeviceStatus device_status;
    IODInterface iod_interface(options);
    
	ConnectionThread connection_thread(options, device_status, iod_interface);
	boost::thread monitor(boost::ref(connection_thread));
    
    struct timeval last_time;
    gettimeofday(&last_time, 0);
    if (!setup_signals()) {
        std::cerr << "Error setting up signals " << strerror(errno) << "\n";
    }
    
    while (!done && !connection_thread.done)
    {
        struct timeval now;
        gettimeofday(&now, 0);
        // TBD once the connection is open, check that data has been received within the last second
        if (device_status.status == DeviceStatus::e_up || device_status.status == DeviceStatus::e_timeout) {
            std::string msg;
            struct timeval last;
            connection_thread.last_message(msg, last);
            if (last_time.tv_sec != last.tv_sec && now.tv_sec > last.tv_sec + 1) {
                if (device_status.status == DeviceStatus::e_timeout)
                    std::cerr << "Warning: Device timeout\n";
                else
                    std::cout << "Warning: connection idle\n";
                last_time = last;
            }
        }
        // send a message to iod
        usleep(100);
    }
    
    connection_thread.stop();
    monitor.join();
    }
    catch (std::exception e) {
        std::cerr << e.what() << "\n";
    }
    return 0;
}
