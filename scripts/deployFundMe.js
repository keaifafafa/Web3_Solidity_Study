// import { ethers } from "hardhat";

const { ethers } = require("hardhat") 


async function main() {
    // create factory
    const fundMeFactory = await ethers.getContractFactory("FundMe")
    // deploy contract from factory
    const fundMe        = await fundMeFactory.deploy(300)
    // confirm contract has been in in-chain, 确保合约已经在链上
    await fundMe.waitForDeployment()
    console.log(`contract has been deployed successfully, contract address is ${fundMe.target}`)

    // verify fundme
    if (hre.network.config.chainId == 11155111 && process.env.API_KEY) {
        console.log("Waiting for 5 confirmations")
        await fundMe.deploymentTransaction().wait(5) 
        await verifyFundMe(fundMe.target, [300])
    } else {
        console.log("verification skipped...");
    }

     // init 2 accounts
     const [firstAccount, secondAccount] = await ethers.getSigners()
    
     // fund contract with first account
     const fundTx = await fundMe.fund({value: ethers.parseEther("0.5")})
     await fundTx.wait()
 
     console.log(`2 accounts are ${firstAccount.address} and ${secondAccount.address}`)
     
     // check balance of contract
     const balanceOfContract = await ethers.provider.getBalance(fundMe.target)
     console.log(`Balance of the contract is ${balanceOfContract}`)
 
     // fund contract with second account
     const fundTxWithSecondAccount = await fundMe.connect(secondAccount).fund({value: ethers.parseEther("0.5")})
     await fundTxWithSecondAccount.wait()
 
     // check balance of contract
     const balanceOfContractAfterSecondFund = await ethers.provider.getBalance(fundMe.target)
     console.log(`Balance of the contract is ${balanceOfContractAfterSecondFund}`)
 
     // check mapping 
     const firstAccountbalanceInFundMe = await fundMe.fundersToAmount(firstAccount.address)
     const secondAccountbalanceInFundMe = await fundMe.fundersToAmount(secondAccount.address)
     console.log(`Balance of first account ${firstAccount.address} is ${firstAccountbalanceInFundMe}`)
     console.log(`Balance of second account ${secondAccount.address} is ${secondAccountbalanceInFundMe}`)

}

/**
 * 验证FundMe
 * @param {yanzh} fundMeAddr 
 * @param {*} args 
 */
async function verifyFundMe(fundMeAddr, args) {
    await hre.run("verify:verify", {
        address: fundMeAddr,
        constructorArguments: args,
      });
}

// execute main function
main().then().catch((error) => {
    console.error(error)
    process.exit(0)
})

