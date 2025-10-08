class async_fifo_rd_monitor extends uvm_monitor;
    `uvm_component_utils(async_fifo_rd_monitor)
    
    virtual async_fifo_intf vif;
    
    uvm_analysis_port #(async_fifo_rd_seq_item) read_port;
    
    function new(string name = "async_fifo_rd_monitor", uvm_component parent = null);
        super.new(name, parent);
        read_port = new("read_port", this);
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
            async_fifo_rd_seq_item read_trans;
            
          repeat(2)@(vif.read_mon_cb);
            
            read_trans = async_fifo_rd_seq_item::type_id::create("read_trans");
            
            read_trans.rrst_n = vif.read_mon_cb.rrst_n;
            read_trans.rinc = vif.read_mon_cb.rinc;
            read_trans.rdata = vif.read_mon_cb.rdata;
            read_trans.rempty = vif.read_mon_cb.rempty;
            
            `uvm_info(get_type_name(), 
                      $sformatf("Read Monitor @%0t: rrst_n=%0b, rinc=%0b, rdata=0x%0h, rempty=%0b", 
                               $time, read_trans.rrst_n, read_trans.rinc, 
                               read_trans.rdata, read_trans.rempty), 
                      UVM_MEDIUM)
            
            read_port.write(read_trans);
        end
    endtask
    
endclass
