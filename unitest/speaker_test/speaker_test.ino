const int buzzerPin = 25; // Assuming you have connected the KY-012 to GPIO pin 25

void setup() {
  Serial.begin(9600);
  pinMode(buzzerPin, OUTPUT);
}

void loop() {
  int frequency = 0; // Generate a random frequency between 500 and 2000 Hz
  int duration = 500; // Set a constant duration for simplicity

  playTone(frequency, duration);  // Play the generated tone
  delay(1000); // Wait for 1 second

  // Print the generated amplitude (assuming the maximum amplitude is 127 for simplicity)
  int amplitude = 127; // You may need to adjust this based on your actual setup
  Serial.print("Frequency: ");
  Serial.print(frequency);
  Serial.print(" Hz, Amplitude: ");
  Serial.println((buzzerPin));
}

void playTone(int frequency, int duration) {
  tone(buzzerPin, frequency, duration);
}
