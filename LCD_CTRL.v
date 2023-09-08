module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output IROM_rd;
output [5:0] IROM_A;
output reg IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output busy;
output done;

reg [2:0]cur_st,nex_st;
parameter IDLE =3'd0,READ=3'd1,CMD=3'd2,EXE=3'd3,WRITE=3'd4,DONE=3'd5 ;
reg [6:0]counter_64;
reg [2:0]counter_4;
reg [7:0]data[63:0];
reg exe_done;
reg [2:0]x_point,y_point;
reg [6:0]dot1,dot2,dot3,dot4;
reg [7:0]data1,data2,data3,data4,max,min,avg;
reg [9:0]sum;
reg counter_1;

always @(posedge clk or posedge reset) begin
    if(reset)
        cur_st<=IDLE;
    else 
        cur_st<=nex_st;
end

always @(*) begin
    case(cur_st)
        IDLE:nex_st=READ;
        READ:nex_st=(counter_64==63)?CMD:READ;
        CMD:nex_st=(cmd==0)?WRITE:EXE;//(counter_1)?((cmd==0)?WRITE:EXE):CMD;
        EXE:nex_st=(exe_done)?CMD:EXE;
        WRITE:nex_st=(counter_64==64)?DONE:WRITE;
        DONE:nex_st=DONE;
        default:nex_st=IDLE;
    endcase
end
//counter_1
always @(posedge clk or posedge reset) begin
    if(reset)
        counter_1<=0;
    else if(cur_st==CMD)
        counter_1<=1;
end

assign IROM_rd=(cur_st==READ)?1:0;
assign IROM_A=(cur_st==READ)?counter_64:0;
//assign IRAM_valid=(cur_st==WRITE)?1:0;
//assign IRAM_A=(cur_st==WRITE)?counter_64:0;
//assign IRAM_D=(cur_st==WRITE)?data[counter_64]:0;
assign done=(cur_st==DONE)?1:0;
assign busy=(cur_st==READ | cur_st==EXE | cur_st==IDLE)?1:0;

//IRAM_A
always @(posedge clk) begin
    if(cur_st==WRITE)
        IRAM_A<=counter_64;
end

always @(posedge clk) begin
    if(cur_st==WRITE)
        IRAM_D<=data[counter_64];
end

always @(posedge clk) begin
    if(cur_st==WRITE)
        IRAM_valid<=1;
    else
        IRAM_valid<=0;
end

//exe_done
always @(*) begin
    if(cur_st==EXE)begin
        if(cmd==0)begin
            if(counter_64==63)
                exe_done=1;
            else
                exe_done=0;
            end
        else if(cmd==4'b0101 | cmd==4'b0110)begin
            if(counter_4==5)//4?
                exe_done=1;
            else    
                exe_done=0;
         end
        else 
            exe_done=1;
    end
    else
        exe_done=0;
end

//counter_64
always @(posedge clk or posedge reset) begin
    if(reset)
        counter_64<=0;
    else if(cur_st==READ | cur_st==WRITE)
        counter_64<=counter_64+1;
    else
        counter_64<=0;
end

//counter_4
always @(posedge clk or posedge reset) begin
    if(reset)
        counter_4<=0;
    else if(cur_st==EXE)
        counter_4<=counter_4+1;
    else
        counter_4<=0;
end

//max
always @(posedge clk or posedge reset) begin
    if(reset)
        max<=0;
    else if(cur_st==EXE & cmd==4'b0101)begin
        case (counter_4)
            0:max<=data[dot1];
            1:max<=(data[dot2]>max)?data[dot2]:max;
            2:max<=(data[dot3]>max)?data[dot3]:max;
            3:max<=(data[dot4]>max)?data[dot4]:max;
            default: max<=0;
        endcase
    end
end

//min
always @(posedge clk or posedge reset) begin
    if(reset)
        min<=0;
    else if(cur_st==EXE & cmd==4'b0110)begin
        case (counter_4)
            0:min<=data[dot1];
            1:min<=(data[dot2]<min)?data[dot2]:min;
            2:min<=(data[dot3]<min)?data[dot3]:min;
            3:min<=(data[dot4]<min)?data[dot4]:min;
            default: min<=0;
        endcase
    end
end

//avg
always @(*) begin
    sum=(data[dot1]+data[dot2]+data[dot3]+data[dot4]);
    avg=sum[9:2];
end

//DATA
always @(posedge clk) begin
    if(cur_st==READ)
        data[counter_64]<=IROM_Q;
    else if(cur_st==EXE)begin
        case(cmd)
            4'b0101:begin//max
                if(counter_4==4)begin
                    data[dot1]<=max;
                    data[dot2]<=max;
                    data[dot3]<=max;
                    data[dot4]<=max;
                end
            end
            4'b0110:begin //min
                if(counter_4==4)begin
                    data[dot1]<=min;
                    data[dot2]<=min;
                    data[dot3]<=min;
                    data[dot4]<=min;
                end
            end
            4'b0111:begin//avg
                data[dot1]<= avg;
                data[dot2]<= avg;
                data[dot3]<= avg;
                data[dot4]<= avg;
            end
            4'b1000:begin//counterclock
                data[dot1]<=data[dot2];
                data[dot2]<=data[dot4];
                data[dot3]<=data[dot1];
                data[dot4]<=data[dot3];
            end
            4'b1001:begin//clockwise
                data[dot1]<=data[dot3];
                data[dot2]<=data[dot1];
                data[dot3]<=data[dot4];
                data[dot4]<=data[dot2];
            end
            4'b1010:begin//mirrir x
                data[dot1]<=data[dot3];
                data[dot2]<=data[dot4];
                data[dot3]<=data[dot1];
                data[dot4]<=data[dot2];
            end
            4'b1011:begin//mirror y
                data[dot1]<=data[dot2];
                data[dot2]<=data[dot1];
                data[dot3]<=data[dot4];
                data[dot4]<=data[dot3];
            end
        endcase
    end 
end

//x_point
always @(posedge clk or posedge reset) begin
    if(reset)
        x_point<=4;
    else if(cur_st==EXE)begin
        case(cmd)
            4'b0011:begin
                if(x_point>1)
                    x_point<=x_point-1;
                else    
                    x_point<=1;
            end
            4'b0100:begin
                if(x_point<7)    
                    x_point<=x_point+1;
                else
                    x_point<=7;
            end
        endcase
    end
end

//y_point
always @(posedge clk or posedge reset) begin
    if(reset)
        y_point<=4;
    else if(cur_st==EXE)begin
        case(cmd)
            4'b0001:begin
                if(y_point>1)
                    y_point<=y_point-1;
                else    
                    y_point<=1;
            end
            4'b0010:begin
                if(y_point<7)
                    y_point<=y_point+1;
                else
                    y_point<=7;
            end
        endcase
    end
end

//dot
always @(*) begin
    dot1=(y_point-1)*8+x_point-1;
    dot2=(y_point-1)*8+x_point;
    dot3=y_point*8+x_point-1;
    dot4=y_point*8+x_point;
end


endmodule



