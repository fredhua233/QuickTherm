#include <SystemStatus.h>
#include <SoftwareSerial.h>
#include <OneWire.h> 
#include <DallasTemperature.h>

#define ONE_WIRE_BUS 2 

OneWire oneWire(ONE_WIRE_BUS); 
DallasTemperature sensors(&oneWire);
SoftwareSerial ble_device(8, 9); // BLE TX-> ATtiny85 PB0, BLE RX-> ATtiny85 PB1
SystemStatus dev_status = SystemStatus();


void setup() {
  ble_device.begin(9600); // start BLE device
  delay(500); // wait until BLE device start
  sensors.begin(); 
}
void loop() {
  char msg = 'z';
  if (ble_device.available()) {
    msg = ble_device.read();
  }
  if (msg == 'T') {
    int Vbat = dev_status.getVCC();
    sensors.requestTemperatures();
    float T = sensors.getTempCByIndex(0);
    ble_device.print("T:");
    ble_device.print(T);
    ble_device.print(";Vcc:");
    ble_device.print(Vbat);
    delay(100);
    msg = 'z';
  }
  if (msg == 'C') {
    while(true) {
      char m = 'y';
      if (ble_device.available()) {
         m = ble_device.read();
      }
      int Vbat = dev_status.getVCC();
      
      sensors.requestTemperatures();
      float T = sensors.getTempCByIndex(0);
      
      ble_device.print("T:");
      ble_device.print(T);
      ble_device.print(";Vcc:");
      ble_device.print(Vbat);
      delay(1000);
      if (m == 'S') {
        ble_device.print("Terminate");
        break;
      }
    }
    msg = 'z';
  }
}
