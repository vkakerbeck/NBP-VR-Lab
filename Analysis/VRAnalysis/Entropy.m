%--------------------Entropy Over Houses in Interval-----------------------
savepath = 'C:/Users/vivia/Dropbox/Project Seahaven/Tracking/';
IntervalLen = 2*30;%=2 seconds
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
    files = dir('ViewedHouses_VP*.txt');%Analyzes all subjectfiles in your ViewedHouses directory
end
% Analyze -----------------------------------------------------------------
Number = length(files);
avgdist = cell(1,Number);
avgEs = cell(2,Number+1);
avgEAll = 0;
for ii = 1:Number
    if Condition == "All"
        suj_num = files(ii).name(16:19);
    else
        suj_num = files(ii);
    end
    disp(suj_num);
    file = strcat('ViewedHouses/ViewedHouses_VP',num2str(suj_num),'.txt');
    data = fopen(file);
    data = textscan(data,'%s','delimiter', '\n');
    data = data{1};
    data = table2array(cell2table(data));
    %initialize fields
    len = int64(length(data));
    houses = cell(1,len);
    distance = zeros(1,len);
    timestamps = zeros(1,len);
    for a = 1:double(len)
        line = textscan(data{a},'%s','delimiter', ',');line = line{1};
        l = char(line(1));
        if l(1:2) == 'NH'
            house = 0;%XX add distance
        else
            house = str2num(l(1:3));
        end
        houses{a} = house;
    end
    avgdist = mean(distance);
    clear data;
    entropy = cell(1,len-IntervalLen);
    for s = 1:len-IntervalLen
        h = hist(cell2mat(houses(s:s+IntervalLen)));
        p = h/sum(h);
        entropy{s} = -nansum(times(p,log2(p)));
    end
    %plot(cell2mat(entropy))
    avgE = mean(cell2mat(entropy));
    avgEs{1,ii} = suj_num;
    avgEs{2,ii} = avgE;
    avgEAll = avgEAll + avgE;
    %saveas(gcf,fullfile(savepath,['Results\Entropy_' num2str(IntervalLen) '_' num2str(suj_num) '.jpeg']));
end
avgEs{1,end} = 'all';
avgEs{2,end} = avgEAll/Number;
save(fullfile(savepath,['TaskPerformance\Results\Entropy_' num2str(IntervalLen) '_' num2str(Number) 'SJs.mat']), 'avgEs');
hist([avgEs{2,:}])
%clear all;
%% Now we can look if people with higher entropy (more switches between houses) have better performance...
Performances = cell(7,Number);
for ii = 2: Number
    try
        load([savepath 'TaskPerformance/AlignmentVR_SubjNo_',avgEs{1,ii},'.mat']);
    catch
        continue
    end
    Abs3sec = [];
    AbsInf = [];
    Rel3sec = [];
    RelInf = [];
    Poi3sec = [];
    PoiInf = [];
    for i = 1:36%extract performance
        Abs3sec = [Abs3sec strcmp(Output.Absolute.Trial_3s(i).Correct,Output.Absolute.Trial_3s(i).Decision)];
        AbsInf = [AbsInf strcmp(Output.Absolute.Trial_Inf(i).Correct,Output.Absolute.Trial_Inf(i).Decision)];
        Rel3sec = [Rel3sec strcmp(Output.Relative.Trial_3s(i).Correct,Output.Relative.Trial_3s(i).Decision)];
        RelInf = [RelInf strcmp(Output.Relative.Trial_Inf(i).Correct,Output.Relative.Trial_Inf(i).Decision)];    
        Poi3sec = [Poi3sec strcmp(Output.Pointing.Trial_3s(i).Correct,Output.Pointing.Trial_3s(i).Decision)];
        PoiInf = [PoiInf strcmp(Output.Pointing.Trial_Inf(i).Correct,Output.Pointing.Trial_Inf(i).Decision)];
    end
    disp(['Subject ',avgEs{1,ii},':'])
%     disp(['Im Absolute Task 3sec korrekt: ' num2str(100*sum(Abs3sec)/36) '%']);%in thi sorder the performanes will be written into the cell array.
%     disp(['Im Absolute Task Inf korrekt: ' num2str(100*sum(AbsInf)/36) '%']);
%     disp(['Im Relative Task 3sec korrekt: ' num2str(100*sum(Rel3sec)/36) '%']);
%     disp(['Im Relative Task Inf korrekt: ' num2str(100*sum(RelInf)/36) '%']);
%     disp(['Im Pointing Task 3sec korrekt: ' num2str(100*sum(Poi3sec)/36) '%']);
%     disp(['Im Pointing Task Inf korrekt: ' num2str(100*sum(PoiInf)/36) '%']);
    Performances(1:end,ii)=num2cell([(100*sum(Abs3sec)/36);(100*sum(AbsInf)/36);(100*sum(Rel3sec)/36);(100*sum(RelInf)/36);(100*sum(Poi3sec)/36);(100*sum(PoiInf)/36);avgEs{2,ii}]);
end
%% Plot
f = figure;

l = LinearModel.fit([Performances{7,:}],[Performances{1,:}]);
pval = l.Coefficients.pValue(2);
ax1 = subplot(3,2,1);
scatter(ax1,[Performances{7,:}],[Performances{1,:}])
title(ax1,['Absolute, 3sec, p: ', num2str(pval)]);
l1 = lsline(ax1);l1.LineWidth = 3;l1.Color = 'r';

l = LinearModel.fit([Performances{7,:}],[Performances{2,:}]);
pval = l.Coefficients.pValue(2);
ax2 = subplot(3,2,2);
scatter(ax2,[Performances{7,:}],[Performances{2,:}])
title(ax2,['Absolute, Inf, p: ', num2str(pval)]);
l2 = lsline(ax2);l2.LineWidth = 3;l2.Color = 'r';

l = LinearModel.fit([Performances{7,:}],[Performances{3,:}]);
pval = l.Coefficients.pValue(2);
ax3 = subplot(3,2,3);
scatter(ax3,[Performances{7,:}],[Performances{3,:}])
title(ax3,['Relative, 3sec, p: ', num2str(pval)]);
l3 = lsline(ax3);l3.LineWidth = 3;l3.Color = 'r';

l = LinearModel.fit([Performances{7,:}],[Performances{4,:}]);
pval = l.Coefficients.pValue(2);
ax4 = subplot(3,2,4);
scatter(ax4,[Performances{7,:}],[Performances{4,:}])
title(ax4,['Relative, Inf, p: ', num2str(pval)]);
l4 = lsline(ax4);l4.LineWidth = 3;l4.Color = 'r';

l = LinearModel.fit([Performances{7,:}],[Performances{5,:}]);
pval = l.Coefficients.pValue(2);
ax5 = subplot(3,2,5);
scatter(ax5,[Performances{7,:}],[Performances{5,:}])
title(ax5,['Pointing, 3sec, p: ', num2str(pval)]);
l5 = lsline(ax5);l5.LineWidth = 3;l5.Color = 'r';

l = LinearModel.fit([Performances{7,:}],[Performances{6,:}]);
pval = l.Coefficients.pValue(2);
ax6 = subplot(3,2,6);
scatter(ax6,[Performances{7,:}],[Performances{6,:}])
title(ax6,['Pointing, Inf, p: ', num2str(pval)]);
l6 = lsline(ax6);l6.LineWidth = 3;l6.Color = 'r';
ax = findobj(f,'Type','Axes');
for i=1:length(ax)
    ylabel(ax(i),{'Performance in %'})
    xlabel(ax(i),{'Entropy'})
end
saveas(gcf,fullfile(savepath,['\TaskPerformance\Results\Performance_Entropy' num2str(IntervalLen/30) 'secInterval' num2str(Number) 'SJs.jpeg']));