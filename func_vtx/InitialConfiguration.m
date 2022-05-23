function [initprm, init_window, r] = InitialConfiguration(INIT_VER)

initprm.height=20; % [É m] --fixed
initprm.width=5; % [É m] --fixed
d_len=70; % [É m] plausible range: 100-200 É m from the images; for INIT_VER==5, but 80-140É m

initprm.cnumb=40; % cell number except for INIT_VER==4,5
initprm.r1 = (initprm.width*initprm.cnumb/pi - initprm.height)*0.5; % inner radius, 2.0 before 190717
initprm.r2 = initprm.r1 + initprm.height;
init_window = initprm.r1*1;

initprm.noise = 0.01; % noise for the initial configuration

if INIT_VER==1
    [r,initprm.cnumb]=ImportImage(initprm.height,initprm.width,d_len);
    
    for s=1:2
        r.x(1:2*s)=[]; r.x(end-2*s+1:end)=[];
        r.y(1:2*s)=[]; r.y(end-2*s+1:end)=[];
    end
    r.y = r.y - (r.y(1)+r.y(2)+r.y(end)+r.y(end-1))*0.25;
    
    tmp_y = -reshape(r.y,[2 length(r.y)/2]);
    tmp_y(:,1)=0.0; tmp_y(:,end)=0.0; % zero adjustment
    tmp_x=fliplr(reshape(r.x,[2 length(r.x)/2]));
    
    tmp_x(:,1)=[]; tmp_x(:,end)=[]; % delete
    tmp_y(:,1)=[]; tmp_y(:,end)=[]; % delete
    
    tmp=r.x;
    r.x=-[r.y';tmp_y(:)]';
    r.y=[tmp';tmp_x(:)]';
    
    initprm.cnumb = length(r.x)*0.5;
    
    init_window=max(r.x)*1.5;
    
elseif INIT_VER==4
    % valid only when INIT_VER==4
    initprm.n1=15; % cell # in the center; note that this number correpsponds to the half
    initprm.n2=10; % cell # in the one edge;
    initprm.h=1; % cell height half, DO NOT CHANGE!
    initprm.cnumb=(initprm.n1+initprm.n2)*2;
    
elseif INIT_VER==5
    [r,initprm.cnumb]=ImportImage(initprm.height,initprm.width,d_len);
    init_window=max(r.x)*1.5;
end

end