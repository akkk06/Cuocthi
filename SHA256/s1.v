module s1(input [31:0] x, output [31:0] y);
	assign y = ({x[16:0],x[31:17]} ^ {x[18:0],x[31:19]} ^ x >> 10);
endmodule