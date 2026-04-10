module PID #(
	parameter ANCHO = 16,

	parameter signed [ANCHO-1:0] mK = 16'b0000000000000001,
	parameter signed [ANCHO-1:0] Kb = 16'b0000000000000010,
	parameter signed [ANCHO-1:0] KbmK = 16'b0,

	parameter signed [ANCHO-1:0] mKT_Ti = 16'b0000000000000001,
	parameter signed [ANCHO-1:0] KT_Ti =  16'b0000000000000010,

	parameter signed [ANCHO-1:0] KTdN_TdmsNT =  16'b0000100001000010,
	parameter signed [ANCHO-1:0] mKTdN_TdmsNT =  16'b000001000011010,

	parameter signed [ANCHO-1:0] Td_TdmsNT = 16'b0100000000000000
)(
	input wire [ANCHO-1:0] Uc, //Señal set point
	input wire [ANCHO-1:0] Y, //Señal feedback

	input wire clk, 
	input wire reset,
	input wire start_tick,

	output wire [ANCHO-1:0] RESULTADO_PID
);

	//CONTROL ACC
	wire clear_acc;
	wire enable_acc;
	wire resta;
	wire update_out;

	//RESULTADO ACC
	wire [ANCHO-1:0] ACC_P_res;
	wire [ANCHO-1:0] ACC_I_res;
	wire [ANCHO-1:0] ACC_D2_res;
	wire [ANCHO-1:0] ACC_D1_res;

	//IO PISOs
	wire load_PISO;
	wire shift_SO;

	wire SO_Uc;
	wire SO_Y;

	wire SO_Delay_Uc;
	wire SO_Delay_Y;
	wire SO_ACC_D2;

	wire [ANCHO-1:0] Delay_Uc_out;
	wire [ANCHO-1:0] Delay_Y_out;

	//IO LUTs
	wire [1:0] lut_inP = {SO_Uc, SO_Y};
	wire [1:0] lut_inI = {SO_Delay_Uc, SO_Delay_Y};
	wire [1:0] lut_inD2 = {SO_Y, SO_Delay_Y};

	wire [ANCHO-1:0] I_out;
	wire [ANCHO-1:0] P_out;
	wire [ANCHO-1:0] D2_out;
	wire [ANCHO-1:0] D1_out;

	
	//MODULO DE CONTROL CENTRAL
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

	//PISO DEL SETPOINT
	PISO #(
		.ANCHO(ANCHO)
	) PISO_Uc (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Uc),
		.serial_out(SO_Uc) 
	);
	
	//PISO DEL FEEDBACK
	PISO #(
		.ANCHO(ANCHO)
	) PISO_Y (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Y),
		.serial_out(SO_Y) 
	);
	
	//DELAY DEL SETPOINT PARA LA LUT I
	Delay #(
		.ANCHO(ANCHO)
	) Delay_Uc (
		.clk(clk),
		.reset(reset),
		.update(update_out),
		.in_val(Uc),
		.out_val(Delay_Uc_out)
	);
	
	//PISO DEL DELAY DEL SETPOINT
	PISO #(
		.ANCHO(ANCHO)
	) PISO_Delay_Uc (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Delay_Uc_out),
		.serial_out(SO_Delay_Uc) 
	);
	
	//DELAY DEL FEEDBACK PARA LA LUT I
	Delay #(
		.ANCHO(ANCHO)
	) Delay_Y (
		.clk(clk),
		.reset(reset),
		.update(update_out),
		.in_val(Y),
		.out_val(Delay_Y_out)
	);
	
	//PISO DEL DELAY DEL FEEDBACK
	PISO #(
		.ANCHO(ANCHO)
	) PISO_Delay_Y (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Delay_Y_out),
		.serial_out(SO_Delay_Y) 
	);

	//ACCION PROPORCIONAL
	LUTP #(
		.mK(mK),
		.Kb(Kb),
		.KbmK(KbmK)
	) P_value (
		.lut_in(lut_inP),
		.lut_out(P_out)
	);

	ACC #(
		.ANCHO(ANCHO)
	) ACC_P (
		.clk(clk),
		.reset(reset),
		.enable(enable_acc),
		.sub(resta),
		.update_val(update_out),
		.val(P_out),
		.resultado(ACC_P_res)
	);

	//ACCION INTEGRAL
	LUTI #(
		.mKT_Ti(mKT_Ti),
		.KT_Ti(KT_Ti)
	) I_value (
		.lut_in(lut_inI),
		.lut_out(I_out)
	);
	
	ACC #(
		.ANCHO(ANCHO)
	) ACC_I (
		.clk(clk),
		.reset(reset),
		.enable(enable_acc),
		.sub(resta),
		.update_val(update_out),
		.val(I_out),
		.resultado(ACC_I_res)
	);

	//ACCION DERIVATIVA
	LUTD2 #(
		.KTdN_TdmsNT(KTdN_TdmsNT),
		.mKTdN_TdmsNT(mKTdN_TdmsNT)
	) D2_value (
		.lut_in(lut_inD2),
		.lut_out(D2_out)
	);

	ACC #(
		.ANCHO(ANCHO)
	) ACC_D2 (
		.clk(clk),
		.reset(reset),
		.enable(enable_acc),
		.sub(resta),
		.update_val(update_out),
		.val(D2_out),
		.resultado(ACC_D2_res)
	);

	PISO #(
		.ANCHO(ANCHO)
	) PISO_D2 (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(ACC_D2_res), //AÑADIR ENTRADA
		.serial_out(SO_ACC_D2) //AÑADIR SALIDA
 	);	

	LUTD1 #(
		.Td_TdmsNT(Td_TdmsNT)
	) D1_value (
		.lut_in(SO_ACC_D2),
		.lut_out(D1_out)
	);

	ACC #(
		.ANCHO(ANCHO)
	) ACC_D1 (
		.clk(clk),
		.reset(reset),
		.enable(enable_acc),
		.sub(resta),
		.update_val(update_out),
		.val(D1_out),
		.resultado(ACC_D1_res)
	);

	assign RESULTADO_PID = ACC_P_res + ACC_I_res + ACC_D2_res + ACC_D1_res;

endmodule