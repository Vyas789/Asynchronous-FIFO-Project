class async_fifo_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(async_fifo_virtual_sequencer)
    
    // Handles to actual sequencers
    async_fifo_wr_sequencer wr_seqr;
    async_fifo_rd_sequencer rd_seqr;
    
    // Constructor
    function new(string name = "async_fifo_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass
