% check how often pupils were detected with a reliability below 0.5
% this is the case when NH and distance 0 is saved in ViewedHouses

clear all;
clc;

% list of participants
% CHANGE: to the participants you want to analyze
PartList = {2907, 5324, 4302, 7561, 6348, 4060, 6503, 7535, 1944, 8457, 3854, 2637, 5579, 7018, 8580, 1961, 6844, 8804, 7350, 3116}; % all Subjects
Number = length(PartList);



%--------------------------------------------------------------------------

% for every participant save for how many timestamps the reliability was 
% below 0.5
Percentages = [];
% how many minutes of the training session does this represent
Minutes = [];

% for every participant
for i = 1:Number
    
    % read in the data
    suj_num = cell2mat(PartList(i));
    % CHANGE: to where you stored this data
    file = strcat('../Daten/Eyetracking/ViewedHouses/ViewedHouses_VP',num2str(suj_num),'.txt');
    data = fopen(file);
    data = textscan(data,'%s','delimiter', '\n');
    data = data{1};
    data = table2array(cell2table(data));
    len = int32(length(data));
    ViewedHouses = cell(3,len);
    for a = 1:double(len)
        line = textscan(data{a},'%s','delimiter', ',');
        line = line{1};
        test = cellstr(line{1});
        ViewedHouses(1,a) = cellstr(line{1});
        ViewedHouses(2,a) = line(2);
        ViewedHouses(3,a) = line(3);
    end
    
    % count how often NH and 0 occurs
    Count = [];
    for j = 1:double(len)
        if (strcmp(cell2mat(ViewedHouses(1,j)), 'NH') == 1) && (strcmp(cell2mat(ViewedHouses(2,j)), '0') == 1)
            %disp(j);
            Count = [Count 1];
        end
    end
    
    percent = sum(Count)/double(len)*100;
    Percentages = [Percentages percent];
    time = sum(Count)/30/60;
    Minutes = [Minutes time];
end



%--------------------------------------------------------------------------
% calculate how much time participants spent looking at houses not taking
% into account the time where the pupils were detected with a reliability
% below 0.5

% CHANGE: to the time your participants spent looking at houses (which you
% can get with Viviane's script "Analysis_ViewedHouses.m")
LookingTimeHouses = [20.13 21.32 18.46 18.98 11.85 15.79 17.17 15.68 17.23 16.53 15.73 19.32 13.16 12.93 18.68 14.91 18.78 13.47 17.91 16.59];

PercentageHouses = [];

for i = 1:Number
    PercentageHouses = [PercentageHouses 30-Minutes(i)];
end
    
for i = 1:Number
    PercentageHouses(i) = LookingTimeHouses(i) / PercentageHouses(i) * 100;
end
    
    

