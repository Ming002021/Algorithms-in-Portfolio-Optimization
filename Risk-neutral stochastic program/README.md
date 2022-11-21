
 
 
## Introduction

The following is an example of the two-stage stochastic programming in portfolio optimization with recourse. The dataset indices.csv has mostly closing values for eight leading stock market indices, S&P100, S&P500, S&P SmallCap 600, Dow Jones, NASDAQ Composite, Russell 2000, Barron’s 400, Wilshire 5000 as well as weekly prices for the years 2013 – 2019.

 
## Problems

You have £10,000 to invest (without short selling) in a portfolio composed of eight leading stock market indices (think of investing in a market index as investing equally in all securities that form the index, e.g., if your decision is to invest 8% in a index formed by 10 securities, then each security is getting 0.8% of your total investment) in the US stock market, S&P100, S&P500, S&P SmallCap 600, Dow Jones, NASDAQ Composite, Russell 2000, Barron’s 400, Wilshire 5000.

You have to invest while considering the performance of these indices over four quarters of a calendar year, <div align="center">Q1: Jan.1–March 31, Q2: April 1–June 30, Q3: July 1–Sep.30, Q4: Oct.1–Dec.31. <div align="left">We are allowed recourse actions on our investment via having shortfall on target return rates.

Let $\Omega$ denote the scenario set with probabilities $p(\omega)$ for $\omega \in \Omega$. Let $r_{i,t}(\omega)$ denote the random return rate of index $i$, for $i = 1,\dots,n$ where $n = 8$, in time period $t$, for quarters $t = 1,\dots,T$ where $T = 4$. Let $R_t$ denote the target return rate in time period $t$, for $t = 1,\dots,T$. You incur investment cost of $c_i$ for each index $i$, for $i = 1,\dots,n$, and also a penalty cost of $b_t$ for unit shortfall in time $t$, for $t = 1,\dots,T$. The two-stage stochastic program that minimises the total cost is formulated as follows, where $\omega_{.t}$ is the vector of scenarios $(\omega_{it})_{i=1,\dots, n}$ formed by scenarios for returns of asset $i$ in time $t$,



```math
\min_{x} c^T x+E \left[ \sum_{t=1}^T b_t y_t(\omega_{.t})\right]
```
```math
\sum_{i=1}^n r_{i,t}(\omega)x_i+y_t(\omega_{.t}) \geq R_t, t = 1,\dots,T
```
```math
\sum_{i=1}^n x_i=1, x\geq0, y \geq 0
```

### Step 1
 
Batch the data and create a table giving the geometric means $\mu_{i,t}$ and standard deviation $\sigma_{i,t}$ for the 8 indices (two 4 x 8 tables, one for mean, one for std.dev).

### Step 2

Solve the risk-neutral stochastic program as a Linear Program. Use the ten scenarios given below, and we assume for simplicity each of these scenarios repre- sents the scenarios for all assets $i$ and quarters $t$,

| Scenarios     | Return rate $r_{i,t}(\omega_j)$ | Probability $p(\omega_j)$     |
| :---        |    :----:   |        :----:|
| $\omega_1$      | $\mu_{i,t}-8\sigma_{i,t}$      | 0.10   |
| $\omega_2$      | $\mu_{i,t}-3\sigma_{i,t}$      | 0.04   |
| $\omega_3$      | $\mu_{i,t}-2\sigma_{i,t}$      | 0.07   |
| $\omega_4$      | $\mu_{i,t}-1.5\sigma_{i,t}$      | 0.12  |
| $\omega_5$      | $\mu_{i,t}-\sigma_{i,t}$      | 0.20   |
| $\omega_6$      | $\mu_{i,t}$      | 0.15   |
| $\omega_7$      | $\mu_{i,t}+\sigma_{i,t}$      | 0.05   |
| $\omega_8$      | $\mu_{i,t}+1.5\sigma_{i,t}$      | 0.13   |
| $\omega_9$      | $\mu_{i,t}+2\sigma_{i,t}$      | 0.08  |
| $\omega_10$      | $\mu_{i,t}+3\sigma_{i,t}$      | 0.06   |

The investment cost $c_i$ for each index is
|Index| S&P100| S&P500| S&P600| Dow| NASDAQ |Russell2000| Barron’s| Wilshire|
|:--- |  :----:  |  :----:  |  :----:  |  :----:  |  :----:   | :----:  |  :----:  |  :----:  |
|$c_i$|0.45| 1.15| 0.65| 0.8 |1.25| 1.1| 0.9| 0.7|

and the penalty cost $b_t$ for the four quarters are, respectively, 1.3, 2.5, 1.75, 3.25.
Target return rates for the different quarters are $R_t(0.5)$ where for $\lambda \in [0, 1]$ we define
```math
R_t(\lambda):= \min_{i=1, \dots, n} \mu_{i,t} +\lambda \left( \max_{i=1, \dots, n} \mu_{i,t}-\min_{i=1, \dots, n} \mu_{i,t} \right)
```
### Step 3

Vary target returns as $R_t(\lambda)$ for $\lambda \in \left{0,0.05,0.1,0.15,\dots,1.0 \right} and using the optimal portfolios for the above stochastic program, plot the composition of portfolios.

### Step 4

Formulate a Linear Program for the risk-averse stochastic program using $CVaR$ as the risk measure, where the term $\delta CVaR_{\beta}\left[Q(x,\omega)\right]$ is added to the objective.

### Step 5
 
Solve the risk-averse problem and plot the portfolio composition by varying $R_t(\lambda)$ as before and $\beta = 90%$ and $\delta=1, 10,50$.
 
