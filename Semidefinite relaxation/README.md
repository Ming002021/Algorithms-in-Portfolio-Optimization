
## Introduction

The following is an example of the semidefinite relaxation programming in portfolio optimization with benchmark. 
The dataset indices.csv has mostly closing values for eight leading stock market indices, S&P100, S&P500, S&P SmallCap 600, Dow Jones, NASDAQ Composite, Russell 2000, Barron’s 400, Wilshire 5000 as well as weekly prices for the years 2013 – 2019.

## Problem

Consider the same ten scenarios as in Risk-neutral stochastic program, for each asset and each quarter. We wish to find a portfolio that invests in at least m assets, for $m =1,\dots,8$. For each of the indices, any investment must be at least 5% of the total portfolio. Investment in the three S&P indices together cannot be more than 30% of the portfolio, for Dow and Nasdaq together it cannot be more than 40% of the portfolio, and for S&P SmallCap and Russell 2000 (which are both for small-cap stocks) it cannot be more than 25% of the portfolio. We must invest in at least one but no more than two of the S&P indices, and we must invest in at least one of Russell, Barron’s or Wilshire. Furthermore, the investment in Dow must be at least as much as that in the greater of Barron’s and Wilshire.



Consider the tracking error w.r.t. the fully-diversified portfolio (equal investment in each asset) and let the net tracking error be the maximum of tracking errors for each quarter.

### Step 1 

Formulate a SDP relaxation of the problem of finding a feasible portfolio with minimum net tracking error and meeting required target return rate. 

Let $x^b=\left(1/n, \dots, 1/n\right)$ be the benchmark portfolio. The primal problem with minimum net tracking error and meeting required target return rate can be written as

```math
  \min\limits_{x}  \Big(\max_{t=1,\dots, T} \{(x-x^b)^T \Sigma_{t} (x-x^b)\}\Big)
```
```math
\text{s.t.  }    \mu_t x\geq R_t(\lambda), t=1, \dots, T
```
```math
\sum_{i=1}^n x_i =1, x\geq 0
```
If we introduce the variables $z$ to control the net tracking error, the formulated model is
```math
  \min\limits_{x,z}  z
```
```math
(x-x^b)^T \Sigma_{t} (x-x^b) \leq z, t=1, \dots, T

```
```math
\text{s.t.  }    \mu_t x\geq R_t(\lambda), t=1, \dots, T
```
```math
\sum_{i=1}^n x_i =1, x\geq 0
```
Adding all constraints in the problems into the formulated model, then the optimization model is 
```math
  \min\limits_{x,z,y}  z
```
```math
(x-x^b)^T \Sigma_{t} (x-x^b) \leq z, t=1, \dots, T

```
```math
\text{s.t.  }    \mu_t x\geq R_t(\lambda), t=1, \dots, T
```
```math
\sum_{i=1}^n x_i =1, x\geq 0
```
```math
\sum_{i=1}^n y_i =m, y \in \{0,1\}^n
```
```math
0.05y_i \leq x_i \leq y_i, i=1,\dots, n
```
```math
1 \leq y_1+y_2+y_3 \leq 2, y_6+y_7+y_8 \geq 1
```
```math
x_1+x_2+x_3 \leq 0.3, x_4+x_5 \leq 0.4, x_3+x_6 \leq 0.25, x_4 \geq x_7, x_4 \geq x_8
```
Finally, the formulated SDP relaxation model is
```math
  \min\limits_{x,z}  z
```
```math
\text{s.t.  }  (x-x^b)^T \Sigma_{t} (x-x^b) \leq z, t=1, \dots, T

```
```math
  \mu_t x\geq R_t(\lambda), t=1, \dots, T
```
```math
\sum_{i=1}^n x_i =1, x\geq 0
```
Adding all constraints in the problems into the formulated model, then the optimization model is 
```math
  \min\limits_{x,z,y,X}  z
```
```math
\text{s.t.  }     \Sigma_{t}\cdot X-2(x^b)^T \Sigma_{t}x+(x^b)^T \Sigma_{t}x^b \leq z, t=1, \dots, T

```
```math
   \mu_t x\geq R_t(\lambda), t=1, \dots, T
```
```math
\sum_{i=1}^n x_i =1, x\geq 0
```
```math
\sum_{i=1}^n y_i =m, y \in \{0,1\}^n
```
```math
0.05y_i \leq x_i \leq y_i, i=1,\dots, n
```
```math
1 \leq y_1+y_2+y_3 \leq 2, y_6+y_7+y_8 \geq 1
```
```math
x_1+x_2+x_3 \leq 0.3, x_4+x_5 \leq 0.4, x_3+x_6 \leq 0.25, x_4 \geq x_7, x_4 \geq x_8
```
```math
\begin{pmatrix}
1 & x^T \\
x & X
\end{pmatrix}
\in PSD_n
```
```math
diag(X) \leq x, X \geq 0
```

### Step 2
Solve the SDP model for $m=1, \dots, 8$ and a range of target returns.

### Step 3

Plot and compare the appropriate efficient frontiers in one single figure. Compare the portfolio compositions in one single figure. Also comment on the highest return rate for which you are able to find a feasible portfolio.

### Step4

Give an algorithm that uses the SDP solution to find a feasible portfolio.
