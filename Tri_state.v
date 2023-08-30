module Tri_state (
	inout io_data,
	input direcionamento, 
	input envio,
	output recebimento 
); 

 
assign io_data = direcionamento ? envio : 1'bZ;
assign recebimento = io_data;


endmodule