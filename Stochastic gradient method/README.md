## Introduction

The following is an example using stochastic gradient methd in portfolio optimization. 
The dataset indices.csv has mostly closing values for eight leading stock market indices, S&P100, S&P500, S&P SmallCap 600, Dow Jones, NASDAQ Composite, Russell 2000, Barron’s 400, Wilshire 5000 as well as weekly prices for the years 2013 – 2019.

## Problem

Consider the same ten scenarios as in Risk-neutral stochastic program, for each asset and each quarter. We wish to find a portfolio that invests in at least m assets, for $m =1,\dots,8$. For each of the indices, any investment must be at least 5% of the total portfolio. Investment in the three S&P indices together cannot be more than 30% of the portfolio, for Dow and Nasdaq together it cannot be more than 40% of the portfolio, and for S&P SmallCap and Russell 2000 (which are both for small-cap stocks) it cannot be more than 25% of the portfolio. We must invest in at least one but no more than two of the S&P indices, and we must invest in at least one of Russell, Barron’s or Wilshire. Furthermore, the investment in Dow must be at least as much as that in the greater of Barron’s and Wilshire.

### Step 1 
Formulate the investment problem as stochastic optimization.

Given $c,b,R_t(\lambda),r_{i,t}(\omega)$, the primal problem with minimum total cost can be written as

```math
  \min_{x} c^Tx+E[Q(x,\omega)]
```
```math
\text{s.t.  }    x^Tx=1
```
```math
 x \geq 0
```
where
```math
 Q(x,\omega)= \min_{y} \sum_{t=1}^T b_t y_t(\omega)
```
```math
\text{s.t.  }     \sum_{i=1}^n r_{i,t}(\omega)x_i+y_t(\omega) \geq R_t,  t=1,2,3,4
```
```math
 y \geq 0
```
Given m, then adding all constraints into the formulated model
```math
  \min_{x,z} c^Tx+E[Q(x,\omega)]
```
```math
z_{sp1}+z_{sp5}+z_{sp6} \geq 1 \textit{ (at least one but)}
```
```math
z_{sp1}+z_{sp5}+z_{sp6} \leq 2 \textit{ (no more than two of the SP indices)}
```
```math
z_{Ru}+z_{Ba}+z_{Wil} \geq  1 \textit{ (at least one R, B or W)}
```
```math
x \geq 0.05z \textit{ (any investment at least 0.05 of the total portfolio)}
```
```math
x_{sp1}+x_{sp5}+x_{sp6} \leq 0.3  \textit{ (no more than 0.3 of the SP indices)}
```
```math
x_{dow}+x_{nasdap} \leq 0.4 \textit{ (no more than 0.4 of the Dow and Nasdap)}
```
```math
x_{sc}+x_{russ} \leq 0.25 \textit{ (no more than 0.25 of the SmallCap and R2000)}
```
```math
z^Tz\leq 8  \textit{ (the number of assets no more than 8  )}
```
```math
z^Tz \geq m \textit{ (the number of assets at least m )}
```
```math
  x^Tx=1
```
```math
 x \geq 0
```
### Step 2
For each value of $m=1,\dots, 8$, solve the stochastic optimization problem by the stochastic gradient method, using step sizes of $1/k$ in iteration $k$ and randomly generating $N$ equally likely scenarios at each iteration, where you should test with $N=50,100,200$. Stop the algorithm when either of the following happens: it reaches 1000 iterations or the changes in objective value between consecutive iterations is no more than $epslion = 10^{−4}$ for each of the past 10 iterations.

### Step 3

Plot the portfolio compositions using bar graphs in a single figure for $m = 4$ and different values of $N$.
