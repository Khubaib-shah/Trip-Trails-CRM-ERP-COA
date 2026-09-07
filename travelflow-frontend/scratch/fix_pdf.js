const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '../src/../app/(dashboard)/../components/invoices/InvoicePDFViewer.tsx');
let content = fs.readFileSync(filePath, 'utf-8');

content = content.replace(/data\.customerId\?/g, 'data.customer?');
content = content.replace(/data\.bookingId\?/g, 'data.booking?');
content = content.replace(/data\.bookingId\./g, 'data.booking.');

fs.writeFileSync(filePath, content);
console.log("Fixed PDF viewer references");
