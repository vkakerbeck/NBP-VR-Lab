%--Analyze Task Performance Overall and in Relation to Viewed Houses-------
PartList ={3755,6876}; %all Subjects
Number = length(PartList);
%--------------------------------------------------------------------------
for ii = 1: Number
    e = cell2mat(PartList(ii));
    load(['AlignmentVR_SubjNo_',num2str(e),'.mat']);
    Abs3sec = [];
    AbsInf = [];
    Rel3sec = [];
    RelInf = [];
    Poi3sec = [];
    PoiInf = [];
    if ii==1%create cells for performance for each house
        houselistAInf=[];
        houselistA3s=[];
        for i=1:36
            houselistAInf=[houselistAInf Output.Absolute.Trial_Inf(i).House_Nr];
            houselistA3s=[houselistA3s Output.Absolute.Trial_3s(i).House_Nr];
        end
        AbsperfInf = cell(36,Number+1);%make list of houses 
        AbsperfInf(1:end,1)=num2cell(sort(houselistAInf.'));
        Absperf3s = cell(36,Number+1);
        Absperf3s(1:end,1)=num2cell(sort(houselistA3s.'));
    end
    for i = 1:36%extract performance
        Abs3sec = [Abs3sec strcmp(Output.Absolute.Trial_3s(i).Correct,Output.Absolute.Trial_3s(i).Decision)];
        AbsInf = [AbsInf strcmp(Output.Absolute.Trial_Inf(i).Correct,Output.Absolute.Trial_Inf(i).Decision)];
        Rel3sec = [Rel3sec strcmp(Output.Relative.Trial_3s(i).Correct,Output.Relative.Trial_3s(i).Decision)];
        RelInf = [RelInf strcmp(Output.Relative.Trial_Inf(i).Correct,Output.Relative.Trial_Inf(i).Decision)];    
        Poi3sec = [Poi3sec strcmp(Output.Pointing.Trial_3s(i).Correct,Output.Pointing.Trial_3s(i).Decision)];
        PoiInf = [PoiInf strcmp(Output.Pointing.Trial_Inf(i).Correct,Output.Pointing.Trial_Inf(i).Decision)];
        IndexAI = find([AbsperfInf{:,1}]==(Output.Absolute.Trial_Inf(i).House_Nr));%write performance for each house into cells
        AbsperfInf(IndexAI,ii+1) = num2cell(AbsInf(i));%performance for each house in absolute condition - Infinite
        IndexA3 = find([Absperf3s{:,1}]==(Output.Absolute.Trial_3s(i).House_Nr));
        Absperf3s(IndexA3,ii+1) = num2cell(Abs3sec(i));%performance for each house in absolute condition - 3Sec
    end

    disp(['Subject ',num2str(e),':'])
    disp(['Im Absolute Task 3sec korrekt: ' num2str(100*sum(Abs3sec)/36) '%']);
    disp(['Im Absolute Task Inf korrekt: ' num2str(100*sum(AbsInf)/36) '%']);
    disp(['Im Relative Task 3sec korrekt: ' num2str(100*sum(Rel3sec)/36) '%']);
    disp(['Im Relative Task Inf korrekt: ' num2str(100*sum(RelInf)/36) '%']);
    disp(['Im Pointing Task 3sec korrekt: ' num2str(100*sum(Poi3sec)/36) '%']);
    disp(['Im Pointing Task Inf korrekt: ' num2str(100*sum(PoiInf)/36) '%']);
end
clear e;clear i; clear ii; clear IndexA3;clear IndexAI;clear houselistAInf;clear houselistA3;
%% Analyze Task Performance in Relation to Viewed Houses
dname = 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\ViewedHouses\';
listTCI = [];%list of viewing time for correct performance - Infinite
listTWI = [];%list of viewing time for wrong performance - Infinite
listTC3 = [];%list of viewing time for correct performance - 3sec
listTW3 = [];%list of viewing time for wrong performance - 3sec
for ii = 1: Number
    %open numViewed Table
    e = cell2mat(PartList(ii));
    fname=fullfile(dname,['NumViewsD_VP_' num2str(e) '.mat']);
    v = load(fname);
    numV=v.NumViews;

    for i = 1:36
        houseAI = AbsperfInf(i,1);
        if cell2mat(houseAI)<10%Format house number
            houseAI=['00' num2str(cell2mat(houseAI))];
        elseif cell2mat(houseAI)<100
            houseAI=['0' num2str(cell2mat(houseAI))];
        else
            houseAI=num2str(cell2mat(houseAI));
        end
        idAI = strfind(numV.House, houseAI);
        idAI = find(not(cellfun('isempty', idAI)));
        if cell2mat(AbsperfInf(i,ii+1))==1%Write time spent for Abs Inf into list
            listTCI = [listTCI,numV.occ(idAI)];
        else
            listTWI = [listTWI,numV.occ(idAI)];
        end
        %Same for Absolute - 3 Seconds
        houseA3 = Absperf3s(i,1);
        if cell2mat(houseA3)<10%Format house number
            houseA3=['00' num2str(cell2mat(houseA3))];
        elseif cell2mat(houseA3)<100
            houseA3=['0' num2str(cell2mat(houseA3))];
        else
            houseA3=num2str(cell2mat(houseA3));
        end
        idA3 = strfind(numV.House, houseA3);
        idA3 = find(not(cellfun('isempty', idA3)));
        if cell2mat(Absperf3s(i,ii+1))==1%Write time spent for Abs Inf into list
            listTC3 = [listTC3,numV.occ(idA3)];
        else
            listTW3 = [listTW3,numV.occ(idA3)];
        end
    end
end
%% Plotting
mini = min(length(listTCI),length(listTWI));
boxplot(([listTCI(1:mini); listTWI(1:mini)]).','Labels',{'Correct','Wrong'});
title('Time Spent Looking at Houses for Performance in Absolute Task - Infinite')
xlabel('Task Performance')
ylabel('Time Looked at House')
%% 
%Plot 3sec
mini = min(length(listTC3),length(listTW3));
boxplot(([listTC3(1:mini); listTW3(1:mini)]).','Labels',{'Correct','Wrong'});
title('Time Spent Looking at Houses for Performance in Absolute Task - 3 Sec')
xlabel('Task Performance')
ylabel('Time Looked at House')
%% both
mini = min([length(listTC3),length(listTW3),length(listTCI),length(listTWI)]);
boxplot(([listTC3(1:mini); listTW3(1:mini);listTCI(1:mini); listTWI(1:mini)]).','Labels',{'Correct 3s','Wrong 3s','Correct Inf','Wrong Inf'});
title('Variance in Viewing Distance of Houses for Performance in Absolute Task')
xlabel('Task Performance')
ylabel('Variance in Viewing Distance')
%% Analyze Task Performance in Relation to Viewed Distance and other stuff
%not very clean with all the names but just change the lines with XX to the
%variable you want to analyze.
dname = 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\ViewedHouses\';
listTCI = [];%list of viewing time for correct performance - Infinite
listTWI = [];%list of viewing time for wrong performance - Infinite
listTC3 = [];%list of viewing time for correct performance - 3sec
listTW3 = [];%list of viewing time for wrong performance - 3sec
for ii = 1: Number
    %open numViewed Table
    e = cell2mat(PartList(ii));
    fname=fullfile(dname,['NumViewsD_VP_' num2str(e) '.mat']);
    v = load(fname);
    numV=v.NumViews;

    for i = 1:36
        houseAI = AbsperfInf(i,1);
        if cell2mat(houseAI)<10%Format house number
            houseAI=['00' num2str(cell2mat(houseAI))];
        elseif cell2mat(houseAI)<100
            houseAI=['0' num2str(cell2mat(houseAI))];
        else
            houseAI=num2str(cell2mat(houseAI));
        end
        idAI = strfind(numV.House, houseAI);
        idAI = find(not(cellfun('isempty', idAI)));
        if cell2mat(AbsperfInf(i,ii+1))==1%Write time spent for Abs Inf into list
            listTCI = [listTCI,numV.DistanceVariance(idAI)];%XX
        else
            listTWI = [listTWI,numV.DistanceVariance(idAI)];%XX
        end
        %Same for Absolute - 3 Seconds
        houseA3 = Absperf3s(i,1);
        if cell2mat(houseA3)<10%Format house number
            houseA3=['00' num2str(cell2mat(houseA3))];
        elseif cell2mat(houseA3)<100
            houseA3=['0' num2str(cell2mat(houseA3))];
        else
            houseA3=num2str(cell2mat(houseA3));
        end
        idA3 = strfind(numV.House, houseA3);
        idA3 = find(not(cellfun('isempty', idA3)));
        if cell2mat(Absperf3s(i,ii+1))==1%Write time spent for Abs Inf into list
            listTC3 = [listTC3,numV.DistanceVariance(idA3)];%XX
        else
            listTW3 = [listTW3,numV.DistanceVariance(idA3)];%XX
        end
    end
end