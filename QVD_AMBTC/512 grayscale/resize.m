
% training={'./tiffany.png'};
training={'5.png','7.png','8.png','24.png','26.png','35.png','37.png','clown.png','elaine.png','house.png','houses.png','kiel.png','lighthouse.png','owl.png','tank.png','zelda.png'};


for i=1:size(training,2)
 picture=imread(training{i});
 picture=imresize(picture,[256,256]);
%  picture=[56,59,60,61,59,55,55,57,56,56,59,57,56,54,53,55,56,56,58,58,58,56,55,60,58,58,58,58,59,59,60,64,63,63,58,60,60,63,64,64,62,62,60,62,62,63,62,62,61,62,61,62,60,60,59,61,59,60,59,60,59,60,59,61];
 
 disp(size(picture));
%  picture=reshape(picture,[8 8]);
%   figure,imshow(uint8(picture),'InitialMagnification','fit');
  aaa=['D:\大學和碩士\影像處理方法\圖片集\256 grayscale\',training{i}];
  imwrite(uint8(picture),aaa);

%  figure,imshow(edge(picture,'Canny'),'InitialMagnification','fit');
end