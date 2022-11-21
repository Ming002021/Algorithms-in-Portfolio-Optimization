%Read the indices2 file
indices= readtable('indices2.csv','PreserveVariableNames',true);%read table
ind_mat=table2array(indices(:,2:end));%convert the table into matrix
%Assets name
index={'S&P100', 'S&P500', 'S&P SmallCap 600', 'Dow Jones', 'NASDAQ Composite', 'Russell 2000', 'Barron 400', 'Wilshire 5000'};
%Transform into weekly return rates
n_col = size(ind_mat,2);
m_row = size(ind_mat,1);
ret = zeros(m_row-1,n_col);
for i=1:m_row-1
    for j=1:n_col
        ret(i,j)=ind_mat(i+1,j)/ind_mat(i,j);
    end 
end
dates = table2array(indices(:,1)); % convert the first column of dates to an array
qtr = quarter(dates);
dateYear=dates;
dateYear.Format='yyyy';
Year=str2num(char(dateYear));
%count the number of data points of each quarter of each year
count_number=[];
for i=2013:2019
    for j=1:4
        num=size(find( qtr(:)==j& Year(:)==i),1);
        count_number=[count_number num];
    end 
end
disp(count_number);
%Caulate the geo mean of return rates of each quarter of each year
geo_mean_perQY=[];

geo_mean_1_2013=geo_mean(ret(1:13,:));
geo_mean_4_2019=geo_mean(ret(353:364,:));

for i=2:27
    h=sum(count_number(1:i-1))+1;
    t=sum(count_number(1:i));
    ret_mat_1=ret(h:t,:);
    geo_mean_1=geo_mean(ret_mat_1);
    geo_mean_perQY=[geo_mean_perQY;geo_mean_1];
end

geo_mean_perQY=[geo_mean_1_2013;geo_mean_perQY;geo_mean_4_2019];
%Calculate the geo mean and standard deviation of return rates
geo_mean_perQ=[];
std_perQ=[];
for i=1:4
    mat=[];
    for j=i:4:28
        mat=[mat;geo_mean_perQY(j,:)];
    end
    gep_m_Q=geo_mean(mat);
    std_Q=std(mat);
    geo_mean_perQ=[geo_mean_perQ;gep_m_Q];
    std_perQ=[std_perQ;std_Q ];
end
ret_mu_perQ=geo_mean_perQ;
%Probability of scenarios
prob=[0.10 0.04 0.07 0.12 0.20 0.15 0.05 0.13 0.08 0.06];
%number of scenarios
m=10;
%number of index
n=8;
%number of time periods
T=4;
%the return rate matrix of each scenario
ret_sce1=[];ret_sce2=[];ret_sce3=[];ret_sce4=[];ret_sce5=[];
ret_sce6=[];ret_sce7=[];ret_sce8=[];ret_sce9=[];ret_sce10=[];
for i=1:m
    if(i==1)
        ret_sce1=ret_mu_perQ-8.* std_perQ;
    elseif(i==2)
        ret_sce2=ret_mu_perQ-3.* std_perQ;
    elseif(i==3)
        ret_sce3=ret_mu_perQ-2.* std_perQ;
    elseif(i==4)
       ret_sce4=ret_mu_perQ-1.5.* std_perQ;
    elseif(i==5)
        ret_sce5=ret_mu_perQ-std_perQ;
    elseif(i==6)
        ret_sce6=ret_mu_perQ;
    elseif(i==7)
        ret_sce7=ret_mu_perQ+std_perQ;
   elseif(i==8)
        ret_sce8=ret_mu_perQ+1.5.* std_perQ;
   elseif(i==9)
        ret_sce9=ret_mu_perQ+2.* std_perQ;
  else
        ret_sce10=ret_mu_perQ+3.* std_perQ;
  end
end
%the return rate matrix of each time period of all scenarios
rer_q1_sce=[ret_sce1(1,:);ret_sce2(1,:);ret_sce3(1,:);ret_sce4(1,:);ret_sce5(1,:);
    ret_sce6(1,:);ret_sce7(1,:);ret_sce8(1,:);ret_sce9(1,:);ret_sce10(1,:)];
rer_q2_sce=[ret_sce1(2,:);ret_sce2(2,:);ret_sce3(2,:);ret_sce4(2,:);ret_sce5(2,:);
    ret_sce6(2,:);ret_sce7(2,:);ret_sce8(2,:);ret_sce9(2,:);ret_sce10(2,:)];
rer_q3_sce=[ret_sce1(3,:);ret_sce2(3,:);ret_sce3(3,:);ret_sce4(3,:);ret_sce5(3,:);
    ret_sce6(3,:);ret_sce7(3,:);ret_sce8(3,:);ret_sce9(3,:);ret_sce10(3,:)];
rer_q4_sce=[ret_sce1(4,:);ret_sce2(4,:);ret_sce3(4,:);ret_sce4(4,:);ret_sce5(4,:);
    ret_sce6(4,:);ret_sce7(4,:);ret_sce8(4,:);ret_sce9(4,:);ret_sce10(4,:)];
%the covaraince matrix of each time period
Sigma_q1=findcovar(rer_q1_sce,prob);
Sigma_q2=findcovar(rer_q2_sce,prob);
Sigma_q3=findcovar(rer_q3_sce,prob);
Sigma_q4=findcovar(rer_q4_sce,prob);

% the expected return of each time period
mu_q1=geo_mean(rer_q1_sce);
mu_q2=geo_mean(rer_q2_sce);
mu_q3=geo_mean(rer_q3_sce);
mu_q4=geo_mean(rer_q4_sce);


function Sigma=findcovar(ret,prob)
%Covaraince matrix
n=size(ret,2);
m=size(ret,1);
Sigma=zeros(n,n);
%The mu
mu_pro=prob*ret;
%Lower triangular
for i=1:n
    for j=1:i
        diff=[(ret(:,i)-mu_pro(i)),(ret(:,j)-mu_pro(j))];
        vec=diff(:,1).*diff(:,2);
        Sigma(i,j)=prob*vec;
    end
end
Sigma=Sigma+triu(Sigma',1);
end


 
