import { ethers } from "hardhat";


async function main() {
    const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const DAIHolder = "0x748dE14197922c4Ae258c7939C7739f3ff1db573";

    const LINK = "0x514910771AF9Ca656af840dff83E8264EcF986CA";
    const LINKHolder = "0x56178a0d5F301bAf6CF3e1Cd53d9863437345Bf9";

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
//LINK impersonation
  await helpers.impersonateAccount(LINKHolder);
  const LINKimpersonatedSigner = await ethers.getSigner(LINKHolder);
  const LINKContract = await ethers.getContractAt("IToken", LINK);
  const balance2beforeSwap = await LINKContract.balanceOf(LINKHolder);
  console.log(`balance of link owner before swap ${balance2beforeSwap}`);

//USDC impersonation
await helpers.impersonateAccount(USDCHolder);
  const USDCimpersonatedSigner = await ethers.getSigner(USDCHolder);
  const USDCContract = await ethers.getContractAt("IToken", USDC);
  const USDCbalancebeforeSwap = await USDCContract.balanceOf(USDCHolder);
  console.log(`balance of link owner before swap ${USDCbalancebeforeSwap}`);



//   Add DAI liquidity
    const amount = ethers.utils.parseEther("5");
    const approval = await DAIContract.connect(DAIimpersonatedSigner).approve(swap.address, amount);
    await swap.connect(DAIimpersonatedSigner).AddDAILiquidity(amount);
    const daiOwner = await DAIContract.balanceOf(DAIHolder);
    const contractDAIbalance = await DAIContract.balanceOf(swap.address);
    console.log(`Dai Owner balance after adding liquidity ${daiOwner}`)
    console.log(`contract Dai balance after liquidity Add ${contractDAIbalance}`);

// Add LINK liquidity
const amount1 = ethers.utils.parseEther("50");
    const approval1 = await LINKContract.connect(LINKimpersonatedSigner).approve(swap.address, amount1);
    await swap.connect(LINKimpersonatedSigner).AddLINKLiquidity(amount1);
    const linkOwner = await LINKContract.balanceOf(LINKHolder);
    const contractLINKbalance = await LINKContract.balanceOf(swap.address);
    console.log(`link Owner balance after adding liquidity ${linkOwner}`)
    console.log(`contract link balance after liquidity Add ${contractLINKbalance}`);


//Add USDC liquidity
const amount3 = ethers.utils.parseEther("50");
    const approval2 = await LINKContract.connect(LINKimpersonatedSigner).approve(swap.address, amount3);
    await swap.connect(USDCimpersonatedSigner).AddUSDCLiquidity(amount3);
    const USDCOwner = await USDCContract.balanceOf(USDCHolder);
    const contractUSDCbalance = await USDCContract.balanceOf(swap.address);
    console.log(`link Owner balance after adding liquidity ${USDCOwner}`)
    console.log(`contract usdc balance after liquidity Add ${contractUSDCbalance}`);

// swap LINK for DAI 
const amountToSwap = ethers.utils.parseEther("0.01");
const approvall = await LINKContract.connect(LINKimpersonatedSigner).approve(swap.address, amountToSwap);
await swap.connect(LINKimpersonatedSigner).swapLINKforDai(amountToSwap);
const DaiSwapbalance = await DAIContract.balanceOf(LINKHolder);
console.log(`new dai owner balance after swap is ${DaiSwapbalance}`)
const contractRemaindDAI = await DAIContract.balanceOf(swap.address);
const contractRemaindLINK = await LINKContract.balanceOf(swap.address);
console.log(`contract Dai balance after last swap ${contractRemaindDAI}`);
console.log(`contract LINK balance after last swap ${contractRemaindLINK}`);

//swap LINK for USDC
const amountToSwapp = ethers.utils.parseEther("5");
const approves = await LINKContract.connect(LINKimpersonatedSigner).approve(swap.address, amountToSwapp);
await swap.connect(LINKimpersonatedSigner).swapLINKforUsdc(1000);
const UsdcSwapbalance = await USDCContract.balanceOf(LINKHolder);
console.log(`new usdc owner balance after swap is ${UsdcSwapbalance}`)
const contractRemaindUSDC = await DAIContract.balanceOf(swap.address);
const contractRemaindLINKK = await LINKContract.balanceOf(swap.address);
console.log(`contract USDC balance after last swap ${contractRemaindLINKK}`);
console.log(`contract LINK balance after last swap ${contractRemaindLINKK}`);


//swap DAI for LINK 
// const amountToSwap2 = 2000;
// const approvall4 = await DAIContract.connect(DAIimpersonatedSigner).approve(swap.address, amountToSwap2);
// console.log("working...");
// await swap.connect(DAIimpersonatedSigner).swapDAIforLink(amountToSwap2);
// console.log("still working");
// const linkSwapbalance = await LINKContract.balanceOf(DAIHolder);
// console.log(`new link owner balance after swap is ${linkSwapbalance}`)
// const contractRemaindDAII = await DAIContract.balanceOf(swap.address);
// const contractRemaindLINKL = await LINKContract.balanceOf(swap.address);
// console.log(`contract Dai balance after 2nd swap ${contractRemaindDAII}`);
// console.log(`contract LINK balance after 2nd swap ${contractRemaindLINKL}`);

}



main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
