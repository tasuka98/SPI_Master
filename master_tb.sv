`timescale 1ns/1ns

module MasterTestbench();

    logic systemclock = 0;
    logic Start = 1;
    logic Reset = 1; 
    logic CPOL = 0;
    logic CPHA = 0;
    logic Input_Rdy = 0;
    logic [7:0] Input = 0;
    logic [7:0] Output = 0;
    logic [7:0] Result = 0;
    logic [7:0] Testvector_MOSI [49:0];
    logic [7:0] Testvector_MISO [49:0];
    logic [5:0] count = 0;
    logic [3:0] index = 0;
    logic DUT_Out;
    logic DUT_In;

    //Generate system clock.
    always #20 systemclock = !systemclock;

    initial begin
        $readmemb("MOSI_test.txt",Testvector_MOSI);
        $readmemb("MISO_test.txt",Testvector_MISO);
    end

    SPIMaster DUT
    (
        .CLK(systemclock), 
        .Start(Start),
        .Reset(Reset),
        .T_Data(Input),
        .T_Ready(Input_Rdy),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .MISO(DUT_In),
        .MOSI(DUT_Out)
    );

    initial begin

        for (count = 0; count < 50; count++) begin
        Input_Rdy = 1;
        Result = Testvector_MISO[count];
        Input = Testvector_MOSI[count];
        #40 Input_Rdy = 0;
        #100 Reset = 0;
        #15 Reset = 1;
        Start = 0;

        repeat(8) @(posedge DUT.SPI_clk) begin
            #1;
            Output[index] = DUT_Out;
            DUT_In = Input[index];
            index = index + 1;
        end
        
        Start = !Start;
        index = 0;

        if (Output !== Input) $display("MISO: Correct Value = %h, Delivered value = %h", Input, Output); 
        else $display("Test Case %d passed!", count);
        
        end

        $stop;
    end

    

endmodule 