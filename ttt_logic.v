module ttt_logic(
        input [3:0]a,
		 input reset, 
		 output reg p1_win, p2_win, p_draw,err,g_end,
        output reg [6:0]disp_p, p_num1, p_num2);

reg [9:1]board1,board2;
reg player;

always@(*)
begin
if(reset)
begin
p1_win = 1'b0;
p2_win = 1'b0;
p_draw = 1'b0;
player = 1'b0;
p_num1 = 1'b0;
p_num2 = 1'b0;
err=1'b0;
disp_p=7'b0000110;
g_end=1'b0;
end

if(g_end == 1'b0)
begin
	if(player==0)// Player 1's turn
	begin
		if(board1[a]!=1'b1)// check if input is valid
		begin
			board1[a]=1'b1;
			checkwin g1(board1,p1_win);
			//bcd_7seg_decoder g2(4'h1,p_num1,);
			p_num1=7'b1001111;
			player=1'b1;
			if(p1_win==1'b1)g_end=1'b1;
		end
		
		else
		begin
		err=1'b1;
		end
	end

	else if(player==1)// Player 2's turn
	begin
		if(board2[a]!=1'b1)// check if input is valid
		begin
			board2[a]=1'b1;
			checkwin g3(board2,p2_win);
			//bcd_7seg_decoder g4(4'h2,p_num2,);
			p_num=7'b0010010;
			player=1'b0;
			if(p2_win==1'b1)g_end=1'b1;
		end
		
		else
		begin
		err=1'b1;
		end
	end

	if((board1 ^ board2) == {9{1'b1}})
	begin
		p_draw=1'b1;
		g_end=1'b1;
	end
end
end
		  		  
endmodule