%-----------------------------DistanceEffect-------------------------------
% Does the performance in the pointing and the relative orientation task 
% decrease with increasing distance between the houses? (analyzed 
% separately for the pointing and the relative orientation task since the 
% distance measure is different (2 vs. 3 houses))

clear all;
clc;

% CHANGE: to the participants you want to analyze
%VR-PartList 
PartList = {1003,1119,1171,1181,1359,1809,1882,1909,1944,1961,2051,2151,2637,2653,2907,3093,3116,3251,3430,3668,3854,3961,3983,4060,4302,4376,4444,4502,5287,5311,5324,5579,5625,5699,5823,6348,6468,6503,6525,6844,7018,7350,7395,7535,7561,7666,7670,7953,8222,8457,8466,8517,8556,8580,8586,8665,8804,8864,9057,9327,9430,9434,9471};

%VRbelt-PartList
%PartList = {1081,1093,1162,1184,1299,1661,1784,1821,1896,2147,2228,2358,2450,2623,2654,2702,2705,2760,2950,2978,3034,3309,3826,4069,4305,4554,4772,5424,5514,5648,5746,5984,6212,6393,6406,6976,7037,7498,7545,8070,8220,8235,8437,8765,9145,9308,9378,9448,9559,9680,9994};

%Map-PartList
%PartList = {1217,1231,1385,1533,1838,1911,2007,2020,2592,2650,2830,3334,3497,3574,3599,4230,4608,4684,4875,4931,5046,5059,5171,5296,5891,6157,6298,6513,6812,6980,7405,7439,8169,8265,8343,8357,8368,8500,8610,8756,8863,8990,9069,9246,9309,9826,9849,9998};

%Kirstens List
%PartList = {2907, 5324, 4302, 7561, 6348, 4060, 6503, 7535, 1944, 8457, 3854, 2637, 5579, 7018, 8580, 1961, 6844, 8804, 7350, 3116};
Number = length(PartList);




%--------------------------------------------------------------------------
% get the data into the right format and get all the necessary information


% create cell with one row for each house with house number, x-coordinate
% and y-coordinate
% CHANGE: to folder where you saved this file
file = '/User/larasyrek/Desktop/Thesis/AllParticipantsResults/HouseList.txt';
data = fopen(file);
data = textscan(data,'%s','delimiter', {':',';','\n'});
len = 200;
houseCoordinates = cell(200,3);
counter = 1;
for j = 1:len
    houseCoordinates(j,1) = data{1}(counter);
    counter = counter + 1;
    houseCoordinates(j,2) = data{1}(counter);
    counter = counter + 1;
    houseCoordinates(j,3) = data{1}(counter);
    counter = counter + 1;
end

% until 92 index and house number match
% from line 93 onwards, housenumber is index+1
houseCoordinates = sortrows(houseCoordinates,1);

% cell for each trial in pointing and relative task
% there are 72 trials in each task (both time conditions taken together)
% and 20 participants who each gave an answer for every trial (-> save 0 if
% answer was false and 1 if answer was correct)
PointingTrials = cell(72,20);
RelativeTrials = cell(72,20);

% save distances of all the trials (in same order as trials are in the
% cells above)
PointingDistances = cell(72,1);
RelativeDistances = cell(72,1);
PointingAngularDiffs = cell(72,1);
RelativeAngularDiffs = cell(72,1);
PointingToSort1 = cell(36,3);
PointingToSort2 = cell(36,3);
RelativeToSort1 = cell(36,3);
RelativeToSort2 = cell(36,3);

% distance calculation needs to be done only once since the distances are
% the same for all participants and the trials can also be brought into the
% same order for all participants
ee = cell2mat(PartList(1));
% CHANGE: to folder where you stored output from the tasks
load(['/User/larasyrek/Desktop/Thesis/AllParticipantsResults/WithAngularDiffs_VP_' num2str(ee) '.mat']);

% for each trial in the relative orientation and pointing task in the 3s 
% and the infinite time condition
for i = 1:36
    
    % get coordinates of prime and target(s) (infinite time conditions)
    npPI = Output.Pointing.Trial_Inf(i).Prime_Nr;
    ntPI = Output.Pointing.Trial_Inf(i).Target_Nr;
    npRI = Output.Relative.Trial_Inf(i).Prime_Nr;
    ntcRI = Output.Relative.Trial_Inf(i).TargetNr_Correct;
    ntwRI = Output.Relative.Trial_Inf(i).TargetNr_Wrong;
    
    if npPI > 92
        npPI = npPI-1;
    end
    if ntPI > 92
        ntPI = ntPI-1;
    end
    if npRI > 92
        npRI = npRI-1;
    end
    if ntcRI > 92
        ntcRI = ntcRI-1;
    end
    if ntwRI > 92
        ntwRI = ntwRI-1;
    end
    
    pPIX = str2num(cell2mat(houseCoordinates(npPI,2)));
    pPIY = str2num(cell2mat(houseCoordinates(npPI,3)));
    tPIX = str2num(cell2mat(houseCoordinates(ntPI,2)));
    tPIY = str2num(cell2mat(houseCoordinates(ntPI,3)));
    pRIX = str2num(cell2mat(houseCoordinates(npRI,2)));
    pRIY = str2num(cell2mat(houseCoordinates(npRI,3)));
    tcRIX = str2num(cell2mat(houseCoordinates(ntcRI,2)));
    tcRIY = str2num(cell2mat(houseCoordinates(ntcRI,3)));
    twRIX = str2num(cell2mat(houseCoordinates(ntwRI,2)));
    twRIY = str2num(cell2mat(houseCoordinates(ntwRI,3)));
    
    % and the same for the 3s conditions
    npP3 = Output.Pointing.Trial_3s(i).Prime_Nr;
    ntP3 = Output.Pointing.Trial_3s(i).Target_Nr;
    npR3 = Output.Relative.Trial_3s(i).Prime_Nr;
    ntcR3 = Output.Relative.Trial_3s(i).TargetNr_Correct;
    ntwR3 = Output.Relative.Trial_3s(i).TargetNr_Wrong;
    
    if npP3 > 92
        npP3 = npP3-1;
    end
    if ntP3 > 92
        ntP3 = ntP3-1;
    end
    if npR3 > 92
        npR3 = npR3-1;
    end
    if ntcR3 > 92
        ntcR3 = ntcR3-1;
    end
    if ntwR3 > 92
        ntwR3 = ntwR3-1;
    end
    
    pP3X = str2num(cell2mat(houseCoordinates(npP3,2)));
    pP3Y = str2num(cell2mat(houseCoordinates(npP3,3)));
    tP3X = str2num(cell2mat(houseCoordinates(ntP3,2)));
    tP3Y = str2num(cell2mat(houseCoordinates(ntP3,3)));
    pR3X = str2num(cell2mat(houseCoordinates(npR3,2)));
    pR3Y = str2num(cell2mat(houseCoordinates(npR3,3)));
    tcR3X = str2num(cell2mat(houseCoordinates(ntcR3,2)));
    tcR3Y = str2num(cell2mat(houseCoordinates(ntcR3,3)));
    twR3X = str2num(cell2mat(houseCoordinates(ntwR3,2)));
    twR3Y = str2num(cell2mat(houseCoordinates(ntwR3,3)));
    
    
    % calculate the distance
    
    % pointing
    % distance between prime and target as the distance measure
    distPI = sqrt((pPIX-tPIX)*(pPIX-tPIX) + (pPIY-tPIY)*(pPIY-tPIY));
    distP3 = sqrt((pP3X-tP3X)*(pP3X-tP3X) + (pP3Y-tP3Y)*(pP3Y-tP3Y));
    
    % relative
    % distance between prime and correct target
    distRI1 = sqrt((pRIX-tcRIX)*(pRIX-tcRIX) + (pRIY-tcRIY)*(pRIY-tcRIY));
    distR31 = sqrt((pR3X-tcR3X)*(pR3X-tcR3X) + (pR3Y-tcR3Y)*(pR3Y-tcR3Y));
    % distance between prime and wrong target
    distRI2 = sqrt((pRIX-twRIX)*(pRIX-twRIX) + (pRIY-twRIY)*(pRIY-twRIY));
    distR32 = sqrt((pR3X-twR3X)*(pR3X-twR3X) + (pR3Y-twR3Y)*(pR3Y-twR3Y));
    % distance between correct and wrong target
    distRI3 = sqrt((tcRIX-twRIX)*(tcRIX-twRIX) + (tcRIY-twRIY)*(tcRIY-twRIY));
    distR33 = sqrt((tcR3X-twR3X)*(tcR3X-twR3X) + (tcR3Y-twR3Y)*(tcR3Y-twR3Y));
    % mean distance of prime - correct target and prime - wrong target as
    % the distance measure (could also be changed to something else)
    distRI = (distRI1 + distRI2)/2;
    distR3 = (distR31 + distR32)/2;
    
    % save the distances together with the house number of the correct
    % target in this trial, so that later on it and the output of the 
    % individual participants can be sorted in the same way
    PointingToSort1(i,1) = num2cell(Output.Pointing.Trial_3s(i).Target_Nr);
    PointingToSort1(i,2) = num2cell(distP3);
    PointingToSort2(i,1) = num2cell(Output.Pointing.Trial_Inf(i).Target_Nr);
    PointingToSort2(i,2) = num2cell(distPI);
    RelativeToSort1(i,1) = num2cell(Output.Relative.Trial_3s(i).TargetNr_Correct);
    RelativeToSort1(i,2) = num2cell(distR3);
    RelativeToSort2(i,1) = num2cell(Output.Relative.Trial_Inf(i).TargetNr_Correct);
    RelativeToSort2(i,2) = num2cell(distRI);
    
    % and also save the angular difference of each trial
    PointingToSort1(i,3) = num2cell(Output.Pointing.Trial_3s(i).Difference);
    PointingToSort2(i,3) = num2cell(Output.Pointing.Trial_Inf(i).Difference);
    RelativeToSort1(i,3) = num2cell(Output.Pointing.Trial_3s(i).Difference);
    RelativeToSort2(i,3) = num2cell(Output.Pointing.Trial_Inf(i).Difference);
    
end

% put the data together (sorted according to the house number of the
% correct target)
PointingToSort1 = sortrows(PointingToSort1,1);
PointingToSort2 = sortrows(PointingToSort2,1);
RelativeToSort1 = sortrows(RelativeToSort1,1);
RelativeToSort2 = sortrows(RelativeToSort2,1);
PointingDistances(1:36,1) = PointingToSort1(:,2);
PointingDistances(37:72,1) = PointingToSort2(:,2);
RelativeDistances(1:36,1) = RelativeToSort1(:,2);
RelativeDistances(37:72,1) = RelativeToSort2(:,2);
PointingAngularDiffs(1:36,1) = PointingToSort1(:,3);
PointingAngularDiffs(37:72,1) = PointingToSort2(:,3);
RelativeAngularDiffs(1:36,1) = RelativeToSort1(:,3);
RelativeAngularDiffs(37:72,1) = RelativeToSort2(:,3);



%--------------------------------------------------------------------------
% calculate the performance for each trial (distance) over all participants

% for each participant
for i = 1:Number
    e = cell2mat(PartList(i));
    load(['../Daten/Tasks/AlignmentVR_SubjNo_' num2str(e) '.mat']);
    
    cellPoi3s = table2cell(struct2table(Output.Pointing.Trial_3s));
    cellPoiInf = table2cell(struct2table(Output.Pointing.Trial_Inf));
    cellRel3s = table2cell(struct2table(Output.Relative.Trial_3s));
    cellRelInf = table2cell(struct2table(Output.Relative.Trial_Inf));
    
    % sort the cells so that the trials are in the same order for every
    % participant
    cellPoi3s = sortrows(cellPoi3s,2);
    cellPoiInf = sortrows(cellPoiInf,2);
    cellRel3s = sortrows(cellRel3s,2);
    cellRelInf = sortrows(cellRelInf,2);
    
    % for each trial in pointing and relative task 3sec
    for j = 1:36
        PointingTrials(j,i) = num2cell(strcmp(cellPoi3s(j,5), cellPoi3s(j,7)));
        RelativeTrials(j,i) = num2cell(strcmp(cellRel3s(j,4), cellRel3s(j,6)));
    end
    
    % and the same for inf time condition
    for j = 1:36
        PointingTrials(j+36,i) = num2cell(strcmp(cellPoiInf(j,5), cellPoiInf(j,7)));
        RelativeTrials(j+36,i) = num2cell(strcmp(cellRelInf(j,4), cellRelInf(j,6)));
    end
    
end


% calculate performance for each trial
PointingPerformances = cell(72,1);
RelativePerformances = cell(72,1);

for i = 1:72
   PointingPerformances(i,1) = num2cell(100*sum(cellfun(@double,PointingTrials(i,1:end)))/Number);
   RelativePerformances(i,1) = num2cell(100*sum(cellfun(@double,RelativeTrials(i,1:end)))/Number);
end



%--------------------------------------------------------------------------
% plotting (performance against distance, separately for the pointing and
% the relative orientation task)


% for the pointing task

% plot performances against distances
scatter(cell2mat(PointingDistances), cell2mat(PointingPerformances),'*');

% make plot look nice
xlabel('Distance in Unity units');
ylabel('Performance in %');
title('Distance Effect for the Pointing Task');
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
ylim([10 95]);
hline = refline([0, 50]);
hline.Color = 'r';
hline.LineStyle = '--';
hold on;

% plot linear regression line
p = polyfit(cell2mat(PointingDistances),cell2mat(PointingPerformances),1);
y1 = polyval(p,cell2mat(PointingDistances));
plot(cell2mat(PointingDistances),y1,'g');

% linear regression model
mdl = fitlm(cell2mat(PointingDistances),cell2mat(PointingPerformances));
disp(mdl);


% for the relative orientation task

% plot performances against distances
figure;
scatter(cell2mat(RelativeDistances), cell2mat(RelativePerformances),'*');

% make plot look nice
xlabel('Distance in Unity units');
ylabel('Performance in %');
title('Distance Effect for the Relative Orientation Task');
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
ylim([15 85]);
xlim([0 350]);
hline = refline([0, 50]);
hline.Color = 'r';
hline.LineStyle = '--';
hold on;

% plot linear regression line
p1 = polyfit(cell2mat(RelativeDistances),cell2mat(RelativePerformances),1);
y2 = polyval(p1,cell2mat(RelativeDistances));
plot(cell2mat(RelativeDistances),y2,'g');

% linear regression model
mdl2 = fitlm(cell2mat(RelativeDistances),cell2mat(RelativePerformances));
disp(mdl2);



%--------------------------------------------------------------------------
% plotting (distances against the angular differences, separately for the 
% pointing and the relative orientation task; to see whether the different
% distances are equally distributed across the angular differences)

% for the pointing task
figure;
scatter(cell2mat(PointingAngularDiffs), cell2mat(PointingDistances), '*');
ylabel('Distance in Unity units');
xlabel('Angular Difference in Degrees');
title({'Distribution of Distances across the Angular Differences', 'for the Pointing Task Trials'});
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
xlim([25 185]);
xticks([0 30 60 90 120 150 180]);

% for the relative orientation task
figure;
scatter(cell2mat(RelativeAngularDiffs), cell2mat(RelativeDistances), '*');
ylabel('Distance in Unity units');
xlabel('Angular Difference in Degrees');
title({'Distribution of Distances across the Angular Differences', 'for the Relative Orientation Task Trials'});
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
xlim([25 185]);
xticks([0 30 60 90 120 150 180]);
ylim([0 350]);

