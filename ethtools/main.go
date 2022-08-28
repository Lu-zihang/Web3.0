// SPDX-License-Identifier: MIT
package main

import (
	"CoinTrack/asset"
	IERC20 "CoinTrack/interfaces/IERC20"
	IERC721 "CoinTrack/interfaces/IERC721"
	IUniswapV2Router01 "CoinTrack/interfaces/IUniswap"
	"crypto/ecdsa"
	"fmt"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

type Nodes map[string]string

type SmartContract struct {
	Client      *ethclient.Client
	PrivateKey  *ecdsa.PrivateKey
	Address     string
	Transaction string
	Self        *asset.Asset
}

type Standard struct {
	// ERC20
	ERC20 struct {
		// Returns the amount of tokens in existence.
		TotalSupply *big.Int
		// Returns the amount of tokens owned by `account`.
		BalanceOf func(address string) *big.Int
		// Moves `amount` tokens from the caller's account to `recipient`.
		Transfer func(receiver string, amount string) (*types.Transaction, bool)
		// Returns the remaining number of tokens that `spender` will be allowed to spend on behalf of `owner` through {transferFrom}.
		Allowance func(owner string, spender string) *big.Int
		// Returns a boolean value indicating whether the operation succeeded.
		Approve func(spender string, amount string) (*types.Transaction, bool)
	}

	// ERC721
	ERC721 struct {
		// Returns the number of tokens in ``owner``'s account.
		BalanceOf func(owner string) *big.Int
		// Returns the owner of the `tokenId` token.
		OwnerOf func(tokenId string) string
		// The approval is cleared when the token is transferred.
		Approve func(to string, tokenId string) (*types.Transaction, bool)
		// Returns the account approved for `tokenId` token.
		GetApproved func(tokenId string) string
		// Approve or remove `operator` as an operator for the caller.
		// Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
		SetApprovalForAll func(operator string, _approved bool) (*types.Transaction, bool)
	}
}

type DexSwap struct {
	// The struct of Uniswap
	IUniswap struct {
		// Read-only Function
		Factory string
		WETH    string
		// Useful for calculating optimal token amounts before calling swap.
		GetAmountsOut func(amount string, path []string) []*big.Int
	}
}

type SwapTokenPair struct {
	TokenIn   string
	TokenOut  string
	AmountIn  string
	AmountOut string
	Describe  string
}

// Dial connects a client to the given URL.
func Dial(s *SmartContract, node Nodes) {
	client, err := ethclient.Dial(node["Rinkeby"])
	if err != nil {
		log.Fatal(err)
	}

	s.Client = client
}

// Deployed smart contract
func DeployContract(privateKey string, node string) *SmartContract {
	contract := new(SmartContract)
	contract.Private(privateKey)
	auth := contract.Auth()

	address, tx, instance, err := asset.DeployAsset(auth, contract.Client)
	if err != nil {
		log.Fatal(err)
	}

	return &SmartContract{
		Address:     address.Hex(),
		Transaction: tx.Hash().Hex(),
		Self:        instance,
	}
}

// Private Return wallet private key.
func (s *SmartContract) Private(secret string) {
	privatekey, err := crypto.HexToECDSA(secret)
	if err != nil {
		log.Fatal(err)
	}

	s.PrivateKey = privatekey
}

func (s *SmartContract) Auth() *bind.TransactOpts {
	auth := bind.NewKeyedTransactor(s.PrivateKey)
	auth.Nonce = big.NewInt(int64(10))
	auth.Value = big.NewInt(0)
	auth.GasLimit = uint64(20000)
	return auth
}

// #######################################################
// ################ ERC Standard Function ################
// #######################################################
func ERCStandard(sc *SmartContract, std *Standard, this string, _type string) *Standard {
	if sc.Client == nil {
		panic("Please ensure that a client connection is established!")
	}

	target := common.HexToAddress(this)

	// creates a new instance of IERC20 Interfaces
	erc20 := func(std *Standard) {
		IERC20, err := IERC20.NewInterfaces(target, sc.Client)
		if err != nil {
			log.Fatal(err)
		}

		// call BalanceOf
		std.ERC20.BalanceOf = func(address string) *big.Int {
			bal, err := IERC20.BalanceOf(&bind.CallOpts{}, common.HexToAddress(address))
			if err != nil {
				log.Fatal(err)
			}
			return bal
		}

		total, err := IERC20.TotalSupply(&bind.CallOpts{})
		if err != nil {
			log.Fatal(err)
		}
		std.ERC20.TotalSupply = total

		std.ERC20.Transfer = func(receiver string, amount string) (*types.Transaction, bool) {
			n := new(big.Int)
			n, _ = n.SetString(amount, 10)
			transaction, err := IERC20.Transfer(&bind.TransactOpts{}, common.HexToAddress(receiver), n)
			if err != nil {
				log.Fatal(err)
				return nil, false
			}
			return transaction, true
		}

		std.ERC20.Allowance = func(owner string, spender string) *big.Int {
			amount, err := IERC20.Allowance(&bind.CallOpts{}, common.HexToAddress(owner), common.HexToAddress(spender))
			if err != nil {
				log.Fatal(err)
			}
			return amount
		}

		std.ERC20.Approve = func(spender string, amount string) (*types.Transaction, bool) {
			n := new(big.Int)
			n, _ = n.SetString(amount, 10)
			transaction, err := IERC20.Approve(&bind.TransactOpts{}, common.HexToAddress(spender), n)
			if err != nil {
				log.Fatal(err)
				return nil, false
			}
			return transaction, true
		}

	}

	// creates a new instance of IERC721 Interfaces
	erc721 := func(std *Standard) {
		IERC721, err := IERC721.NewIERC721(target, sc.Client)
		if err != nil {
			log.Fatal(err)
		}

		std.ERC721.BalanceOf = func(owner string) *big.Int {
			bal, err := IERC721.BalanceOf(&bind.CallOpts{}, common.HexToAddress(owner))
			if err != nil {
				log.Fatal(err)
			}
			return bal
		}

		std.ERC721.OwnerOf = func(tokenId string) string {
			id := new(big.Int)
			id, _ = id.SetString(tokenId, 10)
			address, err := IERC721.OwnerOf(&bind.CallOpts{}, id)
			if err != nil {
				log.Fatal(err)
			}
			return address.String()
		}

		std.ERC721.Approve = func(to string, tokenId string) (*types.Transaction, bool) {
			id := new(big.Int)
			id, _ = id.SetString(tokenId, 10)
			transaction, err := IERC721.Approve(&bind.TransactOpts{}, common.HexToAddress(to), id)
			if err != nil {
				log.Fatal(err)
				return nil, false
			}
			return transaction, true
		}

		std.ERC721.GetApproved = func(tokenId string) string {
			id := new(big.Int)
			id, _ = id.SetString(tokenId, 10)
			address, err := IERC721.GetApproved(&bind.CallOpts{}, id)
			if err != nil {
				log.Fatal(err)
			}
			return address.String()
		}

		std.ERC721.SetApprovalForAll = func(operator string, _approved bool) (*types.Transaction, bool) {
			transaction, err := IERC721.SetApprovalForAll(&bind.TransactOpts{}, common.HexToAddress(operator), _approved)
			if err != nil {
				log.Fatal(err)
				return nil, false
			}
			return transaction, true
		}
	}

	switch _type {
	case "ERC20":
		erc20(std)

	case "ERC721":
		erc721(std)
	}

	return std
}

// ###########################################################
// ################ Dex Swap Operator Function ###############
// ###########################################################
func DexSwapCall(s *SmartContract, dex *DexSwap, this string, _type string) *DexSwap {
	if s.Client == nil {
		panic("Please ensure that a client connection is established!")
	}

	target := common.HexToAddress(this)

	uniswap := func(dex *DexSwap) {
		// creates a new read-only instance of IUniswapV2Router01.
		IUniswapV2Router01Caller, err := IUniswapV2Router01.NewIUniswapV2Router01Caller(target, s.Client)
		if err != nil {
			log.Fatal(err)
		}

		address, err := IUniswapV2Router01Caller.Factory(&bind.CallOpts{})
		if err != nil {
			log.Fatal(err)
		}
		dex.IUniswap.Factory = address.String()

		weth, err := IUniswapV2Router01Caller.WETH(&bind.CallOpts{})
		if err != nil {
			log.Fatal(err)
		}
		dex.IUniswap.WETH = weth.String()

		dex.IUniswap.GetAmountsOut = func(amount string, path []string) []*big.Int {
			n := new(big.Int)
			n, _ = n.SetString(amount, 10)

			paths := make([]common.Address, 2)
			paths[0] = common.HexToAddress(path[0])
			paths[1] = common.HexToAddress(path[1])
			pairAmount, err := IUniswapV2Router01Caller.GetAmountsOut(&bind.CallOpts{}, n, paths)
			if err != nil {
				log.Fatal(err)
			}
			return pairAmount
		}

	}

	switch _type {
	case "Uniswap":
		uniswap(dex)
	}
	return dex
}

// ########################################################
// ################ Swap Arbitrage Function ###############
// ########################################################
func ExecuteSwapArbitrage() {
	return
}

func SwapPriceCompare(sc *SmartContract, pair string, in string, out string, types []string) ([]string, error) {
	path := make([]string, 2)

	for _, match := range TokenPair() {
		// Match token pair
		if pair == match.Describe {
			match.AmountIn = in
			match.AmountOut = out

			path[0] = match.TokenIn
			path[1] = match.TokenOut

			dexSwapFromUniSwap := DexSwapCall(sc, &DexSwap{}, "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", types[0])
			price1 := dexSwapFromUniSwap.IUniswap.GetAmountsOut(match.AmountIn, path)[1]
			fmt.Println("price1", price1)
			//dexSwapFromSuShiSwap := DexSwapCall(sc, &DexSwap{}, "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", types[1])
			//price0 := dexSwapFromSuShiSwap.IUniswap.GetAmountsOut(match.AmountIn, path)[1]

		}
	}

	fmt.Println("Can't find a match pair, Please check if pair is correct")
	return nil, nil
}

func TokenPair() []*SwapTokenPair {
	pairs := []*SwapTokenPair{
		&SwapTokenPair{
			TokenIn:  "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
			TokenOut: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
			Describe: "WETH to USDT",
		},

		&SwapTokenPair{
			TokenIn:  "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
			TokenOut: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
			Describe: "WETH to DAI",
		},

		&SwapTokenPair{
			TokenIn:  "0x6B175474E89094C44Da98b954EedeAC495271d0F",
			TokenOut: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
			Describe: "DAI to WETH",
		},

		&SwapTokenPair{
			TokenIn:  "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
			TokenOut: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
			Describe: "WETH to USDC",
		},

		&SwapTokenPair{
			TokenIn:  "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
			TokenOut: "0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e",
			Describe: "WETH to YFI",
		},
	}

	return pairs
}

func main() {
	//private := "4d3a7fa76eacb1a0a82d953a4040db344f002ff67030df2a01939d08d148ac75"
	/*
		nodes := make(map[string]string, 4)

		rinkeby := "https://rinkeby.infura.io/v3/6455df3ba91a42a2af9fb331973db958"
		nodes["Rinkeby"] = rinkeby


		erc20Bot := ERCStandard(sc, &Standard{}, "0xdd8C635d50AEDfEab357031b4390a7319157a9C8", "ERC20")
		fmt.Println(erc20Bot.ERC20.BalanceOf("0x87A46c33356a5610026293B01f421e15ac7d33b9"))
		fmt.Println(erc20Bot.ERC20.TotalSupply)
		fmt.Println(
			erc20Bot.ERC20.Allowance(
				"0x87A46c33356a5610026293B01f421e15ac7d33b9",
				"0x104a4a9578e07DE50f0942a6Af72834bf975b783"),
		)

		start := time.Now().Unix()

		for {
			erc721Bot := ERCStandard(
				sc,
				&Standard{},
				"0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b",
				"ERC721",
			)

			fmt.Println(erc721Bot.ERC721.BalanceOf("0xf1c9dc0baa21bb260e192c8a52ee97c887456fb2"))

			if start+60 == time.Now().Unix() {
				break
			}
		}*/

	nodes := make(map[string]string, 4)

	rinkeby := "https://rinkeby.infura.io/v3/6455df3ba91a42a2af9fb331973db958"
	
	nodes["Rinkeby"] = rinkeby
	sc := new(SmartContract)
	Dial(sc, nodes)
	var swapSelect []string = []string{"Uniswap", "Uniswap"}
	SwapPriceCompare(sc, "WETH to DAI", "100", "200", swapSelect)

}
