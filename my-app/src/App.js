import logo from './logo.svg';
import './App.css';
import Web3 from 'web3';
import config from './abis'
import './App.css';
import Ethereum from "./Etherenium";
import React, { useState, useEffect } from 'react';

const web3 = new Web3(Web3.givenProvider);
const configAbi = config.abi
const contractAddr = '0x1824B7c5a0b765A38EFF0Ba2477F00bfdCA7d586';
const imagesStore = new web3.eth.Contract(configAbi, contractAddr);
const MetamaskHandler = (account, setAccount) => {
  useEffect(() => {
    if (window.ethereum) {
    window.web3 = new Web3(window.ethereum)
    window.ethereum.enable()}
  }, [])
  const connectMetamask = () => {
    window.ethereum.request({ method: 'eth_requestAccounts' }).then((x) => setAccount(x[0]))
  }

  if (window.ethereum === undefined) {
    return <>Metamask is not installed</>
  }  else {
    return <button onClick={connectMetamask}>Connect metamask</button>
  }

}

const ImageStore = () => {
  const [title, setTitle] = useState('')
  const [url, setUrl] = useState('')
  const [imagesLoaded, setImagesLoaded] = useState(false)
  const [images, setImages] = useState([])
  const [account, setAccount] = useState(null)
  const [eth, setEth] = useState(null)

  useEffect(() => {
    if (account) {
    setEth(Ethereum(imagesStore, account ))}
  }, [account])

  useEffect(()=>{
    if (eth) {
      updateImages()
      setImagesLoaded(true)
    }
  }, [eth])

  async function buyImage () {
    await eth.buyImage(title, url)
  }
  async function updateImages () {
    const images = await eth.getAllImages()
    setImages(images.map(x => ({
      ...x
    })))
  }

  return <div>
    <MetamaskHandler account={account} setAccount={setAccount}/>
    {(eth && imagesLoaded) &&
    <div>
      <div><input onChange={(event) => setTitle(event.target.value)}/></div>
      <div><input onChange={(event) => setUrl(event.target.value)}/></div>
      <div>
        <button onClick={buyImage}>
          Buy a new image!
        </button>
      </div>
    <div style={{display: 'flex', flexWrap: 'wrap'}}>{images.map(image => <div>
      <div>
        Title: {image.title}
      </div>
      <div>
        <img alt="some image" style={{width: '50px', height: '50px'}} src={image.url} />
      </div>
    </div>)}

    </div> </div>}
  </div>

}

function App() {
  return <ImageStore/>
}

export default App;
