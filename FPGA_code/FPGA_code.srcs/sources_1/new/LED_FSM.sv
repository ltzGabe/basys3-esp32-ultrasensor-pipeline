module LED_FSM(
    input logic [7:0] data_from_FIFO,
    input logic clk,
    input logic empty,
    output logic [15:0] led,
    output logic read_from_fifo
    );
    assign read_from_fifo = !empty;
    logic [6:0] distance;
    assign distance = data_from_FIFO[6:0];
    logic [4:0] num_leds_to_light;
    always_comb begin
        if (distance < 7'd8)        num_leds_to_light = 1;
        else if (distance < 7'd16)  num_leds_to_light = 2;
        else if (distance < 7'd24)  num_leds_to_light = 3;
        else if (distance < 7'd32)  num_leds_to_light = 4;
        else if (distance < 7'd40)  num_leds_to_light = 5;
        else if (distance < 7'd48)  num_leds_to_light = 6;
        else if (distance < 7'd56)  num_leds_to_light = 7;
        else if (distance < 7'd64)  num_leds_to_light = 8;
        else if (distance < 7'd72)  num_leds_to_light = 9;
        else if (distance < 7'd80)  num_leds_to_light = 10;
        else if (distance < 7'd88)  num_leds_to_light = 11;
        else if (distance < 7'd96)  num_leds_to_light = 12;
        else if (distance < 7'd104) num_leds_to_light = 13;
        else if (distance < 7'd112) num_leds_to_light = 14;
        else if (distance < 7'd120) num_leds_to_light = 15;
        else                        num_leds_to_light = 16;
    end
    assign led = (1 << num_leds_to_light) - 1;
endmodule