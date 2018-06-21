%-------------3D Heatmap fo eye gaze (x,y,distance)------------------------
savepath = 'C:/Users/vivia/Dropbox/Project Seahaven/Tracking/Heatmap3D/Results';
Condition = '';
%--------------------------------------------------------------------------
%%Load data
Cond = "VR"; %Options: VR, VR-belt,All
Repeated = false;%Options: true, false
%--------------------------------------------------------------------------
files = [];
if Cond ~= "All"
    for line = 1:height(Seahavenalingmentproject)
        if lower(cellstr(Seahavenalingmentproject.Training(line)))==lower(Cond) && Seahavenalingmentproject.Discarded(line) ==""
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
    files = dir('3DHeatmap_VP*.txt');%Analyzes all subjectfiles in your ViewedHouses directory
end
%Analyze ------------------------------------------------------------------
Number = length(files);
x=[];y=[];d=[];
for num = 1:1
    if Cond == "All"
        VPNum =files(num).name(13:16);
    else
        VPNum = files(num);
    end
    disp(VPNum);
    path = ['3DHeatmap' Condition '_VP' num2str(VPNum) '.txt'];
    disp(path);
    data = fopen(path);
    data = textscan(data,'%s','delimiter', '\n');
    data = data{1};
    data = table2array(cell2table(data));
    len = int64(length(data));
    for i = 1:double(len)
        if data{i}(2)~=char('-')&&~isempty(data{i}(21:end-1))&&~contains(data{i},'-')&&data{i}(10)==','
            x(end+1) = str2num(data{i}(2:9));
            y(end+1) = str2num(data{i}(11:19));
            d(end+1) = log(str2num(data{i}(21:end-1)));
        else
            x(i)=0;y(i)=0;d(i)=210;
        end
        %sort out point of no tracking
        if d(i)>=200 || d(i)<=0 || x(i)>1 ||y(i) >1 ||x(i)==0||y(i)==0
            x(i)=200;y(i)=200;d(i)=200; 
        end
    end
    d = d(d~=200);y = y(y~=200);x = x(x~=200);
end
%% 
c=zeros(size(x));
for i=1:length(x)
  j=1:length(x);
  j(i)=[];
  s = sort((x(j)-x(i)).^2+(y(j)-y(i)).^2+(d(j)/5-d(i)/5).^2);
  c(i)=sum(s<0.05);
end
%remember to cut off first values when eye tracker isn't initialized yet
%scatter3(d,x,y)
t = array2table([x;y;d;c].');
t.Properties.VariableNames = {'x' 'y' 'd' 'c'};
toDelete = t.d < 0;
t(toDelete,:) = [];
save(fullfile(savepath,['Heatmap3D' Condition '_' num2str(Number) 'SJs']),'t');
scatter3(d,x,y,2,c);%then save the plot by hand
colorbar;   
xlabel('Close - Far','FontSize',22); ylabel('Left - Right','FontSize',22); zlabel('Up - Down','FontSize',22);
saveas(gcf,fullfile(savepath,['Heatmap3D' Condition '_' num2str(Number) 'SJs' '.jpeg']));
%% Calculate difference & Other Extra Info
%navigate into Results folder (where heatmaps from previous section are
%saved)
Random = load(['Heatmap3DRandomGaze_31.mat']);
Normal = load(['Heatmap3D_31.mat']);
RandomPos = load(['Heatmap3DRandomPos_31.mat']);
%get distance of maximum density-------------------------------------------
[maxN,iN]=max(Normal.t.c);maxdN=Normal.t.d(iN);
[maxRP,iRP]=max(RandomPos.t.c);maxdRP=RandomPos.t.d(iRP);
[maxRG,iRG]=max(Random.t.c);maxdRG=Random.t.d(iRG);
disp('Distance of most dense point: ');
disp(['Normal: ',num2str(maxdN),' Random Position: ',num2str(maxdRP),' Random Gaze: ',num2str(maxdRG)]);
%get average distance of x most dense points-------------------------------
x=10;
sortN = sortrows(Normal.t,'c');distN=mean(sortN.d(end-x:end));
sortRP = sortrows(RandomPos.t,'c');distRP=mean(sortRP.d(end-x:end));
sortRG = sortrows(Random.t,'c');distRG=mean(sortRG.d(end-x:end));
disp(['Average distance of ',num2str(x),' most dense points: ']);
disp(['Normal: ',num2str(distN),' Random Position: ',num2str(distRP),' Random Gaze: ',num2str(distRG)]);
%Calculate heatmaps--------------------------------------------------------
size = 50;
NormDistribution = hist3([Normal.t.x, Normal.t.d],[size,size]);
RandDistribution = hist3([Random.t.x, Random.t.d],[size,size]);
RandPDistribution = hist3([RandomPos.t.x, RandomPos.t.d],[size,size]);
distNorm = NormDistribution/norm(NormDistribution);
distRand = RandDistribution/norm(RandDistribution);
distRandP = RandPDistribution/norm(RandPDistribution);
differenceG = distNorm-distRand;
differenceP = distNorm-distRandP;
%plot----------------------------------------------------------------------
figure;
subplot(2,3,1);hold;
title('Normal');xlabel('Distance');ylabel('X');
h=pcolor(distNorm);colorbar;set(h, 'EdgeColor', 'none');
subplot(2,3,2);hold;
title('Random Gaze');xlabel('Distance');ylabel('X');
h=pcolor(distRand);colorbar;set(h, 'EdgeColor', 'none');
subplot(2,3,3);hold;
title('Random Position');xlabel('Distance');ylabel('X');
h=pcolor(distRandP);colorbar;set(h, 'EdgeColor', 'none');
subplot(2,3,4);hold;
title('Normal - Random Gaze');xlabel('Distance');ylabel('X');
h=pcolor(differenceG);colorbar;set(h, 'EdgeColor', 'none');
subplot(2,3,5);hold;
title('Normal - Random Position');xlabel('Distance');ylabel('X');
h=pcolor(differenceP);colorbar;set(h, 'EdgeColor', 'none');