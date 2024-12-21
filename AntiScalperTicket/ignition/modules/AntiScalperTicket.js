const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DeployAntiScalperTicket", (m) => {
  const AntiScalperTicket = m.contract("AntiScalperTicket", []);
  return { AntiScalperTicket };
});