`timescale 1ns / 1ps

/***************************************************************************
 * File Name: debouncer.v
 * Project: Project 01
 * Designer: Juan Saavedra
 * Email: juan.saavedra01@student.csulb.edu
 * Rev. Date: February 4th
 *
 * Purpose: Takes an input (in) from an electromechanical button and outputs a 
 * debounced signal (db) once the input has become stable, pressumed to occur
 * after 20ms at most.
 * A ticker module outputs a pulse every 10ms, this signal is used as the 
 * AISO.v tick input.
 * This module models a modified Moore finite state machine with eight states.
 * Moving across states 000 to 011 requires both "in" and "tick" to be high,
 * while moving across states 100 to 111 requires "in" to be low and "tick" 
 * to be high. States 000 to 011 output db = 0, while states 100 to 111 
 * output db = 1. As a result, db will set high once "in" remains high for
 * two ticks, presumed to be enough time for the debouncing signal to stabilize.
 * 
 * Notes:  
***************************************************************************/

module debouncer(
    input   clk     ,
            rst     ,
            in      ,
            tick    ,
    output  reg db
    );
    
    // Declare present and next state registers for FSM
    reg [2:0]   present_state   ;
    reg [2:0]   next_state      ;
    reg         next_out        ;
    
    // State register logic
    always  @(posedge clk, posedge rst)
        if  (rst)
            {present_state, db} <= {4'b000_0}               ;
        else
            {present_state, db} <= {next_state, next_out}   ;
    
    // Next state combinational logic
    always @ ( present_state, in, tick  )
        casez({present_state, in, tick} )
            // out = 0
            // state 000
            5'b000_0_?  :   {next_state, next_out}  =   4'b000_0;
            5'b000_1_?  :   {next_state, next_out}  =   4'b001_0;
            // state 001
            5'b001_0_?  :   {next_state, next_out}  =   4'b000_0;
            5'b001_1_0  :   {next_state, next_out}  =   4'b001_0;
            5'b001_1_1  :   {next_state, next_out}  =   4'b010_0;
            // state 010
            5'b010_0_?  :   {next_state, next_out}  =   4'b000_0;
            5'b010_1_0  :   {next_state, next_out}  =   4'b010_0;
            5'b010_1_1  :   {next_state, next_out}  =   4'b011_0;
            // state 011
            5'b011_0_?  :   {next_state, next_out}  =   4'b000_0;
            5'b011_1_0  :   {next_state, next_out}  =   4'b011_0;
            5'b011_1_1  :   {next_state, next_out}  =   4'b100_0;
            // out = 1
            // state 100
            5'b100_1_?  :   {next_state, next_out}  =   4'b100_1;
            5'b100_0_?  :   {next_state, next_out}  =   4'b101_1;
            // state 101
            5'b101_1_?  :   {next_state, next_out}  =   4'b100_1;
            5'b101_0_0  :   {next_state, next_out}  =   4'b101_1;
            5'b101_0_1  :   {next_state, next_out}  =   4'b110_1;
            // state 110
            5'b110_1_?  :   {next_state, next_out}  =   4'b100_1;
            5'b110_0_0  :   {next_state, next_out}  =   4'b110_1;
            5'b110_0_1  :   {next_state, next_out}  =   4'b111_1;
            // state 111
            5'b111_1_?  :   {next_state, next_out}  =   4'b100_1;
            5'b111_0_0  :   {next_state, next_out}  =   4'b111_1;
            5'b111_0_1  :   {next_state, next_out}  =   4'b000_1;
            // default case
            default     :   {next_state, next_out}  =   4'b000_0;
        endcase
endmodule
