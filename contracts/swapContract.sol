// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

//LINK, ETH, DAI, USDC
//Integrate chainlink
//transfer token to liquidity provider
//swap link for dai /// done 
//swap link for usdc ///done
//swap dai for link ///done
//swap dai for usdc ///done
//swap usdc for dai ///done
//swap usdc for link ///done

//remove liquidty.... give owner back the original token amount + gain.
// remoce 2 percent from swap amount and save it.


import {IToken} from "./IToken.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";



contract swapContract {
    using SafeCast for int256;
    AggregatorV3Interface internal DAIusdpriceFeed;
    AggregatorV3Interface internal LINKusdpriceFeed;
    AggregatorV3Interface internal ETHusdpriceFeed;
    AggregatorV3Interface internal USDCusdpriceFeed;
IToken DAI;
IToken LINK;
IToken USDC;
mapping(address => uint) DAIliquidityProvider;
address[] DAIliquidityProviders;

mapping(address => uint) LINKliquidityProvider;
address[] LINKliquidityProviders;

mapping(address => uint) ETHliquidityProvider;
address[] ETHliquidityProviders;

mapping(address => uint) USDCliquidityProvider;
address[] USDCliquidityProviders;

uint private Linkprofit;
uint private Daiprofit;

constructor(){
    DAI = IToken(0x6B175474E89094C44Da98b954EedeAC495271d0F);  //8 decimals
    LINK = IToken(0x514910771AF9Ca656af840dff83E8264EcF986CA); //18 decimals
    USDC = IToken(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // 8 decimals

DAIusdpriceFeed = AggregatorV3Interface(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9); //mainnet
LINKusdpriceFeed = AggregatorV3Interface(0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c); //mainnet
USDCusdpriceFeed = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6); //mainnet

}

//linkpricefeedGoerli = 0xb4c4a493AB6356497713A78FFA6c60FB53517c63
//daiPriceFeedGoerli = 0x0d79df66BE487753B02D015Fb622DED7f0E9798d
//usdcPriceFeedGoerli = 0xAb5c49580294Aff77670F839ea425f5b78ab3Ae7

function AddDAILiquidity(uint _amount)external  {
    DAI.transferFrom(msg.sender, address(this), _amount);
    DAIliquidityProvider[msg.sender] += _amount;
    DAIliquidityProviders.push(msg.sender);
}

function AddLINKLiquidity(uint _amount)external {
    LINK.transferFrom(msg.sender, address(this), _amount);
    LINKliquidityProvider[msg.sender] += _amount;
    LINKliquidityProviders.push(msg.sender);
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
function getLINKUSDPrice() public view returns (uint) {
        ( , int price, , , ) = LINKusdpriceFeed.latestRoundData();
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


function swapLINKforDai(uint link_amount) public {
    address receiver = msg.sender;
    LINK.transferFrom(msg.sender, address(this), link_amount);
    uint linkPrice = getLINKUSDPrice();
    uint daiPrice = getDAIUSDPrice();
    uint swappedAmount = (linkPrice * link_amount)/daiPrice ;
    uint balance = DAI.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    DAI.transferFrom(address(this), receiver, swappedAmount);

}

function swapDAIforLink(uint dai_amount) external {
    address receiver = msg.sender;
    DAI.transferFrom(msg.sender, address(this), dai_amount);
    uint linkPrice = getLINKUSDPrice();
    uint daiPrice = getDAIUSDPrice();
    uint swappedAmount = (daiPrice * dai_amount)/linkPrice;
    uint balance = LINK.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    LINK.transferFrom(address(this), receiver, swappedAmount);
}


function swapLINKforUsdc(uint link_amount) public {
    address receiver = msg.sender;
    LINK.transferFrom(msg.sender, address(this), link_amount);
    uint linkPrice = getLINKUSDPrice();
    uint usdcPrice = getUSDCUSDPrice();
    uint converted = link_amount/1e18;
    uint swappedAmount = (linkPrice * converted)/usdcPrice ;
    uint balance = USDC.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    USDC.transferFrom(address(this), receiver, swappedAmount);

}


function swapUSDCforLink(uint usdc_amount) public {
    address receiver = msg.sender;
    USDC.transferFrom(msg.sender, address(this), usdc_amount);
    uint linkPrice = getLINKUSDPrice();
    uint usdcPrice = getUSDCUSDPrice();
    uint swappedAmount = (usdcPrice/linkPrice) * usdc_amount;
    uint balance = LINK.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    LINK.transferFrom(address(this), receiver, swappedAmount);

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
    uint balance = LINK.balanceOf(address(this));
    require(balance >= swappedAmount, "not enough liquidity, check back");
    DAI.transferFrom(address(this), receiver, swappedAmount);

}


}