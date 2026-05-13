module coree ( input [0:511] message, input clk, input reset, input init_hash, output reg ready, output [255:0] result);
	 wire [31:0] k[0:63];
    assign k[00] = 32'h428a2f98;
    assign k[01] = 32'h71374491;
    assign k[02] = 32'hb5c0fbcf;
    assign k[03] = 32'he9b5dba5;
    assign k[04] = 32'h3956c25b;
    assign k[05] = 32'h59f111f1;
    assign k[06] = 32'h923f82a4;
    assign k[07] = 32'hab1c5ed5;
    assign k[08] = 32'hd807aa98;
    assign k[09] = 32'h12835b01;
    assign k[10] = 32'h243185be;
    assign k[11] = 32'h550c7dc3;
    assign k[12] = 32'h72be5d74;
    assign k[13] = 32'h80deb1fe;
    assign k[14] = 32'h9bdc06a7;
    assign k[15] = 32'hc19bf174;
    assign k[16] = 32'he49b69c1;
    assign k[17] = 32'hefbe4786;
    assign k[18] = 32'h0fc19dc6;
    assign k[19] = 32'h240ca1cc;
    assign k[20] = 32'h2de92c6f;
    assign k[21] = 32'h4a7484aa;
    assign k[22] = 32'h5cb0a9dc;
    assign k[23] = 32'h76f988da;
    assign k[24] = 32'h983e5152;
    assign k[25] = 32'ha831c66d;
    assign k[26] = 32'hb00327c8;
    assign k[27] = 32'hbf597fc7;
    assign k[28] = 32'hc6e00bf3;
    assign k[29] = 32'hd5a79147;
    assign k[30] = 32'h06ca6351;
    assign k[31] = 32'h14292967;
    assign k[32] = 32'h27b70a85;
    assign k[33] = 32'h2e1b2138;
    assign k[34] = 32'h4d2c6dfc;
    assign k[35] = 32'h53380d13;
    assign k[36] = 32'h650a7354;
    assign k[37] = 32'h766a0abb;
    assign k[38] = 32'h81c2c92e;
    assign k[39] = 32'h92722c85;
    assign k[40] = 32'ha2bfe8a1;
    assign k[41] = 32'ha81a664b;
    assign k[42] = 32'hc24b8b70;
    assign k[43] = 32'hc76c51a3;
    assign k[44] = 32'hd192e819;
    assign k[45] = 32'hd6990624;
    assign k[46] = 32'hf40e3585;
    assign k[47] = 32'h106aa070;
    assign k[48] = 32'h19a4c116;
    assign k[49] = 32'h1e376c08;
    assign k[50] = 32'h2748774c;
    assign k[51] = 32'h34b0bcb5;
    assign k[52] = 32'h391c0cb3;
    assign k[53] = 32'h4ed8aa4a;
    assign k[54] = 32'h5b9cca4f;
    assign k[55] = 32'h682e6ff3;
    assign k[56] = 32'h748f82ee;
    assign k[57] = 32'h78a5636f;
    assign k[58] = 32'h84c87814;
    assign k[59] = 32'h8cc70208;
    assign k[60] = 32'h90befffa;
    assign k[61] = 32'ha4506ceb;
    assign k[62] = 32'hbef9a3f7;
    assign k[63] = 32'hc67178f2;

    reg [31:0] h0, h1, h2, h3, h4, h5, h6, h7;
reg ready_prev;

    // Thêm always block này để bắt trạng thái trễ 1 nhịp của ready
    always @(posedge clk) begin
        if (reset) ready_prev <= 1'b0;
        else       ready_prev <= ready;
    end

    // Sửa lại khối gán h0...h7
    always @(posedge clk) begin
        if (init_hash) begin
            h0 <= 32'h6a09e667;
            h1 <= 32'hbb67ae85;
            h2 <= 32'h3c6ef372;
            h3 <= 32'ha54ff53a;
            h4 <= 32'h510e527f;
            h5 <= 32'h9b05688c;
            h6 <= 32'h1f83d9ab;
            h7 <= 32'h5be0cd19;
        end 
        // Thay "else if (ready)" thành dòng bên dưới:
        else if (ready && !ready_prev) begin 
            h0 <= current_hash[255:224];     // THAY CHỮ result THÀNH current_hash
            h1 <= current_hash[223:192];
            h2 <= current_hash[191:160];
            h3 <= current_hash[159:128];
            h4 <= current_hash[127:96];
            h5 <= current_hash[95:64];
            h6 <= current_hash[63:32];
            h7 <= current_hash[31:0];
        end
    end
	 
	 reg [31:0] w [0:63];
	 wire [31:0] temp1, temp2;
	 reg [6:0] cnt_1, cnt16_1, cnt15_1, cnt7_1, cnt2_1;
	 reg [6:0] cnt_2, cnt16_2, cnt15_2, cnt7_2, cnt2_2;
	 reg done;
	 
	 w_new instt( w[cnt16_1], w[cnt15_1], w[cnt7_1], w[cnt2_1], temp1 );
	 w_new insttt( w[cnt16_2], w[cnt15_2], w[cnt7_2], w[cnt2_2], temp2 );
	 
	 reg [31:0] w_new1, w_new2;
	 always @(*) begin
		if (done) begin
			w_new1 = w[62];
			w_new2 = w[63];
		end
		else begin
			w_new1 = temp1;
			w_new2 = temp2;
		end
	 end
	 
	 integer i;
	 always @(posedge clk) begin
		if (reset) begin
			cnt_1 <= 7'd16;
			cnt16_1 <= 7'd0;
			cnt15_1 <= 7'd1;
			cnt7_1 <= 7'd9;
			cnt2_1 <= 7'd14;
			cnt_2 <= 7'd17;
			cnt16_2 <= 7'd1;
			cnt15_2 <= 7'd2;
			cnt7_2 <= 7'd10;
			cnt2_2 <= 7'd15;
			done <= 1'b0;
			
         for(i = 0; i < 16; i=i+1) begin
                w[i] <= message[32*i +: 32];
         end
         for(i = 16; i < 64; i=i+1) begin
                w[i] <= 32'b0;
			end
		end
		
		else begin
			cnt16_1 <= cnt16_1 + 2;
			cnt15_1 <= cnt15_1 + 2; 
			cnt7_1 <= cnt7_1 + 2;
			cnt2_1 <= cnt2_1 + 2;
			cnt16_2 <= cnt16_2 + 2;
			cnt15_2 <= cnt15_2 + 2;
			cnt7_2 <= cnt7_2 + 2;
			cnt2_2 <= cnt2_2 + 2;

			w[cnt_1] <= w_new1;
			w[cnt_2] <= w_new2;

			if ( cnt_1 == 7'd62 ) begin
				cnt_1 <= cnt_1;
				cnt_2 <= cnt_2;
				done <= 1'b1;
			end
			else begin
				cnt_1 <= cnt_1 + 2;
				cnt_2 <= cnt_2 + 2;
				done <= 1'b0;
			end		
		end
	 end
	 
	 reg [6:0] count_hash1, count_hash2;
    reg reset_hash;
    always @(posedge clk) reset_hash <= reset;
    
    reg ready_dash;
    always @(posedge clk) begin
        if(reset_hash) begin
            count_hash1   <= 7'd0;
            count_hash2   <= 7'd1;
            ready_dash   <= 1'b0;
            //ready   <= 1'b0;
        end
        else begin
            if(count_hash1 == 7'd62) begin 
                count_hash1 <= count_hash1; 
                count_hash2 <= count_hash2;
                ready_dash <= 1'b1;
                //ready <= 1'b1;
            end
            else begin 
                count_hash1 <= count_hash1 + 2;
                count_hash2 <= count_hash2 + 2;
                ready_dash <= 1'b0;
                //ready <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (reset || reset_hash) begin
            ready <= 1'b0;
        end 
        else begin
            ready <= ready_dash;
        end
    end

    wire select;
    assign select = ~ready;
	 
	 reg [31:0] w1, w2, k1, k2;
	 
	 always @(posedge clk) begin
		if (reset_hash) begin
			w1 <= w[0];
			w2 <= w[1];
			k1 <= k[0];
			k2 <= k[1];
		end
		else begin
			if (count_hash1 <= 7'd60) begin
				w1 <= w[count_hash1+2];
				w2 <= w[count_hash2+2];
				k1 <= k[count_hash1+2];
				k2 <= k[count_hash2+2];
			end
			else begin
				w1 <= 32'b0;
            w2 <= 32'b0;
            k1 <= 32'b0;
            k2 <= 32'b0;
			end
		end
	 end
	 
	 reg reset_hash_dash;
    always @(posedge clk) reset_hash_dash <= reset_hash;
	 wire [255:0] current_hash;
	 hashfunctionn inst0 ( reset_hash_dash, w1, w2, k1, k2, clk, select, h0, h1, h2, h3, h4, h5, h6, h7, current_hash );
	 assign result = {h0, h1, h2, h3, h4, h5, h6, h7};
endmodule
