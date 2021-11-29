import { expect } from "chai";
import hre, { deployments, waffle, ethers } from "hardhat";
import "@nomiclabs/hardhat-ethers";
import { AddressZero } from "@ethersproject/constants";
import { AddressOne } from "@gnosis.pm/safe-contracts";

describe("ModGuard", async () => {
  const [user1, user2] = waffle.provider.getWallets();
  const abiCoder = new ethers.utils.AbiCoder();

  const setupTests = deployments.createFixture(async ({ deployments }) => {
    await deployments.fixture();
    const avatarFactory = await hre.ethers.getContractFactory("TestAvatar");
    const avatar = await avatarFactory.deploy();
    const factory = await hre.ethers.getContractFactory("ModGuard");
    const guard = await factory.deploy(user1.address, avatar.address, [
      AddressOne,
    ]);
    await avatar.enableModule(user1.address);
    await avatar.setGuard(guard.address);
    const tx = {
      to: avatar.address,
      value: 0,
      data: "0x",
      operation: 0,
      avatarTxGas: 0,
      baseGas: 0,
      gasPrice: 0,
      gasToken: AddressZero,
      refundReceiver: AddressZero,
      signatures: "0x",
    };
    return {
      avatar,
      guard,
      tx,
    };
  });

  describe("setUp()", async () => {
    it("throws if guard has already been initialized", async () => {
      const { avatar, guard } = await setupTests();
      const initializeParams = abiCoder.encode(
        ["address", "address", "address[]"],
        [user1.address, avatar.address, []]
      );
      await expect(guard.setUp(initializeParams)).to.be.revertedWith(
        "Initializable: contract is already initialized"
      );
    });

    it("throws if owner is zero address", async () => {
      const Guard = await hre.ethers.getContractFactory("ModGuard");
      await expect(
        Guard.deploy(AddressZero, AddressZero, [])
      ).to.be.revertedWith("Ownable: new owner is the zero address");
    });

    it("should emit event because of successful set up", async () => {
      const Guard = await hre.ethers.getContractFactory("ModGuard");
      const guard = await Guard.deploy(user1.address, user1.address, []);
      await guard.deployed();

      await expect(guard.deployTransaction)
        .to.emit(guard, "ModGuardSetup")
        .withArgs(user1.address, user1.address, user1.address, []);
    });
  });

  describe("fallback", async () => {
    it("must NOT revert on fallback without value", async () => {
      const { guard } = await setupTests();
      await user1.sendTransaction({
        to: guard.address,
        data: "0xbaddad",
      });
    });
    it("should revert on fallback with value", async () => {
      const { guard } = await setupTests();
      await expect(
        user1.sendTransaction({
          to: guard.address,
          data: "0xbaddad",
          value: 1,
        })
      ).to.be.reverted;
    });
  });

  describe("checkAfterExecution()", async () => {
    it("should revert if protected module is disabled", async () => {
      const { guard } = await setupTests();
      await expect(
        guard.checkAfterExecution(
          "0x0000000000000000000000000000000000000000000000000000000000000000",
          true
        )
      ).to.be.revertedWith("Cannot disable protected modules");
    });

    it("allows execution if protected module is enabled", async () => {
      const { avatar, guard } = await setupTests();
      await avatar.enableModule(AddressOne);
      await expect(
        guard.checkAfterExecution(
          "0x0000000000000000000000000000000000000000000000000000000000000000",
          true
        )
      );
    });
  });
});
