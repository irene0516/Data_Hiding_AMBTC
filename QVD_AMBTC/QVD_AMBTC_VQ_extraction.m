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
        quotient_block2=floor([L,H]/4);
        d=dec2bin(abs(quotient_block2(1)-quotient_block2(2)));

        
        len=length(secret_data);
        bitmap=all_bitmap(((i-1)*4+1):i*4,((j-1)*4+1):j*4);
        if abs(H-L)<=dth
            smooth=1;
        end
        if  quotient_block2(1)<quotient_block2(2)
            if smooth==1
                secret_data_1_count=secret_data_1_count+17;
                secret_data_1(secret_data_1_count-16:secret_data_1_count)=[0,bitmap(1:16)];
            else
                secret_data_1_count=secret_data_1_count+1;
                secret_data_1(secret_data_1_count)=0;
            end
        elseif quotient_block2(1)>quotient_block2(2)
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
        plus=mod(H,2);
        H=floor(H/2);
        dec1=mod(L,4);
        dec2=mod(H,2);
        secret_data_2_count=secret_data_2_count+2;
        secret_data_2(secret_data_2_count-1:secret_data_2_count)=bitget(dec1,2:-1:1);
        secret_data_2_count=secret_data_2_count+1;
        secret_data_2(secret_data_2_count)=bitget(dec2,1:-1:1);
        if d~=0
            c=str2num(d(1));
            for p=2:length(d)
                c=[c str2num(d(p))];
            end
            if plus==1
            a2=zeros(1,length(c));
            a2(find(c==0))=1;
            c=a2;
            H=H-1;
        end
        secret_data_2_count=secret_data_2_count+length(c);
        secret_data_2(secret_data_2_count-(length(c)-1):secret_data_2_count)=c;
        end
        
        
        
        secret_data=[secret_data,secret_data_2,secret_data_1];
%                 if secret_data(len+1:len+secret_data_1_count+secret_data_2_count)==extract_bit(len+1:len+secret_data_1_count+secret_data_2_count)
%                     disp("yes");
%                 else
%                     stop=1;
%                     disp("no");
%                 end
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