const { expect } = require("chai");
const { ethers } = require("hardhat");

// describe("Greeter", function () {
//   it("Should return the new greeting once it's changed", async function () {
//     const Greeter = await ethers.getContractFactory("Greeter");
//     const greeter = await Greeter.deploy("Hello, world!");
//     await greeter.deployed();

//     expect(await greeter.greet()).to.equal("Hello, world!");

//     const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

//     // wait until the transaction is mined
//     await setGreetingTx.wait();

//     expect(await greeter.greet()).to.equal("Hola, mundo!");
//   });
// });


// describe("Simple NFT", function () {
//     it("Should mint an NFT", async function () {
//       const NFT = await ethers.getContractFactory("SimpleNFT");
//       const nft = await NFT.deploy();
//       await nft.deployed();
  
//       const [_, minter] = await ethers.getSigners()
  
//       await nft.connect(minter).mint()
  
      
//     });
//   });


// describe("Happy melody  test", function () {
//     it("Should return  Happy", async function () {
     
//         const Lib = await ethers.getContractFactory("LibSalePhase");
//         const lib = await Lib.deploy();
//         await lib.deployed()

//         const pricehexValue = ethers.utils.parseUnits("0.001", 18)
//         const PRICE = pricehexValue.toString()

//         const erc721Contract   = await ethers.getContractFactory("HappyMelody" ,
//                 {
//                 libraries: {
//                     LibSalePhase: lib.address,
//                 },
//                 });

//                 const erc721_nft = await  erc721Contract.deploy(
//                     "ipfs://bafybeiaghwu5n5pjmfmrmvfi47bpybd3ehput7de2yrp7266yfyc6l57o4/",
//                     PRICE,
//                     "0x60Cc1b0a3543307Acf398fC01676458555C4c62C",
//                     "0x60Cc1b0a3543307Acf398fC01676458555C4c62C"
//                 );
     
//       await erc721_nft.deployed()

//       const  setPhaseStatus =  await   erc721_nft.setPhaseStatus(1, 1)

//     //   const setAirDropActive  = await erc721_nft.setAirdropActive(true)

//       const setAirDropActive  = await erc721_nft.reduceMaxSupply(
//         99 ,
//         "ipfs://bafybeia6j2cfxvdx4csmev4ig4zu4nq6wqjutjdj5lvbwhvj57um2tya34/"
//       )

//       const setWhiteList  = await erc721_nft.addAirdropWhitelistAddresses(
//             [
//                 "0x60cc1b0a3543307acf398fc01676458555c4c62c",
//                 "0x60cc1b0a3543307acf398fc01676458555c4c62c",
//                 "0x60cc1b0a3543307acf398fc01676458555c4c62c",
//                 "0x60cc1b0a3543307acf398fc01676458555c4c62c",
//                 "0x60cc1b0a3543307acf398fc01676458555c4c62c",
//             ]) 

//         // const mintTeamNFTsTx  = await erc721_nft.mintTeamNFTs() 

//         // const tx = await erc721_nft.mint(1, { value: ethers.utils.parseEther("0.001") });

//       });
//   });


describe("ERC721  test", function () {
    it("Should test HappyMelodyCloset", async function () {
     
        const Lib = await ethers.getContractFactory("LibSalePhase");
        const lib = await Lib.deploy();
        await lib.deployed()

        const pricehexValue = ethers.utils.parseUnits("0.01", 18)
        const PRICE = pricehexValue.toString()

        const erc721Contract   = await ethers.getContractFactory("HappyMelodyCloset" ,
                {
                libraries: {
                    LibSalePhase: lib.address,
                },
                });

      const HappyMelodyAddress = "0x6C1A1E349607AB8e94B548fE58E955Ccc45B8375"
       const erc721_nft = await  erc721Contract.deploy(
        "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        PRICE,
        HappyMelodyAddress
       )
       await erc721_nft.deployed()

       const hexValue = ethers.utils.parseUnits("0.01", 18)
       const WEI_VALUE = hexValue.toString()
  
        await erc721_nft.addPhase(
            "public",
            100,
            100,
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            true,
            WEI_VALUE
       )

        //  const  setPhaseStatus =  await   erc721_nft.setPhaseStatus(1, 1)

        //  const tx = await erc721_nft.mint(
        //  1, 
        //  [], 
        //  { value: ethers.utils.parseEther("0.01") });

        //  const setTokenResultTx =  await erc721_nft.setUseToken(3, 0)

      });



       


  });