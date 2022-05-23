function vtx = PerimeterForce(cell,vtx)

    % 180903 perim force calculation
    
    vl=cell.vtx;
    [row, col]=size(vl);
    
    len=sum(vl~=0,2);
    vid = sub2ind(size(vl), [1:cell.numb]', len); % (same) -> lid = (len-1)*cell.numb + i;
    
    % v_next
    v_next=circshift(vl,-1,2);
    v_next(vid)=vl(:,1); % Še×–E‚Ì’†‚ÌÅŒã‚Ìvid‚ÉA‚Í‚¶‚ß‚Ìvid‚ğ“ü‚ê‚éB
    
    % v_before
    v_before=circshift(vl,1,2);
    v_before(:,1)=vl(vid);
    
    % Calculation of force at each vertex on cells
    f_x1 = reshape( vtx.pos(vl,1) - vtx.pos(v_next,1), row, col) .* (vl>0);
    f_y1 = reshape( vtx.pos(vl,2) - vtx.pos(v_next,2), row, col) .* (vl>0); 
    f_x2 = reshape( vtx.pos(vl,1) - vtx.pos(v_before,1), row, col) .* (vl>0);
    f_y2 = reshape( vtx.pos(vl,2) - vtx.pos(v_before,2), row, col) .* (vl>0);
    dist1 = sqrt(f_x1.*f_x1 + f_y1.*f_y1);
    dist2 = sqrt(f_x2.*f_x2 + f_y2.*f_y2);
    f_x = f_x1./dist1 + f_x2./dist2;
    f_y = f_y1./dist1 + f_y2./dist2;
    
    param = repmat(cell.prm_perim,1,col);
    perim = repmat(cell.perim,1,col);
    tarperim = repmat(cell.target_perim,1,col);
    
    cfx = -param .* f_x.*(perim - tarperim);
    cfy = -param .* f_y.*(perim - tarperim);
    
    % Rearrange the vertices force for each vertex
    vl1 = vl(:);
    len1 = row*col;
    i = [1:len1]';
    
    vtabx = zeros(len1, vtx.numb);
    vtaby = zeros(len1, vtx.numb);
    
    ls = (vl1-1)*len1 + i;
    cfx1=cfx(ls>0);
    cfy1=cfy(ls>0);
    ls1 = ls(ls>0);
    vtabx(ls1) = cfx1;
    vtaby(ls1) = cfy1;
    
    vtx.f_perim(1:vtx.numb,1)=sum(vtabx)';
    vtx.f_perim(1:vtx.numb,2)=sum(vtaby)';

end
