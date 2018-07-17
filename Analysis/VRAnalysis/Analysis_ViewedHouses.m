%------------Overall Viewed Houses Analysis (2nd Level)--------------------
savepath = 'C:/Users/vivia/Dropbox/Project Seahaven/Tracking/ViewedHouses/Results/';
%--------------------------------------------------------------------------
%%Load data
Condition = "VR"; %Options: VR, VR-belt,All
Repeated = false;%Options: true, false
%--------------------------------------------------------------------------
files = [];
if Condition ~= "All"
    for line = 1:height(Seahavenalingmentproject)
        if lower(cellstr(Seahavenalingmentproject.Training(line)))==lower(Condition) && Seahavenalingmentproject.Discarded(line) ==""
            if Repeated == false && Seahavenalingmentproject.Measurement(line)==1
                files = [files, Seahavenalingmentproject.Subject(line)];
            end
            if Repeated == true && Seahavenalingmentproject.Measurement(line)==3
                str = char(Seahavenalingmentproject.Comments(line));
                i = strfind(Seahavenalingmentproject.Comments(line),'#');
                Mes = [str2num(str(i(1)+1:i(1)+4));str2num(str(i(2)+1:i(2)+4));(Seahavenalingmentproject.Subject(line))];
                files = [files, Mes];
            end
        end
    end
else
    files = dir('NumViewsD_VP_*.mat');%Analyzes all subjectfiles in your ViewedHouses directory
end
% Analyze -----------------------------------------------------------------
Number = length(files);
NumHouses = cell(2,Number);
total = 0;
totalper = 0;
names = [];
for ii = 1: Number
    if Condition == "All"
        suj_num = files(ii).name(14:17);
    else
        suj_num = files(ii);
    end
    names = [names num2str(suj_num)];
    x = load(['NumViewsD_VP_' num2str(suj_num) '.mat']);
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
%Statistics and Saving-----------------------------------------------------
avg=total/Number;%how many houses were looked at on average
avgper = totalper/Number;%how much percent of the houses
avgTime = mean(avgocc(2:end));%how long on average were houses looked at (s)
avgTotalTime = sum(avgocc(2:end))/60;%average overall time looked at houses in minutes
totalNum = [totalNum array2table(avgocc)];
totalNum=sortrows(totalNum,2,'descend');%sort the table of houseViews in descending order (most often viewed houses on top)
ViewStats=cell2table(NumHouses);
ViewStats.Properties.RowNames={'NumHousesSeen' 'PercentHousesSeen' 'AverageTimeLookedAtOneHouse (s)' 'TimeLookedAtHouses (min)'};
%ViewStats.Properties.VariableNames = strcat('VP ',cellfun(@num2str,PartList, 'un',0));
t = array2table([avg,avgper,avgTime,avgTotalTime].');%add overall stas to table
ViewStats = [ViewStats t];
ViewStats.Properties.VariableNames{'Var1'} = 'Overall';
save([savepath 'totalNum' num2str(Number) '.mat'],'totalNum');%list of houses looks at with overal duration, average distance etc
save([savepath 'ViewingStats' num2str(Number) '.mat'],'ViewStats');%overall subject stats in a table (percentage, num houses looked at, avg duration)
clear ii; clear len; clear total; clear x; clear Number; clear totalper; clear percentage;clear ans;clear sumViews;clear h;clear totaltime;
clear e;clear found;clear n;clear a;clear avgocc;clear NumHouses;clear PartList;clear savepath;clear t;