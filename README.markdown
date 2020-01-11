---
title: wireguard-admin
author: Steffen Uhlig
---

[![Build Status](https://travis-ci.org/suhlig/wireguard-admin.svg?branch=master)](https://travis-ci.org/suhlig/wireguard-admin)

`wg-admin` is an opinionated command-line tool to administer [Wireguard](https://www.wireguard.com/) configuration.

# Create the initial config

Create the relay (bounce) server:

```command
$ wgadmin init --name wg.example.com
```

This command will add a new server to the database with the given name and a default configuration. Note that no config files are written yet; this is the subject of another [`command`](#generate-the-cpnfig-files).

# Addding a new client

Let's call the client "Alice":

```command
$ wgadmin add-client Alice --ip 192.168.20.11
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
