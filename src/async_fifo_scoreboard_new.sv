`uvm_analysis_imp_decl(_from_write)
`uvm_analysis_imp_decl(_from_read)

class async_fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(async_fifo_scoreboard)
    
    // Reference model - internal memory queue
    bit [`WIDTH-1:0] scb_queue[$];
    bit [`WIDTH-1:0] expected_data;
    
    // Counters for write and read pointers (independent tracking)
    int write_ptr;
    int read_ptr;
    int fifo_count;  // Current number of items in FIFO
    
    // Analysis ports
    uvm_analysis_imp_from_write#(async_fifo_wr_seq_item, async_fifo_scoreboard) write_export;
    uvm_analysis_imp_from_read#(async_fifo_rd_seq_item, async_fifo_scoreboard) read_export;
    
    // Statistics
    int match = 0;
    int mismatch = 0;
    int write_count = 0;
    int read_count = 0;
    int full_flag_errors = 0;
    int empty_flag_errors = 0;
    
    // Predicted flags
    bit predicted_full;
    bit predicted_empty;
    
    function new(string name = "async_fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        write_export = new("write_export", this);
        read_export = new("read_export", this);
        
        // Initialize pointers and counters
        write_ptr = 0;
        read_ptr = 0;
        fifo_count = 0;
        predicted_full = 0;
        predicted_empty = 1;  // Initially empty
    endfunction
    
    // Function to update predicted flags based on counter
    function void update_predicted_flags();
      predicted_full = (fifo_count == (1<<`WIDTH));
        predicted_empty = (fifo_count == 0);
        
        `uvm_info(get_type_name(), 
                 $sformatf("FLAG UPDATE: fifo_count=%0d, predicted_full=%0b, predicted_empty=%0b", 
                          fifo_count, predicted_full, predicted_empty), 
                 UVM_HIGH)
    endfunction
    
    function void write_from_write(async_fifo_wr_seq_item wr_trans);
        if(wr_trans.wrst_n && wr_trans.winc) begin
            // Check if our prediction says FIFO is full
            if(!predicted_full) begin
                // We predict write should succeed - add to queue
                scb_queue.push_back(wr_trans.wdata);
                write_count++;
                fifo_count++;
                write_ptr = (write_ptr + 1) % `WIDTH;
                
                // Update predicted flags
                update_predicted_flags();
                
                `uvm_info(get_type_name(), 
                         $sformatf("WRITE CAPTURED @%0t: wdata=0x%0h, fifo_count=%0d/%0d, queue_size=%0d", 
                                  $time, wr_trans.wdata, fifo_count, `WIDTH, scb_queue.size()), 
                         UVM_MEDIUM)
                
                // Verify DUT's wfull flag matches our prediction
                if(predicted_full != wr_trans.wfull) begin
                    full_flag_errors++;
                    `uvm_error(get_type_name(), 
                              $sformatf("WFULL FLAG MISMATCH @%0t: predicted_full=%0b, DUT_wfull=%0b, fifo_count=%0d", 
                                       $time, predicted_full, wr_trans.wfull, fifo_count))
                end else begin
                    `uvm_info(get_type_name(), 
                             $sformatf("WFULL FLAG MATCH @%0t: wfull=%0b (fifo_count=%0d)", 
                                      $time, wr_trans.wfull, fifo_count), 
                             UVM_HIGH)
                end
                
            end else begin
                // We predict FIFO is full - write should not go through
                `uvm_info(get_type_name(), 
                         $sformatf("WRITE BLOCKED (PREDICTED FULL) @%0t: wdata=0x%0h, fifo_count=%0d", 
                                  $time, wr_trans.wdata, fifo_count), 
                         UVM_MEDIUM)
                
                // Verify DUT also indicates full
                if(!wr_trans.wfull) begin
                    full_flag_errors++;
                    `uvm_error(get_type_name(), 
                              $sformatf("WFULL FLAG ERROR @%0t: predicted_full=1 but DUT_wfull=0, fifo_count=%0d", 
                                       $time, fifo_count))
                end else begin
                    `uvm_info(get_type_name(), 
                             $sformatf("WFULL FLAG CORRECTLY SET @%0t: wfull=%0b", 
                                      $time, wr_trans.wfull), 
                             UVM_HIGH)
                end
            end
        end else if(!wr_trans.wrst_n) begin
            // Write reset detected - clear everything
            `uvm_info(get_type_name(), "WRITE RESET DETECTED - Clearing write-side state", UVM_MEDIUM)
            scb_queue.delete();
            write_ptr = 0;
            fifo_count = 0;
            update_predicted_flags();
        end
    endfunction
  
    function void write_from_read(async_fifo_rd_seq_item rd_trans);
        if(rd_trans.rrst_n && rd_trans.rinc) begin
            // Check if our prediction says FIFO is empty
            if(!predicted_empty) begin
                // We predict read should succeed
                if(scb_queue.size() > 0) begin
                    // Get expected data from reference queue
                    expected_data = scb_queue.pop_front();
                    read_count++;
                    fifo_count--;
                    read_ptr = (read_ptr + 1) % `WIDTH;
                    
                    // Update predicted flags
                    update_predicted_flags();
                    
                    // Compare with actual read data
                    if(rd_trans.rdata === expected_data) begin
                        match++;
                        `uvm_info(get_type_name(), 
                                 $sformatf("DATA MATCH @%0t: expected=0x%0h, received=0x%0h, fifo_count=%0d/%0d, queue_size=%0d", 
                                          $time, expected_data, rd_trans.rdata, fifo_count, `WIDTH, scb_queue.size()), 
                                 UVM_MEDIUM)
                    end else begin
                        mismatch++;
                        `uvm_error(get_type_name(), 
                                  $sformatf("DATA MISMATCH @%0t: expected=0x%0h, received=0x%0h, fifo_count=%0d", 
                                           $time, expected_data, rd_trans.rdata, fifo_count))
                    end
                    
                    // Verify DUT's rempty flag matches our prediction
                    if(predicted_empty != rd_trans.rempty) begin
                        empty_flag_errors++;
                        `uvm_error(get_type_name(), 
                                  $sformatf("REMPTY FLAG MISMATCH @%0t: predicted_empty=%0b, DUT_rempty=%0b, fifo_count=%0d", 
                                           $time, predicted_empty, rd_trans.rempty, fifo_count))
                    end else begin
                        `uvm_info(get_type_name(), 
                                 $sformatf("REMPTY FLAG MATCH @%0t: rempty=%0b (fifo_count=%0d)", 
                                          $time, rd_trans.rempty, fifo_count), 
                                 UVM_HIGH)
                    end
                    
                end else begin
                    `uvm_error(get_type_name(), 
                              $sformatf("INTERNAL ERROR @%0t: predicted not empty but queue is empty! fifo_count=%0d", 
                                       $time, fifo_count))
                end
            end else begin
                // We predict FIFO is empty - read should not return valid data
                `uvm_info(get_type_name(), 
                         $sformatf("READ BLOCKED (PREDICTED EMPTY) @%0t, fifo_count=%0d", 
                                  $time, fifo_count), 
                         UVM_MEDIUM)
                
                // Verify DUT also indicates empty
                if(!rd_trans.rempty) begin
                    empty_flag_errors++;
                    `uvm_error(get_type_name(), 
                              $sformatf("REMPTY FLAG ERROR @%0t: predicted_empty=1 but DUT_rempty=0, fifo_count=%0d", 
                                       $time, fifo_count))
                end else begin
                    `uvm_info(get_type_name(), 
                             $sformatf("REMPTY FLAG CORRECTLY SET @%0t: rempty=%0b", 
                                      $time, rd_trans.rempty), 
                             UVM_HIGH)
                end
            end
        end else if(!rd_trans.rrst_n) begin
            // Read reset detected - clear read side
            `uvm_info(get_type_name(), "READ RESET DETECTED - Clearing read-side state", UVM_MEDIUM)
            read_ptr = 0;
            // Note: Don't clear scb_queue on read reset, data is still there
            // But reset the fifo_count to 0 as both pointers reset
            fifo_count = 0;
            update_predicted_flags();
        end
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        `uvm_info(get_type_name(), "       SCOREBOARD FINAL REPORT         ", UVM_LOW)
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Writes       : %0d", write_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Reads        : %0d", read_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Data Matches       : %0d", match), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Data Mismatches    : %0d", mismatch), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Full Flag Errors   : %0d", full_flag_errors), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Empty Flag Errors  : %0d", empty_flag_errors), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Queue Size         : %0d", scb_queue.size()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Final FIFO Count   : %0d", fifo_count), UVM_LOW)
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        
        if(mismatch > 0 || full_flag_errors > 0 || empty_flag_errors > 0) begin
            `uvm_error(get_type_name(), "SCOREBOARD: ERRORS DETECTED!")
        end else begin
            `uvm_info(get_type_name(), "SCOREBOARD: ALL CHECKS PASSED!", UVM_LOW)
        end
        
        if(scb_queue.size() != 0) begin
            `uvm_warning(get_type_name(), 
                        $sformatf("Queue not empty at end of test. Remaining items: %0d", scb_queue.size()))
        end
    endfunction
    
endclass
