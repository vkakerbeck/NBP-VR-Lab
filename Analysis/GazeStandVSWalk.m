%---------------Compare Gaze While Standing to Walking--------------------- 
PartList = {3755,6876};%List of subject numbers
sourcepath = 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\';%path to tracking folder
%--------------------------------------------------------------------------
Number = length(PartList);
StandX = [];
StandY = [];
WalkX = [];
WalkY = [];
Xall = [];
Yall = [];
StandWalk = cell(2,Number);
for ii = 1:Number
    suj_num = num2str(cell2mat(PartList(ii)));
    startS = length(StandX);
    startW = length(WalkX);
    X = [];
    Y = [];
    Xp = [];
    Yp = [];
    data = fopen(['EyesOnScreen_VP' suj_num,'.txt']);
    data = textscan(data,'%s','delimiter', '\n');
    data = data{1};
    data = table2array(cell2table(data));
    pdata = fopen(strcat(sourcepath,'position\positions_VP',num2str(suj_num),'.txt'));
    pdata = textscan(pdata,'%s','delimiter', '\n');
    pdata = pdata{1};
    pdata = table2array(cell2table(pdata));
    plen = int64(length(pdata));
    for p = 1:plen-1
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
    standing = length(StandX);
    walking = length(WalkX);
    StandWalk(1,ii)=num2cell(standing-startS);StandWalk(2,ii)=num2cell(walking-startW);
    Xall = [Xall, X];
    Yall = [Yall, Y];
end
StandWalk=cell2table(StandWalk);
StandWalk.Properties.RowNames={'Standing','Walking'};
save([sourcepath '\EyesOnScreen\StandWalk' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.mat'],'StandWalk')
if length(StandX)>length(WalkX)
    limit = length(WalkX);
else
    limit = length(StandX);
end   
%% ---------------General Heatmap------------------------------------------
size = 50;
HMNorm = hist3([Xall', Yall'],[size,size]);
HMNormN = HMNorm/norm(HMNorm);
HMStand = hist3([StandX(1:limit)', StandY(1:limit)'],[size,size]);
HMStandN = HMStand/norm(HMStand);
HMWalk = hist3([WalkX(1:limit)', WalkY(1:limit)'],[size,size]);
HMWalkN = HMWalk/norm(HMWalk);
figure;
subplot(2,2,1);hold;
title('Gaze Overall');
pcolor(HMNormN);colorbar;hold off;
subplot(2,2,2);hold;
title('Gaze Stand-Walk');
pcolor(HMStandN-HMWalkN);colorbar;hold off;
subplot(2,2,3);hold;
title('Gaze During Standing');
pcolor(HMStandN);colorbar;
subplot(2,2,4);hold;
title('Gaze During Walking');
pcolor(HMWalkN);colorbar;
saveas(gcf,fullfile(sourcepath,'EyesOnScreen\Results\',['GazeWalkStandHeatmap' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.jpeg']));
%% ---------------Comparing Gaze Walking to Gaze Standing------------------
scatter(StandX(1:limit),StandY(1:limit));hold;
scatter(WalkX(1:limit),WalkY(1:limit));colorbar;
[ns,cs] = hist3([StandX', StandY']);
contour(cs{1},cs{2},ns,'-','LineWidth',2);
[nw,cw] = hist3([WalkX', WalkY']);
contour(cw{1},cw{2},nw,':','LineWidth',2);
legend('Gaze while standing (line)','Gaze while walking (dotted)');
title('Gaze During Walking and Standing');
xlabel('X');ylabel('Y');
saveas(gcf,fullfile(sourcepath,'EyesOnScreen\Results\',['GazeWalkStand' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.jpeg']));
VarianceStandX = var(StandX);VarianceStandY = var(StandY);
VarianceWalkX = var(WalkX);VarianceWalkY = var(WalkY);
[hx,px] = vartest2(StandX,WalkX,0.0001,'right');
[hy,py] = vartest2(StandY,WalkY,0.0000001,'both');
variances = table([VarianceStandX;VarianceStandY], [VarianceWalkX;VarianceWalkY],[px;py]);
variances.Properties.VariableNames = {'Standing','Walking','pValues'};
variances.Properties.RowNames = {'X','Y'};
save([sourcepath 'EyesOnScreen\Results\Variances' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.mat'],'variances');
%clear all;
