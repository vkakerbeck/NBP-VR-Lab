%---------------Compare Gaze Before Left and Right Turns------------------- 
sourcepath = 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\';%path to tracking folder
IntervalLength = 10;%Significant turn +_Interval Length = Interval of gazes counted for turn
TurnSignificance = 20;%amount of rotation degree change for something to classified as turn
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
rightpX = [];rightpY = [];
leftpX = [];leftpY = [];
normpX = [];normpY = [];
for ii = 1:Number
    if Condition == "All"
        suj_num = files(ii).name(16:19);
    else
        suj_num = files(ii);
    end
    disp(suj_num);
    turnsright = [];
    turnsleft = [];
    rightI = [];
    leftI = [];
    data = fopen(['EyesOnScreen_VP' suj_num,'.txt']);
    data = textscan(data,'%s','delimiter', '\n');
    data = data{1};
    data = table2array(cell2table(data));
    len = int16(length(data));
    X = zeros(1,len);
    Y = zeros(1,len);
    %cut out certain part
    try
        rdata = fopen(strcat(sourcepath,'Position\positions_VP',suj_num,'.txt'));
        rdata = textscan(rdata,'%s','delimiter', '\n');
        rdata = rdata{1};
        rdata = table2array(cell2table(rdata));
        rlen = int16(length(rdata)/9);
    catch
        continue
    end
    r = zeros(1,rlen);
    %extract rotation information------------------------------------------
    for a = 1:double(len)-1
        liner = textscan(rdata{a},'%s','delimiter', ',');liner = liner{1};
        r(a) = str2num(cell2mat(liner(4)));
    end
    %clear rdata;
    %look for significant turns--------------------------------------------
    for a = IntervalLength+1:double(rlen)
        if r(a)-r(a-IntervalLength)>TurnSignificance
            turnsright(end+1) = a-IntervalLength;
        end
        if r(a)-r(a-IntervalLength)<-TurnSignificance
            turnsleft(end+1) = a-IntervalLength;
        end
    end
    %take out multiple detections of same turn-----------------------------
    for i=length(turnsright):-1:2
        if turnsright(i)-turnsright(i-1)==1
           turnsright(i)=0; 
        end
    end
    for i = length(turnsleft):-1:2
        if turnsleft(i)-turnsleft(i-1)==1
           turnsleft(i)=0; 
        end
    end
    turnsright = turnsright(turnsright~=0);%take multiple turns out of list
    turnsleft = turnsleft(turnsleft~=0);
    %define intervals------------------------------------------------------
    for e = 1:length(turnsright)
        rightI = [rightI turnsright(e)-IntervalLength:turnsright(e)+IntervalLength];
    end
    for e = 1:length(turnsleft)
        leftI = [leftI turnsleft(e)-IntervalLength:turnsleft(e)+IntervalLength];
    end
    %Sort view points into 3 categories------------------------------------
    for a = 1:len-1
       X(a) = str2double(data{a}(2:9));
       Y(a) = str2double(data{a}(12:19));
    end
    
    meanX = mean(X(X~=0));meanY = mean(Y(Y~=0));
    %X = X-meanX;Y = Y-meanY;
    X = X-0.5;Y = Y-0.5;
    X = X(abs(Y)<0.4);Y = Y(abs(Y)<0.4);
    X = X(abs(X)<0.4);Y = Y(abs(X)<0.4);
    len = int16(length(X));
    
    for a = 50:len-100
       if(X(a)~=0 &&X(a-1)~=0 &&Y(a)~=0 &&Y(a-1)~=0 &&X(a)>-0.5&&Y(a)>-0.5&&X(a)<0.5&&Y(a)<0.5)%cut out false/uncertain recordings
           if ismember(a,rightI)
               rightpX(end+1) = X(a);rightpY(end+1) = Y(a);
           elseif ismember(a,leftI)
               leftpX(end+1) = X(a);leftpY(end+1) = Y(a);
           else
               normpX(end+1) = X(a);normpY(end+1) = Y(a);
           end
       end
    end
    fclose('all');
end
scatter(normpX,normpY);hold;scatter(rightpX,rightpY);scatter(leftpX,leftpY);
[n,c] = hist3([normpX', normpY']);
contour(c{1},c{2},n',12,'-','LineWidth',2);colorbar;
legend('Standard','Right Turn','Left Turn');
title('Gaze During Left and Right Turns');
xlabel('X');ylabel('Y');
plot(mean(rightpX),mean(rightpY),'k.','MarkerSize',35)
plot(mean(rightpX),mean(rightpY),'r.','MarkerSize',30)
plot(mean(leftpX),mean(leftpY),'k.','MarkerSize',35)
plot(mean(leftpX),mean(leftpY),'y.','MarkerSize',30)
plot(mean(normpX),mean(normpY),'k.','MarkerSize',35)
plot(mean(normpX),mean(normpY),'b.','MarkerSize',30)
saveas(gcf,fullfile(sourcepath,'EyesOnScreen\Results\',['GazeLeftRight' num2str(Number) 'SJs_' 'itv' num2str(IntervalLength) 'Tsig' num2str(TurnSignificance) '.jpeg']));
%% Make Heatmaps-----------------------------------------------------------
size = 50;
HMNorm = hist3([[normpX -0.3 0.3]', [normpY -0.3 0.3]'],[size,size]);
HMNormN = HMNorm/norm(HMNorm);
HMRight = hist3([[rightpX -0.3 0.3]', [rightpY -0.3 0.3]'],[size,size]);
HMRightN = HMRight/norm(HMRight);
HMLeft = hist3([[leftpX -0.3 0.3]', [leftpY -0.3 0.3]'],[size,size]);
HMLeftN = HMLeft/norm(HMLeft);
figure;
subplot(2,2,1);hold;
title('Gaze During No Turn');
h=pcolor(HMNormN);colorbar;hold off;
set(h, 'EdgeColor', 'none');
subplot(2,2,3);hold;
title('Gaze During Right Turn');
h2=pcolor(HMRightN);colorbar;
set(h2, 'EdgeColor', 'none');
subplot(2,2,4);hold;
title('Gaze During Left Turn');
h3=pcolor(HMLeftN);colorbar;
set(h3, 'EdgeColor', 'none');
saveas(gcf,fullfile(sourcepath,'EyesOnScreen\Results\',['HeatMapLeftRight' num2str(Number) 'SJs_' 'itv' num2str(IntervalLength) 'Tsig' num2str(TurnSignificance) '.jpeg']));
%ttest the three distributions (left, right, normal)-----------------------
[hn pn] = ttest(normpX,0,'Alpha',0.01);
[hl pl] = ttest(leftpX,0,'Alpha',0.01);
[hr pr] = ttest(rightpX,0,'Alpha',0.01);
ttests = table([hn;pn],[hl;pl],[hr;pr]);
ttests.Properties.VariableNames = {'Normal','Left','Right'};
ttest.Properties.RowNames = {'Hypothesis Rejected','P-Value'};
save([sourcepath 'EyesOnScreen\Results\TTestLR' num2str(Number) 'SJs_' 'itv' num2str(IntervalLength) 'Tsig' num2str(TurnSignificance) '.mat'],'ttests');
clear all;