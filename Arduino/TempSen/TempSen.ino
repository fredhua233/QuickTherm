#include <SystemStatus.h>
#include <SoftwareSerial.h>
SoftwareSerial ble_device(8, 9); // BLE TX-> ATtiny85 PB0, BLE RX-> ATtiny85 PB1
SystemStatus dev_status = SystemStatus();
int ThermistorPin = 3;
float Vo, Vin;
float R1 = 10000;
float logR2, R2, T;
float c1 = 0.2501292874e-03, c2 = 3.847945539e-04, c3 = -5.719579276e-07;

volatile int ii = 0; // integer to iterate

void setup() {
  pinMode(ThermistorPin, INPUT);

  ble_device.begin(9600); // start BEL device
  delay(500); // wait until BLE device start
}

void loop() {
  char msg = 'z';
  if (ble_device.available()) {
    msg = ble_device.read();
  }
  if (msg == 'T') {
    Vo = analogRead(ThermistorPin);
    int Vbat = dev_status.getVCC();
    //Using Temp sensor:
  //  T = (((5000.0/Vin)*Vo)-500.0)/10.0;
    // Using Thermistor
    R2 = R1 * (1023.0 / (float)Vo - 1.0);
    logR2 = log(R2);
    T = (1.0 / (c1 + c2 * logR2 + c3 * logR2 * logR2 * logR2));
    T = T - 273.15;
    
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
      Vo = analogRead(ThermistorPin);
      int Vbat = dev_status.getVCC();
      //Using Temp sensor:
    //  T = (((5000.0/Vin)*Vo)-500.0)/10.0;
      // Using Thermistor
      R2 = R1 * (1023.0 / (float)Vo - 1.0);
      logR2 = log(R2);
      T = (1.0 / (c1 + c2 * logR2 + c3 * logR2 * logR2 * logR2));
      T = T - 273.15;
      
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
