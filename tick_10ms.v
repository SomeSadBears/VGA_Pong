`timescale 1ns / 1ps

/***************************************************************************
 * File Name: ticker.v
 * Project: Project 01
 * Designer: Juan Saavedra
 * Email: juan.saavedra01@student.csulb.edu
 * Rev. Date: February 4th
 *
 * Purpose: Uses the board's 100Mhz clock to generate a pulse (tick) every
 * 10ms. The 100Mhz clock cycles 1x10^6 times every 10ms (calculation shown
 * below). The module implements a counter which increases at every positive
 * edge of the clock. Once the counter reaches 1x10^6 the module outputs a
 * "tick" and the counter resets to zero.
 *
 *      f = 100Mhz, T = 10ns
 *      10ms / 10ns = 1M 
 * 
 * Notes:  
***************************************************************************/

module tick_10ms(
    input   clk     , 
            rst     , 
    output  tick
    );
    
    reg [19:0] count, ncount;
    
    assign tick = (count == 20'd999_999);
    
    always @ (posedge clk, posedge rst)
        if  (rst) 
            count <= 20'b0;
        else
            count <= ncount;
    
    always @ (*)
        if (tick) 
            ncount = 20'b0;
        else
            ncount = count + 20'b1;
    
endmodule