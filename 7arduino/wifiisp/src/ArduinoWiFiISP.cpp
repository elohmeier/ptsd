#include <SPI.h>
#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <ESP8266AVRISP.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

// DEFINE HERE THE KNOWN NETWORKS
const char* KNOWN_SSID[] = {"SSID-1", "SSID-2"};
const char* KNOWN_PASSWORD[] = {"Password-SSID-1", "Password-SSID-2"};

const int   KNOWN_SSID_COUNT = sizeof(KNOWN_SSID) / sizeof(KNOWN_SSID[0]); // number of known networks

const char* host = "ArduinoWiFiISP";
const uint16_t port = 328;
const uint8_t reset_pin = 2;

#define OLED_RESET 0  // GPIO0

ESP8266AVRISP avrprog(port, reset_pin);

Adafruit_SSD1306 OLED(OLED_RESET);

void setup() {
  OLED.begin();
  OLED.clearDisplay();
 
  //Add stuff into the 'display buffer'
  OLED.setTextWrap(false);
  OLED.setTextSize(1);
  OLED.setTextColor(WHITE);
  OLED.setCursor(0,0);
  OLED.println("Arduino WiFiISP");
  
  Serial.begin(230400);
  Serial.println("");
  Serial.println("Arduino AVR-ISP over TCP");
  avrprog.setReset(false); // let the AVR run

  boolean wifiFound = false;
  int i, n;

  Serial.begin(230400);

  // ----------------------------------------------------------------
  // Set WiFi to station mode and disconnect from an AP if it was previously connected
  // ----------------------------------------------------------------
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(100);
  Serial.println("Setup done");

  // ----------------------------------------------------------------
  // WiFi.scanNetworks will return the number of networks found
  // ----------------------------------------------------------------
  Serial.println(F("scan start"));
  int nbVisibleNetworks = WiFi.scanNetworks();
  Serial.println(F("scan done"));
  if (nbVisibleNetworks == 0) {
    Serial.println(F("no networks found. Reset to try again"));
    while (true); // no need to go further, hang in there, will auto launch the Soft WDT reset
  }

  // ----------------------------------------------------------------
  // if you arrive here at least some networks are visible
  // ----------------------------------------------------------------
  Serial.print(nbVisibleNetworks);
  Serial.println(" network(s) found");

  // ----------------------------------------------------------------
  // check if we recognize one by comparing the visible networks
  // one by one with our list of known networks
  // ----------------------------------------------------------------
  for (i = 0; i < nbVisibleNetworks; ++i) {
    Serial.println(WiFi.SSID(i)); // Print current SSID
    for (n = 0; n < KNOWN_SSID_COUNT; n++) { // walk through the list of known SSID and check for a match
      if (strcmp(KNOWN_SSID[n], WiFi.SSID(i).c_str())) {
        Serial.print(F("\tNot matching "));
        Serial.println(KNOWN_SSID[n]);
      } else { // we got a match
        wifiFound = true;
        break; // n is the network index we found
      }
    } // end for each known wifi SSID
    if (wifiFound) break; // break from the "for each visible network" loop
  } // end for each visible network

  if (!wifiFound) {
    Serial.println(F("no Known network identified. Reset to try again"));
    OLED.println("no Known network identified. Reset to try again");
    OLED.display(); //output 'display buffer' to screen  

    while (true); // no need to go further, hang in there, will auto launch the Soft WDT reset
  }

  // ----------------------------------------------------------------
  // if you arrive here you found 1 known SSID
  // ----------------------------------------------------------------
  Serial.print(F("\nConnecting to "));
  Serial.println(KNOWN_SSID[n]);

  // ----------------------------------------------------------------
  // We try to connect to the WiFi network we found
  // ----------------------------------------------------------------
  WiFi.begin(KNOWN_SSID[n], KNOWN_PASSWORD[n]);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");

  // ----------------------------------------------------------------
  // SUCCESS, you are connected to the known WiFi network
  // ----------------------------------------------------------------

  MDNS.begin(host);
  MDNS.addService("avrisp", "tcp", port);

  IPAddress local_ip = WiFi.localIP();
  Serial.print("IP address: ");
  Serial.println(local_ip);
  OLED.println(" ");
  OLED.println(KNOWN_SSID[n]);
  OLED.print(local_ip);
  OLED.print(":");
  OLED.println(port);
  OLED.display(); //output 'display buffer' to screen  
  Serial.println("Use your avrdude:");
  Serial.print("avrdude -b 230400 -c arduino -p <device> -P net:");
  Serial.print(local_ip);
  Serial.print(":");
  Serial.print(port);
  Serial.println(" -t # or -U ...");

  // listen for avrdudes
  avrprog.begin();
}

void loop() {
  static AVRISPState_t last_state = AVRISP_STATE_IDLE;
  AVRISPState_t new_state = avrprog.update();
  if (last_state != new_state) {
    switch (new_state) {
      case AVRISP_STATE_IDLE: {
          Serial.printf("[AVRISP] now idle\r\n");
          // Use the SPI bus for other purposes
          break;
        }
      case AVRISP_STATE_PENDING: {
          Serial.printf("[AVRISP] connection pending\r\n");
          // Clean up your other purposes and prepare for programming mode
          break;
        }
      case AVRISP_STATE_ACTIVE: {
          Serial.printf("[AVRISP] programming mode\r\n");
          // Stand by for completion
          break;
        }
    }
    last_state = new_state;
  }
  // Serve the client
  if (last_state != AVRISP_STATE_IDLE) {
    avrprog.serve();
  }

  if (WiFi.status() == WL_CONNECTED) {
    MDNS.update();
  }
}
