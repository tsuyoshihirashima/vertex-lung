function vertex=InitialVertexVertex(cell,vertex)

for i=1:vertex.numb
    c_list = vertex.cell(i,:);
    
    cnt=1; vtx_list=[];
    for j=1:sum(c_list>0)
        vtx_tmp = cell.vtx(c_list(j),:);
        k = find(i==vtx_tmp);
        len = length(vtx_tmp);
        
        if k==1
            vtx_list(cnt) = vtx_tmp(len);
            vtx_list(cnt+1) = vtx_tmp(k+1);
        elseif k==len
            vtx_list(cnt) = vtx_tmp(k-1);
            vtx_list(cnt+1) = vtx_tmp(1);
        else
            vtx_list(cnt) = vtx_tmp(k-1);
            vtx_list(cnt+1) = vtx_tmp(k+1);
        end
        cnt = cnt+2;
    end
    ls = unique(vtx_list);
    len=length(ls);
    vertex.vtx(i,1:len) = ls;
end

end
