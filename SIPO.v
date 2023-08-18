module SIPO // Serial para Paralelo
	(
	input 			s,			// Entrada SEruak
	input 			clk, 		// Entrada de Clock
	input 			reset,  	// Reseta os FFs
	output [7:0] 	p			// Saida Paralela
	);
	
	reg [7:0] q = 0;			// Buffer
	reg [2:0] i = 7;			// Index
	
	
	always @(posedge clk) begin
		if (!reset) begin
			q = 0;
			i = 7;
		end else if (i > 0) begin
			q[i] = s;
			i = i - 1;
		end else begin
			q[i] = s;
			i = 7;
		end
	end
	
	assign p = q;
	
endmodule