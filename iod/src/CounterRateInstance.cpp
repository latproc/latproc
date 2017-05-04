#include <stdint.h>
#include "filtering.h"
#include "CounterRateFilterSettings.h"
#include "CounterRateInstance.h"

CounterRateInstance::CounterRateInstance(InstanceType instance_type) :MachineInstance(instance_type) {
	settings = new CounterRateFilterSettings(32);
}
CounterRateInstance::CounterRateInstance(CStringHolder name, const char * type, InstanceType instance_type)
	: MachineInstance(name, type, instance_type) {
		settings = new CounterRateFilterSettings(32);
	}
CounterRateInstance::~CounterRateInstance() { delete settings; }

#if 0
bool CounterRateInstance::hasWork() {
	struct timeval now;
	gettimeofday(&now, 0);
	return ( (uint64_t)now.tv_sec*1000000L + now.tv_usec >= (uint64_t) next_poll);
}
#endif

void CounterRateInstance::setValue(const std::string &property, Value new_value, uint64_t authority) {
	if (property == "VALUE") {
		if (new_value.kind == Value::t_symbol) {
			new_value = lookup(new_value.sValue.c_str());
		}
		long val;
		if (!new_value.asInteger(val)) val = 0;
		if (settings->property_changed) {
			settings->property_changed = false;
		}

		//reset once the buffers have been filled with zeros
		if (!val) ++settings->zero_count;
        else settings->zero_count = 0;
		if (settings->zero_count > settings->readings.length()) {
			settings->zero_count = 0;
			// reset buffers;
			//settings->start_t = settings->update_t;
			settings->readings.reset();
		}

        if ( (settings->update_t - settings->last_update_t)/1000 == 0 )
            return;
        settings->last_update_t = settings->update_t;
		uint64_t delta_t = settings->update_t - settings->start_t;
        settings->readings.append( val, delta_t);

		int32_t mean = (settings->readings.average(settings->readings.length()) + 0.5f);
		if ( (uint32_t)abs(mean - settings->last_sent) > settings->noise_tolerance ) {
			settings->last_sent = mean;
		}
		settings->position = settings->last_sent;
		settings->velocity = filter(settings->position);

		MachineInstance::setValue(property, settings->velocity);
		MachineInstance::setValue("position", settings->position);
		MachineInstance *pos = lookup(parameters[0]);
		if (pos) pos->setValue("VALUE", settings->position);
	}
	else
		MachineInstance::setValue(property, new_value);
}

long CounterRateInstance::filter(long val) {
	if (settings->readings.length() < 4) return 0;
	//float speed = settings->positions.difference(settings->positions.length()-1, 0) / settings->times.difference(settings->times.length()-1,0) * 250000;
	//float speed = settings->positions.slopeFromLeastSquaresFit(settings->times) * 1000000;
    float speed = settings->readings.rate();
	return speed;
}

void CounterRateInstance::idle() {
	if (!io_interface) {
		struct timeval now;
		gettimeofday(&now, 0);
		uint64_t now_t = now.tv_sec * 1000000 + now.tv_usec;
		if (settings->update_t + 2000 < now_t) {
			long new_val = (long)((float)settings->position + settings->velocity * 2 / 1000.0f); //* (now_t-update_t) / 1000000.0f );
			setValue("VALUE", new_val);
		}
	}
}