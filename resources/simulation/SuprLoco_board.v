module SuprLoco_board (
    input   wire            i_EMU_CLK40M,
    input   wire            i_EMU_RST_n,

    output  wire            o_VIDEO_CEN,
    output  reg             o_VIDEO_EN,
    output  wire    [2:0]   o_VIDEO_R,
    output  wire    [2:0]   o_VIDEO_G,
    output  wire    [2:0]   o_VIDEO_B
);

parameter PATH = "D:/cores/ikacore_SuprLoco/rtl/roms/";

///////////////////////////////////////////////////////////
//////  Clocking information and prescaler
////

/*
    74LS321 acts really weird - see the LS321 sigrok waveform

    CLK40M      ¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|
    prescaler   -0-|-1-|-2-|-3-|-4-|-5-|-6-|-7-|-0-|-1-|-2-|-3-|-4-|-5-|-6-|-7-|-0-|-1-|-2-|

    CLK20Mp     ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|
    
    CLK10Mp     ¯¯¯|___________|¯¯¯|___________|¯¯¯|___________|¯¯¯|___________|¯¯¯|________
    CLK10Mn     ___|¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯

    CLK5Mp      ___|¯¯¯¯¯¯¯¯¯¯¯|___________________|¯¯¯¯¯¯¯¯¯¯¯|___________________|¯¯¯¯¯¯¯¯
    CLK5Mn      ¯¯¯|___________|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___________|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|________

    CLK20M -> use posedge
    CLK10Mp -> use negedge(315-5012 internally inverts the clock)
    CLK5Mp -> use negedge
*/

reg     [2:0]   prescaler;
wire            mrst_n = i_EMU_RST_n;
wire            clk40m = i_EMU_CLK40M;
reg             clk20m_pcen, clk20m_ncen, __ref_clk20m;
reg             clk10m_pcen, clk10m_ncen, __ref_clk10m;
reg             clk5m_pcen, clk5m_ncen, __ref_clk5m;

always @(posedge clk40m) begin
    if(!mrst_n) prescaler <= 3'd0;
    else prescaler <= prescaler == 3'd7 ? 3'd0 : prescaler + 3'd1;

    //clock enables
    clk20m_pcen <= ~prescaler[0];
    clk20m_ncen <= prescaler[0];

    clk10m_pcen <= prescaler == 3'd2 || prescaler == 3'd6;
    clk10m_ncen <= prescaler == 3'd3 || prescaler == 3'd7;

    clk5m_pcen <= prescaler == 3'd7;
    clk5m_ncen <= prescaler == 3'd2;

    //generate reference clocks
    if(clk20m_pcen) __ref_clk20m <= 1'b1;
    else if(clk20m_ncen) __ref_clk20m <= 1'b0;

    if(clk10m_pcen) __ref_clk10m <= 1'b1;
    else if(clk10m_ncen) __ref_clk10m <= 1'b0;

    if(clk5m_pcen) __ref_clk5m <= 1'b1;
    else if(clk5m_ncen) __ref_clk5m <= 1'b0;
end



///////////////////////////////////////////////////////////
//////  Video timing generator
////

wire            flip; assign flip = 1'b0;
wire    [7:0]   hcntr_preload_val = flip ? 8'd63 : 8'd192;
wire    [7:0]   vcntr_preload_val = flip ? 8'd223 : 8'd0;
wire            hcntr_ld_n, vcntr_ld_n;
reg     [7:0]   hcntr, vcntr;
wire            vclk_pcen;
always @(posedge clk40m) begin
    if(!mrst_n) begin
        hcntr <= 8'd0;
        vcntr <= 8'd0;
    end
    else begin if(clk5m_ncen) begin
        if(!hcntr_ld_n) hcntr <= hcntr_preload_val;
        else hcntr <= flip ? hcntr + 8'd255 : hcntr + 8'd1;

        if(vclk_pcen) begin
            if(!vcntr_ld_n) vcntr <= vcntr_preload_val;
            else vcntr <= flip ? vcntr + 8'd255 : vcntr + 8'd1;
        end
    end end 
end

wire            dmaend, vblank, vsync_n;
wire            vclk, dmaon_n, csync_n;
assign  vclk_pcen = vclk == 1'b0 && (flip ? hcntr == 8'd0 : hcntr == 8'd255) && clk5m_ncen;
SuprLoco_PAL16R4_PA5017 u_pa5017 (
    .i_MCLK                     (clk40m                     ),
    .i_RST_n                    (mrst_n                     ),
    .i_CEN                      (clk5m_ncen                 ),

    .i_HCNTR                    (hcntr                      ),
    .i_FLIP_n                   (~flip                      ),
    .i_VBLANK                   (vblank                     ),
    .i_VSYNC_n                  (vsync_n                    ),
    .i_DMAEND                   (dmaend                     ),

    .o_HCNTR_LD_n               (hcntr_ld_n                 ),
    .o_VCLK                     (vclk                       ),
    .o_DMAON_n                  (dmaon_n                    ),
    .o_CSYNC_n                  (csync_n                    )
);


wire            blank, irq_n;
SuprLoco_PAL16R4_PA5016 u_pa5016 (
    .i_MCLK                     (clk40m                     ),
    .i_RST_n                    (mrst_n                     ),
    .i_CEN                      (vclk_pcen                  ),

    .i_VCNTR                    (vcntr                      ),
    .i_FLIP_n                   (~flip                      ),

    .o_VCNTR_LD_n               (vcntr_ld_n                 ),
    .o_BLANK_n                  (                           ),
    .o_VSYNC_n                  (vsync_n                    ),
    .o_VBLANK                   (vblank                     ),
    .o_VBLANK_PNCEN_n           (                           ),
    .o_BLANK                    (blank                      ),
    .o_IRQ_n                    (irq_n                      )
);



///////////////////////////////////////////////////////////
//////  CPU
////

wire    [15:0]  maincpu_addr;
wire    [7:0]   maincpu_wrbus, maincpu_rdbus;





///////////////////////////////////////////////////////////
//////  Tilemap
////

//tilemap sequencer control bits
wire            tmram_wrtime_n; //tilemap write strobe for CPU access
wire            maincpu_wait_clr_n;
wire            htile_addr_lsb;
wire            codelatch_lo_tick, codelatch_hi_tick;
wire            dlylatch_tick;
wire            scrlatch_en_n;
wire    [1:0]   tmram_addrsel;
wire    [1:0]   tmsr_modesel;

//tick positive edge enables
wire            dlylatch_tick_pcen;
wire            codelatch_lo_tick_pcen;
wire            codelatch_hi_tick_pcen;

//tilemap/scroll ram
wire    [7:0]   tmram_rdbus;
reg     [10:0]  tmram_addr;
SuprLoco_SRAM #(.AW(11), .DW(8), .simhexfile({PATH, "tilemap.txt"})) u_tmram (
    .i_MCLK                     (clk40m                     ),

    .i_ADDR                     (tmram_addr                 ),
    .i_DIN                      (maincpu_wrbus              ),
    .o_DOUT                     (tmram_rdbus                ),
    .i_RD                       (1'b1                       ),
    .i_WR                       (1'b0                       )
);

//attribute latches
reg     [7:0]   scrlatch; //74LS377
reg     [7:0]   codelatch_lo, codelatch_hi; //74LS273
always @(posedge clk40m) begin
    if(!mrst_n) scrlatch <= 8'h00;
    else begin if(clk5m_ncen) begin
        if(codelatch_lo_tick_pcen & ~scrlatch_en_n) scrlatch <= tmram_rdbus;
        if(codelatch_lo_tick_pcen) codelatch_lo <= tmram_rdbus;
        if(codelatch_hi_tick_pcen) codelatch_hi <= tmram_rdbus;
    end end
end

//scroll value generator
wire    [7:0]   scrval = hcntr + scrlatch;

//tmram address selector
always @(*) begin
    case(tmram_addrsel)
        2'b00: tmram_addr = maincpu_addr[11:0];
        2'b01: tmram_addr = maincpu_addr[11:0];
        2'b10: tmram_addr = {vcntr[7:3], scrval[7:3], htile_addr_lsb}; //htile index
        2'b11: tmram_addr = {6'b111111, vcntr[7:3]}; //scroll register address
    endcase
end

//tilemap sequencer 
wire        [4:0]   tmseqrom_addr = {~flip, tmram_addrsel[0], scrval[2:0]};
wire        [7:0]   tmseqrom_data;
SuprLoco_PROM #(.AW(5), .DW(8), .simhexfile({PATH, "pr-5221.txt"})) u_seqrom (
    .i_MCLK                     (clk40m                     ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b0                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     (tmseqrom_addr              ),
    .o_DOUT                     (tmseqrom_data              ),
    .i_RD                       (1'b1                       )
);

//LS273
reg     [7:0]   tmseqrom_273_device;
always @(posedge clk40m) begin
    if(!mrst_n) tmseqrom_273_device <= 8'h00;
    else begin if(clk5m_ncen) begin
        tmseqrom_273_device[0] <= tmseqrom_data[0];
        tmseqrom_273_device[1] <= tmseqrom_data[1];
        tmseqrom_273_device[6] <= tmseqrom_data[2];
        tmseqrom_273_device[7] <= tmseqrom_data[3];
        tmseqrom_273_device[5] <= tmseqrom_data[4];
        tmseqrom_273_device[4] <= tmseqrom_data[5];

        tmseqrom_273_device[2] <= tmseqrom_273_device[1];
        tmseqrom_273_device[3] <= tmseqrom_273_device[2];
    end end
end

//reassign the bits
assign  htile_addr_lsb = tmseqrom_273_device[0];
assign  codelatch_lo_tick = tmseqrom_273_device[1];
assign  codelatch_hi_tick = tmseqrom_273_device[3];
assign  dlylatch_tick = tmseqrom_273_device[4];
assign  tmram_addrsel[1] = tmseqrom_273_device[5];
assign  maincpu_wait_clr_n = tmseqrom_273_device[6];
assign  tmram_wrtime_n = tmseqrom_273_device[7];
assign  tmsr_modesel = tmseqrom_data[7:6];

//tick positive edge enables
assign  dlylatch_tick_pcen     = tmseqrom_data[5] & ~dlylatch_tick; //5MHz cen
assign  codelatch_lo_tick_pcen = tmseqrom_data[1] & ~codelatch_lo_tick;
assign  codelatch_hi_tick_pcen = tmseqrom_273_device[2] & ~codelatch_hi_tick;

//external LS109 device
wire    [1:0]   tmseqrom_109_device_rst_n;
reg     [1:0]   tmseqrom_109_device_reg;
wire    [1:0]   tmseqrom_109_device_q = tmseqrom_109_device_reg & tmseqrom_109_device_rst_n;

assign  tmram_addrsel[0] = tmseqrom_109_device_q[0];
assign  scrlatch_en_n = ~tmseqrom_109_device_q[0];

assign  tmseqrom_109_device_rst_n[0] = ~tmseqrom_109_device_q[1];
assign  tmseqrom_109_device_rst_n[1] = vclk;

always @(posedge clk40m) 
    if(!mrst_n) tmseqrom_109_device_reg <= 2'b00;
    else begin if(clk5m_ncen) begin
        if(!tmseqrom_109_device_rst_n[0]) tmseqrom_109_device_reg[0] <= 1'b0;
        else begin if(dlylatch_tick_pcen) begin
            //J=vclk, /K=GND
            if(vclk) tmseqrom_109_device_reg[0] <= ~tmseqrom_109_device_reg[0];
            else     tmseqrom_109_device_reg[0] <= 1'b0;
        end end

        if(!tmseqrom_109_device_rst_n[1]) tmseqrom_109_device_reg[1] <= 1'b0;
        else begin if(dlylatch_tick_pcen) begin
            //J=tmram_addrsel[0], /K=Vcc
            if(tmram_addrsel[0]) tmseqrom_109_device_reg[1] <= 1'b1;
        end end
    end
end

//tilemap attributes
wire    [10:0]  tilecode = {codelatch_hi[2:0], codelatch_lo};
wire    [1:0]   palcode = codelatch_hi[4:3];
wire            force_obj_top_n = codelatch_hi[5];

//tilemap roms
wire    [7:0]   tilerom0_q, tilerom1_q, tilerom2_q;
SuprLoco_PROM #(.AW(13), .DW(8), .simhexfile({PATH, "epr-5223.txt"})) u_tilerom0 (
    .i_MCLK                     (clk40m                     ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b0                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     ({tilecode[9:0], vcntr[2:0]}),
    .o_DOUT                     (tilerom0_q                 ),
    .i_RD                       (1'b1                       )
);
SuprLoco_PROM #(.AW(13), .DW(8), .simhexfile({PATH, "epr-5224.txt"})) u_tilerom1 (
    .i_MCLK                     (clk40m                     ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b0                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     ({tilecode[9:0], vcntr[2:0]}),
    .o_DOUT                     (tilerom1_q                 ),
    .i_RD                       (1'b1                       )
);
SuprLoco_PROM #(.AW(13), .DW(8), .simhexfile({PATH, "epr-5225.txt"})) u_tilerom2 (
    .i_MCLK                     (clk40m                     ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b0                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     ({tilecode[9:0], vcntr[2:0]}),
    .o_DOUT                     (tilerom2_q                 ),
    .i_RD                       (1'b1                       )
);

//LS299 for pixel shifting
reg     [7:0]   tilerom_299_device_a, tilerom_299_device_b, tilerom_299_device_c;
always @(posedge clk40m) if(clk5m_ncen) begin
    case(tmsr_modesel)
        2'b00: begin 
            tilerom_299_device_a <= tilerom_299_device_a;
            tilerom_299_device_b <= tilerom_299_device_b;
            tilerom_299_device_c <= tilerom_299_device_c;
        end
        2'b01: begin 
            tilerom_299_device_a <= tilerom_299_device_a << 1;
            tilerom_299_device_b <= tilerom_299_device_b << 1;
            tilerom_299_device_c <= tilerom_299_device_c << 1;
        end
        2'b10: begin 
            tilerom_299_device_a <= tilerom_299_device_a >> 1;
            tilerom_299_device_b <= tilerom_299_device_b >> 1;
            tilerom_299_device_c <= tilerom_299_device_c >> 1;
        end
        2'b11: begin 
            tilerom_299_device_a <= tilerom0_q;
            tilerom_299_device_b <= tilerom1_q;
            tilerom_299_device_c <= tilerom2_q;
        end
    endcase
end

//LS157 for MSB/LSB selecting
wire    [2:0]   tmpx_3bpp = flip ? {tilerom_299_device_c[0], tilerom_299_device_b[0], tilerom_299_device_a[0]} :
                                   {tilerom_299_device_c[7], tilerom_299_device_b[7], tilerom_299_device_a[7]};

//palette latch(Z)
reg     [7:0]   tilecode_z;
reg     [1:0]   palcode_z;
reg             force_obj_top_n_z;
always @(posedge clk40m) if(clk5m_ncen) begin
    if(dlylatch_tick_pcen) begin
        tilecode_z <= tilecode[10:3];
        palcode_z <= palcode;
        force_obj_top_n_z <= force_obj_top_n;
    end
end

//3bpp -> 4bpp converting LUT
wire    [3:0]   tmpx_4bpp;
SuprLoco_PROM #(.AW(10), .DW(4), .simhexfile({PATH, "pr-5219.txt"})) u_bppconvlut (
    .i_MCLK                     (clk40m                     ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b0                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     ({tilecode_z[6:0], tmpx_3bpp}),
    .o_DOUT                     (tmpx_4bpp                  ),
    .i_RD                       (1'b1                       )
);





///////////////////////////////////////////////////////////
//////  Sprite engine
////

/*
    SPRITE RAM INFORMATION

    WORD3
    {BYTE7, BYTE6}: SPRITE TILE INDEX
    
    WORD2
    {BYTE5, BYTE4}: INDEX OFFSET(can be negative, should be added to the index value)

    WORD0
    BYTE0: Y TOP(starting scanline)
    BYTE1: Y BOTTOM(ending scanline)
    
    WORD1
    {BYTE3[0], BYTE2}: X POS
*/

`ifdef SUPRLOCO_SIMULATION
reg     [7:0]   objram_buf[0:2047];
reg     [7:0]   objram_buf_even[0:1023];
reg     [7:0]   objram_buf_odd[0:1023];
integer         i;
initial begin
    $readmemh({PATH, "sprite.txt"}, objram_buf);
    for(i=0; i<2048; i=i+1) begin
        if(i&1) objram_buf_odd[i>>1] = objram_buf[i];
        else    objram_buf_even[i>>1] = objram_buf[i];
    end
    $writememh({PATH, "sprite_even.txt"}, objram_buf_even);
    $writememh({PATH, "sprite_odd.txt"}, objram_buf_odd);
end
`endif

//instantiate the 315-5012 module
wire            objram_cs_n, objramlo_wr_n, objramhi_wr_n, bufhi_en_n, buflo_en_n;
wire    [9:0]   objram_addr;
wire            objend_n, ptend, lohp_n, cwen, vcul_n, ven_n, deltax_n, alulo_n, ontrf;
Sega_315_5012 u_315_5012_main (
    .i_MCLK                     (clk40m                     ),
    .i_CLK5MNCEN                (clk5m_ncen                 ),
    .i_CLK10MPCEN               (clk10m_pcen                ),

    .o_DMAEND                   (dmaend                     ),
    .i_DMAON_n                  (dmaon_n                    ),
    .i_ONELINE_n                (vcntr_ld_n                 ),

    .i_AD                       (                           ),
    .i_OBJ_n                    (1'b1                       ),
    .i_RD_n                     (1'b1                       ),
    .i_WR_n                     (1'b1                       ),

    .o_BUFENH_n                 (bufhi_en_n                 ),
    .o_BUFENL_n                 (buflo_en_n                 ),

    .i_OBJEND_n                 (objend_n                   ),
    .i_PTEND                    (ptend                      ),

    .o_LOHP_n                   (lohp_n                     ),
    .o_CWEN                     (cwen                       ),
    .o_VCUL_n                   (vcul_n                     ),
    .i_VEN_n                    (ven_n                      ),
    .o_DELTAX_n                 (deltax_n                   ),
    .o_ALULO_n                  (alulo_n                    ),
    .o_ONTRF                    (ontrf                      ),

    .o_RCS_n                    (objram_cs_n                ),
    .o_RAMWRH_n                 (objramhi_wr_n              ),
    .o_RAMWRL_n                 (objramlo_wr_n              ),
    .o_RA                       (objram_addr                )
);

reg     [15:0]  obj_attr_bus;
wire    [15:0]  ro_do;
wire            ro_do_oe;
wire            swap;
Sega_315_5011 u_315_5011_main (
    .i_MCLK                     (clk40m                     ),
    .i_CLK5MNCEN                (clk5m_ncen                 ),

    .i_V                        (vcntr                      ),
    .i_RO_DI                    (obj_attr_bus               ),
    .o_RO_DO                    (ro_do                      ),
    .o_RO_DO_OE                 (ro_do_oe                   ),

    .i_CWEN                     (cwen                       ),
    .i_VCUL_n                   (vcul_n                     ),
    .i_DELTAX_n                 (deltax_n                   ),
    .i_ALULO_n                  (alulo_n                    ),
    .i_ONTRF                    (ontrf                      ),

    .o_VEN_n                    (ven_n                      ),
    .o_SWAP                     (swap                       )
);

//declare object attribute RAM(MBM2148 1k*4 SRAM x 4)
wire    [15:0]  objram_q;
SuprLoco_SRAM #(.AW(10), .DW(8), .simhexfile({PATH, "sprite_odd.txt"})) u_objramhi (
    .i_MCLK                     (clk40m                     ),

    .i_ADDR                     (objram_addr                ),
    .i_DIN                      (obj_attr_bus[15:8]         ),
    .o_DOUT                     (objram_q[15:8]             ),
    .i_RD                       (~objram_cs_n               ),
    .i_WR                       (~(objram_cs_n | objramhi_wr_n))
);

SuprLoco_SRAM #(.AW(10), .DW(8), .simhexfile({PATH, "sprite_even.txt"})) u_objramlo (
    .i_MCLK                     (clk40m                     ),

    .i_ADDR                     (objram_addr                ),
    .i_DIN                      (obj_attr_bus[7:0]          ),
    .o_DOUT                     (objram_q[7:0]              ),
    .i_RD                       (~objram_cs_n               ),
    .i_WR                       (~(objram_cs_n | objramlo_wr_n))
);

//object attribute bus: there are two sources
always @(*) begin
    if(ro_do_oe) obj_attr_bus = ro_do;
    else if(~objram_cs_n) obj_attr_bus = objram_q;
    else obj_attr_bus = 16'h0000;
end

//sprite data ROM
wire    [7:0]   objrom0_q, objrom1_q;

//intel D27128
SuprLoco_PROM #(.AW(14), .DW(8), .simhexfile({PATH, "epr-5229.txt"})) u_objrom0 (
    .i_MCLK                     (clk40m                     ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b0                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     (obj_attr_bus[13:0]         ),
    .o_DOUT                     (objrom0_q                  ),
    .i_RD                       (1'b1                       )
);

//Fujitsu MBM2764
SuprLoco_PROM #(.AW(13), .DW(8), .simhexfile({PATH, "epr-5230.txt"})) u_objrom1 (
    .i_MCLK                     (clk40m                     ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b0                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     (obj_attr_bus[12:0]         ),
    .o_DOUT                     (objrom1_q                  ),
    .i_RD                       (1'b1                       )
);

//sprite data output latch
reg     [7:0]   objdata_reg;
wire    [7:0]   objdata = objdata_reg & {8{ontrf}};
always @(posedge clk40m) begin
    if(!mrst_n) objdata_reg <= 8'h00;
    else begin if(clk5m_ncen) begin
        if(!ontrf) objdata_reg <= 8'h00;
        else begin
            if(cwen) objdata_reg <= obj_attr_bus[14] ? objrom1_q : objrom0_q;
        end
    end end 
end


//select pixel nibble
wire    [3:0]   objdata_nibble = swap ? objdata[7:4] : objdata[3:0];

//object X pos counter
reg             obj_xposcntr_cnt;
always @(posedge clk40m) if(clk5m_ncen) obj_xposcntr_cnt <= ontrf;

reg     [7:0]   obj_xposcntr;
wire            obj_xposcntr_cout = (obj_xposcntr == 8'd255) && obj_xposcntr_cnt;
always @(posedge clk40m) begin
    if(!mrst_n) obj_xposcntr <= 8'd0;
    else begin if(clk5m_ncen) begin
        if(!lohp_n) obj_xposcntr <= obj_attr_bus[7:0];
        else begin
            if(obj_xposcntr_cnt) obj_xposcntr <= obj_xposcntr + 8'd1;
        end
    end end
end

//sprite engine control signal
assign  objend_n = ~&{obj_attr_bus[15:12]};
assign  ptend = &{objdata_nibble} | obj_xposcntr_cout; //de morgan



wire    [3:0]   objpx; assign objpx = 4'hF;




///////////////////////////////////////////////////////////
//////  Priority handler
////

reg             pxsel;
wire    [3:0]   pxout = pxsel ? tmpx_4bpp : objpx;
always @(*) begin
    if(objpx == 4'hF) pxsel = 1'b1; //transparent sprite
    else begin
        if(!force_obj_top_n_z) pxsel = 1'b0; //obj on tm
        else begin
            if(tmpx_4bpp == 4'h0) pxsel = 1'b0; //tm on obj, but the tm is transparent
            else pxsel = 1'b1;
        end
    end
end



///////////////////////////////////////////////////////////
//////  Palette ROM
////

wire            palrom_banksel; assign palrom_banksel = 1'b1;
wire    [8:0]   palrom_addr = {palrom_banksel, pxsel, palcode_z, tilecode_z[7], pxout};
wire    [7:0]   palrom_q;
SuprLoco_PROM #(.AW(9), .DW(8), .simhexfile({PATH, "pr-5220.txt"})) u_palrom (
    .i_MCLK                     (clk40m                     ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b0                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     (palrom_addr                ),
    .o_DOUT                     (palrom_q                   ),
    .i_RD                       (1'b1                       )
);

//screen blanking(async) control 1-bit registrer
wire            screen_force_blank_n; assign screen_force_blank_n = 1'b1;
wire            screen_blank_d = ~(blank | vclk | ~screen_force_blank_n);
reg             screen_blank_q;
wire            screen_blank = ~(screen_force_blank_n & screen_blank_q);

//final pixel register
reg     [7:0]   final_px_reg;
wire    [7:0]   final_px_q = final_px_reg;

always @(posedge clk40m) if(clk5m_ncen) begin
    screen_blank_q <= screen_blank_d;

    if(screen_blank) final_px_reg <= 8'h00;
    else final_px_reg <= palrom_q;

    o_VIDEO_EN <= ~screen_blank;
end

assign  o_VIDEO_CEN = clk5m_ncen;
assign  o_VIDEO_R = final_px_q[2:0];
assign  o_VIDEO_G = final_px_q[5:3];
assign  o_VIDEO_B = {final_px_q[7:6], 1'b0};


endmodule