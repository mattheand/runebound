// Optional: requires Playwright and a local Chrome installation (see docs/testing.md).
const { chromium } = require('playwright');
const fs = require('node:fs');
const assert = require('node:assert/strict');

(async () => {
  const browser = await chromium.launch({
    headless: true,
    ...(process.env.CHROME ? { executablePath: process.env.CHROME } : {}),
  });
  try {
    const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    page.on('console', message => {
      console.log(`browser ${message.type()}: ${message.text()}`);
      if (message.type() === 'error') errors.push(message.text());
    });
    page.on('response', response => {
      if (response.status() >= 400) errors.push(`HTTP ${response.status()}: ${response.url()}`);
    });
    fs.mkdirSync('build/screenshots', { recursive: true });
    await page.goto(process.env.GAME_URL || 'http://127.0.0.1:8765', { waitUntil: 'networkidle' });
    await page.locator('#status').waitFor({ state: 'detached' });
    await page.screenshot({ path: 'build/screenshots/browser-menu.png' });
    await page.keyboard.press('Enter');
    await page.waitForTimeout(1200);
    const start = await page.screenshot({ path: 'build/screenshots/browser-gameplay.png' });
    await page.keyboard.down('d');
    await page.waitForTimeout(300);
    await page.keyboard.down('Space');
    await page.waitForTimeout(180);
    await page.keyboard.up('Space');
    await page.waitForTimeout(40);
    await page.keyboard.down('Space');
    await page.waitForTimeout(60);
    const jumping = await page.screenshot({ path: 'build/screenshots/browser-double-jump.png' });
    await page.keyboard.up('Space');
    await page.keyboard.up('d');
    assert(!start.equals(jumping), 'keyboard movement changes the rendered frame');
    await page.keyboard.press('r');
    await page.waitForTimeout(800);
    await page.screenshot({ path: 'build/screenshots/browser-restart.png' });
    await page.keyboard.press('Escape');
    await page.waitForTimeout(300);
    await page.screenshot({ path: 'build/screenshots/browser-return-menu.png' });
    assert.deepEqual(errors, [], 'web export has no runtime/resource/HTTP errors');
    console.log('PASS: browser startup and keyboard smoke test; screenshots saved for visual review');
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
