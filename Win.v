module Win(
		input play,
		input [9:1]board,
		output pwin);

assign pwin= play && ((board[1]==1'b1 && board[2]==1'b1 && board[3]==1'b1) ||
						 (board[4]==1'b1 && board[5]==1'b1 && board[6]==1'b1) ||
						 (board[7]==1'b1 && board[8]==1'b1 && board[9]==1'b1) ||
						 (board[1]==1'b1 && board[5]==1'b1 && board[9]==1'b1) ||
						 (board[3]==1'b1 && board[5]==1'b1 && board[7]==1'b1) ||
						 (board[1]==1'b1 && board[4]==1'b1 && board[7]==1'b1) ||
						 (board[3]==1'b1 && board[6]==1'b1 && board[9]==1'b1) ||
						 (board[2]==1'b1 && board[5]==1'b1 && board[8]==1'b1))? 1'b1: 1'b0;

		
endmodule