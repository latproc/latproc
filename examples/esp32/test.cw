# this is how we can instantiate objects for the esp32 demo

esp32 ESP32; # CPU defined in the runtime support
gateway32 OLIMEX_GATEWAY32 esp32; # board defined in the runtime support

# gateway32 MODULE (cpu: ESP32, board: OLIMEX_GATEWAY32); alternative setup, not functional yet

button INPUT gateway32, gateway32.BUT1;
#led OUTPUT gateway32, gateway32.LED;
left ANALOGOUTPUT gateway32, gateway32.GPIO16;
right ANALOGOUTPUT gateway32, gateway32.GPIO17;
left_dir OUTPUT gateway32, gateway32.GPIO32;
right_dir OUTPUT gateway32, gateway32.LED;

pulser Pulse (delay:50);
left_motor Ramp(start: 13000, end: 15000) pulser, left, left_dir;
right_motor Ramp pulser, right, right_dir;
d_button DebouncedInput button;
speed_select SpeedSelect d_button, pulser;

