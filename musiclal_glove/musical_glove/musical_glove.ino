#include "EEPROM.h"
#include <SPIFFS.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

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


#define EEPROM_SIZE 128
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

//#include <ESP32Ping.h>



String bluetoothValue = "";

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;

const int ledPin = 22;
const int modeAddr = 0;
const int wifiAddr = 10;



class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      BLEDevice::startAdvertising();
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};



class MyCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic){
    std::string value = pCharacteristic->getValue();

    if(value.length() > 0){
      Serial.print("Value : ");
      Serial.println(value.c_str());

      bluetoothValue = value.c_str();
      
    }
  }
};


void setup() {
  Serial.begin(9600);
  pinMode(buzzerPin, OUTPUT);
  pinMode(pinky, INPUT_PULLUP);   // Enable internal pull-up resistor for pinky button
  pinMode(ring, INPUT_PULLUP);    // Enable internal pull-up resistor for ring button
  pinMode(middle, INPUT_PULLUP);  // Enable internal pull-up resistor for middle button
  pinMode(indexfinger, INPUT_PULLUP);   // Enable internal pull-up resistor

    if (!SPIFFS.begin(true)) {
    Serial.println("An error occurred while mounting SPIFFS");
    return;
  }

connect_to_bluetooth();
}

bool flag=0,flag2=0;


String Note="";

void loop() {
  static int count=0;
  static String song;
  static String data;
  int pinkeystate = digitalRead(pinky);
  int ringstate = digitalRead(ring);
  int middlestate = digitalRead(middle);
  int indexstate = digitalRead(indexfinger);
  double currentfreq,freq=0 ;


  if (bluetoothValue=="Song1_hear"){
    flag=0;
    playFile(&data ,&flag,"/song1.txt");
    bluetoothValue="";

  }

  if (bluetoothValue=="Song2_hear"){
      flag=0;
      playFile(&data ,&flag,"/song2.txt");
      bluetoothValue="";

  }
    if (bluetoothValue=="Song3_hear"){
      flag=0;
      playFile(&data ,&flag,"/song3.txt");
      bluetoothValue="";

  }
    if (bluetoothValue=="Song1_play"){
      song = "/song1.txt";
      playGame(pinkeystate,ringstate,middlestate,indexstate,song ,&count);
      bluetoothValue="";
      Serial.println(count);
    }
      if (bluetoothValue=="Song2_play"){
      song = "/song2.txt";
      playGame(pinkeystate,ringstate,middlestate,indexstate,song ,&count);
      bluetoothValue="";
      Serial.println(count);
    }

     if (bluetoothValue=="Song3_play"){
      song = "/song3.txt";
      playGame(pinkeystate,ringstate,middlestate,indexstate,song ,&count);
      bluetoothValue="";
      Serial.println(count);
    }
     if (bluetoothValue=="P-reference")
        freq=playMusic( pinkeystate, ringstate, middlestate, indexstate );

  
  //Serial.print("loop value");
  //Serial.println(bluetoothValue);
  //Serial .println(freq);
  //if (bluetoothValue=="hello"){
  //  flag=0;
   // playFile(&data ,&flag,"/note.txt");
  //  bluetoothValue="";}
//
  //buttonWait(pinky,ring,middle,indexfinger);

    //if (bluetoothValue=="")
   // freq=playMusic( pinkeystate, ringstate, middlestate, indexstate );
   // Serial.print("currentfreq=");
   // Serial.println(currentfreq);
   // Serial.print("freq=");
   // Serial.println(freq);
    //if (bluetoothValue=="")
  // if (bluetoothValue=="hello"){
  //   song = "/note.txt";
  //   playGame(pinkeystate,ringstate,middlestate,indexstate,song ,&count);
  //   Serial.println(count);
  // }

  //Serial.print("points= ");
  //Serial.println(counter);
}









void playTone(double frequency, int duration) {
  tone(buzzerPin, frequency, duration);
  delay(duration);
}


double frequency(int indexState, int middleState,int ringState,int pinkyState){
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


String readFromFile( String filename) {
  File file = SPIFFS.open(filename, "r");
  String data = "";

  if (!file) {
    Serial.println("Failed to open file for reading");
    return data;
  }

  while (file.available()) {
    data += (char)file.read();
  }

  file.close();
  return data;
}



////////////////////////////////////////////////////////////////////
String split_remaning(int S ,String inputString){
    char delimiter = ',';

  // Find the position of the first comma
  int commaPosition = inputString.indexOf(",");

  // Extract the rest of the string after the first comma
  String remainingString = inputString.substring(commaPosition + 1);

  return remainingString ;
} 

String split_value(int S ,String inputString){
    char delimiter = ',';

  // Find the position of the first comma
  int commaPosition = inputString.indexOf(",");

  // Extract the first value
  String Value = inputString.substring(0, commaPosition);


  return Value ;
} 

//////////////////////////////////////////////////////
double toneToFreq(String T){
  if (T=="do_")
    return do_;
  if (T=="re_")
    return re_;
  if (T=="me_")
    return me_;
  if (T=="fa_")
    return fa_;
  if (T=="sol_")
    return sol_;
  if (T=="la_")
    return la_;
  if (T=="si_")
    return si_;
  return 0;
}


/////////////////////////////////////////////////////////////////////////
void playOneTone(String tone,String start,String end ,String del){
  int START=start.toInt();
  int END=end.toInt();
  int TONE=toneToFreq(tone);
  int DEL =del.toInt();
  playTone(TONE,(END-START)*500);

  if (DEL!=END)
    delay((DEL-END)*500);

}
String splitNote (int i, String notes ){
  String substring = notes.substring(i, i+9);
  return substring;
}


/////////////////////////////////////////////////////////////
///play hard coded song 
void playFile(String *data ,bool  *flag, char* songName){
  String S,E,N,D;
  
     if (*flag==0){
     *data = readFromFile(songName);
     *flag=1;
  
     Serial.print("data");
     Serial.println(*data);
    }
  Serial.println(data->length());
  while (1){
    Serial.println(*data);

   S=split_value(0,*data);
   *data =split_remaning(0,*data);
  
   N=split_value(0,*data);
   *data =split_remaning(0,*data);
  
   E=split_value(0,*data);
   *data =split_remaning(0,*data);
  
   D=split_value(0,*data);
   
   if (D=="END"){
    playOneTone(N,S,E,E);
    break;
   }
   playOneTone(N,S,E,D);
// if (N!=""){
//   Serial.print("T=");
//   Serial.println(N);
//   Serial.print("S=");
//   Serial.println(S);
//   Serial.print("E=");
//   Serial.println(E);
//   Serial.print("D=");
//   Serial.println(D);
// }
  
   
  }

  Serial.println("that working!");
}



////////////////////////////////////////////////////////////////
double playMusic(int pinkeystate,int ringstate,int middlestate,int indexstate ){
  double freq=frequency(indexstate,middlestate,ringstate,pinkeystate);

  playTone(freq,500);
  
  if (pinkeystate == LOW) {
    Serial.println("pinky is toutching thumb!");
  }
  
  if (ringstate == LOW) {
    Serial.println("ring finger is toutching thumb!");
  }

  
  if (middlestate == LOW) {
    Serial.println("middle finger is toutching thumb!");
  }
  
  if (indexstate == LOW) {
    Serial.println("index finger is toutching thumb!");
  }


  return freq;

}
//////////////////////////////////////////////////////////////////
void playGame(int pinkeystate,int ringstate,int middlestate,int indexstate, String songname ,int *count){
  bool endgame=0;
  double fre=0;
  double currefre;
  String song = readFromFile(songname);
  while (1){
  

  while (fre==0){
    pinkeystate = digitalRead(pinky);
    ringstate = digitalRead(ring);
    middlestate = digitalRead(middle);
    indexstate = digitalRead(indexfinger);
    
    fre=playMusic(pinkeystate,ringstate,middlestate,indexstate);

    }
    

    currefre=getCurrentFreq(&song,&endgame);
    
    comparefreq(fre,currefre,count);
    fre=0;

    if (endgame==1)
      break ;

    
  }

  Serial.print("finish");

}


////////////////////////////////////////////////////////////////
void comparefreq(double freq ,double note , int *counter  ){
  if (freq ==note )
    (*counter)=(*counter)+1;
}

double getCurrentFreq(String *song ,bool *endgame){
    String S,E,N,D;

   
   S=split_value(0,*song);
   *song =split_remaning(0,*song);
  
   N=split_value(0,*song);
   *song =split_remaning(0,*song);
  
   E=split_value(0,*song);
   *song =split_remaning(0,*song);

   D=split_value(0,*song);
   
   if (D=="END")
    *endgame=1;



   return toneToFreq(N);
}



/////////////////////////////////////////////////////////////////////////////////////
void buttonWait(int buttonPin1,int buttonPin2,int buttonPin3,int buttonPin4){
  int buttonState1 = 0;
  int buttonState2 = 0;
  int buttonState3 = 0;
  int buttonState4 = 0;
  while(1){
    buttonState1 = digitalRead(buttonPin1);
    buttonState2 = digitalRead(buttonPin2);
    buttonState3 = digitalRead(buttonPin3);
    buttonState4 = digitalRead(buttonPin4);
    if (buttonState1 == LOW ||buttonState2 == LOW ||buttonState3== LOW||buttonState4 == LOW) {
      return;
    }
  }
}









///////////////////////////////
// bluetooth 
//////////////////////////////
void connect_to_bluetooth(){
   Serial.begin(9600);
  pinMode(ledPin, OUTPUT);

  if(!EEPROM.begin(EEPROM_SIZE)){
    delay(1000);
  }

  //BLE MODE
  digitalWrite(ledPin, true);
  Serial.println("BLE MODE");
  bleTask();
  
}

//////////////////////////////////////////////////////////////




void bleTask(){
  // Create the BLE Device
  BLEDevice::init("ESP32");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );

  pCharacteristic->setCallbacks(new MyCallbacks());
  // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
  // Create a BLE Descriptor
  BLE2902 *c=new BLE2902();
  c->setNotifications(true);
  pCharacteristic->addDescriptor(new BLE2902());


  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println("Waiting a client connection to notify...");
}
