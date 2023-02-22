import { ethers } from "hardhat";
import { BigNumber } from "ethers";


async function main() {
    const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const DAIHolder = "0x748dE14197922c4Ae258c7939C7739f3ff1db573";

    const UNI = "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984";
    const UNIHolder = "0x56178a0d5F301bAf6CF3e1Cd53d9863437345Bf9";

    const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const USDCHolder = "0x56178a0d5F301bAf6CF3e1Cd53d9863437345Bf9";

  const Swap = await ethers.getContractFactory("swapContract");
  const swap = await Swap.deploy();
  await swap.deployed();
  console.log(`swap contract deployed to ${swap.address}`);

//DAI impersonation
const helpers = require("@nomicfoundation/hardhat-network-helpers");
  await helpers.impersonateAccount(DAIHolder);
  const DAIimpersonatedSigner = await ethers.getSigner(DAIHolder);
  const DAIContract = await ethers.getContractAt("IToken", DAI);
    const balanceBeforeSwap = await DAIContract.balanceOf(DAIHolder);
    console.log(`balance of dai owner before swap ${balanceBeforeSwap}`)
//UNI impersonation
  await helpers.impersonateAccount(UNIHolder);
  const UNIimpersonatedSigner = await ethers.getSigner(UNIHolder);
  const UNIContract = await ethers.getContractAt("IToken", UNI);
  const balance2beforeSwap = await UNIContract.balanceOf(UNIHolder);
  console.log(`balance of UNI owner before swap ${balance2beforeSwap}`);

//USDC impersonation
await helpers.impersonateAccount(USDCHolder);
  const USDCimpersonatedSigner = await ethers.getSigner(USDCHolder);
  const USDCContract = await ethers.getContractAt("IToken", USDC);
  const USDCbalancebeforeSwap = await USDCContract.balanceOf(USDCHolder);
  console.log(`balance of USDC owner before swap ${USDCbalancebeforeSwap}`);



//   Add DAI liquidity
    const amount = ethers.utils.parseEther("50");
    const approval = await DAIContract.connect(DAIimpersonatedSigner).approve(swap.address, amount);
    await swap.connect(DAIimpersonatedSigner).AddDAILiquidity(amount);
    const daiOwner = await DAIContract.balanceOf(DAIHolder);
    const contractDAIbalance = await DAIContract.balanceOf(swap.address);
    console.log(`Dai Owner balance after adding liquidity ${daiOwner}`)
    console.log(`contract Dai balance after liquidity Add ${contractDAIbalance}`);

// Add UNI liquidity
const amount1 = ethers.utils.parseEther("50");
    const approval1 = await UNIContract.connect(UNIimpersonatedSigner).approve(swap.address, amount1);
    await swap.connect(UNIimpersonatedSigner).AddUNILiquidity(amount1);
    const UNIOwner = await UNIContract.balanceOf(UNIHolder);
    const contractUNIbalance = await UNIContract.balanceOf(swap.address);
    console.log(`UNI Owner balance after adding liquidity ${UNIOwner}`)
    console.log(`contract UNI balance after liquidity Add ${contractUNIbalance}`);


//Add USDC liquidity
const amount3 = 50000000
    const approval2 = await USDCContract.connect(USDCimpersonatedSigner).approve(swap.address, amount3);
    await swap.connect(USDCimpersonatedSigner).AddUSDCLiquidity(amount3);
    const USDCOwner = await USDCContract.balanceOf(USDCHolder);
    const contractUSDCbalance = await USDCContract.balanceOf(swap.address);
    console.log(`usdc Owner balance after adding liquidity ${USDCOwner}`)
    console.log(`contract usdc balance after liquidity Add ${contractUSDCbalance}`);

// swap UNI for DAI 
const amountToSwap = ethers.utils.parseEther("1");
const approvall = await UNIContract.connect(UNIimpersonatedSigner).approve(swap.address, amountToSwap);
await swap.connect(UNIimpersonatedSigner).swapUNIforDai(amountToSwap);
const DaiSwapbalance = await DAIContract.balanceOf(UNIHolder);
console.log(`new dai owner balance after swap is ${DaiSwapbalance}`)
const contractRemaindDAI = await DAIContract.balanceOf(swap.address);
const contractRemaindUNI = await UNIContract.balanceOf(swap.address);
console.log(`contract Dai balance after last swap ${contractRemaindDAI}`);
console.log(`contract UNI balance after last swap ${contractRemaindUNI}`);

// swap UNI for USDC
const amountToSwapp = ethers.utils.parseEther("10");
const approves = await UNIContract.connect(UNIimpersonatedSigner).approve(swap.address, amountToSwapp);
console.log("working...")
await swap.connect(UNIimpersonatedSigner).swapUNIforUsdc(100000);
const UsdcSwapbalance = await USDCContract.balanceOf(UNIHolder);
console.log(`new usdc owner balance after swap is ${UsdcSwapbalance}`)
const contractRemaindUSDC = await DAIContract.balanceOf(swap.address);
const contractRemaindUNIK = await UNIContract.balanceOf(swap.address);
console.log(`contract USDC balance after last22 swap ${contractRemaindUNIK}`);
console.log(`contract UNI balance after last22 swap ${contractRemaindUNIK}`);


//swap DAI for UNI 
// const amountToSwap2 = ethers.utils.parseEther("1");
// const approvall4 = await DAIContract.connect(DAIimpersonatedSigner).approve(swap.address, amountToSwap2);
// console.log("working...");
// await swap.connect(DAIimpersonatedSigner).swapDAIforUNI(amountToSwap2);
// console.log("still working");
// const UNISwapbalance = await UNIContract.balanceOf(DAIHolder);
// console.log(`new UNI owner balance after swap is ${UNISwapbalance}`)
// const contractRemaindDAII = await DAIContract.balanceOf(swap.address);
// const contractRemaindUNIL = await UNIContract.balanceOf(swap.address);
// console.log(`contract Dai balance after 2nd swap ${contractRemaindDAII}`);
// console.log(`contract UNI balance after 2nd swap ${contractRemaindUNIL}`);

}



main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
