const hre = require("hardhat");

async function main() {
  const candidateCount = 3; // Example: 3 candidates
  const Voting = await hre.ethers.getContractFactory("Voting");
  const voting = await Voting.deploy(candidateCount);

  await voting.deployed();
  console.log("Voting contract deployed to:", voting.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
