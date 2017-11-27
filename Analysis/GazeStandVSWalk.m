%---------------Compare Gaze While Standing to Walking--------------------- 
PartList = {27};%input('Enter subject number (1-50): ','s');
sourcepath = 'C:\Users\Vivi\Dropbox\Project Seahaven\Tracking\';%path to tracking folder
%--------------------------------------------------------------------------
Number = length(PartList);
StandX = [];
StandY = [];
WalkX = [];
WalkY = [];
for ii = 1:Number
    suj_num = num2str(cell2mat(PartList(ii)));
    X = [];
    Y = [];
    Xp = [];
    Yp = [];
    data = fopen(['EyesOnScreen_VP' suj_num,'.txt']);
    data = textscan(data,'%s','delimiter', '\n');
    data = data{1};
    data = table2array(cell2table(data));
    pdata = fopen(strcat(sourcepath,'Position\positions_VP',num2str(suj_num),'.txt'));
    pdata = textscan(pdata,'%s','delimiter', '\n');
    pdata = pdata{1};
    pdata = table2array(cell2table(pdata));
    plen = int64(length(pdata));
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
end
scatter(StandX,StandY);hold;scatter(WalkX,WalkY);
legend('Gaze while standing','Gaze while walking');
title('Gaze During Walking and Standing');
xlabel('X');ylabel('Y');
saveas(gcf,fullfile(sourcepath,'EyesOnScreen\Results\',['GazeWalkStand' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.jpeg']));
VarianceStandX = var(StandX);VarianceStandY = var(StandY);
VarianceWalkX = var(WalkX);VarianceWalkY = var(WalkY);
[hx,px] = vartest2(StandX,WalkX,0.0001,'right')
[hy,py] = vartest2(StandY,WalkY,0.0000001,'both')
variances = table([VarianceStandX;VarianceStandY], [VarianceWalkX;VarianceWalkY],[px;py]);
variances.Properties.VariableNames = {'Standing','Walking','pValues'};
variances.Properties.RowNames = {'X','Y'};
save([sourcepath 'EyesOnScreen\Results\Variances' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.mat'],'variances');
%clear all;