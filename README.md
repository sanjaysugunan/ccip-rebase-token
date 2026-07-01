# 🌉 Cross-Chain Rebase Token — Chainlink CCIP

> An `ERC-20` rebase token whose supply and balances stay in sync across multiple chains — bridged securely via **Chainlink CCIP** (Cross-Chain Interoperability Protocol), with rate-limited, access-controlled minting to prevent cross-chain supply manipulation.

[![Foundry](https://img.shields.io/badge/built%20with-Foundry-orange)](https://book.getfoundry.sh/)
[![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.19-363636?logo=solidity)](https://soliditylang.org/)
[![Chainlink CCIP](https://img.shields.io/badge/Chainlink-CCIP-375BD2?logo=chainlink)](https://chain.link/cross-chain)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

---

## 📐 What is a Rebase Token?

A rebase token doesn't move fixed balances between users — instead, every holder's **balance grows over time** as the token's global interest/reward rate accrues, without needing a transfer event to update it. Balances are computed dynamically from a stored "linear interest rate" rather than a static number.

This project takes that idea **cross-chain**: the token's rebasing behavior and interest accrual stay consistent no matter which chain a user's tokens currently live on.

---

## 🏗️ How It Works

```
        Source Chain (e.g. Sepolia)                Destination Chain (e.g. zkSync/Arbitrum Sepolia)
   ┌──────────────────────────────┐            ┌──────────────────────────────┐
   │   RebaseToken.sol             │            │   RebaseToken.sol             │
   │   (user holds balance,        │   burn     │   (bridged supply minted      │
   │    interest accrues)          │──────────▶ │    here on arrival)           │
   └──────────────┬────────────────┘  CCIP      └──────────────┬────────────────┘
                  │  message                                    │
                  ▼                                              ▼
   ┌──────────────────────────────┐            ┌──────────────────────────────┐
   │  RebaseTokenPool.sol          │            │  RebaseTokenPool.sol          │
   │  (Chainlink CCIP token pool,  │◀──────────▶│  (Chainlink CCIP token pool,  │
   │   rate-limited, access-ctrl)  │  CCIP Router│   rate-limited, access-ctrl)  │
   └──────────────────────────────┘            └──────────────────────────────┘
```

**Cross-chain flow:**
1. A user bridges tokens from the source chain — their balance is **burned** locally.
2. Chainlink CCIP relays a message (including the user's accrued interest rate) to the destination chain.
3. The destination chain's pool **mints** the equivalent supply to the user, preserving their rebase/interest state.

This **lock-and-mint** (burn-and-mint) architecture — rather than lock-and-unlock — keeps total cross-chain supply consistent and auditable, with no wrapped-asset drift between chains.

---

## 🔑 Core Contracts

| Contract | Responsibility |
|---|---|
| **`RebaseToken.sol`** | The `ERC-20` itself — tracks each user's principal balance and linear interest rate, and exposes the dynamic `balanceOf()` that reflects accrued interest. |
| **`RebaseTokenPool.sol`** | Chainlink CCIP-compliant token pool — handles burning on the source chain and minting on the destination chain, enforcing rate limits and access control on every cross-chain transfer. |
| **`Vault.sol`** | Deposit / redeem entry point users interact with to mint rebase tokens against underlying collateral and later redeem them. |

---

## 🛡️ Security Mechanisms

- **Rate-limiting** on the CCIP token pool — caps how much supply can move cross-chain within a given window, limiting the blast radius of any single compromised message or misbehaving relay.
- **Access-controlled minting** — only the authorized `RebaseTokenPool` (driven by verified CCIP messages) can mint on the destination chain; there is no arbitrary mint path.
- **Interest-rate propagation** — a user's individual accrued interest rate travels with them across chains inside the CCIP message payload, so rebasing stays correct regardless of which chain they're on.

---

## 🧪 Testing

Built and tested with **Foundry**, including Chainlink's local CCIP simulator for cross-chain message testing without needing live testnets for every iteration.

```bash
# Clone the repo
git clone https://github.com/sanjaysugunan/ccip-rebase-token.git
cd ccip-rebase-token

# Install dependencies
forge install

# Compile
forge build

# Run the test suite
forge test

# Run with verbose traces
forge test -vvvv

# Check coverage
forge coverage
```

---

## 🚀 Deploying Cross-Chain

Deployment involves configuring a `RebaseTokenPool` on each chain and linking them through Chainlink CCIP's on-chain registry (`TokenAdminRegistry`, `RegistryModuleOwnerCustom`), then enabling the lane between source and destination pools. See the `script/` directory for the deployment and configuration scripts used to wire this up across testnets.

---

## ⚠️ Disclaimer

This is an educational / portfolio project demonstrating cross-chain protocol engineering with Chainlink CCIP. It has **not been audited** and should not be used with real funds in production.

---

## 🔗 Links

- Repo: [github.com/sanjaysugunan/ccip-rebase-token](https://github.com/sanjaysugunan/ccip-rebase-token)
- Author: [Sanjay Sugunan](https://github.com/sanjaysugunan) · [@s4njyy](https://x.com/s4njyy) · [LinkedIn](https://www.linkedin.com/in/sanjaysugunan)

---

<p align="center">Bridged with 🌉 Chainlink CCIP, built with 🔨 Foundry.</p>
