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
            <th>Build</th>
            <th>Release</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=6><a href="https://github.com/aria2/aria2">aria2</a></td>
            <td rowspan=4>Windows</td>
            <td rowspan=2>amd64</td>
            <td>OpenSSL</td>
            <td><a href="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-windows-x86_64-openssl.yml"><img src="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-windows-x86_64-openssl.yml/badge.svg" alt="aria2c-windows-x86_64-openssl" style="max-width: 100%;"></a></td>
            <td><a href="https://github.com/Elypha/aria2-mod/releases/download/2023-12-25/aria2c-windows-x86_64-openssl.zip">2023-12-25</a></td>
        </tr>
        <tr>
            <td>Windows TLS</td>
            <td><a href="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-windows-x86_64-wintls.yml"><img src="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-windows-x86_64-wintls.yml/badge.svg" alt="aria2c-windows-x86_64-wintls" style="max-width: 100%;"></a></td>
            <td><a href="https://github.com/Elypha/aria2-mod/releases/download/2023-12-25/aria2c-windows-x86_64-wintls.zip">2023-12-25</a></td>
        </tr>
        <tr>
            <td rowspan=2>i386</td>
            <td>OpenSSL</td>
            <td><a href="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-windows-i686-openssl.yml"><img src="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-windows-i686-openssl.yml/badge.svg" alt="aria2c-windows-i686-openssl" style="max-width: 100%;"></a></td>
            <td><a href="https://github.com/Elypha/aria2-mod/releases/download/2023-12-25/aria2c-i686-x86_64-openssl.zip">2023-12-25</a></td>
        </tr>
        <tr>
            <td>Windows TLS</td>
            <td><a href="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-windows-i686-wintls.yml"><img src="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-windows-i686-wintls.yml/badge.svg" alt="aria2c-windows-i686-wintls" style="max-width: 100%;"></a></td>
            <td><a href="https://github.com/Elypha/aria2-mod/releases/download/2023-12-25/aria2c-i686-x86_64-wintls.zip">2023-12-25</a></td>
        </tr>
        <tr>
            <td rowspan=2>Linux</td>
            <td>amd64</td>
            <td>OpenSSL</td>
            <td><a href="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-linux-amd64-openssl.yml"><img src="https://github.com/Elypha/aria2-mod/actions/workflows/aria2c-linux-amd64-openssl.yml/badge.svg" alt="aria2c-linux-amd64-openssl" style="max-width: 100%;"></a></td>
            <td><a href="https://github.com/Elypha/aria2-mod/releases/download/2023-12-25/aria2c-linux-amd64-openssl.zip">2023-12-25</a></td>
        </tr>
        <tr>
            <td>i386</td>
            <td>OpenSSL</td>
            <td>-</td>
            <td>RIP</td>
        </tr>
        <tr>
            <td rowspan=3><a href="https://github.com/mayswind/AriaNg-Native">AriaNg-Native</a></td>
            <td rowspan=2>Windows</td>
            <td>amd64</td>
            <td>-</td>
            <td><a href="https://github.com/Elypha/aria2-mod/actions/workflows/ariang-windows.yml"><img src="https://github.com/Elypha/aria2-mod/actions/workflows/ariang-windows.yml/badge.svg" alt="ariang-windows" style="max-width: 100%;"></a></td>
            <td><a href="https://github.com/Elypha/aria2-mod/releases/download/2023-12-25/AriaNg_Native-windows-x64.7z.zip">2023-12-25</a></td>
        </tr>
        <tr>
            <td>i386</td>
            <td>-</td>
            <td><a href="https://github.com/Elypha/aria2-mod/actions/workflows/ariang-windows.yml"><img src="https://github.com/Elypha/aria2-mod/actions/workflows/ariang-windows.yml/badge.svg" alt="ariang-windows" style="max-width: 100%;"></a></td>
            <td><a href="https://github.com/Elypha/aria2-mod/releases/download/2023-12-25/AriaNg_Native-windows-x86.7z.zip">2023-12-25</a></td>
        </tr>
        <tr>
            <td>macOS</td>
            <td>amd64</td>
            <td>-</td>
            <td>-</td>
            <td>RIP</td>
        </tr>
    </tbody>
</table>

You may also 'watch' this repo to subscribe to future releases, and make sure you select the right kinds of notification in the sub-menu to avoid annoying messages.

All the binaries are available in [Releases](https://github.com/Elypha/aria2-mod/releases).

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
