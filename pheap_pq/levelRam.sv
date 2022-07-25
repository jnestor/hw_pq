`include "pheapTypes.sv"

module levelRam
    import pheapTypes::*;

    #(parameter RAMLEVEL=2)

        (input logic clk, we_a, we_b, [$bits(pheapTypes::entry_t) - 1 : 0] data_a, data_b, [RAMLEVEL - 2:0] addr_a, addr_b,
        output logic [$bits(pheapTypes::entry_t) - 1 : 0] q_a, q_b);
//  Xilinx True Dual Port RAM No Change Single Clock
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  This is a no change RAM which retains the last read value on the output during writes
//  which is the most power efficient mode.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.

  parameter RAM_WIDTH = $bits(pheapTypes::entry_t);                  // Specify RAM data width
  parameter RAM_DEPTH = (2**(RAMLEVEL - 1));                  // Specify RAM depth (number of entries)
  //parameter INIT_FILE = {"C:/Users/mobil/ThesisIncludes/pheap/level", s.itoa(RAMLEVEL), ".data"};                       // Specify name/location of RAM initialization file if using one (leave blank if not)
  parameter INIT_FILE = "";
  //parameter INIT_FILE = $sformatf("level%0d.data",RAMLEVEL);
  parameter START_LOC = 2**(RAMLEVEL - 1) - 1;
  parameter END_LOC = 2**(RAMLEVEL) - 2;



  reg [RAM_WIDTH - 1:0] level_ram [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data_a = {RAM_WIDTH{1'b0}};
  reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        //$readmemb(INIT_FILE, level_ram, START_LOC, END_LOC);
        $readmemb(INIT_FILE, level_ram);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          level_ram[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clk)
      if (we_a)
        level_ram[addr_a] <= data_a;
      else
        ram_data_a <= level_ram[addr_a];

  always @(posedge clk)
      if (we_b)
        level_ram[addr_b] <= data_b;
      else
        ram_data_b <= level_ram[addr_b];

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign q_a = ram_data_a;
       assign q_b = ram_data_b;


  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
endmodule
