training={'512 grayscale/lena.tif'};
for kk=1:size(training,2)
     org_img = imread(training{kk}); %原始圖
        % org_img=[44 83 84 44;43 83 42 44;42 82 82 81;42 82 81 80];
        [high,weight] = size(org_img(:,:,1));
        cover_img = org_img;
for i=1:floor(high/4)
            for j=1:floor(weight/4)
                origin = double(cover_img(((i-1)*4+1):i*4,((j-1)*4+1):j*4,1)); %從圖片中取出3*3九宮格block
                %                 origin=[52,53,53,54;45,43,55,49;57,46,58,63;58,59,59,63];
                %   origin=[182,203,206,197;173,200,203,194;177,197,195,185;188,203,194,180];
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
             all_decompress(((i-1)*4+1):i*4,((j-1)*4+1):j*4)=decompress;
            end
end

   ORG_MSE = immse(cover_img(:,:,1),uint8(org_img(:,:,1)));
                    ORG_PSNR = 10*log10((255)^2/ORG_MSE);
                imwrite(uint8(all_decompress),'Lena_AMBTC_image.tif');
end