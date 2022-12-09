function savePlotelites(pop,scores,eliteC,name,gname) 
    [~,idx]=sort(scores,'ascend');
    pop = pop(idx(1:eliteC)',:);
    % Each pop row corresponds to an elite
    % pop columns correspond to design variables' values
    maxs = ones(length(pop(1,:)),1);
    mins = ones(length(pop(1,:)),1);
    means = ones(length(pop(1,:)),1);
    yneg = ones(length(pop(1,:)),1);
    ypos = ones(length(pop(1,:)),1);

    lb = [0.02  1   10  200  40     0   0];
    ub = [0.2   10  90  250  120    1   100];

    pop = (pop -  repmat(lb,length(pop(:,1)),1))./(repmat(ub,length(pop(:,1)),1)-repmat(lb,length(pop(:,1)),1));

    for it = 1:length(pop(1,:))
        maxs(it) = max(pop(:,it));
        mins(it) = min(pop(:,it));
        means(it) = mean(pop(:,it));
        yneg(it) = means(it)-mins(it);
        ypos(it) = maxs(it)-means(it);
    end
    
    x = 1:7;
    X = categorical({'layer_height (mm)', 'wall_thickness (mm)', 'infill_density (%)' ...
        'nozzle_temperature (0C)', 'print_speed (mm/s)', 'material', 'fanspeed (%)'});
    %reordercats(x,{'layer_height (mm)', 'wall_thickness (mm)', 'infill_density (%)' ...
    %    'nozzle_temperature (0C)', 'print_speed (mm/s)', 'material', 'fan_speed (%)'});
    y = means;
   
    fig = figure('Name',gname,'NumberTitle','off','Visible','off');
    %figure(fig,'Visible','off')
    b = bar(means,1);
    b.FaceColor = 'flat';
    b.CData = [0.8 0.6 0.1];
   
    ylim([0 (max(maxs)+0.05)])
    xlim([0.5 7.5])
    
    hold on 
    xline(0.5,'LineWidth',2);
    xline(1.5,'LineWidth',2);
    xline(2.5,'LineWidth',2);
    xline(3.5,'LineWidth',2);
    xline(4.5,'LineWidth',2);
    xline(5.5,'LineWidth',2);
    xline(6.5,'LineWidth',2);
    xline(7.5,'LineWidth',2);
    err = errorbar(x,y,yneg,ypos,"s","MarkerSize",10,...
    "MarkerEdgeColor","blue","MarkerFaceColor",[1 0 0],'CapSize',50,'LineWidth',1.25, 'Color', "blue");
    hold off
    set(gca,'xticklabel',X)
    xtickangle(45)
    title(strjoin({gname ,'Statistics'}))
    xlabel('Design Variables')
    ylabel('Value')
    saveas(fig,name)