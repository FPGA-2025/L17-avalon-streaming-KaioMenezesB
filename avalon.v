module avalon (
    input wire clk,
    input wire resetn,
    output reg valid,
    input wire ready,
    output reg [7:0] data
);

    parameter wait_fsm = 3'd0,
              delay_cycle = 3'd1,
              send4 = 3'd2,
              send5 = 3'd3,
              send6 = 3'd4,
              finished = 3'd5;

    reg [2:0] state, next_state;

    always @(posedge clk or posedge resetn) begin
        if (resetn)
            state <= wait_fsm;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            wait_fsm: next_state = (ready ? delay_cycle : wait_fsm);
            delay_cycle: next_state = send4;
            send4: next_state = (ready ? send5    : send4);
            send5: next_state = (ready ? send6    : send5);
            send6: next_state = (ready ? finished : send6);
            finished: next_state = finished;
            default: next_state = wait_fsm;
        endcase
    end

    always @(posedge clk or posedge resetn) begin
        if (resetn) begin
            valid <= 1'b0;
            data  <= 8'd0;
        end else begin
            case (state)
                send4: begin valid <= 1'b1; data <= 8'd4; end
                send5: begin valid <= 1'b1; data <= 8'd5; end
                send6: begin valid <= 1'b1; data <= 8'd6; end
                default: begin valid <= 1'b0; data <= 8'd0; end
            endcase
        end
    end
endmodule

