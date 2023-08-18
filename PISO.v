module PISO // Paralelo para Serial
	(
	input [7:0] p,		// Entrada Paralela
	input clk, 			// Entrada de clock
	input charge,  	// Carga
	output reg s
	);
	
	reg [7:0] q = 0;	// Buffer
	reg [2:0] i = 7;	// Index
	
	
	always @(posedge clk) begin
		if (!charge) begin
			q = p;
			i = 7;
		end else if (i > 0) begin
			s = q[i];
			i = i - 1;
		end else begin
			s = q[i];
			i = 7;
		end
	end
	
endmodule