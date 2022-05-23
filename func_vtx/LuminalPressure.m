function vtx = LuminalPressure(vtx, prm)
% 190716

vls = [1:2:vtx.numb]'; % apical side
vtx.f_luminal(vls,1:2) = prm.lumpre .* vtx.n_norm_vec(vls,1:2);

end