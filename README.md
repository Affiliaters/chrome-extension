# Affiliaters Deal Converter

Turn any supported store link into your affiliate deal link — right from your browser. Convert on the page, from a popup, or in a full dashboard, and share in one click.

> **Chromium browsers only** — Google Chrome, Microsoft Edge, Brave, Opera. (No Firefox / Safari.)

---

## ✨ What you get

- **On-page Convert buttons** on **Amazon.in, Flipkart, Myntra, Croma, and Shopsy** — *Convert Only* and *Convert & Share*.
- **Popup + full Dashboard** — paste a link, convert instantly, and copy the result.
- **Conversion history** — every link you convert is saved so you can find and re-copy it.
- **WhatsApp linking** — connect your WhatsApp session to share deals.
- **Amazon Associate linking** — link your Amazon SiteStripe account.
- **Two platforms in one** — switch between **Affiliaters** and **EK Affiliaters**.
- **Automatic update alerts** — the extension checks for new versions and tells you when to update.

---

## ⬇️ Install (about 1 minute)

### 1. Download & unzip
On this page, click the green **`< > Code`** button, then **Download ZIP**. Unzip it — you'll get a folder named **`chrome-extension-main`** that contains `manifest.json`.

![Download and unzip](docs/step-1-download.svg)

### 2. Open the Extensions page
In your browser's address bar, go to **`chrome://extensions`** (Edge: `edge://extensions`) and turn on **Developer mode** (toggle at the top-right).

![Open chrome://extensions and enable Developer mode](docs/step-2-developer-mode.svg)

### 3. Load unpacked
Click **Load unpacked** and select the **unzipped folder** (the one with `manifest.json` inside).

![Click Load unpacked and choose the folder](docs/step-3-load-unpacked.svg)

### 4. Pin it & open
Click the puzzle-piece icon in the toolbar, **pin** *Affiliaters Deal Converter*, then click its icon to start.

![Pin the extension and open it](docs/step-4-pin.svg)

### 5. Turn on auto-updates (recommended)
In the extension folder, double-click **`install.bat`** (Windows) or **`install.command`** (macOS — if blocked, right-click → Open). Done once, the extension keeps itself up to date automatically. Details in [Updating](#-updating) below.

That's it — the extension is installed and ready to use.

---

## 🔄 Updating

### Recommended: turn on automatic updates (one time, 10 seconds)

The extension folder includes its own updater — run the installer for your system **once**, from inside the extension folder (it works no matter where you keep the folder):

- **Windows:** double-click **`install.bat`**
- **macOS:** double-click **`install.command`** — if macOS blocks it, right-click it → **Open** → **Open**. (Or in Terminal: `bash install.command`)
- **Linux:** run `bash install.command`

That's it. From then on the extension **updates itself in the background** — it checks for new versions every hour and applies them without you doing anything, even if you never close your browser. No git or other tools required.

> If you ever **move the extension folder**, run the installer again from the new location (Chrome also requires re-loading a moved unpacked folder).
> The file `last-update.log` inside the folder shows what the updater last did.

### Manual update (fallback)

If you skip the installer, the extension still checks for new versions and shows a **red `!` badge** on the icon and a **“New version available — Download”** banner when you open it.

![Update banner](docs/update-banner.svg)

1. Click **Download** on the banner (or use **`< > Code` → Download ZIP** here) and unzip it.
2. Replace the **contents** of your old extension folder with the newly unzipped files.
3. On `chrome://extensions`, press **Reload** on the extension card.

---

## 🧰 Troubleshooting

| Problem | Fix |
|---|---|
| "Manifest file is missing or unreadable" | You selected the wrong folder — pick the one that **directly contains** `manifest.json`. |
| No Convert buttons on a store | Refresh the page after installing. Make sure the site is enabled in the extension. |
| Nothing happens on click | Open the extension, sign in / authorize your platform, then try again. |
| Update banner won't go away | Install the latest version, or click **×** to dismiss until the next release. |

---

## 🔒 Privacy & permissions

The extension needs access to the supported store sites (to add Convert buttons and read your affiliate details) and to the Affiliaters API (to convert links and save history). It only runs on those sites.

---

## 💬 Help & feedback

Need help, found a bug, or have an idea? **Feature requests are welcome!**

- 📧 Email: **admin@affiliaters.in**
- 💬 Telegram: **[@AffiliatersHelpBot](https://t.me/AffiliatersHelpBot)**
