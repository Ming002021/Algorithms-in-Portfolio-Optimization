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
%the return rate matrix of scenario 1
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
%The cost c and the penalty cost b
c=[0.45 1.15 0.65 0.8 1.25 1.1 0.9 0.7];
b=[1.3 2.5 1.75 3.25];
%Target return
Target=[0:0.05:1.0];
%%CVar
beta=0.9;
alpha=[1 10 50];
%Call the function
riskNeutral(Target,index,m,n,T,c,b,prob,geo_mean_perQ,ret_sce1,ret_sce2,ret_sce3,ret_sce4,ret_sce5,ret_sce6,ret_sce7,ret_sce8,ret_sce9,ret_sce10);


%%%Function of risk-neutral stochastic linear program 
function X=riskNeutral(Target,index,m,n,T,c,b,prob,geo_mean_perQ,ret_sce1,ret_sce2,ret_sce3,ret_sce4,ret_sce5,ret_sce6,ret_sce7,ret_sce8,ret_sce9,ret_sce10)
 
X=[];
Exp_Q1=[];
Exp_Q2=[];
Exp_Q3=[];
Exp_Q4=[];
for r=1:length(Target)
    %Calculate R_t
    Rt=[];
    for i=1:4
        Rt_lam=min( geo_mean_perQ(i,:))+Target(r)*(max( geo_mean_perQ(i,:))-min( geo_mean_perQ(i,:)));
        Rt=[Rt Rt_lam];
    end
    Rt=Rt';
    cvx_begin
        variable x(n);
        variable y1(T);variable y2(T);
        variable y3(T);variable y4(T);variable y5(T);
        variable y6(T);variable y7(T);variable y8(T);
        variable y9(T);variable y10(T);variable y(m);
        minimize c*x+prob*y
        y==[b*y1;b*y2;b*y3;b*y4;b*y5;b*y6;b*y7;b*y8;b*y9;b*y10];
        ret_sce1*x+y1 >= Rt;ret_sce2*x+y2 >= Rt;
        ret_sce3*x+y3 >= Rt;ret_sce4*x+y4 >= Rt;
        ret_sce5*x+y5 >= Rt;ret_sce6*x+y6 >= Rt;
        ret_sce7*x+y7 >= Rt;ret_sce8*x+y8 >= Rt;
        ret_sce9*x+y9 >= Rt;ret_sce10*x+y10 >= Rt;
        ones(1,n)*x==1;
        x >= 0;
        y >= 0;
        y1,y2,y3,y4,y5,y6,y7,y8,y9,y10 >= 0;
    cvx_end

    X=[X x];
    Exp_Q1=[Exp_Q1 geo_mean_perQ(1,:)*x];
    Exp_Q2=[Exp_Q2 geo_mean_perQ(2,:)*x];
    Exp_Q3=[Exp_Q3 geo_mean_perQ(3,:)*x];
    Exp_Q4=[Exp_Q4 geo_mean_perQ(4,:)*x];
     
     
end
 composition(Exp_Q1,X,Target,'% Target Return',index)
 composition(Exp_Q2,X,Target,'% Target Return',index)
 composition(Exp_Q3,X,Target,'% Target Return',index)
 composition(Exp_Q4,X,Target,'% Target Return',index)
end

 
function composition(ExpRet,X,xaxis,x_label,assets)
PercRet = 100*([ExpRet;xaxis] - 1);
figure;
area(PercRet(2,:),X');
title('Composition of Efficient Portfolios');
xlabel(char(x_label));
ylabel('% Investement in each index');
legend(assets);
figure;
area(PercRet(1,:),X');
title('Composition of Efficient Portfolios');
xlabel('%Expected return of');
ylabel('% Investement in each asset');
legend(assets);
end

 
