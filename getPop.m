function [w,z]=getPop(w1,w2,w3)
%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 12);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["layer_heightmm", "wall_thicknessmm", "infill_density", "infill_pattern", "nozzle_temperature0C", "bed_temperature0C", "print_speedmms", "material", "fan_speed", "roughnessm", "tension_strengthMPa", "elongation"];
opts.VariableTypes = ["double", "double", "double", "categorical", "double", "double", "double", "categorical", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["infill_pattern", "material"], "EmptyFieldRule", "auto");

% Import the data
data1 = readtable("data.csv", opts);
clear opts
data1= removevars(data1,{'bed_temperature0C','infill_pattern','roughnessm','elongation','tension_strengthMPa'});
[~, ~, G] = unique(categorical(data1.material));
pop = data1;
pop.pla = ~(G-1);
pop= removevars(pop,{'material'});
pop = movevars(pop,{'layer_heightmm','wall_thicknessmm','infill_density',...
               'nozzle_temperature0C','print_speedmms','pla', ...
               'fan_speed'},'Before',1);
w = table2array(pop);

data2run = data1;
[~, ~, G] = unique(categorical(data2run.material));
data2run.pla = ~(G-1);
data2run.abs = (G-1);
data2run= removevars(data2run,{'material'});

data2run = movevars(data2run,{'layer_heightmm','wall_thicknessmm','infill_density',...
               'nozzle_temperature0C','print_speedmms','pla','abs', ...
               'fan_speed'},'Before',1);
res = double(pyrunfile('ANN.py',"z","df",table2array(data2run)));
rmax = 368;
rmin = 21;
umax = 37;
umin = 4;
emax = 3.3;
emin = 0.4;
z = w1*((res(:,1)-rmin)/(rmax-rmin))-w2*((res(:,2)-umin)/(umax-umin))-w3*((res(:,3)-emin)/(emax-emin));