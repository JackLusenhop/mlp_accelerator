module axis_passthrough #(
    parameter DATAW = 32,  // Data width
    parameter IDW   = 4,   // ID width
    parameter USERW = 4,   // User width
    parameter DESTW = 4    // Destination width
)(
    input   wire                  CLK,
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
    // Pass-through logic
    // -------------------------------------------------------
    always_ff @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            AXIS_M_TVALID <= 1'b0;
            AXIS_S_TREADY <= 1'b0;
            AXIS_M_TDATA  <= {DATAW{1'b0}};
            AXIS_M_TLAST  <= 1'b0;
            AXIS_M_TID    <= {IDW{1'b0}};
            AXIS_M_TUSER  <= {USERW{1'b0}};
            AXIS_M_TDEST  <= {DESTW{1'b0}};
        end else begin
            AXIS_M_TVALID <= AXIS_S_TVALID;
            AXIS_S_TREADY <= AXIS_M_TREADY;
            AXIS_M_TDATA  <= AXIS_S_TDATA;
            AXIS_M_TLAST  <= AXIS_S_TLAST;
            AXIS_M_TID    <= AXIS_S_TID;
            AXIS_M_TUSER  <= AXIS_S_TUSER;
            AXIS_M_TDEST  <= AXIS_S_TDEST;
        end
    end

endmodule
