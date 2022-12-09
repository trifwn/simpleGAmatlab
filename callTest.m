clear all
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
Target= data1{:,10:12};
T= removevars(data1,{'bed_temperature0C','infill_pattern','roughnessm','elongation','tension_strengthMPa'});
[GN, ~, G] = unique(categorical(T.material));
T.pla = ~(G-1);
T.abs = (G-1);
T= removevars(T,{'material'});

T = movevars(T,{'layer_heightmm','wall_thicknessmm','infill_density',...
               'nozzle_temperature0C','print_speedmms','pla','abs', ...
               'fan_speed'},'Before',1);

%% CALL PYTHON FILE
%pyenv("Version","/home/tryfonas/Applications/anaconda3/envs/tf/bin/python", "ExecutionMode", "OutOfProcess")

py.sys.setdlopenflags(int32(10))
res = pyrunfile('ANN.py',"z","df",table2array(T));
res = double(res);
plot(res(:,1),res(:,1),res(:,1),Target(:,1),'o')
plot(res(:,2),res(:,2),res(:,2),Target(:,2),'o')
plot(res(:,3),res(:,3),res(:,3),Target(:,3),'o')