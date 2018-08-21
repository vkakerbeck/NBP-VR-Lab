%--Analyzes some aspects of the FRS and the Seahaven questionnaire---------

clear all;
clc;

% CHANGE: to how many participants you want to analyze
Number = 20;

%--------------------------------------------------------------------------
% FRS Questionnaire


% CHANGE: to where you stored this file
M = csvread('../Daten/Fragebögen/FRS.csv');

% for each participant get his/her value for each of the three scales
orientation = [];
survey = [];
directions = [];

for i = 1:Number
    valueOrientation = (M(i+1,13) + M(i+1,15) + M(i+1,2) + M(i+1,9) + M(i+1,11) + M(i+1,5) + M(i+1,14) + M(i+1,6) + M(i+1,19) + M(i+1,16))/10;
    orientation = [orientation valueOrientation];
    valueSurvey = (M(i+1,8) + M(i+1,20) + M(i+1,3) + M(i+1,4) + M(i+1,12) + M(i+1,17) + M(i+1,10))/7;
    survey = [survey valueSurvey];
    valueDirections = (M(i+1,7) + M(i+1,18))/2;
    directions = [directions valueDirections];
end


% calculate mean and SEM
means = [mean(orientation) mean(survey) mean(directions)];
SEMs = [std(orientation)/sqrt(Number) std(survey)/sqrt(Number) std(directions)/sqrt(Number)];
disp(means);
disp(SEMs);
m = mean(means);
disp(m);



% plotting
chr = blanks(20);
bar(means, 'BarWidth', 0.7);
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
ylim([0 7]);
ylabel('Value on Likert Scale');
title('Results from the FRS Questionnaire');
xticklabels({strcat('Global-Egocentric \newline Orientation'), 'Survey', 'Cardinal \newline Directions'});
xtickangle(55);
hline = refline([0, m]);
hline.Color = 'r';
hline.LineStyle = '--';
hold on;
e = errorbar(1:3,means,SEMs, 'k');
e.LineStyle = 'none';




%--------------------------------------------------------------------------
% Seahaven Questionnaire


% get mean and SEM for these three questions
% CHANGE: to the answers from your participants
sunForOrientation = [1 3 3 2 2 1 3 1 3 2 1 1 2 2 1 2 2 3 1 1];
disp(mean(sunForOrientation));
disp(std(sunForOrientation)/Number);
sunForCardinalDirections = [1 5 2 2 2 1 3 1 4 2 1 1 2 2 1 3 2 4 1 2];
disp(mean(sunForCardinalDirections));
disp(std(sunForCardinalDirections)/Number);
noticeableHouses = [3 4 4 5 5 3 2 4 5 5 4 5 3 5 4 4 4 4 5 4];
disp(mean(noticeableHouses));
disp(std(noticeableHouses)/Number);



% analyze whether the participants who said that they can spontaneously
% point to North have a significantly smaller deviation from true North

% CHANGE: to the deviations of your participants
Deviations = [146.33 176.99 28.97 2.27 27.41 47.55 1.44 0.67 35.81 71.19 85.15 78.60 4.34 178.09 1.50 159.83 90.65 90.41 41.82 27.32];

% these are the participants who said that they can spontaneously point to
% North
% CHANGE: to your participants
yes = (Deviations(3) + Deviations(5) + Deviations(6) + Deviations(8) + Deviations(12) + Deviations(15))/6;
yesT = [Deviations(3) Deviations(5) Deviations(6) Deviations(8) Deviations(12) Deviations(15)];

% these are the participants who said that they cannot spontaneously point
% to North
% CHANGE: to your participants
values = [1 2 4 7 9 10 11 13 14 16 17 18 19 20];
summe = 0;
noT = [];

for i = 1:length(values)
    summe = summe + Deviations(values(i));
    noT = [noT Deviations(values(i))];
end
    
no = summe/14;


% t-test to check whether these two groups of participants differ
% significantly
[h,pValue,ci,stats] = ttest2(yesT,noT);
disp(pValue);
disp(stats);


