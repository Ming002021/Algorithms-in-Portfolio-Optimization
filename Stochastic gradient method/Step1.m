%Given diffrent values of m ,get the portfolio for each target return,the initial x0
%Given the expected return geo_mean_perQ
%%%Using Function of SG with different values of N
m_value=[1 2 3 4 5 6 7 8];
l=length(m_value);
Portfolio_N_M=[];
Exp_ret__N_M=[];
for g=1:l
    m=m_value(g);
    N_value=[50 100 200];
    nl=length(N_value);
    Portfolio_N=[];
    Exp_ret_N=[];
    for h=1:nl
        N=N_value(h);
        x0=[1/8 1/8 1/8 1/8 1/8 1/8 1/8 1/8]';
        [portfolio,Exp_ret]= SG(m,N,x0,geo_mean_perQ);
        Portfolio_N=[Portfolio_N;portfolio];
        Exp_ret_N=[Exp_ret_N;Exp_ret];
    end
    Portfolio_N_M=[Portfolio_N_M;Portfolio_N];
     
end
 
%Given m and N, get the portfolio for each target return,the initial x0
%Given the expected return geo_mean_perQ
%%%Function of SG
function [portfolio,Exp_u]=SG(m,N,x0,geo_mean_perQ)  
%The cost c and the penalty cost b
c=[0.45 1.15 0.65 0.8 1.25 1.1 0.9 0.7];
b=[1.3 2.5 1.75 3.25];
% the initial x0
assets={'S&P100', 'S&P500', 'S&P SmallCap 600', 'Dow Jones', 'NASDAQ Composite', 'Russell 2000', 'Barron 400', 'Wilshire 5000'};
n=8;
t=4;
%Target return
Target=[0:0.05:1.0];
K=length(Target);
portfolio=zeros(n,K);%Store all portfilos
target_q1=[];%Store all target return of quarter 1
target_q2=[];
target_q3=[];
target_q4=[];
for k=1:K
    %Calculate target return of each quarter Return
    %Fixed the target return in all iterations
    Return=[];
    for i=1:4
        Rt_lam=min( geo_mean_perQ(i,:))+Target(k)*(max( geo_mean_perQ(i,:))-min( geo_mean_perQ(i,:)));
        Return=[Return;Rt_lam];%Return:4 by 1 vector
    end
    target_q1=[target_q1 Return(1)];
    target_q2=[target_q2 Return(2) ];
    target_q3=[target_q3 Return(3) ];
    target_q4=[target_q4 Return(4) ];
    target_allq=[target_q1;target_q2;target_q3;target_q4];
    g=1;%For stepsize 1/g
    repeat=true;
    x_new=x0;%the initial x0 for the first iteration
    iter=0;
    opt_obj=[];
    while repeat==true
        %One iteration
        x_now=x_new';
        iter=iter+1;
        if iter==1000
            repeat=false;
        end
        %Obtain the gradient
        g_hat=zeros(N,n);
        %Staring N scenarios
        for s=1:N
            %Generate one scenario for each asset and each time period
            ret = zeros(t,n);
            rng(s,'twister'); % Fix the seed and the random number generator
            ret=0.8+(1.3-0.8).*rand(4,8);% Assuming the return is no more than 1.3 
                                     % and no less than 0.8 
            %Return in this scenario now of each quarter
            retn=ret*x_now';
            %Given this scenario
            %Calculate the Dual recourse function
            cvx_begin
                variable u(t);
                %Return-retn is the target return-return in this scenario
                maximize(( Return-retn )'*u);
                u >= 0;
                u <= b';
            cvx_end
            %g_s^k
            g_s=(-ret'*u)';%In this scenario,the gradient change of all x
            g_hat(s,:)=g_s;%g_hat is N x n matrix
        end %Finishing N scenarios in here and the partial derivative
        %Gradient 
        gam=1/g;
        g=g+1;
        gradient=mean(g_hat,1)+c;
        x_gra=x_now-gam*gradient;
        %Find the projection on feasible region X
        cardinality = 8;
        cvx_begin
            variable x(n)  
            variable y(n)
            minimize (norm(x-x_gra', 2 ));
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
        x_new=x;%Finish one iteration and get a new x
        %optimal of objective function
        opt_obj_now=c*x_new;
        opt_obj=[opt_obj; opt_obj_now];
        %Inverse the array to check the stop criteria
        s_obj=size(opt_obj,1);
        if repeat==true
            if s_obj >= 10
                con=zeros(1,9);
                for j=1:9
                    con(j)=opt_obj(s_obj-(10-j))-opt_obj(s_obj-(10-j)+1);
                end
                if abs(con) <= 1.0000e-4
                    repeat=false;
                end
            end
   
        end  
   
    end  
    portfolio(:,k)=x_new;
    %Finish all iteration and get the final portfolio for this given target
    %return
end %Finish all vary target returns
mu_q1=geo_mean_perQ(1,:);
mu_q2=geo_mean_perQ(2,:);
mu_q3=geo_mean_perQ(3,:);
mu_q4=geo_mean_perQ(4,:);
Exp_Q1=mu_q1*portfolio;% The expected return of quarter 1 of each portfolio
Exp_Q2=mu_q2*portfolio;% The expected return of quarter 2 of each portfolio
Exp_Q3=mu_q3*portfolio;
Exp_Q4=mu_q4*portfolio;
Exp_u=[Exp_Q1;Exp_Q2;Exp_Q3;Exp_Q4];
%For each N, each m, each quarter, get one composition plot
composition(Exp_Q1,portfolio,target_q1,'% Target Return',assets,m,N,'Quarter 1'); 
composition(Exp_Q2,portfolio,target_q2,'% Target Return',assets,m,N,'Quarter 2'); 
composition(Exp_Q3,portfolio,target_q3,'% Target Return',assets,m,N,'Quarter 3'); 
composition(Exp_Q4,portfolio,target_q4,'% Target Return',assets,m,N,'Quarter 4'); 
 
end

function composition(ExpRet,X,xaxis,x_label,assets,m,N,time)
PercRet = 100*([ExpRet;xaxis] - 1);

figure;
area(PercRet(1,:),X');
title( ['Composition of Efficient Portfolios with m is ' num2str( m ) ' and time is ' time 'and N is ' N] )
 
xlabel('%Expected return');
ylabel('% Investement in each asset');
legend(assets);

end  

 
    
     