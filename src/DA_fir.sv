function automatic int power(int base, int exp);
	int result = 1;
	for (int i = 0; i < exp; i++) begin
		result *= base;
	end
	return result;
endfunction

module DA_fir #(parameter OPSIZE = 12, parameter ORDER = 6, parameter BAAT = 3, parameter PARTITION = 2, parameter string MEM_T[0:1] = {"memh_test.hex", "memh_test1.hex"})
(
	input logic rst,
	input logic start,
	input logic clk,
	input logic[OPSIZE-1:0] xin,
	output logic ready,
	output logic[OPSIZE:0] yout
);

	localparam CNT_WIDTH = $clog2(OPSIZE/BAAT);
	localparam STATE_IDLE = 0;
	localparam STATE_CALC = 1;

	logic[ORDER/PARTITION-1:0]				rom_addr[0:BAAT*PARTITION-1];
	logic signed[OPSIZE-1:0]				rom_data[0:BAAT*PARTITION-1];
	logic[OPSIZE-1:0]						x_n[0:ORDER-1];

	logic[OPSIZE:0]							y = '0;
	logic signed[OPSIZE:0]				y_add[0:PARTITION-1];
	logic signed[OPSIZE:0]				y_fb[0:PARTITION-1];
	logic signed[OPSIZE:0]				y_out;
	logic TS = 0;

	logic 					state = STATE_IDLE;
	logic[CNT_WIDTH:0]  	cnt = 0;

	genvar i, j;
	generate 
		//Create ROM blocks
		for(i = 0; i < PARTITION*BAAT; i++) begin : ROM_i
			ROM #(	
				.OPSIZE(OPSIZE),
				.CELLS(power(2, ORDER/PARTITION)),
				.ADDR_SIZE(ORDER/PARTITION),
				.MEM_H(MEM_T[i/(ORDER/PARTITION)])) 
			rom_i
			(
				.i_oe(1'b1),
				.i_addr(rom_addr[i]),
				.o_data(rom_data[i])
			);
		end
		
		//Create x_n to ROM blocks connections
		for(i = 0; i < ORDER*ORDER/PARTITION; i++) begin
			assign rom_addr[i/(ORDER/PARTITION)][i%(ORDER/PARTITION)] = 
				x_n[(i%(ORDER/PARTITION)) + ((i / (ORDER/PARTITION*BAAT)) * (ORDER/PARTITION))][i/BAAT - ((i / (ORDER/PARTITION*BAAT)) * (ORDER/PARTITION))];
		end
	endgenerate
	
	 //Create adders tree's
	always_comb begin
		yout = 0; 
		for(integer i = 0; i < PARTITION; i++) begin
			yout += y_fb[i]; 
		end

		for(integer i = 0; i < PARTITION; i++) begin
			y_add[i] = 0;
			for(integer j = 0; j < BAAT-1; j++) begin
				y_add[i] += (rom_data[j+i*BAAT] >>> (BAAT-1)-j);
			end
			//TS signal
			y_add[i] = TS ? 
				(y_add[i] + (y_fb[i] >>> BAAT) - (rom_data[(BAAT-1) + BAAT*i])) : 
				(y_add[i] + (y_fb[i] >>> BAAT) + (rom_data[(BAAT-1) + BAAT*i]));
		end
	end

	always_ff @(posedge clk) begin
		if(rst) begin
			state = STATE_IDLE;
			for(integer i = 0; i < PARTITION; i++) begin
				y_fb[i] = 0;
			end
			for(integer i = 0; i < ORDER; i++) 	begin
				x_n[i] = 0;
			end
		end else begin
			if(state == STATE_IDLE) begin
				cnt = 0;
				TS = 0;
				ready = 1;
				if(start) begin
					state = STATE_CALC;
					x_n[0] = xin;
					ready = 0;
				end
			end else if(state == STATE_CALC) begin
				//Put adder value to FB reg
				for(integer i = 0; i < PARTITION; i++) begin
					y_fb[i] = y_add[i];
				end

				//x_n shift
				for(integer i = ORDER-1; i >= 1; i--) begin
					x_n[i][(OPSIZE-1)-BAAT : 0] = x_n[i][OPSIZE-1:BAAT]; 
					x_n[i][(OPSIZE-1):OPSIZE-BAAT] = x_n[i-1][BAAT-1:0];
				end
				x_n[0][(OPSIZE-1)-BAAT : 0] = x_n[0][OPSIZE-1:BAAT];
				x_n[0][(OPSIZE-1):OPSIZE-BAAT] = 0;

				if(cnt == (OPSIZE/BAAT)-1) begin
					ready = 1;
					state = STATE_IDLE;
					yout = y_out;
				end else if(cnt == (OPSIZE/BAAT)-2) begin
					TS = 1;
				end

				cnt = cnt + 1;
			end
		end
	end

	initial begin
		for(integer i = 0; i < PARTITION; i++) begin
			y_fb[i] = 0;
		end
		for(integer i = 0; i < ORDER; i++) begin
			x_n[i] = 0;
		end
	end

endmodule

module test_DA_fir();

	localparam OPSIZE = 12;
	localparam ORDER = 6;
	localparam BAAT = 3;
	localparam PARTITION = 2;
	parameter string MEM_T[0:1] = {"memh_test.hex", "memh_test1.hex"};
	
	logic rst = 0;
	logic start = 0;
	logic ready;
	logic clk = 0;
	logic[OPSIZE-1:0] X = 12'h7ff;
	logic[OPSIZE:0] Y;

	always #1 clk ^= 1;

	DA_fir #(OPSIZE, ORDER, BAAT, PARTITION, MEM_T) DA_fir_uut (rst, start, clk, X, ready, Y);
	integer i = 0;
	initial begin
		$dumpfile("test_DA_fir.wcd");
		$dumpvars(1, test_DA_fir);
		#10
		start = 1;
		#2
		start = 0;
		X = 0;
		for(i = 0; i < 10; i ++) begin
			while(!ready) begin
				#2
				start = 0;
			end
			$display("%h",Y);
			start = 1;
			#2
			start = 0;
		end
		$finish;
	end

endmodule