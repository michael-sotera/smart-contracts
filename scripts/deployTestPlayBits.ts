import { ethers, upgrades } from "hardhat";

async function main() {
  const [owner] = await ethers.getSigners();
  const signerAddress = owner.address;

  const C = await ethers.getContractFactory("TestPlayBits");
  const c = await upgrades.deployProxy(
    C,
    ["TestPlayBits", "TPB", signerAddress],
    {
      kind: "uups",
      initializer: "initialize",
      constructorArgs: [],
      txOverrides: { gasLimit: 3_000_000 },
    }
  );
  await c.waitForDeployment();

  const addresses = {
    proxy: await c.getAddress(),
    impl: await upgrades.erc1967.getImplementationAddress(await c.getAddress()),
  };
  console.log("Addresses:", addresses);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
