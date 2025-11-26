# aria2-mod
[![Version](https://img.shields.io/github/v/release/Elypha/aria2-mod)](https://github.com/Elypha/aria2-mod/releases)
[![downloads](https://img.shields.io/github/downloads/Elypha/aria2-mod/total)](https://github.com/Elypha/aria2-mod/releases)

Pre-compiled [aria2](https://github.com/aria2/aria2) and [AriaNg-Native](https://github.com/mayswind/AriaNg-Native) with QoL modifications for Windows and Linux.

If this project helps you, a star would be greatly appreciated - it lets me know my work is useful :)

## Introduction

*__Make sure you understand the changes ([section below](https://github.com/Elypha/aria2-mod#changes)) before using any release from this repo.__*

Please file an [issue](https://github.com/Elypha/aria2-mod/issues) if you encounter any stability issues, particularly regarding memory leaks. Feedbacks are also much appreciated.

<table>
    <thead>
        <tr>
            <th>Application</th>
            <th>Platform</th>
            <th>Architecture</th>
            <th>TLS</th>
            <th>Download</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=6><a href="https://github.com/aria2/aria2">aria2</a></td>
            <td rowspan=4>Windows</td>
            <td rowspan=2>amd64</td>
            <td>OpenSSL</td>
            <td rowspan=5><a href="https://github.com/Elypha/aria2-mod/releases/tag/aria2c-1.37.0-b4fd7cb-20251126">v1.37.0-b4fd7cb-20251126</a></td>
        </tr>
        <tr>
            <td>Windows TLS</td>
        </tr>
        <tr>
            <td rowspan=2>i386</td>
            <td>OpenSSL</td>
        </tr>
        <tr>
            <td>Windows TLS</td>
        </tr>
        <tr>
            <td rowspan=2>Linux</td>
            <td>amd64</td>
            <td>OpenSSL</td>
        </tr>
        <tr>
            <td>i386</td>
            <td>OpenSSL</td>
            <td>RIP</td>
        </tr>
        <tr>
            <td rowspan=3><a href="https://github.com/mayswind/AriaNg-Native">AriaNg-Native</a></td>
            <td rowspan=2>Windows</td>
            <td>amd64</td>
            <td>-</td>
            <td rowspan=2><a href="https://github.com/Elypha/aria2-mod/releases/tag/ariang-1.3.11">v1.3.11</a></td>
        </tr>
        <tr>
            <td>i386</td>
            <td>-</td>
        </tr>
        <tr>
            <td>macOS</td>
            <td>amd64</td>
            <td>-</td>
            <td>RIP</td>
        </tr>
    </tbody>
</table>

For updates, you can 'Star' this repo to see updates in your GitHub feeds, or 'Watch' this repo and subscribe to releases to get notified (uncheck others to avoid unwanted pings).

These softwares are mostly stable and complete, and you don't have to update if it doesn't deliver a feature you need.

See [Releases](https://github.com/Elypha/aria2-mod/releases) for all previous binaries. Check out [Actions](https://github.com/Elypha/aria2-mod/actions) for workflows to produce these binaries.

## Changes

### aria2

1. **[0001](https://github.com/Elypha/aria2-mod/blob/master/aria2-patch/0001-options-unlock-connection-per-server-limit.patch) Configuration `max-connection-per-server`**
   - Patch: Upper limit is removed.
   - Original behaviour: Upper limit is `16`.
2. **[0002](https://github.com/Elypha/aria2-mod/blob/master/aria2-patch/0002-options-lower-min-split-size.patch) Configuration `min-split-size`**
   - Patch: Default value is set to `4M` (lower limit = `1K`).
   - Original behaviour: Default value is `20M` (lower limit = `1M`).
3. **[0003](https://github.com/Elypha/aria2-mod/blob/master/aria2-patch/0003-download-retry-on-slow-speed-or-reset.patch) Download at best effort**
   - Patch: When 'speed drops below `lowest-speed-limit`' or encounter 'connection closed', default behaviour is set to `restart`.
   - Original behaviour: Default behaviour is `abrot`.
4. **[0004](https://github.com/Elypha/aria2-mod/blob/master/aria2-patch/0004-option-add-option-to-retry-on-http-4xx.patch) Add option to retry on `HTTP 4xx`.**
   - Patch: New options to automatically retry if http-4xx error is encountered.
       - `--retry-on-400[=true|false]`
       - `--retry-on-403[=true|false]`
       - `--retry-on-406[=true|false]`
       - `--retry-on-unknown[=true|false]`
5. ~~[0005](https://github.com/Elypha/aria2-mod/blob/master/aria2-patch/expired/0005-option-add-option-to-disable-want-digest-header.patch) New option `--http-want-digest` to NOT send [Want-Digest HTTP header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Want-Digest).~~ Deprecated: aria2 has `--no-want-digest-header` as of 1.37.0.
6. **[0006](https://github.com/Elypha/aria2-mod/blob/master/aria2-patch/0006-options-change-default-path-to-current-dir.patch) Download to current path**
   - Patch: Default output path is set to the current working path.
   - Original behaviour: Default path is `$HOME` (i.e. user home dir).
7. **[0007](https://github.com/Elypha/aria2-mod/blob/master/aria2-patch/0007-retry-raw-deflate-mode.patch) Add support for raw deflate stream.**

### AriaNg-Native

1. **[0001](https://github.com/Elypha/aria2-mod/blob/master/ariang-native-patch/0001-options-unlock-connection-per-server-limit.patch) Configuration `max-connection-per-server`**
   - Patch: Value validation (upper limit) on the GUI is removed.
   - Original behaviour: Upper limit is `16`.
3. **[0002](https://github.com/Elypha/aria2-mod/blob/master/ariang-native-patch/0002-options-lower-default-min-split-size.patch) Configuration `min-split-size`**
   - Patch: Default value is set to `4M`.
   - Original behaviour: Default value is `20M`.
5. **[0003](https://github.com/Elypha/aria2-mod/blob/master/ariang-native-patch/0003-options-higher-default-splits.patch) Configuration `split`**
   - Patch: Default value is set to `16`.
   - Original behaviour: Default value is `5`.
