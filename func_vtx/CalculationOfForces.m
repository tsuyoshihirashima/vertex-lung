function vtx = CalculationOfForces(vtx, cell, edge, prm, INIT_VER, APhit, BShit)

vtx = AreaForce(cell,vtx);
vtx = ApicalEdgeForce(edge,vtx,2);
vtx = LateralEdgeForce(edge,vtx,1);
vtx = CellSpontBendingForce(vtx,cell,prm,INIT_VER);
vtx = LuminalPressure(vtx, prm); % f_luminal

%% Avoid hitting vertices each other
if APhit==1 || BShit==1
    vtx.f_hitavoid = zeros(vtx.numb,2);
    vtx = HitAvoid(vtx, APhit, BShit);
end

%% Force calculation
vtx.force = vtx.f_area + vtx.f_apicaledge + vtx.f_lateraledge + vtx.f_cellcurv + vtx.f_luminal + vtx.f_hitavoid;

%% For fixed boundaries
if INIT_VER>=3
    vtx.force(1:2,2)=0.0;
    vtx.force(vtx.initnumb-1:vtx.initnumb,2)=0.0;
end


end
