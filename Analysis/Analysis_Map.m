%% Show overlaid maps
%PartList={1,2,3,4,5,6,7,8,10,11}; %for Bachelors Thesis Data set
PartList = {12,13,14,15,16,17,18,19,20,21,22,25,26,27,28}; %Subjects with new script
Number = length(PartList);%11;
map = imread('map5.png'); 
map = imresize(map,[500 450]);
for ii = 1: Number
    e = cell2mat(PartList(ii));
    if e<10
        x = load(['path_VP_0' num2str(e) '.mat']);
    else
        x = load(['path_VP_' num2str(e) '.mat']);
    end
    color = randi([0 255],1,3);
    len = size(x.path,2);
    for a=1:len
        map(int64(x.path(1,a)),int64(x.path(2,a)),1) = color(1);
        map(int64(x.path(1,a)),int64(x.path(2,a)),2) = color(2);
        map(int64(x.path(1,a)),int64(x.path(2,a)),3) = color(3);
    end
end
image(map)
%% show single maps
for ii = 1: Number
    e = cell2mat(PartList(ii));
    if e<10
        x = load(['map_VP_0' num2str(e) '.mat']);
    else
        x = load(['map_VP_' num2str(e) '.mat']);
    end
    figure;
    imshow(x.map);
    hold on;
end
%% Individual North
%shows graph of individual north for all subjects
% true north = rotation of 270
r = 1; % Radius
for ii = 1: Number
    e = cell2mat(PartList(ii));
    if e<10
        n = load(['North_VP_0' num2str(e) '.mat']);
    else
        n = load(['North_VP_' num2str(e) '.mat']);
    end
    t = cell2mat(n.north(3))-180; % Angle in degrees, -180 to have north on top
    [x,y] = pol2cart(t/180*pi,r);
    hold on;
    plot([0 x],[0,y])
    legendInfo{ii} = ['Subject = ' num2str(e)];
end
t = 90;%true north at 270 degrees -> -180 = 90
[x,y] = pol2cart(t/180*pi,r);
hold on;
plot([0 x],[0,y])
legendInfo{Number+1} = ['True North'];
legend(legendInfo)
clear all;