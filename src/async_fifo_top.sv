
`include "defines.svh"
`include "async_fifo_intf.sv"
`include "async_fifo_pkg.svh"
`include "design.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"
import async_fifo_pkg::*;

module top();
    bit wclk;
    bit rclk;
    async_fifo_intf vif(wclk, rclk);

    FIFO  DUT (
        .wclk(vif.wclk),
        .rclk(vif.rclk),
        .wrst_n(vif.wrst_n),
        .rrst_n(vif.rrst_n),
        .winc(vif.winc),
        .rinc(vif.rinc),
        .wdata(vif.wdata),
        .rdata(vif.rdata),
        .wfull(vif.wfull),
        .rempty(vif.rempty)
    );
    
    initial begin
        wclk = 0;
        forever #5ns wclk = ~wclk;
    end
    
    initial begin
        rclk = 0;
        forever #10ns rclk = ~rclk;
    end
    
    // Initial block for simulation setup
    initial begin
        uvm_config_db#(virtual async_fifo_intf)::set(null, "*", "vif", vif);
        $dumpfile("async_fifo_dump.vcd");
      $dumpvars(0,top);
        run_test("async_fifo_test");
	#30ns;
	$finish;
    end
    
endmodule
