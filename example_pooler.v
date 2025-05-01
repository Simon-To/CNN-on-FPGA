//file: pooler.v
//this is the top module of the pooling unit and it instantiates several sub-blocks which are explained further in the article
`timescale 1ns / 1ps

module pooler #(
    parameter m = 9'h00c, //size of input image/activation map (post convolution)
    parameter p = 9'h003, //size of pooling window
    parameter N = 16,     //total bitwidth of data
    parameter Q = 12,     //number of fractional bits in the Fixed Point representation
    parameter ptype = 0,  //ptype = 0 -> max pooling, ptype = 1 -> average pooling
    parameter p_sqr_inv = 16'b0000010000000000 //this parameter is needed in average pooling case 												where the sum is divided by p**2.
                                               //It needs to be supplied manually and should be equal 											  to (1/p)^2 in whatever the
                                               //(Q,N) format is being used.
    )(
    input clk,
    input ce,
    input master_rst,
    input [N-1:0] data_in,
    output [N-1:0] data_out,
    output valid_op,               //output signal to indicate the valid output
    output end_op                  //output signal to indicate when all the valid outputs have been  
                                   //produced for that particular input matrix
    );

    wire rst_m,op_en,pause_ip,load_sr,global_rst;
    wire [1:0] sel;
    wire [N-1:0] comp_op;
    wire [N-1:0] sr_op;
    wire [N-1:0] max_reg_op;
    wire [N-1:0] div_op;
    wire ovr;
    wire [N-1:0] mux_out;
    wire temp2;
    reg [N-1:0] temp;
    
    control_logic2 #(m,p) log(          //This block is the brains of this pooling unit. It generates 
                                        //the various signals needed to control all the other blocks 
        .clk(clk),                      //in the pooling unit.
        .master_rst(master_rst),
        .ce(ce),
        .sel(sel),
        .rst_m(rst_m),
        .valid_op(valid_op),
        .load_sr(load_sr),
        .global_rst(global_rst),
        .end_op(end_op)
      );
    
    comparator2 #(.N(N),.ptype(ptype)) cmp(  //ptype = 0 -> This comparator outputs the maximum of
        .ip1(data_in),                       //the two inputs. 
        .ip2(mux_out),                       //ptype = 1 -> This comparator outputs the sum of the 
        .comp_op(comp_op)                    //two inputs.
      );
  
    max_reg #(.N(N)) m1(                     //A simple register to hold the current maximum/sum 	 
        .clk(clk),                           //value. It can also be reset to zero
        .din(comp_op),
        .rst_m(rst_m),
        .global_rst(temp2),
        .master_rst(master_rst),
        .reg_op(reg_op)
      );
    
   variable_shift_reg #(.WIDTH(N),.SIZE((m/p))) SR (
      .d(comp_op),                                 // input [N-1 : 0] d
      .clk(clk),                                   // input clk
      .ce(load_sr),                                // input ce
      .rst(global_rst && master_rst),              // input sclr
      .out(Q)                                      // output [N-1 : 0] q
      );

   input_mux #(.N(N)) mux(                   //the multiplexer that controls one input of the 
       .ip1(Q),                              //comparator (refer post title image)
       .ip2(reg_op),
       .sel(sel),
       .op(mux_out)
       );

   qmult #(N,Q) mul (max_reg_op,p_sqr_inv,div_op,ovr);  //fixed point multiplier
    
   assign data_out = ptype ? div_op : max_reg_op; //for average pooling, we output the sum divided by 												 p**2 
   
endmodule