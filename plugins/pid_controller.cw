PIDCONFIGURATION MACHINE {
	OPTION PERSISTENT true;
	EXPORT RW 32BIT min_update_time, StartTimeout, fwd_step_up, fwd_step_down, rev_step_up, rev_step_down;
	OPTION min_update_time 20; # minimum time between normal control updates
	OPTION StartTimeout 500;		#conveyor start timeout
	OPTION fwd_step_up 40000; # maximum change per second
	OPTION fwd_step_down 60000; # maximum change per second
	OPTION rev_step_up 40000; # maximum change per second
	OPTION rev_step_down 60000; # maximum change per second
	OPTION inverted false; # do not invert power

	OPTION Kp 100000;
	OPTION Ki 20;
	OPTION Kd 1000;
}

PIDCONTROL MACHINE {
	stop INITIAL;
	drive STATE;
	none STATE;
}

PIDCONTROLLER MACHINE M_Control, settings, output_settings, fwd_settings, rev_settings, driver, pos, freq_sampler {
    PLUGIN "pid_controller.so.1.0";

%BEGIN_PLUGIN
#include <Plugin.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/time.h>
#include <stdint.h>
#include <math.h>

struct PIDData {
	enum { 
		pid_init, 
		pid_interlocked, 
		pid_off, 
		pid_forward, 
		pid_reverse, 
		pid_idle 
	} pid_state;
	enum { 
		cs_init, 
		cs_interlocked, /* something upstream is interlocked */
		cs_stopped, 		/* sleeping */
		cs_position,
		cs_speed
	} state;

	/**** clockwork interface ***/
    long *set_point;
    long *stop_position; 
    long *mark_position; 
	long *speed;
	long *position;
	long *target_power;

	/* ramp settings */
	long *min_update_time;
	long *fwd_step_up;		/* ramp increase per second */
	long *fwd_step_down;
	long *rev_step_up;		/* downward ramp change per second */
	long *rev_step_down;

	long *max_forward;
	long *max_reverse;
	long *zero_pos;
	long *min_forward;
	long *min_reverse;

	long *fwd_tolerance;
	long *fwd_stopping_distance;
	long *fwd_slow_speed;
	long *fwd_full_speed;
	long *fwd_power_factor;
	long *fwd_travel_allowance;

	long *rev_tolerance;
	long *rev_stopping_distance;
	long *rev_slow_speed;
	long *rev_full_speed;
	long *rev_power_factor;
	long *rev_travel_allowance;

	long *Kp_long;
	long *Ki_long;
	long *Kd_long;

	/* internal values for ramping */
	long current_power;
	uint64_t ramp_start_time;
	long ramp_start_power;		/* the power level at the point ramping started */
	long ramp_start_target; 	/* the target that was set when ramping started */
	uint64_t last_poll;
	long tolerance;
	long last_set_point;
	long last_stop_position;
	long default_debug; /* a default debug level if one is not specified in the script */
	int inverted;
	long last_speed;
	double last_Ep;

	char *conveyor_name;

	/* stop/start control */
	long stop_marker;
	long *debug;

	double Kp;
	double Ki;
	double Kd;
	
	double total_err;
};

int getInt(void *scope, const char *name, long **addr) {
	struct PIDData *data = (struct PIDData*)getInstanceData(scope);
	if (!getIntValue(scope, name, addr)) {
		char buf[100];
		char *val = getStringValue(scope, name);
		if (data)
			snprintf(buf, 100, "%s PIDController: %s (%s) is not an integer", data->conveyor_name, name, (val) ? val : "null");
		else
			snprintf(buf, 100, "PIDController: %s (%s) is not an integer", name, (val) ? val : "null");
		printf("%s\n", buf);
		log_message(scope, buf);
		free(val);
		return 0;
	}
	/* printf("%s: %d\n", name, **addr); */
	return 1;
}

long output_scaled(struct PIDData * settings, long power) {

	long raw = *settings->zero_pos;
	if (power > 0)
		raw = power + *settings->min_forward;
	else if (power < 0)
		raw = power + *settings->min_reverse;
	
	if (raw < *settings->max_reverse) raw = *settings->max_reverse;
  if (raw > *settings->max_forward) raw = *settings->max_forward;

  if ( settings->inverted ) {
		raw = 32766 - (uint16_t)raw;
		if (raw < 0) raw = 0;
	}
	return raw;
}

double calc_set_point(long current_position, long stop_position) {
	long diff = stop_position - current_position;
	if (diff > 2000) return 2000.0;
	else if (diff > 200) return 500.0;
	else if (diff > -200) return 0.0;
	else return -500.0;
}
    
PLUGIN_EXPORT
int check_states(void *scope)
{
	int ok = 1;
	struct PIDData *data = (struct PIDData*)getInstanceData(scope);
	if (!data) {
		// one-time initialisation
		data = (struct PIDData*)malloc(sizeof(struct PIDData));
		memset(data, 0, sizeof(struct PIDData));
		setInstanceData(scope, data);
		{ 
			data->conveyor_name = getStringValue(scope, "NAME");
			if (!data->conveyor_name) data->conveyor_name = strdup("UNKNOWN CONVEYOR");
		}

		ok = ok && getInt(scope, "SetPoint", &data->set_point);
		ok = ok && getInt(scope, "StopMarker", &data->mark_position);
		ok = ok && getInt(scope, "StopPosition", &data->stop_position);
		ok = ok && getInt(scope, "TargetPower", &data->target_power);
		ok = ok && getInt(scope, "freq_sampler.VALUE", &data->speed);
		ok = ok && getInt(scope, "pos.VALUE", &data->position);
		ok = ok && getInt(scope, "settings.min_update_time", &data->min_update_time);
		ok = ok && getInt(scope, "settings.fwd_step_up", &data->fwd_step_up);
		ok = ok && getInt(scope, "settings.fwd_step_down", &data->fwd_step_down);
		ok = ok && getInt(scope, "settings.rev_step_up", &data->rev_step_up);
		ok = ok && getInt(scope, "settings.rev_step_down", &data->rev_step_down);

		ok = ok && getInt(scope, "output_settings.MaxForward", &data->max_forward);
		ok = ok && getInt(scope, "output_settings.MaxReverse", &data->max_reverse);
		ok = ok && getInt(scope, "output_settings.ZeroPos", &data->zero_pos);
		ok = ok && getInt(scope, "output_settings.MinForward", &data->min_forward);
		ok = ok && getInt(scope, "output_settings.MinReverse", &data->min_reverse);

		ok = ok && getInt(scope, "fwd_settings.SlowSpeed", &data->fwd_slow_speed);
		ok = ok && getInt(scope, "fwd_settings.FullSpeed", &data->fwd_full_speed);
		ok = ok && getInt(scope, "fwd_settings.PowerFactor", &data->fwd_power_factor);
		ok = ok && getInt(scope, "fwd_settings.StoppingDistance", &data->fwd_stopping_distance);
		ok = ok && getInt(scope, "fwd_settings.TravelAllowance", &data->fwd_travel_allowance);
		ok = ok && getInt(scope, "fwd_settings.tolerance", &data->fwd_tolerance);

		ok = ok && getInt(scope, "rev_settings.SlowSpeed", &data->rev_slow_speed);
		ok = ok && getInt(scope, "rev_settings.FullSpeed", &data->rev_full_speed);
		ok = ok && getInt(scope, "rev_settings.PowerFactor", &data->rev_power_factor);
		ok = ok && getInt(scope, "rev_settings.StoppingDistance", &data->rev_stopping_distance);
		ok = ok && getInt(scope, "rev_settings.TravelAllowance", &data->rev_travel_allowance);
		ok = ok && getInt(scope, "rev_settings.tolerance", &data->rev_tolerance);

		ok = ok && getInt(scope, "settings.Kp", &data->Kp_long);
		ok = ok && getInt(scope, "settings.Ki", &data->Ki_long);
		ok = ok && getInt(scope, "settings.Kd", &data->Kd_long);

		if (!getInt(scope, "DEBUG", &data->debug) ) data->debug = &data->default_debug;
		
	  {
			char *invert = getStringValue(scope, "settings.inverted");
			if (invert && strcmp(invert,"true") == 0) {
				data->inverted = 1; 
				if (data->debug) printf("inverted output");
			}
			else data->inverted = 0;
			free(invert);
		}

		if (!ok) {
			printf("%s plugin failed to initialise\n", data->conveyor_name);
			setInstanceData(scope, 0);
			free(data);
			return PLUGIN_ERROR;
		}

		data->state = cs_init;
		data->current_power = 0;
		data->last_poll = 0;

		data->stop_marker = 0;
		data->last_stop_position = 0;
		data->last_set_point = 0;

		data->total_err = 0.0;

		printf("%s plugin initialised ok: update time %ld\n", data->conveyor_name, *data->min_update_time);
	}
	data->Kp = (double) *data->Kp_long / 1000000.0f;
	data->Ki = (double) *data->Ki_long / 1000000.0f;
	data->Kd = (double) *data->Kd_long / 1000000.0f;

	return PLUGIN_COMPLETED;
}

PLUGIN_EXPORT
int poll_actions(void *scope) {
	struct PIDData *data = (struct PIDData*)getInstanceData(scope);
	struct timeval now;
	uint64_t now_t = 0;
	double new_power = 0.0f;
	long calculated_target_power = 0;
	long calculated_set_point = 0;
	long calculated_stop_position = 0;
	char *current = 0;
	char *control = 0;

	if (!data) return PLUGIN_COMPLETED; /* not initialised yet; nothing to do */

	gettimeofday(&now, 0);
	now_t = now.tv_sec * 1000000 + now.tv_usec;

	if ( (now_t - data->last_poll)/1000 < *data->min_update_time) return PLUGIN_COMPLETED;

	new_power = data->current_power;

	/* Determine what the controller should be doing */
	{
		enum {cmd_none, cmd_stop, cmd_drive} command;
		void *controller = 0;
		current = getState(scope);
		control = 0;
		/*printf("%s test: %s %ld, stop: %ld, pow: %ld, pos: %ld\n", data->conveyor_name,
							 (current)? current : "null", 
                *data->set_point,
                *data->stop_position,
                *data->target_power,
                *data->position);
		*/
		controller = getNamedScope(scope, "control");
		if (controller) {
			control = getState(controller);
			//printf("%s controller state: %s\n", data->conveyor_name, (control) ? control : "null");
			if (strcmp(control, "stop") == 0)
				command = cmd_stop;
			else if (strcmp(control, "drive") == 0)
				command = cmd_drive;
			else 
				command = cmd_none;
		}
		else
			command = cmd_stop;
		void *std_state = getNamedScope(scope, "M_Control");
		if (!std_state) log_message(scope, "Could not find named scope M_Control");

		int interlocked = current && strcmp(current, "interlocked") == 0;

		if (interlocked && data->state != cs_interlocked) {
			if (std_state) changeState(std_state, "Unavailable");
			data->state = cs_interlocked;
			command = cmd_stop;
		}

		if (command == cmd_stop) {
			if (data->debug && *data->debug) printf("%s stop command\n", data->conveyor_name);
			data->current_power = 0;
			new_power = 0;
			data->stop_marker = 0;
			data->last_set_point = 0;
			setIntValue(scope, "SetPoint", 0);
			if (!interlocked) {
				printf("%s stopped\n", data->conveyor_name);
				data->state = cs_stopped;
				if (std_state) changeState(std_state, "Ready");
			}
			setIntValue(scope, "TargetPower", 0);
			setIntValue(scope, "driver.VALUE", output_scaled(data, 0) );
			if (controller) changeState(controller, "none");
			goto done_polling_actions;
		}
		if (interlocked) goto done_polling_actions;

		if (data->current_power == 0 && (data->state == cs_init || data->state == cs_interlocked) ) {
			if (std_state) changeState(std_state, "Ready");
			data->state = cs_stopped;
		}

		/* Seek to the stop position if there is one otherwise maintain the set point */

		double set_point = 0.0;

		/* if the stop position has changed, we attempt to move to that position */
		if (*data->stop_position && data->last_stop_position != *data->stop_position) {
			printf("%s new stop position %ld\n", data->conveyor_name, *data->stop_position);
			data->last_stop_position = *data->stop_position;
			data->state = cs_position;
			data->stop_marker = *data->mark_position;
			if (!data->stop_marker) {
				*data->set_point = 0;
				set_point = 0;
				data->state = cs_speed;
			}
			else
				set_point = calc_set_point(*data->position, *data->stop_position);
			if (std_state) changeState(std_state, "Resetting");
		}
		else if ( data->state == cs_position ) { 
				set_point = calc_set_point(*data->position, *data->stop_position);
		}
		else if (set_point != 0.0) {
			data->state = cs_speed;
			set_point = *data->set_point;
		}

		double Ep = set_point - *data->speed;
		if (data->state != cs_stopped) {
			double dt = (now_t - data->last_poll)/1000;
			double dp = *data->speed - data->last_speed;
			data->total_err += (data->last_Ep + Ep)/2 * dt;
			data->last_Ep = Ep;
			data->last_speed = *data->speed;

			double Dout = (int) (data->Kp * Ep + data->Ki * data->total_err - data->Kd * dp / dt);
			if (data->debug && *data->debug) 
				if (fabs(Ep)>0.5) 
					printf("%s Ep: %5.3f Ierr: %5.3f dp/dt: %5.3f\n", data->conveyor_name,
							Ep, data->total_err, dp/dt );
			
			if (Dout > 100.0) Dout = 100.0;
			if (Dout < -100.0) Dout = -100.0;
			new_power += Dout;
		}

		if (set_point != 0.0 && std_state) 
			changeState(std_state, "Working");
		else if (set_point == 0.0 && fabs(Ep) < 40) {
			printf("%s stopped\n", data->conveyor_name);
			data->state = cs_stopped;
			data->total_err = 0.0;
			changeState(std_state, "Resetting");
			new_power = 0;
		}

	}

	if (new_power != data->current_power) {
		if (data->debug && *data->debug) printf("%s setting power to %d\n", data->conveyor_name, (int)new_power);
		setIntValue(scope, "driver.VALUE", output_scaled( data, (long)new_power) );
		data->current_power = new_power;
	}

done_polling_actions:
	data->last_poll = now_t;
	
    return PLUGIN_COMPLETED;
}

%END_PLUGIN

	OPTION SetPoint 0;
	OPTION StopPosition 0;
	OPTION TargetPower 0;
	OPTION StopMarker 0;
	OPTION DEBUG 0;
	
	control PIDCONTROL;
	
	interlocked WHEN driver IS interlocked;
	stopped WHEN control IS stop;
	waiting DEFAULT;

	COMMAND stop { SET control TO stop; }

	COMMAND MarkPos {
		StopMarker := pos.VALUE;
		IF (SetPoint > 0) {
			StopPosition := StopMarker + fwd_settings.StoppingDistance;
		} ELSE {
			StopPosition := StopMarker - rev_settings.StoppingDistance;
		};
	}

	# convenience commands
	COMMAND slow {
	    SetPoint := fwd_settings.SlowSpeed; 
	}
	
	COMMAND start { 
    	SetPoint := fwd_settings.FullSpeed;
    }
	
	COMMAND slowrev { 
	    SetPoint := rev_settings.SlowSpeed;
	}

	COMMAND startrev { 
	    SetPoint := rev_settings.FullSpeed;
	}

	COMMAND clear {
		StopPosition := pos.VALUE;
	}
}
