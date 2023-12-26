# aria2-mod
[![Version](https://img.shields.io/github/v/release/Elypha/aria2-mod)](https://github.com/Elypha/aria2-mod/releases)
[![downloads](https://img.shields.io/github/downloads/Elypha/aria2-mod/total)](https://github.com/Elypha/aria2-mod/releases)

[aria2](https://github.com/aria2/aria2) and [AriaNg-Native](https://github.com/mayswind/AriaNg-Native) with QoL modifications.

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
            <td rowspan=6><a href="https://github.com/aria2/aria2">aira2</a></td>
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

Archive of all the binaries is available in [Releases](https://github.com/Elypha/aria2-mod/releases).

Feedback is much appreciated via [Issues](https://github.com/Elypha/aria2-mod/issues).

## Features

*__Make sure you understand the modification before using any release from this repo.__* You may refer to the description below or check out the patch files in the corresponding folders. Please also read the original `readme` of each application.

### aira2

1. Remove the upper limit of `max-connection-per-server`, which is originally `16`.
2. `min-split-size` can be as low as `1K`, which is originally `1M`, with the default value set to `1M`, which is originally `20M`.
3. 'Restart' instead of 'abort' when 'speed drops below `lowest-speed-limit`' or 'connection closed'.
4. New feature: option to automatically retry if http-4xx error is encountered.
5. New feature: option to NOT send [Want-Digest HTTP header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Want-Digest).
6. Change default path to current dir, which is originally the user path (i.e. home dir).

### AriaNg-Native

1. Remove the upper limit of `max-connection-per-server` in settings GUI, which is originally `16`.
2. `min-split-size` defaults to `1M`, which is originally `20M`.
3. `split` defaults to `16`, which is originally `5`.
