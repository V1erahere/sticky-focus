const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  closeApp:     () => ipcRenderer.send('close-app'),
  minimizeApp:  () => ipcRenderer.send('minimize-app'),
  resizeWindow: (w, h) => ipcRenderer.send('resize-window', { w, h }),
});
