module sr_pq_tb;
  parameter KW=4, VW=4, DEPTH=4;

  // DUV inputs
  logic clk, rst, push, pop;
  logic [KW+VW-1:0] kvi;
  // DUV outputs
  logic [KW+VW-1:0] kvo;
  logic full, empty;

  logic [KW-1:0] key_in;
  logic [VW-1:0] val_in;
  assign kvi = {key_in,val_in};



  sr_pq #(.KW(KW), .VW(VW), .DEPTH(DEPTH)) DUV (
    .clk, .rst, .push, .pop,
    .kvi, .kvo, .full, .empty
  );

  always begin
      clk = 0; #5;
      clk = 1; #5;
  end

  initial begin
      rst = 1;
      @(posedge clk) #1;
      rst = 0;
      @(posedge clk) #1;
      key_in = 4;
      val_in = 4;
      push = 1;
      @(posedge clk) #1;
      key_in = 5;
      val_in = 5;
      push = 1;
      @(posedge clk) #1;
      push = 0;
      @(posedge clk) #1;
      key_in = 6;
      val_in = 6;
      push = 1;
      @(posedge clk) #1;
      key_in = 3;
      val_in = 3;
      @(posedge clk) #1;
      push = 0;
      @(posedge clk) #1;
      pop = 1;
      @(posedge clk) #1;
      pop = 0;
      @(posedge clk) #1;
      push = 1;
      pop = 1;
      key_in = 7;
      val_in = 7;
      @(posedge clk) #1;
      push = 0;
      @(posedge clk) #1;
      $stop;
  end



endmodule: sr_pq_tb
