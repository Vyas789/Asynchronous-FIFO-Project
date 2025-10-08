class async_fifo_wr_driver extends uvm_driver#(async_fifo_wr_seq_item);
`uvm_component_utils(async_fifo_wr_driver)

	virtual async_fifo_intf vif;

	function new(string name = "async_fifo_wr_driver", uvm_component parent = null);
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

	vif.write_drv_cb.wrst_n <= 1'b1;
	vif.write_drv_cb.winc <= 1'b0;
	vif.write_drv_cb.wdata <= '0;

	forever begin
	async_fifo_wr_seq_item req;

	seq_item_port.get_next_item(req);

	drive_item(req);

	seq_item_port.item_done();
	end
	endtask

	task drive_item(async_fifo_wr_seq_item req);

	@(vif.write_drv_cb);

if(!req.wrst_n) 
	begin
	vif.write_drv_cb.wrst_n <= 1'b0;
	vif.write_drv_cb.winc <= 1'b0;
	vif.write_drv_cb.wdata <= '0;

	`uvm_info(get_type_name(), 
			$sformatf("WRITE RESET @%0t: wrst_n=%0b", $time, req.wrst_n), 
			UVM_MEDIUM)
	end 
	else 
	begin
      vif.write_drv_cb.wrst_n <= 1'b1;
if(req.winc) 
	begin
// if(vif.write_drv_cb.wfull) 
// 	begin
// 	vif.write_drv_cb.winc <= 1'b0;
// 	vif.write_drv_cb.wdata <= '0;
// 	`uvm_warning(get_type_name(), 
// 			$sformatf("FIFO FULL @%0t: Cannot write data=0x%0h", 
// 				$time, req.wdata))
// 	end 
// 	else 
// 	begin
	vif.write_drv_cb.winc <= 1'b1;
	vif.write_drv_cb.wdata <= req.wdata;
	`uvm_info(get_type_name(), 
			$sformatf("WRITE COMPLETED @%0t: winc=%0b, wdata=0x%0h", 
				$time, req.winc, req.wdata), 
			UVM_MEDIUM)
	//end
	end
	else 
	begin
	vif.write_drv_cb.winc <= 1'b0;
	vif.write_drv_cb.wdata <= '0;
	`uvm_info(get_type_name(), 
			$sformatf("WRITE IDLE @%0t: winc=%0b", $time, req.winc), 
			UVM_MEDIUM)
	end
	end
	@(vif.write_drv_cb);
	vif.write_drv_cb.winc <= 1'b0;
	endtask
	endclass
