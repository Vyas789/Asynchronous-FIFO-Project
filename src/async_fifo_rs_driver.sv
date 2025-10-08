class async_fifo_rd_driver extends uvm_driver#(async_fifo_rd_seq_item);
    `uvm_component_utils(async_fifo_rd_driver)
    
    virtual async_fifo_intf vif;
    
    function new(string name = "async_fifo_rd_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual async_fifo_intf)::get(this, "", "vif", vif)) begin
            `uvm_error(get_type_name(), "Failed to get virtual interface handle from config_db")
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
		vif.read_drv_cb.rrst_n <= 1'b1;
        vif.read_drv_cb.rinc <= 1'b0;
        
        forever begin
            async_fifo_rd_seq_item req;
            
            // Get next transaction from sequencer
            seq_item_port.get_next_item(req);
            
            // Drive the transaction
            drive_item(req);
            
            // Signal completion to sequencer
            seq_item_port.item_done();
        end
    endtask
    
    task drive_item(async_fifo_rd_seq_item req);
        
        @(vif.read_drv_cb);
        
        if(!req.rrst_n) begin
            vif.read_drv_cb.rrst_n <= 1'b0;
            vif.read_drv_cb.rinc <= 1'b0;
            
            `uvm_info(get_type_name(), 
                      $sformatf("READ RESET @%0t: rrst_n=%0b", $time, req.rrst_n), 
                      UVM_MEDIUM)
            
        end else begin
            vif.read_drv_cb.rrst_n <= 1'b1;
            
            if(req.rinc) begin
//                 if(vif.read_drv_cb.rempty) begin
//                     vif.read_drv_cb.rinc <= 1'b0;
                    
//                     `uvm_warning(get_type_name(), 
//                                 $sformatf("FIFO EMPTY @%0t: Cannot read data", $time))
                    
//                 end else begin
                     vif.read_drv_cb.rinc <= 1'b1;
                    
                    `uvm_info(get_type_name(), 
                             $sformatf("READ REQUEST @%0t: rinc=%0b", 
                                      $time, req.rinc), 
                             UVM_MEDIUM)
                    
                   @(vif.read_drv_cb);
                    
                    // Deassert read enable
                    vif.read_drv_cb.rinc <= 1'b0;
                    
                    `uvm_info(get_type_name(), 
                             $sformatf("READ COMPLETED @%0t", $time), 
                             UVM_MEDIUM)
                    
                    return;
              //  end
                
            end else begin
                vif.read_drv_cb.rinc <= 1'b0;
                
                `uvm_info(get_type_name(), 
                         $sformatf("READ IDLE @%0t: rinc=%0b", $time, req.rinc), 
                         UVM_MEDIUM)
            end
        end
        
        @(vif.read_drv_cb);
        vif.read_drv_cb.rinc <= 1'b0;
        
    endtask
    
endclass

