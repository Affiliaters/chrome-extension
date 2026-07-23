# Deal message template guide

Customize the text posted for each deal under **Settings → Message format**.  
Tap chips to insert tags, or type them yourself. Errors appear under the editor and block Save until fixed.

Related: in Settings → Message format, click **Full guide with more examples** to open `template-guide.html` in a new tab (same detailed content).

---

## Variables

| Tag | Purpose | Example | Empty when |
|-----|---------|---------|------------|
| `{{title}}` | Product or page title | `BOSCH 7 kg Steam…` | Title missing |
| `{{price}}` | Selling price | `₹27990` | No price / OOS |
| `{{mrp}}` | List / struck price | `₹49990` | No MRP or MRP ≤ price |
| `{{link}}` | Product URL (required) | affiliate URL after convert | — |
| `{{discount}}` | ₹ saved vs MRP | `₹22000` | No usable MRP |
| `{{off}}` | % off vs MRP | `44%` | No usable MRP |
| `{{coupon}}` | Amazon / Flipkart / Myntra coupon line | `Apply 5% coupon` / `Apply ₹16499 coupon` | No coupon |
| `{{coupon_amt}}` | ₹ value of that coupon | `₹50` | No coupon |
| `{{finalprice}}` | Price after coupon (when coupon present) | `₹617` | See Settings help |
| `{{card_bank}}` | Flipkart Best Value / Amazon cardification bank | `HDFC` / `Amazon Pay ICICI` | No bank offer |
| `{{card_type}}` | Credit / Debit / Credit/Debit | `Credit` | Same |
| `{{card_offer}}` | Full offer line | `10% Instant Discount on HDFC…` | Same |
| `{{card_off}}` | Best single display | `10%` or `₹2250` | Same |
| `{{card_off_pct}}` | Bank offer % (number) | `10` | Same |
| `{{card_off_amt}}` | Bank offer ₹ amount | `₹2250` | Same |
| `{{website}}` | Retailer id | `amazon` / `flipkart` / … | Unknown host |

Developer playbook for card offers (`cardOfferRaw` + `card_*`): [`docs/fk_card_offer.md`](docs/fk_card_offer.md) (Flipkart), [`docs/amz_card_offer.md`](docs/amz_card_offer.md) (Amazon).

**MRP %:** `off = round((mrp − price) / mrp × 100)`.

**Coupon:** `coupon` is the text line; `coupon_amt` is the ₹ amount parsed from it (from `%` or flat ₹). Used in `{{math}}` as `coupon`. Flipkart uses the Coupons / “Save ₹X extra” row (same `Apply ₹X coupon` shape as Amazon).

**Card offers:** from Flipkart’s **Best value for you** bank/card tile only — **non-EMI** (Cashback / Instant Discount). EMI / No Cost EMI / Credit Card EMI rows are ignored, as are exchange and SuperCoins. Card tokens stay empty on Amazon and other sites for now.

---

## Basics

- `{{link}}` is required.
- A line whose tags are all empty is dropped (no leftover `MRP: `).
- Truncate: `{{title[40]}}`
- Fallback: `{{mrp|N/A}}`
- Product vs listing prefixes: `{{'Price: ', 'Starts from: ', price}}`

---

## Math

Compute a number from fields (safe: only `+ - * / ( )`, numbers, and known numeric fields):

```text
{{math price - coupon - card_off}}
{{math price - card_off}}
{{math finalprice - card_off_amt}}
```

- In math, `coupon` = ₹ coupon amount; `card_off` = ₹ bank off (`card_off_amt`, or `price × card_off_pct / 100` when only %).
- Money results format as `₹…`. Result ≤ 0 or missing `price` → empty (line can drop).
- Missing optional subtractors (no coupon / no card) count as **0**.

With an if (only when bank % is strong enough):

```text
{{if card_off_pct >= 5}}
Pay {{math price - card_off}}
{{endif}}
```

Allowed fields: `price`, `mrp`, `discount`, `off`, `finalprice`, `coupon`, `coupon_amt`, `card_off`, `card_off_pct`, `card_off_amt`.

---

## Compose

Mix quoted text and field names:

```text
{{compose 'Apply ', card_bank, ' ', card_type, ' to get ', card_off}}
```

→ `Apply HDFC Credit to get 10%`

More examples:

```text
{{compose 'Price: ', price, ' (was ', mrp, ')'}}
{{compose title, ' — ', off, ' off'}}
{{compose 'Bank: ', card_bank, ' · ', card_offer}}
{{compose 'Save ', discount, ' (', off, ')'}}
```

If a field is empty it becomes blank (spaces collapse). If **every** field in the compose is empty, the whole compose is empty and the line can drop.

---

## If / else / endif

```text
{{if CONDITION}}
…shown when true…
{{else}}
…optional…
{{endif}}
```

### Presence

| Condition | True when |
|-----------|-----------|
| `price` | selling price present |
| `mrp` | MRP present |
| `coupon` | coupon text present |
| `off` / `discount` | MRP discount computable |
| `card_bank` / `card_type` / `card_offer` | that card field present |
| `card_off_pct` / `card_off_amt` | bank % / ₹ known |

### Comparisons

Ops: `>`, `<`, `>=`, `<=`, `=`, `!=` with a number:

```text
{{if off >= 20}}
Mega deal — {{off}} off MRP
{{endif}}

{{if card_off_pct >= 5}}
{{compose 'Apply ', card_bank, ' ', card_type, ' to get ', card_off}}
{{endif}}

{{if price}}
Price: {{price}}
{{else}}
Price: check link
{{endif}}
```

### Per-site (`website`)

`{{website}}` is the retailer id: `amazon`, `flipkart`, `myntra`, `croma`, `shopsy`.

Match by id **or** base URL (subdomains included). **Quotes required** (`'` or `"`):

```text
{{if website = 'amazon'}}
{{if website = "amazon"}}
{{if website = 'https://amazon.in'}}
{{if website = 'amazon.in'}}
{{if website != 'flipkart'}}
```

`https://amazon.in` / `amazon.in` matches `amazon.in`, `www.amazon.in`, `m.amazon.in`, etc.

**Amazon style with fallback title+link for every other site:**

```text
{{if website = 'amazon'}}
{{title}}
Price: {{price}}
{{coupon}}
{{link}}
{{else}}
{{title}}

{{link}}
{{endif}}
```

**Nested site + condition** (supported):

```text
{{if website = 'flipkart'}}
{{if price >= 5000}}
Apply {{card_bank}} Bank {{card_type}} Card Offer To Get @ {{math price - coupon_amt - card_off}}
{{endif}}
{{endif}}
```

**Separate blocks per site** (also fine — one after another):

```text
{{if website = 'flipkart'}}
{{title}}
Price: {{price}}
{{compose 'Apply ', card_bank, ' ', card_type, ' to get ', card_off}}
{{link}}
{{endif}}
{{if website = 'https://amazon.in'}}
{{title}} @ {{price}}
{{link}}
{{endif}}
```

**Rules:** one `{{else}}` per `{{if}}`; **nested `{{if}}` is supported**. Always close each block with `{{endif}}`. Max nesting depth 20.

---

## Full templates

### Simple + optional card offer

```text
{{title}}

{{if price}}
Price: {{price}}
{{endif}}
{{coupon}}
{{if card_off_pct >= 5}}
{{compose 'Apply ', card_bank, ' ', card_type, ' to get ', card_off}}
Pay {{math price - card_off}}
{{endif}}

Buy Now: {{link}}
```

### Gate on MRP %

```text
{{title}}

{{if off >= 20}}
🔥 {{off}} off — was {{mrp}}, now {{price}}
{{endif}}
{{if price}}
Price: {{price}}
{{endif}}

Buy Now: {{link}}
```

### Raw Flipkart line

```text
{{title}}
Price: {{price}}
{{if card_offer}}
{{card_offer}}
{{endif}}
Buy Now: {{link}}
```

### Card ₹ amount only

```text
{{if card_off_amt}}
Bank offer: {{card_off_amt}} off with {{card_bank}} {{card_type}}
{{endif}}
```

---

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Missing `{{link}}` | Add `Buy Now: {{link}}` |
| Unclosed `{{if}}` | Add matching `{{endif}}` |
| `{{if foo}}` | Use a known field name |
| `{{if off > }}` | Need a number: `{{if off >= 20}}` |
| `{{if website = amazon}}` (no quotes) | Use `{{if website = 'amazon'}}` |
| Compose typo `banc` | Use `card_bank` |
| Unclosed quote in compose | Match `'` / `"` pairs |
| `{{math price - title}}` | Only numeric fields (`price`, `coupon`, `card_off`, …) |

The editor lists these errors under the textarea and blocks Save until they are fixed.
