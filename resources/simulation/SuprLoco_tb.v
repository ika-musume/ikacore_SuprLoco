`timescale 1ns/1ns
module SuprLoco_tb ;

reg             CLK40M = 1'b0;
always #1 CLK40M = ~CLK40M;

reg             MRST = 1'b1;
initial #1200 MRST <= 1'b0;

reg             pll_locked = 1'b0;
initial #3500 pll_locked <= 1'b1;

wire            master_reset = MRST | ~pll_locked;

wire            vcen, vden;
wire    [2:0]   r, g, b;

wire    [15:0]  ioctl_index;
wire            ioctl_download;
wire    [26:0]  ioctl_addr;
wire    [7:0]   ioctl_data;
wire            ioctl_wr;
wire            ioctl_wait;

SuprLoco_emu u_gameboard_main (
    .i_EMU_MCLK                 (CLK40M                     ),
    .i_EMU_INITRST              (master_reset               ),
    .i_EMU_SOFTRST              (master_reset               ),

    .o_HSYNC_n                  (                           ),
    .o_VSYNC_n                  (                           ),
    .o_CSYNC_n                  (                           ),

    .o_VIDEO_CEN                (vcen                       ),
    .o_VIDEO_DEN                (vden                       ),
    .o_VIDEO_R                  (r                          ),
    .o_VIDEO_G                  (g                          ),
    .o_VIDEO_B                  (b                          ),

    .o_SOUND                    (                           ),

    .i_JOYSTICK0                (                           ),
    .i_JOYSTICK1                (                           ),

    .ioctl_index                (ioctl_index                ),
    .ioctl_download             (ioctl_download             ),
    .ioctl_addr                 (ioctl_addr                 ),
    .ioctl_data                 (ioctl_data                 ),
    .ioctl_wr                   (ioctl_wr                   ), 
    .ioctl_wait                 (ioctl_wait                 )
);

SuprLoco_screensim u_main (
    .i_EMU_MCLK                 (CLK40M                     ),

    .i_VIDEO_CEN                (vcen                       ),
    .i_VIDEO_EN                 (vden                       ),
    .i_VIDEO_R                  (r                          ),
    .i_VIDEO_G                  (g                          ),
    .i_VIDEO_B                  (b                          )
);

SuprLoco_ioctl_test u_ioctl_test (
    .i_HPSIO_CLK                (CLK40M                     ),
    .i_RST                      (master_reset               ),

    .o_IOCTL_INDEX              (ioctl_index                ),
    .o_IOCTL_DOWNLOAD           (ioctl_download             ),
    .o_IOCTL_ADDR               (ioctl_addr                 ),
    .o_IOCTL_DATA               (ioctl_data                 ),
    .o_IOCTL_WR                 (ioctl_wr                   ),
    .i_IOCTL_WAIT               (ioctl_wait                 )
);


endmodule