class async_fifo_env extends uvm_env;
    `uvm_component_utils(async_fifo_env)
    
    async_fifo_wr_agent wr_agent;
    async_fifo_rd_agent rd_agent;
    
    async_fifo_virtual_sequencer v_seqr;
    
    async_fifo_scoreboard scb;
    
    async_fifo_subscriber cov;
    
    function new(string name = "async_fifo_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        wr_agent = async_fifo_wr_agent::type_id::create("wr_agent", this);
        rd_agent = async_fifo_rd_agent::type_id::create("rd_agent", this);
        
        v_seqr = async_fifo_virtual_sequencer::type_id::create("v_seqr", this);
        
        scb = async_fifo_scoreboard::type_id::create("scb", this);
        
        cov = async_fifo_subscriber::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        v_seqr.wr_seqr = wr_agent.wr_seqr;
        v_seqr.rd_seqr = rd_agent.rd_seqr;
        
        wr_agent.wr_mon.write_port.connect(scb.write_export);
        rd_agent.rd_mon.read_port.connect(scb.read_export);
        
        wr_agent.wr_mon.write_port.connect(cov.write_export);
        rd_agent.rd_mon.read_port.connect(cov.read_export);
    endfunction
    
endclass
