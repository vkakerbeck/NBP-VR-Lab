PartList={27,30,31};%list of subjects that you want to analyze
Number = length(PartList);
NumHouses = cell(2,Number);
total = 0;
totalper = 0;
for ii = 1: Number
    e = cell2mat(PartList(ii));
    if e<10
        x = load(['NumViewsD_VP_0' num2str(e) '.mat']);
    else
        x = load(['NumViewsD_VP_' num2str(e) '.mat']);
    end
    len = (size(x.NumViews,1));
    total=total+len;
    percentage = len/214;
    totalper = totalper+percentage;
    NumHouses{1,ii}=len;
    NumHouses{2,ii}=percentage;
    NumHouses{3,ii}=mean(x.NumViews.occ);%Average seconds looked at one house
    NumHouses{4,ii}=sum(x.NumViews.occ)/60;%minutes looked at houses
    a=array2table(ones(len,1));
    if ii==1
        totalNum=[x.NumViews ];
        a.Properties.VariableNames{'Var1'} = 'numVP';
        totalNum=[totalNum a];
    else
        for h=1:len
            found=false;
            for e=1:size(totalNum)
                if strcmp((x.NumViews.House(h)),totalNum.House(e))
                    totalNum.occ(e)=totalNum.occ(e)+x.NumViews.occ(h);
                    totalNum.numVP(e) = totalNum.numVP(e)+1;
                    found = true;
                end
            end
            if found==false
                totalNum=[totalNum;{x.NumViews.House(h) x.NumViews.occ(h) x.NumViews.DistanceMean(h) x.NumViews.DistanceVariance(h) 1}];
            end
        end
    end
end
avgocc = ones(height(totalNum),1);
for n = 1:height(totalNum)
    avgocc(n) = totalNum.occ(n)/totalNum.numVP(n);
end
totalNum = [totalNum array2table(avgocc)];
    
avg=total/Number;%how many houses were looked at on average
avgper = totalper/Number;%how much percent of the houses
avgTime = mean(avgocc);%how long on average were houses looked at
avgTotalTime = sum(avgocc)/60;%average overall time looked at houses in minutes
totalNum=sortrows(totalNum,2,'descend');%sort the table of houseViews in descending order (most often viewed houses on top)
ViewStats=cell2table(NumHouses);
ViewStats.Properties.RowNames={'NumHousesSeen' 'PercentHousesSeen' 'AverageTimeLookedAtOneHouse (s)' 'TimeLookedAtHouses (min)'};
save('C:/Users/Vivi/Dropbox/Project Seahaven/Tracking/ViewedHouses/totalNum.mat','totalNum');%list of houses looks at with overal duration, average distance etc
save('C:/Users/Vivi/Dropbox/Project Seahaven/Tracking/ViewedHouses/ViewingStats.mat','ViewStats');%overall subject stats in a table (percentage, num houses looked at, avg duration)
clear ii; clear len; clear total; clear x; clear Number; clear totalper; clear percentage;clear ans;clear sumViews;clear h;clear totaltime;
clear e;clear found;clear n;