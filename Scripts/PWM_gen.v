module PWM_gen #(
    parameter ANCHO = 16
)(
    input wire clk,
    input wire reset,

    input wire [ANCHO-1:0] RESULTADO_PID,
    output wire PWM_out
)

    localparam CURRENT_CYCLE = 16'b00;

    always(@posedge clk) begin
        if (CURRENT_CYCLE == RESULTADO_PID) begin
            assign PWM_out = 1'b0;
        end
        else begin
            assign PWM_out = 1'b1;
        end
    end

endmodule