// -----------------------------------------------------------------------------
// Sample input ROM for two degree-127 polynomials.
// Modify these coefficients for a different demonstration vector.
// A[i] = (3*i*i + 5*i + 7) mod q
// B[i] = (11*i + 13) mod q
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module input_rom_128(
    input  [6:0] addr,
    output reg [13:0] a_coeff,
    output reg [13:0] b_coeff
);
    always @(*) begin
        case (addr)
            7'd0: begin a_coeff = 14'd7; b_coeff = 14'd13; end
            7'd1: begin a_coeff = 14'd15; b_coeff = 14'd24; end
            7'd2: begin a_coeff = 14'd29; b_coeff = 14'd35; end
            7'd3: begin a_coeff = 14'd49; b_coeff = 14'd46; end
            7'd4: begin a_coeff = 14'd75; b_coeff = 14'd57; end
            7'd5: begin a_coeff = 14'd107; b_coeff = 14'd68; end
            7'd6: begin a_coeff = 14'd145; b_coeff = 14'd79; end
            7'd7: begin a_coeff = 14'd189; b_coeff = 14'd90; end
            7'd8: begin a_coeff = 14'd239; b_coeff = 14'd101; end
            7'd9: begin a_coeff = 14'd295; b_coeff = 14'd112; end
            7'd10: begin a_coeff = 14'd357; b_coeff = 14'd123; end
            7'd11: begin a_coeff = 14'd425; b_coeff = 14'd134; end
            7'd12: begin a_coeff = 14'd499; b_coeff = 14'd145; end
            7'd13: begin a_coeff = 14'd579; b_coeff = 14'd156; end
            7'd14: begin a_coeff = 14'd665; b_coeff = 14'd167; end
            7'd15: begin a_coeff = 14'd757; b_coeff = 14'd178; end
            7'd16: begin a_coeff = 14'd855; b_coeff = 14'd189; end
            7'd17: begin a_coeff = 14'd959; b_coeff = 14'd200; end
            7'd18: begin a_coeff = 14'd1069; b_coeff = 14'd211; end
            7'd19: begin a_coeff = 14'd1185; b_coeff = 14'd222; end
            7'd20: begin a_coeff = 14'd1307; b_coeff = 14'd233; end
            7'd21: begin a_coeff = 14'd1435; b_coeff = 14'd244; end
            7'd22: begin a_coeff = 14'd1569; b_coeff = 14'd255; end
            7'd23: begin a_coeff = 14'd1709; b_coeff = 14'd266; end
            7'd24: begin a_coeff = 14'd1855; b_coeff = 14'd277; end
            7'd25: begin a_coeff = 14'd2007; b_coeff = 14'd288; end
            7'd26: begin a_coeff = 14'd2165; b_coeff = 14'd299; end
            7'd27: begin a_coeff = 14'd2329; b_coeff = 14'd310; end
            7'd28: begin a_coeff = 14'd2499; b_coeff = 14'd321; end
            7'd29: begin a_coeff = 14'd2675; b_coeff = 14'd332; end
            7'd30: begin a_coeff = 14'd2857; b_coeff = 14'd343; end
            7'd31: begin a_coeff = 14'd3045; b_coeff = 14'd354; end
            7'd32: begin a_coeff = 14'd3239; b_coeff = 14'd365; end
            7'd33: begin a_coeff = 14'd3439; b_coeff = 14'd376; end
            7'd34: begin a_coeff = 14'd3645; b_coeff = 14'd387; end
            7'd35: begin a_coeff = 14'd3857; b_coeff = 14'd398; end
            7'd36: begin a_coeff = 14'd4075; b_coeff = 14'd409; end
            7'd37: begin a_coeff = 14'd4299; b_coeff = 14'd420; end
            7'd38: begin a_coeff = 14'd4529; b_coeff = 14'd431; end
            7'd39: begin a_coeff = 14'd4765; b_coeff = 14'd442; end
            7'd40: begin a_coeff = 14'd5007; b_coeff = 14'd453; end
            7'd41: begin a_coeff = 14'd5255; b_coeff = 14'd464; end
            7'd42: begin a_coeff = 14'd5509; b_coeff = 14'd475; end
            7'd43: begin a_coeff = 14'd5769; b_coeff = 14'd486; end
            7'd44: begin a_coeff = 14'd6035; b_coeff = 14'd497; end
            7'd45: begin a_coeff = 14'd6307; b_coeff = 14'd508; end
            7'd46: begin a_coeff = 14'd6585; b_coeff = 14'd519; end
            7'd47: begin a_coeff = 14'd6869; b_coeff = 14'd530; end
            7'd48: begin a_coeff = 14'd7159; b_coeff = 14'd541; end
            7'd49: begin a_coeff = 14'd7455; b_coeff = 14'd552; end
            7'd50: begin a_coeff = 14'd7757; b_coeff = 14'd563; end
            7'd51: begin a_coeff = 14'd8065; b_coeff = 14'd574; end
            7'd52: begin a_coeff = 14'd8379; b_coeff = 14'd585; end
            7'd53: begin a_coeff = 14'd8699; b_coeff = 14'd596; end
            7'd54: begin a_coeff = 14'd9025; b_coeff = 14'd607; end
            7'd55: begin a_coeff = 14'd9357; b_coeff = 14'd618; end
            7'd56: begin a_coeff = 14'd9695; b_coeff = 14'd629; end
            7'd57: begin a_coeff = 14'd10039; b_coeff = 14'd640; end
            7'd58: begin a_coeff = 14'd10389; b_coeff = 14'd651; end
            7'd59: begin a_coeff = 14'd10745; b_coeff = 14'd662; end
            7'd60: begin a_coeff = 14'd11107; b_coeff = 14'd673; end
            7'd61: begin a_coeff = 14'd11475; b_coeff = 14'd684; end
            7'd62: begin a_coeff = 14'd11849; b_coeff = 14'd695; end
            7'd63: begin a_coeff = 14'd12229; b_coeff = 14'd706; end
            7'd64: begin a_coeff = 14'd326; b_coeff = 14'd717; end
            7'd65: begin a_coeff = 14'd718; b_coeff = 14'd728; end
            7'd66: begin a_coeff = 14'd1116; b_coeff = 14'd739; end
            7'd67: begin a_coeff = 14'd1520; b_coeff = 14'd750; end
            7'd68: begin a_coeff = 14'd1930; b_coeff = 14'd761; end
            7'd69: begin a_coeff = 14'd2346; b_coeff = 14'd772; end
            7'd70: begin a_coeff = 14'd2768; b_coeff = 14'd783; end
            7'd71: begin a_coeff = 14'd3196; b_coeff = 14'd794; end
            7'd72: begin a_coeff = 14'd3630; b_coeff = 14'd805; end
            7'd73: begin a_coeff = 14'd4070; b_coeff = 14'd816; end
            7'd74: begin a_coeff = 14'd4516; b_coeff = 14'd827; end
            7'd75: begin a_coeff = 14'd4968; b_coeff = 14'd838; end
            7'd76: begin a_coeff = 14'd5426; b_coeff = 14'd849; end
            7'd77: begin a_coeff = 14'd5890; b_coeff = 14'd860; end
            7'd78: begin a_coeff = 14'd6360; b_coeff = 14'd871; end
            7'd79: begin a_coeff = 14'd6836; b_coeff = 14'd882; end
            7'd80: begin a_coeff = 14'd7318; b_coeff = 14'd893; end
            7'd81: begin a_coeff = 14'd7806; b_coeff = 14'd904; end
            7'd82: begin a_coeff = 14'd8300; b_coeff = 14'd915; end
            7'd83: begin a_coeff = 14'd8800; b_coeff = 14'd926; end
            7'd84: begin a_coeff = 14'd9306; b_coeff = 14'd937; end
            7'd85: begin a_coeff = 14'd9818; b_coeff = 14'd948; end
            7'd86: begin a_coeff = 14'd10336; b_coeff = 14'd959; end
            7'd87: begin a_coeff = 14'd10860; b_coeff = 14'd970; end
            7'd88: begin a_coeff = 14'd11390; b_coeff = 14'd981; end
            7'd89: begin a_coeff = 14'd11926; b_coeff = 14'd992; end
            7'd90: begin a_coeff = 14'd179; b_coeff = 14'd1003; end
            7'd91: begin a_coeff = 14'd727; b_coeff = 14'd1014; end
            7'd92: begin a_coeff = 14'd1281; b_coeff = 14'd1025; end
            7'd93: begin a_coeff = 14'd1841; b_coeff = 14'd1036; end
            7'd94: begin a_coeff = 14'd2407; b_coeff = 14'd1047; end
            7'd95: begin a_coeff = 14'd2979; b_coeff = 14'd1058; end
            7'd96: begin a_coeff = 14'd3557; b_coeff = 14'd1069; end
            7'd97: begin a_coeff = 14'd4141; b_coeff = 14'd1080; end
            7'd98: begin a_coeff = 14'd4731; b_coeff = 14'd1091; end
            7'd99: begin a_coeff = 14'd5327; b_coeff = 14'd1102; end
            7'd100: begin a_coeff = 14'd5929; b_coeff = 14'd1113; end
            7'd101: begin a_coeff = 14'd6537; b_coeff = 14'd1124; end
            7'd102: begin a_coeff = 14'd7151; b_coeff = 14'd1135; end
            7'd103: begin a_coeff = 14'd7771; b_coeff = 14'd1146; end
            7'd104: begin a_coeff = 14'd8397; b_coeff = 14'd1157; end
            7'd105: begin a_coeff = 14'd9029; b_coeff = 14'd1168; end
            7'd106: begin a_coeff = 14'd9667; b_coeff = 14'd1179; end
            7'd107: begin a_coeff = 14'd10311; b_coeff = 14'd1190; end
            7'd108: begin a_coeff = 14'd10961; b_coeff = 14'd1201; end
            7'd109: begin a_coeff = 14'd11617; b_coeff = 14'd1212; end
            7'd110: begin a_coeff = 14'd12279; b_coeff = 14'd1223; end
            7'd111: begin a_coeff = 14'd658; b_coeff = 14'd1234; end
            7'd112: begin a_coeff = 14'd1332; b_coeff = 14'd1245; end
            7'd113: begin a_coeff = 14'd2012; b_coeff = 14'd1256; end
            7'd114: begin a_coeff = 14'd2698; b_coeff = 14'd1267; end
            7'd115: begin a_coeff = 14'd3390; b_coeff = 14'd1278; end
            7'd116: begin a_coeff = 14'd4088; b_coeff = 14'd1289; end
            7'd117: begin a_coeff = 14'd4792; b_coeff = 14'd1300; end
            7'd118: begin a_coeff = 14'd5502; b_coeff = 14'd1311; end
            7'd119: begin a_coeff = 14'd6218; b_coeff = 14'd1322; end
            7'd120: begin a_coeff = 14'd6940; b_coeff = 14'd1333; end
            7'd121: begin a_coeff = 14'd7668; b_coeff = 14'd1344; end
            7'd122: begin a_coeff = 14'd8402; b_coeff = 14'd1355; end
            7'd123: begin a_coeff = 14'd9142; b_coeff = 14'd1366; end
            7'd124: begin a_coeff = 14'd9888; b_coeff = 14'd1377; end
            7'd125: begin a_coeff = 14'd10640; b_coeff = 14'd1388; end
            7'd126: begin a_coeff = 14'd11398; b_coeff = 14'd1399; end
            7'd127: begin a_coeff = 14'd12162; b_coeff = 14'd1410; end
            default: begin a_coeff = 14'd0; b_coeff = 14'd0; end
        endcase
    end
endmodule
