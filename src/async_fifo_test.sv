class async_fifo_test extends uvm_test;
    `uvm_component_utils(async_fifo_test)
    
    async_fifo_env env;
    
    async_fifo_virtual_sequence v_seq;
    
    function new(string name = "async_fifo_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = async_fifo_env::type_id::create("env", this);
        `uvm_info(get_type_name(), "Build phase completed", UVM_LOW)
    endfunction
    
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this, "Starting async_fifo_test");
        v_seq = async_fifo_virtual_sequence::type_id::create("v_seq");
        `uvm_info(get_type_name(), "Starting virtual sequence", UVM_MEDIUM)
        v_seq.start(env.v_seqr);
        phase.drop_objection(this, "Finished async_fifo_test");
    endtask
    
endclass
