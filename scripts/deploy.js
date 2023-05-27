// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  await run('compile');





const Lib = await ethers.getContractFactory("LibSalePhase");
const lib = await Lib.deploy();
await lib.deployed()

console.log("lib  deployed to address:",lib.address);

//   const erc721Contract    = await ethers.getContractFactory("Template721A" ,
//    {
//     libraries: {
//         LibSalePhase: lib.address,
//     },
//   });
//   const erc721_nft = await  erc721Contract.deploy('','');

//   await  erc721_nft.deployed()

//   console.log("ERC721 NFT Contract deployed to address:", erc721_nft.address);


//Deploy 721 with random 


const pricehexValue = ethers.utils.parseUnits("0.001", 18)
const PRICE = pricehexValue.toString()

const erc721Contract   = await ethers.getContractFactory("HappyMelodyCloset" ,
{
 libraries: {
     LibSalePhase: lib.address,
 },
});

  const HappyMelodyAddress = "0x6C1A1E349607AB8e94B548fE58E955Ccc45B8375"
  const erc721_nft = await  erc721Contract.deploy(
    "https://sleepy-hev-api.onepirate.finance/folder/579a260e-91f8-49d5-a034-012819fb3267-Happy-closet/build/json/",
    PRICE,
    HappyMelodyAddress
  );

  await  erc721_nft.deployed()

  console.log("ERC721 NFT Contract deployed to address:", erc721_nft.address);



//HappyMelody



// const erc721Contract   = await ethers.getContractFactory("HappyMelody" ,
// {
//  libraries: {
//      LibSalePhase: lib.address,
//  },
// });

//   const erc721_nft = await  erc721Contract.deploy(
//     "ipfs://bafybeietaxys6gooi4wj6kfmmem3qifhx2ue5csowzjled3tdt4wamdeke/",
//      PRICE,
//      "0x60Cc1b0a3543307Acf398fC01676458555C4c62C",
//      "0x5F0685BD746dBe3190fDB4e3B3CfCE3F0CD292B3"
//   );

//   await  erc721_nft.deployed()

//   console.log("ERC721 NFT Contract deployed to address:", erc721_nft.address);

//   await erc721_nft.addAirdropWhitelistAddresses(["0x60Cc1b0a3543307Acf398fC01676458555C4c62C"])

//   await erc721_nft.setAirdropActive(true)

// const erc1555Contract    = await ethers.getContractFactory("Ko1155" ,
// {
//  libraries: {
//      LibSalePhase: lib.address,
//  },
// });
// const erc155_nft = await  erc1555Contract.deploy('');
// console.log("ERC1155 NFT Contract deployed to address:", erc155_nft.address);
// await  erc155_nft.deployed()

// await erc155_nft.addItemKeys([1,2,3,4,5], [10,10,10,5,1])

// const maxMintPerTX =  await erc155_nft.setBaseURI("ipfs://QmcYEtN6ua3isahyeNSzDDKvmvN7QNFb2Pm6MqaUfYow5e/")
// console.log("maxMintPerTX" ,  maxMintPerTX)



// const hexValue = ethers.utils.parseUnits("0.005", 18)
//  const WEI_VALUE = hexValue.toString()
  
//   await erc155_nft.addPhase(
// 	"public",
// 	 100,
// 	 10,
// 	 "0x6173647361647361647361647361646173647361640000000000000000000000",
// 	 true,
//      WEI_VALUE
//   )

//   await erc721_nft.addPhase(
// 	"private",
// 	 33,
// 	 1,
// 	 "0x6173647361647361647361647361646173647361640000000000000000000000",
// 	 true,
//      WEI_VALUE
//   )
   


//  const  res =  await  erc155_nft.setPhaseStatus(1, 1)
//  const  tx =    await  erc155_nft.mint(1 ,{ value: ethers.utils.parseEther("0.005")})

//  const  tx2 =    await  erc155_nft.mint(2 ,{ value: ethers.utils.parseEther("0.01")})
//   //console.log("res" , res)
  
//   const  tx  =   await  erc721_nft.mint(1 ,{ value: ethers.utils.parseEther("0.01")})
// //   const  tx2  =   await  erc721_nft.mint(1 ,{ value: ethers.utils.parseEther("0.005")})
// //   const  tx3  =   await  erc721_nft.mint(1 ,{ value: ethers.utils.parseEther("0.005")})
   


// //   const resBL =  await erc721_nft.balanceOf('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266')
// //   console.log("resBL", resBL)
 
//  const receipt = await tx.wait()

// //   const  availble =  await  erc721_nft.getMintAvailableAddress("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")

// //   console.log("avaible",availble)
// // Mock

//   await erc721_nft.setBaseURI("ipfs://QmcYEtN6ua3isahyeNSzDDKvmvN7QNFb2Pm6MqaUfYow5e/", ".json")

//   for (const event of receipt.events) {
//     console.log(`Event ${event.event} with args ${event.args}`);
//   }





//    const mintTx = await erc155_nft.getLastedMintTransection("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//    const tokenId  =  ethers.utils.formatUnits(mintTx[0], 0)
//    console.log("mintTx" ,  tokenId  )


//     const tokenUrl = await erc155_nft.uri(tokenId)
//     console.log("tokenUrl", tokenUrl)


//     const remian =    await erc155_nft.mintableLeft()
//     console.log("remain" , remian)


//     const max  =  await erc155_nft.maxSupply()
//     console.log("max" , max)


//     const phasetotalMint  =  await erc155_nft.getPhaseTotalMint(1)
//     console.log("phasetotalMint" ,phasetotalMint)


//     const mintAvalible  =  await erc155_nft.getMintAvailableAddress("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
//     console.log(" mintAvalible " , mintAvalible )



//  const  res2  =  await  erc721_nft.getAllPhase();
//  console.log(res2)


//   const factoryNFTContarct = await ethers.getContractFactory("FactoryNFT");
//   const factory_nft = await factoryNFTContarct.deploy();
//   await factory_nft.deployed()
//   console.log("Factory NFT Contract deployed to address:", factory_nft.address);
//   await factory_nft.setAddress721( factory_nft.address)


///verify  smart contract

  await hre.run("verify:verify", {
    address:  lib.address,
    contract: "contracts/LibSalePhase.sol:LibSalePhase", //Filename.sol:ClassName
    constructorArguments: [],
  });

  await erc721_nft.deployTransaction.wait(10);

//   await hre.run("verify:verify", {
//     address:  erc721_nft.address,
//     contract: "contracts/Random721.sol:Template721ARandom", //Filename.sol:ClassName
//     constructorArguments: [],
//   });


//   await hre.run("verify:verify", {
//     address:  erc721_nft.address,
//     contract: "contracts/HappyMelody.sol:HappyMelody", //Filename.sol:ClassName
//     constructorArguments: [
//         "ipfs://bafybeietaxys6gooi4wj6kfmmem3qifhx2ue5csowzjled3tdt4wamdeke/",
//         PRICE,
//         "0x60Cc1b0a3543307Acf398fC01676458555C4c62C",
//         "0x5F0685BD746dBe3190fDB4e3B3CfCE3F0CD292B3"
//     ],
//   });


// await erc155_nft.deployTransaction.wait(5);

//   await hre.run("verify:verify", {
//     address:  erc155_nft.address,
//     contract: "contracts/Ko1155.sol:Ko1155", //Filename.sol:ClassName
//     constructorArguments: ['']
//   });


} // endmain

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
