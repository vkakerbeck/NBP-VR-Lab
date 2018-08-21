%--Analyze how often participants did not respond in the 3s condition------


clear all;
clc;


% list of participants you want to analyze
% CHANGE: to the participants you want to analyze
PartList = {2907, 5324, 4302, 7561, 6348, 4060, 6503, 7535, 1944, 8457, 3854, 2637, 5579, 7018, 8580, 1961, 6844, 8804, 7350, 3116};
Number = length(PartList);


%--------------------------------------------------------------------------

% cell with how often each participant gave no answer in the 3s condition of
% each task
NoAns = cell(Number, 4); 

% for each participant
for i = 1:Number
    e = cell2mat(PartList(i));
    % CHANGE: to where you stored the data
    load(['../Daten/Tasks/AlignmentVR_SubjNo_',num2str(e),'.mat']);
    Abs = [];
    Rel = [];
    Poi = [];
    
    % for each trial
    for j = 1 : 36
        Abs = [Abs strcmp('None', Output.Absolute.Trial_3s(j).Decision)];
        Rel = [Rel strcmp('None', Output.Relative.Trial_3s(j).Decision)];
        Poi = [Poi strcmp('None', Output.Pointing.Trial_3s(j).Decision)];
    end
    
    disp(['Subject ', num2str(e), ':'])
    disp(['Im Absolute Task 3s so oft nicht geantwortet: ' num2str(sum(Abs))]);
    disp(['Im Relative Task 3s so oft nicht geantwortet: ' num2str(sum(Rel))]);
    disp(['Im Pointing Task 3s so oft nicht geantwortet: ' num2str(sum(Poi))]);
    NoAns(i, 1) = num2cell(e);
    NoAns(i, 2:end) = num2cell([sum(Abs); sum(Rel); sum(Poi)]);
end



% compute mean
tmp = cell2mat(NoAns);
AbsMean = mean(tmp(1:Number, 2));
RelMean = mean(tmp(1:Number, 3));
PoiMean = mean(tmp(1:Number, 4));
disp(AbsMean);
disp(RelMean);
disp(PoiMean);



% save
% CHANGE: to where you want to save this output
save('../Daten/Tasks/NoAnswer_MoreVP.mat', 'NoAns');
csvwrite('../Daten/Tasks/NoAnswer_MoreVP.csv', NoAns);



