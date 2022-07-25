const { ethers } = require('hardhat');
const { expect } = require('chai');
const { sign } = require('crypto');
const { getCreate2Address } = require('./UniswapV2Utils.test');

const TEST_ADDRESSES = [
  '0x1000000000000000000000000000000000000000',
  '0x2000000000000000000000000000000000000000'
]

context('UniswapV2Factory', async () => {
  beforeEach(async () => {
    const [signer, feeto, addr2] = await ethers.getSigners();
    const UniswapV2Factory = await ethers.getContractFactory("UniswapV2Factory");
    const uniswapV2Factory = await UniswapV2Factory.deploy(signer.address);
    
    this.deploy = (await uniswapV2Factory.deployed()).address;
    this.signer = signer;
    // feeto address
    this.feeto = feeto;
    this.otnerAddr = addr2;

    this.factory = await ethers.getContractAt("UniswapV2Factory", this.deploy, signer);
  });

  describe('creatPair', async () => {
    it('creatPair:success', async () => {
      await this.factory.connect(this.signer).createPair(TEST_ADDRESSES[0], TEST_ADDRESSES[1]);
      // To be created
      expect(await this.factory.allPairsLength()).to.eq(1);
    });

    it('createPair:IDENTICAL_ADDRESSES', async () => {
      await expect(this.factory
        .connect(this.signer)
        .createPair(TEST_ADDRESSES[0], TEST_ADDRESSES[0]))
        .to.be.revertedWith(
          'UniswapV2: IDENTICAL_ADDRESSES'
        );
    });

    it('createPair: ZERO_ADDRESS', async () => {
      await expect(this.factory
        .connect(this.signer)
        .createPair('0x0000000000000000000000000000000000000000', TEST_ADDRESSES[0]))
        .to.be.revertedWith(
          'UniswapV2: ZERO_ADDRESS'
        );
    });

    it('createPair: PAIR_EXISTS', async () => {
      await expect(this.factory.connect(this.signer).createPair(TEST_ADDRESSES[0], TEST_ADDRESSES[1]));

      await expect(this.factory
        .connect(this.signer)
        .createPair(TEST_ADDRESSES[0], TEST_ADDRESSES[1]))
        .to.be.revertedWith(
          'UniswapV2: PAIR_EXISTS'
        );
    });
    
  });
});
