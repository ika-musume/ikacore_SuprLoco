module Psychic5_top
(
    input   wire            i_EMU_MCLK,
    input   wire            i_EMU_CLK12MPCEN_n,
    input   wire            i_EMU_CLK5MPCEN_n,
    input   wire            i_EMU_CLK5MNCEN_n,

    input   wire            i_EMU_INITRST_n,
    input   wire            i_EMU_SOFTRST_n,

    //for screen recording
    output  wire            __REF_PXCEN,
    output  wire    [8:0]   __REF_HCOUNTER,
    output  wire    [8:0]   __REF_VCOUNTER,

    //video
    output  wire            o_CSYNC_n,
    output  wire            o_HSYNC_n,
    output  wire            o_VSYNC_n,

    output  wire            o_HBLANK_n,
    output  wire            o_VBLANK_n,

    output  wire    [3:0]   o_VIDEO_R,
    output  wire    [3:0]   o_VIDEO_G,
    output  wire    [3:0]   o_VIDEO_B,

    output  wire    [15:0]  o_SOUND,

    input   wire    [7:0]   i_P1_BTN,
    input   wire    [7:0]   i_P2_BTN,
    input   wire    [7:0]   i_SYS_BTN,
    input   wire    [7:0]   i_DIPSW1,
    input   wire    [7:0]   i_DIPSW2,

    //SDRAM requests
    output  wire    [16:0]  o_EMU_MAINCPU_ADDR,
    input   wire    [7:0]   i_EMU_MAINCPU_DATA,
    output  wire            o_EMU_MAINCPU_RQ_n,

    output  wire    [16:0]  o_EMU_OBJROM_ADDR,
    input   wire    [7:0]   i_EMU_OBJROM_DATA,
    output  wire            o_EMU_OBJROM_RQ_n,

    //BRAM programming
    input   wire    [16:0]  i_EMU_BRAM_ADDR,
    input   wire    [7:0]   i_EMU_BRAM_DATA,
    input   wire            i_EMU_BRAM_WR_n,
    
    input   wire            i_EMU_BRAM_SOUNDROM_CS_n,
    input   wire            i_EMU_BRAM_TMBGROM_CS_n,
    input   wire            i_EMU_BRAM_TMFGROM_CS_n,
    input   wire            i_EMU_BRAM_GRAYLUT_CS_n,
    input   wire            i_EMU_BRAM_SEQROM_CS_n
);