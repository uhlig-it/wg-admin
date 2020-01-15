---
title: wireguard-admin
author: Steffen Uhlig
---

[![Build Status](https://travis-ci.org/suhlig/wireguard-admin.svg?branch=master)](https://travis-ci.org/suhlig/wireguard-admin)

`wg-admin` is a command-line tool to administer [Wireguard](https://www.wireguard.com/) configuration files. It maintains a local database of networks, which each has a number of peers. From this database, the configuration can be rendered for all peers.

Deploying the configuration is outside the scope of this project.

# Add a Network

The defining attribute of the configuration is a network. This is a range of IP addresses specified as `prefix/suffix`, e.g. `192.168.10.0/24` or `2001:0DB8:0:CD30::1/60`.

Examples:

```command
$ wgadmin add-network 192.168.10.0/24
```

# Add a Server

A `server` is a peer with a public DNS name that is reachable by all clients via public internet. It's the entry point for clients into the VPN (a.k.a. relay or bounce server).

Examples:

```command
$ wgadmin add-server --name wg.example.com
$ wgadmin add-server --name wg.example.com --ip 192.168.20.128
```

This command will add a new server with the given DNS name and a default configuration. If no IP address was passed, the next available address in the network will be used. When no port was specified, the de-facto standard port for Wireguard will be used (`51820`).

# Add a Client

A `client` is regular peer that does not relay (bounce) traffic. It will connect to the VPN via a server.

Examples:

```command
$ wgadmin add-client --name Alice
$ wgadmin add-client --name Alice --ip 192.168.20.11
```

If no IP address was passed, the next available address in the network will be used.

# List Peers

```command
$ wgadmin list-peers
+================+========|=================|
| Name           | Type   | IP Addresses    |
+================+========|=================|
| wg.example.com | server | 192.168.20.1    |
+----------------+--------|-----------------|
| Alice          | client | 192.168.20.11   |
+----------------+--------|-----------------|
```

`TODO` If this command is run without a (pseudo) terminal, it will print the name of each peer on a single line, which allows for a convenient loop over all peers, e.g. for writing configuration files (see below for further details):

```command
$ for name in $(wgadmin list-peers); do
  wgadmin config "$name" > "$name".conf
done
```

# `TODO` Generate the Config Files

This command will show the configuration of the server itself as well as the necessary fragments for a particular peer:

```command
$ wgadmin config wg.example.com
[Interface]
Address = 192.168.20.1/24
ListenPort = 51820
PrivateKey = private-key-of-the-server=

[Peer]
# Name = Alice
PublicKey = public-key-of-Alice=
AllowedIPs = 192.168.20.11/32
```

The result is printed to `stdout` and could be redirected to a file, or piped into a QR encoder:

```command
$ wgadmin config --client=Alice | qrencode -t ANSIUTF8
```
