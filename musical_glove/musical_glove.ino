#include "EEPROM.h"
#include <SPIFFS.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <FS.h>
#include <Preferences.h>
#include <ArduinoJson.h>

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
const double P_=0;

Preferences p_ref;

Preferences SongStatics;


int  initialnumber= 50; // Initial size of the array
int Songsnumber = initialnumber; // Current size of the array
char **dynamicArray; // Pointer to the dynamic array of strings
int currentSongsNumber  = 0; // Number of elements currently in the array


String currentuser="";



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
      //Serial.print("Value : ");
      //Serial.println(value.c_str());
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
    //Serial.println("An error occurred while mounting SPIFFS");
    return;


  }
p_ref.begin("USERS", false);
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

 if (bluetoothValue=="get_statistics"){
   String last = readFromFile("/statistics.txt");
   //Serial.println(last);
   sendString(last);
   delay(500);
  bluetoothValue="";

  }

  if (bluetoothValue=="song_list"){
    String x=readFromFile("/Song_List.txt");
    //Serial.println(x);
    sendString(x);
    
    bluetoothValue="";

  }




  if (bluetoothValue=="start_action_savesong"){
    sendString("got_it");
    bluetoothValue="";
    String newsong=receiveString("end_action_savesong");
    record(newsong);
    bluetoothValue="";
  }
  if (bluetoothValue=="start_action_register"){
    sendString("got_it");
    bluetoothValue="";
    String json=receiveString("end_action_register");
    StaticJsonDocument<128> doc;
    

    //Serial.println(json);
    DeserializationError error = deserializeJson(doc, json);

    //Serial.print("Failed to parse JSON: ");
    //Serial.println(error.c_str());
    //Serial.println(json);
    
    String username = doc["username"];
    String password = doc["password"];
    //Serial.println("////////////////");
    //Serial.println(password);
    regester(username,password);
    bluetoothValue="";
  }


  if (bluetoothValue=="start_action_login"){
    sendString("got_it");
    bluetoothValue="";
    String json=receiveString("end_action_login");

    StaticJsonDocument<128> doc;
    delay(1000);
    //Serial.println(json);
    DeserializationError error = deserializeJson(doc, json);

    //Serial.print("Failed to parse JSON: ");
    //Serial.println(error.c_str());
    //Serial.println(json);
    String username = doc["username"];
    String password = doc["password"];
    //Serial.println("////////////////login");
    //Serial.println(password);
    //Serial.println(username);

    log_in(username,password);
    bluetoothValue="";
  }


  //sendString("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq"); 
  
  int underscoreIndex = bluetoothValue.indexOf('_');

  if (underscoreIndex != -1 &&  bluetoothValue!= "get_statistics" &&bluetoothValue!= "song_list" && bluetoothValue!="start_action_login" && bluetoothValue!="start_action_register") {
  
  String songnum = bluetoothValue.substring(0, underscoreIndex);
  String action = bluetoothValue.substring(underscoreIndex + 1);
  int difficulty =0;
  //Serial.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  //Serial.println(songnum);
  //Serial.println(action);
  

  if (songnum=="play" && action.substring(0,4)=="note") {
      //Serial.println(bluetoothValue.substring(10)+"_");
      playOneTone(bluetoothValue.substring(10)+"_",180);
      bluetoothValue="";
      songnum="";
      action="";
  }

  if (action=="delete"){
    delete_song(songnum);
    bluetoothValue="";
  }

  if (action=="hear"){
    flag=0;
    //Serial.println("/Songs/"+songnum+".txt");
    playFile(&data ,&flag,(songnum));
    bluetoothValue="";
    
  }

  else{
    difficulty=action.substring(5).toInt();
    //Serial.println(difficulty);
    action=action.substring(0,4);
    //Serial.println(action);
    bluetoothValue="";}

  if (action=="play"){
    song = songnum;
    playGame(pinkeystate,ringstate,middlestate,indexstate,song ,&count,difficulty);
    bluetoothValue="";
    //Serial.println(count);
    
    count=0;
    bluetoothValue="";
  }
  }
  
 if (bluetoothValue=="P-reference") {
  freq=traial( pinkeystate, ringstate, middlestate, indexstate );
  if (freq==do_)
    sendString("do_");
  if (freq==re_)
    sendString("re_");
  if (freq==me_)
    sendString("me_");
  if (freq==fa_)
    sendString("fa_");
  if (freq==sol_)
    sendString("sol_");
  if (freq==la_)
    sendString("la_");
  if (freq==si_)
    sendString("si_");
  if (freq==0)
    sendString("p_");
    
 }






}



void playTone(double frequency, int duration) {
  tone(buzzerPin, frequency, duration);
  delay(150);
}


double frequency(int indexState, int middleState,int ringState,int pinkyState){
  if (indexState==LOW && middleState==LOW &&ringState==LOW && pinkyState==LOW) {return 0;}
  if (indexState==LOW && middleState==LOW &&ringState==LOW ) {return 0;}
  if (indexState==LOW && middleState==LOW  && pinkyState==LOW) {return 0;}
  if (indexState==LOW &&ringState==LOW && pinkyState==LOW) {return 0;}
  if ( middleState==LOW &&ringState==LOW && pinkyState==LOW) {return 0;}
  if (indexState==LOW && middleState==LOW ) {return re_;}
  if (ringState==LOW && middleState==LOW ) {return fa_;}
  if (ringState==LOW && pinkyState==LOW ) {return la_;}
  if (indexState==LOW  ) {return do_;}
  if (middleState==LOW  ) {return me_;}
  if (ringState==LOW){return sol_;}
  if (pinkyState==LOW) {return si_;}
  return 0;

}


String readFromFile( String filename) {
  File file = SPIFFS.open(filename, "r");
  String data = "";

  if (!file) {
    //Serial.println("Failed to open file for reading");
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
void playOneTone(String tone ,int del){
  int TONE=toneToFreq(tone);
  playTone(TONE,del);


}
String splitNote (int i, String notes ){
  String substring = notes.substring(i, i+9);
  return substring;
}


/////////////////////////////////////////////////////////////
///play hard coded song 
void playFile(String *data ,bool  *flag, String songName){
  std::map<String, String> songsNotes;
  String S,E,N,D;
  
    if (*flag==0){
     
      deserializeJsonToMap2(readFromFile("/Song_notes.txt") , songsNotes);
      //Serial.print(readFromFile("/Song_notes.txt"));
      ////Serial.print(songsNotes["song1"]);
      //Serial.print(songName);
      
      *data = songsNotes[songName];
      *flag=1;
  
     //Serial.print("data");
    // //Serial.println(*data);
    }
  //Serial.println(data->length());
  while (1){
   // //Serial.println(*data);

   S=split_value(0,*data);
   *data =split_remaning(0,*data);
  
   
   if (S=="END"){
    *data =split_remaning(0,*data);
    break;
   }
   playOneTone(S,300);
   
  }

  //Serial.println("that working!");
}

////////////////////////////////////////////////////////////////
double playMusic(int pinkeystate,int ringstate,int middlestate,int indexstate ){
  double freq=frequency(indexstate,middlestate,ringstate,pinkeystate);

  playTone(freq,250);
  /*
  if (pinkeystate == LOW) {
    //Serial.println("pinky is toutching thumb!");
  }
  
  if (ringstate == LOW) {
    //Serial.println("ring finger is toutching thumb!");
  }

  
  if (middlestate == LOW) {
    //Serial.println("middle finger is toutching thumb!");
  }
  
  if (indexstate == LOW) {
    //Serial.println("index finger is toutching thumb!");
  }

*/
  return freq;

}



double traial(int pinkeystate,int ringstate,int middlestate,int indexstate ){
 

  double freq=frequency(indexstate,middlestate,ringstate,pinkeystate);
 
  playTone2(freq,100);
    return freq;
}

void playTone2(double frequency, int duration) {
  tone(buzzerPin, frequency, duration);
  delay(100);
}

//////////////////////////////////////////////////////////////////
void playGame(int pinkeystate,int ringstate,int middlestate,int indexstate, String songname ,int *count, int level ){
  int waitingTime=0;
  int points=0;
  int right=0;
  bool flag=1;
  std::map<std::string, std::map<std::string, std::map<std::string, String>>> my3DMap;

  if (level ==0) waitingTime=2000;
  if (level ==1) waitingTime=3000;
  if (level ==2) waitingTime=1500;
  if (level ==3) waitingTime=1000;


  //Serial.println(waitingTime);


  std::map<String, String> songsNotes;
  String jsonmap;

  bool endgame=0;
  double fre=0;
  double currefre;
  int songlen=0;
  String send1="";
  String send2="";
  String send3="";
  deserializeJsonToMap2(readFromFile("/Song_notes.txt") , songsNotes);
  //Serial.print(readFromFile("/Song_notes.txt"));
  //Serial.print(songsNotes["song1"]);
  //Serial.print(songname);
      
  String song= songsNotes[songname];
  //Serial.println(waitingTime);
  int sendi =0;


  while (1){
    sendi++;
  if (split_value(0,song)=="END"){  
    send1=split_value(0,song);
    String to_send=send1+","+String(sendi);
    sendString(to_send);
  }
  else if(split_value(0,split_remaning(0,song))=="END"){
    send1=split_value(0,song);
    send2=split_value(0,split_remaning(0,song));
    String to_send=send1+","+send2+","+String(sendi);
    sendString(to_send);

  }
  else{
    send1=split_value(0,song);
    //Serial.println(send1);
    send2=split_value(0,split_remaning(0,song));
    
    //Serial.println(send2);
    send3=split_value(0,split_remaning(0,split_remaning(0,song)));
    String to_send=send1+","+send2+","+send3+","+String(sendi);
    
    //Serial.println(send3);
    sendString(to_send);
  }


  
  songlen++;
  
  //Serial.println(song.substring(0,song.indexOf(',')));
  unsigned long startTime = millis(); 


  while (fre==0 &&  millis() -startTime< waitingTime){
    pinkeystate = digitalRead(pinky);
    ringstate = digitalRead(ring);
    middlestate = digitalRead(middle);
    indexstate = digitalRead(indexfinger);
    

    if ( pinkeystate!=LOW && ringstate!=LOW  && middlestate!=LOW  && indexstate!=LOW ){
      flag=1;
      pinkeystate = digitalRead(pinky);
      ringstate = digitalRead(ring);
      middlestate = digitalRead(middle);
      indexstate = digitalRead(indexfinger);
    }
    if (flag && !(pinkeystate!=LOW && ringstate!=LOW  && middlestate!=LOW  && indexstate!=LOW)){
      delay(20);
      pinkeystate = digitalRead(pinky);
      ringstate = digitalRead(ring);
      middlestate = digitalRead(middle);
      indexstate = digitalRead(indexfinger);
    
    fre=playMusic(pinkeystate,ringstate,middlestate,indexstate);
    flag=0;
    }


    if (bluetoothValue=="stop_game"){
      break ;
    }

  }
  unsigned long endTime = millis(); 


    if (bluetoothValue=="stop_game"){
      bluetoothValue="";
      break ;
    }

    currefre=getCurrentFreq(&song,&endgame);


    ////Serial.println(song);
    //Serial.println(fre);
    //Serial.println(currefre);
    if (fre==currefre){
      
      right+=1;
      
      if (endTime-startTime < waitingTime/3){
        sendString("perfect");
        //Serial.println("perfect");
        points+=150;
      }
      else if (endTime-startTime < 2*waitingTime/3){
        sendString("good");
        //Serial.println("good");
        points+=100;
      }
      else if (endTime-startTime < waitingTime){
      sendString("not_bad");
      //Serial.println("not_bad");
      points+=50;}
      
      startTime = millis(); 
      delay(70);
      while ( millis() -startTime< 200){
      pinkeystate = digitalRead(pinky);
      ringstate = digitalRead(ring);
      middlestate = digitalRead(middle);
      indexstate = digitalRead(indexfinger);


        if ((pinkeystate==LOW || ringstate==LOW  || middlestate==LOW  || indexstate==LOW)){
          sendString("not_time");
          //Serial.println("not_time");
        }

    }
      
      
    }
    else{
      String x=String("fail") ;
      sendString(x);
      //Serial.println("fail");
      startTime = millis(); 
      delay(70);
      while ( millis() -startTime< 200){
      pinkeystate = digitalRead(pinky);
      ringstate = digitalRead(ring);
      middlestate = digitalRead(middle);
      indexstate = digitalRead(indexfinger);


      if ((pinkeystate==LOW || ringstate==LOW  || middlestate==LOW  || indexstate==LOW)){
          sendString("not_time");
          //Serial.println("not_time");
      }

    }
      
    }

    //delay(1000);
    
    
    fre=0;

    if (endgame==1){
      String zzz=readFromFile("/statistics.txt");
      //Serial.println(zzz);
      deserializeJsonTo3DMap(zzz,my3DMap);
      ////Serial.println((my3DMap[songname.c_str()][currentuser.c_str()]));

      if (level==1){
        if (hasValue(my3DMap,songname.c_str(),"easy",currentuser.c_str())){
          if (my3DMap[songname.c_str()]["easy"][currentuser.c_str()].toInt()<points){
            my3DMap[songname.c_str()]["easy"][currentuser.c_str()]=String(points);
          }
        }
        else {
          my3DMap[songname.c_str()]["easy"][currentuser.c_str()]=String(points);

        }
      }



      if (level==2){
        if (hasValue(my3DMap,songname.c_str(),"medium",currentuser.c_str())){
          if (my3DMap[songname.c_str()]["medium"][currentuser.c_str()].toInt()<points){      
            my3DMap[songname.c_str()]["medium"][currentuser.c_str()]=String(points);
          }
        }
        else {
          my3DMap[songname.c_str()]["medium"][currentuser.c_str()]=String(points);
        }
      }

      
      if (level==3){
        if (hasValue(my3DMap,songname.c_str(),"hard",currentuser.c_str())){
          if (my3DMap[songname.c_str()]["hard"][currentuser.c_str()].toInt()<points){
            my3DMap[songname.c_str()]["hard"][currentuser.c_str()]=String(points);
          }
        }
        else {
          my3DMap[songname.c_str()]["hard"][currentuser.c_str()]=String(points);
        }
      }
        /////////////////////////////////////////////////////////////////////////////////////
 //   String tyuio=currentuser+"_correct";
 //   right-=1;
 //   if (level==1){
 //     if (hasValue(my3DMap,songname.c_str(),"easy",tyuio.c_str())){
 //       if (my3DMap[songname.c_str()]["easy"][tyuio.c_str()].toInt()<right){
 //         my3DMap[songname.c_str()]["easy"][tyuio.c_str()]=String(right);
 //       }
 //     }
 //     else {
 //       my3DMap[songname.c_str()]["easy"][tyuio.c_str()]=String(right);

 //     }
 //   }



 //   if (level==2){
 //     if (hasValue(my3DMap,songname.c_str(),"medium",tyuio.c_str())){
 //       if (my3DMap[songname.c_str()]["medium"][tyuio.c_str()].toInt()<right){      
 //         my3DMap[songname.c_str()]["medium"][tyuio.c_str()]=String(right);
 //       }
 //     }
 //     else {
 //       my3DMap[songname.c_str()]["medium"][tyuio.c_str()]=String(right);
 //     }
 //   }

 //   
 //   if (level==3){
 //     if (hasValue(my3DMap,songname.c_str(),"hard",tyuio.c_str())){
 //       if (my3DMap[songname.c_str()]["hard"][tyuio.c_str()].toInt()<right){
 //         my3DMap[songname.c_str()]["hard"][tyuio.c_str()]=String(right);
 //       }
 //     }
 //     else {
 //       my3DMap[songname.c_str()]["hard"][tyuio.c_str()]=String(right);
 //     }
 //   }

         ////////////////////////////////////////////////////////////////////////////////////
      if (level==1)
        if (!hasValue(my3DMap,songname.c_str(),"easy","song_played"))
          my3DMap[songname.c_str()]["easy"]["song_played"]="1";
        else{
          int something =(my3DMap[songname.c_str()]["easy"]["song_played"].toInt()+1);
          my3DMap[songname.c_str()]["easy"]["song_played"]=String(something);
        }

      if (level==2)
        if (!hasValue(my3DMap,songname.c_str(),"medium","song_played"))
          my3DMap[songname.c_str()]["medium"]["song_played"]="1";
        else{
          int something =(my3DMap[songname.c_str()]["medium"]["song_played"].toInt()+1);
          my3DMap[songname.c_str()]["medium"]["song_played"]=String(something);
        }
      if (level==3)
        if (!hasValue(my3DMap,songname.c_str(),"hard","song_played"))
          my3DMap[songname.c_str()]["hard"]["song_played"]="1";
        else{
          int something =(my3DMap[songname.c_str()]["hard"]["song_played"].toInt()+1);
          my3DMap[songname.c_str()]["hard"]["song_played"]=String(something);
        }
      
      serialize3DMapToJson(my3DMap,jsonmap);
      writeFile("/statistics.txt",jsonmap);
      break ;
      }

    
  }

  //Serial.print("finish");

}

////////////////////////////////////////////////////////////////
bool hasValue(std::map<std::string, std::map<std::string, std::map<std::string, String>>>& my3DMap,
              const std::string& songname,
              const std::string& difficulty,
              const std::string& currentuser) {
    auto it_song = my3DMap.find(songname);
    if (it_song != my3DMap.end()) {
        auto it_difficulty = it_song->second.find(difficulty);
        if (it_difficulty != it_song->second.end()) {
            auto it_user = it_difficulty->second.find(currentuser);
            if (it_user != it_difficulty->second.end()) {
                return true; // Value found
            }
        }
    }
    return false; // Value not found
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
  
   
   if (S=="END")
    *endgame=1;



   return toneToFreq(S);
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
  //Serial.println("BLE MODE");
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
  //Serial.println("Waiting a client connection to notify...");
}




////////////////////////////////////////////////////////////

void writeFile(const char *path, String message) {
  //Serial.printf("Writing to file: %s\n", path);

  File file = SPIFFS.open(path, FILE_WRITE);

  if (!file) {
    //Serial.println("Failed to open file for writing");
    return;
  }

  if (file.print(message)) {
    //Serial.println("File written successfully");
  } else {
    //Serial.println("Write failed");
  }

  file.close();
}

bool  log_in(String user_name,String password ){
  
  String the_password =p_ref.getString(user_name.c_str() );
  //Serial.println("......................");
  //Serial.println(the_password);
  //Serial.println(user_name);
  //Serial.println("......................");
  if (the_password==""){
    the_password="invalid user";
  }
  if (the_password=="invalid user"){
      int value =0;
      sendString("user dose not exist");
      currentuser="";
    return 0;
  }  
  else {
    if (password==the_password){
      int value =1;
      sendString("login_ok");
      currentuser=user_name;
      return 1;
    }
    else{
      sendString("wrong passowrd");
      currentuser="";
      return 0;
    }
  }
}

bool regester(String user_name,String password ){
  
  String the_password =p_ref.getString(user_name.c_str() );
  if (the_password==""){
    the_password="new user";
  }
  if (the_password=="new user"){
      p_ref.putString(user_name.c_str(),password.c_str());
      sendString("register_ok");
      currentuser=user_name;
      return 1;
  }  
  else {
    sendString("user name already exist");
    currentuser="";
    return 0;
    
  }



}





void writeFile(const char *path, const char *message) {
  //Serial.printf("Writing to file: %s\n", path);

  File file = SPIFFS.open(path, FILE_WRITE);

  if (!file) {
    //Serial.println("Failed to open file for writing");
    return;
  }

  if (file.print(message)) {
    //Serial.println("File written successfully");
  } else {
    //Serial.println("Write failed");
  }

  file.close();
}


void sendString(String str) {
  // Send the string over BLE
  pCharacteristic->setValue(str.c_str());
  pCharacteristic->notify();
}


String receiveString(String endstring) {
  String receivedString = ""; 

  while (bluetoothValue != endstring) {  
    
    if ( bluetoothValue!="" ) {
      receivedString += bluetoothValue; 
      sendString("got_it");
      bluetoothValue="";
     // //Serial.println("receivedString=");
     // //Serial.println(receivedString);
    }

    
    delay(1);
  }
  //Serial.println("receivedString=");
  //Serial.println(receivedString);
  
  return receivedString;
}




// Function to serialize a map to a JSON string
void serializeMapToJson(const std::map<int, String>& mapData, String& jsonString) {
  // Create a DynamicJsonDocument
  DynamicJsonDocument doc(JSON_OBJECT_SIZE(mapData.size())); // Estimate the capacity based on the number of key-value pairs
  
  // Populate the JSON document with key-value pairs from the map
  for (const auto& entry : mapData) {
    // Check if the value is valid (not null or empty)
    if (entry.second != "" && entry.second != "null") {
      doc[String(entry.first)] = entry.second; // Convert int key to String
    }
  }
  
  // Serialize the JSON document to a string
  serializeJson(doc, jsonString);
}

// Function to deserialize a JSON string back into a map
void deserializeJsonToMap(const String& jsonString, std::map<int, String>& mapData) {
  // Create a DynamicJsonDocument
  DynamicJsonDocument doc(JSON_OBJECT_SIZE(mapData.size()) + jsonString.length());
  
  // Deserialize the JSON string
  DeserializationError error = deserializeJson(doc, jsonString);
  if (error) {
    //Serial.print("deserializeJson() failed: ");
    //Serial.println(error.c_str());
    return;
  }
  
  // Clear the existing map
  mapData.clear();
  
  // Populate the map with key-value pairs from the JSON document
  for (auto entry : doc.as<JsonObject>()) { // Removed const from auto&
    int key = atoi(entry.key().c_str()); // Convert string key to integer
    String value = entry.value().as<String>(); // Store the value in a local variable
    mapData[key] = value; // Assign the value to the map
  }
}



// Function to serialize a map to a JSON string
void serializeMapToJson2(const std::map<String, String>& mapData, String& jsonString) {
  // Create a DynamicJsonDocument
  DynamicJsonDocument doc(JSON_OBJECT_SIZE(mapData.size())); // Estimate the capacity based on the number of key-value pairs
  
  // Populate the JSON document with key-value pairs from the map
  for (const auto& entry : mapData) {
    // Check if the value is valid (not null or empty)
    if (entry.second != "" && entry.second != "null") {
      doc[String(entry.first)] = entry.second; // Convert int key to String
    }
  }
  
  // Serialize the JSON document to a string
  serializeJson(doc, jsonString);
}

// Function to deserialize a JSON string back into a map
void deserializeJsonToMap2(const String& jsonString, std::map<String, String>& mapData) {
  // Create a DynamicJsonDocument
  DynamicJsonDocument doc(JSON_OBJECT_SIZE(mapData.size()) + jsonString.length());
  
  // Deserialize the JSON string
  DeserializationError error = deserializeJson(doc, jsonString);
  if (error) {
    //Serial.print("deserializeJson() failed: ");
    //Serial.println(error.c_str());
    return;
  }
  
  // Clear the existing map
  mapData.clear();
  
  // Populate the map with key-value pairs from the JSON document
  for (auto entry : doc.as<JsonObject>()) {
    String key = entry.key().c_str(); // Extract the key as a C-string
    String value; // Define a variable to store the value

    // Extract the value based on its type
    if (entry.value().is<String>()) {
      value = entry.value().as<String>();
    } else if (entry.value().is<int>()) {
      value = String(entry.value().as<int>());
    } // Add other types as needed
    
    mapData[key] = value; // Assign the value to the map
  }
}



void serialize3DMapToJson(const std::map<std::string, std::map<std::string, std::map<std::string, String>>>& mapData, String& jsonString) {
  // Create a DynamicJsonDocument
  DynamicJsonDocument doc(JSON_OBJECT_SIZE(mapData.size())); // Estimate the capacity based on the number of key-value pairs
  
  // Populate the JSON document with key-value pairs from the map
  for (const auto& entry1 : mapData) {
    JsonObject obj1 = doc.createNestedObject(entry1.first);
    for (const auto& entry2 : entry1.second) {
      JsonObject obj2 = obj1.createNestedObject(entry2.first);
      for (const auto& entry3 : entry2.second) {
        obj2[entry3.first] = entry3.second;
      }
    }
  }
  
  // Serialize the JSON document to a string
  serializeJson(doc, jsonString);
}

void deserializeJsonTo3DMap(const String& jsonString, std::map<std::string, std::map<std::string, std::map<std::string, String>>>& map3D) {
    DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, jsonString);

    if (error) {
        //Serial.print(F("deserializeJson() failed: "));
        //Serial.println(error.c_str());
        return;
    }

    for (auto it1 = doc.as<JsonObject>().begin(); it1 != doc.as<JsonObject>().end(); ++it1) {
        std::map<std::string, std::map<std::string, String>> innerMap1;
        JsonObject obj1 = it1->value();
        for (auto it2 = obj1.begin(); it2 != obj1.end(); ++it2) {
            std::map<std::string, String> innerMap2;
            JsonObject obj2 = it2->value();
            for (auto it3 = obj2.begin(); it3 != obj2.end(); ++it3) {
                innerMap2[it3->key().c_str()] = it3->value().as<String>();
            }
            innerMap1[it2->key().c_str()] = innerMap2;
        }
        map3D[it1->key().c_str()] = innerMap1;
    }
}


void record (String json){
    StaticJsonDocument<128> doc;
    std::map<int, String> newList;
    std::map<String, String> newNotsList;
    String list1;
    String list2;




    //Serial.println(json);
    DeserializationError error = deserializeJson(doc, json);
    
    
    deserializeJsonToMap(readFromFile("/Song_List.txt") , newList);
    deserializeJsonToMap2(readFromFile("/Song_notes.txt") , newNotsList);

    String aaaaaaa=doc["songname"].as<String>();
    if (newNotsList.find(aaaaaaa)!=newNotsList.end()){
      sendString("name_already_exist");
      return;
    }

    newList[newList.size()+2]=doc["songname"].as<String>();
    //Serial.println(newList[newList.size()+2]);
    
    newNotsList[doc["songname"]]=doc["notes"].as<String>();

    serializeMapToJson(newList, list1);
    serializeMapToJson2(newNotsList, list2);

    writeFile("/Song_List.txt",list1);
    writeFile("/Song_notes.txt",list2);

    sendString("save_ok");
}

int findKey(const std::map<int, String>& myMap, String& valueToFind) {
    for (const auto& pair : myMap) {
        if (pair.second == valueToFind) {
            return pair.first; // Return the key if the string is found
        }
    }
    return -1; // Return -1 if the string is not found
}




void delete_song (String songname){
   StaticJsonDocument<128> doc;
    std::map<int, String> newList;
    std::map<String, String> newNotsList;
    String list1;
    String list2;


    String zzz=readFromFile("/statistics.txt");
    //Serial.println(zzz);



    deserializeJsonToMap(readFromFile("/Song_List.txt") , newList);
    int keyToDelete = findKey(newList, songname);
    if (keyToDelete != -1) 
      newList.erase(keyToDelete);
    
    deserializeJsonToMap2(readFromFile("/Song_notes.txt") , newNotsList);
    newNotsList.erase(songname);    

    serializeMapToJson(newList, list1);
    serializeMapToJson2(newNotsList, list2);
    writeFile("/Song_List.txt",list1);
    writeFile("/Song_notes.txt",list2);


}



