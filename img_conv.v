`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2021 16:52:10
// Design Name: 
// Module Name: img_conv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module img_conv#(Datawidth = 8, Img_W = 512, Img_H = 512, K_W = 3, K_H = 3)(

    input [Datawidth-1:0]in_img_data,
    input img_valid,
    
    output reg [Datawidth-1:0]out_img_data,
    output reg conv_valid,
    
    input clk,
    input reset
    
    );
    
    
    reg [Datawidth-1:0] in_img [Img_W-1:0][Img_H-1:0];
    //reg [7:0] out_img [511-2:0][511-2:0];
    reg [21:0] sum;
    reg [20:0] sum1;
    reg [20:0] sum2;
    
    reg [7:0] filter_h[2:0][2:0];
    reg [7:0] filter_v[2:0][2:0];
    reg [7:0] filter_GS[4:0][4:0];
    
    
    integer i,j,m,n;
    
    initial
    begin
        
        
        //Sobel
        filter_h[0][0] = 1 ;  filter_h[0][1] = 0 ;  filter_h[0][2] = -1 ;
        filter_h[1][0] = 2 ;  filter_h[1][1] = 0 ;  filter_h[1][2] = -2 ;
        filter_h[2][0] = 1 ;  filter_h[2][1] = 0 ;  filter_h[2][2] = -1 ;
        
        filter_v[0][0] =  1 ;  filter_v[0][1] =  2 ;  filter_v[0][2] =  1 ;
        filter_v[1][0] =  0 ;  filter_v[1][1] =  0 ;  filter_v[1][2] =  0 ;
        filter_v[2][0] = -1 ;  filter_v[2][1] = -2 ;  filter_v[2][2] = -1 ;
        
        //Gaussian Smoothing sigma = 1
        
        filter_GS[0][0] = 1;   filter_GS[0][1] =  4;  filter_GS[0][2] =  7;  filter_GS[0][3] =  4;  filter_GS[0][4] = 1;
        filter_GS[1][0] = 4;   filter_GS[1][1] = 16;  filter_GS[1][2] = 26;  filter_GS[1][3] = 16;  filter_GS[1][4] = 4;
        filter_GS[2][0] = 7;   filter_GS[2][1] = 26;  filter_GS[2][2] = 41;  filter_GS[2][3] = 26;  filter_GS[2][4] = 7;
        filter_GS[3][0] = 4;   filter_GS[3][1] = 16;  filter_GS[3][2] = 26;  filter_GS[3][3] = 16;  filter_GS[3][4] = 4;
        filter_GS[4][0] = 1;   filter_GS[4][1] =  4;  filter_GS[4][2] =  7;  filter_GS[4][3] =  4;  filter_GS[4][4] = 1;
        
        
        
    end
    
    always @(posedge clk)
    begin
    if(reset)
    begin
        sum = 20'b0;
        sum1 = 20'b0;
        sum2 = 20'b0;
        conv_valid = 1'b0;        
    end
    else
    begin
        if(!img_valid) //read the image
        begin
            for(i = 0; i< Img_W; i=i+1)
            begin
            for(j = 0; j< Img_H; j=j+1)
            begin
                in_img[i][j] = in_img_data;
                @(posedge clk);                
            end 
            end   
            
        end
        
        
        else
        
        begin
        //for 510x510 header needs to be changed
//          for(i=0; i<Img_W-K_W+1; i=i+1)
//              for(j=0; j<Img_H-K_H+1; j=j+1)
              for(i=0; i<Img_W; i=i+1)
              for(j=0; j<Img_H; j=j+1)
              begin
                  sum = 20'b0;
                  sum1 = 20'b0;
                  sum2 = 20'b0;
                  for(m=0; m<K_W; m=m+1)
                  for(n=0 ; n<K_H; n=n+1)
                  begin
                    //Average
                      //sum = sum + ( in_img[i+m][j+n] * 1);
                   //Sobel
                      sum1 = $signed(sum1) + ( ($signed({1'b0,in_img[i+m][j+n]})) * $signed( filter_h [m][n]));
                      sum2 = $signed(sum2) + ( ($signed({1'b0,in_img[i+m][j+n]})) * $signed( filter_v [m][n]));
                   //Gaussian Smoothing
                      //  sum = sum + ( in_img[i+m][j+n] * filter_GS[m][n]);                        
                     
                  end
                  
                  //sum = sum / 9; //for Average
                    sum1 = $signed(sum1)*$signed(sum1);
                    sum2 = $signed(sum2)*$signed(sum2);
                    sum = sum1+sum2; //for Sobel
                   if(sum>4000)
                    sum = 8'hff;
                   else
                    sum = 8'h00;
                  //sum = sum / 273; // for Gaussian Smoothing
                 
                                    
                  conv_valid = 1'b1;
                  out_img_data = sum;
                  @(posedge clk);
              end                          
        end  
    end
    end
    
endmodule
