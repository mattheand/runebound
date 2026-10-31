const { chromium } = require('playwright');
const fs = require('node:fs');
const assert = require('node:assert/strict');

(async () => {
  const browser = await chromium.launch({ headless: true,
    ...(process.env.CHROME ? { executablePath: process.env.CHROME } : {}) });
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
    await page.screenshot({ path: 'build/screenshots/browser-m4-menu.png' });
    await page.keyboard.press('Enter');
    await page.waitForTimeout(1500);
    const start = await page.screenshot({ path: 'build/screenshots/browser-m4-forest.png' });
    await page.keyboard.down('d');
    await page.waitForTimeout(4100);
    await page.keyboard.up('d');
    await page.waitForTimeout(150);
    await page.keyboard.down('d');
    await page.waitForTimeout(1100);
    await page.keyboard.up('d');
    await page.waitForTimeout(150);
    for (const duration of [600, 750]) {
      await page.keyboard.down('d');
      await page.keyboard.down('Space');
      await page.waitForTimeout(duration);
      await page.keyboard.up('d');
      await page.keyboard.up('Space');
      await page.waitForTimeout(250);
    }
    const exploring = await page.screenshot({ path: 'build/screenshots/browser-m4-rune.png' });
    assert(!start.equals(exploring), 'adventure movement changes the rendered scene');
    await page.keyboard.press('Escape');
    await page.waitForTimeout(250);
    await page.screenshot({ path: 'build/screenshots/browser-m4-pause.png' });
    await page.keyboard.press('Enter');
    await page.waitForTimeout(250);
    await page.keyboard.press('r');
    await page.waitForTimeout(900);
    await page.screenshot({ path: 'build/screenshots/browser-m4-retry.png' });
    await page.keyboard.press('Escape');
    await page.waitForTimeout(150);
    await page.keyboard.press('ArrowDown');
    await page.keyboard.press('ArrowDown');
    await page.keyboard.press('Enter');
    await page.waitForTimeout(300);
    await page.screenshot({ path: 'build/screenshots/browser-m4-return-menu.png' });
    assert.deepEqual(errors, [], 'M4 has no browser runtime/resource/HTTP errors');
    console.log('PASS: M4 browser menu, exploration, jump/rune, pause/resume, checkpoint retry and return smoke');
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
