const { app, BrowserWindow, ipcMain, screen } = require('electron');
const path = require('path');
const fs   = require('fs');

// Catch unhandled errors so they appear in the console
process.on('uncaughtException', (err) => {
  console.error('[sticky-focus] Uncaught exception:', err);
});

// Persist window position between launches
const statePath = path.join(app.getPath('userData'), 'window-state.json');

function loadState() {
  try { return JSON.parse(fs.readFileSync(statePath, 'utf8')); }
  catch (_) { return null; }
}

function saveState(win) {
  try {
    const [x, y] = win.getPosition();
    fs.writeFileSync(statePath, JSON.stringify({ x, y }), 'utf8');
  } catch (_) {}
}

function createWindow() {
  const saved = loadState();
  const display = screen.getPrimaryDisplay();
  const { width: sw } = display.workAreaSize;

  const winW = 390, winH = 670;
  const defaultX = sw - winW - 40;
  const defaultY = 60;

  const opts = {
    width:  winW,
    height: winH,
    x: saved ? saved.x : defaultX,
    y: saved ? saved.y : defaultY,
    frame:       false,
    transparent: true,
    alwaysOnTop: true,
    resizable:   false,
    skipTaskbar:  false,
    hasShadow:   false,
    backgroundColor: '#00000000',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  };

  let win;
  try {
    win = new BrowserWindow(opts);
  } catch (e) {
    // Fallback: non-transparent window if GPU compositor fails
    console.error('[sticky-focus] Transparent window failed, falling back:', e.message);
    opts.transparent    = false;
    opts.backgroundColor = '#C4BEBC';
    opts.hasShadow      = true;
    win = new BrowserWindow(opts);
  }

  win.loadFile('index.html');

  win.webContents.on('did-fail-load', (event, code, desc) => {
    console.error('[sticky-focus] Page failed to load:', code, desc);
  });

  win.on('moved', () => saveState(win));
  win.on('close', () => saveState(win));

  ipcMain.removeAllListeners('close-app');
  ipcMain.removeAllListeners('minimize-app');
  ipcMain.removeAllListeners('resize-window');

  ipcMain.on('close-app',    () => { saveState(win); app.quit(); });
  ipcMain.on('minimize-app', () => win.minimize());
  ipcMain.on('resize-window', (_, { w, h }) => {
    win.setSize(w, h);
  });
}

app.commandLine.appendSwitch('enable-transparent-visuals');

app.whenReady().then(() => {
  createWindow();
}).catch(err => {
  console.error('[sticky-focus] App failed to start:', err);
});

app.on('window-all-closed', () => app.quit());
