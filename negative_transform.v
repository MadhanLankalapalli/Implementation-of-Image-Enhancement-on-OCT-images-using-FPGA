`timescale 1ps / 1ps

module negative_transform #(parameter DATA_WIDTH = 8) (
    input clk,
    input reset,
    input [DATA_WIDTH-1:0] pixel_in,   // Input pixel value
    input pixel_valid,                 // Valid input signal
    output reg [DATA_WIDTH-1:0] pixel_out, // Transformed output pixel value
    output reg pixel_ready,            // Ready signal
    output reg [6:0] seg,              // Seven-segment display segments
    output reg [7:0] an                // Seven-segment display anode control
);

    // Internal signals
    reg [3:0] current_digit;           // Current nibble to display
    reg [2:0] digit_index;             // Current anode index (which display to activate)
    reg display_state;                 // 0: Show input, 1: Show transformed output

    // Negative transformation logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_out <= 0;
            pixel_ready <= 0;
            display_state <= 0;        // Start with showing input
        end else if (pixel_valid) begin
            pixel_out <= 255 - pixel_in;  // Apply negative transformation
            pixel_ready <= 1;
            display_state <= ~display_state; // Toggle between input and output display
        end else begin
            pixel_ready <= 0;          // Indicate not ready when no valid input
        end
    end

    // Seven-segment display driver
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            seg <= 7'b1111111;         // Turn off all segments
            an <= 8'b11111110;         // Activate first anode
            digit_index <= 0;          // Start with the first digit
        end else begin
            // Determine which digit to display based on display_state
            case (digit_index)
                0: current_digit <= (display_state == 0) ? pixel_in[3:0]  : pixel_out[3:0];   // Lower nibble
                1: current_digit <= (display_state == 0) ? pixel_in[7:4]  : pixel_out[7:4];   // Upper nibble
                default: current_digit <= 4'h0; // Default to zero
            endcase

            // Display the current digit on the seven-segment display
            case (current_digit)
                4'h0: seg <= 7'b1000000;  // 0
                4'h1: seg <= 7'b1111001;  // 1
                4'h2: seg <= 7'b0100100;  // 2
                4'h3: seg <= 7'b0110000;  // 3
                4'h4: seg <= 7'b0011001;  // 4
                4'h5: seg <= 7'b0010010;  // 5
                4'h6: seg <= 7'b0000010;  // 6
                4'h7: seg <= 7'b1111000;  // 7
                4'h8: seg <= 7'b0000000;  // 8
                4'h9: seg <= 7'b0010000;  // 9
                4'hA: seg <= 7'b0001000;  // A
                4'hB: seg <= 7'b0000011;  // B
                4'hC: seg <= 7'b1000110;  // C
                4'hD: seg <= 7'b0100001;  // D
                4'hE: seg <= 7'b0000110;  // E
                4'hF: seg <= 7'b0001110;  // F
                default: seg <= 7'b1111111;  // Blank display for invalid values
            endcase

            // Activate the corresponding anode for the digit
            case (digit_index)
                0: an <= 8'b11111110;  // Activate the first anode
                1: an <= 8'b11111101;  // Activate the second anode
                default: an <= 8'b11111111;  // Turn off all anodes
            endcase

            // Increment the digit index to cycle through digits
            digit_index <= digit_index + 1;
        end
    end

endmodule
