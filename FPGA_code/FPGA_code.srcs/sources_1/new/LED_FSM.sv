module LED_FSM(
    input logic [15:0] data_from_FIFO,
    input logic clk,
    input logic empty,
    output logic [15:0] led,
    output logic read_from_fifo
    );

    assign read_from_fifo = !empty;

    logic [8:0] distance;
    assign distance = data_from_FIFO[8:0];

    logic [4:0] num_leds_to_light;

    always_comb begin
        if (distance < 9'd25)       num_leds_to_light = 1;
        else if (distance < 9'd50)  num_leds_to_light = 2;
        else if (distance < 9'd75)  num_leds_to_light = 3;
        else if (distance < 9'd100) num_leds_to_light = 4;
        else if (distance < 9'd125) num_leds_to_light = 5;
        else if (distance < 9'd150) num_leds_to_light = 6;
        else if (distance < 9'd175) num_leds_to_light = 7;
        else if (distance < 9'd200) num_leds_to_light = 8;
        else if (distance < 9'd225) num_leds_to_light = 9;
        else if (distance < 9'd250) num_leds_to_light = 10;
        else if (distance < 9'd275) num_leds_to_light = 11;
        else if (distance < 9'd300) num_leds_to_light = 12;
        else if (distance < 9'd325) num_leds_to_light = 13;
        else if (distance < 9'd350) num_leds_to_light = 14;
        else if (distance < 9'd375) num_leds_to_light = 15;
        else                        num_leds_to_light = 16;
    end

    assign led = (1 << num_leds_to_light) - 1;

endmodule