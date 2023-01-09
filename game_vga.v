
module game_vga(
	clk,
	reset,
	player, a,
	board1,board2,
	p1_win,p2_win,draw,


	end_of_active_frame,
	end_of_frame,divcntr,

	// dac pins
	vga_blank,					//	VGA BLANK
	vga_c_sync,					//	VGA COMPOSITE SYNC
	vga_h_sync,					//	VGA H_SYNC
	vga_v_sync,					//	VGA V_SYNC
	vga_data_enable,			// VGA DEN
	vga_red,						//	VGA Red[9:0]
	vga_green,	 				//	VGA Green[9:0]
	vga_blue,	   			//	VGA Blue[9:0]
	vga_color_data	   		//	VGA Color[9:0] for TRDB_LCM
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter CW								= 7;

/* Number of pixels */
parameter H_ACTIVE 						= 640;
parameter H_FRONT_PORCH					=  16;
parameter H_SYNC							=  96;
parameter H_BACK_PORCH 					=  48;
parameter H_TOTAL 						= 800;

/* Number of lines */
parameter V_ACTIVE 						= 480;
parameter V_FRONT_PORCH					=  10;
parameter V_SYNC							=   2;
parameter V_BACK_PORCH 					=  33;
parameter V_TOTAL							= 525;

parameter PW								= 10;			// Number of bits for pixels
parameter PIXEL_COUNTER_INCREMENT	= 10'h001;

parameter LW								= 10;			// Number of bits for lines
parameter LINE_COUNTER_INCREMENT		= 10'h001;

/******************************************************************************/

parameter [2500:0] o_pic = {
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000001111111111100000000000000000000},
{50'b00000000000000001111111111111111100000000000000000},
{50'b00000000000000011111111111111111110000000000000000},
{50'b00000000000001111110000000000011111100000000000000},
{50'b00000000000011111000000000000000111110000000000000},
{50'b00000000000111100000000000000000001111000000000000},
{50'b00000000001111000000000000000000000111100000000000},
{50'b00000000001110000000000000000000000011100000000000},
{50'b00000000011100000000000000000000000001110000000000},
{50'b00000000111100000000000000000000000001111000000000},
{50'b00000000111000000000000000000000000000111000000000},
{50'b00000000111000000000000000000000000000111000000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000000111000000000000000000000000000111000000000},
{50'b00000000111000000000000000000000000000111000000000},
{50'b00000000111100000000000000000000000001111000000000},
{50'b00000000011100000000000000000000000001110000000000},
{50'b00000000001110000000000000000000000011100000000000},
{50'b00000000001111000000000000000000000111100000000000},
{50'b00000000000111100000000000000000001111000000000000},
{50'b00000000000011111000000000000000111110000000000000},
{50'b00000000000001111110000000000011111100000000000000},
{50'b00000000000000011111111111111111110000000000000000},
{50'b00000000000000001111111111111111100000000000000000},
{50'b00000000000000000001111111111100000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000}
};

parameter [2500:0] x_pic = {
{50'b00000000000000000000000000000000000000000000000000},
{50'b01110000000000000000000000000000000000000000000111},
{50'b00111000000000000000000000000000000000000000001110},
{50'b00011100000000000000000000000000000000000000011100},
{50'b00001110000000000000000000000000000000000000111000},
{50'b00000111000000000000000000000000000000000001110000},
{50'b00000011100000000000000000000000000000000011100000},
{50'b00000001110000000000000000000000000000000111000000},
{50'b00000000111000000000000000000000000000001110000000},
{50'b00000000011100000000000000000000000000011100000000},
{50'b00000000001110000000000000000000000000111000000000},
{50'b00000000000111000000000000000000000001110000000000},
{50'b00000000000011100000000000000000000011100000000000},
{50'b00000000000001110000000000000000000111000000000000},
{50'b00000000000000111000000000000000001110000000000000},
{50'b00000000000000011100000000000000011100000000000000},
{50'b00000000000000001110000000000000111000000000000000},
{50'b00000000000000000111000000000001110000000000000000},
{50'b00000000000000000011100000000011100000000000000000},
{50'b00000000000000000001110000000111000000000000000000},
{50'b00000000000000000000111000001110000000000000000000},
{50'b00000000000000000000011100011100000000000000000000},
{50'b00000000000000000000001110111000000000000000000000},
{50'b00000000000000000000000111110000000000000000000000},
{50'b00000000000000000000000011100000000000000000000000},
{50'b00000000000000000000000111110000000000000000000000},
{50'b00000000000000000000001110111000000000000000000000},
{50'b00000000000000000000011100011100000000000000000000},
{50'b00000000000000000000111000001110000000000000000000},
{50'b00000000000000000001110000000111000000000000000000},
{50'b00000000000000000011100000000011100000000000000000},
{50'b00000000000000000111000000000001110000000000000000},
{50'b00000000000000001110000000000000111000000000000000},
{50'b00000000000000011100000000000000011100000000000000},
{50'b00000000000000111000000000000000001110000000000000},
{50'b00000000000001110000000000000000000111000000000000},
{50'b00000000000011100000000000000000000011100000000000},
{50'b00000000000111000000000000000000000001110000000000},
{50'b00000000001110000000000000000000000000111000000000},
{50'b00000000011100000000000000000000000000011100000000},
{50'b00000000111000000000000000000000000000001110000000},
{50'b00000001110000000000000000000000000000000111000000},
{50'b00000011100000000000000000000000000000000011100000},
{50'b00000111000000000000000000000000000000000001110000},
{50'b00001110000000000000000000000000000000000000111000},
{50'b00011100000000000000000000000000000000000000011100},
{50'b00111000000000000000000000000000000000000000001110},
{50'b01110000000000000000000000000000000000000000000111},
{50'b01100000000000000000000000000000000000000000000011},
{50'b01000000000000000000000000000000000000000000000001}
};


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

input						clk;
input						reset;
input player; 
input [3:0] a;
input [9:1]board1,board2;
input p1_win,p2_win,draw;
output reg           divcntr;

output reg				end_of_active_frame;
output reg				end_of_frame;

output reg				vga_blank;			//	VGA BLANK
output reg				vga_c_sync;			//	VGA COMPOSITE SYNC
output reg				vga_h_sync;			//	VGA H_SYNC
output reg				vga_v_sync;			//	VGA V_SYNC
output reg				vga_data_enable;	// VGA DEN
output reg	[CW: 0]	vga_red;				//	VGA Red[9:0]
output reg	[CW: 0]	vga_green;			//	VGA Green[9:0]
output reg	[CW: 0]	vga_blue;  	 		//	VGA Blue[9:0]
output reg	[CW: 0]	vga_color_data;	//	VGA Color[9:0] for TRDB_LCM


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
reg			[PW:1]	pixel_counter;
reg			[LW:1]	line_counter;

reg						early_hsync_pulse;
reg						early_vsync_pulse;
reg						hsync_pulse;
reg						vsync_pulse;
reg						csync_pulse;

reg						hblanking_pulse;
reg						vblanking_pulse;
reg						blanking_pulse;

// State Machine Registers
//integers
reg [11:0] m11,m12,m13,m14,m15,m16,m17,m18,m19;
reg [11:0] m21,m22,m23,m24,m25,m26,m27,m28,m29;

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
always @(posedge clk)
begin
if(reset) divcntr=1'b0;
 else
 divcntr = ~divcntr;
 //div_clk = divcntr;
 end
///////////////////////////////////////////////////////////////////////////////

always @ (negedge divcntr)
begin
	if (reset)
	begin
		vga_c_sync			<= 1'b1;
		vga_blank			<= 1'b1;
		vga_h_sync			<= 1'b1;
		vga_v_sync			<= 1'b1;

		vga_red				<= {(CW + 1){1'b0}};
		vga_green			<= {(CW + 1){1'b0}};
		vga_blue				<= {(CW + 1){1'b0}};

		m11=2500;m12=2500;m13=2500;m14=2500;m15=2500;m16=2500;m17=2500;m18=2500;m19=2500;
		m21=2500;m22=2500;m23=2500;m24=2500;m25=2500;m26=2500;m27=2500;m28=2500;m29=2500;
	end
	
	else
	
	begin
		vga_blank			<= ~blanking_pulse;
		vga_c_sync			<= ~csync_pulse;
		vga_h_sync			<= ~hsync_pulse;
		vga_v_sync			<= ~vsync_pulse;
		vga_data_enable	<= ~blanking_pulse;

		if (blanking_pulse)
		begin
			vga_red			<= {(CW + 1){1'b0}};
			vga_green		<= {(CW + 1){1'b0}};
			vga_blue			<= {(CW + 1){1'b0}};

		end
	
		else
		begin
		///////////////////////////////////////////Display #
		if((pixel_counter >= 10'd211 && pixel_counter <= 10'd215) ||
			          (pixel_counter >= 10'd424 && pixel_counter <= 10'd428) ||
						 (line_counter >= 10'd158 && line_counter <= 10'd162) ||
						 (line_counter >= 10'd318 && line_counter <= 10'd322))			
		begin
			vga_red<= 8'd255;
			vga_blue<= 8'd255;
			vga_green<= 8'd255;
		end
		else
		begin
			vga_red<= 8'd0;
			vga_blue<= 8'd0;
			vga_green<= 8'd0;
		end
		
				if(board1 != 9'h0) begin
				if(board1[1]==1'b1)
				begin
					if((pixel_counter >= 10'd0 && pixel_counter <= 10'd210)  && (line_counter >= 10'd0 && line_counter <= 10'd157)) 
					begin
						if((pixel_counter > 10'd60 && pixel_counter <= 10'd110)  && (line_counter > 10'd40 && line_counter <= 10'd90))
						begin
							if(m11==1)
							begin
							vga_red<= 8'd255;
							vga_blue<= 8'd255;
							vga_green<= 8'd255;
							m11<=2500;
							end
			
						else if(x_pic[m11])
							begin
							vga_red<= 8'd255;
							vga_blue<= 8'd255;
							vga_green<= 8'd255;
							m11<=m11-1'b1;
							end
						else
							begin
							vga_red<= 8'd25;
							vga_blue<= 8'd25;
							vga_green<= 8'd25;
							m11<=m11-1'b1;
							end
						end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end
				
			if(board1[2]==1'b1)
				begin
				if((pixel_counter > 10'd216 && pixel_counter <= 10'd423)  && (line_counter >= 10'd0 && line_counter <= 10'd157)) begin
				if((pixel_counter > 10'd300 && pixel_counter <= 10'd350)  && (line_counter > 10'd40 && line_counter <= 10'd90))
					begin
						if(m12==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m12<=2500;
						end
		
					else if(x_pic[m12])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m12<=m12-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m12<=m12-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
				end
				end
				
			if(board1[3]==1'b1)
			begin
				if((pixel_counter > 10'd429 && pixel_counter <= 10'd640)  && (line_counter >= 10'd0 && line_counter <= 10'd157)) begin

				if((pixel_counter > 10'd550 && pixel_counter <= 10'd600)  && (line_counter > 10'd40 && line_counter <= 10'd90))
					begin
						if(m13==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m13<=2500;
						end
		
					else if(x_pic[m13])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m13<=m13-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m13<=m13-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
				end
				end
				
			if(board1[4]==1'b1)
			begin
				if((pixel_counter > 10'd0 && pixel_counter <= 10'd210)  && (line_counter > 10'd163 && line_counter <= 10'd317)) begin

				if((pixel_counter > 10'd60 && pixel_counter <= 10'd110)  && (line_counter > 10'd220 && line_counter <= 10'd270))
					begin
						if(m14==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m14<=2500;
						end
		
					else if(x_pic[m14])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m14<=m14-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m14<=m14-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
				end		
				end
				
			if(board1[5]==1'b1)
			begin
				if((pixel_counter > 10'd216 && pixel_counter <= 10'd423)  && (line_counter > 10'd163 && line_counter <= 10'd317)) begin

				if((pixel_counter > 10'd300 && pixel_counter <= 10'd350)  && (line_counter > 10'd220 && line_counter <= 10'd270))
					begin
						if(m15==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m15<=2500;
						end
		
					else if(x_pic[m15])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m15<=m15-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m15<=m15-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
				end
				end	
			
			if(board1[6]==1'b1)
				begin
				if((pixel_counter > 10'd429 && pixel_counter <= 10'd640)  && (line_counter > 10'd163 && line_counter <= 10'd317)) begin

				if((pixel_counter > 10'd550 && pixel_counter <= 10'd600)  && (line_counter > 10'd220 && line_counter <= 10'd270))
					begin
						if(m16==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m16<=2500;
						end
		
					else if(x_pic[m16])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m16<=m16-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m16<=m16-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
				end
				end
				
			if(board1[7]==1'b1)
				begin
				if((pixel_counter > 10'd0 && pixel_counter <= 10'd210)  && (line_counter > 10'd323 && line_counter <= 10'd480)) begin

				if((pixel_counter > 10'd60 && pixel_counter <= 10'd110)  && (line_counter > 10'd380 && line_counter <= 10'd430))
					begin
						if(m17==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m17<=2500;
						end
		
					else if(x_pic[m17])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m17<=m17-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m17<=m17-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end	
				
			if(board1[8]==1'b1)
				begin
				if((pixel_counter > 10'd216 && pixel_counter <= 10'd423)  && (line_counter > 10'd323 && line_counter <= 10'd480)) begin

				if((pixel_counter > 10'd300 && pixel_counter <= 10'd350)  && (line_counter > 10'd380 && line_counter <= 10'd430))
					begin
						if(m18==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m18<=2500;
						end
		
					else if(x_pic[m18])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m18<=m18-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m18<=m18-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end
				
			if(board1[9]==1'b1)
				begin
				if((pixel_counter > 10'd429 && pixel_counter <= 10'd640)  && (line_counter > 10'd323 && line_counter <= 10'd480)) begin

				if((pixel_counter > 10'd550 && pixel_counter <= 10'd600)  && (line_counter > 10'd380 && line_counter <= 10'd430))
					begin
						if(m19==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m19<=2500;
						end
		
					else if(x_pic[m19])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m19<=m19-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m19<=m19-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end
				end
			
			if(board2 !=9'h0) begin
			if(board2[1]==1'b1)
				begin
				if((pixel_counter >= 10'd0 && pixel_counter <= 10'd210)  && (line_counter > 10'd0 && line_counter <= 10'd157)) begin
					if((pixel_counter > 10'd60 && pixel_counter <= 10'd110)  && (line_counter > 10'd40 && line_counter <= 10'd90))
					begin
						if(m21==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m21<=2500;
						end
		
						else if(o_pic[m21])
							begin
							vga_red<= 8'd255;
							vga_blue<= 8'd255;
							vga_green<= 8'd255;
							m21<=m21-1'b1;
							end
						else
							begin
							vga_red<= 8'd25;
							vga_blue<= 8'd25;
							vga_green<= 8'd25;
							m21<=m21-1'b1;
						end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
				end
			end	
				
			if(board2[2]==1'b1)
				begin
				if((pixel_counter > 10'd216 && pixel_counter <= 10'd423)  && (line_counter > 10'd0 && line_counter <= 10'd157)) begin
				if((pixel_counter > 10'd300 && pixel_counter <= 10'd350)  && (line_counter > 10'd40 && line_counter <= 10'd90))
					begin
						if(m22==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m22<=2500;
						end
		
					else if(o_pic[m22])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m22<=m22-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m22<=m22-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
				end
				end
				
			if(board2[3]==1'b1)
				begin
				if((pixel_counter > 10'd429 && pixel_counter <= 10'd640)  && (line_counter > 10'd0 && line_counter <= 10'd157)) begin

				if((pixel_counter > 10'd550 && pixel_counter <= 10'd600)  && (line_counter > 10'd40 && line_counter <= 10'd90))
					begin
						if(m23==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m23<=2500;
						end
		
					else if(o_pic[m23])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m23<=m23-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m23<=m23-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end
				
			if(board2[4]==1'b1)
				begin
				if((pixel_counter > 10'd0 && pixel_counter <= 10'd210)  && (line_counter > 10'd163 && line_counter <= 10'd317)) begin

				if((pixel_counter > 10'd60 && pixel_counter <= 10'd110)  && (line_counter > 10'd220 && line_counter <= 10'd270))
					begin
						if(m24==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m24<=2500;
						end
		
					else if(o_pic[m24])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m24<=m24-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m24<=m24-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end			 
				
			if(board2[5]==1'b1)
				begin
				if((pixel_counter > 10'd216 && pixel_counter <= 10'd423)  && (line_counter > 10'd163 && line_counter <= 10'd317)) begin
				if((pixel_counter > 10'd300 && pixel_counter <= 10'd350)  && (line_counter > 10'd220 && line_counter <= 10'd270))
					begin
						if(m25==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m25<=2500;
						end
		
					else if(o_pic[m25])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m25<=m25-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m25<=m25-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end	
				
			if(board2[6]==1'b1)
				begin
				if((pixel_counter > 10'd429 && pixel_counter <= 10'd640)  && (line_counter > 10'd163 && line_counter <= 10'd317)) begin
				if((pixel_counter > 10'd550 && pixel_counter <= 10'd600)  && (line_counter > 10'd220 && line_counter <= 10'd270))
					begin
						if(m26==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m26<=2500;
						end
		
					else if(o_pic[m26])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m26<=m26-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m26<=m26-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end	
				
			if(board2[7]==1'b1)
				begin
				if((pixel_counter > 10'd0 && pixel_counter <= 10'd210)  && (line_counter > 10'd323 && line_counter <= 10'd480)) begin
				if((pixel_counter > 10'd60 && pixel_counter <= 10'd110)  && (line_counter > 10'd380 && line_counter <= 10'd430))
					begin
						if(m27==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m27<=2500;
						end
		
					else if(o_pic[m27])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m27<=m27-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m27<=m27-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end	
				
			if(board2[8]==1'b1)
				begin
				if((pixel_counter > 10'd216 && pixel_counter <= 10'd423)  && (line_counter > 10'd323 && line_counter <= 10'd480)) begin

				if((pixel_counter > 10'd300 && pixel_counter <= 10'd350)  && (line_counter > 10'd380 && line_counter <= 10'd430))
					begin
						if(m28==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m28<=2500;
						end
		
					else if(o_pic[m28])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m28<=m28-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m28<=m28-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end		
				
			if(board2[9]==1'b1)
				begin
				if((pixel_counter >= 10'd429 && pixel_counter <= 10'd640)  && (line_counter > 10'd323 && line_counter <= 10'd480)) begin
				if((pixel_counter > 10'd550 && pixel_counter <= 10'd600)  && (line_counter > 10'd380 && line_counter <= 10'd430))
					begin
						if(m29==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m29<=2500;
						end
		
					else if(o_pic[m29])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m29<=m29-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m29<=m29-1'b1;
					end
					end
					else
					begin
					vga_red<= 8'd25;
					vga_blue<= 8'd25;
					vga_green<= 8'd25;
					end
					end
				end
			
		if(p1_win==1'b1)
	   begin
			if((pixel_counter > 10'd300 && pixel_counter <= 10'd350)  && (line_counter > 10'd220 && line_counter <= 10'd270))
					begin
						if(m15==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m15<=2500;
						end
		
					else if(x_pic[m15])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m15<=m15-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m15<=m15-1'b1;
					end
					end
			 else
			 begin
				vga_red<= 8'd25;
				vga_blue<= 8'd25;
				vga_green<= 8'd25;
			 end
	   end
	   else if(p2_win==1'b1)
	   begin
			if((pixel_counter > 10'd300 && pixel_counter <= 10'd350)  && (line_counter > 10'd220 && line_counter <= 10'd270))
					begin
						if(m25==1)
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m25<=2500;
						end
		
					else if(o_pic[m25])
						begin
						vga_red<= 8'd255;
						vga_blue<= 8'd255;
						vga_green<= 8'd255;
						m25<=m25-1'b1;
						end
					else
						begin
						vga_red<= 8'd25;
						vga_blue<= 8'd25;
						vga_green<= 8'd25;
						m25<=m25-1'b1;
					end
					end
			 else
			 begin
				vga_red<= 8'd25;
				vga_blue<= 8'd25;
				vga_green<= 8'd25;
			 end
	   end
	   else if(draw)
	   begin
			vga_red<= 8'd255;
			vga_blue<= 8'd255;
			vga_green<= 8'd255;
	   end	
		end
		
		
////////////////////////////////////////////////////////////////////////////////////////////////RESULT
		
		
	end
end
end
///////////////////////////////////////////////////////////////////////////////
//Horizontal and Vertical counters

always @ (posedge divcntr)
begin
	if (reset)
	begin
		pixel_counter	<= H_TOTAL - 20; 
		line_counter	<= V_TOTAL - 1; 
	end
	else
	begin
		// last pixel in the line
		if (pixel_counter == (H_TOTAL - 1))
		begin
			pixel_counter <= {PW{1'b0}};
			
			// last pixel in last line of frame
			if (line_counter == (V_TOTAL - 1))
				line_counter <= {LW{1'b0}};
			// last pixel but not last line
			else
				line_counter <= line_counter + LINE_COUNTER_INCREMENT;
		end
		else 
			pixel_counter <= pixel_counter + PIXEL_COUNTER_INCREMENT;  
	end
	
end

///////////////////////////////////////////////////////////////////////////////////////////////////
//End of frame and end of active frame
always @ (posedge divcntr) 
begin
	if (reset)
	begin
		end_of_active_frame <= 1'b0;
		end_of_frame		<= 1'b0;
	end
	else
	begin
		if ((line_counter == (V_ACTIVE - 1)) &&
			(pixel_counter == (H_ACTIVE - 2)))
			end_of_active_frame <= 1'b1;
		else
			end_of_active_frame <= 1'b0;

		if ((line_counter == (V_TOTAL - 1)) && 
			(pixel_counter == (H_TOTAL - 2)))
			end_of_frame <= 1'b1;
		else
			end_of_frame <= 1'b0;
	end
end

///////////////////////////////////////////////////////////////////////////////////////////////////
//Sync pulses

always @ (posedge divcntr) 
begin
	if (reset)
	begin
		early_hsync_pulse <= 1'b0;
		early_vsync_pulse <= 1'b0;
		
		hsync_pulse <= 1'b0;
		vsync_pulse <= 1'b0;
		
		csync_pulse	<= 1'b0;
	end
	else
	begin
		// start of horizontal sync
		if (pixel_counter == (H_ACTIVE + H_FRONT_PORCH - 2))
			early_hsync_pulse <= 1'b1;	
		// end of horizontal sync
		else if (pixel_counter == (H_TOTAL - H_BACK_PORCH - 2))
			early_hsync_pulse <= 1'b0;	
			
		// start of vertical sync
		if ((line_counter == (V_ACTIVE + V_FRONT_PORCH - 1)) && 
				(pixel_counter == (H_TOTAL - 2)))
			early_vsync_pulse <= 1'b1;
		// end of vertical sync
		else if ((line_counter == (V_TOTAL - V_BACK_PORCH - 1)) && 
				(pixel_counter == (H_TOTAL - 2)))
			early_vsync_pulse <= 1'b0;
			
		hsync_pulse <= early_hsync_pulse;
		vsync_pulse <= early_vsync_pulse;

		csync_pulse <= early_hsync_pulse ^ early_vsync_pulse;
	end
end


///////////////////////////////////////////////////////////////////////////////////////////////////

// Blanking pulse signals

always @ (posedge divcntr) 
begin
	if (reset)
	begin
		hblanking_pulse	<= 1'b1;
		vblanking_pulse	<= 1'b1;
		
		blanking_pulse	<= 1'b1;
	end
	else
	begin
		if (pixel_counter == (H_ACTIVE - 2))
			hblanking_pulse	<= 1'b1;
		else if (pixel_counter == (H_TOTAL - 2))
			hblanking_pulse	<= 1'b0;
		
		if ((line_counter == (V_ACTIVE - 1)) &&
				(pixel_counter == (H_TOTAL - 2))) 
			vblanking_pulse	<= 1'b1;
		else if ((line_counter == (V_TOTAL - 1)) &&
				(pixel_counter == (H_TOTAL - 2))) 
			vblanking_pulse	<= 1'b0;
			
		blanking_pulse		<= hblanking_pulse | vblanking_pulse;
	end
end

endmodule
