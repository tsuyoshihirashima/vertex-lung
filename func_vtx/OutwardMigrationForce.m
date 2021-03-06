function vtx = OutwardMigrationForce(vtx, cell, prm, INIT_VER)

%vls = [1:2:vtx.numb]'; % apical side
vls = [2:2:vtx.numb]'; % basal side
cls1 = vtx.cell(vls,1);
cls2 = vtx.cell(vls,2);

if INIT_VER>=3
    cls1(1)=1;
    cls2(vtx.initnumb/2)=cls2(vtx.initnumb/2-1);
end

% とりあへず、ERK活性の代わりにcell curvatureで代用している。
ave_mig = 0.5*(cell.curv(cls1) + cell.curv(cls2)); % vertexが属する細胞２つ分の平均をとる。
ave_mig(find(ave_mig<0))=0.0; % migration ability becomes zero when the ERK activity is negative

vtx.f_outward(vls,1:2) = prm.outward .* ave_mig .* vtx.n_norm_vec(vls,1:2); % vertexが属する細胞２つ分の平均をとる。

end