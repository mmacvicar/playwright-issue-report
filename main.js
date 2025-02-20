const { chromium } = require("playwright");

(async () => {
  const proxy = {
    server: "localhost:8888",
  };

  const contextArgs = {
    headless: false,
    ignoreHTTPSErrors: true,
    proxy: proxy,
    clientCertificates: [
      {
        pfxPath: "certs/client.pfx",
        origin: "https://unrelated.com",
        passphrase: "password",
      },
    ],
  };
  var browser = await chromium.launch();
  var context = await browser.newContext(contextArgs);
  var page = await context.newPage();
  console.log("Navigating to fake.example.com using a proxy and client certificates set to unrelated.com");
  try {
    await page.goto("https://fake.example.com", { timeout: 5000 });
    console.log("SUCCESS");
  } catch (error) {
    console.error("ERROR:", error.message);
  }
  
  // Remove client certificates configuration
  contextArgs.clientCertificates = [];

  context = await browser.newContext(contextArgs);
  page = await context.newPage();
  console.log("Navigating to fake.example.com using a proxy");
  try {
    await page.goto("https://fake.example.com", { timeout: 5000 });
    console.log("SUCCESS");
  } catch (error) {
    console.error("ERROR:", error.message);
  }
  await browser.close();
  process.exit(0);
})();
