`timescale 1ns / 1ps

module vga_top(
    input           clk     ,
                    rst     ,
                    up      ,
                    down    ,
                    SW      ,
                    
    output          VGA_HS  ,
                    VGA_VS  ,
            [3:0]   VGA_R   ,
            [3:0]   VGA_G   ,
            [3:0]   VGA_B   
    );
    
    wire            tick        ,
                    ref_tick    ,
                    tick_10ms   ,
                    rst_s       ,
                    video_on    ,
                    up_db       ,
                    down_db     ;
                
    wire    [9:0]   pixel_x     ,
                    pixel_y     ;
                    
    wire    [11:0]  rgb         ;
    
    assign {VGA_R, VGA_G, VGA_B} = video_on ? rgb : 12'b0;
    
    aiso    aiso
        (
            .clk        (       clk         ),
            .rst        (       rst         ),
            .rst_s      (       rst_s       )
        );
    
    ticker_25MHz ticker25MHz_0
        (
            .clk        (       clk         ),
            .rst        (       rst_s       ),
            .tick       (       tick        )
        );
        
    ticker_60Hz ticker60Hz_0
        (
            .clk        (       clk         ),
            .rst        (       rst_s       ),
            .ref_tick   (       ref_tick    )    
        );
        
    tick_10ms   tick_10ms_0
        (
            .clk        (       clk         ),
            .rst        (       rst_s       ),
            .tick       (       tick_10ms   )
        );
        
    debouncer   debouncer_up
        (
            .clk        (       clk         ),
            .rst        (       rst_s       ),
            .in         (       up          ),
            .tick       (       tick_10ms   ),
            .db         (       up_db       )
        );
        
    debouncer   debouncer_down
        (
            .clk        (       clk         ),
            .rst        (       rst_s       ),
            .in         (       down        ),
            .tick       (       tick_10ms   ),
            .db         (       down_db     )
        );
    vga_sync vga_sync_0
        (
            .clk        (       clk         ),
            .rst        (       rst_s       ),
            .tick       (       tick        ),
            .video_on   (       video_on    ),
            .h_sync     (       VGA_HS      ),
            .v_sync     (       VGA_VS      ),
            .pixel_x    (       pixel_x     ),
            .pixel_y    (       pixel_y     )
        );
    
    pixel_generator pixel_gen_0
        (
            .clk        (       clk         ),
            .rst        (       rst_s       ),
            .video_on   (       video_on    ),
            .tick       (       tick        ),
            .ref_tick   (       ref_tick    ),
            .up         (       up_db       ),
            .down       (       down_db     ),
            .mode       (       SW          ),
            .pixel_x    (       pixel_x     ),
            .pixel_y    (       pixel_y     ),
            .rgb        (       rgb         )
        );

endmodule
