%Read in map and positions
map = imread('map5.png'); 
map = imresize(map,[500 450]);
data = fopen('positions.txt');
data = textscan(data,'%s','delimiter', '\n');
data = data{1};
data = table2array(cell2table(data));
len = int64(length(data));
%format and sort the raw data
x = zeros(1,len);
y = zeros(1,len);
r = zeros(1,len);
path = zeros(2,len);
for a = 1:double(len)-1
    x(a) = str2num(data{a}(2:6))-177;
    y(a) = str2num(data{a}(14:18))-535;
    r(a) = str2num(data{a}(21:length(data{a})-1));
    path(1,a)=x(a);path(2,a)=y(a);
    map(int16(x(a)),int16(y(a)),1) = 255;map(int16(x(a)),int16(y(a)),2) = 0;map(int16(x(a)),int16(y(a)),3) = 0; %draw red line
end
image(map)
%% draw individual north
lineLength = 50;
n=length(r)-1;
angle = r(n);
xp(1) = y(n);
yp(1) = x(n);
xp(2) = xp(1) + lineLength * cosd(angle);
yp(2) = yp(1) + lineLength * sind(angle);
image(map);
hold on;
line(xp, yp);
north={xp,yp,angle}; %save x and y of line + rotation of player
%% Save
suj_num = str2double(input('Enter subject number (1-50): ','s'));
if suj_num < 1 || suj_num > 50
    error('subject number invalid');
end
if suj_num < 10
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Position/','Map_','VP_',num2str(0),num2str(suj_num),'.mat');
else
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Position/','Map_','VP_',num2str(suj_num),'.mat');
end 
save(current_name,'map')
if suj_num < 1 || suj_num > 50
    error('subject number invalid');
end
if suj_num < 10
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Position/','North_','VP_',num2str(0),num2str(suj_num),'.mat');
else
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Position/','North_','VP_',num2str(suj_num),'.mat');
end 
save(current_name,'north')
suj_num = str2double(input('Enter subject number (1-50): ','s'));
if suj_num < 10
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Position/','Path_','VP_',num2str(0),num2str(suj_num),'.mat');
else
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Position/','Path_','VP_',num2str(suj_num),'.mat');
end 
save(current_name,'path')
%clear all