import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import abi from "./abi/NFTCollectible.json";
import './App.css';

const contractAddress = "0x0Fd7714EE72Bde2F11525E0069169fAbd990e7A4";
const contractABI = abi.abi;

function App() {
  const [currentAccount, setCurrentAccount] = useState("");

  const checkIfWalletIsConnected = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        console.log("Make sure you have Metamask");
        return;
      } else {
        console.log("Ethereum objected detected:", ethereum);
      }

      const accounts = await ethereum.request({ method: "eth_accounts" });
      if (accounts.length !== 0) {
        const account = accounts[0];
        console.log("Found an authorized account:", account);
        setCurrentAccount(account);
      } else {
        console.log("No authorized account found");
      }
    } catch (error) {
      console.log(error);
    }
  };

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  const connectWallet = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        alert("Get Metamask");
        return;
      }
      const accounts = await ethereum.request({
        method: "eth_requestAccounts",
      });
      console.log("Connected:")
    } catch (error) {
      console.log(error);
    }
  }

  const mintNftHandler = async () => {
    try {
      const { ethereum } = window;

      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const nftContract = new ethers.Contract(contractAddress, contractABI, signer);

        console.log("initialize payment");
        let nftTxn = await nftContract.mintNFTs(1, {
          value: ethers.utils.parseEther("0.01")
        });

        console.log("Minting...");
        await nftTxn.wait();

        console.log(`Mined, see transaction: ${nftTxn.hash}`);
      } else {
        console.log("Ethereum object does not exist");
      }
    } catch (err) {
      console.log(err);
    }
  };

  const mintNftButton = () => {
    return (
      <button onClick={mintNftHandler} className="dappButton">
        Mint NFT
      </button>
    );
  };

  return (
    <div className="main-app">
      <div>
        {!currentAccount && (
          <button className="dappButton cta-button" onClick={connectWallet}>
            Connect Wallet
          </button>
        )}
        {currentAccount && (
          <button className="dappButton cta-button" onClick={mintNftHandler}>
            Mint NFT
          </button>
        )}
      </div>
    </div>
  );
}

export default App;
