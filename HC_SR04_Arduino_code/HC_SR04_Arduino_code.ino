/*
 * HC-SR04 -> FPGA sensor pipeline
 * Sends distance readings over a dedicated UART (Serial1) to the FPGA.
 * USB Serial (Serial) is kept free for debug prints only - never mixed
 * with the binary protocol stream.
 */

const int trigPin = 18;
const int echoPin = 19;

// Dedicated UART pins for the FPGA link - pick free GPIOs, NOT 18/19 (used above)
const int fpgaTxPin = 17;   // ESP32 TX -> Basys3 Pmod RX pin
  const int fpgaRxPin = 16;   // unused here, but Serial1.begin requires a pin

float duration, distance;

void setup() {         
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  Serial.begin(115200);                              // USB debug only
  Serial1.begin(115200, SERIAL_8N1, fpgaRxPin, fpgaTxPin);  // FPGA link
}   

void loop() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH, 30000);   // timeout avoids hanging if no echo
  distance = (duration * 0.0343) / 2;

  uint16_t distance_val;
  uint8_t error_flag;

  if (duration == 0 || distance < 2 || distance > 400) {
    error_flag   = 1;
    distance_val = 0;
  } else {
    error_flag   = 0;
    distance_val = (uint16_t)distance & 0x1FF;   // mask to 9 bits (0-511)
  }

  uint8_t byte0 = distance_val & 0xFF;                          // lower 8 bits
  uint8_t byte1 = ((distance_val >> 8) & 0x01) | (error_flag << 1);  // bit0=MSB, bit1=error

  Serial1.write(byte0);   // to FPGA - distance low byte
  Serial1.write(byte1);   // to FPGA - MSB + error flag

  // Debug output - USB Serial only, never touches the FPGA link
  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.print(" cm | error_flag: ");
  Serial.println(error_flag);

  delay(100);
}