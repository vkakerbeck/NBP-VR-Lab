%--Analyze the task performance for each participant-----------------------
% IMPORTANT: no answer in the 3s condition is counted as a false answer

clear all;
clc;

% list of participants
% CHANGE: to the participants you want to analyze
PartList = {2907, 5324, 4302, 7561, 6348, 4060, 6503, 7535, 1944, 8457, 3854, 2637, 5579, 7018, 8580, 1961, 6844, 8804, 7350, 3116};
Number = length(PartList);



%--------------------------------------------------------------------------
% calculate the performances


% cell with the performance for each task in each time condition for every 
% participants
Performances = cell(Number, 8);


% for each participant
for i = 1:Number
    e = cell2mat(PartList(i));
    % CHANGE: to where you stored this data
    load(['../Daten/Tasks/AlignmentVR_SubjNo_',num2str(e),'.mat']);
    Abs3sec = [];
    AbsInf = [];
    Rel3sec = [];
    RelInf = [];
    Poi3sec = [];
    PoiInf = [];
    
    % for each trial extract whether the answer was correct or wrong
    for j = 1:36
        Abs3sec = [Abs3sec strcmp(Output.Absolute.Trial_3s(j).Correct, Output.Absolute.Trial_3s(j).Decision)];
        AbsInf = [AbsInf strcmp(Output.Absolute.Trial_Inf(j).Correct, Output.Absolute.Trial_Inf(j).Decision)];
        Rel3sec = [Rel3sec strcmp(Output.Relative.Trial_3s(j).Correct, Output.Relative.Trial_3s(j).Decision)];
        RelInf = [RelInf strcmp(Output.Relative.Trial_Inf(j).Correct, Output.Relative.Trial_Inf(j).Decision)];    
        Poi3sec = [Poi3sec strcmp(Output.Pointing.Trial_3s(j).Correct, Output.Pointing.Trial_3s(j).Decision)];
        PoiInf = [PoiInf strcmp(Output.Pointing.Trial_Inf(j).Correct, Output.Pointing.Trial_Inf(j).Decision)];
    end
    
    disp(['Participant ', num2str(e), ':'])
    % in this order the performanes are also written into the cell array
    disp(['Im Absolute Task 3s korrekt: ' num2str(100*sum(Abs3sec)/36) '%']);
    disp(['Im Absolute Task Inf korrekt: ' num2str(100*sum(AbsInf)/36) '%']);
    disp(['Im Relative Task 3s korrekt: ' num2str(100*sum(Rel3sec)/36) '%']);
    disp(['Im Relative Task Inf korrekt: ' num2str(100*sum(RelInf)/36) '%']);
    disp(['Im Pointing Task 3s korrekt: ' num2str(100*sum(Poi3sec)/36) '%']);
    disp(['Im Pointing Task Inf korrekt: ' num2str(100*sum(PoiInf)/36) '%']);
    % also save the participant number
    Performances(i, 1) = num2cell(e);
    Performances(i, 2:end-1) = num2cell([(100*sum(Abs3sec)/36); (100*sum(AbsInf)/36); (100*sum(Rel3sec)/36); (100*sum(RelInf)/36); (100*sum(Poi3sec)/36); (100*sum(PoiInf)/36)]);
    % and the overall task performance for this participant
    Performances(i, 8) = num2cell((100*sum(Abs3sec)/36 + 100*sum(AbsInf)/36 + 100*sum(Rel3sec)/36 + 100*sum(RelInf)/36 + 100*sum(Poi3sec)/36 + 100*sum(PoiInf)/36)/6);
end


% csv-file can be imported into SPSS to compute an ANOVA there
% CHANGE: to where you want to store this data
csvwrite('../Daten/Tasks/Performance.csv', Performances);
save('../Daten/Tasks/Performance.mat', 'Performances');


% compute the mean performance over all participants and the standard error
% of the mean (SEM)
tmp = cell2mat(Performances);

Abs3secOverall = mean(tmp(1:Number, 2));
SEMAbs3sec = std(tmp(1:Number, 2))/sqrt(Number);
AbsInfOverall = mean(tmp(1:Number, 3));
SEMAbsInf = std(tmp(1:Number, 3))/sqrt(Number);

Rel3secOverall = mean(tmp(1:Number, 4));
SEMRel3sec = std(tmp(1:Number, 4))/sqrt(Number);
RelInfOverall = mean(tmp(1:Number, 5));
SEMRelInf = std(tmp(1:Number, 5))/sqrt(Number);

Poi3secOverall = mean(tmp(1:Number, 6));
SEMPoi3sec = std(tmp(1:Number, 6))/sqrt(Number);
PoiInfOverall = mean(tmp(1:Number, 7));
SEMPoiInf = std(tmp(1:Number, 7))/sqrt(Number);

disp('Mean Performance and SEM');
disp(['   Abs3sec' '   AbsInf' '    Rel3sec' '   RelInf' '    Poi3sec' '   PoinInf']);
disp([Abs3secOverall AbsInfOverall Rel3secOverall RelInfOverall Poi3secOverall PoiInfOverall]);
disp([SEMAbs3sec SEMAbsInf SEMRel3sec SEMRelInf SEMPoi3sec SEMPoiInf]);



%--------------------------------------------------------------------------
% plotting

% Data to be plotted as a bar graph
model_series = [Abs3secOverall AbsInfOverall; Rel3secOverall RelInfOverall; Poi3secOverall PoiInfOverall];

% Data to be plotted as the error bars
model_error = [SEMAbs3sec SEMAbsInf; SEMRel3sec SEMRelInf; SEMPoi3sec SEMPoiInf];

% Creating axes and the bar graph
ax = axes;
h = bar(model_series,'BarWidth',1);

% line for chance level
hline = refline([0, 50]);

% Set colors and line style
h(1).FaceColor = 'c';
h(2).FaceColor = 'g';
hline.Color = 'r';
hline.LineStyle = '--';

% Properties of the bar graph as required
ax.GridLineStyle = '-';
xticks(ax,[1 2 3]);
ylim([45 60]);
yticks([45 50 55 60]);
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');

% Naming each of the bar groups
xticklabels(ax,{'Absolute', 'Relative', 'Pointing'});
title('Performance in the Different Tasks and Time Conditions');

% X and Y labels
xlabel('Task');
ylabel('Performance in %');

% Creating a legend and placing it inside the bar plot
lg = legend('3 seconds', 'Infinite', 'AutoUpdate', 'off');
lg.Location = 'northeast';
lg.Orientation = 'Vertical';

hold on;

% Finding the number of groups and the number of bars in each group
ngroups = size(model_series, 1);
nbars = size(model_series, 2);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));

% adding the error bars
x1 = (1:ngroups) - (groupwidth/2) + (2*1-1) * (groupwidth / (2*nbars));
errorbar(x1, model_series(:,1), model_error(:,1), 'k', 'linestyle', 'none');

x2 = (1:ngroups) - (groupwidth/2) + (2*2-1) * (groupwidth / (2*nbars));
errorbar(x2, model_series(:,2), model_error(:,2), 'k', 'linestyle', 'none');


