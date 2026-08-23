#include "defines.h"

#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <Adafruit_H3LIS331.h>
#include <AsyncUDP_RP2040W.h>

// SENSORS + I2C

Adafruit_MPU6050 mpu;
Adafruit_H3LIS331 lis;

TwoWire CustomI2C0(i2c0, 20, 21);

// WIFI / UDP

IPAddress pcIP(192, 168, 0, 100);

#define MSG_PORT 4444

AsyncUDP Udp;

int status = WL_IDLE_STATUS;

// ======================================================
// CSV SEND FUNCTIONS
// ======================================================

// ------------------------------------------------------
// LOW-G CSV
// ------------------------------------------------------

void sendLowGCSV(
  uint32_t us,
  float ax,
  float ay,
  float az
)
{
  char buf[96];

  int len = snprintf(
    buf,
    sizeof(buf),
    "%lu,%.5f,%.5f,%.5f\n",
    us,
    ax,
    ay,
    az
  );

  Udp.write((uint8_t*)buf, len);
}

// ------------------------------------------------------
// HIGH-G CSV
// ------------------------------------------------------

void sendHighGCSV(
  uint32_t us,
  float hx,
  float hy,
  float hz
)
{
  char buf[96];

  int len = snprintf(
    buf,
    sizeof(buf),
    "%lu,%.5f,%.5f,%.5f\n",
    us,
    hx,
    hy,
    hz
  );

  Udp.write((uint8_t*)buf, len);
}

// ======================================================
// CORE 0 — SENSOR ACQUISITION
// ======================================================

void setup()
{
  Serial.begin(115200);

  while (!Serial)
    delay(10);

  Serial.println("Core0 init");

  // --------------------------------------------------
  // I2C
  // --------------------------------------------------

  CustomI2C0.begin();

  // 1 MHz I2C
  CustomI2C0.setClock(1000000);

  // --------------------------------------------------
  // MPU6050
  // --------------------------------------------------

  if (!mpu.begin(MPU6050_I2CADDR_DEFAULT, &CustomI2C0, 0))
  {
    Serial.println("MPU6050 failed");

    while (1)
      tight_loop_contents();
  }

  // --------------------------------------------------
  // H3LIS331
  // --------------------------------------------------

  if (!lis.begin_I2C(0x18, &CustomI2C0, 0))
  {
    Serial.println("H3LIS331 failed");

    while (1)
      tight_loop_contents();
  }

  // ==================================================
  // LOW-G SETTINGS (MPU6050)
  // ==================================================

  mpu.setAccelerometerRange(MPU6050_RANGE_16_G);

  mpu.setGyroRange(MPU6050_RANGE_250_DEG);

  mpu.setFilterBandwidth(MPU6050_BAND_44_HZ);

  // ==================================================
  // HIGH-G SETTINGS (H3LIS331)
  // ==================================================

  lis.setRange(H3LIS331_RANGE_400_G);

  lis.setDataRate(LIS331_DATARATE_1000_HZ);

  Serial.println("Core0 ready");
}

// ======================================================
// MAIN LOOP
// ======================================================

void loop()
{
  uint32_t us = micros();

  // ==================================================
  // HIGH-G ACQUISITION + TRANSMISSION
  // ==================================================

  sensors_event_t highGEvent;

  lis.getEvent(&highGEvent);

  float hx = highGEvent.acceleration.x;
  float hy = highGEvent.acceleration.y;
  float hz = highGEvent.acceleration.z;

  sendHighGCSV(us, hx, hy, hz);

  // ==================================================
  // LOW-G ACQUISITION + TRANSMISSION
  // ==================================================
  /*
  sensors_event_t a, g, t;

  mpu.getEvent(&a, &g, &t);

  float ax = a.acceleration.x;
  float ay = a.acceleration.y;
  float az = a.acceleration.z;

  sendLowGCSV(us, ax, ay, az);
  */
}

// ======================================================
// CORE 1 — WIFI + UDP
// ======================================================

void setup1()
{
  Serial.println("Core1 init");

  if (WiFi.status() == WL_NO_MODULE)
  {
    Serial.println("WiFi module failed");

    while (1)
      tight_loop_contents();
  }

  status = WiFi.begin(ssid, pass);

  while (status != WL_CONNECTED)
  {
    delay(200);

    status = WiFi.status();
  }

  Serial.println("WiFi connected");

  if (Udp.connect(pcIP, MSG_PORT))
    Serial.println("UDP connected");
  else
    Serial.println("UDP failed");
}

void loop1()
{
  // idle core
  delay(1);
}
