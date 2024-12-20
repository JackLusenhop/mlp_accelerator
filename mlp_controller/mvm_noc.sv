`include "/home/advent2/Simple_NoC/hw/parameters.sv"

module mvm_noc (

    input   wire                  CLK,
    input   wire                  CLK_NOC,
    input   wire                  RST_N,

    // -------------------------------------------------------
    // AXI-Stream Slave Interface
    // -------------------------------------------------------
    input   wire                  AXIS_S_TVALID,
    output  logic                 AXIS_S_TREADY,
    input   wire    [ DATAW-1:0]  AXIS_S_TDATA,
    input   wire                  AXIS_S_TLAST,
    input   wire    [   IDW-1:0]  AXIS_S_TID,
    input   wire    [ USERW-1:0]  AXIS_S_TUSER,
    input   wire    [ DESTW-1:0]  AXIS_S_TDEST,

    // -------------------------------------------------------
    // AXI-Stream Master Interface
    // -------------------------------------------------------
    output  logic                 AXIS_M_TVALID,
    input   wire                  AXIS_M_TREADY,
    output  logic   [ DATAW-1:0]  AXIS_M_TDATA,
    output  logic                 AXIS_M_TLAST,
    output  logic   [   IDW-1:0]  AXIS_M_TID,
    output  logic   [ USERW-1:0]  AXIS_M_TUSER,
    output  logic   [ DESTW-1:0]  AXIS_M_TDEST

);

    // -------------------------------------------------------
    // NoC Connections
    // -------------------------------------------------------
    //
    // NOTE: These names in/out are named for the directions 
    // in which they enter the noc. Not the MVMs they are 
    // connected to
    //
    // -------------------------------------------------------
    logic              axis_in_tvalid   [ROWS][COLUMNS];
    logic              axis_in_tready   [ROWS][COLUMNS];
    logic [ DATAW-1:0] axis_in_tdata    [ROWS][COLUMNS];
    logic              axis_in_tlast    [ROWS][COLUMNS];
    logic [ USERW-1:0] axis_in_tuser    [ROWS][COLUMNS];
    logic [ DESTW-1:0] axis_in_tdest    [ROWS][COLUMNS];

    logic              axis_out_tvalid  [ROWS][COLUMNS];
    logic              axis_out_tready  [ROWS][COLUMNS];
    logic [ DATAW-1:0] axis_out_tdata   [ROWS][COLUMNS];
    logic              axis_out_tlast   [ROWS][COLUMNS];
    logic [ USERW-1:0] axis_out_tuser   [ROWS][COLUMNS];
    logic [ DESTW-1:0] axis_out_tdest   [ROWS][COLUMNS];

    logic [TDATAW-1:0] mesh_in_tdata    [ROWS][COLUMNS];
    logic [TDATAW-1:0] mesh_out_tdata   [ROWS][COLUMNS];
    logic [ USERW-1:0] mesh_out_tuser   [ROWS][COLUMNS];

    // assign mesh_in_tdata  [0][0] = {axis_in_tuser [0][0],axis_in_tdata  [0][0]};

    // assign mesh_in_tdata  [0][1] = {axis_in_tuser [0][1],axis_in_tdata  [0][1]};
    // assign axis_out_tdata [0][1] = mesh_out_tdata [0][1][DATAW-1:0];
    // assign axis_out_tuser [0][1] = mesh_out_tdata [0][1][TDATAW-1:DATAW];

    // assign mesh_in_tdata  [1][0] = {axis_in_tuser [1][0],axis_in_tdata  [1][0]};
    // assign axis_out_tdata [1][0] = mesh_out_tdata [1][0][DATAW-1:0];
    // assign axis_out_tuser [1][0] = mesh_out_tdata [1][0][TDATAW-1:DATAW];

    // assign mesh_in_tdata  [1][1] = {axis_in_tuser [1][1],axis_in_tdata  [1][1]};
    // assign axis_out_tdata [1][1] = mesh_out_tdata [1][1][DATAW-1:0];
    // assign axis_out_tuser [1][1] = mesh_out_tdata [1][1][TDATAW-1:DATAW];

    genvar i, j;

    generate
        for (i = 0; i < ROWS; i = i + 1) begin : row_loop
            for (j = 0; j < COLUMNS; j = j + 1) begin : column_loop
                // Assign mesh_in_tdata by concatenating axis_in_tuser and axis_in_tdata
                assign mesh_in_tdata[i][j] = {axis_in_tuser[i][j], axis_in_tdata[i][j]};
                
                // Assign axis_out_tdata from the lower part of mesh_out_tdata
                assign axis_out_tdata[i][j] = mesh_out_tdata[i][j][DATAW-1:0];
                
                // Assign axis_out_tuser from the upper part of mesh_out_tdata
                assign axis_out_tuser[i][j] = mesh_out_tdata[i][j][TDATAW-1:DATAW];
            end
        end
    endgenerate


    // -------------------------------------------------------
    // Module Instantions
    // -------------------------------------------------------

    // Generate axis_passthrough for [0][0] only
    axis_passthrough #(
        .DATAW(DATAW),
        .IDW(IDW),
        .USERW(USERW),
        .DESTW(DESTW)
    ) axis_passthrough_inst (
        .CLK(CLK),
        .RST_N(RST_N),
        .AXIS_S_TVALID(AXIS_S_TVALID),
        .AXIS_S_TREADY(AXIS_S_TREADY),
        .AXIS_S_TDATA(AXIS_S_TDATA),
        .AXIS_S_TLAST(AXIS_S_TLAST),
        .AXIS_S_TUSER(AXIS_S_TUSER),
        .AXIS_S_TDEST(AXIS_S_TDEST),
        .AXIS_M_TVALID(axis_in_tvalid[0][0]),
        .AXIS_M_TREADY(axis_in_tready[0][0]),
        .AXIS_M_TDATA(axis_in_tdata[0][0]),
        .AXIS_M_TLAST(axis_in_tlast[0][0]),
        .AXIS_M_TUSER(axis_in_tuser[0][0]),
        .AXIS_M_TDEST(axis_in_tdest[0][0])
    );

    axis_passthrough #(
        .DATAW(DATAW),
        .IDW(IDW),
        .USERW(USERW),
        .DESTW(DESTW)
    ) axis_passthrough_inst2 (
        .CLK(CLK),
        .RST_N(RST_N),
        .AXIS_S_TVALID(axis_out_tvalid [1][1]),
        .AXIS_S_TREADY(axis_out_tready [1][1]),
        .AXIS_S_TDATA (axis_out_tdata  [1][1]),
        .AXIS_S_TLAST (axis_out_tlast  [1][1]),
        // .AXIS_S_TUSER (axis_out_tuser  [1][1]),
        .AXIS_S_TDEST (axis_out_tdest  [1][1]),
        .AXIS_M_TVALID(AXIS_M_TVALID),
        .AXIS_M_TREADY(AXIS_M_TREADY),
        .AXIS_M_TDATA (AXIS_M_TDATA),
        .AXIS_M_TLAST (AXIS_M_TLAST),
        // .AXIS_M_TUSER (AXIS_M_TUSER),
        .AXIS_M_TDEST (AXIS_M_TDEST)
    );
    
    // Generate rtl_mvm instances, skipping [0][0]
    generate
        for (i = 0; i < ROWS; i = i + 1) begin : NUM_ROWS

            for (j = 0; j < COLUMNS; j = j + 1) begin : NUM_COLUMNS

                // Skipping [1][1] for now to use a passthrough block
                if (!(i == 0 && j == 0) && !(i == 1 && j == 1)) begin  // Skip [0][0]

                    if (i != ROWS-1 || j != COLUMNS-1) begin

							 if(i == 0 && j == 1) begin
								rtl_mvm #(
									 .DATAW(DATAW),
									 .BYTEW(BYTEW),
									 .IDW(IDW),
									 .DESTW(DESTW),
									 .USERW(USERW),
									 .IPRECISION(8),
									 .OPRECISION(32),
									 .LANES(LANES),
									 .DPES(DPES),
									 .NODES(NODES),
									 .NODESW($clog2(NODES)),
									 .RFDEPTH(RFDEPTH),
									 .RFADDRW(RFADDRW),
									 .INSTW(1 + NODESW + 2 * RFADDRW + 4),
									 .INSTD(512),
									 .INSTADDRW($clog2(INSTD)),
									 .AXIS_OPS(4),
									 .AXIS_OPSW($clog2(AXIS_OPS)),
									 .FIFOD(64),
									 .DATAPATH_DELAY(10),
									 .WEIGHTS_INIT_FILE("/home/advent2/quartus_projects/mlp_controller_v2/rf_weights0_1.mif")
								) mvm_inst (
									 .clk(CLK),
									 .rst(~RST_N),
									 .axis_rx_tvalid(axis_out_tvalid[i][j]),
									 .axis_rx_tdata(axis_out_tdata[i][j][DATAW-1:0]),
									 .axis_rx_tdest(axis_out_tdest[i][j]),
									 .axis_rx_tuser(axis_out_tuser[i][j]),
									 .axis_rx_tlast(axis_out_tlast[i][j]),
									 .axis_rx_tready(axis_out_tready[i][j]),
									 .axis_tx_tvalid(axis_in_tvalid[i][j]),
									 .axis_tx_tdata(axis_in_tdata[i][j][DATAW-1:0]),
									 .axis_tx_tdest(axis_in_tdest[i][j]),
									 .axis_tx_tuser(axis_in_tuser[i][j]),
									 .axis_tx_tlast(axis_in_tlast[i][j]),
									 .axis_tx_tready(axis_in_tready[i][j])
								);
							end	
							else begin
								rtl_mvm #(
									 .DATAW(DATAW),
									 .BYTEW(BYTEW),
									 .IDW(IDW),
									 .DESTW(DESTW),
									 .USERW(USERW),
									 .IPRECISION(8),
									 .OPRECISION(32),
									 .LANES(LANES),
									 .DPES(DPES),
									 .NODES(NODES),
									 .NODESW($clog2(NODES)),
									 .RFDEPTH(RFDEPTH),
									 .RFADDRW(RFADDRW),
									 .INSTW(1 + NODESW + 2 * RFADDRW + 4),
									 .INSTD(512),
									 .INSTADDRW($clog2(INSTD)),
									 .AXIS_OPS(4),
									 .AXIS_OPSW($clog2(AXIS_OPS)),
									 .FIFOD(64),
									 .DATAPATH_DELAY(10),
									 .WEIGHTS_INIT_FILE("/home/advent2/quartus_projects/mlp_controller_v2/rf_weights1_0.mif")
								) mvm_inst (
									 .clk(CLK),
									 .rst(~RST_N),
									 .axis_rx_tvalid(axis_out_tvalid[i][j]),
									 .axis_rx_tdata(axis_out_tdata[i][j][DATAW-1:0]),
									 .axis_rx_tdest(axis_out_tdest[i][j]),
									 .axis_rx_tuser(axis_out_tuser[i][j]),
									 .axis_rx_tlast(axis_out_tlast[i][j]),
									 .axis_rx_tready(axis_out_tready[i][j]),
									 .axis_tx_tvalid(axis_in_tvalid[i][j]),
									 .axis_tx_tdata(axis_in_tdata[i][j][DATAW-1:0]),
									 .axis_tx_tdest(axis_in_tdest[i][j]),
									 .axis_tx_tuser(axis_in_tuser[i][j]),
									 .axis_tx_tlast(axis_in_tlast[i][j]),
									 .axis_tx_tready(axis_in_tready[i][j])
								);
							end	
							
                    end else begin

                        rtl_mvm #(
                            .DATAW(DATAW),
                            .BYTEW(BYTEW),
                            .IDW(IDW),
                            .DESTW(DESTW),
                            .USERW(USERW),
                            .IPRECISION(8),
                            .OPRECISION(32),
                            .LANES(DATAW / IPRECISION),
                            .DPES(LANES),
                            .NODES(512),
                            .NODESW($clog2(NODES)),
                            .RFDEPTH(512),
                            .RFADDRW($clog2(RFDEPTH)),
                            .INSTW(1 + NODESW + 2 * RFADDRW + 4),
                            .INSTD(512),
                            .INSTADDRW($clog2(INSTD)),
                            .AXIS_OPS(4),
                            .AXIS_OPSW($clog2(AXIS_OPS)),
                            .FIFOD(64),
                            .DATAPATH_DELAY(2)
                        ) mvm_inst (
                            .clk(CLK),
                            .rst(~RST_N),
                            .axis_rx_tvalid(axis_out_tvalid[i][j]),
                            .axis_rx_tdata(axis_out_tdata[i][j][DATAW-1:0]),
                            .axis_rx_tdest(axis_out_tdest[i][j]),
                            .axis_rx_tuser(axis_out_tuser[i][j]),
                            .axis_rx_tlast(axis_out_tlast[i][j]),
                            .axis_rx_tready(axis_out_tready[i][j]),
                            .axis_tx_tvalid(AXIS_M_TVALID),
                            .axis_tx_tdata(AXIS_M_TDATA[DATAW-1:0]),
                            .axis_tx_tdest(AXIS_M_TDEST),
                            .axis_tx_tuser(AXIS_M_TUSER),
                            .axis_tx_tlast(AXIS_M_TLAST),
                            .axis_tx_tready(AXIS_M_TREADY)
                        );
                        
                    end
                end
            end
        end
    endgenerate

    // axis_passthrough #(
    //     .DATAW          (DATAW),                        // Bitwidth of axi-s tdata
    //     .IDW            (IDW),                          // Bitwidth of axi-s tid
    //     .USERW          (USERW),                        // Bitwidth of axi-s tuser
    //     .DESTW          (DESTW)
    // ) axis_passthrough_inst (
    //     .CLK(CLK),                                      // input
    //     .RST_N(RST_N),                                  // input

    //     .AXIS_S_TVALID  (AXIS_S_TVALID),               // input
    //     .AXIS_S_TREADY  (AXIS_S_TREADY),               // output
    //     .AXIS_S_TDATA   (AXIS_S_TDATA ),               // input
    //     .AXIS_S_TLAST   (AXIS_S_TLAST ),               // input
    //     .AXIS_S_TUSER   (AXIS_S_TUSER ),               // input
    //     .AXIS_S_TDEST   (AXIS_S_TDEST ),               // input

    //     .AXIS_M_TVALID  (axis_in_tvalid  [0][0]),      // output
    //     .AXIS_M_TREADY  (axis_in_tready  [0][0]),      // input
    //     .AXIS_M_TDATA   (axis_in_tdata   [0][0]),      // output
    //     .AXIS_M_TLAST   (axis_in_tlast   [0][0]),      // output
    //     .AXIS_M_TUSER   (axis_in_tuser   [0][0]),      // output
    //     .AXIS_M_TDEST   (axis_in_tdest   [0][0])       // output
    // );

    //     rtl_mvm #(
    //     .DATAW          (DATAW),                          // Bitwidth of axi-s tdata
    //     .BYTEW          (BYTEW),   		                    // Bitwidth of axi-s tkeep, tstrb
    //     .IDW            (IDW),                           // Bitwidth of axi-s tid
    //     .DESTW          (DESTW),		                    // Bitwidth of axi-s tdest
    //     .USERW          (USERW),                           // Bitwidth of axi-s tuser
    //     .IPRECISION     (8),                            // Input precision in bits
    //     .OPRECISION     (32),                           // Output precision in bits
    //     .LANES          (DATAW / IPRECISION),           // Number of dot-product INT8 lanes
    //     .DPES           (LANES),                        // Number of dot-product engines
    //     .NODES          (512),		      	            // Max number of nodes in each NoC
    //     .NODESW         ($clog2(NODES)),                // Bitwidth of store node ID
    //     .RFDEPTH        (512),                          // Depth of register files (RFs)
    //     .RFADDRW        ($clog2(RFDEPTH)),              // Bitwidth of RF address
    //     .INSTW          (1 + NODESW + 2 * RFADDRW + 4), // Instruction bitwidth {release_op, release_dest, rf_raddr, accum_raddr, last, release, accum_en, reduce, jump, en}
    //     .INSTD          (512),                          // Depth of instruction FIFO
    //     .INSTADDRW      ($clog2(INSTD)),                // Bitwidth of instruction memory address
    //     .AXIS_OPS       (4),                            // Number of AXI-S operations (max 4) {instruction, reduction vector, input vector, matrix}
    //     .AXIS_OPSW      ($clog2(AXIS_OPS)),
    //     .FIFOD          (64),                           // Depth of input, accumulation, and output FIFOs
    //     .DATAPATH_DELAY (2)                             // Delay of datpath (inputs -> result)
    // ) mvm_inst_2 (
    //     .clk(CLK),                                      // input
    //     .rst(~RST_N),                                   // input

    //     .axis_rx_tvalid  (axis_out_tvalid [0][1]),       // input
    //     .axis_rx_tdata   (axis_out_tdata  [0][1][DATAW-1:0]),       // input
    //     // .axis_rx_tstrb(axis_out_tstrb  [0][1]),       // input
    //     // .axis_rx_tkeep(axis_out_tkeep  [0][1]),       // input
    //     // .axis_rx_tid  (axis_out_tid    [0][1]),       // input
    //     .axis_rx_tdest   (axis_out_tdest  [0][1]),       // input
    //     .axis_rx_tuser   (axis_out_tuser  [0][1]),       // input
    //     .axis_rx_tlast   (axis_out_tlast  [0][1]),       // input
    //     .axis_rx_tready  (axis_out_tready [0][1]),       // output

    //     .axis_tx_tvalid  (axis_in_tvalid  [0][1]),       // output
    //     .axis_tx_tdata   (axis_in_tdata   [0][1][DATAW-1:0]),       // output
    //     // .axis_tx_tstrb(axis_in_tstrb   [0][1]),       // output
    //     // .axis_tx_tkeep(axis_in_tkeep   [0][1]),       // output
    //     // .axis_tx_tid  (axis_in_tid     [0][1]),       // output
    //     .axis_tx_tdest   (axis_in_tdest   [0][1]),       // output
    //     .axis_tx_tuser   (axis_in_tuser   [0][1]),       // output
    //     .axis_tx_tlast   (axis_in_tlast   [0][1]),       // output
    //     .axis_tx_tready  (axis_in_tready  [0][1])        // input
    // );

    //     rtl_mvm #(
    //     .DATAW          (DATAW),                          // Bitwidth of axi-s tdata
    //     .BYTEW          (BYTEW),  		                    // Bitwidth of axi-s tkeep, tstrb
    //     .IDW            (IDW),                             // Bitwidth of axi-s tid
    //     .DESTW          (DESTW),		                    // Bitwidth of axi-s tdest
    //     .USERW          (USERW),                           // Bitwidth of axi-s tuser
    //     .IPRECISION     (8),                            // Input precision in bits
    //     .OPRECISION     (32),                           // Output precision in bits
    //     .LANES          (DATAW / IPRECISION),           // Number of dot-product INT8 lanes
    //     .DPES           (LANES),                        // Number of dot-product engines
    //     .NODES          (512),		      	            // Max number of nodes in each NoC
    //     .NODESW         ($clog2(NODES)),                // Bitwidth of store node ID
    //     .RFDEPTH        (512),                          // Depth of register files (RFs)
    //     .RFADDRW        ($clog2(RFDEPTH)),              // Bitwidth of RF address
    //     .INSTW          (1 + NODESW + 2 * RFADDRW + 4), // Instruction bitwidth {release_op, release_dest, rf_raddr, accum_raddr, last, release, accum_en, reduce, jump, en}
    //     .INSTD          (512),                          // Depth of instruction FIFO
    //     .INSTADDRW      ($clog2(INSTD)),                // Bitwidth of instruction memory address
    //     .AXIS_OPS       (4),                            // Number of AXI-S operations (max 4) {instruction, reduction vector, input vector, matrix}
    //     .AXIS_OPSW      ($clog2(AXIS_OPS)),
    //     .FIFOD          (64),                           // Depth of input, accumulation, and output FIFOs
    //     .DATAPATH_DELAY (2)                             // Delay of datpath (inputs -> result)
    // ) mvm_inst_3 (
    //     .clk(CLK),                                      // input
    //     .rst(~RST_N),                                   // input

    //     .axis_rx_tvalid  (axis_out_tvalid [1][0]),       // input
    //     .axis_rx_tdata   (axis_out_tdata  [1][0][DATAW-1:0]),       // input
    //     // .axis_rx_tstrb(axis_out_tstrb  [1][0]),       // input
    //     // .axis_rx_tkeep(axis_out_tkeep  [1][0]),       // input
    //     // .axis_rx_tid  (axis_out_tid    [1][0]),       // input
    //     .axis_rx_tdest   (axis_out_tdest  [1][0]),       // input
    //     .axis_rx_tuser   (axis_out_tuser  [1][0]),       // input
    //     .axis_rx_tlast   (axis_out_tlast  [1][0]),       // input
    //     .axis_rx_tready  (axis_out_tready [1][0]),       // output

    //     .axis_tx_tvalid  (axis_in_tvalid  [1][0]),       // output
    //     .axis_tx_tdata   (axis_in_tdata   [1][0][DATAW-1:0]),       // output
    //     // .axis_tx_tstrb(axis_in_tstrb   [1][0]),       // output
    //     // .axis_tx_tkeep(axis_in_tkeep   [1][0]),       // output
    //     // .axis_tx_tid  (axis_in_tid     [1][0]),       // output
    //     .axis_tx_tdest   (axis_in_tdest   [1][0]),       // output
    //     .axis_tx_tuser   (axis_in_tuser   [1][0]),       // output
    //     .axis_tx_tlast   (axis_in_tlast   [1][0]),       // output
    //     .axis_tx_tready  (axis_in_tready  [1][0])        // input
    // );

    //     rtl_mvm #(
    //     .DATAW          (DATAW),                          // Bitwidth of axi-s tdata
    //     .BYTEW          (BYTEW),   		                    // Bitwidth of axi-s tkeep, tstrb
    //     .IDW            (IDW),                              // Bitwidth of axi-s tid
    //     .DESTW          (DESTW),		                    // Bitwidth of axi-s tdest
    //     .USERW          (USERW),                            // Bitwidth of axi-s tuser
    //     .IPRECISION     (8),                            // Input precision in bits
    //     .OPRECISION     (32),                           // Output precision in bits
    //     .LANES          (DATAW / IPRECISION),           // Number of dot-product INT8 lanes
    //     .DPES           (LANES),                        // Number of dot-product engines
    //     .NODES          (512),		      	            // Max number of nodes in each NoC
    //     .NODESW         ($clog2(NODES)),                // Bitwidth of store node ID
    //     .RFDEPTH        (512),                          // Depth of register files (RFs)
    //     .RFADDRW        ($clog2(RFDEPTH)),              // Bitwidth of RF address
    //     .INSTW          (1 + NODESW + 2 * RFADDRW + 4), // Instruction bitwidth {release_op, release_dest, rf_raddr, accum_raddr, last, release, accum_en, reduce, jump, en}
    //     .INSTD          (512),                          // Depth of instruction FIFO
    //     .INSTADDRW      ($clog2(INSTD)),                // Bitwidth of instruction memory address
    //     .AXIS_OPS       (4),                            // Number of AXI-S operations (max 4) {instruction, reduction vector, input vector, matrix}
    //     .AXIS_OPSW      ($clog2(AXIS_OPS)),
    //     .FIFOD          (64),                           // Depth of input, accumulation, and output FIFOs
    //     .DATAPATH_DELAY (2)                             // Delay of datpath (inputs -> result)
    // ) mvm_inst_4 (
    //     .clk(CLK),                                      // input
    //     .rst(~RST_N),                                   // input

    //     .axis_rx_tvalid  (axis_out_tvalid [1][1]),       // input
    //     .axis_rx_tdata   (axis_out_tdata  [1][1][DATAW-1:0]),       // input
    //     // .axis_rx_tstrb(axis_out_tstrb  [1][1]),       // input
    //     // .axis_rx_tkeep(axis_out_tkeep  [1][1]),       // input
    //     // .axis_rx_tid  (axis_out_tid    [1][1]),       // input
    //     .axis_rx_tdest   (axis_out_tdest  [1][1]),       // input
    //     .axis_rx_tuser   (axis_out_tuser  [1][1]),       // input
    //     .axis_rx_tlast   (axis_out_tlast  [1][1]),       // input
    //     .axis_rx_tready  (axis_out_tready [1][1]),       // output

    //     .axis_tx_tvalid  (AXIS_M_TVALID),                // output
    //     .axis_tx_tdata   (AXIS_M_TDATA [DATAW-1:0]),                // output
    //     // .axis_tx_tstrb(AXIS_M_TSTRB ),                // output
    //     // .axis_tx_tkeep(AXIS_M_TKEEP ),                // output
    //     // .axis_tx_tid  (AXIS_M_TID   ),                // output
    //     .axis_tx_tdest   (AXIS_M_TDEST ),                // output
    //     .axis_tx_tuser   (AXIS_M_TUSER ),                // output
    //     .axis_tx_tlast   (AXIS_M_TLAST ),                // output
    //     .axis_tx_tready  (AXIS_M_TREADY)                 // input
    // );

    // -------------------------------------------------------
    // Axis Mesh
    // -------------------------------------------------------

    axis_mesh #(
        .NUM_ROWS                   (ROWS),
        .NUM_COLS                   (COLUMNS),
        .PIPELINE_LINKS             (1),

        .TDEST_WIDTH                (TDESTW),
        .TDATA_WIDTH                (TDATAW),
        .SERIALIZATION_FACTOR       (1),
        .CLKCROSS_FACTOR            (1),
        .SINGLE_CLOCK               (1),
        .SERDES_IN_BUFFER_DEPTH     (16),
        .SERDES_OUT_BUFFER_DEPTH    (16),
        .SERDES_EXTRA_SYNC_STAGES   (0),

        .FLIT_BUFFER_DEPTH          (16),
        .ROUTING_TABLE_PREFIX       (ROUTING_TABLES_DIR),
        .ROUTER_PIPELINE_OUTPUT     (1),
        .DISABLE_SELFLOOP           (0),
        .ROUTER_FORCE_MLAB          (0)
    ) axis_mesh_inst (
        .clk_noc         (CLK_NOC),
        .clk_usr         (CLK),
        .rst_n           (RST_N),

        .axis_in_tvalid  (axis_in_tvalid),
        .axis_in_tready  (axis_in_tready),
        .axis_in_tdata   (mesh_in_tdata),
        .axis_in_tlast   (axis_in_tlast),
        // .axis_in_tuser   (axis_in_tuser),
        // .axis_in_tid  (axis_in_tid),
        .axis_in_tdest   (axis_in_tdest),

        .axis_out_tvalid (axis_out_tvalid),
        .axis_out_tready (axis_out_tready),
        .axis_out_tdata  (mesh_out_tdata),
        .axis_out_tlast  (axis_out_tlast),
        // .axis_out_tuser  (axis_out_tuser),
        // .axis_out_tid (axis_out_tid),
        .axis_out_tdest  (axis_out_tdest)
    );

endmodule
