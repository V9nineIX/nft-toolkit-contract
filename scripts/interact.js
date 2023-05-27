// interact.js

const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = "0x8BE041b1AEe03304Fc237019E481B32755abEfA9";  // hello world contract address
const contract = require("../artifacts/contracts/Hello.sol/HelloWorld.json");
const { ethers } = require("hardhat");

// provider - Alchemy
const alchemyProvider = new ethers.providers.AlchemyProvider(network="rinkeby", API_KEY);
// signer - you
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);
// contract instance
const helloWorldContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);


async function main() {

    const message = await helloWorldContract.message();
    console.log("The message is: " + message); 

    console.log("Updating the message...");
    const tx = await helloWorldContract.update("this is the new message");
    await tx.wait();

    const newMessage = await helloWorldContract.message();
    console.log("The new message is: " + newMessage); 
} 

main()