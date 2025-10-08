class async_fifo_wr_monitor extends uvm_monitor;
    `uvm_component_utils(async_fifo_wr_monitor)
    
    virtual async_fifo_intf vif;
    
    uvm_analysis_port #(async_fifo_wr_seq_item) write_port;
    
    function new(string name = "async_fifo_wr_monitor", uvm_component parent = null);
        super.new(name, parent);
        write_port = new("write_port", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual async_fifo_intf)::get(this, "", "vif", vif)) begin
            `uvm_error(get_type_name(), "Failed to get virtual interface handle from config_db")
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            async_fifo_wr_seq_item write_trans;
            
            
           repeat(2) @(vif.write_mon_cb);
            write_trans = async_fifo_wr_seq_item::type_id::create("write_trans");
            
            write_trans.wrst_n = vif.write_mon_cb.wrst_n;
            write_trans.winc = vif.write_mon_cb.winc;
            write_trans.wdata = vif.write_mon_cb.wdata;
            write_trans.wfull = vif.write_mon_cb.wfull;
            
            `uvm_info(get_type_name(), 
                      $sformatf("Write Monitor @%0t: wrst_n=%0b, winc=%0b, wdata=0x%0h, wfull=%0b", 
                               $time, write_trans.wrst_n, write_trans.winc, 
                               write_trans.wdata, write_trans.wfull), 
                      UVM_MEDIUM)
            
            write_port.write(write_trans);
        end
    endtask
    
endclass
