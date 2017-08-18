%PartList={1,2,3,4,5,6,7,8,10,11}; %for Bachelors Thesis Data set
%PartList = {12,13,14,15,16,18,19,20,21,22,24,25,26,28,29}; %Subjects with new script (without 17 bc wrong eye tracker connected
%PartList ={1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,18,19,20,21,22,24,25,26,28,29}; %all Subjects
Number = length(PartList);
NumHouses = cell(3,Number);
total = 0;
totalper = 0;
totaltime=0;
for ii = 1: Number
    e = cell2mat(PartList(ii));
    if e<10
        x = load(['NumViews_VP_0' num2str(e) '.mat']);
    else
        x = load(['NumViews_VP_' num2str(e) '.mat']);
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
    if ii==1
        totalNum=x.NumViews;
    else
        for h=1:len
            found=false;
            for e=1:size(totalNum)
                if strcmp((x.NumViews.Var1(h)),totalNum.Var1(e))
                    totalNum.occ(e)=totalNum.occ(e)+x.NumViews.occ(h);
                    found = true;
                end
            end
            if found==false
                totalNum=[totalNum;{x.NumViews.Var1(h) x.NumViews.occ(h)}];
            end
        end
    end
end
avg=total/Number;%how many houses were looked at on average
avgper = totalper/Number;%how much percent of the houses
avgTime = totaltime/Number;%how long on average were houses looked at
totalNum=sortrows(totalNum,2,'descend');%sort the table of houseViews in descending order (most often viewed houses on top)
A=cell2table(NumHouses);
A.Properties.RowNames={'NumHousesSeen' 'PercentHousesSeen' 'DurationLookedAtHouse'};
clear ii; clear len; clear total; clear x; clear Number; clear totalper; clear percentage;clear ans;clear sumViews;clear h;clear totaltime;
clear e;clear found;