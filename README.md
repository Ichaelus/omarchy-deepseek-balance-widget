# DeepSeek balance widget for the Omarchy bar

A small pill in the [Omarchy](https://omarchy.org) top bar showing the current
balance of a DeepSeek API account. Hovering shows a tooltip with the same figure,
refreshed on the spot; clicking opens the usage page.

```
$5.94
```

## Install

```bash
./install.sh
```

That symlinks the two files into `~/.config/omarchy/bar/`, so edits in this repo
are what the shell loads. Then add the module to `~/.config/omarchy/shell.json`
(the script prints the exact entry):

```json
{
  "id": "deepseek-balance",
  "type": "qml",
  "onClick": "xdg-open https://platform.deepseek.com/usage"
}
```

It goes in `bar.layout.right` — anywhere in that list works.

## API key

Set `$DEEPSEEK_API_KEY`, or put the bare key in
`~/.config/omarchy/bar/deepseek-key` (mode 600). The env var wins.

The key file is **never** committed — it lives outside this repo, and
`.gitignore` covers it in case one is dropped in.

## How it works

Two files:

- `bar/scripts/deepseek-balance` — fetches
  `GET https://api.deepseek.com/user/balance` and prints one line of
  waybar-style JSON (`{"text":…,"tooltip":…}`). It has no schedule of its own;
  every invocation fetches. The last good response is cached at
  `~/.cache/omarchy/deepseek-balance.json` and used when the API is unreachable.
- `bar/modules/deepseek-balance.qml` — the bar module. Owns the refresh timer
  and the hover refresh, and renders through the shell's shared `WidgetButton`.

The script must print a **single line**: the bar's parser reads only the last
line of a module's output.

### Tooltip contents

Normally the tooltip is one line:

```
DeepSeek balance
Balance: $5.94
```

`granted_balance` is DeepSeek's free promotional credit, which expires;
`topped_up_balance` is money actually paid in; `total = granted + topped_up`.
When there is grant to account for, the tooltip breaks the total down:

```
DeepSeek balance
Total: $12.00
Granted: $6.06
Topped up: $5.94
```

## Refresh

Polling backs off while the balance holds still:

| Balance since the last fetch | Next refresh |
| --- | --- |
| changed | 5 min |
| unchanged | 10, 15, 20, 25, then 30 min |

A change resets the interval to 5 minutes; 30 minutes is the ceiling. Hovering
refreshes immediately, and an open tooltip is re-rendered with what that fetch
returned. Hover refreshes are debounced so that hovering repeatedly cannot
hammer the API, and they count for the backoff like any other fetch.

A 5-minute floor is up to 288 requests in an active day, against 48 at the
ceiling. The floor only applies while the balance is actually moving.

The interval lives in memory, so restarting the shell starts at 5 minutes.

## Requirements

`bash`, `curl`, `jq`, and a running Omarchy shell. Nothing else.
