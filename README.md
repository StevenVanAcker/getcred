# getcred

Retrieves credentials from a password manager (Bitwarden) and outputs them in
formats useful for scripting: NetworkManager keyfiles, netplan YAML, wg-quick
configs, hosts files, and more.

## Dependencies

- [`bw`](https://bitwarden.com/help/cli/) — Bitwarden CLI
- `bw-login-and-unlock` — helper script that logs in / unlocks and writes the
  session token to `~/.bw_session`
- `wg` — WireGuard tools (only needed for `wireguard generate-server-config`)
- [`argcomplete`](https://pypi.org/project/argcomplete/) — tab completion

## Tab completion

```bash
eval "$(register-python-argcomplete getcred)"
```

Add this to your shell's rc file for persistent completion.

## Vault structure

Items are read from two Bitwarden folders:

| Folder | Contents |
|---|---|
| `AutoInstaller WiFi` | One item per wireless network |
| `AutoInstaller WireGuard` | One item per WireGuard peer/server, plus defaults items |

Configuration is stored in each item's **Notes** field as `Key=Value` pairs,
one per line.

### WiFi item notes fields

| Key | Description | Default |
|---|---|---|
| `Password` | WPA pre-shared key or EAP password | — |
| `Type` | `wpa-psk` or `wpa-eap` | `wpa-psk` |
| `Username` | EAP identity (required for `wpa-eap`) | — |
| `Autoconnect` | `true` / `false` | `true` |
| `ignore` | Set to `true` to skip this item | `false` |

The item **name** is used as the SSID.

### WireGuard item notes fields

| Key | Description |
|---|---|
| `Type` | VPN type label, e.g. `nexus` |
| `Key` | WireGuard private key |
| `Address` | Tunnel IP address (without prefix length) |
| `Hostname` | Short hostname of this peer |
| `DNS` | DNS server(s), semicolon-separated (NM format) |
| `DNSSearch` | Search domain(s), semicolon-separated (NM format) |
| `DNSPriority` | NM dns-priority value, e.g. `-50` |
| `Server` | VPN server endpoint, `host:port` |
| `ServerPubKey` | VPN server's WireGuard public key |
| `AllowedIPs` | Allowed IP ranges, semicolon-separated (NM format) |
| `Autoconnect` | `true` / `false` (default from type defaults or `true`) |
| `isServer` | `true` for the server peer |

#### Type defaults items

An item named `<type>---defaults` (e.g. `nexus---defaults`) is not treated as
a peer. Its Notes fields are applied as defaults to all items of that type,
and individual items can override them. The `Server` field in the defaults item
must be `host:port` and is used to extract the `ListenPort` for server configs.

## Usage

### WiFi

```
getcred wifi list
```
Print all SSIDs, one per line.

```
getcred wifi ssid-pw-list
```
Print `SSID:password` pairs, one per line.

```
getcred wifi get-pw <ssid>
```
Print the password for `<ssid>` (no trailing newline).

```
getcred wifi generate-nm-config <ssid>
```
Print a NetworkManager keyfile for `<ssid>`.

```
getcred wifi generate-netplan-config <ssid>
```
Print a netplan YAML config for `<ssid>`. Matches any `wl*` interface.
Supports both `wpa-psk` and `wpa-eap`.

### WireGuard

```
getcred wireguard list
```
Print all WireGuard profile names, one per line.

```
getcred wireguard generate-nm-config <name>
```
Print a NetworkManager keyfile for the named profile.

```
getcred wireguard generate-netplan-config <name>
```
Print a netplan config file for the named profile (NetworkManager renderer).
Produces the same format Ubuntu 24.04 uses when it converts an NM keyfile to
netplan: DNS priority and search domains go into `networkmanager.passthrough`
so they are preserved exactly as NM expects them.

```
getcred wireguard generate-wg-quick-config <name>
```
Print a `wg-quick` config for the named profile.

```
getcred wireguard generate-server-config <type>
```
Print a `wg-quick` server config for all peers of the given type. Expects
exactly one item with `isServer=true`; all other items become `[Peer]` entries.
Derives each peer's public key from its stored private key using `wg pubkey`.

```
getcred wireguard generate-hosts-file <type>
```
Print a hosts file fragment (`address hostname.vpn`) for all peers of the
given type. Suitable for appending to `/etc/hosts` or a `hosts.extra` file.
