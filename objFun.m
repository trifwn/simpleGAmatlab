function w=objFun(data,w1,w2,w3)
    df = [data(:,1:5) round(data(:,6)) ~round(data(:,6)) data(:,7)];
    out = pyrunfile('ANN.py','z','df',df );
    out = double(out);
    rmax = 368;
    rmin = 21;
    umax = 37;
    umin = 4;
    emax = 3.3;
    emin = 0.4;
    w = w1*((out(:,1)-rmin)/(rmax-rmin))-w2*((out(:,2)-umin)/(umax-umin))-w3*((out(:,3)-emin)/(emax-emin));

