%--------------------------PositionAnalysis--------------------------------
%PartList = {2907};%subjects you want to analyze
files = dir('positions_VP*.txt');%Analyzes all subjectfiles in your positions directory
sourcepath = 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\';%path to tracking folder
%--------------------------------------------------------------------------
Number = length(files);%length(PartList);
map = imread('map5.png'); 
map = imresize(map,[500 450]);
mapC = map;
lineLength = 50;
for ii = 1:Number
    %Read in map and positions
    suj_num = files(ii).name(13:16);
%----------Comment in if you are using PartList to only analyze
%specific subjects---------------------------------------------
%     disp(suj_num);
%     if suj_num < 10
%         file = strcat('positions_VP',num2str(0),num2str(suj_num),'.txt');
%     else
%         file = strcat('positions_VP',num2str(suj_num),'.txt');
%     end
%---------------------------------------------------------------
    data = fopen(files(ii).name);
    %data = fopen(file);
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
        line = textscan(data{a},'%s','delimiter', ',');line = line{1};
        x(a) = str2num(cell2mat(line(1)))-180;
        y(a) = str2num(cell2mat(line(3)))-535;
        r(a) = str2num(cell2mat(line(5)));
        path(1,a)=x(a);path(2,a)=y(a);
    end
    derivR = abs(diff(r)*100);
    for a = 1:double(len)-1
        color = derivR(a);
        map(int16(x(a)),int16(y(a)),1) = 0;
        map(int16(x(a)),int16(y(a)),2) = color*3;
        map(int16(x(a)),int16(y(a)),3) = color*10; %draw line colored by change in rotation (light blue = much change)
    end
    %image(map);
    %-----------------------Individual North-------------------------------
    n=length(r)-1;
    angle = r(n);
    xp(1) = y(n); yp(1) = x(n);
    xp(2) = xp(1) + lineLength * cosd(angle);
    yp(2) = yp(1) + lineLength * sind(angle);
    north={xp,yp,angle}; %save x and y of line + rotation of player
    %----------------------Colored Rotation Map----------------------------
%     eyeD = fopen([sourcepath 'EyesOnScreen\EyesOnScreen_VP' num2str(suj_num) '.txt']);
%     eyeD = textscan(eyeD,'%s','delimiter', '\n');
%     eyeD= eyeD{1};
%     eyeD = table2array(cell2table(eyeD));
%     ln = int64(length(eyeD));
%     X = zeros(1,ln+1);
%     for n = 1:double(ln)
%         X(n) = (str2double(eyeD{n}(2:9))-0.5);
%         if(X(n)>0.5||X(n)<-0.5||X(n)==-0.5)
%             X(n) = 0;
%         end
%     end
%     newr = r - X*90;
%     derivR = abs(diff(newr)*100);
%     for a = 1:double(len)-1
%         color = derivR(a);
%         mapC(int16(x(a)),int16(y(a)),1) = 0;
%         mapC(int16(x(a)),int16(y(a)),2) = color;
%         mapC(int16(x(a)),int16(y(a)),3) = color*10; %draw red line
%     end
%     image(mapC);
    %-----------------------------Save-------------------------------------
    current_name = strcat(sourcepath,'Position/','Map_','VP_',num2str(suj_num),'.mat');
    save(current_name,'map')
    current_name = strcat(sourcepath,'Position/','North_','VP_',num2str(suj_num),'.mat');
    save(current_name,'north')
    current_name = strcat(sourcepath,'Position/','Path_','VP_',num2str(suj_num),'.mat');
    save(current_name,'path')
end
clear all;