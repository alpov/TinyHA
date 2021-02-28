#include <GxEPD2_BW.h>
#include <WiFi.h>
#include <driver/dac.h>
#include <esp_int_wdt.h>
#include <esp_task_wdt.h>
#include <rom/ets_sys.h>
#include "board.h"
#include "./config.h"
//#include "paulvha_SCD30.h"

GxEPD2_BW<GxEPD2_290, GxEPD2_290::HEIGHT> display(GxEPD2_290(/*CS=*/ ELINK_SS, /*DC=*/ ELINK_DC, /*RST=*/ ELINK_RESET, /*BUSY=*/ ELINK_BUSY));
//SCD30 airSensor;

extern void OTAWebUpdater(void);


const char *ssid     = WIFI_SSID;
const char *password = WIFI_PASSWORD;
const char *host     = "tinyha.lan";

#define UPDATE_INTERVAL 10000


void do_beep()
{
    static const uint8_t dataBuffer[] = {
#include "sound.h"
    };

    for (uint32_t i = 0; i < sizeof(dataBuffer); i++) {
        dac_output_voltage(DAC_CHANNEL_1, dataBuffer[i]);
        ets_delay_us(21);
    }
}


void hard_restart()
{
    esp_task_wdt_init(1, true);
    esp_task_wdt_add(NULL);
    while (true) {}
}


bool update_display(uint8_t btn)
{
    static bool restart = true;
    
    Serial.println("");
    Serial.print("Connecting to ");
    Serial.println(host);

    // Use WiFiClient class to create TCP connections
    WiFiClient client;
    if (!client.connect(host, 80)) {
        Serial.println("connection failed");
        return false;
    }

    // We now create a URI for the request
    String url = "/screen.php";

    if (restart) {
        url += "?reset=1";
        restart = false;
    }
    else if (btn) {
        url += "?btn=";
        url += btn;
    }

    Serial.print("Requesting URL: ");
    Serial.println(url);

    // This will send the request to the server
    client.print(String("GET ") + url + " HTTP/1.1\r\n" +
                 "Host: " + host + "\r\n" +
                 "Connection: close\r\n\r\n");
    uint32_t timeout = millis();
    while (client.available() == 0) {
        if (millis() - timeout > 5000) {
            Serial.println(">>> Client Timeout 1!");
            client.stop();
            return false;
        }
    }

    String line = client.readStringUntil('\r');
    uint8_t beep = 0;
    if (line.indexOf("200") > 0) {
        do {
            line = client.readStringUntil('\r');
            line.trim();
            if (line.indexOf("X-Beep") == 0) beep = atoi(&line.c_str()[line.indexOf(":")+2]);
        } while (client.available() && line != "");
        client.readStringUntil('\n');

        line = client.readStringUntil('\n');
        Serial.print("Image header: ");
        Serial.println(line);

        if (line.indexOf("P4 296 128") == 0) {
            uint8_t img[296 * 128 / 8];
            uint32_t timeout = millis();
            while (client.available() < sizeof(img)) {
                if (millis() - timeout > 5000) {
                    Serial.println(">>> Client Timeout 2!");
                    client.stop();
                    return false;
                }
            }
            client.read(img, sizeof(img));

            display.setRotation(1);
            display.firstPage();
            do {
                display.fillScreen(GxEPD_WHITE);
                display.drawInvertedBitmap(0, 0, img, 296, 128, GxEPD_BLACK);
            } while (display.nextPage());
            display.hibernate();

            Serial.println("Screen update done");
        }
    }
    else if (line.indexOf("304") > 0) {
        do {
            line = client.readStringUntil('\r');
            line.trim();
            if (line.indexOf("X-Beep") == 0) beep = atoi(&line.c_str()[line.indexOf(":")+2]);
        } while (client.available() && line != "");
        client.readStringUntil('\n');

        Serial.println("Screen unchanged");
    }
    else {
        Serial.println("Screen update error");
    }

    if (beep) {
        do_beep();
        Serial.println("Beep done");
    }

    Serial.println("Closing connection");
    client.stop();
    return true;
}

/*
bool update_measurements()
{
    if (!airSensor.dataAvailable()) return true;

    Serial.println("");
    Serial.print("Connecting to ");
    Serial.println(host);

    // Use WiFiClient class to create TCP connections
    WiFiClient client;
    if (!client.connect(host, 80)) {
        Serial.println("connection failed");
        return false;
    }

    // We now create a URI for the request
    String url = "/meas.php?src=29";
    url += "&co2=";
    url += (uint16_t)airSensor.getCO2();
    url += "&temp=";
    url += String(airSensor.getTemperature(), 1);
    url += "&hum=";
    url += (uint16_t)airSensor.getHumidity();
    
    Serial.print("Requesting URL: ");
    Serial.println(url);

    // This will send the request to the server
    client.print(String("GET ") + url + " HTTP/1.1\r\n" +
                 "Host: " + host + "\r\n" +
                 "Connection: close\r\n\r\n");
    uint32_t timeout = millis();
    while (client.available() == 0) {
        if (millis() - timeout > 5000) {
            Serial.println(">>> Client Timeout !");
            client.stop();
            return false;
        }
    }

    String line = client.readStringUntil('\r');
    if (line.indexOf("200") > 0) {
        Serial.println("Measurement done");
    } else {
        Serial.println("Measurement error");
    }

    Serial.println("Closing connection");
    client.stop();
    return true;
}
*/

void setup()
{
    Serial.begin(115200);
    display.init(115200);
    pinMode(BUTTON_1, INPUT);
    pinMode(BUTTON_2, INPUT);
    pinMode(BUTTON_3, INPUT);
    dac_output_enable(DAC_CHANNEL_1);
    delay(10);

    Serial.println();
    Serial.println();
    Serial.print("Connecting to SSID ");
    Serial.print(ssid);
    WiFi.begin(ssid, password);

    uint16_t timeout = 0;
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
        timeout++;
        if (timeout > 60) {
            Serial.println("reboot");
            hard_restart();
        }
    }
    Serial.println("");
    Serial.print("WiFi connected, address: ");
    Serial.println(WiFi.localIP());

    if (digitalRead(BUTTON_2) == LOW) {
        Serial.println("Starting OTAWebUpdater");
        OTAWebUpdater();
    }
    
    Serial.println("Starting TinyHA");
    do_beep();

//    Wire.begin();
//    airSensor.begin(Wire, false);
#if 0
    airSensor.StopMeasurement();
    delay(500);
    airSensor.setMeasurementInterval(5);
    delay(500);
    airSensor.setAltitudeCompensation(276);
    delay(500);
    airSensor.setAutoSelfCalibration(true);
    delay(500);
    airSensor.setTemperatureOffset(2.8);
    delay(500);
    airSensor.beginMeasuring();
    do_beep();
#endif
}


void loop()
{
    static uint8_t errors;
    static uint8_t btn;

//    if (!update_measurements()) errors++;
    if (!update_display(btn)) errors++; else errors = 0;

    if (btn) delay(500);

    if (errors > 10) {
        Serial.println("reboot!");
        hard_restart();
    }

    for (uint32_t i = 0; i < UPDATE_INTERVAL/40; i++) {
        delay(40);

        if (digitalRead(BUTTON_1) == LOW) btn = 1;
        else if (digitalRead(BUTTON_2) == LOW) btn = 2;
        else if (digitalRead(BUTTON_3) == LOW) btn = 4;
        else btn = 0;

        if (btn) break;
    }
}
