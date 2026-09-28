RS-232 TX Serial transmitter (VHDL, DE2 board)

A UART-style serial transmitter built as a state machine, designed to pair with the matching receiver. It sends data on EX_IO0. Each message has a start bit, a 2-bit type ID, a variable number of data bits (set with SW11–10), and a stop bit. The baud rate is selected with SW16–14.

SW17 selects the mode:

Normal mode: the value on SW7–0 is sent with type ID 00 when KEY0 is pressed.
Clock mode: a built-in clock shown on HEX0–5 is sent continuously. The seconds, minutes and hours are sent in turn as BCD, with type IDs 01, 10 and 11.

The LEDs show the data being sent. KEY3 resets the design through a reset synchronizer.
