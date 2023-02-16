import fs from "fs/promises";
import puppeteer from "puppeteer";

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  await page.goto("https://werft.gitpod-dev.com");

  const inputs = ["gitpod-build-main", "success", "done"];

  for (const input of inputs) {
    // Type into search box
    await page.type("input.MuiInputBase-input", input);

    // Wait and click on first result
    const searchResultSelector = "svg.MuiSvgIcon-root";
    await page.waitForSelector(searchResultSelector);
    await page.click(searchResultSelector);
  }

  // It takes a moment
  await new Promise((r) => setTimeout(r, 1000));

  // Locate the results
  const data = await page.evaluate(() => {
    const tds = Array.from(
      document.querySelectorAll(
        ".MuiTable-root tbody td .MuiTypography-colorPrimary",
      ),
    );
    return tds.map((td) => td.textContent);
  });

  const tags = data.map((item) => item.replace("gitpod-build-", ""));

  fs.writeFile("./output.json", JSON.stringify({ tags }, null, 2));

  await browser.close();
})();
