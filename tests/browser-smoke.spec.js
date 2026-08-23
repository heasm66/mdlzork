const { test, expect } = require('@playwright/test');

test('starts a game and accepts a command', async ({ page }) => {
    const errors = [];
    page.on('pageerror', (error) => errors.push(error.message));

    await page.goto('/');
    await expect(page.locator('#start-btn')).toBeEnabled({ timeout: 30_000 });
    await page.locator('#start-btn').click();

    const terminal = page.locator('#terminal');
    await expect(terminal).toContainText('West of House', { timeout: 30_000 });

    await page.locator('.xterm-helper-textarea').focus();
    await page.keyboard.type('look');
    await page.keyboard.press('Enter');

    await expect(terminal).toContainText('There is a small mailbox here.', { timeout: 30_000 });
    await expect(terminal).not.toContainText('Unexpected EOF');
    expect(errors).toEqual([]);
});
