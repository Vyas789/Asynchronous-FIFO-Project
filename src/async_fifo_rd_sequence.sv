`include "defines.svh"
class async_fifo_rd_sequence extends uvm_sequence#(async_fifo_rd_seq_item);
    `uvm_object_utils(async_fifo_rd_sequence)
    
    
    function new(string name = "async_fifo_rd_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_rd_seq_item read_req;
        
        `uvm_info(get_type_name(), $sformatf("Starting read sequence"), UVM_MEDIUM)
        
         read_req = async_fifo_rd_seq_item::type_id::create("read_req");
        repeat(`no_of_trans) begin
            
            start_item(read_req);
            
          if (!read_req.randomize() with{read_req.rrst_n=='b1; read_req.rinc=='b1;}) begin
                `uvm_error(get_type_name(), "Randomization failed for read_req")
            end
            
            `uvm_info(get_type_name(), $sformatf("Sending read transaction: rinc=%0b", read_req.rinc), UVM_MEDIUM)
            
            finish_item(read_req);
	      end
        
        `uvm_info(get_type_name(), "Read sequence completed", UVM_MEDIUM)
    endtask
    
endclass

//======================================================================
//			Read from emtpy FIFO 
//=====================================================================

class async_fifo_rd_empty_sequence extends async_fifo_rd_sequence;
    `uvm_object_utils(async_fifo_rd_empty_sequence)
    
    rand int extra_reads;
    
    constraint extra_reads_c {
        extra_reads inside {[5:15]};
    }
    
    function new(string name = "async_fifo_rd_empty_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_rd_seq_item read_req;
        int total_reads;
        
        `uvm_info(get_type_name(), "Starting read empty sequence", UVM_MEDIUM)
        
        total_reads = `WIDTH + extra_reads;
        read_req = async_fifo_rd_seq_item::type_id::create("read_req");
        
        repeat(total_reads) begin
            start_item(read_req);
            
            if (!read_req.randomize() with {read_req.rrst_n == 'b1; read_req.rinc == 'b1;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            
            `uvm_info(get_type_name(), $sformatf("Read #%0d from potentially empty FIFO", total_reads), UVM_HIGH)
            
            finish_item(read_req);
        end
        
        `uvm_info(get_type_name(), $sformatf("Read empty sequence completed - attempted %0d reads", total_reads), UVM_MEDIUM)
    endtask
endclass

//============================================================
//     		Read with no incrememnt
//===========================================================

class async_fifo_rd_no_inc_sequence extends async_fifo_rd_sequence;
  `uvm_object_utils(async_fifo_rd_no_inc_sequence)
    
  function new(string name = "async_fifo_rd_no_inc_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_rd_seq_item read_req;
        
        `uvm_info(get_type_name(), "Starting read empty sequence", UVM_MEDIUM)
   
        read_req = async_fifo_rd_seq_item::type_id::create("read_req");
        
      repeat(`no_of_trans) begin
            start_item(read_req);
            
          if (!read_req.randomize() with {read_req.rrst_n == 'b1; read_req.rinc == 'b0;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            
        `uvm_info(get_type_name(), $sformatf("Read without incrememnt rdata=%0h", read_req.rdata), UVM_HIGH)
            
            finish_item(read_req);
        end
        
      `uvm_info(get_type_name(), $sformatf("Read with no incrememnt completed"), UVM_MEDIUM)
    endtask
endclass


//============================================================================
// Read Reset Sequence
//============================================================================
class async_fifo_rd_reset_sequence extends async_fifo_rd_sequence;
    `uvm_object_utils(async_fifo_rd_reset_sequence)
    
    rand int reset_cycles;
    
    constraint reset_cycles_c {
        reset_cycles inside {[3:10]};
    }
    
    function new(string name = "async_fifo_rd_reset_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_rd_seq_item read_req;
        
        `uvm_info(get_type_name(), "Starting read reset sequence", UVM_MEDIUM)
        
        read_req = async_fifo_rd_seq_item::type_id::create("read_req");
        
        // Assert reset
        start_item(read_req);
        if (!read_req.randomize() with {read_req.rrst_n == 'b0; read_req.rinc == 'b0;}) begin
            `uvm_error(get_type_name(), "Randomization failed")
        end
        `uvm_info(get_type_name(), "Asserting read reset", UVM_MEDIUM)
        finish_item(read_req);
        
        // Hold reset for multiple cycles
        repeat(reset_cycles) begin
            start_item(read_req);
            if (!read_req.randomize() with {read_req.rrst_n == 'b0;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(read_req);
        end
        
        // Deassert reset
        start_item(read_req);
        if (!read_req.randomize() with {read_req.rrst_n == 'b1; read_req.rinc == 'b0;}) begin
            `uvm_error(get_type_name(), "Randomization failed")
        end
        `uvm_info(get_type_name(), "De-asserting read reset", UVM_MEDIUM)
        finish_item(read_req);
        
        `uvm_info(get_type_name(), "Read reset sequence completed", UVM_MEDIUM)
    endtask
endclass

//-----------------------------------------------------------------------------
// Read Burst Sequence
//-----------------------------------------------------------------------------
class async_fifo_rd_burst_sequence extends async_fifo_rd_sequence;
    `uvm_object_utils(async_fifo_rd_burst_sequence)
    
    rand int burst_size;
    
    constraint burst_size_c {
      burst_size inside {[`WIDTH/4 : `WIDTH/2]};
    }
    
    function new(string name = "async_fifo_rd_burst_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_rd_seq_item read_req;
        
        `uvm_info(get_type_name(), $sformatf("Starting read burst sequence - burst_size=%0d", burst_size), UVM_MEDIUM)
        
        read_req = async_fifo_rd_seq_item::type_id::create("read_req");
        
        repeat(burst_size) begin
            start_item(read_req);
            
            if (!read_req.randomize() with {read_req.rrst_n == 'b1; read_req.rinc == 'b1;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            
            finish_item(read_req);
        end
        
        `uvm_info(get_type_name(), "Read burst sequence completed", UVM_MEDIUM)
    endtask
endclass

//-----------------------------------------------------------------------------
// Read Random Sequence
//-----------------------------------------------------------------------------
class async_fifo_rd_random_sequence extends async_fifo_rd_sequence;
    `uvm_object_utils(async_fifo_rd_random_sequence)
    
    rand int num_transactions;
    
    constraint num_trans_c {
        num_transactions inside {[50:100]};
    }
    
    function new(string name = "async_fifo_rd_random_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        async_fifo_rd_seq_item read_req;
        
        `uvm_info(get_type_name(), $sformatf("Starting read random sequence - %0d transactions", num_transactions), UVM_MEDIUM)
        
        read_req = async_fifo_rd_seq_item::type_id::create("read_req");
        
        repeat(num_transactions) begin
            start_item(read_req);
            
            // Fully random including rinc
            if (!read_req.randomize() with {read_req.rrst_n == 'b1;}) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            
            `uvm_info(get_type_name(), $sformatf("Random read: rinc=%0b", read_req.rinc), UVM_HIGH)
            
            finish_item(read_req);
        end
        
        `uvm_info(get_type_name(), "Read random sequence completed", UVM_MEDIUM)
    endtask
endclass
