#include <SPIFFS.h>
void setup() {
Serial.begin(9600);

  if (!SPIFFS.begin(true)) {
    Serial.println("An error occurred while mounting SPIFFS.");
    return;
  }

  writeFile("/song3.txt", "0,sol_,1,1,fa_,2,2,me_,3,3,fa_,4,4,sol_,5,5,sol_,6,6,sol_,7,7,fa_,8,8,fa_,9,9,fa_,10,10,sol_,11,11,sol_,12,12,sol_,13,14,sol_,15,15,fa_,16,16,me_,17,17,fa_,18,18,sol_,19,19,sol_,20,20,sol_,21,21,fa_,22,22,fa_,23,23,sol_,24,24,fa_,25,25,me_,26,END");
  writeFile("/song2.txt", "1,do_,2,2,re_,3,3,me_,4,4,fa_,5,5,fa_,6,6,me_,7,7,do_,8,END");
  writeFile("/song1.txt","1,do_,2,2,re_,3,3,me_,4,4,fa_,5,5,sol_,6,6,la_,7,7,si_,8,END");

}

void loop() {
  // put your main code here, to run repeatedly:

}


void writeFile(const char *path, const char *message) {
  Serial.printf("Writing to file: %s\n", path);

  File file = SPIFFS.open(path, FILE_WRITE);

  if (!file) {
    Serial.println("Failed to open file for writing");
    return;
  }

  if (file.print(message)) {
    Serial.println("File written successfully");
  } else {
    Serial.println("Write failed");
  }

  file.close();
}
