%% Show overlaid maps
%PartList={1,2,3,4,5,6,7,8,10,11}; %for Bachelors Thesis Data set
%PartList = {12,13,14,15,16,17,18,19,20,21,22,25,26,27,28}; %Subjects with new script
PartList ={1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,18,19,20,21,22,25,26,28,29}; %all Subjects
Number = length(PartList);%11;
map = imread('map5.png'); 
map = imresize(map,[500 450]);
pos = zeros([500 450]);
numS = zeros([51 46]);
for ii = 1: Number
    num=zeros([51 46]);
    e = cell2mat(PartList(ii));
    x = load(['path_VP_' num2str(e) '.mat']);
    disp(e);
    color = randi([0 255],1,3);
    len = size(x.path,2);
    for a=1:len
        map(int64(x.path(1,a)),int64(x.path(2,a)),1) = color(1);
        map(int64(x.path(1,a)),int64(x.path(2,a)),2) = color(2);
        map(int64(x.path(1,a)),int64(x.path(2,a)),3) = color(3);
        num(int64(floor(x.path(1,a)/10)+1),int64(floor(x.path(2,a)/10)+1)) = 1;
        pos(int64(x.path(1,a)),int64(x.path(2,a))) = pos(int64(x.path(1,a)),int64(x.path(2,a)))+1;
    end
    numS=numS+num;
    disp('done');
end
image(map)
%% Show heatmap
newp=zeros([51 46]);
for x=1:500
    for y =1:450
        newp(floor(x/10)+1,floor(y/10)+1) = newp(floor(x/10)+1,floor(y/10)+1)+pos(x,y);
    end
end
h=pcolor(newp/norm(newp));colorbar;
set(h, 'EdgeColor', 'none');
%% Heatmap with number of subjects visited
newp=zeros([51 46]);
for x=1:500
    for y =1:450
        newp(floor(x/10)+1,floor(y/10)+1) = newp(floor(x/10)+1,floor(y/10)+1)+numS(x,y);
    end
end
h=pcolor(newp);colorbar;
set(h, 'EdgeColor', 'none');
%% show single maps
for ii = 1: Number
    e = cell2mat(PartList(ii));
    x = load(['map_VP_' num2str(e) '.mat']);
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
    n = load(['North_VP_' num2str(e) '.mat']);
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
%clear all;