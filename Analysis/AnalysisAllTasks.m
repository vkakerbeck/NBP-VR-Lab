


%% 

Abs3sec = [];

AbsInf = [];

Rel3sec = [];

RelInf = [];

Poi3sec = [];
PoiInf = [];



for i = 1:36

    %correct decision
    Abs3sec = [Abs3sec strcmp(Output.Absolute.Trial_3s(i).Correct,Output.Absolute.Trial_3s(i).Decision)];
    %no decision
    Abs3sec = [Abs3sec strcmp('None',Output.Absolute.Trial_3s(i).Decision)/2];
    
    AbsInf = [AbsInf strcmp(Output.Absolute.Trial_Inf(i).Correct,Output.Absolute.Trial_Inf(i).Decision)];

    Rel3sec = [Rel3sec strcmp(Output.Relative.Trial_3s(i).Correct,Output.Relative.Trial_3s(i).Decision)];
    Rel3sec = [Rel3sec strcmp('None',Output.Relative.Trial_3s(i).Decision)/2];

    RelInf = [RelInf strcmp(Output.Relative.Trial_Inf(i).Correct,Output.Relative.Trial_Inf(i).Decision)];    

    Poi3sec = [Poi3sec strcmp(Output.Pointing.Trial_3s(i).Correct,Output.Pointing.Trial_3s(i).Decision)];
    Poi3sec = [Poi3sec strcmp('None',Output.Pointing.Trial_3s(i).Decision)/2];

    PoiInf = [PoiInf strcmp(Output.Pointing.Trial_Inf(i).Correct,Output.Pointing.Trial_Inf(i).Decision)];   

    

end    


disp(['Im Absolute Task 3sec korrekt: ' num2str(100*sum(Abs3sec)/36) '%']);

disp(['Im Absolute Task Inf korrekt: ' num2str(100*sum(AbsInf)/36) '%']);

disp(['Im Relative Task 3sec korrekt: ' num2str(100*sum(Rel3sec)/36) '%']);

disp(['Im Relative Task Inf korrekt: ' num2str(100*sum(RelInf)/36) '%']);

disp(['Im Pointing Task 3sec korrekt: ' num2str(100*sum(Poi3sec)/36) '%']);

disp(['Im Pointing Task Inf korrekt: ' num2str(100*sum(PoiInf)/36) '%']);
