class async_fifo_wr_agent extends uvm_agent;
    `uvm_component_utils(async_fifo_wr_agent)
    
    // Agent components
    async_fifo_wr_driver wr_drv;
    async_fifo_wr_monitor wr_mon;
    async_fifo_wr_sequencer wr_seqr;
    
    // Constructor
    function new(string name = "async_fifo_wr_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        wr_drv = async_fifo_wr_driver::type_id::create("wr_drv", this);
        wr_mon = async_fifo_wr_monitor::type_id::create("wr_mon", this);
        wr_seqr = async_fifo_wr_sequencer::type_id::create("wr_seqr", this);
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        wr_drv.seq_item_port.connect(wr_seqr.seq_item_export);
    endfunction
    
endclass
