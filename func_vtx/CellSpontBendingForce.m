%% SECTION TITLE
% 201112 start
function vtx = CellSpontBendingForce(vtx, cell, prm, INIT_VER)

% 'list' contains all vertex points
% 1st column denotes the focused vertex point
cv_list=sortrows([cell.vtx;circshift(cell.vtx,-1,2);circshift(cell.vtx,2,2);circshift(cell.vtx,1,2)],1);

if INIT_VER>=2
    % free edgeの場合には、端のvertex indexのdummyをつくる
    cv_list=[cv_list(1:1,:);cv_list(1,:);cv_list(2:end,:)]; % the row in vtx_index==1 is copied
    cv_list=[cv_list(1:3,:);cv_list(3,:);cv_list(4:end,:)]; % the row in vtx_index==2 is copied
    l=find(cv_list(:,1)==vtx.initnumb-1);
    cv_list=[cv_list(1:l,:); cv_list(l,:); cv_list(l+1:end,:)]; % the row in vtx_index==initnumb-1 is copied
    l=find(cv_list(:,1)==vtx.initnumb);
    cv_list=[cv_list(1:l,:); cv_list(l,:); cv_list(l+1:end,:)]; % the row in vtx_index==initnumb is copied
end

%% Vectors and Norms -- 021112 checked
% これはわかりやすさのため。
ls = cv_list(:,1); % The list for the focused vertex
rv = cv_list(:,2); % vertex list in the right side
rrv = cv_list(:,3); % vertex list in the right->right side
lv = cv_list(:,4); % vertex list in the left side
llv = cv_list(:,3); % vertex list in the left->left side

% Vectors
vec_l = vtx.pos(ls,:)-vtx.pos(lv,:); % vector from lv -> target vertex
vec_ll = vtx.pos(lv,:)-vtx.pos(llv,:); % vector from llv -> lv
vec_r = vtx.pos(rv,:)-vtx.pos(ls,:); % vector from target vertex -> rv
vec_rr = vtx.pos(rrv,:)-vtx.pos(rv,:); % vector from rv -> rrv

% Norm of the vectors -- wanted to use 'vecnorm' function but it does not work in ver. 2017
%{
d_vec_l = vecnorm(vec_l,2,2);
d_vec_ll = vecnorm(vec_ll,2,2);
d_vec_r = vecnorm(vec_r,2,2);
d_vec_rr = vecnorm(vec_rr,2,2);
%}
d_vec_l = sqrt(sum(vec_l.*vec_l,2));
d_vec_ll = sqrt(sum(vec_ll.*vec_ll,2));
d_vec_r = sqrt(sum(vec_r.*vec_r,2));
d_vec_rr = sqrt(sum(vec_rr.*vec_rr,2));

% Unit vectors
u_l = vec_l./d_vec_l;
u_ll = vec_ll./d_vec_ll;
u_r = vec_r./d_vec_r;
u_rr = vec_rr./d_vec_rr;

%% Angle calculation
angle_ls = pi - acos(dot(u_l,u_r,2));
angle_lv = pi - acos(dot(u_ll,u_l,2));
angle_rv = pi - acos(dot(u_r,u_rr,2));

%% Calculation of energy
%{
tmp_force = ...
    - (angle(2*lv)-0.5*pi)./sin(angle(2*lv)) .* (u_ll + cos(angle(2*lv)).*u_l)./d_vec_l ...
    - (angle(2*ls)-0.5*pi)./sin(angle(2*ls)) .* (u_r + cos(angle(2*ls)).*u_l)./d_vec_l ...
    + (angle(2*ls)-0.5*pi)./sin(angle(2*ls)) .* (u_l + cos(angle(2*ls)).*u_r)./d_vec_r ...
    + (angle(2*rv)-0.5*pi)./sin(angle(2*rv)) .* (u_rr + cos(angle(2*rv)).*u_r)./d_vec_r;
%}
tmp_force = ...
    - (angle_lv-0.5*pi)./sin(angle_lv) .* (u_ll + cos(angle_lv).*u_l)./d_vec_l ...
    - (angle_ls-0.5*pi)./sin(angle_ls) .* (u_r + cos(angle_ls).*u_l)./d_vec_l ...
    + (angle_ls-0.5*pi)./sin(angle_ls) .* (u_l + cos(angle_ls).*u_r)./d_vec_r ...
    + (angle_rv-0.5*pi)./sin(angle_rv) .* (u_rr + cos(angle_rv).*u_r)./d_vec_r;

l1 = (1:2:vtx.numb*2)';
l2 = (2:2:vtx.numb*2)';

vtx.f_cellcurv(1:vtx.numb,1:2) = prm.cell_bend * (tmp_force(l1,1:2) + tmp_force(l2,1:2));

% 固定端なら関係ないけどね。
if INIT_VER>=2
    vtx.f_cellcurv(1:2,:) = vtx.f_cellcurv(1:2,:)*0.5;
    vtx.f_cellcurv(vtx.initnumb-1:vtx.initnumb,:) = vtx.f_cellcurv(vtx.initnumb-1:vtx.initnumb,:)*0.5;
end

end