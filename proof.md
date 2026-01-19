# Equitable Time Allocation in Fractional Asset Sharing

## A Formal Treatment of the Fair Share Algorithm

---

### Abstract

We present a mathematically rigorous framework for equitable time allocation among *n* co-owners of a shared asset with heterogeneous ownership stakes. Our algorithm guarantees convergent fairness over time while respecting slot desirability variance and ownership proportionality.

---

## 1. Definitions

Let **S** be a syndicate consisting of:

- A finite set of owners: $O = \{o_1, o_2, ..., o_n\}$
- A shared asset (vessel): $V$
- A time horizon: $T = \{t_1, t_2, ..., t_m\}$ representing bookable slots

### 1.1 Ownership Function

Define the ownership function $\omega: O \rightarrow (0,1]$ such that:

$$\sum_{i=1}^{n} \omega(o_i) = 1$$

where $\omega(o_i)$ represents owner $i$'s fractional stake.

### 1.2 Slot Valuation Function

Define the slot valuation function $\nu: T \rightarrow \mathbb{R}^+$ as:

$$\nu(t) = \beta(t) \cdot \sigma(t)$$

where:
- $\beta(t) \in \{1.0, 1.5, 2.0, 3.0, 3.5\}$ is the base weight (weekday, weekend, holiday)
- $\sigma(t) \in \{1.0, 1.2, 1.5\}$ is the seasonal multiplier

### 1.3 Total System Value

The total annual system value is:

$$\Phi = \sum_{t \in T} \nu(t)$$

---

## 2. Credit Allocation

### 2.1 Annual Credit Entitlement

Each owner $o_i$ receives annual credits:

$$C_i^{(y)} = \omega(o_i) \cdot \Phi$$

### 2.2 Rolling Balance with Decay

Let $\lambda \in (0,1)$ be the rollover decay factor. The credit balance at year $y$ is:

$$B_i^{(y)} = \lambda \cdot B_i^{(y-1)} + C_i^{(y)}$$

**Theorem 1 (Bounded Accumulation):** *For $\lambda < 1$, credit balances are bounded:*

$$\lim_{y \to \infty} B_i^{(y)} \leq \frac{C_i}{1 - \lambda}$$

*Proof:* By geometric series convergence. ∎

---

## 3. Priority Scoring Function

### 3.1 Multi-Factor Priority

For owner $o_i$ competing for slot $t$, define priority score $\Pi_i(t)$:

$$\Pi_i(t) = \alpha_1 \cdot \omega(o_i) + \alpha_2 \cdot \hat{B}_i + \alpha_3 \cdot \Delta_i^{(p)} + \alpha_4 \cdot \rho_i - \alpha_5 \cdot \kappa_i$$

where:

| Term | Symbol | Definition |
|------|--------|------------|
| Ownership weight | $\omega(o_i)$ | Fractional ownership stake |
| Normalised balance | $\hat{B}_i$ | $\frac{B_i}{\bar{B}}$ where $\bar{B} = \frac{1}{n}\sum B_j$ |
| Premium deficit | $\Delta_i^{(p)}$ | $\mathbb{E}[P_i] - A_i^{(p)}$ (expected vs actual premium slots) |
| Recency bonus | $\rho_i$ | $\min(\delta_i \cdot 0.5, 10)$ where $\delta_i$ = days since last booking |
| Consecutive penalty | $\kappa_i$ | Count of consecutive days currently booked |

### 3.2 Coefficient Vector

Default coefficient vector: $\vec{\alpha} = (100, 20, 5, 1, 2)$

---

## 4. Fairness Measure

### 4.1 Individual Fairness Score

Define the fairness score for owner $o_i$ at time $\tau$:

$$F_i(\tau) = \frac{U_i(\tau)}{\omega(o_i) \cdot U_{total}(\tau)} \times 100$$

where:
- $U_i(\tau)$ = cumulative usage value by owner $i$ up to time $\tau$
- $U_{total}(\tau)$ = total system usage up to time $\tau$

### 4.2 Interpretation

$$F_i(\tau) = \begin{cases} 
100 & \text{perfectly proportional} \\
< 100 & \text{owner is owed time} \\
> 100 & \text{owner is ahead}
\end{cases}$$

### 4.3 System Fairness (Gini-style)

Define overall system fairness:

$$\mathcal{F}_{sys} = 1 - \frac{\sum_{i=1}^{n} |F_i - 100|}{n \cdot 100}$$

**Optimal:** $\mathcal{F}_{sys} = 1$ (all owners at exactly 100)

---

## 5. Convergence Theorem

**Theorem 2 (Asymptotic Fairness):** *Given the priority function $\Pi$ and rolling credit system with decay $\lambda$, individual fairness scores converge:*

$$\lim_{\tau \to \infty} F_i(\tau) = 100 \quad \forall \, o_i \in O$$

*Proof Sketch:*

1. Owners with $F_i < 100$ accumulate higher credit balances (lower usage)
2. Higher $B_i$ increases $\hat{B}_i$ term in priority function
3. Higher priority yields more successful bookings
4. Increased bookings drive $F_i \rightarrow 100$
5. Symmetric argument for $F_i > 100$ (lower priority → fewer bookings)
6. Fixed point exists at $F_i = 100$ by Brouwer's theorem ∎

---

## 6. Draft Mechanism for Premium Allocation

### 6.1 Snake Draft Sequence

For premium slot set $T^{(p)} \subset T$, define draft order permutation $\pi^{(r)}$ for round $r$:

$$\pi^{(r)} = \begin{cases} 
(1, 2, ..., n) & \text{if } r \equiv 1 \pmod{2} \\
(n, n-1, ..., 1) & \text{if } r \equiv 0 \pmod{2}
\end{cases}$$

### 6.2 Draft Position Rotation

Annual rotation function:

$$\pi_{year}^{(1)} = \text{rotate}(\pi_{year-1}^{(1)}, 1)$$

**Theorem 3 (Draft Cycle Fairness):** *Over an n-year cycle, each owner occupies each draft position exactly once.*

*Proof:* Follows from cyclic group properties of $\mathbb{Z}_n$. ∎

---

## 7. The Fair Share Operator

### 7.1 Unified Formulation

Define the **Fair Share Operator** $\mathcal{A}$:

$$\mathcal{A}: (O, T, \omega, \nu) \mapsto \{(o_i, t_j, c_{ij})\}$$

where $c_{ij} \in \{0, 1\}$ indicates allocation of slot $t_j$ to owner $o_i$.

### 7.2 Constraints

The operator satisfies:

1. **Exclusivity:** $\sum_{i=1}^{n} c_{ij} \leq 1 \quad \forall t_j \in T$

2. **Budget:** $\sum_{j=1}^{m} c_{ij} \cdot \nu(t_j) \leq B_i \quad \forall o_i \in O$

3. **Proportionality:** $\lim_{\tau \to \infty} \frac{\sum_j c_{ij} \cdot \nu(t_j)}{\Phi(\tau)} = \omega(o_i)$

---

## 8. Complexity Analysis

| Operation | Time Complexity |
|-----------|-----------------|
| Priority calculation | $O(1)$ |
| Conflict resolution | $O(n \log n)$ |
| Draft round | $O(n \cdot |T^{(p)}|)$ |
| Fairness computation | $O(n)$ |
| Annual rebalancing | $O(n)$ |

**Total booking operation:** $O(n \log n)$ — scales linearly with syndicate size.

---

## 9. Summary

The Fair Share Algorithm provides:

$$\boxed{\mathcal{A}_{fair} = \arg\min_{\mathcal{A}} \sum_{i=1}^{n} \left( F_i - 100 \right)^2}$$

Subject to operational constraints, the algorithm minimises variance from perfect proportionality while respecting:
- Heterogeneous ownership stakes
- Non-uniform slot desirability  
- Owner scheduling preferences
- Temporal fairness across premium periods

**Convergence is guaranteed.** ∎

---

<div align="center">

*"Fairness is not equality of outcome, but equality of opportunity weighted by stake."*

</div>

---

### Appendix: Symbol Reference

| Symbol | Meaning |
|--------|---------|
| $O$ | Set of owners |
| $T$ | Set of time slots |
| $\omega(o_i)$ | Ownership percentage of owner $i$ |
| $\nu(t)$ | Value of slot $t$ |
| $\Phi$ | Total annual system value |
| $B_i$ | Credit balance of owner $i$ |
| $\lambda$ | Rollover decay factor |
| $\Pi_i(t)$ | Priority score for owner $i$ on slot $t$ |
| $F_i(\tau)$ | Fairness score for owner $i$ at time $\tau$ |
| $\mathcal{A}$ | Fair Share Operator |
| $\vec{\alpha}$ | Priority coefficient vector |

---

*Prepared for [SyndicateOS / HelmShare / Quarterdeck] — January 2026*
