// Rendered M3 smoke check. Real state/damage invariants are covered in Godot.
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
    await page.keyboard.press('Enter');
    await page.waitForTimeout(900);
    await page.keyboard.down('d');
    await page.waitForTimeout(900);
    await page.keyboard.up('d');
    await page.keyboard.down('j');
    await page.waitForTimeout(140);
    await page.screenshot({ path: 'build/screenshots/browser-m3-draugr.png' });
    await page.keyboard.up('j');
    await page.keyboard.press('2');
    await page.waitForTimeout(200);
    await page.keyboard.down('d');
    await page.waitForTimeout(950);
    await page.keyboard.up('d');
    await page.screenshot({ path: 'build/screenshots/browser-m3-raven.png' });
    await page.keyboard.press('3');
    await page.waitForTimeout(200);
    await page.keyboard.down('d');
    await page.waitForTimeout(1400);
    await page.keyboard.up('d');
    await page.waitForTimeout(500);
    await page.keyboard.down('j');
    await page.waitForTimeout(120);
    await page.keyboard.up('j');
    const fight = await page.screenshot({ path: 'build/screenshots/browser-m3-troll.png' });
    await page.waitForTimeout(180);
    await page.keyboard.down('Space');
    await page.waitForTimeout(350);
    await page.screenshot({ path: 'build/screenshots/browser-m3-troll-slam.png' });
    await page.keyboard.up('Space');
    await page.keyboard.press('r');
    await page.waitForTimeout(900);
    const retry = await page.screenshot({ path: 'build/screenshots/browser-m3-retry.png' });
    assert(!fight.equals(retry), 'retry changes the encounter frame');
    await page.keyboard.press('Escape');
    await page.waitForTimeout(250);
    await page.screenshot({ path: 'build/screenshots/browser-m3-menu.png' });
    assert.deepEqual(errors, [], 'M3 has no runtime/resource/HTTP errors');
    console.log('PASS: rendered M3 selectors, combat input, boss intro/attack, retry and menu smoke');
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
