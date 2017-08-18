path1 = 'D:\v.kakerbeck\Tracking\ScreenshotsSelection\';
photos = dir(path1);
N = length(photos)-2;
Data = cell(N,1);
ind = 1;

for pic = 3:length(photos)
    imgName = photos(pic,1).name(1:end-4);
    image = imread(strcat(path1,photos(pic,1).name));
    Data{ind,1}.Data = image; 
    Data{ind,1}.Name = imgName;
    ind=ind+1;
end

% pic =1;
% Laenge = length(Data); 
% count = 1;
% kick = [];
% while pic < Laenge;
%     if Data{pic,1}.North==0
%         Data(pic) =[];
%         kick(count) = pic +length(kick);
%         count = count+1;
%         Laenge = length(Data);        
%     end
%     pic = pic+1;
% end
% 
% %save ('Z:\nbp\refbelt\directionality2\newstimuli\Data.mat', 'Data');
% 
% pic =1;
% while pic < length(Data)
%     if (Data{pic,1}.North==0)        
%     else
%         pic
%         %disp(Data{pic,1}.Name) 
%         imshow(Data{pic,1}.Data);
%         waitforbuttonpress
%     end
%     pic = pic+ 1;
%             
% end

% rem = [3,4,5,6,8,11,12,35,37,38,48,49,59,66,68,69,70,109,111,112,113,114,117];
% Data(rem) = [];


save ('D:\v.kakerbeck\Tracking\Data.mat', 'Data');
