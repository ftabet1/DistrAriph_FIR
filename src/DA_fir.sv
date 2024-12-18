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
	
	logic[BAAT*ORDER/PARTITION-1:0]		rom_addr[0:PARTITION-1];
	logic[OPSIZE*BAAT-1:0]				rom_data[0:PARTITION-1];
	
	genvar i, j;
	generate 
		//CREATE ROM BLOCKS
		for(i = 0; i < PARTITION; i++) begin : PART_i
			for(j = 0; j < BAAT; j++) begin : ROM_i
				ROM #(	.OPSIZE(OPSIZE),
						.CELLS(power(2, ORDER/PARTITION)),
						.ADDR_SIZE(ORDER/PARTITION),
						.MEM_H(MEM_T[i])) 
				rom_i
				(
					.i_oe(1'b1),
					.i_addr(rom_addr[i][(j + 1) * ORDER/PARTITION - 1 : j * ORDER/PARTITION]),
					.o_data(rom_data[i][(j + 1) * OPSIZE - 1 : j * OPSIZE])
				);
			end
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
		$dumpfile("test.wcd");
		$dumpvars(1, test_DA_fir);
		#10
		$finish;
	end

endmodule