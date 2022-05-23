function r=InitialVerticesSeeding(initprm, INIT_VER)

if INIT_VER==0
    % ver.1 -- circle
    x1 = initprm.r1*cos([0:2*pi/initprm.cnumb:2*pi*(1-1/initprm.cnumb)]);
    y1 = 1.0*initprm.r1*sin([0:2*pi/initprm.cnumb:2*pi*(1-1/initprm.cnumb)]);
    x2 = initprm.r2*cos([0:2*pi/initprm.cnumb:2*pi*(1-1/initprm.cnumb)]);
    y2 = 1.0*initprm.r2*sin([0:2*pi/initprm.cnumb:2*pi*(1-1/initprm.cnumb)]);
    r.x = reshape([x1' x2']',1,2*initprm.cnumb);
    r.y = reshape([y1' y2']',1,2*initprm.cnumb);
    
elseif INIT_VER==2
    % ver.2 -- semi-circle
    x1 = initprm.r1*cos([0:pi/initprm.cnumb:pi*(1-1/initprm.cnumb)+pi/initprm.cnumb]);
    y1 = 1.0*initprm.r1*sin([0:pi/initprm.cnumb:pi*(1-1/initprm.cnumb)+pi/initprm.cnumb]);
    x2 = initprm.r2*cos([0:pi/initprm.cnumb:pi*(1-1/initprm.cnumb)+pi/initprm.cnumb]);
    y2 = 1.0*initprm.r2*sin([0:pi/initprm.cnumb:pi*(1-1/initprm.cnumb)+pi/initprm.cnumb]);
    r.x = reshape([x1' x2']',1,2*(initprm.cnumb+1));
    r.y = reshape([y1' y2']',1,2*(initprm.cnumb+1));    
    
elseif INIT_VER==3
    x1=[0:initprm.width:initprm.cnumb*initprm.width];
    y1=-ones(1,initprm.cnumb+1)*0.5*initprm.height;
    y2=ones(1,initprm.cnumb+1)*0.5*initprm.height;
    r.x = reshape([x1' x1']', 1, 2*(initprm.cnumb+1));
    r.x = r.x-max(r.x)*0.5;
    r.x = flip(r.x);
    r.y = reshape([y1' y2']', 1, 2*(initprm.cnumb+1));
    
elseif INIT_VER==4
    theta1=pi/2/initprm.n1;
    theta2=pi/2/initprm.n2;
    
    r1=0.5/(sin(0.5*theta1));
    r2=0.5/(sin(0.5*theta2));
    
    rl1=r1-initprm.h; % l means lower
    ru1=r1+initprm.h; % u means upper
    rl2=r2+initprm.h;
    ru2=r2-initprm.h;
    
    i1=[-pi/2:theta2:0];
    xl1=rl2*cos(i1);
    yl1=rl2*sin(i1)+r2;
    xu1=ru2*cos(i1);
    yu1=ru2*sin(i1)+r2;
    
    i2=[pi:-theta1:0];
    xl2=rl1*cos(i2)+r1+r2;
    yl2=rl1*sin(i2)+r2;
    xu2=ru1*cos(i2)+r1+r2;
    yu2=ru1*sin(i2)+r2;
    
    xl2(1)=[];yl2(1)=[];
    xu2(1)=[];yu2(1)=[];
    xl2(end)=[];yl2(end)=[];
    xu2(end)=[];yu2(end)=[];
    
    i3=[-pi:theta2:-pi/2];
    xl3=rl2*cos(i3)+2*(r1+r2);
    yl3=rl2*sin(i3)+r2;
    xu3=ru2*cos(i3)+2*(r1+r2);
    yu3=ru2*sin(i3)+r2;
    
    xl=[xl1';xl2';xl3'];
    yl=[yl1';yl2';yl3'];
    xu=[xu1';xu2';xu3'];
    yu=[yu1';yu2';yu3'];
    
    r.x=[xl';xu'];
    r.y=[yl';yu'];
    
    r.x=r.x(:)';
    r.y=r.y(:)';
end

end
