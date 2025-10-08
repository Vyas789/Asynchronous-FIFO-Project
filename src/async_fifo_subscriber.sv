`uvm_analysis_imp_decl(_write)
`uvm_analysis_imp_decl(_read)

class async_fifo_subscriber extends uvm_component;
    `uvm_component_utils(async_fifo_subscriber)
    
    uvm_analysis_imp_write#(async_fifo_wr_seq_item, async_fifo_subscriber) write_export;
    uvm_analysis_imp_read#(async_fifo_rd_seq_item, async_fifo_subscriber) read_export;
    
    async_fifo_wr_seq_item wr_trans;
    async_fifo_rd_seq_item rd_trans;
    
    covergroup write_cg;
        
        cp_wdata: coverpoint wr_trans.wdata {
            bins low = {[0:63]};
            bins mid = {[64:191]};
            bins high = {[192:255]};
        }
        
        cp_winc: coverpoint wr_trans.winc {
            bins write_enabled = {1};
            bins write_disabled = {0};
        }
        
        cp_wfull: coverpoint wr_trans.wfull {
            bins full = {1};
            bins not_full = {0};
        }
        
        cross_winc_wfull: cross cp_winc, cp_wfull;
        
    endgroup
    
    // Read side coverage
    covergroup read_cg;
        
        cp_rdata: coverpoint rd_trans.rdata {
            bins low = {[0:63]};
            bins mid = {[64:191]};
            bins high = {[192:255]};
        }
        
        cp_rinc: coverpoint rd_trans.rinc {
            bins read_enabled = {1};
            bins read_disabled = {0};
        }
        
        cp_rempty: coverpoint rd_trans.rempty {
            bins empty = {1};
            bins not_empty = {0};
        }
        
        cross_rinc_rempty: cross cp_rinc, cp_rempty;
        
    endgroup

    function new(string name = "async_fifo_subscriber", uvm_component parent = null);
        super.new(name, parent);
        write_cg = new();
        read_cg = new();
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        write_export = new("write_export", this);
        read_export = new("read_export", this);
    endfunction
    
    function void write_write(async_fifo_wr_seq_item t);
        wr_trans = t;
        write_cg.sample();
        `uvm_info(get_type_name(), "Write coverage sampled", UVM_HIGH)
    endfunction
    
    // Read function - called by read monitor
    function void write_read(async_fifo_rd_seq_item t);
        rd_trans = t;
        read_cg.sample();
        `uvm_info(get_type_name(), "Read coverage sampled", UVM_HIGH)
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "==========================================", UVM_LOW)
        `uvm_info(get_type_name(), "       COVERAGE REPORT                    ", UVM_LOW)
        `uvm_info(get_type_name(), "==========================================", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Write Coverage: %.2f%%", write_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Read Coverage : %.2f%%", read_cg.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), "==========================================", UVM_LOW)
    endfunction
    
endclass
