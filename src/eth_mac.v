`timescale 1 ns / 1 ps

(* keep_hierarchy = "yes" *)
module eth_mac
(
	input         clk_mac,
	input         clk_phy,
	input         rst_n,
	input [2:0]   mode_straps,
	
	output        eth_mdc,
	inout         eth_mdio,
	output        eth_rstn,
	inout         eth_crsdv,
	inout         eth_rxerr,
	inout  [1:0]  eth_rxd,
	output        eth_txen,
	output [1:0]  eth_txd,
	output        eth_clkin,
	inout         eth_intn,
	
	output        rx_vld,
	output [7:0]  rx_dat,
	output        rx_sof,
	output        rx_eof,
	output        rx_err,
	
	input         tx_vld,
	input [7:0]   tx_dat,
	input         tx_sof,
	input         tx_eof,
	output        tx_ack,
	
	input         reg_vld,
	input  [4:0]  reg_addr,
	input         reg_write,
	input  [15:0] reg_wval,
	output [15:0] reg_rval,
	output        reg_ack,
	
	output        speed_100,
	output        full_duplex,
	output        link_up,
	output        remote_fault,
	output        auto_neg_done
);

	assign eth_rstn  = rst_n;
	assign eth_clkin = clk_phy;
	
	reg rstn_d;
	always @(posedge clk_mac)
		rstn_d <= rst_n;
	
	wire       eth_crsdv_in;
	wire [1:0] eth_rxd_in;
	wire       eth_rxerr_in;
	wire       eth_intn_in;
	IOBUF rxd0_buf 
	(
		.O (eth_rxd_in[0]),
		.IO(eth_rxd[0]),
		.I (mode_straps[0]),
		.T (rstn_d)
	);
	
	IOBUF rxd1_buf 
	(
		.O (eth_rxd_in[1]),
		.IO(eth_rxd[1]),
		.I (mode_straps[1]),
		.T (rstn_d)
	);
	
	IOBUF crsdv_buf 
	(
		.O (eth_crsdv_in),
		.IO(eth_crsdv),
		.I (mode_straps[2]),
		.T (rstn_d)
	);
	
	IOBUF rxerr_buf 
	(
		.O (eth_rxerr_in),
		.IO(eth_rxerr),
		.I (1'b1),
		.T (rstn_d)
	);
	
	IOBUF intn_buf 
	(
		.O (eth_intn_in),
		.IO(eth_intn),
		.I (1'b1),
		.T (rstn_d)
	);
	

	eth_config eth_config_inst
	(
		.clk_mac      (clk_mac),
		.rst_n        (rstn_d),
		
		.eth_intn     (eth_intn),
		.eth_mdc      (eth_mdc),
		.eth_mdio     (eth_mdio),
		
		.reg_vld      (reg_vld),
		.reg_addr     (reg_addr),
		.reg_write    (reg_write),
		.reg_wval     (reg_wval),
		.reg_rval     (reg_rval),
		.reg_ack      (reg_ack),
		
		.speed_100    (speed_100),
		.full_duplex  (full_duplex),
		.link_up      (link_up),
		.remote_fault (remote_fault),
		.auto_neg_done(auto_neg_done)
	);
	
	eth_rx eth_rx_inst
	(
		.clk_mac  (clk_mac),
		.rst_n    (rstn_d),
		
		.eth_crsdv(eth_crsdv_in),
		.eth_rxerr(eth_rxerr_in),
		.eth_rxd  (eth_rxd_in),
		
		.rx_vld   (rx_vld),
		.rx_dat   (rx_dat),
		.rx_sof   (rx_sof),
		.rx_eof   (rx_eof),
		.rx_err   (rx_err)
	);
	
	eth_tx eth_tx_inst
	(
		.clk_mac (clk_mac),
		.rst_n   (rstn_d),
	
		.eth_txd (eth_txd),	
		.eth_txen(eth_txen),
	
		.tx_vld  (tx_vld),
		.tx_dat  (tx_dat),
		.tx_sof  (tx_sof),
		.tx_eof  (tx_eof),
		.tx_ack  (tx_ack)
	);

endmodule