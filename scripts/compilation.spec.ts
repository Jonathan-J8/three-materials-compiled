import { test, expect } from "@playwright/test";

test("compile and download files", async ({ page }) => {
  await page.goto("/");

  page.on("download", (download) => {
    download.saveAs("./materials/" + download.suggestedFilename());
  });

  const btn = page.getByRole("button");
  await btn.click();
  //@ts-ignore
  await page.waitForFunction(() => window?.appState);
  expect(await btn.innerText()).toBe("RELAUNCH COMPILATION");
});
