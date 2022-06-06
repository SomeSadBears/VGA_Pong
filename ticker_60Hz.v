`timescale 1ns / 1ps

/***************************************************************************
 * File Name: ticker.v
 * Project: Project 01
 * Designer: Juan Saavedra
 * Email: juan.saavedra01@student.csulb.edu
 * Rev. Date: February 4th
 *
 * Purpose: Uses the board's 100Mhz clock to generate a ticker with a 25Mhz
 * frequency. The module implements a counter which increases at every positive
 * edge of the clock. 
 *
 *      f = 100Mhz, T = 10ns
 *      100Mhz / 60Hz = 1,666,666
 * 
 * Notes:  
***************************************************************************/

module ticker_60Hz(
    input   clk     , 
            rst     , 
    output  ref_tick
    );
    
    reg [24:0] count, ncount;
    
    assign ref_tick = (count == 25'd1_666_666);
    
    always @ (posedge clk, posedge rst)
        if  (rst) 
            count <= 25'b0;
        else
            count <= ncount;
    
    always @ (*)
        if (ref_tick) 
            ncount = 25'b0;
        else
            ncount = count + 25'b1;
    
endmodule