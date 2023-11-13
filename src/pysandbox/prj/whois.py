# SPDX-License-Identifier: AGPL-3.0-or-later
"""WHOIS tools"""

# https://github.com/secynic/ipwhois is no longer maintained

from __future__ import annotations

import copy
import socket
import logging
from ipaddress import ip_network, IPv4Network, IPv6Network
import json

import requests
import click
from netaddr import cidr_merge

from ._cli import prj

log = logging.getLogger(__name__)


@prj.group()
def whois():
    """Retrieve and parse whois data for IPv4 and IPv6 addresses"""


@whois.command("asn-cidr")
@click.argument("asn", nargs=-1)
def _asn_cidr(asn):
    """ASN origin lookups (CIDR)

    usage::

      $ whois asn-cidr AS41947 AS40193 35718 38337 39720 39770

    """

    for whois_host in WHOIS_HOSTS:
        ipv4_list, ipv6_list = asn_networks(asn, whois_host)
        click.echo(f"# {whois_host} ..")
        for item in ipv4_list:
            click.echo(item)

        for item in ipv6_list:
            click.echo(item)


@whois.command("ASN-DROP")
@click.option(
    "--merge", is_flag=True, default=True, help="merge IPs and subnets to smallest possible list of CIDR subnets"
)
@click.argument("asn", nargs=-1)
def _asn_drop(
    asn,
    merge,
):
    """Spamhaus ASN-DROP List (CIDR)

    usage::

      $ whois ASN-DROP
      write IPv4 networks to ipv4_spamhaus_ASN-DROP.lst
      write IPv6 networks to ipv6_spamhaus_ASN-DROP.lst

    """
    ipv4_file = "ipv4_spamhaus_ASN-DROP.lst"
    ipv6_file = "ipv6_spamhaus_ASN-DROP.lst"

    url = "https://www.spamhaus.org/drop/asndrop.json"
    headers = {"accept": "application/json"}
    resp = requests.get(url, headers=headers, timeout=3)
    resp.raise_for_status()

    asn_list = []
    for line in resp.text.split("\n"):
        line = line.strip()
        if not line:
            continue
        asn = json.loads(line).get("asn")
        if not asn:
            continue
        asn_list.append(str(asn))

    ipv4_list, ipv6_list = asn_networks(asn_list, "RADB")

    if merge:
        ipv4_list = cidr_merge([str(ip) for ip in ipv4_list])
        ipv6_list = cidr_merge([str(ip) for ip in ipv6_list])

    click.echo(f"write IPv4 networks to {ipv4_file}")
    with open(ipv4_file, "w", encoding="utf-8") as f:
        for ip in ipv4_list:
            f.write(f"{ip}\n")

    click.echo(f"write IPv6 networks to {ipv6_file}")
    with open(ipv6_file, "w", encoding="utf-8") as f:
        for ip in ipv6_list:
            f.write(f"{ip}\n")


# implementations
# ---------------

# List of Routing Registries https://www.irr.net/docs/list.html#RIPE

WHOIS_DEFAULTS = {
    "no entries": "no entries found",
    "timeout": 10,
}

WHOIS_HOSTS = {
    "AFRINIC": {"server": "whois.afrinic.net", "port": 43},
    "ALTDB": {
        "server": "whois.altdb.net",
        "port": 43,
    },
    "APNIC": {
        "server": "whois.apnic.net",
        "port": 43,
    },
    "ARIN": {
        "server": "rr.arin.net",
        "port": 43,
    },
    "BELL": {
        "server": "whois.in.bell.ca",
        "port": 43,
    },
    "BBOI": {
        "server": "irr.bboi.net",
        "port": 43,
    },
    "CANARIE": {
        "server": "whois.canarie.ca",
        "port": 43003,
    },
    "IDNIC": {
        "server": "irr.idnic.net",
        "port": 43,
    },
    "JPIRR": {
        "server": "jpirr.nic.ad.jp",
        "port": 43,
    },
    "LACNIC": {
        "server": "irr.lacnic.net",
        "port": 43,
    },
    "NTTCOM": {
        "server": "rr.ntt.net",
        "port": 43,
    },
    "NESTEGG": {
        "server": "whois.nestegg.net",
        "port": 43,
    },
    "LEVEL3": {
        "server": "rr.Level3.net",
        "port": 43,
    },
    "PANIX": {
        "server": "rrdb.access.net",
        "port": 43,
    },
    "RADB": {
        "server": "whois.radb.net",
        "port": 43,
    },
    "REACH": {
        "server": "rr.telstraglobal.net",
        "port": 43,
    },
    "RIPE": {
        "server": "whois.ripe.net",
        "port": 43,  # 4444, RIPE near real time mirror
    },
    "TC": {
        "server": "whois.bgp.net.br",
        "port": 43,
    },
}


class WhoisLookupError(Exception):
    """Exception when a WHOIS query fails."""


def asn_networks(asn_list: list[str], whois_host: str) -> tuple[list, list]:
    """get networks of ASN in the ``asn_list``"""

    ipv4_list, ipv6_list = [], []

    for asn in asn_list:
        ipv4, ipv6 = asn_origin_cidr(asn, whois_host)
        ipv4_list.extend(ipv4)
        ipv6_list.extend(ipv6)

    return ipv4_list, ipv6_list


def asn_origin_cidr(asn: str, whois_host: str) -> tuple[list[IPv4Network], list[IPv6Network]]:
    """returns the CIDR of an ASN"""
    ipv4_list, ipv6_list = [], []

    host_setup = copy.deepcopy(WHOIS_DEFAULTS)
    host_setup.update(WHOIS_HOSTS[whois_host])

    resp = asn_origin_whois(asn, host_setup=host_setup)
    fields = parse_whois_resp(resp, host_setup=host_setup)
    if not fields:
        return ipv4_list, ipv6_list

    for entry in fields:
        for item in entry.get("route", []) + entry.get("route6", []):
            net = ip_network(item, strict=False)
            if net.version == 4:
                ipv4_list.append(net)
            else:
                ipv6_list.append(net)

    return ipv4_list, ipv6_list


def asn_origin_whois(asn: str, host_setup: dict) -> str:
    """whois inverse origin ASN search"""

    if not asn.startswith("AS"):
        asn = "AS" + asn
    query = f" -i origin {asn}\r\n"

    try:
        conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        conn.settimeout(host_setup["timeout"])
        conn.connect((host_setup["server"], host_setup["port"]))
        conn.send(query.encode())

        resp = ""
        while True:
            d = conn.recv(4096).decode()
            resp += d
            if not d:
                break
        conn.close()

    except (socket.timeout, socket.error) as exc:
        log.error("ASN origin WHOIS query socket error: %s", exc)
        raise WhoisLookupError(f"ASN origin WHOIS lookup failed for {asn}.") from exc

    return resp


def parse_whois_resp(resp: str, host_setup: dict):
    """parse a WHOIS response"""

    entries = []
    d = {}
    last_field = None
    for line in resp.split("\n"):
        if not line:
            if d:
                entries.append(d)
            d = {}
            continue
        if line.startswith("%"):
            if host_setup["no entries"] in line.lower():
                log.info("parse_whois_resp: %s", line)
                break
            continue
        if line.startswith(" ") or line.startswith("\t"):
            field = last_field
            value = line.strip()
        else:
            field, value = line.split(":", 1)
            field, value = field.strip(), value.strip()
            last_field = field
        l = d.get(field, [])
        l.append(value)
        d[field] = l
    if d:
        entries.append(d)

    return entries
