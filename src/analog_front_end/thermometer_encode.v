`timescale 1ns/1ps

module encoder (
    in_enc,
    out_enc
);

parameter N = 256;

input [0:N-2] in_enc;
reg [7:0] out_enc;
output [7:0] out_enc;
// output out_enc0, out_enc1, out_enc2, out_enc3, out_enc4, out_enc5, out_enc6, out_enc7;

integer k;

always @(*) begin

    out_enc = 0; // Valore di default

    for (k = N-2; k >= 0; k = k - 1) begin
        if (in_enc[k] == 1'b0) begin
			// La posizione dell'unico '0' trovato corrisponde al valore che si vuole rappresentare
            out_enc = N-2 - k + 1; // questa operazione restituisce il valore analogico in digitale 
								 // che si vuole rappresentare 
        end
    end
end

// Un'altra soluzione (probabile migliore)  la seguente
// always @*
// case (in_enc)
//      {255'b0}: out_enc = 0;
//      {254'b0, 1'b1}: out_enc = 1;
//      {253'b0, 1'b1, 1'bz}: out_enc = 2;
//      {252'b0, 1'b1, 2'bz}: out_enc = 3;
//      {}
// endcase

// assign out_enc0 = out_enc[0];
// assign out_enc1 = out_enc[1];
// assign out_enc2 = out_enc[2];
// assign out_enc3 = out_enc[3];
// assign out_enc4 = out_enc[4];
// assign out_enc5 = out_enc[5];
// assign out_enc6 = out_enc[6];
// assign out_enc7 = out_enc[7];

endmodule
