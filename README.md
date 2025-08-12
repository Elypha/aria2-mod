# aria2-mod
[![Version](https://img.shields.io/github/v/release/Elypha/aria2-mod)](https://github.com/Elypha/aria2-mod/releases)
[![downloads](https://img.shields.io/github/downloads/Elypha/aria2-mod/total)](https://github.com/Elypha/aria2-mod/releases)

Pre-compiled [aria2](https://github.com/aria2/aria2) and [AriaNg-Native](https://github.com/mayswind/AriaNg-Native) with QoL modifications for Windows and Linux.

If you find it helpful please consider staring this project so that I will know, and I appreciate it much.

## Introduction

Supported and currently maintained architectures and platforms are as follows.

All releases are built with [Github Actions](https://github.com/Elypha/aria2-mod/actions) for transparency.

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
            <td rowspan=5><a href="https://github.com/Elypha/aria2-mod/releases/tag/aria2c-1.37.0-b519ce0-20250812">v1.37.0-b519ce0-20250812</a></td>
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

You may also 'watch' this repo to subscribe to future releases, and make sure you select the right kinds of notification in the sub-menu to avoid unwanted pings.

All (previous) binaries are available in [Releases](https://github.com/Elypha/aria2-mod/releases).

Feedback is much appreciated via [Issues](https://github.com/Elypha/aria2-mod/issues).

## Changes

*__Make sure you understand the changes before using any release from this repo.__*

A brief description is provided as follows and the patch files are available in the corresponding folders. Please also refer to the official `readme` of each project.

### aria2

1. Configuration `max-connection-per-server`: upper limit is removed (originally `16`).
2. Configuration `min-split-size`: lower limit is set to `1K` (originally `1M`); default value is set to `4M` (originally `20M`).
3. When 'speed drops below `lowest-speed-limit`' or 'connection closed', default behaviour is set to `restart` (originally `abort`).
4. New options to automatically retry if `http-4xx` error is encountered.
   - `--retry-on-400[=true|false]`
   - `--retry-on-403[=true|false]`
   - `--retry-on-406[=true|false]`
   - `--retry-on-unknown[=true|false]`
5. ~~New option `http-want-digest` to NOT send [Want-Digest HTTP header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Want-Digest).~~ Deprecated, aria2 has `no-want-digest-header` as of 1.37.0
6. Default output path is set to current path (originally `$HOME` (i.e. user home dir)).

### AriaNg-Native

1. Configuration `max-connection-per-server`: GUI config validation of upper limit is removed (originally `16`).
2. Configuration `min-split-size`: default value is set to `4M` (originally `20M`).
3. Configuration `split`: default value is set to `16` (originally `5`).
