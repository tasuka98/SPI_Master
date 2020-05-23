//  Simple SPI interface that reads in a FPGA input and output the signal

// The specification of the core can be found via 
// https://www.analog.com/media/en/analog-dialogue/volume-52/number-3/introduction-to-spi-interface.pdf

// In this module, CS is active low followed by start. Only one slave is present to the SPI module.

module SPIMaster(
    // Control/Data Signal
    input   CLK,     //Source CLK
    input   Start,   //Start signal
    input   Reset,   //Reset signal from FPGA

    // MOSI Signal from device
    input [7:0] T_Data,  //Data that needs to be transfered
    input T_Ready,  //Transmit ready for the next byte

    //Clock Configuration
    input CPOL, //Clock Polarity
    input CPHA, //Clock Phase

    input MISO, //Master In Slave out
    output reg MOSI //Master Out Slave in
    );

    wire SPI_clk;
    wire CS;
    reg [7:0] Transfer_Data;
    reg [7:0] Receive_Data;
    reg [2:0] bit_count;

    //CPOL specifies whether the resting clock is upward or downward
    assign SPI_clk = CLK^CPOL;
    assign CS = Start;


    //Register higher level signal to makesure it is stable
    always@(posedge SPI_clk or negedge SPI_clk) begin

        if (T_Ready) begin
            Transfer_Data <= T_Data;
        end

    end

    //Master transmission for CPHA == 1'b1
    always@(negedge SPI_clk or negedge Reset) begin

        if (~Reset) begin
            bit_count <= 0;
        end

        else if (CPHA == 1'b1) begin

            if (CS == 1'b0) begin
                MOSI <= Transfer_Data[bit_count];
                Receive_Data[bit_count] <= MISO;
                bit_count <= bit_count + 1; 
            end

            else begin
                bit_count   <= 0;
            end

        end

    end

    //Master transmission for CPHA == 1'b0
    always@(posedge SPI_clk or negedge Reset) begin

        if (~Reset) begin
            bit_count   <= 0;
        end

        else if (CPHA == 1'b0) begin

            if (CS == 1'b0) begin
                MOSI <= Transfer_Data[bit_count];
                Receive_Data[bit_count] <= MISO;
                bit_count <= bit_count + 1; 
            end

            else begin
                bit_count <= 0;
            end

        end
    end

endmodule


