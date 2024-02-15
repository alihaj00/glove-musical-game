



const int pinky = 13;  // Assuming you have connected the button to GPIO pin 2
const int ring= 12; 
const int middle = 14; 
const int indexfinger = 27;

const int buzzerPin=2;

const double do_=220.00 *2;
const double re_=246.94 *2; 
const double me_=261.63 *2; 
const double fa_=293.66 *2; 
const double sol_=329.63 *2;
const double la_=349.23 *2;
const double si_=392.00 *2;


void setup() {
  Serial.begin(9600);
  pinMode(buzzerPin, OUTPUT);
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

  int freq=frequency(indexstate,middlestate,ringstate,pinkeystate);

  playTone(freq,500);
  Serial.println(freq);


  if (pinkeystate == LOW) {
    Serial.println("pinky is toutching thumb!");
    // Your code to handle button press goes here
      // Optional: debounce delay
  }
  
  if (ringstate == LOW) {
    Serial.println("ring finger is toutching thumb!");
    // Your code to handle button press goes here
   // Optional: debounce delay
  }

  
  if (middlestate == LOW) {
    Serial.println("middle finger is toutching thumb!");
    // Your code to handle button press goes here
      // Optional: debounce delay
  }
  
  if (indexstate == LOW) {

    Serial.println("index finger is toutching thumb!");
    // Your code to handle button press goes here
     // Optional: debounce delay
  }
}

void playTone(int frequency, int duration) {
  tone(buzzerPin, frequency, duration);
  delay(duration);
}


int frequency(int indexState, int middleState,int ringState,int pinkyState){
  if (indexState==LOW && middleState==LOW &&ringState==LOW && pinkyState==LOW) {return 0;}
  if (indexState==LOW && middleState==LOW &&ringState==LOW ) {return 0;}
  if (indexState==LOW && middleState==LOW  && pinkyState==LOW) {return 0;}
  if (indexState==LOW &&ringState==LOW && pinkyState==LOW) {return 0;}
  if ( middleState==LOW &&ringState==LOW && pinkyState==LOW) {return 0;}
  if (indexState==LOW && middleState==LOW ) {return sol_;}
  if (ringState==LOW && middleState==LOW ) {return la_;}
  if (ringState==LOW && pinkyState==LOW ) {return si_;}
  if (indexState==LOW  ) {return do_;}
  if (middleState==LOW  ) {return re_;}
  if (ringState==LOW){return me_;}
  if (pinkyState==LOW) {return fa_;}
  return 0;

}