/*
 * HC-SR04 -> FPGA sensor pipeline
 * Sends distance readings over a dedicated UART (Serial1) to the FPGA.
 * Single-byte protocol: bit 7 = error flag, bits 6:0 = distance (0-127cm).
 * USB Serial (Serial) is kept free for debug prints only - never mixed
 * with the binary protocol stream.
 */

const int trigPin = 18;
const int echoPin = 19;

const int fpgaTxPin = 17;   // ESP32 TX -> Basys3 Pmod RX pin
const int fpgaRxPin = 16;   // unused here, but Serial1.begin requires a pin

float duration, distance;

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  Serial.begin(115200);                                     // USB debug only
  Serial1.begin(115200, SERIAL_8N1, fpgaRxPin, fpgaTxPin);   // FPGA link
}

void loop() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH, 30000);
  distance = (duration * 0.0343) / 2;

  uint8_t error_flag;
  uint8_t distance_byte;

  if (duration == 0 || distance < 2 || distance > 127) {
    error_flag    = 1;
    distance_byte = 0x80;
  } else {
    error_flag    = 0;
    distance_byte = (uint8_t)distance & 0x7F;
  }

  Serial1.write(distance_byte);

  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.print(" cm | error_flag: ");
  Serial.println(error_flag);

  delay(100);
}