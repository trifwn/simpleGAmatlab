clc
%clear

%% Parameters for ga
% Optim Parameter
eliteC = 5;
pCount = 50;
maxGen = 150;
maxStGen = 20;
% Track Param
plot = true;
dsp = false;
save = false;

%% Run Expirements
% Fitness Roughness Dominated
name = 'Rough/';
w1 = 98/100; %roughness
w2 = 1/100;  %UTS
w3 = 1/100;  % ELON
disp('Fitness Roughness Dominated')
[bRough,bFitnessR,~,~,populationR,scoreR] = ea(w1,w2,w3,pCount,eliteC,maxGen,maxStGen,name,plot,dsp,save);
bRpred = evalNN(bRough);
bRpredScaled = scale(bRpred,w1,w2,w3);
if save == true
    savePlotelites(populationR,scoreR,eliteC,'Graphs/roughElites.png','Roughness Elites')
    savePlotelites(populationR,scoreR,pCount,'Graphs/roughPop.png','Roughness Population')
end
% Fitness UTS Dominated
name = 'UTS/';
w1 = 1/100; %roughness
w2 = 98/100;  %UTS
w3 = 1/100;  % ELON
disp('Fitness UTS Dominated')
[bUTS,bFitnessU,~,~,populationU,scoreU] = ea(w1,w2,w3,pCount,eliteC,maxGen,maxStGen,name,plot,dsp,save);
bUpred = evalNN(bUTS);
bUpredScaled = scale(bUpred,w1,w2,w3);
if save == true
    savePlotelites(populationU,scoreU,eliteC,'Graphs/utsElites.png','UTS Elites')
    savePlotelites(populationU,scoreU,pCount,'Graphs/utsPop.png','UTS Population')
end
% Elongation Dominated
name = 'Elon/';
w1 = 1/100; %roughness
w2 = 1/100;  %UTS
w3 = 98/100;  % ELON
disp('Fitness Elon Dominated')
[bElon,bFitnessE,~,~,populationE,scoreE] = ea(w1,w2,w3,pCount,eliteC,maxGen,maxStGen,name,plot,dsp,save);
bEpred = evalNN(bElon);
bEpredScaled = scale(bEpred,w1,w2,w3);
if save == true
    savePlotelites(populationE,scoreE,eliteC,'Graphs/ElonElites.png','Elon Elites');
    savePlotelites(populationE,scoreE,pCount,'Graphs/ElonPop.png','Elon Population');
end

% Fitness scaled equally
name = 'Iso/';
w1 = 1/3; %roughness
w2 = 1/3;  %UTS
w3 = 1/3;  % ELON
disp('Fitness scaled equally')
[bIso,bFitnessI,~,~,populationI,scoreI] = ea(w1,w2,w3,pCount,eliteC,maxGen,maxStGen,name,plot,dsp,save);
bIpred = evalNN(bIso);
bIpredScaled = scale(bIpred,w1,w2,w3);
if save == true
    savePlotelites(populationI,scoreI,eliteC,'Graphs/IsoElites.png','Iso Elites');
    savePlotelites(populationI,scoreI,pCount,'Graphs/IsoPop.png','Iso Population');
end

%% STATISTICS
%Population
allPops = [populationI; populationE; populationU; populationR];
[allPops,idx] = rmoutliers(allPops,'mean');
labels = [0*ones(1,length(populationI(:,1))) ones(1,length(populationE(:,1)))...
          2*ones(1,length(populationU(:,1))) 3*ones(1,length(populationR(:,1)))];
mapcaplot(allPops,labels(~idx))

allPops = [populationI; populationE; populationU; populationR];
df = [allPops(:,1:5) round(allPops(:,6)) ~round(allPops(:,6)) allPops(:,7)];
allScores = double(pyrunfile('ANN.py','z','df',df ));
rmax = 368;
rmin = 21;
umax = 37;
umin = 4;
emax = 3.3;
emin = 0.4;
allScores = [w1*((allScores(:,1)-rmin)/(rmax-rmin)) w2*((allScores(:,2)-umin)/(umax-umin)) w3*((allScores(:,3)-emin)/(emax-emin))];
[allScores,idx] = rmoutliers(allScores,'mean');
mapcaplot(allScores,labels(~idx))

%Elites
allElites = [populationI(1:eliteC,:); populationE(1:eliteC,:); populationU(1:eliteC,:); populationR(1:eliteC,:)];
labels = [0*ones(1,length(populationI(1:eliteC,1))) ones(1,length(populationE(1:eliteC,1)))...
          2*ones(1,length(populationU(1:eliteC,1))) 3*ones(1,length(populationR(1:eliteC,1)))];
mapcaplot(allElites,labels)

allElites = [populationI(1:eliteC,:); populationE(1:eliteC,:); populationU(1:eliteC,:); populationR(1:eliteC,:)];
df = [allElites(:,1:5) round(allElites(:,6)) ~round(allElites(:,6)) allElites(:,7)];
allScores = double(pyrunfile('ANN.py','z','df',df ));
rmax = 368;
rmin = 21;
umax = 37;
umin = 4;
emax = 3.3;
emin = 0.4;
allScores = [w1*((allScores(:,1)-rmin)/(rmax-rmin)) w2*((allScores(:,2)-umin)/(umax-umin)) w3*((allScores(:,3)-emin)/(emax-emin))];
mapcaplot(allScores,labels)

%% Pareto Front
contPop = [];
% Load Roughness Data
mat = dir('Rough/*.mat');
for q = 1:length(mat)
    contPop = [contPop ; load(['Rough/' mat(q).name]).Population_gen];
end

%Load UTS
mat = dir('UTS/*.mat');
for q = 1:length(mat)
    contPop = [contPop ; load(['UTS/' mat(q).name]).Population_gen];
end

%Load Elon
mat = dir('Elon/*.mat');
for q = 1:length(mat)
    contPop = [contPop ; load(['Elon/' mat(q).name]).Population_gen];
end

%Load Iso
mat = dir('Iso/*.mat');
for q = 1:length(mat)
    contPop = [contPop ; load(['Iso/' mat(q).name]).Population_gen];
end

% Calculate Scores
df = [contPop(:,1:5) round(contPop(:,6)) ~round(contPop(:,6)) contPop(:,7)];
allScores = double(pyrunfile('ANN.py','z','df',df ));
allfits = [allScores(:,1) , 1./allScores(:,2), 1./allScores(:,3)];

% Find The front
[idx,f] = find_pareto_frontier(allfits);

figure
F = scatteredInterpolant(f(:,1),f(:,2),f(:,3),'linear','none');
sgr = linspace(min(f(:,1)),max(f(:,1)));
ygr = linspace(min(f(:,2)),max(f(:,2)));
[XX,YY] = meshgrid(sgr,ygr);
ZZ = F(XX,YY);
subplot(2,2,1)
surf(XX,YY,ZZ,'LineStyle','none')
hold on
scatter3(f(:,1),f(:,2),f(:,3),'k.');
hold off
subplot(2,2,2)
surf(XX,YY,ZZ,'LineStyle','none')
hold on
scatter3(f(:,1),f(:,2),f(:,3),'k.');
hold off
view(-148,8)
subplot(2,2,3)
surf(XX,YY,ZZ,'LineStyle','none')
hold on
scatter3(f(:,1),f(:,2),f(:,3),'k.');
hold off
view(-180,8)
subplot(2,2,4)
surf(XX,YY,ZZ,'LineStyle','none')
hold on
scatter3(f(:,1),f(:,2),f(:,3),'k.');
hold off
view(-300,8)

%% COMBINATION OF THE LAST ELITS OF CASES
lb = [0.02  1   10  200  40     0   0];
ub = [0.2   10  90  250  120    1   100];
elitesR = populationR(1:eliteC,:);
elitesR = (elitesR -  repmat(lb,length(elitesR(:,1)),1))./(repmat(ub,length(elitesR(:,1)),1)-repmat(lb,length(elitesR(:,1)),1));
Rmean = mean(elitesR);

elitesE = populationE(1:eliteC,:);
elitesE = (elitesE -  repmat(lb,length(elitesE(:,1)),1))./(repmat(ub,length(elitesE(:,1)),1)-repmat(lb,length(elitesE(:,1)),1));
Emean = mean(elitesE);

elitesU = populationU(1:eliteC,:);
elitesU = (elitesU -  repmat(lb,length(elitesU(:,1)),1))./(repmat(ub,length(elitesU(:,1)),1)-repmat(lb,length(elitesU(:,1)),1));
Umean = mean(elitesU);

elitesI = populationI(1:eliteC,:);
elitesI = (elitesI -  repmat(lb,length(elitesI(:,1)),1))./(repmat(ub,length(elitesI(:,1)),1)-repmat(lb,length(elitesI(:,1)),1));
Imean = mean(elitesI);

matA = (Rmean + Umean +Imean)/3;
matB = Imean;
figure(1000000)
b = bar([matB;Rmean;Umean;Emean;matA].');

v2comp = [matB;Rmean;Umean;Emean;matA];
df = [v2comp(:,1:5) round(v2comp(:,6)) ~round(v2comp(:,6)) v2comp(:,7)];
Scores = double(pyrunfile('ANN.py','z','df',df ));
w1=1/3;
w2=1/3;
w3=1/3;
Scores = w1*((Scores(:,1)-rmin)/(rmax-rmin)) - w2*((Scores(:,2)-umin)/(umax-umin)) - w3*((Scores(:,3)-emin)/(emax-emin));

legend(['Mean of I  ' num2str(Scores(1))],['Mean of R   ' num2str(Scores(2))],['Mean of U   ' num2str(Scores(3))], ...
    ['Mean of E     ' num2str(Scores(4))],['Mean of (R+U+E)/3   ' num2str(Scores(5))]);
X = categorical({'layer height (mm)', 'wall thickness (mm)', 'infill density (%)' ...
    'nozzle temperature (0C)', 'printspeed (mm/s)', 'material', 'fanspeed (%)'});
set(gca,'xticklabel',X)
xtickangle(45)

%% Function Defs
function [membership, member_value]=find_pareto_frontier(input)
    out=[];
    data=unique(input,'rows');
    for i = 1:size(data,1)
        
        c_data = repmat(data(i,:),size(data,1),1);
        t_data = data;
        t_data(i,:) = Inf(1,size(data,2));
        smaller_idx = c_data>=t_data;
        
        idx=sum(smaller_idx,2)==size(data,2);
        if ~nnz(idx)
            out(end+1,:)=data(i,:);
        end
    end
    membership = ismember(input,out,'rows');
    member_value = out;
end

function out=evalNN(data)
    df = [data(:,1:5) data(:,6) ~data(:,6) data(:,7)];
    z = pyrunfile('ANN.py','z','df',df );
    out = double(z);
end

function w=scale(out,w1,w2,w3)
    rmax = 368;
    rmin = 21;
    umax = 37;
    umin = 4;
    emax = 3.3;
    emin = 0.4;
    w = [w1*((out(:,1)-rmin)/(rmax-rmin)) w2*((out(:,2)-umin)/(umax-umin)) w3*((out(:,3)-emin)/(emax-emin))];
end
