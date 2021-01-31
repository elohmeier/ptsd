<h1>AVR In-System Programming over WiFi for ESP8266</h1>

This library allows an ESP8266 module with the HSPI port available to become an AVR In-System Programmer.

Hardware
The ESP8266 module connects to the AVR target chip via the GPIO Pins of the Desmos D1 Mini.

If the AVR target is powered by a different Vcc than what powers your ESP8266 chip, you must provide voltage level shifting or some other form of buffers.

Connections are as follows for ISP:

<table>
<tr><th>Desmos D1 Mini</th><th>SPI</th></tr>
<tr><th>D7</th><th>MISO</th></tr>
<tr><th>D6</th><th>MOSI</th></tr>
<tr><th>D5</th><th>SCK</th></tr>
<tr><th>D4</th><th>RESET</th></tr>
<tr><th>GND</th><th>GND</th></tr>
<tr><th>3V3</th><th>VCC</th></tr>
</table>

Connections are as follows for OLED

<table>
<tr><th>Desmos D1 Mini</th><th>OLED</th></tr>
<tr><th>D2</th><th>SDA</th></tr>
<tr><th>D1</th><th>SCL</th></tr>
<tr><th>5V</th><th>VCC</th></tr>
<tr><th>GND</th><th>GND</th></tr>
</table>

Usage:<br>
The ISP sketch will try to connect to the defined Accesspoints (multiple accesspoints can be defined, with passwords, in the sketch)
Once connected, it will show the connect AP name, and IP/Port

Once connect, use avrdude (Sorry, linux only, as Windows doesnt support net)<br>
avrdude -b 230400 -c arduino -p <i>(device)</i> -P net:<i>(IP:PORT) (commands)</i>

Example:<br>
avrdude -b 230400 -c arduino -p t85 -P net:192.168.8.140:328 -U flash:w:t85_Default.hex
