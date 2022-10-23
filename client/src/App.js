import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import './App.css';

function App() {
  const [currentAccount, setCurrentAccount] = useState("");

  const checkIfWalletIsConnected = async() => {
    try {
      const {ethereum} = window;
      if(!ethereum){
        console.log("Make sure you have Metamask");
        return;
      } else {
        console.log("Ethereum objected detected:", ethereum);
      }

      const accounts = await ethereum.request({ method: "eth_accounts" });
      if(accounts.length !== 0){
        const account = accounts[0];
        console.log("Found an authorized account:", account);
        setCurrentAccount(account);
      } else {
        console.log("No authorized account found");
      }
    } catch(error){
      console.log(error);
    }
  };

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  const connectWallet = async() => {
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
    } catch(error){
      console.log(error);
    }
  }

  return (
    <div className="App">
      Hello world
    </div>
  );
}

export default App;
