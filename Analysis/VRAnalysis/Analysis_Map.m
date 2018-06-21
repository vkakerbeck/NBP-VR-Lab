%%Load data
Condition = "VR"; %Options: VR, VR-belt,All
Repeated = false;%Options: true, false
%--------------------------------------------------------------------------
files = [];
if Condition ~= "All"
    for line = 1:height(Seahavenalingmentproject)
        if lower(cellstr(Seahavenalingmentproject.Training(line)))==lower(Condition) && Seahavenalingmentproject.Discarded(line) ==""
            if Repeated == false && Seahavenalingmentproject.Measurement(line)==1
                files = [files, Seahavenalingmentproject.Subject(line)];
            end
            if Repeated == true && Seahavenalingmentproject.Measurement(line)==3
                str = char(Seahavenalingmentproject.Comments(line));
                i = strfind(Seahavenalingmentproject.Comments(line),'#');
                Mes = [str2num(str(i(1)+1:i(1)+4));str2num(str(i(2)+1:i(2)+4));(Seahavenalingmentproject.Subject(line))];
                files = [files, Mes];
            end
        end
    end
else
    files = dir('path_VP_*.mat');%Analyzes all subjectfiles in your positions directory
end
%% Show overlaid maps
Number = length(files);
map = imread('map5.png'); 
map = imresize(map,[500 450]);
pos = zeros([500 450]);
numS = zeros([51 46]);
for ii = 1: Number
    num=zeros([51 46]);
    if Condition == "All"
        e = files(ii).name(9:12);
    else
        e = files(ii);
    end
    x = load(['path_VP_' num2str(e) '.mat']);
    disp(e);
    color = randi([0 255],1,3);
    len = size(x.path,2);
    for a=1:len-1
        map(int64(x.path(1,a)),int64(x.path(2,a)),1) = color(1);
        map(int64(x.path(1,a)),int64(x.path(2,a)),2) = color(2);
        map(int64(x.path(1,a)),int64(x.path(2,a)),3) = color(3);
        num(51-int64(floor(x.path(1,a)/10)+1),int64(floor(x.path(2,a)/10)+1)) = 1;
        pos(int64(x.path(1,a)),int64(x.path(2,a))) = pos(int64(x.path(1,a)),int64(x.path(2,a)))+1;
    end
    numS=numS+num;
    disp('done');
end
image(map)
%% Show heatmap (normalized)
newp=zeros([51 46]);
for x=1:500
    for y =1:450
        newp(floor(x/10)+1,floor(y/10)+1) = newp(floor(x/10)+1,floor(y/10)+1)+pos(501-x,y);
    end
end
h=pcolor(newp/norm(newp));colorbar;
set(h, 'EdgeColor', 'none');
title('Total Number of Frames a Subject was in Each Area (normalized)');
%% Heatmap with number of subjects visited
h=pcolor(numS);colorbar;
set(h, 'EdgeColor', 'none');
title('Total Number of Subjects in Each Area');
%% show single maps colored by rotation (maybe don't do this when analyzing all subjects at once ;)
for ii = 1: 1
e = files(ii).name(9:12);
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
    if Condition == "All"
        e = files(ii).name(9:12);
    else
        e = files(ii);
    end
    n = load(['North_VP_' num2str(e) '.mat']);
    t = cell2mat(n.north(3))-180; % Angle in degrees, -180 to have north on top
    [x,y] = pol2cart(t/180*pi,r);
    hold on;
    plot([0 x],[0,y])
end
t = 90;%true north at 270 degrees -> -180 = 90
[x,y] = pol2cart(t/180*pi,r);
hold on;
plot([0 x],[0,y])
title('Direction of North for Each Subject (True North on Top)');
%% Draw walking path comparisons of repeated measures (color indicated time when place was visited)
%Before running this section run the first section with Repeated = true.
Number = length(files);
for ii = 1: Number   
    disp(ii);
    figure;
    for iii=1:3
        num=zeros([51 46]);
        x.(strcat('x', num2str(iii))) = load(['path_VP_' num2str(files(iii,ii)) '.mat']);
        disp(num2str(files(iii,ii)));
        len = size(x.(strcat('x', num2str(iii))).path,2);
        for a=1:len-1
            num(51-int64(floor(x.(strcat('x', num2str(iii))).path(1,a)/10)+1),int64(floor(x.(strcat('x', num2str(iii))).path(2,a)/10)+1)) = a*100/len;
        end
        sp = subplot(1,3,iii);hold on;
        h=pcolor(num);
        title(strcat('Measurement ',num2str(iii)), 'FontSize',20);
        set(h, 'EdgeColor', 'none');axis off;
        p = get(sp, 'pos');
        p(3) = p(3) + 0.065;
        set(sp, 'pos', p);
        hold on;plot(21.5,23.5,'.r');
        coverage.(['VP' num2str(ii)])(iii)=(nnz(num)/1034)*100;%Get percentage of map covered (nnz->num of non zero elements in heatmap of all subjects)
    end
end
figure;
for ii = 1:Number
    plot(coverage.(['VP' num2str(ii)]));
    hold on;
end
title('Map Coverage in 3 Repeated Measurements in %');
xlabel('Measurement Number');
ylabel('% of Map coverage (all places visited by at least one subject)');