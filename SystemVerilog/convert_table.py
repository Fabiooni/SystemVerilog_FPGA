import re

# Configurazione
input_file = "flopoco.vhdl"
output_file = "SinCosTable_generated.sv"
# Nome dell'entity VHDL da cercare per la tabella grande
target_entity = "SinCosTable_comb_uid4"

def convert_vhdl_to_sv():
    with open(input_file, 'r') as f:
        lines = f.readlines()

    sv_output = []
    
    # Intestazione del modulo SystemVerilog
    sv_output.append(f"module SinCosTable (\n")
    sv_output.append(f"    input  logic [9:0]  X,\n")
    sv_output.append(f"    output logic [39:0] Y\n")
    sv_output.append(f");\n")
    sv_output.append(f"    always_comb begin\n")
    sv_output.append(f"        case (X)\n")

    capture = False
    
    # Regex per trovare le righe tipo: "0000...00" when "00...00",
    # Gruppo 1: Output (Y), Gruppo 2: Input (X)
    pattern = re.compile(r'\s*"([01]+)"\s+when\s+"([01]+)"')

    for line in lines:
        # Attiva la cattura quando siamo nell'architettura della tabella giusta
        if f"architecture arch of {target_entity}" in line:
            capture = True
        
        # Smetti di catturare se finisce l'architettura
        if capture and "end architecture" in line:
            capture = False
            
        if capture:
            match = pattern.search(line)
            if match:
                val_y = match.group(1) # I 40 bit di output
                val_x = match.group(2) # I 10 bit di input
                
                # Scrittura in formato SystemVerilog: 10'b... : Y = 40'b...;
                sv_line = f"            10'b{val_x}: Y = 40'b{val_y};"
                sv_output.append(sv_line + "\n")

    # Chiusura del modulo
    sv_output.append(f"            default: Y = '0;\n")
    sv_output.append(f"        endcase\n")
    sv_output.append(f"    end\n")
    sv_output.append(f"endmodule\n")

    # Scrittura su file
    with open(output_file, 'w') as f:
        f.writelines(sv_output)
    
    print(f"Fatto! Ho generato {output_file} con tutte le righe convertite.")

if __name__ == "__main__":
    convert_vhdl_to_sv()
