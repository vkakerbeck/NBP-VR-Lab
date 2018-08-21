% Analyze the task performance in relation to the angular difference
% between the two choices and also test whether performance for 30°, 90°
% and 150° differs significantly from performance for 60°, 120° and 180°
% (would be related to grid cells and their 60° symmetric spiking pattern)


clear all;
clc;

% CHANGE: to the participants you want to analyze
PartList = {2907, 5324, 4302, 7561, 6348, 4060, 6503, 7535, 1944, 8457, 3854, 2637, 5579, 7018, 8580, 1961, 6844, 8804, 7350, 3116};
Number = length(PartList);

%--------------------------------------------------------------------------


% CHANGE: to your folder where this file is
load('./houseInformation.mat');

% cell for saving the overall performance of each participant for each of 
% the different angular differences
PerDiff = cell(20, 6);

% for each participant
for i = 1 : Number
    e = cell2mat(PartList(i));
    % CHANGE: to folder where task output of your participants is stored
    load(['C:/Users/vivia/Dropbox/Project Seahaven/Tracking/TaskPerformance/AlignmentVR_SubjNo_',num2str(e),'.mat']);
    
    
    % only for the relative orientation task
    
    % retrieve the orientation of prime, correct und wrong target from the
    % file houseInformation (as it is not stored in the task output)
    for j = 1 : 36
        numberPrimeInf = Output.Relative.Trial_Inf(j).Prime_Nr;
        numberCorrTargetInf = Output.Relative.Trial_Inf(j).TargetNr_Correct;
        numberWronTargetInf = Output.Relative.Trial_Inf(j).TargetNr_Wrong;
        
        numberPrime3sec = Output.Relative.Trial_3s(j).Prime_Nr;
        numberCorrTarget3sec = Output.Relative.Trial_3s(j).TargetNr_Correct;
        numberWronTarget3sec = Output.Relative.Trial_3s(j).TargetNr_Wrong;
        
        Output.Relative.Trial_Inf(j).Orientation_Prime = houseInformation.houseOrientation(houseInformation.houseNumber == numberPrimeInf);
        Output.Relative.Trial_Inf(j).Orientation_CorrectTarget = houseInformation.houseOrientation(houseInformation.houseNumber == numberCorrTargetInf);
        Output.Relative.Trial_Inf(j).Orientation_WrongTarget = houseInformation.houseOrientation(houseInformation.houseNumber == numberWronTargetInf);
        
        Output.Relative.Trial_3s(j).Orientation_Prime = houseInformation.houseOrientation(houseInformation.houseNumber == numberPrime3sec);
        Output.Relative.Trial_3s(j).Orientation_CorrectTarget = houseInformation.houseOrientation(houseInformation.houseNumber == numberCorrTarget3sec);
        Output.Relative.Trial_3s(j).Orientation_WrongTarget = houseInformation.houseOrientation(houseInformation.houseNumber == numberWronTarget3sec);
    end
    
    % calculate the angular difference for each trial of the relative
    % orientation task for the 3s and the infinite time condition
    for j = 1 : 36
        % the angular difference is taken as the orientation difference 
        % between correct and wrong target (an alternative would be the
        % difference between prime and wrong target)
        Output.Relative.Trial_Inf(j).Diff = abs(Output.Relative.Trial_Inf(j).Orientation_CorrectTarget - Output.Relative.Trial_Inf(j).Orientation_WrongTarget);
        Output.Relative.Trial_3s(j).Diff = abs(Output.Relative.Trial_3s(j).Orientation_CorrectTarget - Output.Relative.Trial_3s(j).Orientation_WrongTarget);
        
        % the differences are not exactly in steps of 30°, so round the 
        % differences to the nearest value of [30 60 90 120 150 180 210 240 270 300 330]
        if Output.Relative.Trial_Inf(j).Diff < 45
            Output.Relative.Trial_Inf(j).Difference = 30;
        elseif Output.Relative.Trial_Inf(j).Diff > 45 && Output.Relative.Trial_Inf(j).Diff < 75
            Output.Relative.Trial_Inf(j).Difference = 60;
        elseif Output.Relative.Trial_Inf(j).Diff > 75 && Output.Relative.Trial_Inf(j).Diff < 105
            Output.Relative.Trial_Inf(j).Difference = 90;
        elseif Output.Relative.Trial_Inf(j).Diff > 105 && Output.Relative.Trial_Inf(j).Diff < 135
            Output.Relative.Trial_Inf(j).Difference = 120;
        elseif Output.Relative.Trial_Inf(j).Diff > 135 && Output.Relative.Trial_Inf(j).Diff < 165
            Output.Relative.Trial_Inf(j).Difference = 150;
        elseif Output.Relative.Trial_Inf(j).Diff > 165 && Output.Relative.Trial_Inf(j).Diff < 195
            Output.Relative.Trial_Inf(j).Difference = 180;
        elseif Output.Relative.Trial_Inf(j).Diff > 195 && Output.Relative.Trial_Inf(j).Diff < 225
            Output.Relative.Trial_Inf(j).Difference = 210;
        elseif Output.Relative.Trial_Inf(j).Diff > 225 && Output.Relative.Trial_Inf(j).Diff < 255
            Output.Relative.Trial_Inf(j).Difference = 240;
        elseif Output.Relative.Trial_Inf(j).Diff > 255 && Output.Relative.Trial_Inf(j).Diff < 285
            Output.Relative.Trial_Inf(j).Difference = 270;
        elseif Output.Relative.Trial_Inf(j).Diff > 285 && Output.Relative.Trial_Inf(j).Diff < 315
            Output.Relative.Trial_Inf(j).Difference = 300;
        elseif Output.Relative.Trial_Inf(j).Diff > 315
            Output.Relative.Trial_Inf(j).Difference = 330;
        end
        
        if Output.Relative.Trial_3s(j).Diff < 45
            Output.Relative.Trial_3s(j).Difference = 30;
        elseif Output.Relative.Trial_3s(j).Diff > 45 && Output.Relative.Trial_3s(j).Diff < 75
            Output.Relative.Trial_3s(j).Difference = 60;
        elseif Output.Relative.Trial_3s(j).Diff > 75 && Output.Relative.Trial_3s(j).Diff < 105
            Output.Relative.Trial_3s(j).Difference = 90;
        elseif Output.Relative.Trial_3s(j).Diff > 105 && Output.Relative.Trial_3s(j).Diff < 135
            Output.Relative.Trial_3s(j).Difference = 120;
        elseif Output.Relative.Trial_3s(j).Diff > 135 && Output.Relative.Trial_3s(j).Diff < 165
            Output.Relative.Trial_3s(j).Difference = 150;
        elseif Output.Relative.Trial_3s(j).Diff > 165 && Output.Relative.Trial_3s(j).Diff < 195
            Output.Relative.Trial_3s(j).Difference = 180;
        elseif Output.Relative.Trial_3s(j).Diff > 195 && Output.Relative.Trial_3s(j).Diff < 225
            Output.Relative.Trial_3s(j).Difference = 210;
        elseif Output.Relative.Trial_3s(j).Diff > 225 && Output.Relative.Trial_3s(j).Diff < 255
            Output.Relative.Trial_3s(j).Difference = 240;
        elseif Output.Relative.Trial_3s(j).Diff > 255 && Output.Relative.Trial_3s(j).Diff < 285
            Output.Relative.Trial_3s(j).Difference = 270;
        elseif Output.Relative.Trial_3s(j).Diff > 285 && Output.Relative.Trial_3s(j).Diff < 315
            Output.Relative.Trial_3s(j).Difference = 300;
        elseif Output.Relative.Trial_3s(j).Diff > 315
            Output.Relative.Trial_3s(j).Difference = 330;
        end
        
        % check if the difference is bigger than 180° -> if yes, calculate 360° - difference
        if Output.Relative.Trial_Inf(j).Difference > 180
            Output.Relative.Trial_Inf(j).Difference = 360 - Output.Relative.Trial_Inf(j).Difference;
        end
        if Output.Relative.Trial_3s(j).Difference > 180
            Output.Relative.Trial_3s(j).Difference = 360 - Output.Relative.Trial_3s(j).Difference;
        end
        
    end
    
    
    
    % only for the absolute orientation and the pointing task
    
    % calculate the angular difference
    for j = 1 : 36
        Output.Absolute.Trial_Inf(j).Difference = abs(Output.Absolute.Trial_Inf(j).Correct_Angle - Output.Absolute.Trial_Inf(j).Wrong_Angle);
        Output.Absolute.Trial_3s(j).Difference = abs(Output.Absolute.Trial_3s(j).Correct_Angle - Output.Absolute.Trial_3s(j).Wrong_Angle);
        Output.Pointing.Trial_Inf(j).Difference = abs(Output.Pointing.Trial_Inf(j).PointingAngle_Correct - Output.Pointing.Trial_Inf(j).PointingAngle_Wrong);
        Output.Pointing.Trial_3s(j).Difference = abs(Output.Pointing.Trial_3s(j).PointingAngle_Correct - Output.Pointing.Trial_3s(j).PointingAngle_Wrong);
    end
    
    % check whether the difference is greater than 180° -> if yes, then 
    % 360° - difference
    for j = 1 : 36
        if Output.Absolute.Trial_Inf(j).Difference > 180
            Output.Absolute.Trial_Inf(j).Difference = 360 - Output.Absolute.Trial_Inf(j).Difference;
        end
        if Output.Absolute.Trial_3s(j).Difference > 180
            Output.Absolute.Trial_3s(j).Difference = 360 - Output.Absolute.Trial_3s(j).Difference;
        end
        if Output.Pointing.Trial_Inf(j).Difference > 180
            Output.Pointing.Trial_Inf(j).Difference = 360 - Output.Pointing.Trial_Inf(j).Difference;
        end
        if Output.Pointing.Trial_3s(j).Difference > 180
            Output.Pointing.Trial_3s(j).Difference = 360 - Output.Pointing.Trial_3s(j).Difference;
        end
    end
    
    
    
    % calculate the performance over all tasks for each of the angular differences
    
    iDiff30 = [];
    iDiff60 = [];
    iDiff90 = [];
    iDiff120 = [];
    iDiff150 = [];
    iDiff180 = [];
    
    task = '';
    time = '';
    
    % for each of the 6 combinations of task and time condition
    for j = 1 : 6
        if j == 1 || j == 2
            task = 'Absolute';
        elseif j == 3 || j == 4
            task = 'Pointing';
        else
            task = 'Relative';            
        end
        
        if mod(j,2) == 1
            time = 'Trial_3s';
        else
            time = 'Trial_Inf';
        end
        
        % go through all the trials in this specific condition and add 0 
        % (wrong answer) or 1 (right answer) into the list of the
        % respective angular difference
   
        for k = 1 : 36
            if Output.(task).(time)(k).Difference == 30
                iDiff30 = [iDiff30 strcmp(Output.(task).(time)(k).Correct, Output.(task).(time)(k).Decision)];
            elseif Output.(task).(time)(k).Difference == 60
                iDiff60 = [iDiff60 strcmp(Output.(task).(time)(k).Correct, Output.(task).(time)(k).Decision)];
            elseif Output.(task).(time)(k).Difference == 90
                iDiff90 = [iDiff90 strcmp(Output.(task).(time)(k).Correct, Output.(task).(time)(k).Decision)];
            elseif Output.(task).(time)(k).Difference == 120
                iDiff120 = [iDiff120 strcmp(Output.(task).(time)(k).Correct, Output.(task).(time)(k).Decision)];
            elseif Output.(task).(time)(k).Difference == 150
                iDiff150 = [iDiff150 strcmp(Output.(task).(time)(k).Correct, Output.(task).(time)(k).Decision)];
            elseif Output.(task).(time)(k).Difference == 180
                iDiff180 = [iDiff180 strcmp(Output.(task).(time)(k).Correct, Output.(task).(time)(k).Decision)];
            end
        end
    end
    
    % calculate the performance for this participant and add it to the cell 
    % with the performances of all participants
    
    PerDiff(i,1) = num2cell(100 * sum(iDiff30) / length(iDiff30));
    PerDiff(i,2) = num2cell(100 * sum(iDiff60) / length(iDiff60));
    PerDiff(i,3) = num2cell(100 * sum(iDiff90) / length(iDiff90));
    PerDiff(i,4) = num2cell(100 * sum(iDiff120) / length(iDiff120));
    PerDiff(i,5) = num2cell(100 * sum(iDiff150) / length(iDiff150));
    PerDiff(i,6) = num2cell(100 * sum(iDiff180) / length(iDiff180));
    
    % CHANGE: path to where you want to store the output
    % save the new output which has the angular differences included
    current_name = strcat('../Daten/Tasks/WithAngularDiffs_','VP_',num2str(e),'.mat');
    save(current_name,'Output');
    
end


% calculate the mean performance and the standard deviation over all 
% participants for each of the angular differences

tmp = cell2mat(PerDiff);

PerDiff30 = mean(tmp(1:end,1));
PerDiff60 = mean(tmp(1:end,2));
PerDiff90 = mean(tmp(1:end,3));
PerDiff120 = mean(tmp(1:end,4));
PerDiff150 = mean(tmp(1:end,5));
PerDiff180 = mean(tmp(1:end,6));

Std30 = std(tmp(1:end,1));
Std60 = std(tmp(1:end,2));
Std90 = std(tmp(1:end,3));
Std120 = std(tmp(1:end,4));
Std150 = std(tmp(1:end,5));
Std180 = std(tmp(1:end,6));

% CHANGE: to where you want to store the file
% csv-file which can be imported into SPSS to compute an ANOVA there
csvwrite('../Daten/Tasks/AngularDifference.csv', PerDiff);


%disp(PerDiff30);
%disp(PerDiff60);
%disp(PerDiff90);
%disp(PerDiff120);
%disp(PerDiff150);
%disp(PerDiff180);

%disp(Std30);
%disp(Std60);
%disp(Std90);
%disp(Std120);
%disp(Std150);
%disp(Std180);



%--------------------------------------------------------------------------
% plot performance against angular differences



% list with the angular differences where the performance values should be
% plotted
angPlotForPlotting = [];
% small values in random order which are later added to the angular
% differences
forScatter = linspace(-5,5,20);
forScatter_rand = forScatter(randperm(length(forScatter)));

% the angPlotForPlotting is filled with the values
% to each difference value a small jitter is added so that the performance
% values are slightly jittered and not plotted on top of each other
for i = 1:6
    for j = 1:Number
        angPlotForPlotting = [angPlotForPlotting (i*30 + forScatter_rand(21-j))];
    end
end


% list with RGB values of 20 different colors, one for each participant
% CHANGE: to more colors if you have more participants
colors = [[230 25 75] [60 180 75] [255 225 25] [0 130 200] [245 130 48] [145 30 180] [70 240 240] [240 50 230] [180 215 30] [200 140 140] [0 128 128] [190 150 215] [170 110 40] [255 69 0] [128 0 0] [100 185 125] [128 128 0] [215 175 130] [0 0 128] [128 128 128]];

x = [30 60 90 120 150 180];
counter = 1;

% plot the 6 performance values for each participant
for i = 1:Number
    % y values for plotting
    forPlotting = [];
    % x values for plotting (angular difference values with a slight
    % jitter)
    xx = [angPlotForPlotting(i) angPlotForPlotting(i+20) angPlotForPlotting(i+40) angPlotForPlotting(i+60) angPlotForPlotting(i+80) angPlotForPlotting(i+100)];
    % the y values are the 6 performance values of this participant
    for j = 1:6
        forPlotting = [forPlotting cell2mat(PerDiff(i,j))];
    end
    % get the color for this participant and convert RGB values to be
    % between 0 and 1
    c = [colors(counter)/255 colors(counter+1)/255 colors(counter+2)/255];
    scatter(xx, forPlotting,36,c,'*');
    counter = counter + 3;
    hold on;
    %disp(i);
end


% list with the mean performance of all participants for the 6 angular
% differences
means = [];

for i = 1:6
    summe = 0;
    for j = 1:Number
        summe = summe + cell2mat(PerDiff(j,i));
    end
    means = [means (summe/Number)];
end

% also plot the mean performance values
scatter(x,means,44,'blacko','filled');

% make the plot look nice
title('Performance in Dependence on Angular Difference');
xlabel('Angular Difference in Degrees');
ylabel('Performance in %');
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
ylim([20 80]);
xlim([20 190]);
xticks([30 60 90 120 150 180]);
hline = refline([0, 50]);
hline.Color = 'r';
hline.LineStyle = '--';



%--------------------------------------------------------------------------
% Analysis related to grid cells
% test whether performance for 30°, 90° and 150° differs significantly from
% performance for 60°, 120° and 180°


% calculate the actual observed test measure
TM = (PerDiff60 + PerDiff120 + PerDiff180)/3 - (PerDiff30 + PerDiff90 + PerDiff150)/3;
disp('Actual Test Measure:');
disp(TM);


% create a distribution of test measure in order to see whether the
% observed test measure (TM) is bigger than the critical value (so
% significantly different from what would be expected by chance)
TMValues = [];
rng(31415);

% generate 10,000 test measures
for i = 1:10000
    
    randomPerDiff = cell(20,6);
    
    % for each participant: randomize the 6 performance values within each
    % participant
    for j = 1:Number
        a = tmp(j,1:end);
        n = 6;
        idx = randperm(n);
        %disp(idx);
        for k = 1:6
            index = idx(k);
            randomPerDiff(j,k) = num2cell(a(index));
        end
    end
    
    % calculate the new mean performances for the 6 angular differences
    tmp2 = cell2mat(randomPerDiff);
    PerDiff30Random = mean(tmp2(1:end,1));
    PerDiff60Random = mean(tmp2(1:end,2));
    PerDiff90Random = mean(tmp2(1:end,3));
    PerDiff120Random = mean(tmp2(1:end,4));
    PerDiff150Random = mean(tmp2(1:end,5));
    PerDiff180Random = mean(tmp2(1:end,6));

    % calculate the newly generated test measure and save it in TMValues
    TMRandom = (PerDiff60Random + PerDiff120Random + PerDiff180Random)/3 - (PerDiff30Random + PerDiff90Random + PerDiff150Random)/3;
    %disp(TMRandom);
    TMValues = [TMValues TMRandom];
    
end

%disp(mean(TMValues));



%--------------------------------------------------------------------------
% plot the distribution of test measure values

figure;
h = histfit(TMValues, 50);

% make plot look nice
xlabel('Test Measure');
ylabel('Number of Occurrences');
title('Distribution of Test Measures');
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');

% get the parameters of the fitted distribution
TMValuesNew = TMValues';
pd = fitdist(TMValuesNew,'Normal');
disp(pd);


% plot the actual test value and the cut-offs for the critical values 
% (2.5% on each side of the distribution)
% to calculate 95% confidence interval for a normal distribution: P(xQuer -
% 1.96 * sigma <= mu <= xQuer + 1.96 * sigma) = 0.95
% CHANGE: the height of the vertical lines to fit your distribution
line([TM, TM], [0, 420], 'LineWidth', 2, 'Color', 'g');
% CHANGE: the values to the critical values from your distribution (you get
% the necessary parameters from pd = fitdist)
line([-3.1246, -3.1246], [0, 85], 'LineWidth', 2, 'Color', 'y');
line([3.0883, 3.0883], [0, 85], 'LineWidth', 2, 'Color', 'y');


