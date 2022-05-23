function [r, cell_number] = ImportImage(height, width, d_len)

%%
filename = 'sample_lung_binary.tif';
info = imfinfo(filename);
img=double(imread(filename))/255;
bw = bwmorph(img,'skel');
%figure, imshow(bw)

%%
[row1 col1]=find(bw==1);

right=max(col1);
left=min(col1);
middle=floor(mean(col1));

%% sort and combine
listL=find(col1<middle);
row_L=row1(listL);col_L=col1(listL);
L=[row_L col_L];
L=sortrows(L,[1 2],{'descend' 'descend'});
%figure, plot(L(:,2),L(:,1));

listR=find(col1>=middle);
row_R=row1(listR);col_R=col1(listR);
R=[row_R col_R];
R=sortrows(R,[1 2],{'ascend' 'descend'});
%figure, plot(R(:,2),R(:,1));

table=[R;L];
row1=table(:,1);
col1=table(:,2);


%% 
mag=d_len/(right-left);
row2=row1*mag; col2=col1*mag;

c_row2=circshift(row2,-1);
c_col2=circshift(col2,-1);

dist = sqrt((row2-c_row2).*(row2-c_row2) + (col2-c_col2).*(col2-c_col2));
dist(end)=[];
dist_sum=cumsum(dist);

tmp_max_cell=floor(dist_sum(end)/width);
rest = rem(dist_sum(end),width);

for i=1:tmp_max_cell+1
    [tmp l]=min(abs(dist_sum - ((i-1)*width + (rest+row1(1))*0.5)));
    list(i)=l;
end

%{
figure, plot(col2,row2)
hold on
plot(col2(list),row2(list),'o')
hold off
%}

%% Center line
geta=width-(row2(list(1))+row2(list(end)))*0.5;
len=length(list);
line_x(2:len+1)=col2(list)-middle*mag;
line_y(2:len+1)=row2(list)+geta;
line_x(1)=line_x(2);
line_y(1)=0.0;
line_x(end+1)=line_x(end);
line_y(end+1)=0.0;

%% apical and basal lines
c_line_x = circshift(line_x,-1);
c_line_y = circshift(line_y,-1);

vec_x=(line_x-c_line_x); vec_x(end)=[];
vec_y=(line_y-c_line_y); vec_y(end)=[];

tmpvec_y= -(vec_x + circshift(vec_x,-1)); tmpvec_y(end)=[];
tmpvec_x= (vec_y + circshift(vec_y,-1)); tmpvec_x(end)=[];

norm=sqrt(tmpvec_x.*tmpvec_x + tmpvec_y.*tmpvec_y);
norm_vec_x=tmpvec_x./norm;
norm_vec_y=tmpvec_y./norm;

ap_x=line_x; ap_y=line_y;
bs_x=line_x; bs_y=line_y;

ap_x(1)=ap_x(1)-height*0.5; ap_y(1)=0.0;
bs_x(1)=bs_x(1)+height*0.5; bs_y(1)=0.0;

ap_x(end)=ap_x(end)+height*0.5; ap_y(end)=0.0;
bs_x(end)=bs_x(end)-height*0.5; bs_y(end)=0.0;

len=length(ap_x);

for i=2:len-1
    ap_x(i) = ap_x(i) + norm_vec_x(i-1)*height*0.5;
    ap_y(i) = ap_y(i) + norm_vec_y(i-1)*height*0.5;
    
    bs_x(i) = bs_x(i) - norm_vec_x(i-1)*height*0.5;
    bs_y(i) = bs_y(i) - norm_vec_y(i-1)*height*0.5;
end

%{
figure,
hold on
plot(ap_x,ap_y)
plot(bs_x,bs_y)
hold off
%}

tmp_x=[ap_x;bs_x];
tmp_y=[ap_y;bs_y];

r.x=tmp_x(:)';
r.y=tmp_y(:)';

r.x = r.x + 0.01*(rand(1,length(r.x))-0.5);
r.y = r.y + 0.01*(rand(1,length(r.y))-0.5);

r.y(1:2)=0.0;
r.y(end-1:end)=0.0;

cell_number=len-1;
end