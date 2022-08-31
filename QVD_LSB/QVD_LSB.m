% training={'512 grayscale/lena.png','512 grayscale/peppers.png','512 grayscale/jet.png','512 grayscale/tiffany.png','512 grayscale/elaine.png','512 grayscale/baboon.png','512 grayscale/elaine.png','512 grayscale/tank.png','512 grayscale/couple.png'};
% testing2={'lena.png','peppers.png','jet.png','tiffany.png','lake.png','baboon.png','elaine.png','tank.png','couple.png'};
training={'512 grayscale/lena.tif'};
% training={'512 grayscale/jet.tif','512 grayscale/baboon.tif','512 grayscale/boat.tiff','512 grayscale/elaine.tiff','512 grayscale/lena.tif','512 grayscale/male.tif','512 grayscale/peppers.tif','512 grayscale/tank.tiff','512 grayscale/tiffany.tif'};

xlsFile = 'QVD_LSB_result.xls';
xlsFile2 = 'QVD_LSB_sum_result.xls';
xlsFile3 = 'QVD_LSB_comparison_result.xls';
data=[];
count=0;
count2=0;
layer=2;
% dth2=[0,4,8,16,32];
 dth2=16;
for kk=1:size(training,2)
    for loop=1:size(dth2,2)
        org_img = imread(training{kk}); %原始圖
        % org_img=[44 83 84 44;43 83 42 44;42 82 82 81;42 82 81 80];
        [high,weight] = size(org_img(:,:,1));
        cover_img = org_img;
        secret_num=0;
        secret_data_bit=secret_data_all;
        stop=0;
        dddd=0;
        H_map=[];
        L_map=[];
        all_bitmap=[];
        all_decompress=[];
        extract_bit=[];
        %         dth=16;
        dth=dth2(loop);
        ccc=0;
        nnn=0;
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
                %              origin=[102,92,87,84;78,77,74,79;82,83,82,83;84,83,81,81];
                pic_mean=mean(origin,'all');
                %            bitmap(origin<pic_mean)=0;
                bitmap=zeros(4,4);
                bitmap(origin>=pic_mean)=1;
                bitmap3=bitmap;
                H=round(mean(origin(origin>=pic_mean),'all'));
                if origin==pic_mean
                    L=H;
                else
                    L=round(mean(origin(origin<pic_mean),'all'));
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
                decompress=[];
                origin = double(cover_img(((i-1)*4+1):i*4,((j-1)*4+1):j*4,1)); %從圖片中取出3*3九宮格block
                pic_mean=mean(origin,'all');
                %            bitmap(origin<pic_mean)=0;
                bitmap=zeros(4,4);
                bitmap(origin>=pic_mean)=1;
                bitmap3=bitmap;
                H=round(mean(origin(origin>=pic_mean),'all'));
                if origin==pic_mean
                    L=H;
                else
                    L=round(mean(origin(origin<pic_mean),'all'));
                end
                quotient_block=[L,H];
                
                
                d=abs(H-L);
                
                w=0;
                if d>=0&&d<=15
                    w=3;
                    step_1=step_1+6;
                    secret_num=secret_num+3;
                    px=bin2dec(num2str([bitget(quotient_block(1),8:-1:4),secret_data_bit(secret_num-2:secret_num)]));
                    extract_bit(secret_num-2:secret_num)=secret_data_bit(secret_num-2:secret_num);
                    secret_num=secret_num+3;
                    py=bin2dec(num2str([bitget(quotient_block(2),8:-1:4),secret_data_bit(secret_num-2:secret_num)]));
                    extract_bit(secret_num-2:secret_num)=secret_data_bit(secret_num-2:secret_num);                 
                elseif d>=16
                    w=4;
                     step_1=step_1+8;
                    secret_num=secret_num+4;
                    px=bin2dec(num2str([bitget(quotient_block(1),8:-1:5),secret_data_bit(secret_num-3:secret_num)]));
                    extract_bit(secret_num-3:secret_num)=secret_data_bit(secret_num-3:secret_num);
                    secret_num=secret_num+4;
                    py=bin2dec(num2str([bitget(quotient_block(2),8:-1:5),secret_data_bit(secret_num-3:secret_num)]));
                    extract_bit(secret_num-3:secret_num)=secret_data_bit(secret_num-3:secret_num);  
                else
                    disp("tttttttt");
                    stop=1;
                    break
                end
                if  (px>=quotient_block(1)+2^(w-1)+1)
                    px=px-2^w;
                elseif (px<=quotient_block(1)-(2^(w-1)+1))
                    px=px+2^w;
                end
                
                if  (py>=quotient_block(2)+2^(w-1)+1)
                    py=py-2^w;
                elseif (py<=quotient_block(2)-(2^(w-1)+1))
                    py=py+2^w;
                end
                
                if px>py
                    if floor(px/2^w)==floor(py/2^w)&&px/2^w-1>=0
                        %     px=floor(px/2^w-1)*2^w+mod(px,2^w);
                        px=px-2^w;
                    elseif floor(px/2^w)==floor(py/2^w)
                        %     py=floor(py/2^w+1)*2^w+mod(py,2^w);
                        py=py+2^w;
                     
                    else
                        px2=px;
                        px=floor(py/2^w)*2^w+mod(px,2^w);
                        py=floor(px2/2^w)*2^w+mod(py,2^w);
                            
                    end
                    
                    
                end
                if px>py
                    disp("no");
                    stop=1;
                end
                go=1;
                while go==1
                    if w==3
                        if abs(px-py)>15
                            if abs(px+2^w-quotient_block(1))<=abs((py-2^w)-quotient_block(2))
                                px=px+2^w;
                            else
                                py=py-2^w;
                            end
                        end
                        if abs(px-py)>=0&&abs(px-py)<=15
                            go=0;
                        end
                        
                    elseif w==4
                        if abs(px-py)<16
                            if abs((px-2^w)-quotient_block(1))<=abs((py+2^w)-quotient_block(2))
                                px=px-2^w;
                            else
                                py=py+2^w;
                            end
                        end
                        if abs(px-py)>=16
                            go=0;
                        end
                    end
                end
                
                if px<0||py<0
                    px=px+2^w;
                    py=py+2^w;
                elseif px>255||py>255
                    px=px-2^w;
                    py=py-2^w;
                end
                Px=px;
                Py=py;
                L2=Px;
                H2=Py;
                if px~=py
                    step_2= step_2+1;
                    % if floor(px/2^w)~=floor(py/2^w)
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
                    
                    step_3= step_3+16;
                    smooth_count=smooth_count+1;
                    secret_num=secret_num+16;
                    dec4=secret_data_bit(secret_num-15:secret_num);
                    extract_bit(secret_num-15:secret_num)=secret_data_bit(secret_num-15:secret_num);
                    dec4=reshape(dec4,[4,4]);
                    %                 dec4=dec4';
                    bitmap=dec4;
                    count=count+1;
                else
                    complex_count=complex_count+1;
                end
                
                all_bitmap(((i-1)*4+1):i*4,((j-1)*4+1):j*4)=bitmap;
                decompress=zeros(4,4);
                %             if secret_num>290000
                %                 disp(secret_num);
                %                 decompress(bitmap3==1)=H;
                %             decompress(bitmap3==0)=L;
                %             else
                decompress(bitmap==1)=H_map(i,j);
                decompress(bitmap==0)=L_map(i,j);
                
                %             end
                all_decompress(((i-1)*4+1):i*4,((j-1)*4+1):j*4)=decompress;
                org_img(((i-1)*4+1):i*4,((j-1)*4+1):j*4)=decompress;
                if secret_num>=cap+cap_count*100000
                    
                    ORG_MSE = immse(cover_img(:,:,1),uint8(org_img(:,:,1)));
                    ORG_PSNR = 10*log10((255)^2/ORG_MSE);
                    capacity(kk,2*(cap_count/0.5)+1:2*(cap_count/0.5)+2)=[secret_num,ORG_PSNR];
                    QVD_LSB_capacity((cap_count/0.5)+1,1+2*(loop-1):2+2*(loop-1))=[secret_num,ORG_PSNR];
                    cap_count=cap_count+0.5;
                end
                %             if i==43&&j==86
                %                 stop=1;
                %             end
                
                if stop==1
                    break
                end
                
            end
            if stop==1
                break
            end
        end
        sum(kk,1)=0;
        for y=1:high
            for x=1:weight
                sum(kk,1)=sum(kk,1)+abs(double(cover_img(y,x))-double(org_img(y,x)));
                
            end
        end
        sum(kk,2)=smooth_count;
        sum(kk,3)=complex_count;
        %     disp(count);
        ORG_MSE = immse(cover_img(:,:,1),org_img(:,:,1));
        ORG_PSNR = 10*log10((255)^2/ORG_MSE);
        capacity(kk,2*(cap_count/0.5)+1:2*(cap_count/0.5)+2)=[secret_num,ORG_PSNR];
        QVD_LSB_capacity((cap_count/0.5)+1,1+2*(loop-1):2+2*(loop-1))=[secret_num,ORG_PSNR];
        embedding_rate = secret_num/(high*weight);
        disp("PSNR: "+ORG_PSNR);
        disp("secret_num: "+secret_num);
        disp("embedding_rate: "+embedding_rate);
        %         data(kk,1:3)=[ORG_PSNR,secret_num,embedding_rate];
        data(loop,3*(kk-1)+1:3*(kk-1)+3)=[secret_num,ORG_PSNR,embedding_rate];
        imwrite(uint8(all_decompress),'Lena_QVD_LSB_image.tif');
        %     QVD_LSB_extraction;
    end
    
end
%  [status, message] = xlswrite(xlsFile2, sum);
% [status, message] = xlswrite(xlsFile3, capacity);

% [status, message] = xlswrite(xlsFile, data);