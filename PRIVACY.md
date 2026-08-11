# Privacy Policy — Affiliaters Deal Converter (GitHub / self-hosted build)

_Last updated: 2 August 2026_

**Applies to:** the **GitHub / sideloaded build** — the version you download as a zip and load with "Load unpacked".

> ### ⚠️ This is NOT the Chrome Web Store version
> This build has capabilities the store version does not: WhatsApp Web session transfer, Telegram Web link listening, Amazon cookie linking, page-visibility overrides and background self-update.
>
> The **Chrome Web Store and Safari / App Store builds are covered by a different, narrower policy:**
> <https://affiliaters.in/extension-privacy> · terms: <https://affiliaters.in/extension-terms>
>
> Do not treat the two as interchangeable. If you installed from a browser store, read the store policy instead.

---

## 1. Who we are

Built and operated by **Affiliaters**, Gurugram, Haryana, India. Questions or data requests: **admin@affiliaters.in** or [@AffiliatersHelpBot](https://t.me/AffiliatersHelpBot).

Your Affiliaters account, dashboard and the servers this extension talks to are covered by the main policy at <https://affiliaters.in/privacy>.

## 2. The short version

This build converts store links to *your* affiliate links and can post them for you. To do that it can — **only when you switch each feature on** — read your Amazon cookies, take your WhatsApp Web session, and watch a Telegram Web chat you open. That is genuinely sensitive access, described honestly below so you can decide before enabling it.

We do **not** sell data, run advertising or analytics SDKs, or collect your browsing history.

---

## 3. What the extension processes

### 3.1 Account and settings (always)

| Data | Why | Where it goes |
|---|---|---|
| Affiliaters account email + login token (JWT) | Authenticate every request so conversions use your affiliate IDs | Extension storage on your device; sent only to Affiliaters APIs (`app-api.affiliaters.in`, `ekaro-api.affiliaters.in`) |
| Settings — message template, enabled stores, Auto Post state, onboarding state | Make the extension behave as you configured it | Local browser extension storage |
| Active site choice — Affiliaters or **EK Affiliaters** (the EarnKaro white-label) | Route conversions to the right account and API | Local; selects which API host is used |
| Conversion history | Let you re-copy earlier deals | Your device and/or your Affiliaters account |

### 3.2 Product pages on supported stores (always)

On **Amazon.in, Flipkart, Myntra, Croma and Shopsy** the extension reads product details already visible on the page — URL, title, price, MRP, coupon, offer lines, image — to build your affiliate link and deal message. The product URL is sent to Affiliaters for conversion; the rest is composed on your device.

On **any other website** the extension adds nothing to the page. If you open its popup there yourself, it reads only that tab's **title and URL** so you can convert that link too.

### 3.3 Amazon card & bank offers (when a conversion needs them)

Amazon does not include card-offer details in the product page — not even hidden in the page code. When a conversion needs them, the extension briefly opens Amazon's own offers page for that product in a background tab, reads the offer lines, and closes it. It uses your normal Amazon session, opens no other page and reads nothing else. `declarativeNetRequest` is used **only** to set a mobile User-Agent on that specific request so the offers load.

### 3.4 Amazon cookie linking — you press "Link" ⚠️

If you use Amazon Associates link shortening, the extension can link your Amazon session to your Affiliaters account:

- **What is read:** all cookies for `amazon.in`, **including HttpOnly cookies** (only the service worker can read these), flattened into one `name=value;name=value` Cookie-header string.
- **Where it goes:** POSTed over HTTPS to your Affiliaters advance-settings endpoint as a field named **`amazon_cookies`**, authenticated with your account token.
- **Why:** the server replays that Cookie header when calling Amazon's own shortener on your behalf, so short links are generated under your Associates account.
- **How long:** held server-side against your account until you overwrite it by linking again, or ask us to delete it.
- **Not used for:** reading payment card numbers, bank details or checkout data from Amazon.

**Understand the risk:** an Amazon session cookie can act as your Amazon login. Only link an account you are comfortable delegating, and re-link (which overwrites) or contact us to clear it when you stop using the feature.

### 3.5 WhatsApp Web session transfer — you press "Connect" ⚠️⚠️

This is the most sensitive thing this build does. When you choose to connect WhatsApp:

1. An extractor runs in the WhatsApp Web page context and reads WhatsApp's own **localStorage keys and IndexedDB stores** holding your session material.
2. That material — **authentication credentials and encryption keys** (converted to a Baileys-style `creds` / `keys` structure, plus noise-handshake candidates and device metadata) — is POSTed over HTTPS to your Affiliaters account's WhatsApp session endpoint.
3. Once the server confirms the session is linked, the extension **wipes the local WhatsApp Web session** — removing those localStorage keys and deleting the IndexedDB databases — so the same keys cannot be re-extracted. **You will be logged out of WhatsApp Web in that browser.**
4. From then on, deals are posted from the Affiliaters side using that session.

**This is auth material, not link data.** Anyone holding it can act as your WhatsApp. By enabling it you accept that WhatsApp/Meta may detect unofficial automation and **restrict, lock or ban the number**, that sessions can break at any time, and that delivery is never guaranteed. **Do not enable this on a number you cannot afford to lose** — prefer a dedicated number.

Stop any time by disconnecting in the dashboard and logging out of the linked session; email **admin@affiliaters.in** to have stored session material deleted.

### 3.6 Telegram Web link listening — you press "Start" ⚠️

On `web.telegram.org`, after you press Start on the floating panel, the extension watches the **chat you currently have open** for new messages, extracts shopping links according to your link-mode setting, and opens supported ones in tabs to convert and share. It does not read your other chats, contacts or history, and watches nothing until you press Start. Telegram may restrict accounts that automate — that risk is yours.

### 3.7 Page-visibility override (WhatsApp Web / Telegram Web) ⚠️

While a listener is running, the extension overrides `document.hidden` and `document.visibilityState` in the WhatsApp Web / Telegram Web page so the site keeps rendering incoming messages when the tab is in the background. This is a deliberate override of normal browser behaviour, active **only** while you have pressed Start and only on those two sites. It reads no extra data — but it does mean the site cannot tell the tab is backgrounded, which some platforms treat as a signal of automation.

### 3.8 Self-update and remote configuration (this build only)

This build polls **`raw.githubusercontent.com/Affiliaters/chrome-extension`** for `config/version.json` (update availability) and `config/app-config.json` (site/selector configuration). These are ordinary public file fetches: your IP and standard request headers are visible to GitHub under GitHub's own privacy policy. No account data is sent. The store and Safari builds have no self-update and no remote config.

---

## 4. What we never do

- Never sell, rent or trade your data.
- Never embed advertising, analytics or tracking SDKs.
- Never collect your browsing history.
- Never read pages outside the supported stores (beyond a popup-triggered title + URL), chats you have not opened, or your saved passwords.
- Never swap your affiliate tag for ours.

## 5. Permissions and why they are needed

| Permission | Why |
|---|---|
| `storage` | Save settings, template, history and login state on your device |
| `activeTab` + `scripting` | Read product details and place the Convert Only / Convert & Share buttons on supported stores; read a tab's title + URL when you open the popup |
| `cookies` | **§3.4** — read `amazon.in` cookies (including HttpOnly) when you press Link, so the server can shorten links under your Associates account |
| `alarms` | Schedule background tasks (update poll, listener housekeeping) |
| `declarativeNetRequest` | **§3.3 only** — set a mobile User-Agent on the extension's own Amazon offers request. Does not modify, redirect or observe your normal browsing |
| Hosts — Flipkart, Amazon.in, Myntra, Croma, Shopsy | Run the convert feature on those stores |
| Hosts — `web.whatsapp.com`, `web.telegram.org` | **§3.5–3.7** — the WhatsApp/Telegram helpers. Not present in the store build |
| Hosts — `*.affiliaters.in` APIs | Authenticate and convert |
| Hosts — `raw.githubusercontent.com` | **§3.8** — update and config files. Not present in the store build |

## 6. Sharing

Data goes only to **Affiliaters' own servers**; **the platforms you connect** (WhatsApp, Telegram and your posting destinations — their policies then apply); **affiliate networks**, indirectly, because your link routes through them when someone clicks; and **GitHub**, for the file fetches in §3.8. We disclose to authorities only where legally required.

## 7. Storage, retention and control

Settings and tokens live in browser extension storage on your device — sign out or uninstall to clear them. Data sent to Affiliaters follows the main policy at <https://affiliaters.in/privacy>. Server-side, `amazon_cookies` and WhatsApp session material are held against your account until you re-link (overwriting) or ask for deletion. Email **admin@affiliaters.in** for a copy or erasure.

## 8. Security

Transfers use HTTPS/TLS and are authenticated with a token scoped to your account. The material in §3.4 and §3.5 is transferred only for the features you switched on. No system is perfectly secure — use a strong password and treat Amazon linking and WhatsApp connecting as the high-trust operations they are.

## 9. Your choices

Every sensitive feature is **off until you turn it on**, per feature and (for stores) per site. Turn any of them off, sign out, or uninstall at any time. If you are not comfortable with §3.4 or §3.5, never press Link or Connect — the converter works fully without them.

## 10. Children

Not directed to anyone under 18. We do not knowingly collect data from minors.

## 11. Changes

This policy may be updated at any time as the extension evolves, and the extension's features may change or be withdrawn at any time. Adding or removing a supported *store* does not change what is collected or why (§3.2) and does not require a new version of this document. Changes to the **kinds of data** processed or the **purposes** are reflected here with a new "Last updated" date.

## 12. Contact

**Affiliaters** — Gurugram, Haryana, India
Email: **admin@affiliaters.in** · Telegram: [@AffiliatersHelpBot](https://t.me/AffiliatersHelpBot)
Terms for this build: **TERMS.md**, shipped alongside this file.
