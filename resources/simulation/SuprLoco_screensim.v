module SuprLoco_screensim
(
    input   wire            i_EMU_MCLK,

    input   wire            i_VIDEO_CEN,
    input   wire            i_VIDEO_EN,
    input   wire    [2:0]   i_VIDEO_R,
    input   wire    [2:0]   i_VIDEO_G,
    input   wire    [2:0]   i_VIDEO_B
);

wire                clk40m = i_EMU_MCLK;
wire                clk5m_ncen = i_VIDEO_CEN;

reg     [7:0]       RESNET_CONSTANT[31:0];
reg     [7:0]       BITMAP_HEADER[63:0];
integer             BITMAP_LINE_ADDRESS = 32'h29D36;
wire    [3:0]       B = {i_VIDEO_B, 1'b0};
wire    [3:0]       G = {i_VIDEO_G, 1'b0};
wire    [3:0]       R = {i_VIDEO_R, 1'b0};

integer             fd;
integer             i;
reg     [15:0]      frame = 16'd0;

initial begin
    $readmemh("debug_resnet_level.txt", RESNET_CONSTANT);
    $readmemh("debug_bitmap_header.txt", BITMAP_HEADER);
end

reg     [8:0]   hcntr = 9'd255;
reg     [7:0]   vcntr = 8'd223;
always @(posedge clk40m) if(clk5m_ncen) begin
    if(i_VIDEO_EN) begin
        hcntr = hcntr + 9'd1;
    end
    else begin
        if(hcntr >= 9'd255 && hcntr < 9'd271) begin
            hcntr = hcntr + 9'd1;
        end
        else if(hcntr >= 9'd271) begin
            hcntr = 9'd0;
            vcntr = vcntr == 8'd223 ? 8'd0 : vcntr + 8'd1;
        end
        else begin
            hcntr = hcntr;
            vcntr = vcntr;
        end
    end
end



always @(posedge clk40m) if(clk5m_ncen) begin
    if(vcntr < 8'd224) begin
        if(i_VIDEO_EN) begin
            $fwrite(fd, "%c%c%c", RESNET_CONSTANT[B], RESNET_CONSTANT[G], RESNET_CONSTANT[R]); //B G R
        end
        else begin
            if(vcntr == 9'd223 && hcntr == 9'd266) begin
                BITMAP_LINE_ADDRESS = 32'h29D36; //reset line

                fd = $fopen($sformatf("suprloco_frame%0d.bmp", frame), "wb"); //generate new file

                for(i = 0; i < 54; i = i + 1) begin //write bitmap header
                    $fwrite(fd, "%c", BITMAP_HEADER[i]);
                end      

                $display("Start of frame %d", frame); //debug message
            end
            else if(hcntr == 9'd267) begin
                $fseek(fd, BITMAP_LINE_ADDRESS, 0); //set current line address
            end
            else if(hcntr == 9'd265) begin
                if(vcntr != 8'd223) BITMAP_LINE_ADDRESS = BITMAP_LINE_ADDRESS - 32'h300; //decrease line
            end
            else if(vcntr == 9'd223 && hcntr == 9'd264) begin
                $fclose(fd); //close this frame
                $display("Frame %d saved", frame); //debug message
                
                frame = frame + 16'd1;
            end
        end
    end
end


endmodule