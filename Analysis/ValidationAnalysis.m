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
    Xcoords = [];
    Ycoords = [];
    while ~feof(file)%go through lines in file and save in arrays until end of file in reached
            n = n+1;
            str = fgetl(file);
            if str(1)=='('
                %disp(strsplit(str,','));
                coords = strsplit(str,',');
                cX = char(coords(1));
                cY = char(coords(2));
                Xcoords = [Xcoords abs(str2num(cX(2:end)))];
                Ycoords = [Ycoords abs(str2num(cY(1:end-1)))];
            end
            lines = [lines str2num(str)];
    end
    fclose(file);
    try
        if length(lines)==14
            validations.(subjectNum).(valNum).FullVal = true;
            validations.(subjectNum).(valNum).AvgError = lines(10);
            validations.(subjectNum).(valNum).XError = mean(Xcoords);%lines(13);
            validations.(subjectNum).(valNum).YError = mean(Ycoords);%lines(14);
            validations.(subjectNum).(valNum).Time = lines(11);
            validations.(subjectNum).(valNum).LastCal = lines(12);
        else
            validations.(subjectNum).(valNum).FullVal = false;
            validations.(subjectNum).(valNum).AvgError = lines(2);
            validations.(subjectNum).(valNum).XError = abs(lines(5));
            validations.(subjectNum).(valNum).YError = abs(lines(6));
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
ErrorValGameAccept = [];
ErrorAtEnd = [];
XError = [];
YError = [];
X1P = [];
Y1P = [];
lastVnum = 0;
for i =1:numel(fields)%go through all subjects
    vals = fieldnames(validations.(fields{i}));
    vals=sort_nat(vals);
    for ii=1:numel(vals)%go through al validations
        err = validations.(fields{i}).(vals{ii}).AvgError;
        if ii<numel(vals)
            if validations.(fields{i}).(vals{ii}).Time ==0 && validations.(fields{i}).(vals{ii+1}).Time >0%check if last validation before game (time=0, time+1 >0)
                if lastVnum == i%Take care of some strange cases where session was started twice?
                    %disp(i)
                    AcceptedErrors(end) = err;
                    XError(end) = validations.(fields{i}).(vals{ii}).XError;
                    YError(end) = validations.(fields{i}).(vals{ii}).YError;       
                else
                    AcceptedErrors = [AcceptedErrors err];
                    XError = [XError validations.(fields{i}).(vals{ii}).XError];
                    YError = [YError validations.(fields{i}).(vals{ii}).YError];
                    lastVnum = i;
                end
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
        if validations.(fields{i}).(vals{ii}).Time > 0%check if in Game
            if ii<numel(vals)%its not the last validation file
                if validations.(fields{i}).(vals{ii+1}).Time-validations.(fields{i}).(vals{ii+1}).LastCal >1
                    ErrorValGameAccept = [ErrorValGameAccept err];
                end
            else
                ErrorAtEnd = [ErrorAtEnd err];
            end
        end
    end
end
%% Return Results
disp(['Average Error (degree) for the last callibration before session starts:     ' num2str(mean(AcceptedErrors)), ' Median: ',num2str(median(AcceptedErrors))]);
disp(['Average X-Error (pixel) for the last callibration before session starts:   ' num2str(mean(XError)), ' Median: ',num2str(median(XError))]);
disp(['Average Y-Error (pixel) for the last callibration before session starts:   ' num2str(mean(YError)), ' Median: ',num2str(median(YError))]);
disp(['Average Error (degree) directly after a callibration:                       ' num2str(mean(ErrorAfterVal)), ' Median: ',num2str(median(ErrorAfterVal))]);
disp(['Average Error (degree) directly after a callibration during session:        ' num2str(mean(ErrorAfterValInGame)), ' Median: ',num2str(median(ErrorAfterValInGame))]);
disp(['Average Error (degree) in one point callibration:                           ' num2str(mean(Error1PointVal)), ' Median: ',num2str(median(Error1PointVal))]);
disp(['Average X-Error (pixel) in one point callibration:                         ' num2str(mean(X1P)), ' Median: ',num2str(median(X1P))]);
disp(['Average Y-Error (pixel) in one point callibration:                         ' num2str(mean(Y1P)), ' Median: ',num2str(median(Y1P))]);
disp(['Average accepted error (degree) during Game:                                ' num2str(mean(ErrorValGameAccept)), ' Median: ',num2str(median(ErrorValGameAccept))]);
disp(['Average error (degree) at end of game:                                      ' num2str(mean(ErrorAtEnd)), ' Median: ',num2str(median(ErrorAtEnd))]);
clearvars -except validations

