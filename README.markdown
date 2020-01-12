---
title: wireguard-admin
author: Steffen Uhlig
---

[![Build Status](https://travis-ci.org/suhlig/wireguard-admin.svg?branch=master)](https://travis-ci.org/suhlig/wireguard-admin)

`wg-admin` is an opinionated command-line tool to administer [Wireguard](https://www.wireguard.com/) configuration files.

# Initialize

The defining attribute of the configuration is a network. This is a range of IP addresses specified as `prefix/suffix`, e.g. `192.168.10.0/24` or `2001:0DB8:0:CD30::1/60`.

If not specified, a default is used.

Examples:

```command
$ wgadmin init
$ wgadmin init --network 192.168.10.0/24
```

# Add a server

A `server` is a peer with a public DNS name that is reachable by all clients via public internet. It's the entry point for clients into the VPN (a.k.a. relay or bounce server).

Examples:

```command
$ wgadmin add-server --name wg.example.com
$ wgadmin add-server --name wg.example.com --ip 192.168.20.128
```

This command will add a new server with the given DNS name and a default configuration. If no IP was given, the first address in the network will be used.

# Addding a client

A `client` is regular peer that does not relay (bounce) traffic. It will connect to the VPN via a server.

Examples:

```command
$ wgadmin add-client --name Alice
$ wgadmin add-client --name Alice --ip 192.168.20.11
```

If no IP address was passed, the first available address in the network (after the server) will be used.

# List

```command
$ wgadmin list
+================+========|=================|
| Name           | Type   | IP Addresses    |
+================+========|=================|
| wg.example.com | server | 192.168.20.1    |
+----------------+--------|-----------------|
| Alice          | client | 192.168.20.11   |
+----------------+--------|-----------------|
```

# Generate the config files

## Server

This command will show the configuration of the server itself as well as the necessary fragments for each client:

```command
$ wgadmin config --server
[Interface]
Address = 192.168.20.1/24
ListenPort = 51820
PrivateKey = private-key-of-the-server=

[Peer]
# Name = Alice
PublicKey = public-key-of-Alice=
AllowedIPs = 192.168.20.11/32
```

The server will be assigned the first available address of the specified network (if none was set, a default is chosen). Since no port was specified, the de-facto standard port for Wireguard will be used (`51820`).

Each client will be assigned a unique IP address within the range of the specified network.

## Client

```command
$ wgadmin config --client=Alice
[Interface]
PrivateKey = private-key-of-Alice=
Address = 192.168.20.11/24

[Peer]
PublicKey = public-key-of-the-server=
EndPoint = wg.example.com:51820
AllowedIPs = 192.168.20.0/24
PersistentKeepalive = 25
```

The result is printed to `stdout` and could be redirected to a file, or piped into a QR encoder:

```command
$ wgadmin config --client=Alice | qrencode -t ANSIUTF8
```
