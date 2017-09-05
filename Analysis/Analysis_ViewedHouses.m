PartList={1,5,8,9,12,13,16};%list of subjects that you want to analyze
Number = length(PartList);
NumHouses = cell(3,Number);
total = 0;
totalper = 0;
totaltime=0;
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
    sumViews=0;
    for h=1:len-1
        sumViews = sumViews+x.NumViews.occ(h);%average time looked at houses in seconds
    end
    avgTime=(sumViews/(len-1))/10;
    totaltime=totaltime+avgTime;
    NumHouses{1,ii}=len;
    NumHouses{2,ii}=percentage;
    NumHouses{3,ii}=avgTime;
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
avg=total/Number;%how many houses were looked at on average
avgper = totalper/Number;%how much percent of the houses
avgTime = totaltime/Number;%how long on average were houses looked at
totalNum=sortrows(totalNum,2,'descend');%sort the table of houseViews in descending order (most often viewed houses on top)
ViewStats=cell2table(NumHouses);
ViewStats.Properties.RowNames={'NumHousesSeen' 'PercentHousesSeen' 'DurationLookedAtHouse'};
save('D:/v.kakerbeck/Tracking/ViewedHouses/totalNum.mat','totalNum');%list of houses looks at with overal duration, average distance etc
save('D:/v.kakerbeck/Tracking/ViewedHouses/ViewingStats.mat','ViewStats');%overall subject stats in a table (percentage, num houses looked at, avg duration)
clear ii; clear len; clear total; clear x; clear Number; clear totalper; clear percentage;clear ans;clear sumViews;clear h;clear totaltime;
clear e;clear found;