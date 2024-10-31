// import { ethers } from "hardhat";

const { ethers } = require("hardhat") 


async function main() {
    // create factory
    const fundMeFactory = await ethers.getContractFactory("FundMe")
    // deploy contract from factory
    const fundMe        = await fundMeFactory.deploy(10)
    // confirm contract has been in in-chain, 确保合约已经在链上
    await fundMe.waitForDeployment()
    console.log(`contract has been deployed successfully, contract address is ${fundMe.target}`)
}

// execute main function
main().then().catch((error) => {
    console.error(error)
    process.exit(0)
})

