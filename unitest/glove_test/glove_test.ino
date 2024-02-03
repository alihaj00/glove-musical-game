const int pinky = 13;  // Assuming you have connected the button to GPIO pin 2
const int ring= 12; 
const int middle = 14; 
const int indexfinger = 27;//dose not work  

void setup() {
  Serial.begin(9600);
  pinMode(pinky, INPUT_PULLUP);   // Enable internal pull-up resistor for pinky button
  pinMode(ring, INPUT_PULLUP);    // Enable internal pull-up resistor for ring button
  pinMode(middle, INPUT_PULLUP);  // Enable internal pull-up resistor for middle button
  pinMode(indexfinger, INPUT_PULLUP);   // Enable internal pull-up resistor
}

void loop() {
  int pinkeystate = digitalRead(pinky);
  int ringstate = digitalRead(ring);
  int middlestate = digitalRead(middle);
  int indexstate = digitalRead(indexfinger);

  if (pinkeystate == LOW) {
    Serial.println("pinky is toutching thumb!");
    // Your code to handle button press goes here
    delay(1000);  // Optional: debounce delay
  }
  
  if (ringstate == LOW) {
    Serial.println("ring finger is toutching thumb!");
    // Your code to handle button press goes here
    delay(1000);  // Optional: debounce delay
  }

  
  if (middlestate == LOW) {
    Serial.println("middle finger is toutching thumb!");
    // Your code to handle button press goes here
    delay(1000);  // Optional: debounce delay
  }
  
  if (indexstate == LOW) {
    Serial.println("index finger is toutching thumb!");
    // Your code to handle button press goes here
    delay(1000);  // Optional: debounce delay
  }
}
