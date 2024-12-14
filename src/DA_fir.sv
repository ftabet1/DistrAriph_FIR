module DA_fir #(parameter OPSIZE = 12)
(
	input logic clk,
	input logic[OPSIZE-1:0] X
);
	
	parameter logic[OPSIZE-1:0] A_sub1[0:OPSIZE/4-1] = {500, 500, 500};
	parameter logic[OPSIZE-1:0] A_sub2[0:OPSIZE/4-1] = {500, 500, 500};
	
	logic[OPSIZE-1:0] ROM_sub1[0:OPSIZE/4-1] = {	0,
										A_sub1[0],
										A_sub1[1],
										A_sub1[0]+A_sub1[1],
										A_sub1[2],
										A_sub1[0]+A_sub1[2],
										A_sub1[1]+A_sub1[2],
										A_sub1[0]+A_sub1[1]+A_sub1[2]};
										
	logic[OPSIZE-1:0] ROM_sub2[0:OPSIZE/4-1] = {	0,
										A_sub2[0],
										A_sub2[1],
										A_sub2[0]+A_sub2[1],
										A_sub2[2],
										A_sub2[0]+A_sub2[2],
										A_sub2[1]+A_sub2[2],
										A_sub2[0]+A_sub2[1]+A_sub2[2]};
	
	always@(posedge clk) begin
		
	end
    /*genvar i_gen;
    generate
        for(i_gen = 0; i_gen < OPSIZE/4; i_gen++) begin
            OPSIZE = x_n[i_gen];
        end
        
        for(i_mux = 0; i_mux < RANK; i_mux++) begin
            assign mux_in[i_mux+RANK+1] = y_n[i_mux];
        end
    endgenerate*/

endmodule