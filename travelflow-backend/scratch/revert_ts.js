const fs = require("fs");
const path = require("path");

const accPath = path.join(__dirname, "../src/services/accounting.service.ts");
let accCode = fs.readFileSync(accPath, "utf-8");
accCode = accCode.replace(/bookingServices: true/g, "services: true");
accCode = accCode.replace(/invoice\.booking!\.bookingServices/g, "invoice.booking!.services");
fs.writeFileSync(accPath, accCode);

const domPath = path.join(__dirname, "../src/services/domain.service.ts");
let domCode = fs.readFileSync(domPath, "utf-8");
domCode = domCode.replace(/bookingServices: \{ where:/g, "services: { where:");
domCode = domCode.replace(/b\.bookingServices\.reduce/g, "b.services.reduce");
fs.writeFileSync(domPath, domCode);
