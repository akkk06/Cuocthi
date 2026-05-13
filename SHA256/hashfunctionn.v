module hashfunctionn (
	input reset,
   input [31:0] w1,
   input [31:0] w2,
   input [31:0] k1,
   input [31:0] k2,
   input clk,
    
   input select,
    
   input [31:0] h0,
   input [31:0] h1,
   input [31:0] h2,
   input [31:0] h3,
   input [31:0] h4,
   input [31:0] h5,
   input [31:0] h6,
   input [31:0] h7,
    
   output [255:0] hashvalue
);
	
	reg [31:0] a, b, c, d, e, f, g, h;
	wire [31:0] a_temp, b_temp, e_temp, f_temp;
	wire [31:0] p1, p2, p3, p4, p5;
	wire [31:0] a_new, b_new, c_new, d_new, e_new, f_new, g_new, h_new;
	
	stage1 inst0 ( w1, k1, w2, k2, a, b, c, d, e, f, g, h, a_temp, b_temp, e_temp, f_temp, p1, p2, p3, p4, p5 );
	
	reg [31:0] a_p, b_p, e_p, f_p, p1_p, p2_p, p3_p, p4_p, p5_p;
	
	always @(posedge clk) begin
		a_p <= a_temp;
		b_p <= b_temp;
		e_p <= e_temp;
		f_p <= f_temp;
		p1_p <= p1;
		p2_p <= p2;
		p3_p <= p3;
		p4_p <= p4;
		p5_p <= p5;
	end
	
	stage2 inst1 ( a_p, b_p, e_p, f_p, p1_p, p2_p, p3_p, p4_p, p5_p, a_new, b_new, c_new, d_new, e_new, f_new, g_new, h_new);
	
	always @(*) begin
		if (reset) begin
			a = h0;
			b = h1;
			c = h2;
			d = h3;
			e = h4;
			f = h5;
			g = h6;
			h = h7;
		end
		else begin
			a = a_new;
			b = b_new;
			c = c_new;
			d = d_new;
			e = e_new;
			f = f_new;
			g = g_new;
			h = h_new;
		end
	end
	
	reg [31:0] h0_out, h1_out, h2_out, h3_out, h4_out, h5_out, h6_out, h7_out;
	always @(posedge clk) begin
		if (select) begin
			h0_out <= h0 + a;
			h1_out <= h1 + b;
			h2_out <= h2 + c;
			h3_out <= h3 + d;
			h4_out <= h4 + e;
			h5_out <= h5 + f;
			h6_out <= h6 + g;
			h7_out <= h7 + h;
		end
		else begin
			h0_out <= h0_out;
			h1_out <= h1_out;
			h2_out <= h2_out;
			h3_out <= h3_out;
			h4_out <= h4_out;
			h5_out <= h5_out;
			h6_out <= h6_out;
			h7_out <= h7_out;
		end
	end
	
	assign hashvalue = {h0_out, h1_out, h2_out, h3_out, h4_out, h5_out, h6_out, h7_out};
endmodule
	
	
	
	
	


