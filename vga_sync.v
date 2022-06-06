`timescale 1ns / 1ps

/***************************************************************************
 * File Name: vga_sync.v
 * Project: Project 02
 * Designer: Juan Saavedra
 * Email: juan.saavedra01@student.csulb.edu
 * Rev. Date: February 4th
 *
 * Purpose: Uses a mod 800 counter and a mod 525 counter to generate V sync, 
 * h sync and video on signals. Additionally, the value of the 800 counter is
 * used as the pixel_x value and the mod 525 coutner value is used as the 
 * pixel_y value.
 * 
 * Notes:  
***************************************************************************/


module vga_sync(
    input           clk         ,
                    rst         ,
                    tick        ,
    output          video_on    ,
                    h_sync      ,
                    v_sync      ,
    output  [9:0]   pixel_x     ,
                    pixel_y
    );
    
    /***************************************************************************
     * Constants for Horizontal Sync Signal
     ***************************************************************************/
    localparam  HD      =   640     ;
    localparam  HLB     =   48      ;
    localparam  HRB     =   16      ;
    localparam  HR      =   96      ;
    localparam  H_END   =   HD + HLB + HRB + HR - 1;
    
    /***************************************************************************
     * Constants for Vertical Sync Signal
     ***************************************************************************/
    localparam  VD      =   480     ;
    localparam  VLB     =   33      ;
    localparam  VRB     =   10      ;
    localparam  VR      =   2       ;
    localparam  V_END   =   VD + VLB + VRB + VR - 1;
    
    /***************************************************************************
     * Wire declarations
     ***************************************************************************/
    wire            h_video_on  ,
                    v_video_on  ;

    /***************************************************************************
     * Register declarations
     ***************************************************************************/
    reg     [9:0]   h_count     ,
                    v_count     ,
                    h_count_next,
                    v_count_next;
                    
    /***************************************************************************
     * Procedural block for handling reset of count varialbes
     * and assignment of count_next variables to count variables
     ***************************************************************************/
    
    always @ (posedge clk or posedge rst)
    begin
        if (rst)
        begin
            h_count <= 10'b0;
            v_count <= 10'b0;
        end
        else
        begin
            h_count     <=  h_count_next;
            v_count     <=  v_count_next;
        end
    end
    
    /***************************************************************************
     * Mod 800 counter
     ***************************************************************************/
   always @(*)
       if (tick)
           begin
           if (h_count == H_END)
               h_count_next = 10'b0;
           else
               h_count_next = h_count + 10'b1;
           end
       else
           h_count_next = h_count;

    /***************************************************************************
     * Mod 525 counter
     ***************************************************************************/
   always @(*)
       if (tick & (h_count == H_END))
           begin
           if (v_count == V_END)
               v_count_next = 10'b0;
           else
               v_count_next = v_count + 10'b1;
           end
       else
           v_count_next = v_count;
    
    /***************************************************************************
     * h_sync and v_sync
     ***************************************************************************/
    assign h_sync  = ( h_count >= (HD + HRB) &&
                       h_count <= (HD + HRB + HR - 1));
                
    assign v_sync  = ( v_count >= (VD + VRB) &&
                       v_count <= (VD + VRB + VR - 1));
    /***************************************************************************
     * h_video_on and v_video_on
     ***************************************************************************/
    assign h_video_on   = ( h_count < HD) ? 1'b1 : 1'b0 ;
    assign v_video_on   = ( v_count < VD) ? 1'b1 : 1'b0 ;
    
    /***************************************************************************
     * video_on is asserted when both h_video_on and v_video_on are asserted
     ***************************************************************************/
    assign video_on     = ( h_video_on && v_video_on)   ;
    
    /***************************************************************************
     * The value of pixel_x is obtained from h_count
     * The value of pixel_y is obtained from v_count
     ***************************************************************************/
    assign pixel_x  =   h_count     ;
    assign pixel_y  =   v_count     ;

    endmodule
    