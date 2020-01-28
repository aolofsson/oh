module zcu102_base(/*AUTOARG*/
   // Outputs
   s_axi_wready, s_axi_rvalid, s_axi_rresp, s_axi_rlast, s_axi_rid,
   s_axi_rdata, s_axi_bvalid, s_axi_bresp, s_axi_bid, s_axi_awready,
   s_axi_arready, m_axi_wvalid, m_axi_wstrb, m_axi_wlast, m_axi_wid,
   m_axi_wdata, m_axi_rready, m_axi_bready, m_axi_awvalid,
   m_axi_awsize, m_axi_awqos, m_axi_awprot, m_axi_awlock, m_axi_awlen,
   m_axi_awid, m_axi_awcache, m_axi_awburst, m_axi_awaddr,
   m_axi_arvalid, m_axi_arsize, m_axi_arqos, m_axi_arprot,
   m_axi_arlock, m_axi_arlen, m_axi_arid, m_axi_arcache,
   m_axi_arburst, m_axi_araddr, cclk_n, cclk_p, chip_nreset, chipid,
   elink_active, mailbox_irq, i2c_scl_i, i2c_sda_i, ps_gpio_i,
   txo_data_n, txo_data_p, txo_frame_n, txo_frame_p, txo_lclk_n,
   txo_lclk_p, rxo_rd_wait_n, rxo_rd_wait_p, rxo_wr_wait_n,
   rxo_wr_wait_p, constant_zero, constant_one,
   // Inouts
   i2c_scl, i2c_sda, gpio_n, gpio_p,
   // Inputs
   s_axi_wvalid, s_axi_wstrb, s_axi_wlast, s_axi_wid, s_axi_wdata,
   s_axi_rready, s_axi_bready, s_axi_awvalid, s_axi_awsize,
   s_axi_awqos, s_axi_awprot, s_axi_awlock, s_axi_awlen, s_axi_awid,
   s_axi_awcache, s_axi_awburst, s_axi_awaddr, s_axi_arvalid,
   s_axi_arsize, s_axi_arqos, s_axi_arprot, s_axi_arlock, s_axi_arlen,
   s_axi_arid, s_axi_aresetn, s_axi_arcache, s_axi_arburst,
   s_axi_araddr, m_axi_wready, m_axi_rvalid, m_axi_rresp, m_axi_rlast,
   m_axi_rid, m_axi_rdata, m_axi_bvalid, m_axi_bresp, m_axi_bid,
   m_axi_awready, m_axi_arready, m_axi_aresetn, sys_clk, sys_nreset,
   i2c_scl_o, i2c_scl_t, i2c_sda_o, i2c_sda_t, ps_gpio_o, ps_gpio_t,
   txi_rd_wait_n, txi_rd_wait_p, txi_wr_wait_n, txi_wr_wait_p,
   rxi_data_n, rxi_data_p, rxi_frame_n, rxi_frame_p, rxi_lclk_n,
   rxi_lclk_p
   );

   parameter AW          = 32;
   parameter DW          = 32; 
   parameter PW          = 104;      //packet width   
   parameter ID          = 12'h810;
   parameter S_IDW       = 12;       //ID width for S_AXI
   parameter M_IDW       = 6;        //ID width for M_AXI
   parameter IOSTD_ELINK = "LVDS";
   parameter NGPIO       = 24;
   parameter NPS         = 64;       //Number of PS signals

   //RESET+CLK
   input                sys_clk;
   input                sys_nreset;

   //MISC
   output               cclk_n; 
   output               cclk_p; 
   output               chip_nreset;
   output [11:0]        chipid; 
   output               elink_active;
   output               mailbox_irq;
   
   //I2C
   output               i2c_scl_i;
   output               i2c_sda_i;
   input                i2c_scl_o;
   input                i2c_scl_t;
   input                i2c_sda_o;
   input                i2c_sda_t;
    inout               i2c_scl;
   inout                i2c_sda;

   //GPIO
   input [NPS-1:0]      ps_gpio_o;
   input [NPS-1:0]      ps_gpio_t;
   output [NPS-1:0]     ps_gpio_i;
   inout [NGPIO-1:0]    gpio_n; 
   inout [NGPIO-1:0]    gpio_p; 

   //TX
   output [7:0]         txo_data_n;
   output [7:0]         txo_data_p;
   output               txo_frame_n;
   output               txo_frame_p;
   output               txo_lclk_n;
   output               txo_lclk_p;
   input                txi_rd_wait_n;
   input                txi_rd_wait_p;
   input                txi_wr_wait_n;
   input                txi_wr_wait_p;

   //RX
   input [7:0]          rxi_data_n;
   input [7:0]          rxi_data_p;
   input                rxi_frame_n;
   input                rxi_frame_p;
   input                rxi_lclk_n;
   input                rxi_lclk_p;
   output               rxo_rd_wait_n;
   output               rxo_rd_wait_p;
   output               rxo_wr_wait_n;
   output               rxo_wr_wait_p;
   output               constant_zero;
   output               constant_one;

   /*AUTOINOUT*/
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]        m_axi_araddr;           // From axi_elink of axi_elink.v
   output [1:0]         m_axi_arburst;          // From axi_elink of axi_elink.v
   output [3:0]         m_axi_arcache;          // From axi_elink of axi_elink.v
   output [M_IDW-1:0]   m_axi_arid;             // From axi_elink of axi_elink.v
   output [7:0]         m_axi_arlen;            // From axi_elink of axi_elink.v
   output               m_axi_arlock;           // From axi_elink of axi_elink.v
   output [2:0]         m_axi_arprot;           // From axi_elink of axi_elink.v
   output [3:0]         m_axi_arqos;            // From axi_elink of axi_elink.v
   output [2:0]         m_axi_arsize;           // From axi_elink of axi_elink.v
   output               m_axi_arvalid;          // From axi_elink of axi_elink.v
   output [31:0]        m_axi_awaddr;           // From axi_elink of axi_elink.v
   output [1:0]         m_axi_awburst;          // From axi_elink of axi_elink.v
   output [3:0]         m_axi_awcache;          // From axi_elink of axi_elink.v
   output [M_IDW-1:0]   m_axi_awid;             // From axi_elink of axi_elink.v
   output [7:0]         m_axi_awlen;            // From axi_elink of axi_elink.v
   output               m_axi_awlock;           // From axi_elink of axi_elink.v
   output [2:0]         m_axi_awprot;           // From axi_elink of axi_elink.v
   output [3:0]         m_axi_awqos;            // From axi_elink of axi_elink.v
   output [2:0]         m_axi_awsize;           // From axi_elink of axi_elink.v
   output               m_axi_awvalid;          // From axi_elink of axi_elink.v
   output               m_axi_bready;           // From axi_elink of axi_elink.v
   output               m_axi_rready;           // From axi_elink of axi_elink.v
   output [63:0]        m_axi_wdata;            // From axi_elink of axi_elink.v
   output [M_IDW-1:0]   m_axi_wid;              // From axi_elink of axi_elink.v
   output               m_axi_wlast;            // From axi_elink of axi_elink.v
   output [7:0]         m_axi_wstrb;            // From axi_elink of axi_elink.v
   output               m_axi_wvalid;           // From axi_elink of axi_elink.v
   output               s_axi_arready;          // From axi_elink of axi_elink.v
   output               s_axi_awready;          // From axi_elink of axi_elink.v
   output [S_IDW-1:0]   s_axi_bid;              // From axi_elink of axi_elink.v
   output [1:0]         s_axi_bresp;            // From axi_elink of axi_elink.v
   output               s_axi_bvalid;           // From axi_elink of axi_elink.v
   output [31:0]        s_axi_rdata;            // From axi_elink of axi_elink.v
   output [S_IDW-1:0]   s_axi_rid;              // From axi_elink of axi_elink.v
   output               s_axi_rlast;            // From axi_elink of axi_elink.v
   output [1:0]         s_axi_rresp;            // From axi_elink of axi_elink.v
   output               s_axi_rvalid;           // From axi_elink of axi_elink.v
   output               s_axi_wready;           // From axi_elink of axi_elink.v
   // End of automatics
   /*AUTOINPUT*/   
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                m_axi_aresetn;          // To axi_elink of axi_elink.v
   input                m_axi_arready;          // To axi_elink of axi_elink.v
   input                m_axi_awready;          // To axi_elink of axi_elink.v
   input [M_IDW-1:0]    m_axi_bid;              // To axi_elink of axi_elink.v
   input [1:0]          m_axi_bresp;            // To axi_elink of axi_elink.v
   input                m_axi_bvalid;           // To axi_elink of axi_elink.v
   input [63:0]         m_axi_rdata;            // To axi_elink of axi_elink.v
   input [M_IDW-1:0]    m_axi_rid;              // To axi_elink of axi_elink.v
   input                m_axi_rlast;            // To axi_elink of axi_elink.v
   input [1:0]          m_axi_rresp;            // To axi_elink of axi_elink.v
   input                m_axi_rvalid;           // To axi_elink of axi_elink.v
   input                m_axi_wready;           // To axi_elink of axi_elink.v
   input [31:0]         s_axi_araddr;           // To axi_elink of axi_elink.v
   input [1:0]          s_axi_arburst;          // To axi_elink of axi_elink.v
   input [3:0]          s_axi_arcache;          // To axi_elink of axi_elink.v
   input                s_axi_aresetn;          // To axi_elink of axi_elink.v
   input [S_IDW-1:0]    s_axi_arid;             // To axi_elink of axi_elink.v
   input [7:0]          s_axi_arlen;            // To axi_elink of axi_elink.v
   input                s_axi_arlock;           // To axi_elink of axi_elink.v
   input [2:0]          s_axi_arprot;           // To axi_elink of axi_elink.v
   input [3:0]          s_axi_arqos;            // To axi_elink of axi_elink.v
   input [2:0]          s_axi_arsize;           // To axi_elink of axi_elink.v
   input                s_axi_arvalid;          // To axi_elink of axi_elink.v
   input [31:0]         s_axi_awaddr;           // To axi_elink of axi_elink.v
   input [1:0]          s_axi_awburst;          // To axi_elink of axi_elink.v
   input [3:0]          s_axi_awcache;          // To axi_elink of axi_elink.v
   input [S_IDW-1:0]    s_axi_awid;             // To axi_elink of axi_elink.v
   input [7:0]          s_axi_awlen;            // To axi_elink of axi_elink.v
   input                s_axi_awlock;           // To axi_elink of axi_elink.v
   input [2:0]          s_axi_awprot;           // To axi_elink of axi_elink.v
   input [3:0]          s_axi_awqos;            // To axi_elink of axi_elink.v
   input [2:0]          s_axi_awsize;           // To axi_elink of axi_elink.v
   input                s_axi_awvalid;          // To axi_elink of axi_elink.v
   input                s_axi_bready;           // To axi_elink of axi_elink.v
   input                s_axi_rready;           // To axi_elink of axi_elink.v
   input [31:0]         s_axi_wdata;            // To axi_elink of axi_elink.v
   input [S_IDW-1:0]    s_axi_wid;              // To axi_elink of axi_elink.v
   input                s_axi_wlast;            // To axi_elink of axi_elink.v
   input [3:0]          s_axi_wstrb;            // To axi_elink of axi_elink.v
   input                s_axi_wvalid;           // To axi_elink of axi_elink.v
   // End of automatics
   /*AUTOWIRE*/
   
   assign constant_zero = 1'b0;
   assign constant_one = 1'b1;


   /*axi_elink AUTO_TEMPLATE ( 
                        .m_axi_\(.*\) (m_axi_\1[]),
                        .s_axi_\(.*\) (s_axi_\1[]),
                       );
   */
   defparam axi_elink.ID=ID;   
   axi_elink axi_elink (
                        /*AUTOINST*/
                        // Outputs
                        .elink_active   (elink_active),
                        .rxo_wr_wait_p  (rxo_wr_wait_p),
                        .rxo_wr_wait_n  (rxo_wr_wait_n),
                        .rxo_rd_wait_p  (rxo_rd_wait_p),
                        .rxo_rd_wait_n  (rxo_rd_wait_n),
                        .txo_lclk_p     (txo_lclk_p),
                        .txo_lclk_n     (txo_lclk_n),
                        .txo_frame_p    (txo_frame_p),
                        .txo_frame_n    (txo_frame_n),
                        .txo_data_p     (txo_data_p[7:0]),
                        .txo_data_n     (txo_data_n[7:0]),
                        .chipid         (chipid[11:0]),
                        .chip_nreset    (chip_nreset),
                        .cclk_p         (cclk_p),
                        .cclk_n         (cclk_n),
                        .mailbox_irq    (mailbox_irq),
                        .m_axi_awid     (m_axi_awid[M_IDW-1:0]), // Templated
                        .m_axi_awaddr   (m_axi_awaddr[31:0]),    // Templated
                        .m_axi_awlen    (m_axi_awlen[7:0]),      // Templated
                        .m_axi_awsize   (m_axi_awsize[2:0]),     // Templated
                        .m_axi_awburst  (m_axi_awburst[1:0]),    // Templated
                        .m_axi_awlock   (m_axi_awlock),          // Templated
                        .m_axi_awcache  (m_axi_awcache[3:0]),    // Templated
                        .m_axi_awprot   (m_axi_awprot[2:0]),     // Templated
                        .m_axi_awqos    (m_axi_awqos[3:0]),      // Templated
                        .m_axi_awvalid  (m_axi_awvalid),         // Templated
                        .m_axi_wid      (m_axi_wid[M_IDW-1:0]),  // Templated
                        .m_axi_wdata    (m_axi_wdata[63:0]),     // Templated
                        .m_axi_wstrb    (m_axi_wstrb[7:0]),      // Templated
                        .m_axi_wlast    (m_axi_wlast),           // Templated
                        .m_axi_wvalid   (m_axi_wvalid),          // Templated
                        .m_axi_bready   (m_axi_bready),          // Templated
                        .m_axi_arid     (m_axi_arid[M_IDW-1:0]), // Templated
                        .m_axi_araddr   (m_axi_araddr[31:0]),    // Templated
                        .m_axi_arlen    (m_axi_arlen[7:0]),      // Templated
                        .m_axi_arsize   (m_axi_arsize[2:0]),     // Templated
                        .m_axi_arburst  (m_axi_arburst[1:0]),    // Templated
                        .m_axi_arlock   (m_axi_arlock),          // Templated
                        .m_axi_arcache  (m_axi_arcache[3:0]),    // Templated
                        .m_axi_arprot   (m_axi_arprot[2:0]),     // Templated
                        .m_axi_arqos    (m_axi_arqos[3:0]),      // Templated
                        .m_axi_arvalid  (m_axi_arvalid),         // Templated
                        .m_axi_rready   (m_axi_rready),          // Templated
                        .s_axi_arready  (s_axi_arready),         // Templated
                        .s_axi_awready  (s_axi_awready),         // Templated
                        .s_axi_bid      (s_axi_bid[S_IDW-1:0]),  // Templated
                        .s_axi_bresp    (s_axi_bresp[1:0]),      // Templated
                        .s_axi_bvalid   (s_axi_bvalid),          // Templated
                        .s_axi_rid      (s_axi_rid[S_IDW-1:0]),  // Templated
                        .s_axi_rdata    (s_axi_rdata[31:0]),     // Templated
                        .s_axi_rlast    (s_axi_rlast),           // Templated
                        .s_axi_rresp    (s_axi_rresp[1:0]),      // Templated
                        .s_axi_rvalid   (s_axi_rvalid),          // Templated
                        .s_axi_wready   (s_axi_wready),          // Templated
                        // Inputs
                        .sys_nreset     (sys_nreset),
                        .sys_clk        (sys_clk),
                        .rxi_lclk_p     (rxi_lclk_p),
                        .rxi_lclk_n     (rxi_lclk_n),
                        .rxi_frame_p    (rxi_frame_p),
                        .rxi_frame_n    (rxi_frame_n),
                        .rxi_data_p     (rxi_data_p[7:0]),
                        .rxi_data_n     (rxi_data_n[7:0]),
                        .txi_wr_wait_p  (txi_wr_wait_p),
                        .txi_wr_wait_n  (txi_wr_wait_n),
                        .txi_rd_wait_p  (txi_rd_wait_p),
                        .txi_rd_wait_n  (txi_rd_wait_n),
                        .m_axi_aresetn  (m_axi_aresetn),         // Templated
                        .m_axi_awready  (m_axi_awready),         // Templated
                        .m_axi_wready   (m_axi_wready),          // Templated
                        .m_axi_bid      (m_axi_bid[M_IDW-1:0]),  // Templated
                        .m_axi_bresp    (m_axi_bresp[1:0]),      // Templated
                        .m_axi_bvalid   (m_axi_bvalid),          // Templated
                        .m_axi_arready  (m_axi_arready),         // Templated
                        .m_axi_rid      (m_axi_rid[M_IDW-1:0]),  // Templated
                        .m_axi_rdata    (m_axi_rdata[63:0]),     // Templated
                        .m_axi_rresp    (m_axi_rresp[1:0]),      // Templated
                        .m_axi_rlast    (m_axi_rlast),           // Templated
                        .m_axi_rvalid   (m_axi_rvalid),          // Templated
                        .s_axi_aresetn  (s_axi_aresetn),         // Templated
                        .s_axi_arid     (s_axi_arid[S_IDW-1:0]), // Templated
                        .s_axi_araddr   (s_axi_araddr[31:0]),    // Templated
                        .s_axi_arburst  (s_axi_arburst[1:0]),    // Templated
                        .s_axi_arcache  (s_axi_arcache[3:0]),    // Templated
                        .s_axi_arlock   (s_axi_arlock),          // Templated
                        .s_axi_arlen    (s_axi_arlen[7:0]),      // Templated
                        .s_axi_arprot   (s_axi_arprot[2:0]),     // Templated
                        .s_axi_arqos    (s_axi_arqos[3:0]),      // Templated
                        .s_axi_arsize   (s_axi_arsize[2:0]),     // Templated
                        .s_axi_arvalid  (s_axi_arvalid),         // Templated
                        .s_axi_awid     (s_axi_awid[S_IDW-1:0]), // Templated
                        .s_axi_awaddr   (s_axi_awaddr[31:0]),    // Templated
                        .s_axi_awburst  (s_axi_awburst[1:0]),    // Templated
                        .s_axi_awcache  (s_axi_awcache[3:0]),    // Templated
                        .s_axi_awlock   (s_axi_awlock),          // Templated
                        .s_axi_awlen    (s_axi_awlen[7:0]),      // Templated
                        .s_axi_awprot   (s_axi_awprot[2:0]),     // Templated
                        .s_axi_awqos    (s_axi_awqos[3:0]),      // Templated
                        .s_axi_awsize   (s_axi_awsize[2:0]),     // Templated
                        .s_axi_awvalid  (s_axi_awvalid),         // Templated
                        .s_axi_bready   (s_axi_bready),          // Templated
                        .s_axi_rready   (s_axi_rready),          // Templated
                        .s_axi_wid      (s_axi_wid[S_IDW-1:0]),  // Templated
                        .s_axi_wdata    (s_axi_wdata[31:0]),     // Templated
                        .s_axi_wlast    (s_axi_wlast),           // Templated
                        .s_axi_wstrb    (s_axi_wstrb[3:0]),      // Templated
                        .s_axi_wvalid   (s_axi_wvalid));                 // Templated

endmodule // zcu102_base
// Local Variables:
// verilog-library-directories:("." "../../elink/hdl")
// End:

