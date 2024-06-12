onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group clocks /SuprLoco_tb/u_dut/mrst_n
add wave -noupdate -expand -group clocks /SuprLoco_tb/u_dut/clk40m
add wave -noupdate -expand -group clocks /SuprLoco_tb/u_dut/__ref_clk20m
add wave -noupdate -expand -group clocks /SuprLoco_tb/u_dut/__ref_clk10m
add wave -noupdate -expand -group clocks /SuprLoco_tb/u_dut/__ref_clk5m
add wave -noupdate /SuprLoco_tb/u_dut/clk5m_ncen
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/hcntr_ld_n
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/vcntr_ld_n
add wave -noupdate -group {video timings} -radix unsigned /SuprLoco_tb/u_dut/hcntr
add wave -noupdate -group {video timings} -radix unsigned /SuprLoco_tb/u_dut/vcntr
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/vclk_pcen
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/vblank
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/vsync_n
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/vclk
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/dmaon_n
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/csync_n
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/blank
add wave -noupdate -group {video timings} /SuprLoco_tb/u_dut/irq_n
add wave -noupdate /SuprLoco_tb/u_dut/tmram_rdbus
add wave -noupdate /SuprLoco_tb/u_dut/tmram_addr
add wave -noupdate -group scrlatch /SuprLoco_tb/u_dut/scrlatch_en_n
add wave -noupdate -group scrlatch /SuprLoco_tb/u_dut/codelatch_lo_tick_pcen
add wave -noupdate -group scrlatch /SuprLoco_tb/u_dut/codelatch_lo_tick
add wave -noupdate -group scrlatch -radix unsigned /SuprLoco_tb/u_dut/scrlatch
add wave -noupdate -group scrlatch -radix unsigned /SuprLoco_tb/u_dut/scrval
add wave -noupdate -group {tmseq rom} -radix unsigned -childformat {{{/SuprLoco_tb/u_dut/tmseqrom_addr[4]} -radix unsigned} {{/SuprLoco_tb/u_dut/tmseqrom_addr[3]} -radix unsigned} {{/SuprLoco_tb/u_dut/tmseqrom_addr[2]} -radix unsigned} {{/SuprLoco_tb/u_dut/tmseqrom_addr[1]} -radix unsigned} {{/SuprLoco_tb/u_dut/tmseqrom_addr[0]} -radix unsigned}} -expand -subitemconfig {{/SuprLoco_tb/u_dut/tmseqrom_addr[4]} {-height 15 -radix unsigned} {/SuprLoco_tb/u_dut/tmseqrom_addr[3]} {-height 15 -radix unsigned} {/SuprLoco_tb/u_dut/tmseqrom_addr[2]} {-height 15 -radix unsigned} {/SuprLoco_tb/u_dut/tmseqrom_addr[1]} {-height 15 -radix unsigned} {/SuprLoco_tb/u_dut/tmseqrom_addr[0]} {-height 15 -radix unsigned}} /SuprLoco_tb/u_dut/tmseqrom_addr
add wave -noupdate -group {tmseq rom} /SuprLoco_tb/u_dut/tmseqrom_data
add wave -noupdate -group {tmseq rom} /SuprLoco_tb/u_dut/tmram_wrtime_n
add wave -noupdate -group {tmseq rom} /SuprLoco_tb/u_dut/maincpu_wait_clr_n
add wave -noupdate -group {tmseq rom} /SuprLoco_tb/u_dut/htile_addr_lsb
add wave -noupdate -group {tmseq rom} /SuprLoco_tb/u_dut/codelatch_lo_tick
add wave -noupdate -group {tmseq rom} /SuprLoco_tb/u_dut/codelatch_hi_tick
add wave -noupdate -group {tmseq rom} /SuprLoco_tb/u_dut/tmram_addrsel
add wave -noupdate -group {tmseq rom} /SuprLoco_tb/u_dut/tmsr_modesel
add wave -noupdate -group {LS109 device} /SuprLoco_tb/u_dut/vclk
add wave -noupdate -group {LS109 device} {/SuprLoco_tb/u_dut/tmseqrom_109_device_rst_n[0]}
add wave -noupdate -group {LS109 device} {/SuprLoco_tb/u_dut/tmseqrom_109_device_q[0]}
add wave -noupdate -group {LS109 device} {/SuprLoco_tb/u_dut/tmseqrom_109_device_rst_n[1]}
add wave -noupdate -group {LS109 device} {/SuprLoco_tb/u_dut/tmseqrom_109_device_q[1]}
add wave -noupdate -group codelatch /SuprLoco_tb/u_dut/codelatch_lo_tick
add wave -noupdate -group codelatch /SuprLoco_tb/u_dut/codelatch_lo_tick_pcen
add wave -noupdate -group codelatch /SuprLoco_tb/u_dut/codelatch_lo
add wave -noupdate -group codelatch /SuprLoco_tb/u_dut/codelatch_hi_tick
add wave -noupdate -group codelatch /SuprLoco_tb/u_dut/codelatch_hi_tick_pcen
add wave -noupdate -group codelatch /SuprLoco_tb/u_dut/codelatch_hi
add wave -noupdate -group dlylatch /SuprLoco_tb/u_dut/dlylatch_tick
add wave -noupdate -group dlylatch /SuprLoco_tb/u_dut/dlylatch_tick_pcen
add wave -noupdate -group dlylatch /SuprLoco_tb/u_dut/tilecode_z
add wave -noupdate -group dlylatch /SuprLoco_tb/u_dut/palcode_z
add wave -noupdate -group tilemap /SuprLoco_tb/u_dut/tilerom0_q
add wave -noupdate -group tilemap /SuprLoco_tb/u_dut/tilerom1_q
add wave -noupdate -group tilemap /SuprLoco_tb/u_dut/tilerom2_q
add wave -noupdate -group tilemap /SuprLoco_tb/u_dut/tmpx_3bpp
add wave -noupdate -group tilemap /SuprLoco_tb/u_dut/tmpx_4bpp
add wave -noupdate -group palette /SuprLoco_tb/u_dut/__ref_clk5m
add wave -noupdate -group palette /SuprLoco_tb/u_dut/screen_force_blank_n
add wave -noupdate -group palette /SuprLoco_tb/u_dut/vclk
add wave -noupdate -group palette /SuprLoco_tb/u_dut/blank
add wave -noupdate -group palette /SuprLoco_tb/u_dut/screen_blank
add wave -noupdate -group palette -radix hexadecimal /SuprLoco_tb/u_dut/palrom_addr
add wave -noupdate -group palette -radix hexadecimal /SuprLoco_tb/u_dut/palrom_q
add wave -noupdate -group palette -radix hexadecimal /SuprLoco_tb/u_dut/final_px_q
add wave -noupdate -group palette -radix hexadecimal /SuprLoco_tb/u_dut/o_VIDEO_R
add wave -noupdate -group palette -radix hexadecimal /SuprLoco_tb/u_dut/o_VIDEO_G
add wave -noupdate -group palette -radix hexadecimal /SuprLoco_tb/u_dut/o_VIDEO_B
add wave -noupdate -group screensim /SuprLoco_tb/u_main/i_EMU_MCLK
add wave -noupdate -group screensim /SuprLoco_tb/u_main/i_VIDEO_CEN
add wave -noupdate -group screensim /SuprLoco_tb/u_main/i_VIDEO_EN
add wave -noupdate -group screensim /SuprLoco_tb/u_main/i_VIDEO_R
add wave -noupdate -group screensim /SuprLoco_tb/u_main/i_VIDEO_G
add wave -noupdate -group screensim /SuprLoco_tb/u_main/i_VIDEO_B
add wave -noupdate -group screensim -radix unsigned /SuprLoco_tb/u_main/hcntr
add wave -noupdate -group screensim -radix unsigned /SuprLoco_tb/u_main/vcntr
add wave -noupdate -expand -group 315-5012 -divider {IO PORT}
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_DMAEND
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/i_DMAON_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/i_ONELINE_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_BUFENH_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_BUFENL_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/i_OBJEND_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/i_PTEND
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_LOHP_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_CWEN
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_VCUL_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/i_VEN_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_DELTAX_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_ALULO_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_ONTRF
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_RCS_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_RAMWRH_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_RAMWRL_n
add wave -noupdate -expand -group 315-5012 /SuprLoco_tb/u_dut/u_315_5012_main/o_RA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1383197 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 218
configure wave -valuecolwidth 66
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1312450 ns} {1492038 ns}
