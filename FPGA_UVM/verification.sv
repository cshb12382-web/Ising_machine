`timescale 1ns / 1ps
`define SEED_PATH dut.LFSR1.seed
`include "uvm_macros.svh"


import uvm_pkg::*;

// ============================================================
// 0. DUT: 8-bit adder, 9-bit output
// ============================================================

//인스턴스 한다면 새롭게 로직 필요 X

// ============================================================
// 1. Interface
// ============================================================
interface ising_if(input logic clk);
    logic rst;
     logic [19:0] new_space;
     logic real_done;
     logic [8:0] maxcut;
     logic [19:0] seed;
endinterface


// ============================================================
// 2. Transaction
// ============================================================
class ising_item extends uvm_sequence_item;

    rand bit [19:0] seed;      //랜덤값을 받음을 암시
    constraint c_seed {seed != 0;} //seed가 0이면 시스템 에러
    bit [19:0] new_space;
    bit [8:0] maxcut;

    function new(string name = "ising_item");
        super.new(name);
    endfunction

    `uvm_object_utils(ising_item)

endclass


// ============================================================
// 3. Sequence
// ============================================================
class ising_seq extends uvm_sequence #(ising_item);

    `uvm_object_utils(ising_seq)

    function new(string name = "ising_seq");
        super.new(name);
    endfunction

    task body();
        ising_item t;

        repeat (20000) begin
            t = ising_item::type_id::create("t");

            start_item(t);

            if (!t.randomize())            //실제 랜덤값 집어넣기
                `uvm_error("SEQ", "randomize failed")

            finish_item(t);
        end
    endtask

endclass


// ============================================================
// 4. Driver
// ============================================================
class ising_driver extends uvm_driver #(ising_item);

    `uvm_component_utils(ising_driver)

    virtual ising_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual ising_if)::get(
                this, "", "vif", vif
            ))
            `uvm_fatal("DRV", "vif not found")
    endfunction

    task run_phase(uvm_phase phase);
        vif.rst <= 0;
        vif.seed <= 20'd1;

        forever begin
            seq_item_port.get_next_item(req);

            vif.rst <= 0;  //초기값
            vif.seed <= req.seed;   //초기값
            repeat(10) @ (posedge vif.clk);
            vif.rst <= 1;   //리셋 해제 및 로직 시작
            
            wait (vif.real_done ==1); // 계산 끝날 때까지 기다리기
            
            repeat(2) @ (posedge vif.clk);
            seq_item_port.item_done();
        end

    endtask

endclass


// ============================================================
// 5. Monitor
// ============================================================
class ising_monitor extends uvm_monitor;

    `uvm_component_utils(ising_monitor)

    virtual ising_if vif;
    uvm_analysis_port #(ising_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual ising_if)::get(
                this, "", "vif", vif
            ))
            `uvm_fatal("MON", "vif not found")
    endfunction

    task run_phase(uvm_phase phase);
        ising_item t;
        bit prev_done = 0;
        forever begin
            @(posedge vif.clk);
            if (vif.real_done && !prev_done) begin
                t = ising_item::type_id::create("t");
                t.new_space   = vif.new_space;
                t.seed   = vif.seed;
                t.maxcut = vif.maxcut;
                ap.write(t);
            end
            prev_done = vif.real_done;
        end
    endtask

endclass


// ============================================================
// 6. Scoreboard. logger
// ============================================================
class ising_logger extends uvm_scoreboard;

    `uvm_component_utils(ising_logger)

    uvm_analysis_imp #(ising_item, ising_logger) imp;
    int count = 0;
    int fd;
    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    fd = $fopen("ising_results.csv", "w");             // 파일 열기
    $fwrite(fd, "seed,new_space,maxcut\n");            // 첫 줄 = 열 이름
  endfunction
 
  function void write(ising_item t);                    // monitor가 ap.write(t) 하면 자동 호출
    count++;
    `uvm_info("LOG", $sformatf("#%0d seed=%05h new_space=%b maxcut=%0d", count, t.seed, t.new_space, t.maxcut), UVM_LOW) 
    $fwrite(fd, "%0d,%b,%0d\n", t.seed, t.new_space, t.maxcut);
    endfunction
    
    function void report_phase(uvm_phase phase);
    `uvm_info("LOG", $sformatf("total %0d runs saved to ising_results.csv", count), UVM_LOW)
    $fclose(fd);                                       // 파일 닫기
  endfunction
endclass


// ============================================================
// 7. Environment
// ============================================================
class ising_env extends uvm_env;

    `uvm_component_utils(ising_env)

    uvm_sequencer #(ising_item) sqr;
    ising_driver                 drv;
    ising_monitor                mon;
    ising_logger             log;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sqr = uvm_sequencer#(ising_item)::type_id::create(
            "sqr", this
        );

        drv = ising_driver::type_id::create("drv", this);
        mon = ising_monitor::type_id::create("mon", this);
        log  = ising_logger::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(sqr.seq_item_export);
        mon.ap.connect(log.imp);
    endfunction

endclass


// ============================================================
// 8. Test
// ============================================================
class ising_test extends uvm_test;

    `uvm_component_utils(ising_test)

    ising_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = ising_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        ising_seq seq;

        seq = ising_seq::type_id::create("seq");

        phase.raise_objection(this);

        seq.start(env.sqr);
        #100;
        phase.drop_objection(this);
    endtask

endclass


// ============================================================
// 9. Top-level testbench
// ============================================================
module tb_top_verification;

    logic clk = 0;

    always #5 clk = ~clk;

    ising_if intf(clk);

top dut(.clk(clk),.rst(intf.rst),.cycle(),.real_done(intf.real_done),.new_space(intf.new_space),.maxcut(intf.maxcut));

    initial force `SEED_PATH = intf.seed;

    initial begin

        uvm_config_db#(virtual ising_if)::set(
            null, "*", "vif", intf
        );

        run_test("ising_test");
    end

endmodule
