function vtx = HitAvoid(vtx, APhit, BShit)


% 181105 start
%% Parameters
thr_dist=5; % Threshold of distance
coeff=10^-8;

%% Apical side
if APhit == 1
    v.x=repmat(vtx.pos(1:2:vtx.numb,1),1,vtx.numb/2);
    v.y=repmat(vtx.pos(1:2:vtx.numb,2),1,vtx.numb/2);
    a.x=v.x.';
    a.y=v.y.';
    lst=vtx.vtx(1:2:vtx.numb,1);
    lst(find(lst==0))=1; % 201121 add
    b.x=repmat(vtx.pos(lst,1)',vtx.numb/2,1);
    b.y=repmat(vtx.pos(lst,2)',vtx.numb/2,1);
    
    dot1 = (b.x-a.x).*(v.x-a.x) + (b.y-a.y).*(v.y-a.y);
    dot2 = (a.x-b.x).*(v.x-b.x) + (a.y-b.y).*(v.y-b.y);
    
    isd = dot1.*dot2>0; % inside
    
    % put 0 in outside vertices
    v.x=isd.*v.x; v.y=isd.*v.y;
    a.x=isd.*a.x; a.y=isd.*a.y;
    b.x=isd.*b.x; b.y=isd.*b.y;
    
    len=sqrt((b.x-a.x).*(b.x-a.x) + (b.y-a.y).*(b.y-a.y));
    c.x = (b.x-a.x)./len; c.y = (b.y-a.y)./len;
    % NOTE: c and d includes Nan
    
    d.x = v.x-a.x- ( (v.x-a.x).*c.x + (v.y-a.y).*c.y ).*c.x;
    d.y = v.y-a.y- ( (v.x-a.x).*c.x + (v.y-a.y).*c.y ).*c.y;
    dist = sqrt( (d.x.*d.x)+(d.y.*d.y) );
    
    list = find(0<dist & dist<thr_dist);
    if ~isempty(list)
        [row col] = ind2sub(size(dist), list);
        
        f1.x = coeff * 3*thr_dist^6./dist(list).^7 .* (2*(thr_dist./dist(list)).^6 -1) .* d.x(list)./dist(list);
        f1.y = coeff * 3*thr_dist^6./dist(list).^7 .* (2*(thr_dist./dist(list)).^6 -1) .* d.y(list)./dist(list);
        
        vtx.f_hitavoid(2*row-1,1) = vtx.f_hitavoid(2*row-1,1) + f1.x;
        vtx.f_hitavoid(2*row-1,2) = vtx.f_hitavoid(2*row-1,2) + f1.y;
    end
end

if BShit == 1
    v.x=repmat(vtx.pos(2:2:vtx.numb,1),1,vtx.numb/2);
    v.y=repmat(vtx.pos(2:2:vtx.numb,2),1,vtx.numb/2);
    a.x=v.x.';
    a.y=v.y.';
    lst=vtx.vtx(2:2:vtx.numb,1);
    lst(find(lst==0))=1; % 201121 add

    b.x=repmat(vtx.pos(lst,1)',vtx.numb/2,1);
    b.y=repmat(vtx.pos(lst,2)',vtx.numb/2,1);
    
    dot1 = (b.x-a.x).*(v.x-a.x) + (b.y-a.y).*(v.y-a.y);
    dot2 = (a.x-b.x).*(v.x-b.x) + (a.y-b.y).*(v.y-b.y);
    
    isd = dot1.*dot2>0; % inside
    
    % put 0 in outside vertices
    v.x=isd.*v.x; v.y=isd.*v.y;
    a.x=isd.*a.x; a.y=isd.*a.y;
    b.x=isd.*b.x; b.y=isd.*b.y;
    
    len=sqrt((b.x-a.x).*(b.x-a.x) + (b.y-a.y).*(b.y-a.y));
    c.x = (b.x-a.x)./len; c.y = (b.y-a.y)./len;
    % NOTE: c and d includes Nan
    
    d.x = v.x-a.x- ( (v.x-a.x).*c.x + (v.y-a.y).*c.y ).*c.x;
    d.y = v.y-a.y- ( (v.x-a.x).*c.x + (v.y-a.y).*c.y ).*c.y;
    dist = sqrt( (d.x.*d.x)+(d.y.*d.y) );
    
    list = find(0<dist & dist<thr_dist);
    if ~isempty(list)
        [row col] = ind2sub(size(dist), list);
        
        f2.x = coeff * 3*thr_dist^6./dist(list).^7 .* (2*(thr_dist./dist(list)).^6 -1) .* d.x(list)./dist(list);
        f2.y = coeff * 3*thr_dist^6./dist(list).^7 .* (2*(thr_dist./dist(list)).^6 -1) .* d.y(list)./dist(list);
        
        vtx.f_hitavoid(2*row,1) = vtx.f_hitavoid(2*row,1) + f2.x;
        vtx.f_hitavoid(2*row,2) = vtx.f_hitavoid(2*row,2) + f2.y;
    end
end

%vtx.f_hitavoid(find(vtx.f_hitavoid>10))=0.0; % 190505試験的に導入してみた。
vtx.f_hitavoid(isnan(vtx.f_hitavoid))=0.0; % 190505試験的に導入してみた。

end
