module keypad_top(
    input clk,
    inout [7:0] JA,
	 output [1:0]gnd,  vcc,
    output [3:0] key,
	 
    output [3:0] an
    );

    assign an = 4'b1110;
	 assign gnd = 2'b00;
	 assign vcc = 2'b11;

    // instantiate the keypad circuit
    pmod_keypad keypad(
        .clk(clk), 
        .col(JA[3:0]), 
        .row(JA[7:4]), 
        .key(key)
    );

   

endmodule