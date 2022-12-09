function state=plotelitePop(options,state,flag,eliteC,name) 
    [~,idx]=sort(state.Score,'ascend');
    data =state.Population(idx(1:eliteC)',:);
    % Each data row corresponds to an elite
    % data columns correspond to design variables' values
   
    maxs = ones(length(data(1,:)),1);
    mins = ones(length(data(1,:)),1);
    means = ones(length(data(1,:)),1);
    yneg = ones(length(data(1,:)),1);
    ypos = ones(length(data(1,:)),1);

    lb = [0.02  1   10  200  40     0   0];
    ub = [0.2   10  90  250  120    1   100];

    %{ 
    for foo = 1:length(data(:,1))
        for barr = 1:length(data(1,:))
            data(foo,barr) = (data(foo,barr)-lb(barr))/(ub(barr)-lb(barr))
        end
    end
    %} 
    data = (data -  repmat(lb,length(data(:,1)),1))./(repmat(ub,length(data(:,1)),1)-repmat(lb,length(data(:,1)),1));

    for it = 1:length(data(1,:))
        maxs(it) = max(data(:,it));
        mins(it) = min(data(:,it));
        means(it) = mean(data(:,it));
        yneg(it) = means(it)-mins(it);
        ypos(it) = maxs(it)-means(it);
    end

    x = 1:7;
    y = means;
    
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
    
    title([name ' Statistics'])
    xlabel('Design Variables')
    ylabel('Value')