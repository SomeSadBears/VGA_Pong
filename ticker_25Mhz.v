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
 *      100Mhz / 25Mhz = 4
 * 
 * Notes:  
***************************************************************************/

module ticker_25MHz(
    input   clk     , 
            rst     , 
    output  tick
    );
    
    reg [1:0] count, ncount;
    
    assign tick = (count == 2'd3);
    
    always @ (posedge clk, posedge rst)
        if  (rst) 
            count <= 2'b0;
        else
            count <= ncount;
    
    always @ (*)
        if (tick) 
            ncount = 2'b0;
        else
            ncount = count + 2'b1;
    
endmodule