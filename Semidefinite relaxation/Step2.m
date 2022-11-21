%%get portfolio when m=7 for a range of target returns
m=7;
[portfolio,Exp_ret]= SDP(m,mu_q1,mu_q2,mu_q3, mu_q4,Sigma_q1,Sigma_q2,Sigma_q3,Sigma_q4);

assets={'S&P100', 'S&P500', 'S&P SmallCap 600', 'Dow Jones', 'NASDAQ Composite', 'Russell 2000', 'Barron 400', 'Wilshire 5000'};
X=portfolio;
ex_1=Exp_ret(1,:);
ex_2=Exp_ret(2,:);
ex_3=Exp_ret(3,:);
ex_4=Exp_ret(4,:);
barplot(ex_1,X,assets,'Q1');
barplot(ex_2,X,assets,'Q2');
barplot(ex_3,X,assets,'Q3');
barplot(ex_4,X,assets,'Q4');

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

%%%Function of SDP given m
%%% Given the expected return and covariance matix of each time period
function [portfolio,Exp_u]=SDP(m,mu_q1,mu_q2,mu_q3, mu_q4,Sigma_q1,Sigma_q2,Sigma_q3,Sigma_q4) %bench is the benchmark portfolio
xb=[1/8 1/8 1/8 1/8 1/8 1/8 1/8 1/8 ]';% the benchmark
assets={'S&P100', 'S&P500', 'S&P SmallCap 600', 'Dow Jones', 'NASDAQ Composite', 'Russell 2000', 'Barron 400', 'Wilshire 5000'};
mu_q=[mu_q1;mu_q2;mu_q3;mu_q4];
n=8;
%Target return
Target=[0:0.05:1.0];
K=length(Target);
portfolio=zeros(n,K);%Store all portfilos
Y=zeros(n,K);%Store all y
XX=cell(K,1);%cell array to store matrices X
z_s=[];%Store all z
target_q1=[];%Store all target return of quarter 1
target_q2=[];
target_q3=[];
target_q4=[];
cardinality=8;
for k=1:K
    %Calculate target return of each quarter Return
    Return=[];
    for i=1:4
        Rt_lam=min( mu_q(i,:))+Target(k)*(max( mu_q(i,:))-min( mu_q(i,:)));
        Return=[Return;Rt_lam];%Return:4 by 1 vector
    end
    target_q1=[target_q1 Return(1)];
    target_q2=[target_q2 Return(2) ];
    target_q3=[target_q3 Return(3) ];
    target_q4=[target_q4 Return(4) ];
    target_allq=[target_q1;target_q2;target_q3;target_q4];
    cvx_begin sdp quiet
        variable X(n,n) symmetric
        variable x(n) 
        variable y(n)  
        variable z

        minimize z
        mu_q*x >= Return;
        z >= trace(Sigma_q1*X)-2*xb'*Sigma_q1*x+xb'*Sigma_q1*xb;
        z >= trace(Sigma_q2*X)-2*xb'*Sigma_q2*x+xb'*Sigma_q2*xb;
        z >= trace(Sigma_q3*X)-2*xb'*Sigma_q3*x+xb'*Sigma_q3*xb;
        z >= trace(Sigma_q4*X)-2*xb'*Sigma_q4*x+xb'*Sigma_q4*xb;
        [1, x';x,X] == semidefinite(n+1);
        diag(X) <= x;
        for i=1:n
            X(:,i) >= 0;
        end
        sum(y) <= cardinality;
        sum(y) >= m;%Invests in at least m assets
        y(1)+y(2)+y(3) >=1;%Invest in at least one but no more than two of the S&P indices,
        y(1)+y(2)+y(3) <= 2;
        y(6)+y(7)+y(8) >= 1;%Invest in at least one of Russell, BarronIs or Wilshire.
        x >= (0.05*ones(n,1)).*y;%Any investments in indices at least 5%
        x(1)+x(2)+x(3) <= 0.3; % Three S&P indices together no more than 30%
        x(4)+x(5) <= 0.4;%  Dow and Nasdaq together it cannot be more than 40% 
        x(3)+x(6) <= 0.25;%S&P SmallCap and Russell 2000 no more than 25%
        x(4) >= max(x(7),x(8));%Investment in Dow is at least as much as the greater of Barron's and Wilshire
        sum(x) == 1;
        y <= 1;
        x >= 0;
        y >= 0;
    cvx_end
    portfolio(:,k)=x;
    y(:,k)=y;
    XX{k}=X;
    z_s=[z_s z];

end
Exp_Q1=mu_q1*portfolio;% The expected return of quarter 1 of each portfolio
Exp_Q2=mu_q2*portfolio;% The expected return of quarter 2 of each portfolio
Exp_Q3=mu_q3*portfolio;
Exp_Q4=mu_q4*portfolio;
Exp_u=[Exp_Q1;Exp_Q2;Exp_Q3;Exp_Q4];
P=[];
for k=1:K
    por=[];
    % The expected return of all quarters of each portfolio
    por=[Exp_Q1(k) Exp_Q2(k) Exp_Q3(k) Exp_Q4(k) ];
    P=[P;por];
end
x_val = Target;
vals = P;
b = bar(x_val,vals);

stdv_q1=sqrt(diag(portfolio'*Sigma_q1*portfolio));%Volatility of quarter 1
stdv_q2=sqrt(diag(portfolio'*Sigma_q2*portfolio));%Volatility of quarter 2
stdv_q3=sqrt(diag(portfolio'*Sigma_q3*portfolio));%Volatility of quarter 3
stdv_q4=sqrt(diag(portfolio'*Sigma_q4*portfolio));%Volatility of quarter 4

composition(Exp_Q1,portfolio,target_q1,'% Target Return',assets,m,'Quarter 1'); 
composition(Exp_Q2,portfolio,target_q2,'% Target Return',assets,m,'Quarter 2'); 
composition(Exp_Q3,portfolio,target_q3,'% Target Return',assets,m,'Quarter 3'); 
composition(Exp_Q4,portfolio,target_q4,'% Target Return',assets,m,'Quarter 4'); 
frontierarea(Exp_Q1,stdv_q1,target_q1,{'Std. dev'},'b+-',m);
legend('Quarter 1');
frontierarea(Exp_Q2,stdv_q2,target_q2,{'Std. dev'},'b+-',m);
legend('Quarter 2');
frontierarea(Exp_Q3,stdv_q3,target_q3,{'Std. dev'},'b+-',m);
legend('Quarter 3');
frontierarea(Exp_Q4,stdv_q4,target_q4,{'Std. dev'},'b+-',m);
legend('Quarter 4');
 
end


function frontierarea(ExpRet,risk,xaxis,x_label,style,m)
PercRet = 100*([ExpRet;xaxis ]- 1);
figure;
plot(risk,PercRet(1,:),style,'LineWidth',2);
title(['Efficient Frontier with m is ' num2str( m )]);
xlabel(char(x_label(1)));
ylabel('%Expected return');
end


function composition(ExpRet,X,xaxis,x_label,assets,m,time)
PercRet = 100*([ExpRet;xaxis] - 1);

figure;
area(PercRet(1,:),X');
title( ['Composition of Efficient Portfolios with m is ' num2str( m ) 'and time is ' time] )
 
xlabel('%Expected return');
ylabel('% Investement in each asset');
legend(assets);

end

