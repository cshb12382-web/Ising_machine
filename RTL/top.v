`timescale 1ns / 1ps

module top(clk,rst,cycle, new_space, maxcut);   //이상값 아마도 501, res는 임시 결과확인
input clk,rst;
input [5:0] cycle;
output [19:0] new_space;
output [8:0] maxcut;

wire [8:0] addr;
wire signed [7:0] dout;
reg [11:0] current;
reg en; // 입력신호로 사용할까
wire done;
wire restart;

wire signed [15:0] h_value;
reg signed [27:0] scale_i;
reg signed [14:0] really_i;
reg space_en_delay;

wire [5:0] beta_addr;
wire [11:0] beta_out;
wire signed [12:0] beta_out2;
wire [1:0] direction;

assign beta_out2 = {1'b0,beta_out};

blk_mem_gen_0 beta_mem(
    .clka(clk),
    .addra(beta_addr),
    .douta(beta_out),
    .clkb(clk),
    .addrb(9'b0),
    .doutb()
  );
  
blk_mem_gen_1 weight_mem(
    .clka(clk),
    .addra(addr),
    .douta(dout),
    .clkb(clk),
    .addrb(9'b0),
    .doutb()
  );
  
wire [6:0] random;
wire [19:0] lfsr_space;
reg  [19:0] space_reg;
reg start;
wire change;
wire result;
wire [4:0] change_node;
wire one_cycle_done;
wire [19:0] space;
wire [4:0] target;

assign space = space_reg;

LFSR LFSR1(.clk(clk),.rst(rst),.seed(20'b0000_0000_0000_0000_0001),.out(lfsr_space),.random(random));   //시드는 내맘
//energy energy1(.clk(clk),.rst(rst),.target(),.weight(dout),.space(space_reg),.start(start),.change(change),.
//res(result),.done(done),.h_value(h_value),.addr(addr),.change_node(change_node),.one_cycle_done(one_cycle_done),.new_space(new_space));


wire [19:0] new_space2;
wire [4:0] new_addr;
reg space_en;
wire flip_done;
energy2 energy20(.clk(clk),.rst(rst),.target(target),.space(space_reg),.start(start),.flip_done(flip_done),.direction(direction)
,.one_cycle_done(one_cycle_done),.restart(restart),.done(done),.h_value(h_value),.addr(new_addr),.new_space(new_space),.space_en(space_en));


check check0(.clk(clk),.rst(rst),.change(change),.res(result),.new_space(new_space)
,.flip_done(flip_done),.target(target),.direction(direction),.one_cycle_done(one_cycle_done),.space_en(space_en));


wire [6:0] probability;
tanh tanh1(.clk(clk),.rst(rst),.really_i(really_i),.probability(probability));



compa compa1(.clk(clk),.rst(rst),.probability(probability),.random(random),.space_en(space_en),.res(result),.change(change));

//assign scale_i = beta_out*h_value;
//assign really_i = scale_i >>> 12;  //>>>는 부호유지하기 위해서임. i는 -값 나올 수도 있어서

wire finish;
annealing annealing0(.clk(clk),.rst(rst),.one_cycle_done(one_cycle_done),
.cycle(6'd49),.beta_addr(beta_addr),.finish(finish),.restart(restart));


maxcut maxcut0(.clk(clk),.rst(rst),.finish(finish),.new_space(new_space),.maxcut(maxcut));

parameter cal1=0, cal2=1, waitt=2, enable=3, end_state=4;
reg [2:0]main_state;
reg init;


 always @ (posedge clk or negedge rst)begin
if(!rst) begin
    en <= 1'b1;
    space_en_delay<=1'b0;
    scale_i <= 20'b0;
    really_i <= 12'b0;
    main_state<=2'b0;
    space_en <= 1'b0;
    init <= 1'b0;
    space_reg<=20'b0;
    start <=1'b0;
end
else begin
space_en_delay <= space_en;
if(finish ==1'b1)begin
    start <= 1'b0;
end
if(en==1'b1)begin
    init <= 1'b1;
end
if(init==1'b1)begin
    space_reg <= lfsr_space;
    init <= 1'b0;
    start <=1'b1;
end
    en <= 1'b0;
    case(main_state)
    cal1 : begin
    space_en <= 1'b0;
    if(done == 1'b1)begin
        scale_i <= beta_out2*h_value;
        main_state <= cal2;
    end
    if(finish == 1'b1)begin
        main_state <= end_state;
    end
    end 
    cal2 : begin
        //beta_addr <= beta_addr + 1'b1; 어닐링 모듈에 추가
        really_i <= scale_i >>> 5;  //>>>는 부호유지하기 위해서임. i는 -값 나올 수도 있어서 >한번더, 일단 나누기 32(원래는4096) *128형태
        main_state <= waitt;
    end
    waitt : begin
        space_en <= 1'b0;
        main_state <= enable;
    end
    enable : begin
        space_en<=1'b1;
        main_state<=cal1;
    end
    end_state : begin
        main_state <= end_state;
        space_en <= 1'b0;
    end
    default : main_state <= main_state;
    endcase
end
end
endmodule
