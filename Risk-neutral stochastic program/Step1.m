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
disp(size(count_number,2));
%size(count_number,2)=28
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

%The cost c and the penalty cost b
c=[0.45 1.15 0.65 0.8 1.25 1.1 0.9 0.7];
b=[1.3 2.5 1.75 3.25];
x_0=[1/8 1/8 1/8 1/8 1/8 1/8 1/8 1/8];
N=50;
m=4;
%Calculate R_t
Rt=[];
for i=1:4
    Rt_lam=min( geo_mean_perQ(i,:))+0.35*(max( geo_mean_perQ(i,:))-min( geo_mean_perQ(i,:)));
    Rt=[Rt Rt_lam];
end
Target=Rt';
x_0=[1/4 1/4 1/4 1/4 0 0 0 0 ]';




Rt=Rt';