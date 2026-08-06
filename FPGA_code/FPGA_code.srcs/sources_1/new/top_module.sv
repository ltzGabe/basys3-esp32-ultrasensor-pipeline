module top(
    input logic clk,
    input logic rx,
    input logic BTNC,
    output logic [15:0] led
    );
    logic dataValid;
    logic write_to_fifo;
    logic [7:0] data_write_to_FIFO;
    logic read_from_fifo;
    logic [7:0] data_from_FIFO;
    logic FIFO_full, FIFO_almost_full;
    logic FIFO_empty, FIFO_almost_empty;
    UART_RX uart_rx_inst (
        .clk(clk),
        .rx(rx),
        .BTNC(BTNC),
        .dataValid(dataValid),
        .write_to_fifo(write_to_fifo),
        .data_write_to_FIFO(data_write_to_FIFO)
    );
    FIFO fifo_inst (
        .wr_clk(clk),
        .wr_rst(BTNC),
        .wr_en(write_to_fifo),
        .wr_data(data_write_to_FIFO),
        .full(FIFO_full),
        .almost_full(FIFO_almost_full),
        .rd_clk(clk),
        .rd_rst(BTNC),
        .rd_en(read_from_fifo),
        .rd_data(data_from_FIFO),
        .empty(FIFO_empty),
        .almost_empty(FIFO_almost_empty)
    );
    LED_FSM led_fsm_inst (
        .data_from_FIFO(data_from_FIFO),
        .read_from_fifo(read_from_fifo),
        .clk(clk),
        .empty(FIFO_empty),
        .led(led)
    );
endmodule