`timescale 1ns / 1ps

/***************************************************************************
 * File Name: AISO.v
 * Project: Project 01
 * Designer: Juan Saavedra
 * Email: juan.saavedra01@student.csulb.edu
 * Rev. Date: February 4th
 *
 * Purpose: Implements two D flip-flops to generate an Asynchronous In 
 * Synchronous Out circuit. Takes an asynchronous reset as an input and 
 * outputs a synchronous reset (rst_s).
 *
 * 
 * Notes:  
***************************************************************************/

module aiso(
    input   clk     , 
            rst     ,
    output  rst_s
    );
    
    reg q1, q2;
    
    always @ (posedge clk, posedge rst)
        if (rst)
        begin
            q1 <= 1'b0  ;
            q2 <= 1'b0  ;
        end
        
        else
        begin
            q1 <= 1'b1  ;
            q2 <= q1    ;
        end
    
    assign rst_s = ~q2;
    
endmodule
