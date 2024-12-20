// localparams.sv
`ifndef localparamS_SV
`define localparamS_SV

// LFSR localparams
localparam int LFSR_DW      = 7;
localparam int LFSR_DEFAULT = 8'h01;

// MVM localparams
localparam int DATAW = 128;
localparam int BYTEW = 8;
localparam int IDW = 4;
localparam int DESTW = 12;
localparam int IPRECISION = 8;
localparam int OPRECISION = 32;
localparam int LANES = DATAW / IPRECISION;
localparam int USERW = 75; // Lanes = # RF weigts for each MVM
                                  // + 11 for user operations 10:0
localparam int DPES = LANES;
localparam int NODES = 512;
localparam int NODESW = $clog2(NODES);
localparam int RFDEPTH = 64;
localparam int RFADDRW = 9;
localparam int INSTW = 1 + NODESW + 2 * RFADDRW + 4;
localparam int INSTD = 512;
localparam int INSTADDRW = $clog2(INSTD);
localparam int AXIS_OPS = 4;
localparam int AXIS_OPSW = $clog2(AXIS_OPS);
localparam int FIFOD = 64;
localparam int DATAPATH_DELAY = 12;
localparam int USE_RELU = 1;

// Mesh localparams
// 4x4 Mesh is verified but exceeds intel recommended design size
// this causes the simulation to finish extremely slowly. For testing 
// purposes recommend only using 3x3 noc or below. 
localparam int ROWS         = 2;
localparam int COLUMNS      = 2;
localparam int TDATAW       = DATAW + USERW;
localparam int TIDW         = 4;
localparam int TDESTW       = 12;
localparam int NUM_PACKETS  = 1;

// Directories
localparam string ROUTING_TABLES_DIR = 
    (ROWS == 2 && COLUMNS == 2) ? "../routing_tables/mesh_2x2/" :
    (ROWS == 3 && COLUMNS == 3) ? "../routing_tables/mesh_3x3/" :
    (ROWS == 4 && COLUMNS == 4) ? "../routing_tables/mesh_4x4/" :
    "../routing_tables/default/"; // Default this should be an error

`endif // localparamS_SV
