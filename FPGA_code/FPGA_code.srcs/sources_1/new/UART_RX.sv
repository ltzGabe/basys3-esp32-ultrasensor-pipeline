`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.08.2026 19:11:17
// Design Name: 
// Module Name: UART_RX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
   `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.08.2026 19:11:17
// Design Name: 
// Module Name: UART_RX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
    module UART_RX(
        input clk,
        input rx,
        input BTNC,
        output logic dataValid,
        output logic write_to_fifo,
        output logic [15:0] data_write_to_FIFO
        );
    
    
    localparam IDLE = 2'b00;
    localparam READ = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    
    logic [2:0] STATE;
    logic [4:0] bitcounter;
    logic dataToggle;
    
    logic reset;
    assign reset = BTNC;
    
    logic [7:0] data;
    
    localparam baudRate = 100_000_000 / 115200;
    localparam width =  $clog2(baudRate); 
    logic [width-1:0] baudCounter;
    
    logic sync;
    logic rx_synced;
    
    always_ff @(posedge clk) begin
        sync      <= rx;
        rx_synced <= sync;
    end
    
    always_ff @(posedge clk) begin
            if (reset) begin
                baudCounter <= 0;
                bitcounter  <= 0;
                dataValid   <= 0;
                STATE       <= IDLE;
                write_to_fifo  <= 0;
                dataToggle <= 0; 
         
            end else begin
                case (STATE)
                    IDLE: begin
                        dataValid   <= 0;
                        baudCounter <= 0;     
                        write_to_fifo  <= 0;
                        bitcounter <= 0;
                
                        if (!rx_synced) begin       
                            STATE <= READ;
                        end
                    end
        
                    READ: begin
                        if (baudCounter == baudRate) begin
                            baudCounter <= 0;
                            if (bitcounter == 4'd8) begin                   
                                bitcounter <= 0;
                                STATE <= DATA;
                            end
                            else begin
                                data[bitcounter] <= rx;
                                bitcounter <= bitcounter + 1;
     
                            end
                        end
                        else 
                            baudCounter <= baudCounter + 1;
                        
                    end
        
                    DATA: begin                        
                        STATE <= STOP;
                    end
        
                    STOP: begin
                        if (baudCounter == baudRate) begin
                            baudCounter <= 0;
                            if(dataToggle) begin
                                data_write_to_FIFO[15:8] <= data;
                                write_to_fifo <= 1;
                                dataToggle  <= 0;  
                                if (rx_synced) begin
                                    STATE <= IDLE;
                                    dataValid <= 1;      
                                end
                            end
                            else begin 
                                data_write_to_FIFO[7:0]<= data;
                                dataToggle <= dataToggle +1; 
                                if (rx_synced) begin
                                    STATE <= IDLE;
                                end
                            end
                        end else begin
                            baudCounter <= baudCounter + 1;
                        end
                    end
                endcase
            end
        end
    endmodule