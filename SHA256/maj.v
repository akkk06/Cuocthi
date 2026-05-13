module maj(input [31:0] a, input [31:0] b, input [31:0] c, output [31:0] y);
	assign y = ( a & b ) ^ ( a & c ) ^ ( b & c );
endmodule