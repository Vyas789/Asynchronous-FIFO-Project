class async_fifo_rd_agent extends uvm_agent;
    `uvm_component_utils(async_fifo_rd_agent)
    
    // Agent components
    async_fifo_rd_driver rd_drv;
    async_fifo_rd_monitor rd_mon;
    async_fifo_rd_sequencer rd_seqr;
    
    // Constructor
    function new(string name = "async_fifo_rd_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        rd_drv = async_fifo_rd_driver::type_id::create("rd_drv", this);
        rd_mon = async_fifo_rd_monitor::type_id::create("rd_mon", this);
        rd_seqr = async_fifo_rd_sequencer::type_id::create("rd_seqr", this);
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        rd_drv.seq_item_port.connect(rd_seqr.seq_item_export);
    endfunction
    
endclass
