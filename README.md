# aria2-mod
[![Version](https://img.shields.io/github/v/release/Elypha/aria2-mod)](https://github.com/Elypha/aria2-mod/releases)
[![Release Date](https://img.shields.io/github/release-date/Elypha/aria2-mod)](https://github.com/Elypha/aria2-mod/releases)

[![build-aria2c-linux](https://github.com/Elypha/aria2-mod/actions/workflows/build-aria2c-linux-amd64.yml/badge.svg)](https://github.com/Elypha/aria2-mod/actions/workflows/build-aria2c-linux-amd64.yml)
[![build-aria2c-windows](https://github.com/Elypha/aria2-mod/actions/workflows/build-aria2c-windows-amd64.yml/badge.svg)](https://github.com/Elypha/aria2-mod/actions/workflows/build-aria2c-windows-amd64.yml)
[![build-ariang](https://github.com/Elypha/aria2-mod/actions/workflows/build-ariang-windows-amd64.yml/badge.svg)](https://github.com/Elypha/aria2-mod/actions/workflows/build-ariang-windows-amd64.yml)

A repository containing scripts to build [aria2](https://github.com/aria2/aria2) and [AriaNg-Native](https://github.com/mayswind/AriaNg-Native) with modifications and extra features that are supposed to improve user experience.

Feedbacks would be much appreciated, and please star to let me know if this repo should be helpful.

## Introduction

This project builds binaries for the following platforms and architectures.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Platform</th>
            <th>Architecture</th>
            <th>Release</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=3><a href="https://github.com/aria2/aria2">aira2</a></td>
            <td rowspan=2>Windows</td>
            <td>amd64</td>
            <td>binary</td>
        </tr>
        <tr>
            <td>i386</td>
            <td>binary</td>
        </tr>
        <tr>
            <td>Linux</td>
            <td>amd64</td>
            <td>binary</td>
        </tr>
        <tr>
            <td rowspan=3><a href="https://github.com/mayswind/AriaNg-Native">AriaNg-Native</a></td>
            <td rowspan=2>Windows</td>
            <td>amd64</td>
            <td>portable, msi</td>
        </tr>
        <tr>
            <td>i386</td>
            <td>portable, msi</td>
        </tr>
        <tr>
            <td>macOS</td>
            <td>-</td>
            <td>-</td>
        </tr>
    </tbody>
</table>

All files are built via [Github Actions](https://github.com/Elypha/aria2-mod/actions), to which you may refer for further details, and releases are all available on [Github releases](https://github.com/Elypha/aria2-mod/releases).

*__Please also refer to the original `readme` of each project above before using any release from this project.__*

## Features

### aira2

1. Remove the upper limit of `max-connection-per-server`, which is originally `16`.
2. `min-split-size` can be as low as `1K`, which is originally `1M`, with the default value set to `1M`, which is originally `20M`.
3. Restart instead of abort when speed drops below `lowest-speed-limit` or connection closed.
4. New feature: added option to automatically retry if http-4xx error is encountered.
5. New feature: added option to NOT send [Want-Digest HTTP header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Want-Digest).
6. Change default path to current dir, which is originally the user path (i.e. home dir).

### AriaNg-Native

1. Remove the upper limit of `max-connection-per-server` in settings check, which is originally `16`.
2. `min-split-size` defaults to `1M`, which is originally `20M`.
3. `split` defaults to `16`, which is originally `5`.
