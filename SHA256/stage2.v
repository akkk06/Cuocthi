module stage2 (
	input wire [31:0] a_temp,
   input wire [31:0] b_temp,
   input wire [31:0] e_temp,
   input wire [31:0] f_temp,
    
   input wire [31:0] p1,
   input wire [31:0] p2,
   input wire [31:0] p3,
   input wire [31:0] p4,
   input wire [31:0] p5,
    
   output wire [31:0] a_new,
   output wire [31:0] b_new,
   output wire [31:0] c_new,
   output wire [31:0] d_new,
   output wire [31:0] e_new,
   output wire [31:0] f_new,
   output wire [31:0] g_new,
   output wire [31:0] h_new
);
	
	wire [31:0] temp1, temp2, temp3, temp4, temp5;
	assign temp1 = p1 + p3;
	
	t0 inst0 ( temp1, temp2);
	t1 inst1 ( p2, temp3);
	maj inst2 ( a_temp, b_temp, temp1, temp4);
	ch inst3 ( p2, e_temp, f_temp, temp5);
	
	assign a_new = temp2 + temp3 + p4 + temp4 + temp5;
	assign b_new = temp1;
	assign c_new = a_temp;
	assign d_new = b_temp;
	assign e_new = temp3 + temp5 + p5;
	assign f_new = p2;
	assign g_new = e_temp;
	assign h_new = f_temp;

endmodule