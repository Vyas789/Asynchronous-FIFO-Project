class async_fifo_rd_seq_item extends uvm_sequence_item;
    // Control signals (randomizable)
    rand bit rinc;
    rand bit rrst_n;        
    logic [`WIDTH-1:0] rdata;     
    bit rempty;                  
    
    
    // UVM automation macros
    `uvm_object_utils_begin(async_fifo_rd_seq_item)
        `uvm_field_int(rinc, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(rempty, UVM_ALL_ON)
        `uvm_field_int(rrst_n, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "async_fifo_rd_seq_item");
        super.new(name);
    endfunction
    
endclass
