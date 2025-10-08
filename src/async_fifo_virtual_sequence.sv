class async_fifo_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(async_fifo_virtual_sequence)
		`uvm_declare_p_sequencer(async_fifo_virtual_sequencer)
    
    async_fifo_wr_sequence wr_seq;
    async_fifo_rd_sequence rd_seq;
    
    async_fifo_env env;
    
    function new(string name = "async_fifo_virtual_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        `uvm_info(get_type_name(), "Starting Virtual Sequence", UVM_LOW)
        
        wr_seq = async_fifo_wr_sequence::type_id::create("wr_seq");
        rd_seq = async_fifo_rd_sequence::type_id::create("rd_seq");
        
        fork
            begin
                `uvm_info(get_type_name(), "Starting write virtual sequence", UVM_MEDIUM)
                wr_seq.start(p_sequencer.wr_seqr);
            end
            begin
                `uvm_info(get_type_name(), "Starting read virtual sequence", UVM_MEDIUM)
                rd_seq.start(p_sequencer.rd_seqr);
            end
        join
        
        `uvm_info(get_type_name(), "Virtual Sequence Completed", UVM_LOW)
    endtask
    
endclass
