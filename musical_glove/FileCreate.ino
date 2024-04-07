#include <SPIFFS.h>
#include <ArduinoJson.h>
#include <map>


std::map<int, String> songs;
std::map<String, String> songsNotes;
std::map<std::string, std::map<std::string, std::map<std::string, String>>> my3DMap;
String jsonString;
String jsonString2;
String jsonString3;



void setup() {
Serial.begin(9600);
// clearSPIFFS();
 if (!SPIFFS.begin(true)) {
  Serial.println("An error occurred while mounting SPIFFS.");
   return;
}
// 
// songs[1]="song1";
// songs[2]="song2";
// songs[3]="song3";
// Serial.println(songs.size());
// 
// songsNotes[songs[1]]="do_,re_,me_,fa_,sol_,la_,si_,END";
// songsNotes[songs[2]]="do_,re_,me_,fa_,fa_,me_,do_,END";
// songsNotes[songs[3]]="sol_,fa_,me_,fa_,sol_,sol_,sol_,fa_,fa_,fa_,sol_,sol_,sol_,p_,sol_,fa_,me_,fa_,sol_,sol_,sol_,fa_,fa_,sol_,fa_,me_,END";
// serializeMapToJson2(songsNotes, jsonString2);
// Serial.println("Serialized JSON:");
// Serial.println(jsonString2);
// 
// 
// serializeMapToJson(songs, jsonString);
// Serial.println("Serialized JSON:");
// Serial.println(jsonString);
// const char* sl=jsonString.c_str();
// writeFile("/Song_List.txt", sl);
//
// const char* s2=jsonString2.c_str();
// writeFile("/Song_notes.txt", s2);
// songsNotes.clear();
// deserializeJsonToMap2(jsonString2, songsNotes);
// deserializeJsonToMap(jsonString, songs);
// Serial.println(songs[1]);
//
//
// 
 //createFolder("/Songs");
 //createFolder("/Statics");
 //writeFile("/Statics/song3.txt", "");
 //writeFile("/Statics/song2.txt", "");
 //writeFile("/Statics/song1.txt","");

 //
 //writeFile("/Songs/song3.txt", "sol_,fa_,me_,fa_,sol_,sol_,sol_,fa_,fa_,fa_,sol_,sol_,sol_,p_,sol_,fa_,me_,fa_,sol_,sol_,sol_,fa_,fa_,sol_,fa_,me_,END");
 //writeFile("/Songs/song2.txt", "do_,re_,me_,fa_,fa_,me_,do_,END");
 //writeFile("/Songs/song1.txt","do_,re_,me_,fa_,sol_,la_,si_,END");


    // Initialize the 3D map with some sample data
  //my3DMap[" qw"]["qw "]["qwe "] = " qdwfe";

   
 songs[1]="song1";
 songs[2]="song2";
 songs[3]="song3";
 Serial.println(songs.size());
 
 songsNotes[songs[1]]="do_,re_,me_,fa_,sol_,la_,si_,END";
 songsNotes[songs[2]]="do_,re_,me_,fa_,fa_,me_,do_,END";
 songsNotes[songs[3]]="sol_,fa_,me_,fa_,sol_,sol_,sol_,fa_,fa_,fa_,sol_,sol_,sol_,p_,sol_,fa_,me_,fa_,sol_,sol_,sol_,fa_,fa_,sol_,fa_,me_,END";
 serializeMapToJson2(songsNotes, jsonString2);
 Serial.println("Serialized JSON:");
 Serial.println(jsonString2);
 
 
 serializeMapToJson(songs, jsonString);
 Serial.println("Serialized JSON:");
 Serial.println(jsonString);
 const char* sl=jsonString.c_str();
 writeFile("/Song_List.txt", sl);
//
 const char* s2=jsonString2.c_str();
  writeFile("/Song_notes.txt", s2);

  deleteFolder(SPIFFS, "/Statics");
  deleteFolder(SPIFFS, "/Songs");

  
  my3DMap["song1"]["_"]["_"] = "0";

  serialize3DMapToJson(my3DMap,jsonString3);
  
  writeFile("/statistics.txt", jsonString3);


  //Serial.println(readFromFile("/statistics.txt"));
  //deserializeJsonTo3DMap(readFromFile("/statistics.txt"),my3DMap);
//
  
  
  
  // Serialize the 3D map to a JSON string


}

void loop() {
 Serial.println(readFromFile("/statistics.txt"));

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

void writeFile(const char *path, String message) {
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


void createFolder(const char* folderPath) {
  if (!SPIFFS.mkdir(folderPath)) {
    Serial.println("Error creating folder");
    return;
  }

  Serial.println("Folder created successfully.");
}

void clearSPIFFS() {
  File root = SPIFFS.open("/");
  File file = root.openNextFile();
  while (file) {
    if (file.isDirectory()) {
      // Do nothing for directories
    } else {
      // Delete the file
      SPIFFS.remove(file.name());
    }
    file = root.openNextFile();
  }
  Serial.println("All files cleared from SPIFFS.");
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
    Serial.print("deserializeJson() failed: ");
    Serial.println(error.c_str());
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
    Serial.print("deserializeJson() failed: ");
    Serial.println(error.c_str());
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
        Serial.print(F("deserializeJson() failed: "));
        Serial.println(error.c_str());
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

void deleteFolder(fs::FS &fs, const char *path) {
  Serial.printf("Deleting folder: %s\n", path);

  File root = fs.open(path);
  if (!root || !root.isDirectory()) {
    Serial.println("Failed to open directory");
    return;
  }

  File file = root.openNextFile();
  while (file) {
    if (file.isDirectory()) {
      deleteFolder(fs, file.name());
    } else {
      Serial.printf("Deleting file: %s\n", file.name());
      fs.remove(file.name());
    }
    file = root.openNextFile();
  }

  Serial.printf("Deleting folder: %s\n", path);
  fs.rmdir(path);
}



