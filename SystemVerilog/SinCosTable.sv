module SinCosTable (
    input  logic [9:0]  X,
    output logic [39:0] Y
);
    always_comb begin
        case (X)
            // Copia qui le righe dal VHDL (cerca e sostituisci)
            // Esempio: "00..." when "00...",  -->  10'd0: Y = 40'b00...;
            10'd0:   Y = 40'b0000000000000000100011111111111111111000;
            10'd1:   Y = 40'b0000000000110010110011111111111111111000;
            // ... incolla tutto il resto ...
            default: Y = '0; 
        endcase
    end
endmodule
