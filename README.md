# HACKS

Solidity contracts have various types of vulnerabilities. In this project, I list down the known vulnerabilities and analyze them using an example. You can simply copy the code and try it out on [Remix IDE](https://remix.ethereum.org/) (fastest way of testing)

---

## 01 - REENTRANCY

Re-entrancy is a common vulnerability in solidity code. Re-entrancy happens when some storage variables are not updated correctly. When logic re-enters a contract function (that it previously left), compiler works with old state variables instead of the updated ones.

An exploiter can use the low level functions such as `receive` and `callback` to exploit these vulnerabilities.

[RenentrancyHack.sol](./contracts/01-ReentrancyHack.sol) uses an example to explain this

---

## 02 - UNLIMITED NFT MINT

In this example, protocol whitelisted users for early NFT mint. Users had to submit Merkle Proof that they are part of whitelist to mint NFTs. Problem is that at the time of whitelisting, number of NFT's minted for that specific users was not stored in Merkle Tree.

Team relied on user input for the number of NFT's they could mint. So a whitelisted member could theoretically mint all NFT's in a single shot by passing in a high number as input

[UnlimitedMintHack.sol](./contracts/02-UnlimitedMintHack.sol) explains this exploit with actual code

Came to know of this example from a [tweet](https://twitter.com/rugpullfinder/status/1565734576630145024). A random user minted 400 NFT's in one transaction. Funny thing was the team put in place bot resistant mechanisms but failed to ensure manual check.
