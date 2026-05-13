module stage1 ( 
	input wire [31:0] w1,
   input wire [31:0] k1,
   input wire [31:0] w2,
   input wire [31:0] k2,
    
   input wire [31:0] a,
   input wire [31:0] b,
   input wire [31:0] c,
   input wire [31:0] d,
   input wire [31:0] e,
   input wire [31:0] f,
   input wire [31:0] g,
   input wire [31:0] h,
    
   output wire [31:0] a_temp,
   output wire [31:0] b_temp,
   output wire [31:0] e_temp,
   output wire [31:0] f_temp,
    
   output wire [31:0] p1,
   output wire [31:0] p2,
   output wire [31:0] p3,
   output wire [31:0] p4,
   output wire [31:0] p5
);
	assign a_temp = a;
	assign b_temp = b;
	assign e_temp = e;
	assign f_temp = f;
	
	wire [31:0] temp1, temp2, temp3, temp4;
	t0 inst0 ( a, temp1 );
	t1 inst1 ( e, temp2 );
	maj inst2 ( a, b, c, temp3);
	ch inst3 ( e, f, g, temp4);
	
	assign p1 = temp1 + temp3;
	assign p2 = temp2 + temp4 + h + d + w1 + k1;
	assign p3 = temp2 + temp4 + h + w1 + k1;
	assign p4 = g + w2 + k2;
	assign p5 = g + c + w2 + k2;
	
endmodule