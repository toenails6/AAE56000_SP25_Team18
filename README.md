# AAE56800_SP25_Team18
AAE56800_SP25_Team18

MATLAB to the rescue. 

# Risk factor 
There would be an initial risk factor generated from a seeded RNG. 
The risk factor would then oscillate periodically through a sine function
to mimic seasonal influence. 
There will be a seeded RNG generated amplitude for each grid block. 
Results can be tuned through mean and standard deviation of the corresponding normally stochastic RNG. 

# Fire intensity growth
Fire dynamics in terms of fire intensity $I$: 
```math
I(k+1) = c \cdot R \cdot f\left(H(k)\right) \cdot I(k)
```
<!-- ```math
f(H(k)) = 
    -\frac{1}{\mu^2 -2\,\mu +1}H(k)^2 + 
    \frac{2\,\mu }{\mu^2 -2\,\mu +1}H(k) - 
    \frac{2\,\mu -1}{\mu^2 -2\,\mu +1}
``` -->
```math
f(H(k)) = 
    -\frac{1}{\mu^2 -2\,\mu +1}\cdot\left(H(k)^2-2\mu\cdot H(k)+2\mu-1\right)
```

where: 
* $c$ is an arbitrary growth rate scaling constant for tuning. 
* $R$ is the risk factor. 
* $H(k)$ is the health of the grid block at time $k$. 
* $\mu$ is the health fraction where intensity growth rate peaks. 

\
We can then formulate a state space representation: 
```math
x(k) = \begin{bmatrix}
    I(k) \\ H(k)
\end{bmatrix}
```
```math
x(k+1) = \begin{bmatrix}
    1 + c \cdot R \cdot f(H(k)) & 0 \\
    -1 & 1
\end{bmatrix} 
\begin{bmatrix}
    I(k) \\ H(k)
\end{bmatrix}
```

Upon adding the fire station control input $u(k)$, the state space representation becomes: 
```math
x(k+1) = \begin{bmatrix}
    1 + c \cdot R \cdot f(H(k)) & 0 \\
    -1 & 1
\end{bmatrix} 
\begin{bmatrix}
    I(k) \\ H(k)
\end{bmatrix} + 

\begin{bmatrix}
    u(k) \\ 0
\end{bmatrix}
```

Fire intensities are constrained to minimum of 0 and maximum of 1. 
Grid blocks with fire intensity of 0 means have no active presence of fires. 
A fire intensity of 1 effectively instantly depletes the health a grid block. 

Fires are considered as dead when intensity is three standard deviations below mean of new fire intensity settings. 
Fires also end when health of the corresponding grid block is depleted. 

# Fire Spread
Fires can spread based on intensity and neighboring risk factors, which means local intensity grows after neighboring intensity reaches beyond a certain threshold based on local risk factor. 

**This is yet to be implemented, WORK IN PROGRESS.**

# Fire Occurrence
Stochastic fire generation is based on comparison between a uniform RNG and the risk factor of the corresponding grid block. 
If the output from the uniform RNG is within the risk factor of the corresponding grid, then a fire will be generated. 
The intensity of the new fire will be normally stochastic, with arbitrary mean and standard deviation. 

# Grid Health restoration. 
Grid health will be replenished at a fixed rate when there is no fire present in the corresponding grid block. 
A cost corresponds to each regen, and scales to small regen steps when the health is almost fully restored. 

# Metrics. 
Total costs

Cost vs. tick

Grid (5, 16) Peekaboo

Satellite frequency effects. 

Average fire length. 
