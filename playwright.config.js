const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
    testDir: './tests',
    timeout: 60_000,
    use: {
        baseURL: 'http://127.0.0.1:4173',
        launchOptions: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH ? {
            executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH
        } : {},
        trace: 'retain-on-failure'
    },
    webServer: {
        command: 'python3 -m http.server 4173 -d build/web',
        url: 'http://127.0.0.1:4173',
        reuseExistingServer: false
    }
});
