function [x,fval,exitflag,output,population,score] = ea(w1,w2,w3,pop,eliteC,maxGen,maxStGen,name,plot,dsp,save)
    
    [initPop,initScores] = getPop(w1,w2,w3);
    %% Modify options setting
    options = optimoptions('ga');
    options = optimoptions(options,'UseVectorized',true);
    options = optimoptions(options,'PopulationSize', pop);
    
    %Stopping Criteria
    options = optimoptions(options,'MaxStallGenerations',maxStGen,'MaxGenerations',maxGen,'EliteCount', eliteC);

    % Initialization
    options = optimoptions(options,'InitialPopulationMatrix',initPop,'InitialScoresMatrix',initScores);
    
    % CrossOver Mutation
    options = optimoptions(options,'CrossoverFcn',@crossoverscattered);
    options = optimoptions('ga','SelectionFcn',@selectionstochunif);
    options = optimoptions(options,'CrossoverFraction',0.8);
    options = optimoptions(options,'MutationFcn', @mutationadaptfeasible);
    
    % Plot And Display
    if plot == true
        options = optimoptions(options,'Display', 'off');
        options = optimoptions(options,'PlotFcn', {@gaplotbestf  ...
            @(options,state,flag) plotelitePop(options,state,flag,eliteC,'Elites') ...
            @(options,state,flag) plotelitePop(options,state,flag,pop,'Population')});
    end
    if dsp == true
        options = optimoptions(options,'Display', 'iter');
    end
    % Save Pop
    if save ==true
        options = optimoptions(options,'OutputFcn',{@(state,options,optchanged) ga_save_each_gen(name,state, ...
            options,optchanged,pop,'Population') ,@(state,options,optchanged) ga_save_each_gen(name,state, ...
            options,optchanged,eliteC,'Elites')});
    end

    %% INPUT Variables
    nvars = 7; 
    % 'layer_height (mm)', 'wall_thickness (mm)', 'infill_density (%)'
    % 'nozzle_temperature (0C)', 'print_speed (mm/s)', 'material; 'fan_speed (%)',
    lb = [0.02  1   10  200  40     0   0];
    ub = [0.2   10  90  250  120    1   100];
    %intcon = (6);
    %% RUN
    [x,fval,exitflag,output,population,score] = ga(@(x) objFun(x,w1,w2,w3),nvars,[],[],[],[],lb,ub,[],[],options);
    end

%% Save State
function [state,options,optchanged]=ga_save_each_gen(name,options,state,flag,eliteC,Pname)
        optchanged=false;
        if(strcmp(flag,'iter')) 
            [~,idx]=sort(state.Score,'ascend');
            Score_gen=state.Score(idx(1:eliteC)');
            Population_gen =state.Population(idx(1:eliteC)',:);
            Generation_gen=state.Generation;
            save([name Pname num2str(Generation_gen,'%.4d') '.mat'],'Score_gen','Population_gen','Generation_gen')     
        end
end