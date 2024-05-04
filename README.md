## MetaWe

> This is my pet-project to practice some Solidity coding and testing: an attempt to create social network smart-contract protocol from scratch.
> I will describe every new feature or contract in this readme file.


### Initial architecture scheme

![initial-architecture.png](docs/architecture.png)

### Features implemented

1. Account creation (minting ownership and deploy of the ERC-6551 account)
2. Following mechanism (using ERC721 contract for every specific account, where minting equal following to special account).

### TODO

1. Implement simple client application (using Next.js). It will be useful to understand what to add to the protocol.
2. Add some content creation functions (posting something like tweets, some content via ipfs or smth like that).
3. Maybe some reputation points
