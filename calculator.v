`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 02:08:03 PM
// Design Name: 
// Module Name: calculator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module calculator (
    input [3:0] A,        // First 4-bit number
    input [3:0] B,        // Second 4-bit number
    input [2:0] op,       // Operation selector
    input clk, reset,            // Clock for multiplexing
    output reg [6:0] seg, // Shared 7-segment display pins
    output reg [3:0] digit_select // Control signal for which digit to enable
);
    reg [7:0] result_bin;    // 8-bit result to handle operations
    reg [3:0] current_digit; // Holds the current digit to display
    reg [15:0] counter;      // Counter for multiplexing timing

    // Operation logic
    always @(*) begin
        case (op)
            3'b000: result_bin = A + B;             // Addition
            3'b001: result_bin = A - B;             // Subtraction
            3'b010: result_bin = A * B;             // Multiplication
            3'b011: result_bin = (B != 0) ? A / B : 8'b00000000; // Division
            3'b100: result_bin = {4'b0000, A & B};  // AND
            3'b101: result_bin = {4'b0000, A | B};  // OR
            3'b110: result_bin = {4'b0000, A ^ B};  // XOR
            3'b111: result_bin = {4'b0000, ~A};     // NOT
            default: result_bin = 8'b00000000;
        endcase
    end

    // Multiplexing logic with faster timing
    always @(posedge clk) begin
        counter <= counter + 1;
        if (counter == 16'h61A8) begin // Use a smaller value for quicker switching
            digit_select[1:0] <= ~digit_select[1:0]; // Toggle between digits
            counter <= 16'd0;
        end
    end

    // Initialize signals when reset is asserted
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 16'd0;
            digit_select <= 4'b1110; // Show the lower nibble first
        end
    end

    // Determine which digit to display
    always @(*) begin
        if (digit_select == 4'b1110) begin
            current_digit = result_bin[3:0]; // Lower nibble
        end else begin
            current_digit = result_bin[7:4]; // Upper nibble
        end
    end

    // Seven-segment decoder
    always @(*) begin
        case (current_digit)
            4'b0000: seg = 7'b1000000; // 0
            4'b0001: seg = 7'b1111001; // 1
            4'b0010: seg = 7'b0100100; // 2
            4'b0011: seg = 7'b0110000; // 3
            4'b0100: seg = 7'b0011001; // 4
            4'b0101: seg = 7'b0010010; // 5
            4'b0110: seg = 7'b0000010; // 6
            4'b0111: seg = 7'b1111000; // 7
            4'b1000: seg = 7'b0000000; // 8
            4'b1001: seg = 7'b0010000; // 9
            4'b1010: seg = 7'b0001000; // A
            4'b1011: seg = 7'b0000011; // B
            4'b1100: seg = 7'b1000110; // C
            4'b1101: seg = 7'b0100001; // D
            4'b1110: seg = 7'b0000110; // E
            4'b1111: seg = 7'b0001110; // F
            default: seg = 7'b1111111; // Blank display
        endcase
    end
endmodule

