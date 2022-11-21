%Here are the optput of portfolios when fix the target return
%m=4,N=50,lambta=0.5
p1=[0.2500   0.0000    0.0500    0.2717    0.0000    0.0000    0.1566    0.2717];
%m=4,N=100,lambta=0.5
p2=[0.2275   0.0000    0.0725    0.2819   0.0000    0.0000    0.1362    0.2819];
%m=4,N=200,lambta=0.5
p3=[0.2464   0.0000    0.0536    0.2798   0.0000    0.0000    0.1405   0.2798];
portfolio=[p1;p2;p3]';

mu_q1=geo_mean_perQ(1,:);
mu_q2=geo_mean_perQ(2,:);
mu_q3=geo_mean_perQ(3,:);
mu_q4=geo_mean_perQ(4,:);
Exp_Q1=mu_q1*portfolio;% The expected return of quarter 1 of each portfolio
Exp_Q2=mu_q2*portfolio;% The expected return of quarter 2 of each portfolio
Exp_Q3=mu_q3*portfolio;
Exp_Q4=mu_q4*portfolio;


assets={'S&P100', 'S&P500', 'S&P SmallCap 600', 'Dow Jones', 'NASDAQ Composite', 'Russell 2000', 'Barron 400', 'Wilshire 5000'};

barplot(Exp_Q1,portfolio',assets,'Quarter 1');
barplot(Exp_Q2,portfolio',assets,'Quarter 2');
barplot(Exp_Q3,portfolio',assets,'Quarter 3');
barplot(Exp_Q4,portfolio',assets,'Quarter 4');

composition(Exp_Q1,portfolio,'% Target Return',assets,'Quarter 1'); 
composition(Exp_Q2,portfolio,'% Target Return',assets,'Quarter 2'); 
composition(Exp_Q3,portfolio,'% Target Return',assets,'Quarter 3'); 
composition(Exp_Q4,portfolio,'% Target Return',assets,'Quarter 4'); 


function composition(ExpRet,X,x_label,assets,time)
PercRet = 100*([ExpRet] - 1);

figure;
area(PercRet(1,:),X');
title( ['Composition of Efficient Portfolios ' ' and time is ' time  ] )
 
xlabel('%Expected return');
ylabel('% Investement in each asset');
legend(assets);

end  

function barplot(ExpRet,X,assets,time)
PercRet = 100*([ExpRet] - 1);
x = PercRet;
P=X;
figure;
bar(x, P, 'stacked')
legend(assets);
title( ['Composition of Efficient Portfolios ' ' and time is ' time  ] )
 
xlabel('%Expected return');
ylabel('% Investement in each asset');
legend(assets);

end  
