suj_num = '27';%input('Enter subject number (1-50): ','s');
data = fopen(['EyesOnScreen_VP' suj_num,'.txt']);
data = textscan(data,'%s','delimiter', '\n');
data = data{1};
data = table2array(cell2table(data));
X = [];
Y = [];
pdata = fopen(strcat('D:\v.kakerbeck\Tracking\Position\positions_VP',num2str(suj_num),'.txt'));
pdata = textscan(pdata,'%s','delimiter', '\n');
pdata = pdata{1};
pdata = table2array(cell2table(pdata));
plen = int64(length(pdata));
Xp = [];
Yp = [];
for p = 1:plen
    if(str2double(data{p}(2:9))==0||str2double(data{p}(2:9))>1||str2double(data{p}(2:9))<0)
        
    else
        line = textscan(pdata{p},'%s','delimiter', ',');line = line{1};
        Xp(end+1) = str2num(cell2mat(line(1)));
        Yp(end+1) = str2num(cell2mat(line(3)));
        X(end+1) = str2double(data{p}(2:9))-0.5;
        Y(end+1) = str2double(data{p}(12:19))-0.5;
    end
end
dXp = diff(Xp);dYp=diff(Yp);
StandX = [];
StandY = [];
WalkX = [];
WalkY = [];
len = int64(length(X));
for i = 1:len-1
   if(dXp(i)<0.05 && dYp(i)<0.05)
       StandX(end+1) = X(i);
       StandY(end+1) = Y(i);
   else
       WalkX(end+1) = X(i);
       WalkY(end+1) = Y(i);
   end
end
scatter(StandX,StandY);hold on;scatter(WalkX,WalkY);
title('Gaze While Standing and While Walking');
xlabel('X');
ylabel('Y');
legend('Gaze While Standing','Gaze While Walking');