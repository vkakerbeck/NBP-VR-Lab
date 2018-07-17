%---------------Compare Gaze While Standing to Walking--------------------- 
sourcepath = 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\';%path to tracking folder
%--------------------------------------------------------------------------
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
    files = dir('EyesOnScreen_VP*.txt');%Analyzes all subjectfiles in your ViewedHouses directory
end
%Analyze ------------------------------------------------------------------
Number = length(files);
StandX = [];
StandY = [];
WalkX = [];
WalkY = [];
Xall = [];
Yall = [];
StandWalk = cell(2,Number);
for ii = 2:Number
    if Condition == "All"
        suj_num = files(ii).name(16:19);
    else
        suj_num = files(ii);
    end
    disp(suj_num);
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
    try
        pdata = fopen(strcat(sourcepath,'position\positions_VP',num2str(suj_num),'.txt'));
        pdata = textscan(pdata,'%s','delimiter', '\n');
        pdata = pdata{1};
        pdata = table2array(cell2table(pdata));
    catch
        continue
    end
    plen = int64(length(pdata));
    for p = 1:length(data)-1
        if(str2double(data{p}(2:9))==0||abs(str2double(data{p}(2:9)))>1||abs(str2double(data{p}(12:19)))>1)||p>=plen
        else
            line = textscan(pdata{p},'%s','delimiter', ',');line = line{1};
            Xp(end+1) = str2num(cell2mat(line(1)));
            Yp(end+1) = str2num(cell2mat(line(3)));
            X(end+1) = str2double(data{p}(2:9))-0.5;
            Y(end+1) = str2double(data{p}(12:19))-0.5;
        end
    end
    X = X(abs(Y)<0.5);Y = Y(abs(Y)<0.5);
    X = X(abs(X)<0.5);Y = Y(abs(X)<0.5);
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
    fclose('all');
end
StandWalk=cell2table(StandWalk);
StandWalk.Properties.RowNames={'Standing','Walking'};
%save([sourcepath '\EyesOnScreen\StandWalk' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.mat'],'StandWalk')
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
h=pcolor(HMNormN);colorbar;hold off;
set(h, 'EdgeColor', 'none');
subplot(2,2,2);hold;
title('Gaze Stand-Walk');
h2=pcolor(HMStandN-HMWalkN);colorbar;hold off;
set(h2, 'EdgeColor', 'none');
subplot(2,2,3);hold;
title('Gaze During Standing');
h3=pcolor(HMStandN);colorbar;
set(h3, 'EdgeColor', 'none');
subplot(2,2,4);hold;
title('Gaze During Walking');
h4=pcolor(HMWalkN);colorbar;
set(h4, 'EdgeColor', 'none');
%saveas(gcf,fullfile(sourcepath,'EyesOnScreen\Results\',['GazeWalkStandHeatmap' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.jpeg']));
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
%saveas(gcf,fullfile(sourcepath,'EyesOnScreen\Results\',['GazeWalkStand' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.jpeg']));
VarianceStandX = var(StandX);VarianceStandY = var(StandY);
VarianceWalkX = var(WalkX);VarianceWalkY = var(WalkY);
[hx,px] = vartest2(StandX,WalkX,0.0001,'right');
[hy,py] = vartest2(StandY,WalkY,0.0000001,'both');
variances = table([VarianceStandX;VarianceStandY], [VarianceWalkX;VarianceWalkY],[px;py]);
variances.Properties.VariableNames = {'Standing','Walking','pValues'};
variances.Properties.RowNames = {'X','Y'};
%save([sourcepath 'EyesOnScreen\Results\Variances' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.mat'],'variances');
%clear all;
