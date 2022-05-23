function [cell, kappa, dist] = CellCurvature(vtx, cell, INIT_VER, flag)

% flag, 1: angle based, 2: spline based
if flag==1

   
elseif flag==2
    % This version is based on a spline-curvature calculation. added on
    % 201118
    
    clist = cell.cell';
    if INIT_VER>=3
        clist(find(clist==0))=1; % this is a mock index
    end
    tmp=cell.vtx(clist(:),2:3)'; % (2:3)というのは、basalの曲率をとるということ。
    vlist=reshape(tmp(:),[4,cell.numb])';
    
    % 2-1: move to origin
    ptx = vtx.pos(vlist',1) - repelem(vtx.pos(vlist(:,1),1),4);
    pty = vtx.pos(vlist',2) - repelem(vtx.pos(vlist(:,1),2),4);
    ptx = reshape(ptx,[4,cell.numb])';
    pty = reshape(pty,[4,cell.numb])';
    
    x = 0.5*(ptx(:,2)+ptx(:,3));
    y = 0.5*(pty(:,2)+pty(:,3));
    
    % 2-2: Rotate
    vecx=ptx(:,4)-ptx(:,1);
    vecy=pty(:,4)-pty(:,1);
    theta = atan2(vecy, vecx);
    
    rot_ptx = cos(theta).*ptx + sin(theta).*pty;
    rot_pty = -sin(theta).*ptx + cos(theta).*pty;
    
    % 2-3: Take the measurement point
    org_x = 0.5*(rot_ptx(:,2)+rot_ptx(:,3));
    org_y = 0.5*(rot_pty(:,2)+rot_pty(:,3));
    
    % 2-3: Spline -- ここでfor loopを使うのがいやなところ。。
    if INIT_VER==0 || INIT_VER==1
        for i=1:cell.numb
            pp = spline(rot_ptx(i,:),rot_pty(i,:));
            a(i,1) = pp.coefs(2,1);
            b(i,1) = pp.coefs(2,2);
            c(i,1) = pp.coefs(2,3);
        end
    elseif INIT_VER>=3
        for i=1:cell.numb
            if i==1 || i==cell.initnumb
                a(i,1)=0.0; b(i,1)=0.0; c(i,1)=0.0;
            else
                pp = spline(rot_ptx(i,:),rot_pty(i,:));
                a(i,1) = pp.coefs(2,1);
                b(i,1) = pp.coefs(2,2);
                c(i,1) = pp.coefs(2,3);
            end
        end
    end
    
    upper=(6*a.*(org_x - rot_ptx(:,2)) + 2.*b);
    lower=power(1 + power(3*a.*power(org_x - rot_ptx(:,2),2) + 2*b.*(org_x - rot_ptx(:,2)) + c, 2), 1.5);
    
    cell.curv = upper./lower;

end

end