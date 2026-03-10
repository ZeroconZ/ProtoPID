module PID #(
	parameter ANCHO = 16,
	parameter signed [15:0] mK = 16'b1001,
	parameter signed [15:0] Kb = 16'b0001,
	parameter signed [15:0] KbmK = 16'b0
)(
	input wire [ANCHO-1:0] Uc, //Señal set point
	input wire [ANCHO-1:0] Y, //Señal feedback

	input wire clk, 
	input wire reset,
	input wire start_tick,

	output wire clear_acc,
	output wire enable_acc,
	output wire resta,
	output wire update_out,

	output wire [ANCHO-1:0] P_out,
	output wire SO_Uc,
	output wire SO_Y
);

	//IO PISOs
	wire load_PISO;
	wire shift_SO;
	//wire SO_Uc;
	//wire SO_Y;

	//IO LUTs
	wire [1:0] lut_inP = {SO_Uc, SO_Y};

	UCC UCCi (
		.clk(clk),
		.reset(reset),
		.start_tick(start_tick),

		.load_PISO(load_PISO),
		.shift_SO(shift_SO),

		.clear_acc(clear_acc),
		.enable_acc(enable_acc),
		.resta(resta),
		.update_out(update_out)
	);

	PISO #(
		.ANCHO(ANCHO)
	) PISO_Uc (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Uc),
		.serial_out(SO_Uc) //AÑADIR SALIDA
	);
	
	PISO #(
		.ANCHO(ANCHO)
	) PISO_Y (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Y),
		.serial_out(SO_Y) //AÑADIR SALIDA
	);
	
	/*
	PISO PISO_D1 (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_PISO),

		.parallel_in(), //AÑADIR ENTRADA
		.serial_out() //AÑADIR SALIDA
 	);	
	*/

	LUTP #(
		.mK(mK),
		.Kb(Kb),
		.KbmK(KbmK)
	) P_value (
		.lut_in(lut_inP),
		.lut_out(P_out)
	);

endmodule