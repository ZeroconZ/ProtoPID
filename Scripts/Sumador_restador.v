module ACC #(
	parameter ANCHO = 16
)(
	input wire [ANCHO-1:0] a,
	input wire [ANCHO-1:0] b,
	input wire resta_suma,
	input wire [ANCHO-1:0] resultado
);

	assign resultado = resta_suma ? (a - b) : (a + b);
	
endmodule

MONDONGO