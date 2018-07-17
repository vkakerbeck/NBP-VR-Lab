%PartList={1,2,3,4,5,6,7,8,10,11}; %for Bachelors Thesis Data set
%PartList = {12,13,14,15,16,17,18,19,20,21,22,24,25,26}; %Subjects with new script
PartList ={1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,18,19,20,21,22,24,25,26,28,29,30}; %all Subjects
Number = length(PartList);
SubjectStats= cell(7,Number);
totalsight = 0;
totalnav=0;
Corsum = 0;
for ii = 1: Number
    e = cell2mat(PartList(ii));
    if e<10
        x = load(['Fam_Houses_VP_0' num2str(e) '.mat']);
    else
        x = load(['Fam_Houses_VP_' num2str(e) '.mat']);
    end
    F = [x.Output.Trial.DecisionSight];
    N = [x.Output.Trial.DecisionNav];
    SubjectStats{6,ii}=var(F);
    SubjectStats{7,ii}=var(N);
%     f = zscore(F);
%     n = zscore(N);
%     for m = 1:50
%         x.Output.Trial(m).DecisionSight=f(m);
%         x.Output.Trial(m).DecisionNav=n(m);
%     end
    %calculate average sight/nav rating
    sumsight=0;
    sumnav = 0;
    for i =1:50
        sumsight = sumsight+x.Output.Trial(i).DecisionSight;
        sumnav = sumnav+x.Output.Trial(i).DecisionNav;
    end
    avgsight=sumsight/50;
    avgnav=sumnav/50;
    totalsight = totalsight+avgsight;
    totalnav = totalnav+avgnav;
    SubjectStats{1,ii}=avgsight;
    SubjectStats{2,ii}=avgnav;
    %calculate Correlation Coeficient
    C = corrcoef(F,N);
    Corsum = Corsum + C(1,2);
end
sightavg= totalsight/Number;
navavg = totalnav/Number;
Corr = Corsum/Number;
clear avgsight;clear avgnav;clear i;clear ii;clear sumnav; clear sumsight;clear totalnav;clear totalsight;clear e;
%% analysis dependent on viewed houses
dname = 'C:\Users\vivia\Dropbox\Project Seahaven\TrackingOld\VP_Data\Viewed Houses';
totalsightCleaned = 0;
totalnavCleaned=0;
n=50;
CF = 0;CN = 0;CFD=0;CND=0;
totalsightStep = cell(1,n);totalsightStep(1,:)={0};
totalnavStep = cell(1,n);totalnavStep(1,:)={0};
avgDepOnNsight=cell(Number,n);
avgDepOnNnav=cell(Number,n);
for ii = 1: Number
    %open numViewed Table
    e = cell2mat(PartList(ii));
    if e<10
        x = load(['Fam_Houses_VP_0' num2str(e) '.mat']);
        fname=fullfile(dname,['NumViewsD_VP_0' num2str(e) '.mat']);
        v = load(fname);
    else
        x = load(['Fam_Houses_VP_' num2str(e) '.mat']);
        fname=fullfile(dname,['NumViewsD_VP_' num2str(e) '.mat']);
        v = load(fname);
    end
    v = v.NumViews;
    F = [x.Output.Trial.DecisionSight];
    N = [x.Output.Trial.DecisionNav];
    f = zscore(F);
    nav = zscore(N);
    for m = 1:50
        x.Output.Trial(m).DecisionSight=f(m);
        x.Output.Trial(m).DecisionNav=nav(m);
    end
    x = x.Output.Trial;
    %calculate avg for houses seen longer than 5 sec
    sumsight=0;
    sumnav = 0;
    num = 0;
    numV=zeros(1,50);
    distV = zeros(1,50);
    for i =1:50
        IndexC = strfind(v.Var1, x(i).Image_Name(1:3));
        index = find(not(cellfun('isempty', IndexC)));
        if isempty(index)
            numV(i)=0;
            distV(i)=0;
        else
            numV(i) = v.occ(index(1));
            distV(i) = v.Var4(index(1));
            if v.occ(index(1))>50%if the house has been looked at for at least 5 seconds
                sumsight = sumsight+x(i).DecisionSight;
                sumnav = sumnav+x(i).DecisionNav;
                num = num+1;
            end
        end
        %index = find(contains(v.Var1,x(i).Image_Name(1:3)));
    end
    corrF = corrcoef(numV,F);%correlation between num views and familiarity rating for each subject
    corrN = corrcoef(numV,N);%correlation between num views and navigation rating for each subject
    corrFDist = corrcoef(distV,F);%correlation between distance from which house was seen and familiarity rating for each subject
    corrNDist = corrcoef(distV,N);%correlation between distance from which house was seen and navigation rating for each subject
    CF = corrF(2)+CF;
    CN = corrN(2) + CN;
    CFD = corrFDist+CFD; CND=corrNDist+CND;
    avgsight=sumsight/num;
    avgnav=sumnav/num;
    SubjectStats{3,ii}=avgsight;%avgsight5sec
    SubjectStats{4,ii}=avgnav;%avgnav5sec
    SubjectStats{5,ii}=num;%#houses taken to calculate avg
    %calculate overall avgs
    totalsightCleaned = totalsightCleaned+avgsight;
    totalnavCleaned = totalnavCleaned+avgnav;
    sightavgCleaned= totalsightCleaned/Number;
    navavgCleaned = totalnavCleaned/Number;
    %calculate avg for each threshold
    for limit=1:n      
    sumsight=0;
    sumnav = 0;
    num = 0;
        for i =1:50
        IndexC = strfind(v.Var1, x(i).Image_Name(1:3));
        index = find(not(cellfun('isempty', IndexC)));
        %index = find(contains(v.Var1,x(i).Image_Name(1:3)));
            if v.occ(index)>=limit
                sumsight = sumsight+x(i).DecisionSight;
                sumnav = sumnav+x(i).DecisionNav;
                num = num+1;
            end
        end
        avgsight=sumsight/num;%average fam rating for one subject with one limit
        avgnav=sumnav/num;
        avgDepOnNsight{ii,limit}=avgsight;
        avgDepOnNnav{ii,limit}=avgnav;
        totalsightStep{1,limit} = totalsightStep{1,limit} + avgsight; %average fam rating for limit over all subjects
        totalnavStep{1,limit} = totalnavStep{1,limit} + avgnav;
    end
    
end
%avgDepOnNsight = horzcat(num2cell(zeros(26,1)),avgDepOnNsight);%add average over all houses (0 after z scoring)
%avgDepOnNnav = horzcat(num2cell(zeros(26,1)),avgDepOnNnav);
CN=CN/Number;CF=CF/Number;%average correlation between F and N rating and time house was looked at
CFD=CFD/Number;CND=CND/Number;%average correlation between F and N rating and distance from which house was looked at
A=cell2table(SubjectStats);
A.Properties.RowNames={'SightAvg' 'NavAvg' 'SightAvg5sZScored' 'NavAvg5szScored' 'NumSeenHouses' 'FamViarinace' 'NavVariance'};
clear ii;clear e; clear dname;clear fname;clear i;clear sumnav; clear sumsight; clear num; clear n; clear index; clear imname; 
clear totalnavCleaned; clear totalsightCleaned; clear avgnav; clear avgsight;
%% Bins
dname = 'C:\Users\Vivi\Dropbox\Project Seahaven\Tracking\VP_Data\Viewed Houses';
n=10;
avgDepOnNsight=cell(Number,n);
avgDepOnNnav=cell(Number,n);
totalnavBins = cell(3,n);totalnavBins(:,:)={0};
nan = cell(1,n);nan(:,:)={0};
FamBins = cell(n,Number);
totalfamBins = cell(3,n);totalfamBins(:,:)={0};
for ii = 1: Number
    %open numViewed Table
    e = cell2mat(PartList(ii));
    if e<10
        x = load(['Fam_Houses_VP_0' num2str(e) '.mat']);
        fname=fullfile(dname,['NumViewsD_VP_0' num2str(e) '.mat']);
        v = load(fname);
    else
        x = load(['Fam_Houses_VP_' num2str(e) '.mat']);
        fname=fullfile(dname,['NumViewsD_VP_' num2str(e) '.mat']);
        v = load(fname);
    end
    v = v.NumViews;
    x = x.Output.Trial;
    %calculate avg for each threshold
    for l=1:n      
    sumsight=0;
    sumnav = 0;
    num = 0;
        for i =1:50
        IndexC = strfind(v.Var1, x(i).Image_Name(1:3));
        index = find(not(cellfun('isempty', IndexC)));
        %index = find(contains(v.Var1,x(i).Image_Name(1:3)));
            if v.occ(index)<l*5 & v.occ(index)>(l-1)*5
                sumsight = sumsight+x(i).DecisionSight;
                sumnav = sumnav+x(i).DecisionNav;
                num = num+1;
            end
        end
        avgsight=sumsight/num;
        avgnav=sumnav/num;
        avgDepOnNsight{ii,l}=avgsight;
        avgDepOnNnav{ii,l}=avgnav;

        if ~isnan(avgnav)
        totalnavBins{1,l} = totalnavBins{1,l} + avgnav;
        totalnavBins{2,l} = totalnavBins{2,l} + 1;
       else
           nan{1,l} = nan{1,l}+1;
       end
       if ~isnan(avgsight)
        totalfamBins{1,l} = totalfamBins{1,l} + avgsight;
        totalfamBins{2,l} = totalfamBins{2,l} + 1;
       end
    end
end
for l = 1:n
   totalnavBins{3,l} = [totalnavBins{1,l}/totalnavBins{2,l}];
   totalfamBins{3,l} = [totalfamBins{1,l}/totalfamBins{2,l}];
end
A=cell2table(SubjectStats);
A.Properties.RowNames={'SightAvg' 'NavAvg' 'SightAvgCleaned' 'NavAvgCleaned' 'NumSeenHouses'};
clear ii;clear e; clear dname;clear fname;clear i;clear sumnav; clear sumsight; clear num; clear n; clear index; clear imname; 
clear totalnavCleaned; clear totalsightCleaned; clear avgnav; clear avgsight;

%% plot
figure;
S = cell2mat(avgDepOnNnav);S=S/Number;
N = cell2mat(avgDepOnNsight);N=N/Number;
for i=1:Number
    subplot(Number/2,2,i)%if error Number is uneven
    plot(linspace(1,51,51),S(i,:))
end
SA = cell2mat(totalsightStep);SA=SA/Number;
NA = cell2mat(totalnavStep);NA=NA/Number;
figure;
plot(linspace(1,50,50),SA);
hold;
plot(linspace(1,50,50),NA);
title('Correlation average ratings - duration of house viewed');
ylabel('average rating over all subjects for houses over the threshold')
xlabel('threshold for rating to be considered')
legend('familiarity rating','navigation rating');
figure;
subplot(1,2,1)
plot(linspace(1,51,51),S);
ylabel('average rating for each subject for houses over the threshold')
xlabel('threshold for rating to be considered')
title('Correlation familiarity rating - duration of house viewed');
subplot(1,2,2)
plot(linspace(1,51,51),N);
title('Correlation navigation rating - duration of house viewed');
xlabel('threshold for rating to be considered')
%% Familiarity Correlated with distance
limit = 15;
dname = 'C:\Users\Vivi\Dropbox\Project Seahaven\Tracking\VP_Data\Viewed Houses';
NavBins = cell(limit,Number);
totalnavBins = cell(3,limit);totalnavBins(:,:)={0};
nan = cell(1,limit);nan(:,:)={0};
FamBins = cell(limit,Number);
totalfamBins = cell(3,limit);totalfamBins(:,:)={0};
for ii = 1: Number
    e = cell2mat(PartList(ii));
    if e<10
        x = load(['Fam_Houses_VP_0' num2str(e) '.mat']);
        fname=fullfile(dname,['NumViewsD_VP_0' num2str(e) '.mat']);
        v = load(fname);
    else
        x = load(['Fam_Houses_VP_' num2str(e) '.mat']);
        fname=fullfile(dname,['NumViewsD_VP_' num2str(e) '.mat']);
        v = load(fname);
    end
    v = v.NumViews;
    x = x.Output.Trial;
    for l = 1:limit
       sumsight=0;
       sumnav = 0;
       num = 0;
       for i =1:50
            IndexC = strfind(v.Var1, x(i).Image_Name(1:3));
            index = find(not(cellfun('isempty', IndexC)));
            %index = find(contains(v.Var1,x(i).Image_Name(1:3)));
            if v.Var4(index)>l*10 & v.Var4(index)<(l+1)*10
                sumsight = sumsight+x(i).DecisionSight;
                sumnav = sumnav+x(i).DecisionNav;
                num = num+1;
            end
       end
       avgsight=sumsight/num;
       avgnav=sumnav/num;
       NavBins{l,ii}=avgnav;
       FamBins{l,ii}=avgsight;
       if ~isnan(avgnav)
        totalnavBins{1,l} = totalnavBins{1,l} + avgnav;
        totalnavBins{2,l} = totalnavBins{2,l} + 1;
       else
           nan{1,l} = nan{1,l}+1;
       end
       if ~isnan(avgsight)
        totalfamBins{1,l} = totalfamBins{1,l} + avgsight;
        totalfamBins{2,l} = totalfamBins{2,l} + 1;
       end
    end
end
for l = 1:limit
   totalnavBins{3,l} = [totalnavBins{1,l}/totalnavBins{2,l}];
   totalfamBins{3,l} = [totalfamBins{1,l}/totalfamBins{2,l}];
end
%----------------------plotting--------------------------------------------
%plot familiarity ratings. First plot: rating dependent on avg distance,
%second: how many people saw a house from that distance
s = [totalfamBins{3,:}];
ps = [totalfamBins{2,:}];
figure;
subplot(2,1,1);
hold on;
line([0 15],[sightavg sightavg]);
bar(s);
title('Average familiarity rating for houses seen from this distace');
xlabel('Distance/10')
ylabel('Average familiarity rating')
legend('Average familiarity rating overall');
subplot(2,1,2)
bar(ps);
title('Number of people who saw a house from this distance');
xlabel('Distance/10')
ylabel('Number of people')
%plot navigation ratings. First plot: rating dependent on avg distance,
%second: how many people saw a house from that distance
n = [ totalnavBins{3,:}];
pn = [ totalnavBins{2,:}];
figure;
subplot(2,1,1);
hold on;
line([0 15],[navavg navavg]);
bar(n);
title('Average navigation rating for houses seen from this distace');
xlabel('Distance/10')
ylabel('Average navigation rating')
legend('Average navigation rating overall');
subplot(2,1,2)
bar(pn);
title('Number of people who saw a house from this distance');
xlabel('Distance/10')
ylabel('Number of people')
clear avgnav;clear avgsight; clear dname;clear e; clear i; clear ii; clear fname; clear index; clear l;clear limit;clear n;clear num;
clear sumnav;clear sumsight;clear FamBins;clear NavBins;
%% Plotting Options
%plot rating - sight correlation in bins
s = [totalfamBins{3,:}];
ps = [totalfamBins{2,:}];
figure;
subplot(2,1,1);
hold on;
line([0 15],[sightavg sightavg]);
bar(s);
title('Average familiarity rating for houses seen for certain time');
xlabel('Amount of time looked at (in half second bins from 0 to 5 seconds)')
ylabel('Average familiarity rating')
legend('Average familiarity rating overall');
subplot(2,1,2)
bar(ps);
title('Number of people who saw a house for this amount of time');
xlabel('Amount of time looked at (in half second bins from 0 to 5 seconds)')
ylabel('Number of people')
%plot navigation ratings. First plot: rating dependent on avg distance,
%second: how many people saw a house from that distance
n = [ totalnavBins{3,:}];
pn = [ totalnavBins{2,:}];
figure;
subplot(2,1,1);
hold on;
line([0 15],[navavg navavg]);
bar(n);
title('Average navigation rating for houses seen for certain time');
xlabel('Amount of time looked at (in half second bins from 0 to 5 seconds)')
ylabel('Average navigation rating')
legend('Average navigation rating overall');
subplot(2,1,2)
bar(pn);
title('Number of people who saw a house for this amount of time');
xlabel('Amount of time looked at (in half second bins from 0 to 5 seconds)')
ylabel('Number of people')
