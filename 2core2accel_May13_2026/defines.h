#ifndef defines_h
#define defines_h

#if !( defined(ARDUINO_RASPBERRY_PI_PICO_W) )
  #error For RASPBERRY_PI_PICO_W only
#endif

#include <WiFi.h>

char ssid[] = "cuWaterRouter";        // your network SSID (name)
char pass[] = "mrmoop2026!";         // your network password (use for WPA, or use as key for WEP), length must be 8+
                                    // edit: 8/23/26: This password should technically be redacted, but if came all this way just for it, you deserve it. 

#endif    //defines_h
