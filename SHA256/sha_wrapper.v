module sha256_axi4lite_slave (
    // Tín hiệu Clock và Reset của hệ thống AXI
    input wire          S_AXI_ACLK,
    input wire          S_AXI_ARESETN, // Reset tích cực mức THẤP (chuẩn AXI)

    // Kênh Write Address (AW)
    input wire [5:0]    S_AXI_AWADDR,
    input wire          S_AXI_AWVALID,
    output wire         S_AXI_AWREADY,

    // Kênh Write Data (W)
    input wire [31:0]   S_AXI_WDATA,
    input wire [3:0]    S_AXI_WSTRB,
    input wire          S_AXI_WVALID,
    output wire         S_AXI_WREADY,

    // Kênh Write Response (B)
    output wire [1:0]   S_AXI_BRESP,
    output wire         S_AXI_BVALID,
    input wire          S_AXI_BREADY,

    // Kênh Read Address (AR)
    input wire [5:0]    S_AXI_ARADDR,
    input wire          S_AXI_ARVALID,
    output wire         S_AXI_ARREADY,

    // Kênh Read Data (R)
    output wire [31:0]  S_AXI_RDATA,
    output wire [1:0]   S_AXI_RRESP,
    output wire         S_AXI_RVALID,
    input wire          S_AXI_RREADY
);

    // Vì core SHA dùng Reset mức cao, nên đảo logic S_AXI_ARESETN là chuẩn xác
    wire sha_reset = ~S_AXI_ARESETN; 
    
    reg  [7:0]   sha_datain;
    reg          sha_lastbyte;
    reg          sha_datavalid; 

    wire         sha_readydata;
    wire         sha_done;
    wire [255:0] sha_final_hash;

    // Khởi tạo khối SHA256 của bạn
    project my_sha256 (
        .clk(S_AXI_ACLK),
        .reset(sha_reset),            
        .datain(sha_datain),      
        .datavalid(sha_datavalid),         
        .lastbyte(sha_lastbyte),       
        .readydata(sha_readydata),    
        .done(sha_done),         
        .final_hash(sha_final_hash) 
    );

    // Các thanh ghi nội bộ cho AXI
    reg axi_awready, axi_wready, axi_bvalid;
    reg axi_arready, axi_rvalid;
    reg [31:0] axi_rdata;

    // Gán đầu ra AXI
    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = 2'b00; // Trạng thái OK
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = 2'b00; // Trạng thái OK
    assign S_AXI_RVALID  = axi_rvalid;

    wire slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
    wire slv_reg_rden = axi_arready && S_AXI_ARVALID && ~axi_rvalid;

    // =======================================================
    // Kênh GHI (WRITE) - NHẬN DATA TỪ CPU VÀ ĐƯA VÀO SHA
    // =======================================================
    always @(posedge S_AXI_ACLK) begin
        if (~S_AXI_ARESETN) begin
            axi_awready <= 1'b0;
            axi_wready  <= 1'b0;
            axi_bvalid  <= 1'b0;
            sha_datavalid <= 1'b0;
            sha_datain <= 8'b0;
            sha_lastbyte <= 1'b0;
        end else begin
            // Bắt tay kênh AW và W
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
                axi_awready <= 1'b1;
                axi_wready  <= 1'b1;
            end else begin
                axi_awready <= 1'b0;
                axi_wready  <= 1'b0;
            end

            // Gửi phản hồi BVALID
            if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
                axi_bvalid <= 1'b1;
            end else if (S_AXI_BREADY && axi_bvalid) begin
                axi_bvalid <= 1'b0;
            end

            // ----------------------------------------------------
            // LOGIC BẮT TAY ĐƯA DATA VÀO KHỐI SHA (Đã được fix)
            // ----------------------------------------------------
            if (slv_reg_wren) begin
                // Nếu CPU ghi vào địa chỉ 0x00 (DATA_REG)
                if (S_AXI_AWADDR[5:2] == 4'h0) begin
                    sha_datain    <= S_AXI_WDATA[7:0]; 
                    sha_lastbyte  <= S_AXI_WDATA[8];   
                    sha_datavalid <= 1'b1; 
                end
            end 
            else begin
                sha_datavalid <= 1'b0;
            end
        end
    end

    // =======================================================
    // Kênh ĐỌC (READ) - TRẢ KẾT QUẢ VỀ CHO CPU
    // =======================================================
    always @(posedge S_AXI_ACLK) begin
        if (~S_AXI_ARESETN) begin
            axi_arready <= 1'b0;
            axi_rvalid  <= 1'b0;
            axi_rdata   <= 32'b0;
        end else begin
            // Bắt tay kênh AR
            if (~axi_arready && S_AXI_ARVALID) begin
                axi_arready <= 1'b1;
            end else begin
                axi_arready <= 1'b0;
            end

            // Đưa dữ liệu ra kênh R
            if (slv_reg_rden) begin
                axi_rvalid <= 1'b1;
                
                // Giải mã địa chỉ để trả về dữ liệu tương ứng
                case (S_AXI_ARADDR[5:2])
                    // Địa chỉ 0x04: Đọc thanh ghi Trạng Thái (STATUS_REG)
                    4'h1: axi_rdata <= {30'b0, sha_done, sha_readydata};
                    
                    // Địa chỉ 0x10 -> 0x2C: Đọc 8 mảng của MÃ BĂM (256-bit)
                    4'h4: axi_rdata <= sha_final_hash[31:0];      // 0x10
                    4'h5: axi_rdata <= sha_final_hash[63:32];     // 0x14
                    4'h6: axi_rdata <= sha_final_hash[95:64];     // 0x18
                    4'h7: axi_rdata <= sha_final_hash[127:96];    // 0x1C
                    4'h8: axi_rdata <= sha_final_hash[159:128];   // 0x20
                    4'h9: axi_rdata <= sha_final_hash[191:160];   // 0x24
                    4'hA: axi_rdata <= sha_final_hash[223:192];   // 0x28
                    4'hB: axi_rdata <= sha_final_hash[255:224];   // 0x2C
                    
                    default: axi_rdata <= 32'b0;
                endcase
            end else if (axi_rvalid && S_AXI_RREADY) begin
                axi_rvalid <= 1'b0;
            end
        end
    end

endmodule