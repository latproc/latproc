# ANALOGINPUT is a new machine class and its usage is changing.

ANALOGIN_SETTINGS MACHINE { 
# a third-order pass-through filter that doesn't cutoff any frequencies
#  C LIST 1.0,3.0,3.0,1.0;
#  D LIST 1.0,3.0,3.0,1.0;

#C LIST 0.000061006178758, 0.000122012357516, 0.000061006178758;
#D LIST 1.000000000000, -1.977786483777, 0.978030508492;

# a third order low pass filter that cuts of at 0.01*Pi
#  C LIST 0.000003756838020,0.000011270514059,0.000011270514059,0.000003756838020;
#  D LIST 1.000000000000,-2.937170728450,2.876299723479,-0.939098940325;

# third order low pass filter 0.1
  C LIST 0.002898194633721,0.008694583901164,0.008694583901164,0.002898194633721;
  D LIST 1.000000000000,-2.374094743709,1.929355669091,-0.532075368312;

  OPTION enable_velocity 1;
  OPTION enable_acceleration 1;
  OPTION enable_stddev 1;

  OPTION velocity_scale 1.0;
  OPTION acceleration_scale 1.00;
  OPTION throttle 30;
 
  idle INITIAL;
}
ain_settings ANALOGIN_SETTINGS(filter:2);
ain_underrange POINT(export:ro) Beckhoff_EL3164, 0;
ain_overrange POINT(export:ro) Beckhoff_EL3164, 1;
ain_error POINT(export:ro) Beckhoff_EL3164, 4;
ain ANALOGINPUT Beckhoff_EL3164, 10, ain_settings;

helper SETTINGS_HELPER ain, ain_settings;

# this machine helps update the filter settings
SETTINGS_HELPER MACHINE input, settings {

  OPTION c0 0.000003756838020;
  OPTION c1 0.000011270514059;
  OPTION C2 0.000011270514059;
  OPTION c3 0.000003756838020;

  OPTION d0 1.000000000000;
  OPTION d1 -2.937170728450;
  OPTION d2 2.876299723479;
  OPTION d3 -0.939098940325;

  COMMAND update {
    CLEAR settings.C;
    PUSH c0 TO settings.C;
    PUSH c1 TO settings.C;
    PUSH c2 TO settings.C;
    PUSH c3 TO settings.C;
    CLEAR settings.D;
    PUSH d0 TO settings.C;
    PUSH d1 TO settings.C;
    PUSH d2 TO settings.C;
    PUSH d3 TO settings.C;

    DISABLE input;
    WAIT 100;
    ENABLE input;
  }
}

#Status__Underrange
#Status__Overrange
#Status__Limit1
#Status__Limit2
#Status__Error
#Status__Sync error
#Status__TxPDO State
#Status__TxPDO Toggle
#AI Standard Channel 1 Value



