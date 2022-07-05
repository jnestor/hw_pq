`ifndef PHEAPTYPES
`define PHEAPTYPES
package pheapTypes;

    parameter LEVELS = 16;

    typedef enum logic [1:0] {DONE, NEXT_LEVEL, WAIT} done_t;
    typedef enum logic [1:0] {FREE, LEQ, DEQ} opcode_t;
    typedef logic [31:0] pValue;

    typedef struct packed {
        pValue priorityValue;
        logic [LEVELS - 1:0] capacity;
        logic active;
    } entry_t;

    typedef struct packed {
        opcode_t levelOp;
        logic [31:0] priorityValue;
    } opArray_t;

endpackage
`endif
