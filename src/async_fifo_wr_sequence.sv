
`include "defines.svh"
class async_fifo_wr_sequence extends uvm_sequence#(async_fifo_wr_seq_item);
    `uvm_object_utils(async_fifo_wr_sequence)
    
    
    function new(string name = "async_fifo_wr_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_wr_seq_item write_req;
        
        `uvm_info(get_type_name(), $sformatf("Starting write sequence"), UVM_MEDIUM)
        
            write_req = async_fifo_wr_seq_item::type_id::create("write_req");
       repeat(`no_of_trans) begin
            
            start_item(write_req);
            
         if (!write_req.randomize() with {write_req.wrst_n=='b1; write_req.winc=='b1;}) begin
                `uvm_error(get_type_name(), "Randomization failed for write_req")
            end
            
            `uvm_info(get_type_name(), $sformatf("Sending write transaction: winc=%0b, wdata=0x%0h", 
                      write_req.winc, write_req.wdata), UVM_MEDIUM)
            
            finish_item(write_req);
       end
        
        `uvm_info(get_type_name(), "Write sequence completed", UVM_MEDIUM)
    endtask
    
endclass

//=======================================================================//
//			Write FIFO Full Sequence - Writes beyond FIFO capacity
//=======================================================================//

class async_fifo_wr_full_sequence extends async_fifo_wr_sequence;
    `uvm_object_utils(async_fifo_wr_full_sequence)
    
    rand int extra_writes;
    
    constraint extra_writes_c {
        extra_writes inside {[3:10]};
    }
    
    function new(string name = "async_fifo_wr_full_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_wr_seq_item write_req;
        int total_writes;
        
        `uvm_info(get_type_name(), "Starting write full sequence", UVM_MEDIUM)
        
        total_writes = `WIDTH + extra_writes;
        write_req = async_fifo_wr_seq_item::type_id::create("write_req");
        
        repeat(total_writes) begin
            start_item(write_req);
            
            if (!write_req.randomize() with {write_req.wrst_n == 'b1; write_req.winc == 'b1;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            
            `uvm_info(get_type_name(), $sformatf("Write #%0d: wdata=0x%0h", 
                      total_writes, write_req.wdata), UVM_HIGH)
            
            finish_item(write_req);
        end
        
        `uvm_info(get_type_name(), $sformatf("Write full sequence completed - wrote %0d items", total_writes), UVM_MEDIUM)
    endtask
endclass

//=======================================================================
// Write No-Increment Sequence - Write pointer doesn't increment
//=======================================================================
class async_fifo_wr_no_inc_sequence extends async_fifo_wr_sequence;
    `uvm_object_utils(async_fifo_wr_no_inc_sequence)
    
    function new(string name = "async_fifo_wr_no_inc_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_wr_seq_item write_req;
        
        `uvm_info(get_type_name(), "Starting write no-increment sequence", UVM_MEDIUM)
        
        write_req = async_fifo_wr_seq_item::type_id::create("write_req");
        
        repeat(`no_of_trans) begin
            start_item(write_req);
            
            if (!write_req.randomize() with {write_req.wrst_n == 'b1; write_req.winc == 'b0;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            
            `uvm_info(get_type_name(), $sformatf("Write with no increment: wdata=0x%0h", 
                      write_req.wdata), UVM_HIGH)
            
            finish_item(write_req);
        end
        
        `uvm_info(get_type_name(), "Write no-increment sequence completed", UVM_MEDIUM)
    endtask
endclass

//============================================================================
// Write Reset Sequence
//============================================================================
class async_fifo_wr_reset_sequence extends async_fifo_wr_sequence;
    `uvm_object_utils(async_fifo_wr_reset_sequence)
    
    rand int reset_cycles;
    
    constraint reset_cycles_c {
        reset_cycles inside {[3:10]};
    }
    
    function new(string name = "async_fifo_wr_reset_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_wr_seq_item write_req;
        
        `uvm_info(get_type_name(), "Starting write reset sequence", UVM_MEDIUM)
        
        write_req = async_fifo_wr_seq_item::type_id::create("write_req");
        
        // Assert reset
        start_item(write_req);
        if (!write_req.randomize() with {write_req.wrst_n == 'b0; write_req.winc == 'b0;}) begin
            `uvm_error(get_type_name(), "Randomization failed")
        end
        `uvm_info(get_type_name(), "Asserting write reset", UVM_MEDIUM)
        finish_item(write_req);
        
        // Hold reset for multiple cycles
        repeat(reset_cycles) begin
            start_item(write_req);
            if (!write_req.randomize() with {write_req.wrst_n == 'b0;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(write_req);
        end
        
        // Deassert reset
        start_item(write_req);
        if (!write_req.randomize() with {write_req.wrst_n == 'b1; write_req.winc == 'b0;}) begin
            `uvm_error(get_type_name(), "Randomization failed")
        end
        `uvm_info(get_type_name(), "De-asserting write reset", UVM_MEDIUM)
        finish_item(write_req);
        
        `uvm_info(get_type_name(), "Write reset sequence completed", UVM_MEDIUM)
    endtask
endclass

//============================================================================
// Write Burst Sequence - Continuous back-to-back writes
//===========================================================================
class async_fifo_wr_burst_sequence extends async_fifo_wr_sequence;
    `uvm_object_utils(async_fifo_wr_burst_sequence)
    
    rand int burst_size;
    
    constraint burst_size_c {
      burst_size inside {[`WIDTH/4 : `WIDTH/2]};
    }
    
    function new(string name = "async_fifo_wr_burst_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_wr_seq_item write_req;
        
        `uvm_info(get_type_name(), $sformatf("Starting write burst sequence - burst_size=%0d", burst_size), UVM_MEDIUM)
        
        write_req = async_fifo_wr_seq_item::type_id::create("write_req");
        
        repeat(burst_size) begin
            start_item(write_req);
            
            if (!write_req.randomize() with {write_req.wrst_n == 'b1; write_req.winc == 'b1;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            
            finish_item(write_req);
        end
        
        `uvm_info(get_type_name(), "Write burst sequence completed", UVM_MEDIUM)
    endtask
endclass

//============================================================================
// Write Random Sequence - Random winc pattern
//============================================================================
class async_fifo_wr_random_sequence extends uvm_sequence#(async_fifo_wr_seq_item);
    `uvm_object_utils(async_fifo_wr_random_sequence)
    
    rand int num_transactions;
    
    constraint num_trans_c {
        num_transactions inside {[50:100]};
    }
    
    function new(string name = "async_fifo_wr_random_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_wr_seq_item write_req;
        
        `uvm_info(get_type_name(), $sformatf("Starting write random sequence - %0d transactions", num_transactions), UVM_MEDIUM)
        
        write_req = async_fifo_wr_seq_item::type_id::create("write_req");
        
        repeat(num_transactions) begin
            start_item(write_req);
            
            // Fully random including winc
            if (!write_req.randomize() with {write_req.wrst_n == 'b1;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            
            `uvm_info(get_type_name(), $sformatf("Random write: winc=%0b, wdata=0x%0h", 
                      write_req.winc, write_req.wdata), UVM_HIGH)
            
            finish_item(write_req);
        end
        
        `uvm_info(get_type_name(), "Write random sequence completed", UVM_MEDIUM)
    endtask
endclass

