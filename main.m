% This source code was used for the study by Hirashima and Matsuda

clear
close all

addpath('func_vtx')

%% Initial configuration
INIT_VER=1; %0: circle, 1: image import (closed), 2: semi-circle, 3: linear(Fixed-end), 4: curved(Fixed-end), 5: image import(Fixed-end)
[initprm, init_window, r] = InitialConfiguration(INIT_VER);

%% Parameter settings
dt=0.01;
time_max=100001;

% Vertex model
VERTEX_ANGLE = 1; % 0 or 1 - required when luminal pressure effect is calculated
prm.area = 0.01; % 0.01 
prm.cell_bend = 20; % 20
prm.apical = 1.0; % >0, for spring constraint
prm.lateral = 0.2; % >0, for spring constraint
prm.lumpre = 0.05; % 0.05, Parameter for Luminal pressure
prm.outward = 0.0; % (option) Parameter for Outward migration

% Chemical reactions -- ERK & F-actin
dF = 0.001;
rho = 1.0;
beta = 0.0;
zeta = 3; 
gamma = 100; 

%% Cell Division
DIVISION=1;
initprm.cell_cycle_length=300;
prm.cell_cycle_length=initprm.cell_cycle_length;
cycle_thr=0.0; % curvature threshold for the cell cycle arrest

%% Hit search
APhit = 1; % hit evaluation in Apical side
BShit = 1; % hit evaluation in Basal side


%% Initial vertices seeding
if INIT_VER==0 || INIT_VER==2 || INIT_VER==3
    r=InitialVerticesSeeding(initprm, INIT_VER);
end
[cell,edge,vtx,tie]=InitialSetting2DMonolayer(initprm, r, INIT_VER);

%% Misc settings
prm.target_area=mean(cell.area);
prm.target_perim=mean(cell.perim);

edge.prm_edge = zeros(edge.numb,1);
edge.prm_edge(find(edge.type==1))=prm.apical;
edge.prm_edge(find(edge.type==2))=prm.lateral;

cell.prm_area(1:cell.numb,1) = prm.area;

%% pre-registration
cell=CellCurvature_Basal(vtx, cell, INIT_VER, 2); % flag, 1: angle based, 2: spline based
if VERTEX_ANGLE==1
    vtx=VertexAngle(vtx, 1, INIT_VER); % flag - 1: apical, 2: basal, 3: both(apical&basal)
end

%% Order fields of structure array
initprm = orderfields(initprm);
prm = orderfields(prm);
vtx = orderfields(vtx);
edge = orderfields(edge);
cell = orderfields(cell);

%% ~~~~~~~~~~~~ Dynamics ~~~~~~~~~~~~ %%
tic
for t=1:round(time_max/dt)
    
    time=t*dt;
    
    %% Calculation of Forces
    vtx = CalculationOfForces(vtx, cell, edge, prm, INIT_VER, APhit, BShit);
    
    %% F-actin dynamics
    els1=find(edge.type==1);
    cls=edge.cell(els1);
    
    lst = find(cell.curv(cls)>0);
    tmp_curv = zeros(size(cls));
    tmp_curv(lst) = cell.curv(lst);
    
    d_Factin = rho*tanh(gamma*tmp_curv) + beta - dF*cell.Factin;
    cell.Factin = cell.Factin + d_Factin * dt;
    cell.Factin(find(cell.Factin>=1))=1.0;
    edge.target_dist(els1) = zeta * cell.Factin(cls) + edge.original_length_apical;
    
    
    %% Update of vertex positions
    vtx.pos = vtx.pos + vtx.force*dt;
    
    cell=GetCellPosition(vtx,cell);
    cell=GetCellArea(vtx,cell);
    edge=GetEdgeDistance(cell,edge,vtx);
    
    
    %% Visualization
    if mod(time,10)==0
        disp(['time: ', num2str(time)])
        Visualization(cell, edge, vtx, prm, init_window, INIT_VER, 1);
    end
    
    %% CellCycle -- Note that the "CellCycle" should be ahead of "Curvature in monolayer"
    if DIVISION==1 && mod(time,1)==0
        cell = DivisionSwitch(cell, cycle_thr, INIT_VER);
        
        % Cell Cycle
        cell=AddTimer(cell, 2); % flag: 1->non-conditional, 2->depends on 'cell.div'
        
        list=find(cell.timer>initprm.cell_cycle_length);
        numb=numel(list);
        
        for n=1:numb
            cid=list(n);
            [cell,edge,vtx]=CellDivision2DMonolayer(cid,cell,edge,vtx,prm,INIT_VER);
            
            if mod(cell.numb,1)==0
                disp(['cell number: ', num2str(cell.numb)])
            end
            
        end
    end
    
    
    %% Vertex curvature in monolayer
    if VERTEX_ANGLE==1
        vtx=VertexAngle(vtx, 1, INIT_VER); % flag - 1: apical, 2: basal, 3: both(apical&basal)
    end
    
    %% Cell curvature in monolayer
    if mod(time,1)==0
        [cell]=CellCurvature_Basal(vtx, cell, INIT_VER, 2);
    end
    
end
