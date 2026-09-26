module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input  wire                  wr_clk,
    input  wire                  rd_clk,
    input  wire                  rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire                  full,
    output wire                  empty
);

    localparam DEPTH = (1 << ADDR_WIDTH);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH:0] wr_ptr_bin;
    reg [ADDR_WIDTH:0] rd_ptr_bin;

    reg [ADDR_WIDTH:0] wr_ptr_gray;
    reg [ADDR_WIDTH:0] rd_ptr_gray;

    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync2;

    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync2;

    wire [ADDR_WIDTH:0] wr_ptr_bin_next;
    wire [ADDR_WIDTH:0] rd_ptr_bin_next;

    wire [ADDR_WIDTH:0] wr_ptr_gray_next;
    wire [ADDR_WIDTH:0] rd_ptr_gray_next;

    reg full_reg;
    reg empty_reg;

    assign full = full_reg;
    assign empty = empty_reg;

    assign wr_ptr_bin_next =
        wr_ptr_bin + ((wr_en && !full) ? 1'b1 : 1'b0);

    assign wr_ptr_gray_next =
        (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next;

    assign rd_ptr_bin_next =
        rd_ptr_bin + ((rd_en && !empty) ? 1'b1 : 1'b0);

    assign rd_ptr_gray_next =
        (rd_ptr_bin_next >> 1) ^ rd_ptr_bin_next;

    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;
            full_reg    <= 1'b0;
        end
        else begin
            if (wr_en && !full)
                mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= din;

            wr_ptr_bin  <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;

            full_reg <=
                (wr_ptr_gray_next ==
                {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
                  rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});
        end
    end

    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
            empty_reg   <= 1'b1;
            dout        <= 0;
        end
        else begin
            if (rd_en && !empty)
                dout <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

            rd_ptr_bin  <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;

            empty_reg <=
                (rd_ptr_gray_next == wr_ptr_gray_sync2);
        end
    end

    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end
        else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end
        else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

endmodule