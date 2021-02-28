#include <GxEPD2_BW.h>
#include <WiFi.h>
#include <esp_int_wdt.h>
#include <esp_task_wdt.h>
#include <rom/ets_sys.h>
#include "paulvha_SCD30.h"

// SPI: /*CS=*/ SS=5, /*DIN=*/ MOSI=23, MISO=19, /*CLK=*/ SCK=18
GxEPD2_BW<GxEPD2_750, GxEPD2_750::HEIGHT> display(GxEPD2_750(/*CS=*/ 5, /*DC=*/ 15, /*RST=*/ 16, /*BUSY=*/ 4));

// Wire: SDA=21, SCL=22
SCD30 airSensor;

extern void OTAWebUpdaterInit(void);
extern void OTAWebUpdaterRun(void);

const char *ssid     = WIFI_SSID;
const char *password = WIFI_PASSWORD;
const char *host     = "tinyha.lan";

#define UPDATE_INTERVAL 10000


void hard_restart()
{
    esp_task_wdt_init(1, true);
    esp_task_wdt_add(NULL);
    while (true) {}
}


bool update_display(void)
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
    String url = "/screen75.php";

    if (restart) {
        url += "?reset=1";
        restart = false;
    }

    Serial.print("Requesting URL: ");
    Serial.println(url);

    // This will send the request to the server
    client.print(String("GET ") + url + " HTTP/1.1\r\n" +
                 "Host: " + host + "\r\n" +
                 "Connection: close\r\n\r\n");
    uint32_t timeout = millis();
    while (client.available() == 0) {
        if (millis() - timeout > 10000) {
            Serial.println(">>> Client Timeout 1!");
            client.stop();
            return false;
        }
    }

    String line = client.readStringUntil('\r');
    uint8_t beep = 0;
    if (line.indexOf("200") > 0) {
        bool chunked = false;
        do {
            line = client.readStringUntil('\r');
            line.trim();
            if (line.indexOf("chunked") > 0) chunked = true;
        } while (client.available() && line != "");
        line = client.readStringUntil('\n');

        if (chunked) {
            line = client.readStringUntil('\n');
            Serial.print("Chunked header: ");
            Serial.println(line);
        }

        line = client.readStringUntil('\n');
        Serial.print("Image header: ");
        Serial.println(line);

        if (line.indexOf("P4 640 384") == 0) {
            static uint8_t img[640 * 384 / 8];
            const uint32_t page_size = 4096;
            uint32_t timeout = millis();
            uint32_t idx = 0;

            do {
                uint32_t remaining = sizeof(img) - idx;
                int32_t ret = client.read(&img[idx], (remaining > page_size) ? page_size : remaining);
                
                if (ret < 0) delay(10); // wait for more data
                else idx += ret; // advance index
                
                if (millis() - timeout > 5000) {
                    Serial.println(">>> Client Timeout 2!");
                    client.stop();
                    return false;
                }
            } while (idx < sizeof(img));

            display.setRotation(0);
            display.firstPage();
            do {
                display.fillScreen(GxEPD_WHITE);
                display.drawInvertedBitmap(0, 0, img, 640, 384, GxEPD_BLACK);
            } while (display.nextPage());
            display.hibernate();

            Serial.println("Screen update done");
        }
    }
    else if (line.indexOf("304") > 0) {
        do {
            line = client.readStringUntil('\r');
            line.trim();
        } while (client.available() && line != "");
        client.readStringUntil('\n');

        Serial.println("Screen unchanged");
    }
    else {
        Serial.println("Screen update error");
    }

    Serial.println("Closing connection");
    client.stop();
    return true;
}


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
    String url = "/meas.php?src=75";
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


void setup()
{
    Serial.begin(115200);
    display.init(115200);
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

    Serial.println("Starting OTAWebUpdater");
    OTAWebUpdaterInit();
    
    Serial.println("Starting TinyHA");
    Wire.begin();
    airSensor.begin(Wire, false);
#if 0
    airSensor.StopMeasurement();
    delay(500);
//    airSensor.setMeasurementInterval(5);
//    delay(500);
//    airSensor.setAltitudeCompensation(276);
//    delay(500);
//    airSensor.setAutoSelfCalibration(true);
//    delay(500);
    airSensor.setTemperatureOffset(1.9);
    delay(500);
    airSensor.beginMeasuring();
#endif
}


void loop()
{
    static uint8_t errors;
    static uint8_t btn;

    if (!update_measurements()) errors++;
    if (!update_display()) errors++; else errors = 0;

    if (errors > 10) {
        Serial.println("reboot!");
        hard_restart();
    }

    for (uint16_t i = 0; i < UPDATE_INTERVAL; i++) {
        OTAWebUpdaterRun();
        delay(1);
    }
}
