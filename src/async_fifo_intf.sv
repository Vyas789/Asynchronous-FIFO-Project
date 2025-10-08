`include "defines.svh"

interface async_fifo_intf(input bit wclk, rclk);
    bit wrst_n, rrst_n;
    bit winc, rinc;
    logic [`WIDTH-1:0] wdata;
    bit wfull, rempty;
    logic [`WIDTH-1:0] rdata;
    
    // Write domain clocking block for driver
    clocking write_drv_cb @(posedge wclk);
        default input #0ns output #0ns;
        output wrst_n, winc, wdata;
        input wfull;
    endclocking
    
    // Write domain clocking block for monitor
    clocking write_mon_cb @(posedge wclk);
        default input #0ns output #0ns;
        input winc, wdata, wfull, wrst_n;
    endclocking 
    
    // Read domain clocking block for driver
    clocking read_drv_cb @(posedge rclk);
        default input #0ns output #0ns;
        output rrst_n, rinc;
        input rempty;
    endclocking 
    
    // Read domain clocking block for monitor
    clocking read_mon_cb @(posedge rclk);
        default input #0ns output #0ns;
        input rinc, rdata, rempty, rrst_n;
    endclocking
    
    // Modports for testbench components
    modport write_driver(clocking write_drv_cb);
    modport write_monitor(clocking write_mon_cb);
    modport read_driver(clocking read_drv_cb);
    modport read_monitor(clocking read_mon_cb);
    
    // Modport for DUT connection
    modport dut(
        input wclk, rclk, wrst_n, rrst_n, winc, rinc, wdata,
        output wfull, rempty, rdata
    );
      
      property p2;
    @(posedge wclk) disable iff(!wrst_n)
      (winc && wfull) |-> $stable(wdata);
  endproperty
  assert property(p2)
    else $error("p2 FAILED: Data changed during write when FULL!");

  property p3;
    @(posedge rclk) disable iff(!rrst_n)
      rinc |-> !rempty;
  endproperty
  assert property(p3)
    else $error("p3 FAILED: Read attempted when FIFO is EMPTY!");

  property p4;
    @(posedge rclk) disable iff(!rrst_n)
      (rinc && !rempty) |-> !$isunknown(rdata);
  endproperty
  assert property(p4)
    else $error("p4 FAILED: rdata is X/Z on valid read!");

  property p5;
    @(posedge wclk) disable iff(!wrst_n)
      !(wfull && rempty);
  endproperty
  assert property(p5)
    else $error("p5 FAILED: FIFO signaled FULL and EMPTY simultaneously!");

endinterface
