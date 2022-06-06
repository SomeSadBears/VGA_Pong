`timescale 1ns / 1ps

/***************************************************************************
 * File Name: pixel_generator.v
 * Project: Project 04
 * Designer: Juan Saavedra
 * Email: juan.saavedra01@student.csulb.edu
 * Rev. Date: April 4th
 *
 * Purpose: Takes pixel_x and pixel_y values as inputs and uses them to 
 * determine whether an object should be displayed.
 * The three objects, their areas and their respective RGB color values 
 * are as follows:
 *      Wall:
 *          color:  F00
 *          area:   h. scan 32 - 35  
 *      Paddle:
 *          color:  0F0
 *          area:   h. scan 600 - 603, v. scan 204 - 276
 *      Ball:
 *          color:  00F
 *          area:   h. scan 580 - 588, v. scan 238 - 246
 * Remaining area is assigned an RGB value of 000 (black).
 * 
 * Notes:  
***************************************************************************/

module pixel_generator(
    input           clk     ,
                    rst     ,
                    video_on,
                    tick    ,
                    ref_tick,
                    up      ,
                    down    ,
                    mode    ,
    input   [9:0]   pixel_x ,
    input   [9:0]   pixel_y ,
    output  [11:0]  rgb
    );

    /***************************************************************************
     * Constants for Display Area
     ***************************************************************************/
     localparam DISP_L      =           0                                   ;
     localparam DISP_R      =           798                                 ;
     localparam DISP_T      =           0                                   ;
     localparam DISP_B      =           476                                 ;                  
    
    /***************************************************************************
     * Constants for Wall Area
     ***************************************************************************/
    localparam  WALL_L      =           32      -   1                       ;
    localparam  WALL_R      =           35      -   1                       ;
    localparam  WALL_T      =           0                                   ;
    localparam  WALL_B      =           479                                 ;    
    
    /***************************************************************************
     * Constants for Paddle Area
     ***************************************************************************/
    localparam  PADDLE_L        =       600                                 ;
    localparam  PADDLE_R        =       603                                 ;
    localparam  PADDLE_T_INIT   =       204                                 ;
    localparam  PADDLE_Y        =       72                                  ;
    
    /***************************************************************************
     * Constants for Ball Area
     ***************************************************************************/
    localparam  BALL_L_INIT     =       0                                   ;
    localparam  BALL_X          =       8                                   ;
    localparam  BALL_T_INIT     =       0                                   ;
    localparam  BALL_Y          =       8                                   ;
    
    /***************************************************************************
     * Variables for Paddle Position
     ***************************************************************************/
     reg    [9:0]   paddle_t_n  ,
                    paddle_b_n  ;
     
     reg    [9:0]   PADDLE_T    ,
                    PADDLE_B    ;
    
    /***************************************************************************
     * Variables for Ball Position
     ***************************************************************************/
    reg     [9:0]   ball_l_n    ,
                    ball_t_n    ,
                    ball_r_n    ,
                    ball_b_n    ;
                    
    reg     [9:0]   BALL_L      ,
                    BALL_R      ,
                    BALL_T      ,
                    BALL_B      ;
                    
    reg             DIR_X       ,
                    DIR_Y       ;
                    
    reg             dir_x_n     ,
                    dir_y_n     ;
    
    wire     [9:0]  vel         ;
    
    /***************************************************************************
     * Variables for Display Areas and Colors
     ***************************************************************************/
    
    wire            wall_area   ,
                    paddle_area ,
                    ball_area   ,
                    error_state ,
                    restart     ;
                    
    wire    [11:0]  wall_color  ,
                    paddle_color,
                    ball_color  ,
                    off_color   ;
    
    reg     [11:0]  rgb_reg     ,
                    rgb_next    ;
                                        
    
   /***************************************************************************
    * Variables to hold colors for object areas and background
    ***************************************************************************/
    assign  wall_color      =   (mode)  ?   ({2'b11, BALL_B})   :   (12'hF00)   ;
    assign  paddle_color    =   (mode)  ?   ({PADDLE_T, 2'b11}) :   (12'h0F0)   ;
    assign  ball_color      =   (mode)  ?   ({BALL_T, 2'b11})   :   (12'h00F)   ;
    assign  off_color       =   12'h000;
    
    /***************************************************************************
    * Wall area definition
    ***************************************************************************/
    assign wall_area      = (   pixel_x >=  WALL_L  )   && 
                            (   pixel_x <=  WALL_R  )   &&
                            (   pixel_y >=  WALL_T  )   &&
                            (   pixel_y <=  WALL_B  )   ;

    /***************************************************************************
    * Paddle area definition
    ***************************************************************************/       
    assign paddle_area  =   (   pixel_x >=  PADDLE_L)   &&
                            (   pixel_x <=  PADDLE_R)   &&
                            (   pixel_y >=  PADDLE_T)   &&
                            (   pixel_y <=  PADDLE_B)   ;
    
    /***************************************************************************
    * Ball area definition
    ***************************************************************************/                        
    assign ball_area    =   (   pixel_x >=  BALL_L  )   &&
                            (   pixel_x <=  BALL_R  )   &&
                            (   pixel_y >=  BALL_T  )   &&
                            (   pixel_y <=  BALL_B  )   ;
                              
    /***************************************************************************
    * Error state declared if more than one area is enabled simultanously
    ***************************************************************************/           
    assign error_state  =   (   wall_area     &&  paddle_area                   )   ||  
                            (   wall_area     &&  ball_area                     )   ||
                            (   paddle_area   &&  ball_area                     )   ||   
                            (   wall_area     &&  paddle_area   &&  ball_area   )   ;
    
    /***************************************************************************
     * Restart flag triggers when BALL's Right Edge touches Display Edge
     ***************************************************************************/ 
    assign restart      =   (   BALL_R >= DISP_R                                )   ;
    
    assign vel          =   (mode)  ?   (10'd2) :   (10'd1)                         ;
    /***************************************************************************
     * Procedural block handling secondary position variables
     ***************************************************************************/ 
    
    always@(*)
        if(rst || restart)
        begin
            paddle_b_n  <=  PADDLE_T_INIT   	+   PADDLE_Y;
            ball_r_n    <=  BALL_L_INIT     	+   BALL_X  ;
            ball_b_n    <=  BALL_T_INIT     	+   BALL_Y  ;
        end
        else
        begin
            paddle_b_n  <=  PADDLE_T    	+   PADDLE_Y;
            ball_r_n    <=  BALL_L      	+   BALL_X  ;
            ball_b_n    <=  BALL_T      	+   BALL_Y  ;            
        end
    
    /***************************************************************************
     * Procedural block handling primary paddle position variables
     ***************************************************************************/ 
     
    always@(posedge clk or posedge rst)
        if(rst || restart)
            paddle_t_n  <= PADDLE_T_INIT    ;
        else if(ref_tick)
        begin
            if(up && down)
            begin
                paddle_t_n <= PADDLE_T          ;
            end
            else if(up && (PADDLE_T > DISP_T))
                paddle_t_n <= PADDLE_T - 10'd4  ;
            else if(down && (PADDLE_B <= DISP_B))
                paddle_t_n <= PADDLE_T + 10'd4  ;
        end
    
    /***************************************************************************
     * Procedural block handling primary ball position variables
     ***************************************************************************/ 
    always@(posedge clk or posedge rst)
        if(rst || restart)
        begin
            ball_l_n    <=  BALL_L_INIT ;
            ball_t_n    <=  BALL_T_INIT ;
        end
        else if(ref_tick)
        begin
            ball_l_n = DIR_X ? (BALL_L - vel)   :   (BALL_L + vel   );
            ball_t_n = DIR_Y ? (BALL_T - vel)   :   (BALL_T + vel   );
        /*
            case({dir_x_n, dir_y_n})
                2'b11   :   {ball_l_n, ball_t_n} = {BALL_L + 10'b1, BALL_T + 10'b1}; 
                2'b10   :   {ball_l_n, ball_t_n} = {BALL_L + 10'b1, BALL_T - 10'b1};
                2'b01   :   {ball_l_n, ball_t_n} = {BALL_L - 10'b1, BALL_T + 10'b1};
                2'b00   :   {ball_l_n, ball_t_n} = {BALL_L - 10'b1, BALL_T - 10'b1};   
            endcase
            */
        end
        
       /***************************************************************************
        * Procedural block assigning buffer registers to proper values
        ***************************************************************************/ 
        always@(posedge clk or posedge rst)
        if(rst || restart)
        begin
            PADDLE_T    <=  PADDLE_T_INIT               ;
            PADDLE_B    <=  PADDLE_T_INIT + PADDLE_Y    ;
            BALL_L      <=  BALL_L_INIT                 ;
            BALL_R      <=  BALL_L_INIT   + BALL_X      ;
            BALL_T      <=  BALL_T_INIT                 ;
            BALL_B      <=  BALL_T_INIT   + BALL_Y      ;
            DIR_X       <=  1'b0                        ;
            DIR_Y       <=  1'b0                        ;
        end
        else
        begin
            PADDLE_T    <=  paddle_t_n  ;
            PADDLE_B    <=  paddle_b_n  ;
            BALL_L      <=  ball_l_n    ;
            BALL_R      <=  ball_r_n    ;
            BALL_T      <=  ball_t_n    ;
            BALL_B      <=  ball_b_n    ;
            DIR_X       <=  dir_x_n     ;
            DIR_Y       <=  dir_y_n     ;
        end
        
       /***************************************************************************
        * Procedural block handling ball direction
        ***************************************************************************/ 
        always@(posedge clk or posedge rst)
            if(rst || restart)
            begin
                dir_x_n <=  1'b0;
                dir_y_n <=  1'b0;
            end
            else if(ref_tick)
            begin
                if(BALL_L == WALL_R)
                begin
                    if({DIR_X, DIR_Y} == 2'b10)
                        {dir_x_n, dir_y_n} <= 2'b00;
                    else if({DIR_X, DIR_Y} == 2'b11)
                        {dir_x_n, dir_y_n} <= 2'b01;
                end
                else if(BALL_T == DISP_T)
                begin
                    if({DIR_X, DIR_Y} == 2'b01)
                        {dir_x_n, dir_y_n} <= 2'b00;
                    else if({DIR_X, DIR_Y} == 2'b11)
                        {dir_x_n, dir_y_n} <= 2'b10;
                end
                else if(BALL_B == DISP_B)
                begin
                    if({DIR_X, DIR_Y} == 2'b00)
                        {dir_x_n, dir_y_n} <= 2'b01;
                    else if({DIR_X, DIR_Y} == 2'b10)
                        {dir_x_n, dir_y_n} <= 2'b11;
                end
                else if((BALL_R == PADDLE_L) && 
                        (BALL_T >= PADDLE_T) &&
                        (BALL_B <= PADDLE_B)    )
                 begin
                    if({DIR_X, DIR_Y} == 2'b00)
                        {dir_x_n, dir_y_n} <= 2'b10;
                    else if({DIR_X, DIR_Y} == 2'b01)
                        {dir_x_n, dir_y_n} <= 2'b11;
                 end
                 else
                    {dir_x_n, dir_y_n} <= {DIR_X, DIR_Y};
            end

    
    /***************************************************************************
    * Procedural block assigning correct color to rgb_next register
    * depending on current region
    ***************************************************************************/   
    always@(posedge clk or posedge rst)
        if(rst)
            rgb_next <= off_color;
            
        else if (tick && video_on)
        begin
            if(wall_area)
                rgb_next <=  wall_color  ;
                
            else if(paddle_area)
                rgb_next <=  paddle_color;
            
            else if(ball_area)
                rgb_next <=  ball_color  ;
            
            else
                rgb_next <=  off_color   ;
        end
        
    assign rgb = rgb_next;
    
endmodule
