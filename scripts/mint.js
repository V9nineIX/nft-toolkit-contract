const { ethers , waffle} = require("hardhat");
const hre = require("hardhat");
const abi = require("./abi.js")

const contractABI =  abi;

const contractAddress = "0x99dC6dD0ab380F9e1B8d4dE0746E713eEBB6E7a6"

async function main() {
    const [signer] = await ethers.getSigners();
    const contract = new ethers.Contract(contractAddress, contractABI, signer);

    // const  isAirdropActive  =  await  contract.isAirdropActive()

    // console.log("isAirdropActive", isAirdropActive)




    // const  whitelistAddressesAirdrop = await contract.getWhitelistAddressesAirdrop()
    // console.log("whitelistAddressesAirdrop" ,whitelistAddressesAirdrop)



    const tx = await contract.mint(100, { value: ethers.utils.parseEther("0") });
    const receipt = await tx.wait()
    for (const event of receipt.events) {
      console.log(`Event ${event.event} with args ${event.args}`);
    }
 

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
