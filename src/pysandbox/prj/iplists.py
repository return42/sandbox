# SPDX-License-Identifier: AGPL-3.0-or-later
"""Work with IP lists"""
# pylint: disable = consider-using-f-string, too-many-arguments

from __future__ import annotations
from typing import IO
from dataclasses import dataclass
import re

import click
from netaddr import cidr_merge

from ._cli import prj

# Regular expressions
# -------------------
#
# Stolen from .. and slightly modified
# https://gist.github.com/dfee/6ed3a4b05cfe7a6faf40a2102408d5d8

# pylint: disable = line-too-long
IPV4SEG = r"(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])"
IPV4ADDR = r"(?:(?:" + IPV4SEG + r"\.){3,3}" + IPV4SEG + r")"
IPV6SEG = r"(?:(?:[0-9a-fA-F]){1,4})"
IPV6GROUPS = (
    r"(?:" + IPV6SEG + r":){7,7}" + IPV6SEG,  # 1:2:3:4:5:6:7:8
    r"(?:" + IPV6SEG + r":){1,7}:",  # 1::                                 1:2:3:4:5:6:7::
    r"(?:" + IPV6SEG + r":){1,6}:" + IPV6SEG,  # 1::8               1:2:3:4:5:6::8   1:2:3:4:5:6::8
    r"(?:" + IPV6SEG + r":){1,5}(?::" + IPV6SEG + r"){1,2}",  # 1::7:8             1:2:3:4:5::7:8   1:2:3:4:5::8
    r"(?:" + IPV6SEG + r":){1,4}(?::" + IPV6SEG + r"){1,3}",  # 1::6:7:8           1:2:3:4::6:7:8   1:2:3:4::8
    r"(?:" + IPV6SEG + r":){1,3}(?::" + IPV6SEG + r"){1,4}",  # 1::5:6:7:8         1:2:3::5:6:7:8   1:2:3::8
    r"(?:" + IPV6SEG + r":){1,2}(?::" + IPV6SEG + r"){1,5}",  # 1::4:5:6:7:8       1:2::4:5:6:7:8   1:2::8
    IPV6SEG + r":(?:(?::" + IPV6SEG + r"){1,6})",  # 1::3:4:5:6:7:8     1::3:4:5:6:7:8   1::8
    r":(?:(?::" + IPV6SEG + r"){1,7}|:)",  # ::2:3:4:5:6:7:8    ::2:3:4:5:6:7:8  ::8       ::
    r"fe80:(?::"
    + IPV6SEG
    + r"){0,4}%[0-9a-zA-Z]{1,}",  # fe80::7:8%eth0     fe80::7:8%1  (link-local IPv6 addresses with zone ID)
    r"::(?i:ffff(?::0{1,4}){0,1}:){0,1}[^\s:]"
    + IPV4ADDR,  # ::255.255.255.255  ::ffff:255.255.255.255  ::ffff:0:255.255.255.255 (IPv4-mapped IPv6 addresses and IPv4-translated addresses)
    r"(?:"
    + IPV6SEG
    + r":){1,6}:?[^\s:]"
    + IPV4ADDR,  # 2001:db8:3:4::192.0.2.33  64:ff9b::192.0.2.33 (IPv4-Embedded IPv6 Address)
)
IPV6ADDR = "|".join(["(?:{})".format(g) for g in IPV6GROUPS[::-1]])  # Reverse rows for greedy match
CIDR = r"(?:\/1[01][0-9]|12[0-8]|[0-9]{1,2})"
# pylint: enable = line-too-long

# command line
# ------------


@prj.group()
def iplists():
    """comandline for experimantal IP tools"""


@iplists.command("ip-filter")
@click.option("--ipv4-min-pref", type=int, show_default=True, default=32, help="minimum IPv4 prefix (max. subnet)")
@click.option("--ipv6-min-pref", type=int, show_default=True, default=48, help="minimum IPv6 prefix (max. subnet)")
@click.option(
    "--re-substring", type=str, default=None, help="regular expression to parse only a substring from incomming line"
)
@click.option("--ignore-zone-id", is_flag=True, default=True, help="ignore link-local IPv6 addresses with zone ID")
@click.option(
    "--merge", is_flag=True, default=True, help="merge IPs and subnets to smallest possible list of CIDR subnets"
)
@click.argument("streams", type=click.File("r"), nargs=-1)
@click.argument("output", type=click.File("w", lazy=True))
def _ip_filter(
    ipv4_min_pref,
    ipv6_min_pref,
    re_substring,
    ignore_zone_id,
    merge,
    streams,
    output,
):
    """Filter out IP adresses and subnets from streams (files)"""
    opts = IPListOptions(
        ipv4_min_pref=ipv4_min_pref,
        ipv6_min_pref=ipv6_min_pref,
        re_substring=re_substring,
        ignore_zone_id=ignore_zone_id,
    )

    def iter_items():
        for f in streams:
            for ip, cidr in filter_networks(opts, f):
                if cidr:
                    yield f"{ip}/{cidr}"
                else:
                    yield ip

    if merge:
        for ip in cidr_merge(iter_items()):
            output.write(f"{ip}\n")
    else:
        for ip in iter_items():
            output.write(f"{ip}\n")


# implementations
# ---------------


def filter_networks(opts: IPListOptions, stream: IO):
    """Parse IP adresses and subnets from ``stream``.

    :param opts: :py:obj:`IPListOptions` container with filter options
    :param stream: A stream with IP adresses in.  For example, a server log.
    """

    for line in stream:

        for ipvx, ipvx_min_pref in [(opts.ipv4, opts.ipv4_min_pref), (opts.ipv4, opts.ipv4_min_pref)]:
            ip_cidr_set = set()
            for ip_cidr in parse_networks(opts, line, ipvx, ipvx_min_pref):
                if opts.unique:
                    ip_cidr_set.add(ip_cidr)
                else:
                    yield ip_cidr
            if opts.unique:
                for ip_cidr in ip_cidr_set:
                    yield ip_cidr


def parse_networks(opts: IPListOptions, line: str, ip_re: re.Pattern, ip_min_pref: int):
    """Parse IP adresses and subnets from ``line``.

    :param opts: :py:obj:`IPListOptions` container with filter options
    :param line: A line with IP adresse(s) in.  For example, a line from the
      server log from which the IPs should be collected.
    :param ip_re: :py:obj:`IPV4ADDR` or :py:obj:`IPV6ADDR`
    :param ip_min_pref: minimal CIDR prefix
    """

    if opts.substring:
        match = opts.substring.match(line)
        if not match:
            return
        line = line[match.start() : match.end()]

    ip_cidr_set = set()
    for match in ip_re.finditer(line):
        ip, cidr = (line[match.start() : match.end()].split("/") + [""])[:2]
        if opts.ignore_zone_id and r"%" in ip:
            continue
        if cidr:
            cidr = int(cidr)
            if cidr < ip_min_pref:
                continue
        if opts.unique:
            ip_cidr_set.add((ip, cidr))
        else:
            yield ip, cidr

    if opts.unique:
        for ip_cidr in ip_cidr_set:
            yield ip_cidr


@dataclass
class IPListOptions:  # pylint:disable = too-many-instance-attributes
    """container with filter options that will be passed through IP list
    operations"""

    ipv4_min_pref: int = 32
    """The prefix defines the number of leading bits in an address that are
    compared to determine whether or not an address is part of a network.  This
    value is used, for example, to filter out IPs from the IP list whose CIDR
    suffix addresses a parent network.  For example, a /24 network is a subnet
    of a /23 network, and a single IPv4 address has a network mask of /32 bit
    length (a single IPv6 address is /128 bits long).

    In an IPv4 network, the client usually has only one IP address (aka class
    E), which has a /32 prefix. In IPv6 networks, providers often assign a /48
    or /56 subnet to their customers, from which a single client then has an
    IPv6 /128 address.
    """

    ipv6_min_pref: int = 128
    """see :py:obj:`ipv4_min_pref` (max. 128)"""

    # regular expressions

    re_ipv4: str = IPV4ADDR
    """Regular Expression that matches an IPv4 address"""

    re_ipv6: str = IPV6ADDR
    """Regular Expression that matches an IPv6 address"""

    re_cidr: str = r"(/\d{1,3})?"
    """Regular Expression that matches an CIDR suffix of an IP address."""

    re_substring: str = ""
    """Regular expression to parse IPs only from a substring of the incoming
    line.  If you have log files with lines like::

        YYYY-mm-dd HH:MM:SS foo 0.0.0.0 BLOCK 206.41.169.186/32 bar

    and dont want to parse the IP 0.0.0.0 you can define a regular expression
    like ``BLOCK.*$`` to parse the IP from the substring::

        BLOCK 206.41.169.186/32 bar

    Lines where the regular expression do not match will be ignored.
    """

    ignore_zone_id: bool = True
    """Ignore link-local IPv6 addresses with zone ID.  The purpose of zone IDs
    is to distinguish these addresses.  For instance, if host A has two NICs
    that are connected to two different links (subnets), the same local-link
    address could have been used for ``fe80::7:8%eth0`` and ``fe80::7:8%eth1``.
    """

    unique: bool = True
    """Filter out duplicates."""

    def __post_init__(self):
        self.substring = None
        if self.re_substring:
            self.substring = re.compile(self.re_substring)
        self.ipv4 = re.compile(self.re_ipv4 + self.re_cidr)
        self.ipv6 = re.compile(self.re_ipv6)
