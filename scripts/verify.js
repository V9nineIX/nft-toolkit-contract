const hre = require("hardhat");

async function main() {

  await run('compile');

  await hre.run("verify:verify", {
    address: "0x869846D7ec6871e5d9998FB648367Ab22C6164e9",
    contract: "contracts/FactoryNFT.sol:FactoryNFT", //Filename.sol:ClassName
    constructorArguments: ['']
  });



   
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
