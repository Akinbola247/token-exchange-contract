// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

//UNI, ETH, DAI, USDC
//Integrate chainUNI
//transfer token to liquidity provider
//swap UNI for dai /// done 
//swap UNI for usdc ///done
//swap dai for UNI ///done
//swap dai for usdc ///done
//swap usdc for dai ///done
//swap usdc for UNI ///done

//remove liquidty.... give owner back the original token amount + gain.
// remoce 2 percent from swap amount and save it.


import {IToken} from "./IToken.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";



contract swapContract {
    using SafeCast for int256;
    AggregatorV3Interface internal DAIusdpriceFeed;
    AggregatorV3Interface internal UNIusdpriceFeed;
    AggregatorV3Interface internal ETHusdpriceFeed;
    AggregatorV3Interface internal USDCusdpriceFeed;
IToken DAI;
IToken UNI;
IToken USDC;
mapping(address => uint) DAIliquidityProvider;
address[] DAIliquidityProviders;

mapping(address => uint) UNIliquidityProvider;
address[] UNIliquidityProviders;

mapping(address => uint) ETHliquidityProvider;
address[] ETHliquidityProviders;

mapping(address => uint) USDCliquidityProvider;
address[] USDCliquidityProviders;

uint private UNIprofit;
uint private Daiprofit;

constructor(){
    DAI = IToken(0x6B175474E89094C44Da98b954EedeAC495271d0F);  //8 decimals
    UNI = IToken(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984); //18 decimals
    USDC = IToken(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // 8 decimals

DAIusdpriceFeed = AggregatorV3Interface(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9); //mainnet
UNIusdpriceFeed = AggregatorV3Interface(0x553303d460EE0afB37EdFf9bE42922D8FF63220e); //mainnet
USDCusdpriceFeed = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6); //mainnet

}

//UNIpricefeedGoerli = 0xb4c4a493AB6356497713A78FFA6c60FB53517c63
//daiPriceFeedGoerli = 0x0d79df66BE487753B02D015Fb622DED7f0E9798d
//usdcPriceFeedGoerli = 0xAb5c49580294Aff77670F839ea425f5b78ab3Ae7

function AddDAILiquidity(uint _amount)external  {
    DAI.transferFrom(msg.sender, address(this), _amount);
    DAIliquidityProvider[msg.sender] += _amount;
    DAIliquidityProviders.push(msg.sender);
}

function AddUNILiquidity(uint _amount)external {
    UNI.transferFrom(msg.sender, address(this), _amount);
    UNIliquidityProvider[msg.sender] += _amount;
    UNIliquidityProviders.push(msg.sender);
}

function AddUSDCLiquidity(uint _amount) external {
    USDC.transferFrom(msg.sender, address(this), _amount);
    USDCliquidityProvider[msg.sender] += _amount;
    USDCliquidityProviders.push(msg.sender);
}


function getDAIUSDPrice() public view returns (uint) {
        ( , int price, , , ) = DAIusdpriceFeed.latestRoundData();
        return price.toUint256();
    }
function getUNIUSDPrice() public view returns (uint) {
        ( , int price, , , ) = UNIusdpriceFeed.latestRoundData();
        return price.toUint256();
    }
// function getETHUSDPrice() public view returns (uint) {
//         ( , int price, , , ) = ETHusdpriceFeed.latestRoundData();
//         return price.toUint256();
//     }
function getUSDCUSDPrice() public view returns (uint) {
        ( , int price, , , ) = DAIusdpriceFeed.latestRoundData();
        return price.toUint256();
    }


function swapUNIforDai(uint UNI_amount) public {
    address receiver = msg.sender;
    UNI.transferFrom(msg.sender, address(this), UNI_amount);
    uint UNIPrice = getUNIUSDPrice();
    uint daiPrice = getDAIUSDPrice();
    uint swappedAmount = (UNIPrice * UNI_amount)/daiPrice ;
    uint balance = DAI.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    DAI.transferFrom(address(this), receiver, swappedAmount);

}

function swapDAIforUNI(uint dai_amount) external {
    address receiver = msg.sender;
    DAI.transferFrom(msg.sender, address(this), dai_amount);
    uint UNIPrice = getUNIUSDPrice();
    uint daiPrice = getDAIUSDPrice();
    uint swappedAmount = (daiPrice * dai_amount)/UNIPrice;
    uint balance = UNI.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    UNI.transferFrom(address(this), receiver, swappedAmount);
}


function swapUNIforUsdc(uint UNI_amount) public {
    uint converted = UNI_amount/1e18;
    address receiver = msg.sender;
    UNI.transferFrom(msg.sender, address(this), converted);
    uint UNIPrice = getUNIUSDPrice();
    uint usdcPrice = getUSDCUSDPrice();
    
    uint swappedAmount = (UNIPrice * converted)/usdcPrice ;
    uint balance = USDC.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    USDC.transferFrom(address(this), receiver, swappedAmount);

}


function swapUSDCforUNI(uint usdc_amount) public {
    address receiver = msg.sender;
    USDC.transferFrom(msg.sender, address(this), usdc_amount);
    uint UNIPrice = getUNIUSDPrice();
    uint usdcPrice = getUSDCUSDPrice();
    uint swappedAmount = (usdcPrice/UNIPrice) * usdc_amount;
    uint balance = UNI.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    UNI.transferFrom(address(this), receiver, swappedAmount);

}

function swapDAIforUsdc(uint dai_amount) public {
    address receiver = msg.sender;
    DAI.transferFrom(msg.sender, address(this), dai_amount);
    uint usdcPrice = getUSDCUSDPrice();
    uint daiPrice = getDAIUSDPrice();
    uint swappedAmount = (daiPrice/usdcPrice) * dai_amount;
    uint balance = USDC.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    USDC.transferFrom(address(this), receiver, swappedAmount);
}

function swapUSDCforDai(uint usdc_amount) public {
    address receiver = msg.sender;
    USDC.transferFrom(msg.sender, address(this), usdc_amount);
    uint daiPrice = getDAIUSDPrice();
    uint usdcPrice = getUSDCUSDPrice();
    uint swappedAmount = (usdcPrice/daiPrice) * usdc_amount;
    uint balance = UNI.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    DAI.transferFrom(address(this), receiver, swappedAmount);

}


}