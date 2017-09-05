%read in data & allocate space
suj_num = input('Enter subject number (1-50): ','s');
data = fopen(['EyesOnScreen_VP' suj_num,'.txt']);
data = textscan(data,'%s','delimiter', '\n');
data = data{1};
data = table2array(cell2table(data));
len = int16(length(data));
X = zeros(1,len);
Y = zeros(1,len);
%cut out certain part
rdata = fopen(strcat('D:\v.kakerbeck\Tracking\Position\positions_VP',num2str(suj_num),'.txt'));
rdata = textscan(rdata,'%s','delimiter', '\n');
rdata = rdata{1};
rdata = table2array(cell2table(rdata));
rlen = int16(length(rdata)/9);
r = zeros(1,rlen);
%extract rotation information
for a = 1:double(len)-1
    liner = textscan(rdata{a},'%s','delimiter', ',');liner = liner{1};
    r(a) = str2num(cell2mat(liner(4)));
end
%clear rdata;
%look for significant turns
turnsright = [];
turnsleft = [];
for a = 50:double(rlen)
    if r(a)-r(a-10)>10
        turnsright(end+1) = a-10;
    end
    if r(a)-r(a-10)<-10
        turnsleft(end+1) = a-10;
    end
end
%take out multiple detections of same turn
for i=length(turnsright):-1:2
    if turnsright(i)-turnsright(i-1)==1
       turnsright(i)=0; 
    end
end
for i = length(turnsleft):-1:2
    if turnsleft(i)-turnsleft(i-1)==1
       turnsleft(i)=0; 
    end
end
turnsright = turnsright(turnsright~=0);
turnsleft = turnsleft(turnsleft~=0);
%define intervals
rightI = [];
leftI = [];
for e = 1:length(turnsright)
    rightI = [rightI turnsright(e)-10:turnsright(e)+10];
end
for e = 1:length(turnsleft)
    leftI = [leftI turnsleft(e)-10:turnsleft(e)+10];
end
%loop for drawing the viewing path
X(49) = str2double(data{49}(2:9));
Y(49) = str2double(data{49}(12:19));
sumR=0;
numR=0;
sumL=0;
numL=0;
for a = 50:len-100
   %pause(0.1);
   X(a) = str2double(data{a}(2:9));
   Y(a) = str2double(data{a}(12:19));
   if(X(a)~=0 &&X(a-1)~=0 &&Y(a)~=0 &&Y(a-1)~=0)
       if ismember(a,rightI)
           line([X(a-1) X(a)],[Y(a-1) Y(a)],'Color','red');
           sumR=sumR+X(a);
           numR=numR+1;
       elseif ismember(a,leftI)
           line([X(a-1) X(a)],[Y(a-1) Y(a)],'Color','green');
           sumL=sumL+X(a);
           numL=numL+1;
       else
           line([X(a-1) X(a)],[Y(a-1) Y(a)]);
       end
   end
   axis([-0.1 1.1 -0.1 1.1])
   %drawnow;
end
hold;
avgR=sumR/numR;
avgL=sumL/numL;
plot(avgR,0.6,'k.','MarkerSize',35)
plot(avgR,0.6,'r.','MarkerSize',30)
plot(avgL,0.6,'k.','MarkerSize',35)
plot(avgL,0.6,'b.','MarkerSize',30)
distance = avgR-avgL;
%final plot with marking the data points
%line(X,Y);
%hold;
%scatter(X,Y);
axis([-0.1 1.1 -0.1 1.1])