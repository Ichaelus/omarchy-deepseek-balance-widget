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
  "interval": 1800,
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

The timer refreshes on the configured interval, and hovering refreshes again
(debounced, so hovering repeatedly does not hammer the API). An open tooltip is
re-rendered with whatever the refresh returned.

## Requirements

`bash`, `curl`, `jq`, and a running Omarchy shell. Nothing else.
