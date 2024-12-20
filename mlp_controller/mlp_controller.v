module mlp_controller (
					input [3:0] address,
					input chipselect,
					input clk,
					input read,
					input reset_n,
					input write,
					input [31:0] writedata,
					output [9:0] led_out,
					output reg [31:0] readdata
					);
	 parameter DATAW = 128;
    parameter IDW = 4;
	 parameter DESTW = 12;
	 parameter USERW = 75;
	 
    reg             axis_s_tvalid;
    reg [DATAW-1:0] axis_s_tdata;
    reg [  IDW-1:0] axis_s_tid;
    reg [DESTW-1:0] axis_s_tdest;
    reg [USERW-1:0] axis_s_tuser;
    reg             axis_s_tlast;
    wire            axis_s_tready;
    
    wire              axis_m_tvalid;
    wire [ DATAW-1:0] axis_m_tdata;
    wire [  IDW-1:0]  axis_m_tid;
    wire [DESTW-1:0]  axis_m_tdest;
    wire [USERW-1:0]  axis_m_tuser;
    wire              axis_m_tlast;
    reg               axis_m_tready = 1;
	 
	 reg [31:0] mvm_control_reg; // Bits 31:7 = empty, bits 6:5 = op, bits 4:1 = dest, bit 0 = send data to noc
	 reg [127:0] mvm_input_reg;
	 reg [31:0] mvm_instruction_reg;
	 reg [127:0] mvm_output_reg;
	 reg mvm_output_ready_reg;
	 reg send_mvm_input;
	 
	 // Control reg 
	 always @(posedge clk) begin
		if(reset_n == 1'b0)
			mvm_control_reg <= 0;
		// Reset send data bit if it was set
		else if(mvm_control_reg[0] == 1'b1)
			mvm_control_reg[0] <= 0;
		// Write control reg
		else if(chipselect && write && (address == 4'h0))
			mvm_control_reg <= writedata;
	 end
	 
	 // Input reg
    always @(posedge clk) begin
		if(reset_n == 1'b0) begin
			mvm_input_reg <= 0;
		end
		// Write input reg 1
		else if(chipselect && write && (address == 4'h1)) 
			mvm_input_reg[31:0] <= writedata;
		// Write input reg 2
		else if(chipselect && write && (address == 4'h2)) 
			mvm_input_reg[63:32] <= writedata;
		// Write input reg 3
		else if(chipselect && write && (address == 4'h3))
			mvm_input_reg[95:64] <= writedata;
		// Write input reg 4
	   else if(chipselect && write && (address == 4'h4))
		   mvm_input_reg[127:96] <= writedata;
    end
	 
	 // Instuction reg
    always @(posedge clk) begin
		if(reset_n == 1'b0) begin
			mvm_instruction_reg <= 0;
		end
		// Write instruction reg
		else if(chipselect && write && (address == 4'h5)) 
			mvm_instruction_reg <= writedata;
    end
	 
	 // Output reg
	 always @(posedge clk) begin
		if(reset_n == 1'b0) 
			mvm_output_reg <= 0;
		else if (axis_m_tvalid)
			mvm_output_reg <= axis_m_tdata;
	 end
	 
	 // Readdata
	 always @(posedge clk) begin
		if(reset_n == 1'b0) 
			readdata <= 0;
		// Read control reginput reg 1
		else if(chipselect && read && (address == 4'h0))
			readdata <= mvm_control_reg;
		// Read input reg 1
		else if(chipselect && read && (address == 4'h1)) 
			readdata <= mvm_input_reg[31:0];
		// Read input reg 2
		else if(chipselect && read && (address == 4'h2))
			readdata <= mvm_input_reg[63:32];
		// Read input reg 3
		else if(chipselect && read && (address == 4'h3)) 
			readdata <= mvm_input_reg[95:64];
		// Read input reg 4
		else if(chipselect && read && (address == 4'h4))
			readdata <= mvm_input_reg[127:96];
		// Read instuction reg
		else if(chipselect && read && (address == 4'h5))
			readdata <= mvm_instruction_reg;
		// Read output reg 1
		else if(chipselect && read && (address == 4'h6))
			readdata <= mvm_output_reg[31:0];
		// Read output reg 2
		else if(chipselect && read && (address == 4'h7)) 
			readdata <= mvm_output_reg[63:32];
		// Read output reg 3
		else if(chipselect && read && (address == 4'h8))
			readdata <= mvm_output_reg[95:64];
		// Read output reg 4
		else if(chipselect && read && (address == 4'h9)) 
			readdata <= mvm_output_reg[127:96];
		else if(chipselect && read && (address == 4'hA)) begin
			readdata[31:1] <= 0;
			readdata[0] <= mvm_output_ready_reg;
		end
	 end
	 
	 // Data ready reg
	 always @(posedge clk) begin
		if(reset_n == 1'b0)
			mvm_output_ready_reg <= 0;
		else if(axis_m_tvalid)
			mvm_output_ready_reg <= 1;
		else if(chipselect && read && (address == 4'h6 || address == 4'h7 || address == 4'h8 || address == 4'h9))
			mvm_output_ready_reg <= 0;
	 end
	 
	 // Handle AXI signals to MVM Noc
	 always @(posedge clk) begin
		if(reset_n == 1'b0) begin
			axis_s_tvalid <= 0;
			axis_s_tdata <= 0;
			axis_s_tlast <= 0;
			axis_s_tuser <= 0;
			axis_s_tdest <= 0;
		end
		else if (mvm_control_reg[0] == 1'b0) begin
			axis_s_tvalid <= 0;
			axis_s_tdata <= 0;
			axis_s_tlast <= 0;
		end 
		else if(mvm_control_reg[0] == 1'b1) begin
			axis_s_tvalid <= 1;
			if(mvm_control_reg[6:5] == 2'b0) 
				axis_s_tdata <= mvm_instruction_reg;
			else
				axis_s_tdata <= mvm_input_reg;
			
			// TODO in order to send weights, I need to change the code so the user can set the following bits
			// For not they will just be set to 0
			axis_s_tuser[8:0  ] <=   9'b0;
			axis_s_tuser[74:11] <=  64'b0;
			
			// User controlled bits
			axis_s_tuser[10:9 ] <= mvm_control_reg[6:5]; 
			axis_s_tdest <= mvm_control_reg[4:1]; 
			
			axis_s_tlast <= 1;
		end 
    end
	 
	 assign led_out = mvm_output_reg[9:0];
	 
    mvm_noc top (
        .CLK           (           clk ),
        .CLK_NOC       (       	  clk ),
        .RST_N         (       reset_n ),
        .AXIS_S_TVALID ( axis_s_tvalid ),
        .AXIS_S_TREADY ( axis_s_tready ),
        .AXIS_S_TDATA  (  axis_s_tdata ),
        .AXIS_S_TLAST  (  axis_s_tlast ),
        .AXIS_S_TID    (    axis_s_tid ),
        .AXIS_S_TUSER  (  axis_s_tuser ),
        .AXIS_S_TDEST  (  axis_s_tdest ),
        .AXIS_M_TVALID ( axis_m_tvalid ),
        .AXIS_M_TREADY ( axis_m_tready ),
        .AXIS_M_TDATA  (  axis_m_tdata ),
        .AXIS_M_TLAST  (  axis_m_tlast ),
        .AXIS_M_TID    (    axis_m_tid ),
        .AXIS_M_TUSER  (  axis_m_tuser ),
        .AXIS_M_TDEST  (  axis_m_tdest )
    );
endmodule