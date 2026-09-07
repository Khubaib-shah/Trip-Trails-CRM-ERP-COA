const http = require('http');

function makeRequest(method, path, cookie, body) {
  return new Promise((resolve, reject) => {
    const opts = { hostname: 'localhost', port: 5000, path, method, headers: {} };
    if (cookie) opts.headers.Cookie = cookie;
    if (body) {
      const d = JSON.stringify(body);
      opts.headers['Content-Type'] = 'application/json';
      opts.headers['Content-Length'] = Buffer.byteLength(d);
    }
    const r = http.request(opts, res => {
      let b = '';
      res.on('data', c => b += c);
      res.on('end', () => resolve({ status: res.statusCode, body: b, cookies: res.headers['set-cookie'] }));
    });
    r.on('error', reject);
    if (body) r.write(JSON.stringify(body));
    r.end();
  });
}

async function test() {
  const login = await makeRequest('POST', '/api/v1/auth/login', null, { email: 'agent1@triptrails.pk', password: 'Password123!' });
  console.log('Login:', login.status);
  if (!login.cookies) { console.log('No cookies:', login.body.substring(0,200)); return; }
  const cookie = login.cookies.join('; ');

  const endpoints = [
    '/api/v1/customers',
    '/api/v1/suppliers',
    '/api/v1/roles',
    '/api/v1/customers/40290000-0000-0000-0000-000000000001/ledger',
  ];
  
  for (const path of endpoints) {
    const res = await makeRequest('GET', path, cookie);
    console.log(res.status === 200 ? 'OK' : 'FAIL', path, res.status);
    if (res.status !== 200) console.log('  Error:', res.body.substring(0, 300));
  }
}

test().then(() => process.exit());
