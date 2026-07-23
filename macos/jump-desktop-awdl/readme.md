# Jump Desktop AWDL aliases

This folder contains a small idempotent installer script that adds two aliases to an existing `~/.zshrc`:

```sh
prepare-jump-desktop
jump-desktop-finished
```

## Why these aliases exist

Jump Desktop became much more stable when `awdl0` was disabled on the MacBook before connecting to the Mac Mini.

The observed symptom was high latency and jitter on the local network, even though both Macs were close to the same UniFi access point. Ping times showed repeated spikes into the hundreds of milliseconds. After disabling AWDL, latency dropped to a much more stable range.

`awdl0` is used by Apple Wireless Direct Link. macOS uses it for peer-to-peer features such as AirDrop, Handoff, Universal Clipboard, some Continuity features, peer-to-peer AirPlay, Sidecar, and related Apple ecosystem behavior. On this setup it appears to interfere with low-latency Wi-Fi traffic enough to make Jump Desktop feel laggy.

## Install

Run:

```sh
sh install-jump-desktop-awdl-aliases.sh
```

Then reload the shell:

```sh
source ~/.zshrc
```

The script is idempotent. It checks whether the aliases already exist in `~/.zshrc` and does not add duplicates.

## Use

Before starting a Jump Desktop session:

```sh
prepare-jump-desktop
```

This runs:

```sh
sudo ifconfig awdl0 down
```

After finishing the Jump Desktop session:

```sh
jump-desktop-finished
```

This runs:

```sh
sudo ifconfig awdl0 up
```

You may be asked for your macOS password because both commands use `sudo`.

## What is affected

While `awdl0` is disabled, some Apple peer-to-peer and Continuity features may stop working or become unreliable, including:

- AirDrop
- Handoff
- Universal Clipboard
- Sidecar
- iPhone Mirroring
- peer-to-peer AirPlay
- some Continuity-related discovery features

Running `jump-desktop-finished` turns the interfaces back on. A reboot will normally bring them back as well.

## Remove the aliases

Open `~/.zshrc` and remove this managed block:

```sh
# >>> Jump Desktop AWDL aliases >>>
alias prepare-jump-desktop='sudo ifconfig awdl0 down'
alias jump-desktop-finished='sudo ifconfig awdl0 up'
# <<< Jump Desktop AWDL aliases <<<
```

Then reload the shell:

```sh
source ~/.zshrc
```
