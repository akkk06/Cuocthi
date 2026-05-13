module s0(input [31:0] x, output [31:0] y);
	assign y = ({x[6:0],x[31:7]} ^ {x[17:0],x[31:18]} ^ x >> 3);
endmodule
