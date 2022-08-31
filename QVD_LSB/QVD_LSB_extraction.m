[high,weight] = size(H_map);
secret_num=0;
dth=16;
secret_data=[];
num=0;
stop=0;
for i=1:high
    for j=1:weight
        smooth=0;
        secret_data_1=[];
        secret_data_2=[];
        secret_data_1_count=0;
        secret_data_2_count=0;
        H=H_map(i,j);
        L=L_map(i,j);
        quotient_block2=[L,H];
        d=abs(quotient_block2(1)-quotient_block2(2));
        if d>=0&&d<=15
            w=3;
        else
            w=4;
        end
        L_floor=floor(L/2^w);
        L_ceil=L_floor+1;
        H_floor=floor(H/2^w);
        H_ceil=H_floor+1;
        len=length(secret_data);
        bitmap=all_bitmap(((i-1)*4+1):i*4,((j-1)*4+1):j*4);
        if abs(H-L)<=dth
            smooth=1;
        end
        a=floor(px/4);
        b=floor(py/4);
        if  (quotient_block2(1)<quotient_block2(2))
            if smooth==1
                secret_data_1_count=secret_data_1_count+17;
                secret_data_1(secret_data_1_count-16:secret_data_1_count)=[0,bitmap(1:16)];
            else
                secret_data_1_count=secret_data_1_count+1;
                secret_data_1(secret_data_1_count)=0;
            end
        elseif (quotient_block2(1)>quotient_block2(2))
            if smooth==1
                secret_data_1_count=secret_data_1_count+17;
                secret_data_1(secret_data_1_count-16:secret_data_1_count)=[1,bitmap(1:16)];
            else
                secret_data_1_count=secret_data_1_count+1;
                secret_data_1(secret_data_1_count)=1;
            end
            bitmap3=bitmap;
            bitmap2=zeros(4,4);
            bitmap2(find(bitmap==0))=1;
            bitmap=bitmap2;
            H2=H;
            H=L;
            L=H2;
        elseif quotient_block2(1)==quotient_block2(2)&&smooth==1
            secret_data_1_count=secret_data_1_count+16;
            secret_data_1(secret_data_1_count-15:secret_data_1_count)=bitmap;
        end
%         if smooth==1
%             secret_data_1_count=secret_data_1_count+16;
%             secret_data_1(secret_data_1_count-15:secret_data_1_count)=bitmap;
%         end
        
        
      
        if d>=0&&d<=7
             secret_data_2_count=secret_data_2_count+3;
        secret_data_2(secret_data_2_count-2:secret_data_2_count)=bitget(L,3:-1:1);
         secret_data_2_count=secret_data_2_count+3;
        secret_data_2(secret_data_2_count-2:secret_data_2_count)=bitget(H,3:-1:1);
        elseif d>=8&&d<=15
               secret_data_2_count=secret_data_2_count+3;
        secret_data_2(secret_data_2_count-2:secret_data_2_count)=bitget(L,3:-1:1);
         secret_data_2_count=secret_data_2_count+3;
        secret_data_2(secret_data_2_count-2:secret_data_2_count)=bitget(H,3:-1:1);
        elseif d>=16&&d<=31
               secret_data_2_count=secret_data_2_count+4;
        secret_data_2(secret_data_2_count-3:secret_data_2_count)=bitget(L,4:-1:1);
         secret_data_2_count=secret_data_2_count+4;
        secret_data_2(secret_data_2_count-3:secret_data_2_count)=bitget(H,4:-1:1);
        elseif d>=32
                           secret_data_2_count=secret_data_2_count+4;
        secret_data_2(secret_data_2_count-3:secret_data_2_count)=bitget(L,4:-1:1);
         secret_data_2_count=secret_data_2_count+4;
        secret_data_2(secret_data_2_count-3:secret_data_2_count)=bitget(H,4:-1:1);
        end

                  
        
        
        secret_data=[secret_data,secret_data_2,secret_data_1];
%                         if secret_data(len+1:len+secret_data_1_count+secret_data_2_count)==extract_bit(len+1:len+secret_data_1_count+secret_data_2_count)
%                             disp("yes");
%                         else
%                             stop=1;
%                             disp("no");
%                         end
        if stop==1
            break;
        end
    end
    if stop==1
        break;
    end
end
if secret_data==extract_bit
    disp("yes");
else
    disp("no");
end