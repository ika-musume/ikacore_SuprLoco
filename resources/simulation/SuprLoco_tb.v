`timescale 1ns/1ns
module SuprLoco_tb ;

reg             CLK40M = 1'b0;
always #1 CLK40M = ~CLK40M;

reg             RST_n = 1'b0;
initial begin
    #30 RST_n <= 1'b0;
    #130 RST_n <= 1'b1;
end

wire            pxcen, ven;
wire    [2:0]   r, g, b;

SuprLoco_board u_dut (
    .i_EMU_CLK40M               (CLK40M                     ),
    .i_EMU_RST_n                (RST_n                      ),

    .o_VIDEO_CEN                (pxcen                      ),
    .o_VIDEO_EN                 (ven                        ),
    .o_VIDEO_R                  (r                          ),
    .o_VIDEO_G                  (g                          ),
    .o_VIDEO_B                  (b                          )
);


SuprLoco_screensim u_main (
    .i_EMU_MCLK                 (CLK40M                     ),

    .i_VIDEO_CEN                (pxcen                      ),
    .i_VIDEO_EN                 (ven                        ),
    .i_VIDEO_R                  (r                          ),
    .i_VIDEO_G                  (g                          ),
    .i_VIDEO_B                  (b                          )
);


endmodule