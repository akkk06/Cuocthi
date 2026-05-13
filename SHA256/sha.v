module project (
    input clk,
    input reset,            
    input [7:0] datain,      
    input datavalid,         
    input lastbyte,       
    output readydata,    
    
    output  done,         
    output  [255:0] final_hash 
);


    wire [511:0] wire_block;
    wire wire_core_reset;
    wire wire_core_ready;

    control inst0(
        .clk(clk),
        .reset(reset),    
        .datain(datain),
        .datavalid(datavalid),
        .lastbyte(lastbyte),
        .readydata(readydata),
        .block(wire_block),
        .core_reset(wire_core_reset),
        .core_ready(wire_core_ready),
        .done(done)
    );

    coree inst1(
        .clk(clk),
        .message(wire_block), 
        .reset(wire_core_reset),  
        .init_hash(reset),        
        .ready(wire_core_ready),   
        .result(final_hash)       
    );

endmodule