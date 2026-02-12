module FixRealKCM (
    input  logic [7:0] X,
    output logic [9:0] R
);
    logic [5:0] A0;
    logic [1:0] A1;
    logic [9:0] T0;
    logic [3:0] T1;
    
    // Wire interni per la somma (Bitheap del VHDL)
    logic [9:0] op1, op2;

    // Mapping degli indirizzi
    assign A0 = X[7:2];
    assign A1 = X[1:0];

    // Istanze delle tabelle (che avrai creato sopra)
    FixRealKCM_Table0 u_t0 (.X(A0), .Y(T0));
    FixRealKCM_Table1 u_t1 (.X(A1), .Y(T1));

    // Ricostruzione della somma (VHDL righe 145-146)
    // bitheapFinalAdd_bh7_In0 <= "" & bh7_w9_0 ... & bh7_w0_1;
    // bitheapFinalAdd_bh7_In1 <= ...
    
    // Traduzione della logica di concatenazione FloPoCo:
    // T0 è il contributo MSB, T1 è LSB shiftato e sommato
    assign op1 = {T0[9:4], T1[3:0]}; 
    assign op2 = {6'b0,    T0[3:0]};

    assign R = op1 + op2; // Semplice somma, niente IntAdder dedicato
endmodule
