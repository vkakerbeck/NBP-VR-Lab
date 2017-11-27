%-------------------ValidationAnalysis for all Subjects--------------------
PartList={21,27};%list of subjects that you want to analyze
NumVals = {8,10};%Number of validations done for subject
savepath = 'D:/v.kakerbeck/Tracking/Validation/Results/';%where to save results
%--------------------------------------------------------------------------
NumSj = length(PartList);
validations = zeros(9,max(NumVals{:}),NumSj);
SujStats = cell(3, NumSj);%Summary of individual subject statistics
SJPoints = [];%for variance and mean over all validation points
SJMeans = [];%for overall subject means
for ii = 1: NumSj
    e = cell2mat(PartList(ii));
    SJXPoints = [];%for variance within subject
    SJXMeans = [];%for means of each validation
    for i = 1:NumVals{ii}
        if e<10
            file = fopen(['validation2D_0' num2str(e) '_' num2str(i) '.txt']);
        else
            file = fopen(['validation2D_' num2str(e) '_' num2str(i) '.txt']);
        end
        last = false;
        n = 0;
        while ~feof(file)%go through lines in file and save in arrays until end of file in reached
            n = n+1;
            str = fgetl(file);
            [num, status] = str2num(str);
            if status && ~last
                validations(n,i,ii) = num;
                SJPoints = [SJPoints num];
                SJXPoints = [SJXPoints num];
            else 
                last = true;
            end
            if last
                SJXMeans = [SJXMeans num];
            end
        end
    end
    SJMeans = [SJMeans mean(SJXMeans)];
    SujStats{1,ii} = PartList{ii};%Subject Number
    SujStats{2,ii} = mean(SJXPoints);%mean over all points of Subject X
    SujStats{3,ii} = mean(SJXMeans);%mean over all average validation scores of Subject X
    SujStats{4,ii} = var(SJXPoints);%variance in all validation points
end
OverallMeanPoints = mean(SJPoints);
OverallMeanSubjects = mean(SJMeans);
OverallVariancePoints = var(SJPoints);
Stats=cell2table(SujStats);
Stats.Properties.RowNames={'Subject Number' 'Average of Subject Means' 'Average of all Data Points' 'Variance in Data Points'};
OverallStats = table(OverallMeanPoints,OverallMeanSubjects,OverallVariancePoints);
OverallStats.Properties.VariableNames = {'OverallMeanPoints';'OverallMeanSubjects';'OverallVariancePoints'};
save([savepath 'ValidationStatsSJ.mat'],'Stats');
save([savepath 'OverallStats.mat'],'OverallStats');
clear e;clear file; clear i; clear ii; clear last; clear n;clear num; clear NumSj;clear NumVals;clear PartList; clear status;clear str;clear SujStats;
clear SJXMeans;clear SJXPoints;clear SJMeans;
