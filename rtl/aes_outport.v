/* This is the output part of the interface. */

module aes_outport(
	clk,rst,
	pass_data,aes_en,div_bits,
	out_data,out_valid);

// basic input
input clk,rst;

// about control
input[3:0] div_bits;

// about data input
input [31:0] pass_data;
input aes_en;
reg [1:0] pass_count;

// about data output
output wire [7:0] out_data;
output wire out_valid;   //shakehand
reg [7:0] out;
reg valid;
assign out_data = out;
assign out_valid = valid;

// store data
reg [127:0] out_mem;

// reg of logic of the control of output
reg [19:0] clk_count;

always@(posedge clk or negedge rst) begin // data input
if(!rst) begin
pass_count <= 'd0;
clk_count <= 'd0;
out_mem <= 128'h00000000_00000000_00000000_00000000;
end
else begin
clk_count <= |clk_count ? clk_count - 1'b1 : 'd0 ;
if(aes_en) begin
	case(pass_count) 
	2'd0: begin out_mem[127:96] <= pass_data[31:0]; pass_count <= 2'd1; clk_count[div_bits + 'd4] <= 1'b1; end // clk_count <= 1'b1 << (div_bits + 4); end
	2'd1: begin out_mem[ 95:64] <= pass_data[31:0]; pass_count <= 2'd2; end
	2'd2: begin out_mem[ 63:32] <= pass_data[31:0]; pass_count <= 2'd3; end
	2'd3: begin out_mem[ 31: 0] <= pass_data[31:0]; pass_count <= 2'd0; end
	default: begin out_mem <= 'd0; pass_count <= 'd0; end
	endcase
	end
end //biggest else begin
end //always begin

always @(posedge clk or negedge rst) begin
if(!rst) begin
out <= 'd0;
valid <= 'd0;
end
else begin
case({clk_count[div_bits+3],clk_count[div_bits+2],clk_count[div_bits+1],clk_count[div_bits]})
4'b1111: begin out <= out_mem[127:120]; end
4'b1110: begin out <= out_mem[119:112]; end
4'b1101: begin out <= out_mem[111:104]; end
4'b1100: begin out <= out_mem[103: 96]; end
4'b1011: begin out <= out_mem[ 95: 88]; end
4'b1010: begin out <= out_mem[ 87: 80]; end
4'b1001: begin out <= out_mem[ 79: 72]; end
4'b1000: begin out <= out_mem[ 71: 64]; end
4'b0111: begin out <= out_mem[ 63: 56]; end
4'b0110: begin out <= out_mem[ 55: 48]; end
4'b0101: begin out <= out_mem[ 47: 40]; end
4'b0100: begin out <= out_mem[ 39: 32]; end
4'b0011: begin out <= out_mem[ 31: 24]; end
4'b0010: begin out <= out_mem[ 23: 16]; end
4'b0001: begin out <= out_mem[ 15:  8]; end
4'b0000: begin out <= out_mem[  7:  0]; end
default: begin  end
endcase
valid <= clk_count[div_bits-1];
end // end of biggest else
end // end of always

endmodule