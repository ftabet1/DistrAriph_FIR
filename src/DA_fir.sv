function automatic int power(int base, int exp);
	int result = 1;
	for (int i = 0; i < exp; i++) begin
		result *= base;
	end
	return result;
endfunction

module DA_fir #(parameter OPSIZE = 12, parameter ORDER = 6, parameter BAAT = 3, parameter PARTITION = 2, parameter string MEM_T[0:1])
(
	input logic clk,
	input logic[OPSIZE-1:0] X
);
	
	logic[ORDER/PARTITION-1:0]			rom_addr[0:BAAT*PARTITION-1];
	logic[OPSIZE-1:0]					rom_data[0:BAAT*PARTITION-1];
	
	logic[OPSIZE-1:0]					x_n[0:ORDER-1] = {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101};

	genvar i, j;
	generate 
		//CREATE ROM BLOCKS
		for(i = 0; i < PARTITION*BAAT; i++) begin : ROM_i
			ROM #(	.OPSIZE(OPSIZE),
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
		
		for(i = 0; i < ORDER*ORDER/PARTITION; i++) begin
			assign rom_addr[i/(ORDER/PARTITION)][i%(ORDER/PARTITION)] = x_n[(i%(ORDER/PARTITION)) + ((i / (ORDER/PARTITION*BAAT)) * (ORDER/PARTITION))][i/BAAT - ((i / (ORDER/PARTITION*BAAT)) * (ORDER/PARTITION))]; 
		end
	endgenerate
	
	always@(posedge clk) begin
		
	end
	
	initial begin
		
	end

endmodule

module test_DA_fir();

	localparam OPSIZE = 12;
	localparam ORDER = 6;
	localparam BAAT = 3;
	localparam PARTITION = 2;
	localparam string MEM_T[0:1] = {"memh_test.hex", "memh_test1.hex"};
	
	logic clk = 0;
	logic[OPSIZE-1:0] X;
	
	DA_fir #(OPSIZE, ORDER, BAAT, PARTITION, MEM_T) DA_fir_uut (clk, X);
	
	initial begin
		$dumpfile("test_DA_fir.wcd");
		$dumpvars(1, test_DA_fir);
		#10
		$finish;
	end

endmodule