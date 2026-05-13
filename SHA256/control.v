module control ( input clk, 
					  input reset, 
					  input [7:0] datain, 
					  input datavalid, 
					  input lastbyte, 
					  input core_ready, 
					  output reg readydata, 
					  output wire [0:511] block, 
					  output reg core_reset,
					  output reg done );

	localparam IDLE      = 3'd0,
				  RCV_DATA  = 3'd1,
              PAD_80    = 3'd2,
              PAD_00    = 3'd3,
              PAD_LEN   = 3'd4,
              WAIT_CORE = 3'd5,
              FINISH    = 3'd6,
		        LOAD_CORE = 3'd7;
	reg [2:0] state, next_state, return_state;
	reg [63:0] totalbit;
	reg [5:0]  bytecnt;
	reg [0:511] buffer;
	assign block = buffer;
	

	
always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            return_state <= IDLE;
        end else begin
            state <= next_state;
            
            if (state == RCV_DATA && datavalid && bytecnt == 6'd63) begin
                if (lastbyte) return_state <= PAD_80;
                else return_state <= RCV_DATA;
            end 
            else if (state == PAD_80 && bytecnt == 6'd63) return_state <= PAD_00;
            else if (state == PAD_00 && bytecnt == 6'd63) return_state <= PAD_00;
            else if (state == PAD_LEN && bytecnt == 6'd63) return_state <= FINISH;
        end
    end

    // 2. Kh?i chuy?n tr?ng th�i ti?p theo (Combinational Logic)
    always @(*) begin
        next_state = state;
        readydata = 1'b0;
        done = 1'b0;

        case (state)
            IDLE:  begin
                readydata = 1'b1;
                if (datavalid) next_state = RCV_DATA;
            end
            RCV_DATA: begin
                readydata = 1'b1;
                if (datavalid) begin
                    if (bytecnt == 6'd63) next_state = LOAD_CORE;
                    else if (lastbyte)    next_state = PAD_80;
                end
                else begin
                    next_state = RCV_DATA; 
                end
            end
            PAD_80:    if (bytecnt == 6'd63) next_state = LOAD_CORE; else next_state = PAD_00;
            PAD_00: begin 
                if (bytecnt == 6'd63)      next_state = LOAD_CORE;
                else if (bytecnt == 6'd55) next_state = PAD_LEN;
            end
            PAD_LEN:   if (bytecnt == 6'd63) next_state = LOAD_CORE;
            LOAD_CORE: next_state = WAIT_CORE;
            WAIT_CORE: if (core_ready) begin
                if (bytecnt > 6'd2 && core_ready == 1'b1) next_state = return_state;
                else next_state = WAIT_CORE;
            end
            FINISH:  begin
                done = 1'b1;
                readydata = 1'b1;
                if (datavalid) next_state = RCV_DATA;
                else next_state = FINISH;
            end
            default:   next_state = IDLE;
        endcase
    end

    // 3. Kh?i t?o t�n hi?u core_reset ??ng b?
    always @(posedge clk or posedge reset) begin
        if (reset) core_reset <= 1'b1;
        else begin
            if (next_state == WAIT_CORE) core_reset <= 1'b0;
            else                         core_reset <= 1'b1;
        end
    end
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            totalbit <= 64'd0;
            bytecnt <= 6'd0;
            buffer <= 512'b0;
            //block <= 512'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (datavalid) begin
                        buffer[bytecnt*8 +: 8] <= datain;
                        totalbit <= totalbit + 8;
                        bytecnt <= bytecnt + 1;
                    end
                end

                RCV_DATA: begin
                    if (datavalid) begin
                        buffer[bytecnt*8 +: 8] <= datain;
                        totalbit <= totalbit + 8;
                        bytecnt <= bytecnt + 1;
                    end
                end

                PAD_80: begin
                    buffer[bytecnt*8 +: 8] <= 8'h80;
                    bytecnt <= bytecnt + 1;
                end

                PAD_00: begin
                    buffer[bytecnt*8 +: 8] <= 8'h00;
                    bytecnt <= bytecnt + 1;
                end

                PAD_LEN: begin
                    buffer[bytecnt*8 +: 8] <= totalbit[ (7 - (bytecnt - 56))*8 +: 8 ];
                    bytecnt <= bytecnt + 1;
                end

                WAIT_CORE: begin
                    //block <= buffer; 
                    if (core_ready == 1'b1 && bytecnt > 6'd2) begin
                        bytecnt <= 6'd0; 
                       // buffer <= 512'b0; 
                    end
                    else begin
                        bytecnt <= bytecnt + 1; // Đếm số nhịp clock đã trôi qua
                    end
                end
                FINISH: begin
                    if (datavalid) begin
                        buffer[0 +: 8] <= datain;
                        totalbit <= 64'd8; // Khởi tạo lại độ dài = 8 bit
                        bytecnt <= 6'd1;   // Đã nhận 1 byte
                    end else begin
                        totalbit <= 64'd0; // Reset sạch sẽ chờ chuỗi mới
                        bytecnt <= 6'd0;
                    end
                end
            endcase
        end
    end
	
endmodule
