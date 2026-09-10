# MyNft

A small local NFT app: a Solidity contract in `backend/` and a Next.js wallet UI in `frontend/`.

You can **mint** a token to your MetaMask account, **look it up** by number, **approve** another wallet to send it, and **send** it.

This is a teaching / local-Anvil project. It is not a full ERC-721 marketplace.

## What you need

- **Node.js** (20+ recommended) and npm
- **Anvil** (from [Foundry](https://book.getfoundry.sh/getting-started/installation)) — a local Ethereum node at `http://127.0.0.1:8545`, chain id **31337**
- **MetaMask** in the browser

Install backend and frontend dependencies once:

```bash
cd backend && npm install
cd ../frontend && npm install
```

## Environment files

Never put a private key in the frontend or in any `NEXT_PUBLIC_*` variable. Those values are visible in the browser.

### `backend/.env`

Used by deploy and CLI scripts (the deployer wallet). Typical Anvil defaults:

```env
RPC_URL=http://127.0.0.1:8545
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
PRIVATE_KEY_2=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
CONTRACT_ADDRESS=
```

| Variable | Purpose |
| --- | --- |
| `RPC_URL` | Anvil HTTP endpoint |
| `PRIVATE_KEY` | Account that **deploys** the contract (Anvil account 0 by default) |
| `PRIVATE_KEY_2` | Second Anvil account, used by the backend CLI if you run it |
| `CONTRACT_ADDRESS` | Filled in automatically when you deploy |

Those two private keys are **Anvil’s well-known test keys**. They are only for local use. Do not use them on a real network.

### `frontend/.env.local`

Used by the website. Safe to expose:

```env
NEXT_PUBLIC_RPC_URL=http://127.0.0.1:8545
NEXT_PUBLIC_CONTRACT_ADDRESS=
```

| Variable | Purpose |
| --- | --- |
| `NEXT_PUBLIC_RPC_URL` | Same local RPC the UI uses to read the chain |
| `NEXT_PUBLIC_CONTRACT_ADDRESS` | Deployed MyNft address |

You do **not** need to edit this file by hand if you use `./start.sh`. Deploy writes both keys for you.

Copy from `frontend/.env.local.example` if you start the frontend without that script.

### Optional repo-root `.env`

If a `.env` exists at the repo root, deploy will also store `CONTRACT_ADDRESS` there. The app does not require it.

## How to start (every Anvil session)

Anvil wipes the chain when you stop it. The old contract address is then empty. You must **redeploy** and point the frontend at the new address.

**Terminal 1 — local chain**

```bash
anvil
```

Leave this running. It prints test accounts and private keys.

**Terminal 2 — deploy, sync ABI, run the UI**

From the **project root** (this folder, not `frontend/` or `backend/`):

```bash
./start.sh
```

The script:

1. Checks that Anvil is up at `http://127.0.0.1:8545`. If not, it tells you to start `anvil` and exits.
2. Compiles and deploys `MyNft` (`backend/`)
3. Writes `CONTRACT_ADDRESS` to `backend/.env` and `NEXT_PUBLIC_CONTRACT_ADDRESS` / `NEXT_PUBLIC_RPC_URL` to `frontend/.env.local`
4. Copies the contract ABI into `frontend/abi/MyNft.json`
5. Starts Next.js at [http://localhost:3000](http://localhost:3000)

If Anvil was not running, start it, then run `./start.sh` again.

If the UI still shows an old address after a redeploy, stop the script (`Ctrl+C`) and run `./start.sh` again so Next.js reloads env.

### Manual steps (same as the script)

```bash
# Anvil already running
cd backend && npm run compile && npm run deploy
cd ../frontend && npm run sync-abi && npm run dev
```

## MetaMask

1. Open MetaMask → **Add network** (or Networks):
   - Network name: Anvil / Localhost
   - RPC URL: `http://127.0.0.1:8545`
   - Chain ID: `31337`
   - Currency: ETH
2. **Import account** using an Anvil private key from the Anvil terminal (or the `PRIVATE_KEY` in `backend/.env`).
3. Import a **second** Anvil account if you want to send NFTs between wallets (`PRIVATE_KEY_2`).
4. Connect on [http://localhost:3000](http://localhost:3000).
5. Changing the account **inside MetaMask** updates the connected wallet in the app automatically. Use **Disconnect** only to unplug the wallet from the page.

If MetaMask says the network is wrong, use **Switch to Anvil** on the page, or switch the network in MetaMask.

## How to use the page

1. **Collection** — “Total minted” (all tokens ever created) and “Your NFTs” (how many the connected wallet owns).
2. **Mint** — creates the next token and gives it to you. Confirm in MetaMask.
3. **Look up a token** — type the token number (first mint is usually `0`). You will see **Owner** and **Approved to**.
4. **Approve** — only the owner. Lets another wallet send that token.
5. **Send** — owner or approved wallet. **From** must be the current owner. **Use connected wallet** / **Use looked-up token** fill the fields for you.

There is no gallery of every token. Look up by number only.

## Project layout

```
start.sh                 # compile, deploy, sync ABI, run frontend
README.md                # this file
backend/
  contracts/MyNft.sol    # mint, ownerOf, balanceOf, approve, transferFrom
  scripts/deploy.ts
  .env
frontend/
  app/                   # pages
  components/            # UI cards
  lib/nft/api.ts         # all contract read/write definitions
  abi/MyNft.json         # ABI copied from the backend build
  .env.local
```

## Extra backend CLI

```bash
cd backend && npm run cli
```

Uses `PRIVATE_KEY` / `PRIVATE_KEY_2` against `CONTRACT_ADDRESS`. Optional; the website is enough for mint / lookup / approve / send.

## Troubleshooting

| Problem | What to do |
| --- | --- |
| `./start.sh` says Anvil is not running | Start `anvil` in another terminal, then rerun `./start.sh` |
| App says it is not linked to a contract | Deploy did not write `frontend/.env.local`. Run `./start.sh` from the repo root |
| Reads fail after restarting Anvil | Old address is dead. Redeploy with `./start.sh` |
| “Wrong network” | MetaMask must use chain id 31337 |
| Mint button disabled | Connect a wallet on Anvil |
| Token lookup errors | That number was never minted on **this** deploy |
