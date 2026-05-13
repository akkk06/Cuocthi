module w_new ( input [31:0] w16, input [31:0] w15, input [31:0] w7, input [31:0] w2, output [31:0] y );
	wire [31:0] temp1, temp2;
	s1 inst0 ( w2, temp1 );
	s0 inst2 ( w15, temp2 );
	assign y = temp1 + temp2 + w7 + w16;
endmodule