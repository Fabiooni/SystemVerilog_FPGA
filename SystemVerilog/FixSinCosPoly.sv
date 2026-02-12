module FixSinCosPoly (
    input  logic [16:0] X, // Input Fixed Point
    output logic [16:0] S, // Output Seno
    output logic [16:0] C  // Output Coseno
);

    // Segnali interni
    logic        X_sgn, Q, O;
    logic [13:0] Y_in;
    logic [17:0] Yneg;
    logic [9:0]  A;
    logic [7:0]  Y_red;
    
    logic [39:0] SinCosA;
    logic [19:0] SinPiA, CosPiA;
    logic [9:0]  Z; // KCM Output
    
    // Segnali per il polinomio (DSP)
    logic [19:0] CosPiASinZ, SinPiASinZ;
    logic [19:0] PreSinX, PreCosX;
    
    logic [15:0] C_out, S_out;
    logic [15:0] S_wo_sgn, C_wo_sgn;
    logic [16:0] S_wo_sgn_ext, C_wo_sgn_ext;
    logic [16:0] S_wo_sgn_neg, C_wo_sgn_neg;
    
    logic        C_sgn_calc, Exch_calc;

    // --- 1. Riduzione Argomento ---
    assign X_sgn = X[16];
    assign Q     = X[15];
    assign O     = X[14];
    assign Y_in  = X[13:0];

    // Calcolo 0.25 - Y (Logic NOT trick, riga 189 VHDL)
    assign Yneg = (O) ? {~Y_in, 4'b1111} : {Y_in, 4'b0000};
    
    assign A     = Yneg[17:8];
    assign Y_red = Yneg[7:0];

    // --- 2. Lookup Table ---
    SinCosTable u_table (.X(A), .Y(SinCosA));
    
    assign SinPiA = SinCosA[39:20];
    assign CosPiA = SinCosA[19:0];

    // --- 3. Moltiplicazione per Pi (KCM) ---
    FixRealKCM u_kcm (.X(Y_red), .R(Z));

    // --- 4. Calcolo Polinomiale (Taylor) ---
    // Nel VHDL: CosPiASinZ <= CosPiAtrunc * Z;
    // SystemVerilog gestisce automaticamente la larghezza dei DSP
    assign CosPiASinZ = CosPiA[19:10] * Z;
    assign SinPiASinZ = SinPiA[19:10] * Z;

    // Somme finali (ricostruzione Taylor)
    // PreSinX <= SinPiA + CosPiA*Z
    assign PreSinX = SinPiA + {10'b0, CosPiASinZ[19:10]};
    // PreCosX <= CosPiA - SinPiA*Z
    assign PreCosX = CosPiA - {10'b0, SinPiASinZ[19:10]};

    // --- 5. Ricostruzione Finale ---
    assign C_out = PreCosX[19:4];
    assign S_out = PreSinX[19:4];

    assign C_sgn_calc = X_sgn ^ Q;
    assign Exch_calc  = Q ^ O;

    // Scambio Seno/Coseno
    assign S_wo_sgn = (Exch_calc) ? C_out : S_out;
    assign C_wo_sgn = (Exch_calc) ? S_out : C_out;

    // Estensione segno
    assign S_wo_sgn_ext = {1'b0, S_wo_sgn};
    assign C_wo_sgn_ext = {1'b0, C_wo_sgn};

    // Negazione (Complemento a 2)
    assign S_wo_sgn_neg = (~S_wo_sgn_ext) + 1'b1;
    assign C_wo_sgn_neg = (~C_wo_sgn_ext) + 1'b1;

    // Mux finale
    assign S = (X_sgn == 1'b0) ? S_wo_sgn_ext : S_wo_sgn_neg;
    assign C = (C_sgn_calc == 1'b0) ? C_wo_sgn_ext : C_wo_sgn_neg;

endmodule
