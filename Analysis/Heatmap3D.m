%-------------3D Heatmap fo eye gaze (x,y,distance)------------------------
PartList = {31};
savepath = 'C:/Users/vivia/Dropbox/Project Seahaven/Tracking/Heatmap3D/Results';
Condition = 'RandomGaze';
%--------------------------------------------------------------------------
Number = length(PartList);
x=[];y=[];d=[];
for num = 1:Number
    VPNum =cell2mat(PartList(num));
    disp(VPNum);
    path = ['3DHeatmap' Condition '_VP' num2str(VPNum) '.txt'];
    disp(path);
    data = fopen(path);
    data = textscan(data,'%s','delimiter', '\n');
    data = data{1};
    data = table2array(cell2table(data));
    len = int64(length(data));
    for i = 1:double(len)
        if data{i}(2)~=char('-')
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
scatter3(d,x,y,2,c);%then save the plot by hand
colorbar;
xlabel('Close - Far','FontSize',22); ylabel('Left - Right','FontSize',22); zlabel('Up - Down','FontSize',22);
save(fullfile(savepath,['Heatmap3D' Condition '_' VPNum]),'t');
saveas(gcf,fullfile(savepath,['Heatmap3D' Condition '_' VPNum '.jpeg']));
%% Calculate difference
Random = load(['Heatmap3DRandomGaze_31.mat']);
Normal = load(['Heatmap3D_31.mat']);
RandomPos = load(['Heatmap3DRandomPos_31.mat']);
size = 50;
NormDistribution = hist3([Normal.t.x, Normal.t.d],[size,size]);
RandDistribution = hist3([Random.t.x, Random.t.d],[size,size]);
RandPDistribution = hist3([RandomPos.t.x, RandomPos.t.d],[size,size]);
distNorm = NormDistribution/norm(NormDistribution);
distRand = RandDistribution/norm(RandDistribution);
distRandP = RandPDistribution/norm(RandPDistribution);
differenceG = distRand-distNorm;
differenceP = distRandP-distNorm;
%plot----------------------------------------------------------------------
figure;
subplot(2,3,1);hold;
title('Normal');xlabel('Distance');ylabel('X');
pcolor(distNorm);colorbar;
subplot(2,3,2);hold;
title('Random Gaze');xlabel('Distance');ylabel('X');
pcolor(distRand);colorbar;
subplot(2,3,3);hold;
title('Random Position');xlabel('Distance');ylabel('X');
pcolor(distRandP);colorbar;
subplot(2,3,4);hold;
title('Random Gaze - Normal');xlabel('Distance');ylabel('X');
pcolor(differenceG);colorbar;
subplot(2,3,5);hold;
title('Random Position - Normal');xlabel('Distance');ylabel('X');
pcolor(differenceP);colorbar;