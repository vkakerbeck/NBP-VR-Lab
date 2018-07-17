%--Analyze Overall Task Performance in Relation to other HyperValues-------
PartList ={3755,6876}; %all Subjects
Number = length(PartList);
sourcepath = 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\';%path to tracking folder
%--------------------------------------------------------------------------
Performances = cell(6,Number);%cell with overall performance for each task for each subject
for ii = 1: Number
    e = cell2mat(PartList(ii));
    load(['AlignmentVR_SubjNo_',num2str(e),'.mat']);
    Abs3sec = [];
    AbsInf = [];
    Rel3sec = [];
    RelInf = [];
    Poi3sec = [];
    PoiInf = [];
    for i = 1:36%extract performance
        Abs3sec = [Abs3sec strcmp(Output.Absolute.Trial_3s(i).Correct,Output.Absolute.Trial_3s(i).Decision)];
        AbsInf = [AbsInf strcmp(Output.Absolute.Trial_Inf(i).Correct,Output.Absolute.Trial_Inf(i).Decision)];
        Rel3sec = [Rel3sec strcmp(Output.Relative.Trial_3s(i).Correct,Output.Relative.Trial_3s(i).Decision)];
        RelInf = [RelInf strcmp(Output.Relative.Trial_Inf(i).Correct,Output.Relative.Trial_Inf(i).Decision)];    
        Poi3sec = [Poi3sec strcmp(Output.Pointing.Trial_3s(i).Correct,Output.Pointing.Trial_3s(i).Decision)];
        PoiInf = [PoiInf strcmp(Output.Pointing.Trial_Inf(i).Correct,Output.Pointing.Trial_Inf(i).Decision)];
    end
    disp(['Subject ',num2str(e),':'])
    disp(['Im Absolute Task 3sec korrekt: ' num2str(100*sum(Abs3sec)/36) '%']);%in thi sorder the performanes will be written into the cell array.
    disp(['Im Absolute Task Inf korrekt: ' num2str(100*sum(AbsInf)/36) '%']);
    disp(['Im Relative Task 3sec korrekt: ' num2str(100*sum(Rel3sec)/36) '%']);
    disp(['Im Relative Task Inf korrekt: ' num2str(100*sum(RelInf)/36) '%']);
    disp(['Im Pointing Task 3sec korrekt: ' num2str(100*sum(Poi3sec)/36) '%']);
    disp(['Im Pointing Task Inf korrekt: ' num2str(100*sum(PoiInf)/36) '%']);
    Performances(1:end,ii)=num2cell([(100*sum(Abs3sec)/36);(100*sum(AbsInf)/36);(100*sum(Rel3sec)/36);(100*sum(RelInf)/36);(100*sum(Poi3sec)/36);(100*sum(PoiInf)/36)]);
end
%% Look at the Performance cell in relation to other variables
load([sourcepath '\EyesOnScreen\StandWalk' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.mat']);
percents = [];
for i =1:Number
    percentWalk=StandWalk{1,i}/(StandWalk{1,i}+StandWalk{2,i});
    percents=[percents percentWalk];
    disp(percentWalk)
end
corrcoef(percents,cell2mat(Performances(1,:)))
corrcoef(percents,cell2mat(Performances(2,:)))
plot(percents,cell2mat(Performances(6,:)))%type number in performances(X,:) for specific task
