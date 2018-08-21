%-----------------------------Familiarity----------------------------------
% Does performance increase with increasing familiarity?

clear all;
clc;

% CHANGE: to the participants you want to analyze
PartList = {2907, 5324, 4302, 7561, 6348, 4060, 6503, 7535, 1944, 8457, 3854, 2637, 5579, 7018, 8580, 1961, 6844, 8804, 7350, 3116};
Number = length(PartList);



%--------------------------------------------------------------------------
% two different analyses related to familiarity

% analysis number 1:
% all familiarity values are grouped into 10 bins
% calculate the performance for each familiarity bin to see whether
% performance increases with increasing bin number and thus increasing 
% familiarity

% analysis number 2:
% calculate the average familiarity for every participant for all the
% trials he/she answered correctly and those answered incorrectly to see
% whether familiarity for the correctly answered trials is significantly
% higher than for the incorrectly answered trials

% all the familiarities of all trials and all participants
Familiarities = [];

% performances for the 20 participants in the 10 familiarity bins
Performances = cell(20,10);

% how many trials are in total in each bin
Bin1Len = 0;
Bin2Len = 0;
Bin3Len = 0;
Bin4Len = 0;
Bin5Len = 0;
Bin6Len = 0;
Bin7Len = 0;
Bin8Len = 0;
Bin9Len = 0;
Bin10Len = 0;

% how familiar where participants with the trials they answered correctly
% compared to those they answered incorrectly
CorrectFam = [];
IncorrectFam = [];


% for every participant
for i = 1:Number
    e = cell2mat(PartList(i));
    % CHANGE: to folder where you stored the data
    load(['../Daten/Tasks/AlignmentVR_SubjNo_',num2str(e),'.mat']);
    load(['../Daten/Eyetracking/ViewedHouses/NumViewsD_VP_',num2str(e),'.mat']);
    NumViews = table2cell(NumViews);
    
    % convert house numbers in NumViews to same format as they are in the
    % Output
    for j = 1:length(NumViews)-1
       house = cell2mat(NumViews(j,1));
       % need to differentiate between house 073_1, _2 and _3 since only
       % one of them was shown in the tasks
       if contains(house, '073') == 1
           house = str2num(strcat(house(1:3), house(7)));
       else
           house = str2num(house(1:3));
       end
       NumViews(j,1) = num2cell(house);
    end
    
    Bin1 = [];
    Bin2 = [];
    Bin3 = [];
    Bin4 = [];
    Bin5 = [];
    Bin6 = [];
    Bin7 = [];
    Bin8 = [];
    Bin9 = [];
    Bin10 = [];
    FamC = [];
    FamIC = [];
    
    % for every trial in each of the 6 combinations of task and time
    % condition
    for j = 1:36
        % get the house numbers of this trial
        nhAI = Output.Absolute.Trial_Inf(j).House_Nr;
        nhA3 = Output.Absolute.Trial_3s(j).House_Nr;
        npRI = Output.Relative.Trial_Inf(j).Prime_Nr;
        npR3 = Output.Relative.Trial_3s(j).Prime_Nr;
        ntcRI = Output.Relative.Trial_Inf(j).TargetNr_Correct;
        ntcR3 = Output.Relative.Trial_3s(j).TargetNr_Correct;
        % house 73 is listed 3 times in NumViews but it's the third one
        % that was shown
        if ntcR3 == 73
            ntcR3 = 733;
        end
        ntwRI = Output.Relative.Trial_Inf(j).TargetNr_Wrong;
        ntwR3 = Output.Relative.Trial_3s(j).TargetNr_Wrong;
        npPI = Output.Pointing.Trial_Inf(j).Prime_Nr;
        npP3 = Output.Pointing.Trial_3s(j).Prime_Nr;
        ntPI = Output.Pointing.Trial_Inf(j).Target_Nr;
        ntP3 = Output.Pointing.Trial_3s(j).Target_Nr;
        
        % find the indices of these houses in NumViews
        Houses = cell2mat(NumViews(1:end-1,1));
        ihAI = find(Houses==nhAI);
        ihA3 = find(Houses==nhA3);
        ipRI = find(Houses==npRI);
        ipR3 = find(Houses==npR3);
        itcRI = find(Houses==ntcRI);
        itcR3 = find(Houses==ntcR3);
        itwRI = find(Houses==ntwRI);
        itwR3 = find(Houses==ntwR3);
        ipPI = find(Houses==npPI);
        ipP3 = find(Houses==npP3);
        itPI = find(Houses==ntPI);
        itP3 = find(Houses==ntP3);
        
        % add the viewing time of the houses to the Output as well as the
        % familiarity for this trial
        
        % for the absolute orientation task (familiarity is the viewing
        % time of the one house)
        if length(ihAI) == 0
            Output.Absolute.Trial_Inf(j).HouseViewing = 0;
        else
            Output.Absolute.Trial_Inf(j).HouseViewing = cell2mat(NumViews(ihAI,2));
        end
        
        if length(ihA3) == 0
            Output.Absolute.Trial_3s(j).HouseViewing = 0;
        else
            Output.Absolute.Trial_3s(j).HouseViewing = cell2mat(NumViews(ihA3,2));
        end
        
        Output.Absolute.Trial_Inf(j).Familiarity = Output.Absolute.Trial_Inf(j).HouseViewing;
        Output.Absolute.Trial_3s(j).Familiarity = Output.Absolute.Trial_3s(j).HouseViewing;
        
        
        % for the relative orientation task (familiarity is the mean 
        % viewing time of the 3 houses; could also be changed to the 
        % minimum or something else)
        if length(ipRI) == 0
            Output.Relative.Trial_Inf(j).PrimeViewing = 0;
        else
            Output.Relative.Trial_Inf(j).PrimeViewing = cell2mat(NumViews(ipRI,2));
        end
        
        if length(ipR3) == 0
            Output.Relative.Trial_3s(j).PrimeViewing = 0;
        else
            Output.Relative.Trial_3s(j).PrimeViewing = cell2mat(NumViews(ipR3,2));
        end
        
        if length(itcRI) == 0
            Output.Relative.Trial_Inf(j).TargetCorrectViewing = 0;
        else
            Output.Relative.Trial_Inf(j).TargetCorrectViewing = cell2mat(NumViews(itcRI,2));
        end
        
        if length(itcR3) == 0
            Output.Relative.Trial_3s(j).TargetCorrectViewing = 0;
        else
            Output.Relative.Trial_3s(j).TargetCorrectViewing = cell2mat(NumViews(itcR3,2));
        end
        
        if length(itwRI) == 0
            Output.Relative.Trial_Inf(j).TargetWrongViewing = 0;
        else
            Output.Relative.Trial_Inf(j).TargetWrongViewing = cell2mat(NumViews(itwRI,2));
        end
        
        if length(itwR3) == 0
            Output.Relative.Trial_3s(j).TargetWrongViewing = 0;
        else
            Output.Relative.Trial_3s(j).TargetWrongViewing = cell2mat(NumViews(itwR3,2));
        end

        Output.Relative.Trial_Inf(j).Familiarity = (Output.Relative.Trial_Inf(j).PrimeViewing + Output.Relative.Trial_Inf(j).TargetCorrectViewing + Output.Relative.Trial_Inf(j).TargetWrongViewing)/3;
        Output.Relative.Trial_3s(j).Familiarity = (Output.Relative.Trial_3s(j).PrimeViewing + Output.Relative.Trial_3s(j).TargetCorrectViewing + Output.Relative.Trial_3s(j).TargetWrongViewing)/3;
        
        
        % for the pointing task (familiarity is the mean viewing time of 
        % the 2 houses; could also be changed to something else)
        if length(ipPI) == 0
            Output.Pointing.Trial_Inf(j).PrimeViewing = 0;
        else
            Output.Pointing.Trial_Inf(j).PrimeViewing = cell2mat(NumViews(ipPI,2));
        end
        
        if length(ipP3) == 0
            Output.Pointing.Trial_3s(j).PrimeViewing = 0;
        else
            Output.Pointing.Trial_3s(j).PrimeViewing = cell2mat(NumViews(ipP3,2));
        end
        
        if length(itPI) == 0
            Output.Pointing.Trial_Inf(j).TargetViewing = 0;
        else
            Output.Pointing.Trial_Inf(j).TargetViewing = cell2mat(NumViews(itPI,2));
        end
        
        if length(itP3) == 0
            Output.Pointing.Trial_3s(j).TargetViewing = 0;
        else
            Output.Pointing.Trial_3s(j).TargetViewing = cell2mat(NumViews(itP3,2));
        end
        
        Output.Pointing.Trial_Inf(j).Familiarity = (Output.Pointing.Trial_Inf(j).PrimeViewing + Output.Pointing.Trial_Inf(j).TargetViewing)/2;
        Output.Pointing.Trial_3s(j).Familiarity = (Output.Pointing.Trial_3s(j).PrimeViewing + Output.Pointing.Trial_3s(j).TargetViewing)/2;
        
        
        % add the familiarity of this trial to the list of the familiarity
        % of all trials
        Familiarities = [Familiarities Output.Absolute.Trial_Inf(j).Familiarity Output.Absolute.Trial_3s(j).Familiarity Output.Relative.Trial_Inf(j).Familiarity Output.Relative.Trial_3s(j).Familiarity Output.Pointing.Trial_Inf(j).Familiarity Output.Pointing.Trial_3s(j).Familiarity];
        
        % add 0 or 1 in the list of the right familiarity bin (0 if the 
        % answer was false, 1 if answer was correct) (and do this for all 
        % of the 6 combinations of task and time condition)
        % also add the familiarity of the trial to the familiarities of the
        % correctly or respectively the incorrectly answered trials
        task = '';
        time = '';
    
        % for each of the 6 combinations
        for k = 1 : 6
            if k == 1 || k == 2
                task = 'Absolute';
            elseif k == 3 || k == 4
                task = 'Pointing';
            else
                task = 'Relative';            
            end
        
            if mod(k,2) == 1
                time = 'Trial_3s';
            else
                time = 'Trial_Inf';
            end
            
            value = strcmp(Output.(task).(time)(j).Correct, Output.(task).(time)(j).Decision);
            fam = Output.(task).(time)(j).Familiarity;
            
            % add the familiarity value of this trial into the
            % corresponding list
            if value == 0
                FamIC = [FamIC fam];
            else
                FamC = [FamC fam];
            end
            
            % add value to the right bin (depending on the familiarity fam)
            % CHANGE: the bin boundaries according to your data (see at the
            % very end for how to determine the bin boundaries)
            if fam < 0.3777
                Bin1 = [Bin1 value];
            elseif fam >= 0.3777 && fam < 1.3333
                Bin2 = [Bin2 value];
            elseif fam >= 1.3333 && fam < 2.3889
                Bin3 = [Bin3 value];
            elseif fam >= 2.3889 && fam < 3.4555
                Bin4 = [Bin4 value];
            elseif fam >= 3.4555 && fam < 4.5668
                Bin5 = [Bin5 value];
            elseif fam >= 4.5668 && fam < 5.7556
                Bin6 = [Bin6 value];
            elseif fam >= 5.7556 && fam < 7.2000
                Bin7 = [Bin7 value];
            elseif fam >= 7.2000 && fam < 9.2500
                Bin8 = [Bin8 value];
            elseif fam >= 9.2500 && fam < 12.9167
                Bin9 = [Bin9 value];
            else
                Bin10 = [Bin10 value];
            end 
        end
    end
    
   
    % show how many trials of this participant fall into each of the 10
    % familiarity bins
    len = [length(Bin1) length(Bin2) length(Bin3) length(Bin4) length(Bin5) length(Bin6) length(Bin7) length(Bin8) length(Bin9) length(Bin10)];
    disp(len);
    
    % calculate the performance for this participant and add it to the cell
    % array
    Performances(i, 1) = num2cell(100*sum(Bin1)/length(Bin1));
    Performances(i, 2) = num2cell(100*sum(Bin2)/length(Bin2));
    Performances(i, 3) = num2cell(100*sum(Bin3)/length(Bin3));
    Performances(i, 4) = num2cell(100*sum(Bin4)/length(Bin4));
    Performances(i, 5) = num2cell(100*sum(Bin5)/length(Bin5));
    Performances(i, 6) = num2cell(100*sum(Bin6)/length(Bin6));
    Performances(i, 7) = num2cell(100*sum(Bin7)/length(Bin7));
    Performances(i, 8) = num2cell(100*sum(Bin8)/length(Bin8));
    Performances(i, 9) = num2cell(100*sum(Bin9)/length(Bin9));
    Performances(i, 10) = num2cell(100*sum(Bin10)/length(Bin10));
    
    % add the trials of this participant in every bin to the total bin
    % length
    Bin1Len = Bin1Len + length(Bin1);
    Bin2Len = Bin2Len + length(Bin2);
    Bin3Len = Bin3Len + length(Bin3);
    Bin4Len = Bin4Len + length(Bin4);
    Bin5Len = Bin5Len + length(Bin5);
    Bin6Len = Bin6Len + length(Bin6);
    Bin7Len = Bin7Len + length(Bin7);
    Bin8Len = Bin8Len + length(Bin8);
    Bin9Len = Bin9Len + length(Bin9);
    Bin10Len = Bin10Len + length(Bin10);
    
    % calculate the mean familiarity for the correctly and incorrectly
    % answered trials for this participant and add it to the list with the
    % values from all participants
    CorrectFam = [CorrectFam sum(FamC)/length(FamC)];
    IncorrectFam = [IncorrectFam sum(FamIC)/length(FamIC)];
    
end

% save the performances of all participants in the 10 familiarity bins
% can be imported into SPSS to perform an ANOVA (for analysis number 1)
% CHANGE: to folder where you want to save this file
csvwrite('../Daten/Tasks/Familiarity.csv', Performances);

% calculate the mean performance for each bin
PBin1 = 100*sum(Bin1)/length(Bin1);
PBin2 = 100*sum(Bin2)/length(Bin2);
PBin3 = 100*sum(Bin3)/length(Bin3);
PBin4 = 100*sum(Bin4)/length(Bin4);
PBin5 = 100*sum(Bin5)/length(Bin5);
PBin6 = 100*sum(Bin6)/length(Bin6);
PBin7 = 100*sum(Bin7)/length(Bin7);
PBin8 = 100*sum(Bin8)/length(Bin8);
PBin9 = 100*sum(Bin9)/length(Bin9);
PBin10 = 100*sum(Bin10)/length(Bin10);


%--------------------------------------------------------------------------
% plotting (for analysis number 1)


% RGB values of 20 different color, one for each participant
% CHANGE: to more colors if you have more participants
colors = [[230 25 75] [60 180 75] [255 225 25] [0 130 200] [245 130 48] [145 30 180] [70 240 240] [240 50 230] [180 215 30] [200 140 140] [0 128 128] [190 150 215] [170 110 40] [255 69 0] [128 0 0] [100 185 125] [128 128 0] [215 175 130] [0 0 128] [128 128 128]];

forScatter = linspace(-0.1,0.1,20);
forScatter_rand = forScatter(randperm(length(forScatter)));
x = 1:1:10;
counter = 1;

% plot the performance of every participant
for i = 1:Number
    forPlotting = [];
    % in each of the 10 familiarity bins
    for j = 1:10
        forPlotting = [forPlotting cell2mat(Performances(i,j))];
    end
    c = [colors(counter)/255 colors(counter+1)/255 colors(counter+2)/255];
    scatter(x+forScatter_rand(i), forPlotting,36,c,'*');
    counter = counter + 3;
    hold on;
end


% calculate and plot the mean performance value for each of the 10
% familiarity bins
means = [];

for i = 1:10
    summe = 0;
    for j = 1:Number
        summe = summe + cell2mat(Performances(j,i));
    end
    means = [means (summe/Number)];
end

scatter(x,means,44,'blacko','filled');

% make plot look nice
xlabel('Familiarity Bin');
ylabel('Performance in %');
title('Performance in Dependence on Familiarity');
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
ylim([0 90]);
xlim([0 11]);
xticks([1 2 3 4 5 6 7 8 9 10]);
hline = refline([0, 50]);
hline.Color = 'r';
hline.LineStyle = '--';




%--------------------------------------------------------------------------
% analysis number 2 (test whether familiarity for the correctly answered
% trials is significantly higher than for the incorrectly answered trials)
% and plotting for analysis number 2


% calculate the standard error of the mean (SEM)
SEMCorr = std(CorrectFam)/sqrt(Number);
SEMIncorr = std(IncorrectFam)/sqrt(Number);

% t-test
[h,pValue,ci,stats] = ttest(CorrectFam,IncorrectFam);
disp(pValue);
disp(stats);


% plotting

figure;
xx = [1 1.5];
counter2 = 1;

% plot the familiarity of each participant
for i = 1:Number
    cc = [colors(counter2)/255 colors(counter2+1)/255 colors(counter2+2)/255];
    scatter(xx+forScatter_rand(i), [CorrectFam(i) IncorrectFam(i)],36, cc,'*');
    counter2 = counter2 + 3;
    hold on;
end

% also plot the mean familiarities
scatter(xx, [mean(CorrectFam) mean(IncorrectFam)],44, 'blacko', 'filled');

% make plot look nice
set(gca,'fontsize', 17);
set(gca, 'FontName', 'Times New Roman');
ylim([3 11]);
ylabel('Familiarity in Seconds');
xlim([0.75 1.75]);
xticks([1 1.5]);
xticklabels({'Correct Trials' 'Incorrect Trials'});
title('Familiarity for the Correctly and Incorrectly Answered Trials');



%--------------------------------------------------------------------------
% determine 10 bins with a roughly equal number of trials in each bin

% possibility 1: look into the variable f and check when it reaches 0.1,
% 0.2 etc. for the first quantile, second quantile and so on -> then look
% into the variable x and the corresponding value is the right boundary of
% the respective bin
[f,x] = ecdf(Familiarities);
figure;
plot(x,f);

% possibility 2: use the values in edges; however this way resulted in a
% less equal distribution of trials per bin; so bin boundaries might need
% to be changed by hand to have the trials distributed as equally as
% possible into the 10 bins
nbin = 10;
% to get the edges of the bins
edges = quantile(Familiarities,nbin-1);
% CHANGE: 79 to whatever is the highest familiarity for a single trial in
% your data
edges = [0 edges 79];
%disp(edges);
figure;
histogram(Familiarities,edges); 
[N,edges] = histcounts(Familiarities,edges);
%disp(N);


