% training={'512 grayscale/jet.tif','512 grayscale/baboon.tif','512 grayscale/boat.tiff','512 grayscale/elaine.tiff','512 grayscale/lena.tif','512 grayscale/male.tif','512 grayscale/peppers.tif','512 grayscale/tank.tiff','512 grayscale/tiffany.tif'};
%標準影像
training={'512 grayscale/lena.tif'};
xlsFile = 'QVD_AMBTC_result.xls';
xlsFile2 = 'QVD_AMBTC_sum_result.xls';
xlsFile3 = 'QVD_AMBTC_comparison_result.xls';
data=[];
count=0;
count2=0;
t=0;
layer=2;
dth2=16;    %門檻值
for kk=1:size(training,2)
    for loop=1:size(dth2,2)
        org_img = imread(training{kk}); %原始圖
        [high,weight] = size(org_img(:,:,1));
        cover_img = org_img;
        secret_num=0;
        secret_data_bit=secret_data_all;
        stop=0;
        H_map=[];
        L_map=[];
        all_bitmap=[];
        all_decompress=[];
        dth=dth2(loop);
        ccc=0;
        step_1=0;
        step_2=0;
        step_3=0;
        smooth_count=0;
        complex_count=0;
        cap=50000;
        cap_count=0;
        for i=1:floor(high/4)
            for j=1:floor(weight/4)
                origin = double(cover_img(((i-1)*4+1):i*4,((j-1)*4+1):j*4,1)); %從圖片中取出3*3九宮格block
                pic_mean=mean(origin,'all');
                bitmap=zeros(4,4);
                bitmap(origin>=pic_mean)=1;
                bitmap3=bitmap;
                H=round(mean(origin(origin>=pic_mean),'all'));%高量化值
                if origin==pic_mean
                    L=H;
                else
                    L=round(mean(origin(origin<pic_mean),'all'));%低量化值
                end
                decompress=zeros(4,4);
                decompress(bitmap==1)=H;
                decompress(bitmap==0)=L;
                org_img(((i-1)*4+1):i*4,((j-1)*4+1):j*4)=decompress;
            end
        end
        
        
        
        for i=1:floor(high/4)
            for j=1:floor(weight/4)
                len=secret_num;
                flag=0;
                decompress=[];
                origin = double(cover_img(((i-1)*4+1):i*4,((j-1)*4+1):j*4,1)); %從圖片中取出3*3九宮格block
                
                pic_mean=mean(origin,'all');
                bitmap=zeros(4,4);
                bitmap(origin>=pic_mean)=1;
                bitmap3=bitmap;
                H=round(mean(origin(origin>=pic_mean),'all'));
                if origin==pic_mean
                    L=H;
                else
                    L=round(mean(origin(origin<pic_mean),'all'));
                end
                AMBTC_D=zeros(4,4);
                AMBTC_D(bitmap==1)=H;
                AMBTC_D(bitmap==0)=L;
                AMBTC_img(((i-1)*4+1):i*4,((j-1)*4+1):j*4)=AMBTC_D;
                secret_num=secret_num+3;
                step_1=step_1+3;
                if secret_data_bit(secret_num+1)==0
                    plus=1;
                else
                    plus=0;
                end
                
                %於餘數嵌入3位元
                dec1=bin2dec(num2str(secret_data_bit(secret_num-2:secret_num-1)));
                dec2=bin2dec(num2str([secret_data_bit(secret_num),plus]));
                extract_bit(secret_num-2:secret_num)=secret_data_bit(secret_num-2:secret_num);
                quotient_block=floor([L,H]/4);%計算量化值除以4後的商數值
                d=abs(quotient_block(1)-quotient_block(2));%計算高低商數值之間的差值
                go=1;
                num=floor(log2(d));
                if num==0||d==0
                    num=1;
                end
                ccc=0;
                secret_num=secret_num+num;
                 step_1=step_1+num;
                 %於商數嵌入秘密位元
                while go==1
                    a=secret_data_bit(secret_num-(num-1):secret_num+ccc);
                    if plus==1
                        a2=zeros(1,length(a));
                        a2(find(a==0))=1;
                        a=a2;
                    end
                    d2=bin2dec(num2str(a(1:end)));
                    ddd=quotient_block(1)+d2;
                    new=quotient_block(1)-ceil((d2-d)/2);
                    new2=quotient_block(2)+floor((d2-d)/2);
                    if d2>=d
                        go=0;
                        d3=bin2dec(num2str(a(1:(num+ccc-1))));
                        pre=quotient_block(1)-ceil((d3-d)/2);
                        pre2=quotient_block(2)+floor((d3-d)/2);
                        ddd1=abs(new-quotient_block(1));
                        ddd2=abs(new2-quotient_block(2));
                        ddd3=abs(quotient_block(1)-pre);
                        ddd4=abs(quotient_block(2)-pre2);
                        %                     if ccc>0&&((new2-quotient_block(2)>quotient_block(2)-pre2)||(abs(H-L)<=dth&&abs((new2*4+dec2)-(new*4+dec1))>dth))
                        if (ccc>0&&(ddd1+ddd2>ddd3+ddd4))
                            Px=pre;
                            Py=pre2;
                            d2=d3;
                            ccc=ccc-1;
                            secret_num=secret_num+ccc;
                            step_1=step_1+ccc;
                            extract_bit(secret_num-(num+ccc-1):secret_num)=secret_data_bit(secret_num-(num+ccc-1):secret_num);
                        else
                            
                            Px=new;
                            Py=new2;
                            secret_num=secret_num+ccc;
                             step_1=step_1+ccc;
                            extract_bit(secret_num-(num+ccc-1):secret_num)=secret_data_bit(secret_num-(num+ccc-1):secret_num);
                        end
                    else
                        ccc=ccc+1;
                    end
                end
                if Px<0||Py<0
                    if Px<Py
                        Px=0;
                        Py=d2;
                    elseif Px>Py
                        Px=d2;
                        Py=0;
                    end
                elseif  Px>63||Py>63
                    if Px<Py
                        Px=63-d2;
                        Py=63;
                    elseif Px>Py
                        Px=63;
                        Py=63-d2;
                    end
                end
                
                L2=Px*4+dec1;
                H2=Py*4+dec2;
                if Px~=Py
                     step_2=step_2+1;
                    secret_num=secret_num+1;
                    extract_bit(secret_num)=secret_data_bit(secret_num);
                    dec3=bin2dec(num2str(secret_data_bit(secret_num)));
                    if dec3==1
                        H_map(i,j)=L2;
                        L_map(i,j)=H2;
                        bitmap2=zeros(4,4);
                        bitmap2(find(bitmap==0))=1;
                        bitmap=bitmap2;
                    else
                        H_map(i,j)=H2;
                        L_map(i,j)=L2;
                    end
                else
                    H_map(i,j)=H2;
                    L_map(i,j)=L2;
                end
                
                if abs(H2-L2)<=dth
                       step_3=step_3+16;
                    smooth_count=smooth_count+1;
                    count=count+1;
                    secret_num=secret_num+16;
                    dec4=secret_data_bit(secret_num-15:secret_num);
                    extract_bit(secret_num-15:secret_num)=secret_data_bit(secret_num-15:secret_num);
                    dec4=reshape(dec4,[4,4]);
                    %                 dec4=dec4';
                    bitmap=dec4;
                else
                    complex_count=complex_count+1;
                end
                
                all_bitmap(((i-1)*4+1):i*4,((j-1)*4+1):j*4)=bitmap;
                decompress=zeros(4,4);
                decompress(bitmap==1)=H_map(i,j);
                decompress(bitmap==0)=L_map(i,j);
                all_decompress(((i-1)*4+1):i*4,((j-1)*4+1):j*4)=decompress;
                org_img(((i-1)*4+1):i*4,((j-1)*4+1):j*4)=decompress;
                if secret_num>=cap+cap_count*100000
                    ORG_MSE = immse(cover_img(:,:,1),uint8(org_img(:,:,1)));
                    ORG_PSNR = 10*log10((255)^2/ORG_MSE);
                    capacity(kk,2*(cap_count/0.5)+1:2*(cap_count/0.5)+2)=[secret_num,ORG_PSNR];
                    QVD_AMBTC_capacity((cap_count/0.5)+1,1+2*(loop-1):2+2*(loop-1))=[secret_num,ORG_PSNR];
                    cap_count=cap_count+0.5;
                end
            end
        end
        
        ORG_MSE = immse(cover_img(:,:,1),org_img(:,:,1));
        ORG_PSNR = 10*log10((255)^2/ORG_MSE);
        %          AMBTC_MSE = immse(cover_img,uint8(AMBTC_img));
        %          AMBTC_PSNR = 10*log10((255)^2/AMBTC_MSE);
        capacity(kk,2*(cap_count/0.5)+1:2*(cap_count/0.5)+2)=[secret_num,ORG_PSNR];
        QVD_AMBTC_capacity((cap_count/0.5)+1,1+2*(loop-1):2+2*(loop-1))=[secret_num,ORG_PSNR];
        embedding_rate = secret_num/(high*weight);
        sumdif=0.0;
        sum(kk,1)=0;
        for y=1:high
            for x=1:weight
                sum(kk,1)=sum(kk,1)+abs(double(cover_img(y,x))-double(org_img(y,x)));
                
            end
        end
        sum(kk,2)=smooth_count;
        sum(kk,3)=complex_count;
        
        disp("PSNR: "+ORG_PSNR);
        disp("secret_num: "+secret_num);
        disp("embedding_rate: "+embedding_rate);
        %     data(kk,1:3)=[ORG_PSNR,secret_num,embedding_rate];
        data(loop,3*(kk-1)+1:3*(kk-1)+3)=[secret_num,ORG_PSNR,embedding_rate];
        imwrite(org_img(:,:,1),'Lena_QVD_AMBTC_image.tif');
    end
end
% [status, message] = xlswrite(xlsFile2, sum);
% [status, message] = xlswrite(xlsFile3, capacity);
% [status, message] = xlswrite(xlsFile, data);