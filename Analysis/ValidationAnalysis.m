%-------------------ValidationAnalysis for all Subjects--------------------
files = dir('validation2D_*.txt');
savepath = 'C:/Users/vivia/Dropbox/Project Seahaven/Tracking/Validation/Results/';%where to save results
%--------------------------------------------------------------------------
NumVal = length(files);
for vi=1:NumVal
    file = fopen(files(vi).name);
    n = 0;
    subjectNum = ['Subject' files(vi).name(14:17)];
    valNum = ['Val' files(vi).name(19:end-4)];
    lines = [];
    while ~feof(file)%go through lines in file and save in arrays until end of file in reached
            n = n+1;
            str = fgetl(file);
            lines = [lines str2num(str)];
    end
    fclose(file);
    try
        if length(lines)==14
            validations.(subjectNum).(valNum).FullVal = true;
            validations.(subjectNum).(valNum).AvgError = lines(10);
            validations.(subjectNum).(valNum).XError = lines(13);
            validations.(subjectNum).(valNum).YError = lines(14);
            validations.(subjectNum).(valNum).Time = lines(11);
            validations.(subjectNum).(valNum).LastCal = lines(12);
        else
            validations.(subjectNum).(valNum).FullVal = false;
            validations.(subjectNum).(valNum).AvgError = lines(2);
            validations.(subjectNum).(valNum).XError = lines(5);
            validations.(subjectNum).(valNum).YError = lines(6);
            validations.(subjectNum).(valNum).Time = lines(3);
            validations.(subjectNum).(valNum).LastCal = lines(4);
        end
    catch
        disp(valNum);
        disp(subjectNum);
    end
end
%% Now we have a struct with all important information and analyze this struct in the next step
fields = fieldnames(validations);
AcceptedErrors = [];
ErrorAfterVal = [];
ErrorAfterValInGame = [];
Error1PointVal = [];
XError = [];
YError = [];
X1P = [];
Y1P = [];
for i =1:numel(fields)
    vals = fieldnames(validations.(fields{i}));
    vals=sort_nat(vals);
    for ii=1:numel(vals)
        err = validations.(fields{i}).(vals{ii}).AvgError;
        if ii<numel(vals) && i<numel(fields)
            if validations.(fields{i}).(vals{ii}).Time ==0 && validations.(fields{i}).(vals{ii+1}).Time >0
                AcceptedErrors = [AcceptedErrors err];
                XError = [XError validations.(fields{i}).(vals{ii}).XError];
                YError = [YError validations.(fields{i}).(vals{ii}).YError];
            end
        end
        if validations.(fields{i}).(vals{ii}).Time-validations.(fields{i}).(vals{ii}).LastCal <1%less than 1 minute between validation and the last calibration
            ErrorAfterVal = [ErrorAfterVal err];
            if validations.(fields{i}).(vals{ii}).Time > 0
                ErrorAfterValInGame = [ErrorAfterValInGame err];
            end
        end
        if validations.(fields{i}).(vals{ii}).FullVal == false
            Error1PointVal = [Error1PointVal err];
            X1P = [X1P validations.(fields{i}).(vals{ii}).XError];
            Y1P = [Y1P validations.(fields{i}).(vals{ii}).YError];
        end
        
    end
end
%% Return Results
disp(['Average Error for the last callibration before session starts:     ' num2str(mean(AcceptedErrors)), ' Median: ',num2str(median(AcceptedErrors))]);
disp(['Average X-Error for the last callibration before session starts:   ' num2str(mean(XError)), ' Median: ',num2str(median(XError))]);
disp(['Average Y-Error for the last callibration before session starts:   ' num2str(mean(YError)), ' Median: ',num2str(median(YError))]);
disp(['Average Error directly after a callibration:                       ' num2str(mean(ErrorAfterVal)), ' Median: ',num2str(median(ErrorAfterVal))]);
disp(['Average Error directly after a callibration during session:        ' num2str(mean(ErrorAfterValInGame)), ' Median: ',num2str(median(ErrorAfterValInGame))]);
disp(['Average Error in one point callibration:                           ' num2str(mean(Error1PointVal)), ' Median: ',num2str(median(Error1PointVal))]);
disp(['Average X-Error in one point callibration:                         ' num2str(mean(X1P)), ' Median: ',num2str(median(X1P))]);
disp(['Average Y-Error in one point callibration:                         ' num2str(mean(Y1P)), ' Median: ',num2str(median(Y1P))]);
clearvars -except validations

