class async_fifo_wr_seq_item extends uvm_sequence_item;
    // Control signals (randomizable)
    rand bit winc;
    rand logic [`WIDTH-1:0] wdata;
    rand bit wrst_n;      
    bit wfull;    
    
    `uvm_object_utils_begin(async_fifo_wr_seq_item)
        `uvm_field_int(winc, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(wrst_n, UVM_ALL_ON)
        `uvm_field_int(wfull, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "async_fifo_wr_seq_item");
        super.new(name);
    endfunction
    
endclass
