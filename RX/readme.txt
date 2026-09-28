RS-232 RX Serial receiver (VHDL, DE2 board)

A UART-style serial receiver built as a state machine. It receives data on EX_IO6 and shows it on the seven-segment displays. After the start bit, each message contains a 2-bit type ID, a variable number of data bits (set with SW11–10), and a stop bit. The baud rate is selected with SW16–14, and each bit is sampled in the middle of its bit period.

SW17 selects the mode:

Normal mode (type ID 00): the received byte is shown as data.
Clock mode: the type ID decides whether the byte is stored as seconds (01), minutes (10) or hours (11) in BCD.

LEDR2 lights when a message is received correctly. LEDR0 lights on an error, such as an invalid start or stop bit. KEY3 resets the design through a reset synchronizer.
