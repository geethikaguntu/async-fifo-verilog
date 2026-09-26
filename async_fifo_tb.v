module async_fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;

    reg wr_clk;
    reg rd_clk;
    reg rst_n;

    reg wr_en;
    reg [DATA_WIDTH-1:0] din;

    reg rd_en;
    wire [DATA_WIDTH-1:0] dout;

    wire full;
    wire empty;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .din(din),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;
    end

    initial begin
        rd_clk = 0;
        forever #7 rd_clk = ~rd_clk;
    end

    initial begin
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        #20;
        rst_n = 1;
    end

    integer write_idx;

    initial begin
        wait(rst_n == 1);

        for (write_idx = 0; write_idx < 32; write_idx = write_idx + 1) begin

            while (full)
                @(negedge wr_clk);

            @(negedge wr_clk);

            wr_en = 1;
            din = write_idx;

            @(negedge wr_clk);

            wr_en = 0;
        end
    end

    integer read_idx;
    integer expected;
    integer errors;

    initial begin
        expected = 0;
        errors = 0;

        wait(rst_n == 1);

        for (read_idx = 0; read_idx < 32; read_idx = read_idx + 1) begin

            while (empty)
                @(negedge rd_clk);

            @(negedge rd_clk);

            rd_en = 1;

            @(posedge rd_clk);

            #1;

            if (dout !== expected) begin
                $display(
                    "ERROR: Expected %0d, Got %0d at time %0t",
                    expected, dout, $time
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: Expected %0d, Got %0d at time %0t",
                    expected, dout, $time
                );
            end

            expected = expected + 1;

            @(negedge rd_clk);

            rd_en = 0;
        end

        #20;

        if (errors == 0)
            $display("ASYNC FIFO TEST PASSED");
        else
            $display("ASYNC FIFO TEST FAILED: %0d errors", errors);

        $finish;
    end
    initial begin
        $dumpfile("async_fifo.vcd");
        $dumpvars(0, async_fifo_tb);
    end

endmodule
