module Sensor_receiver #(
    parameter ANCHO = 16
)(
    input wire clk,
    input wire clk_datos,
    input wire reset,
    input wire ini_fin,
    
    input wire bit_entrada,
    output reg signed [ANCHO-1:0] Uc
);
    reg [ANCHO-1:0] contador;
    reg signed [ANCHO-1:0] Uc_temp;

    always @(posedge clk_datos) begin
        if (reset) begin
            contador <= 0;
            Uc <= 0;
            Uc_temp <= 0;
        end
        else if (ini_fin && contador < ANCHO) begin
            Uc_temp[contador] <= bit_entrada;
            contador <= contador + 1;
        end
        else if (!ini_fin && contador > 0) begin
            Uc <= Uc_temp;
            Uc_temp <= 0;
            contador <= 0;
        end
    end

endmodule