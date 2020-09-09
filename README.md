# aria2-alter

## Info

Aira2 and related softwares with options tweaked for better download performance. This repo includes no code modification and is mainly targeting Windows platform.

Please also refer to the original readme of each project involved.

*Portable packs and installers for Windows x64 build are provided in the release.*

## Features

### aira2

- Removed the upper bound for `max-connection-per-server`.

- Allow `min-split-size` to `1K` with the default value set to `1M`.

- Restart instead of abort when speed drops below `lowest-speed-limit` or connection closed.

### AriaNg-Native

- Removed the upper bound for `max connections per server` in settings.

- `min-split-size` defaults to `1M`.

- `split` defaults to `16`.
