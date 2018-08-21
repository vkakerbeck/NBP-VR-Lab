% Analyze the performance in the absolute orientation task in dependence on
% how close participants' individual North was to the true North
% Question: Are those subjects whose individual north is closer to the true
% North better in the absolute orientation task?


clear all;
clc;


% list of participants
% CHANGE: to the participants you want to analyze
PartList = {2907, 5324, 4302, 7561, 6348, 4060, 6503, 7535, 1944, 8457, 3854, 2637, 5579, 7018, 8580, 1961, 6844, 8804, 7350, 3116};
Number = length(PartList);



%--------------------------------------------------------------------------
% get the necessary information

% read in performance
% CHANGE: to where you stored this file
load('../Daten/Tasks/Performance.mat');

% for saving the deviation from true North and the performance
Deviation = [];
Performance = [];
IndNorth = [];
% save whether deviation from true North is + or - (0 if it's + and 1 if
% it's -) (true North is at 270°) (example: thinks North is at 280° 
% -> deviation of 10° from true North and it's + -> so 0 would be saved in 
% Flipped) (so it's 0 from 270° until 90° and 1 for the rest)
Flipped = [];

% for every participant
for i = 1:Number
    e = cell2mat(PartList(i));
    
    % average performance in the absolute task in both time conditions
    % for this participant
    p = (cell2mat(Performances(i,2)) + cell2mat(Performances(i,3)))/2;
    Performance = [Performance p];
    
    % CHANGE: to where you stored this data
    n = load(['../Daten/Eyetracking/Position/North_VP_' num2str(e) '.mat']);
    % true north is rotation of 270 degrees
    d = cell2mat(n.north(3));
    %disp(d);
    IndNorth = [IndNorth d];
    if d >= 270
        d = d-270;
        Flipped = [Flipped 0];
    elseif d < 270 && d >= 90
        d = 270-d;
        Flipped = [Flipped 1];
    elseif d < 90
        d = 90 + d;
        Flipped = [Flipped 0];
    end
    %disp(d);
    Deviation = [Deviation d];
end



%--------------------------------------------------------------------------
% calculate performance in absolute tasks corrected for the participants'
% individual North

CorrectedPerformance = [];

% for every participant
for i = 1:Number
    
    e = cell2mat(PartList(i));
    % CHANGE: to where you stored this data
    load(['../Daten/Tasks/AlignmentVR_SubjNo_',num2str(e),'.mat']);
    IndN = IndNorth(i);
    Abs3s = [];
    AbsInf = [];
    
    % go through every trial in the absolute tasks and save
    % 1) correct North for this trial (which is old correct North +/-
    % deviation from true North for this participant)
    % 2) new correct answer (which is the answer that is closer to the new
    % correct North for this trial)
    for j = 1:36
        
        % for step 1)
        if (Flipped(i) == 0)
            NCN3s = Output.Absolute.Trial_3s(j).Correct_Angle + Deviation(i);
            NCNInf = Output.Absolute.Trial_Inf(j).Correct_Angle + Deviation(i);
        else
            NCN3s = Output.Absolute.Trial_3s(j).Correct_Angle - Deviation(i);
            NCNInf = Output.Absolute.Trial_Inf(j).Correct_Angle - Deviation(i);
        end
        
        if NCN3s >= 360
            NCN3s = NCN3s - 360;
        end
        if NCN3s < 0
            NCN3s = 360 + NCN3s;
        end
        if NCNInf > 360
            NCNInf = NCNInf - 360;
        end
        if NCNInf < 0
            NCNInf = 360 + NCNInf;
        end
        
        Output.Absolute.Trial_3s(j).NewCorrectNorth = NCN3s;
        Output.Absolute.Trial_Inf(j).NewCorrectNorth = NCNInf;
        
        % for step 2)
        DiffCorrect3s = abs(NCN3s - Output.Absolute.Trial_3s(j).Correct_Angle);
        DiffWrong3s = abs(NCN3s - Output.Absolute.Trial_3s(j).Wrong_Angle);
        DiffCorrectInf = abs(NCNInf - Output.Absolute.Trial_Inf(j).Correct_Angle);
        DiffWrongInf = abs(NCNInf - Output.Absolute.Trial_Inf(j).Wrong_Angle);
        
        if DiffCorrect3s > 180
            DiffCorrect3s = 360 - DiffCorrect3s;
        end
        if DiffWrong3s > 180
            DiffWrong3s = 360 - DiffWrong3s;
        end
        if DiffCorrectInf > 180
            DiffCorrectInf = 360 - DiffCorrectInf;
        end
        if DiffWrongInf > 180
            DiffWrongInf = 360 - DiffWrongInf;
        end
        
        
        if DiffCorrect3s < DiffWrong3s
            Output.Absolute.Trial_3s(j).NewCorrectAnswer = Output.Absolute.Trial_3s(j).Correct;
        else
            if strcmp(Output.Absolute.Trial_3s(j).Correct, 'Up') == 1
                Output.Absolute.Trial_3s(j).NewCorrectAnswer = 'Down';
            else
                Output.Absolute.Trial_3s(j).NewCorrectAnswer = 'Up';
            end
        end
        
        if DiffCorrectInf < DiffWrongInf
            Output.Absolute.Trial_Inf(j).NewCorrectAnswer = Output.Absolute.Trial_Inf(j).Correct;
        else
            if strcmp(Output.Absolute.Trial_Inf(j).Correct, 'Up') == 1
                Output.Absolute.Trial_Inf(j).NewCorrectAnswer = 'Down';
            else
                Output.Absolute.Trial_Inf(j).NewCorrectAnswer = 'Up';
            end
        end
        
    end
    
    % calculate the new performance (corrected for individual North)
    for j = 1:36
        Abs3s = [Abs3s strcmp(Output.Absolute.Trial_3s(j).NewCorrectAnswer, Output.Absolute.Trial_3s(j).Decision)];
        AbsInf = [AbsInf strcmp(Output.Absolute.Trial_Inf(j).NewCorrectAnswer, Output.Absolute.Trial_Inf(j).Decision)]; 
    end
    
    Abs3sP = 100*sum(Abs3s)/36;
    AbsInfP = 100*sum(AbsInf)/36;
    cp = (Abs3sP + AbsInfP)/2;
    CorrectedPerformance = [CorrectedPerformance cp];
    
end



%--------------------------------------------------------------------------
% plotting

sc1 = scatter(Deviation, Performance, '*', 'b');
xlabel('Deviation from True North in Degrees');
ylabel('Performance in %');
title({'Performance in the Absolute Orientation Task', 'in Dependence on Deviation from True North'});
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
yticks([40 50 60 70]);
ylim([35 75]);
xticks([0 30 60 90 120 150 180]);
hold on;
sc2 = scatter(Deviation, CorrectedPerformance, '+', 'g');
hold on;
hline = refline([0, 50]);
hline.Color = 'r';
hline.LineStyle = '--';
legend([sc1 sc2],{'Performance', 'Performance Corrected for Individual North'});



%--------------------------------------------------------------------------
% Median split based on deviation from true North
% Are the 10 people closest to North better in the absolute orientation
% task compared to the 10 people most far away from true North?

[DeviationSorted Index] = sort(Deviation);

% mean performance in the absolute orientation task and deviation from true
% North of the 10 best participants
performanceBest = 0;
deviationBest = 0;
Best = [];

for i = 1:(Number/2)
    performanceBest = performanceBest + Performance(Index(i));
    Best = [Best Performance(Index(i))];
    deviationBest = deviationBest + DeviationSorted(i);
end

performanceBest = performanceBest/(Number/2);
deviationBest = deviationBest/(Number/2);


% mean performance in the absolute orientation task and deviation from true
% North of the 10 worst participants
performanceWorst = 0;
deviationWorst = 0;
Worst = [];

for i = (Number/2+1):Number
    performanceWorst = performanceWorst + Performance(Index(i));
    Worst = [Worst Performance(Index(i))];
    deviationWorst = deviationWorst + DeviationSorted(i);
end

performanceWorst = performanceWorst/(Number/2);
deviationWorst = deviationWorst/(Number/2);


% standard error of the mean (SEM)
SEMBest = std(Best)/sqrt((Number/2));
SEMWorst = std(Worst)/sqrt((Number/2));


% t-Test
[h,pValue,ci,stats] = ttest2(Best,Worst);
disp(pValue);
disp(stats);


% plotting
figure;
bar([performanceBest performanceWorst], 'BarWidth', 0.7);
hline = refline([0, 50]);
hline.Color = 'r';
hline.LineStyle = '--';
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
ylim([42 60]);
yticks([45 50 55 60]);
title({'Median Split for the Performance in the Absolute Orientation Task', 'Based on the Deviation from True North'});
ylabel('Performance in %');
c = newline;
xticklabels({'Least Deviation' 'Most Deviation'});
hold on;
e = errorbar(1:2,[performanceBest performanceWorst],[SEMBest SEMWorst], 'k');
e.LineStyle = 'none';

