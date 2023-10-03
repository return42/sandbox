# SPDX-License-Identifier: AGPL-3.0-or-later
"""Print words from ``words.dat``"""

import socket
import ipaddress
import pydnsbl
from pydnsbl.providers import (
    DNSBL_CATEGORY_UNKNOWN,
    DNSBL_CATEGORY_SPAM,
    DNSBL_CATEGORY_EXPLOITS,
    # DNSBL_CATEGORY_PHISH,
    # DNSBL_CATEGORY_MALWARE,
    # DNSBL_CATEGORY_CNC,
    # DNSBL_CATEGORY_ABUSED,
    # DNSBL_CATEGORY_LEGIT,
)
import click

from ._cli import prj


@prj.group()
def dnsbl():
    """dnsbl lists checker based on asyncio/aiodns

    - https://github.com/dmippolitov/pydnsbl/

    """


@dnsbl.command("py")
@click.argument("streams", type=click.File("r"), nargs=-1)
def _py(streams):
    """check IPs from a stream (pydnsbl)"""

    ip_checker = pydnsbl.DNSBLIpChecker()

    for f in streams:
        for ip in f.readlines():
            ip = ip.strip()
            chk = ip_checker.check(ip)
            _echo_check_result(chk)


@dnsbl.command("socket")
@click.argument("streams", type=click.File("r"), nargs=-1)
def _socket(streams):
    """check IPs from a stream (socket.gethostbyname)"""

    dns_zone = "zen.spamhaus.org"
    dnsbl_setup = DNSBL_ZONES[dns_zone]

    for f in streams:
        for ip in f.readlines():
            ip = ip.strip()
            try:
                ret_code = socket.gethostbyname(dnsxl_hostname(ip.strip(), dns_zone))
                result = dnsbl_setup["result"].get(ret_code, "dnsbl error")
            except socket.gaierror as exc:
                if exc.args[0] == socket.EAI_NONAME:
                    result = "not listed"
                    ret_code = socket.EAI_NONAME
                else:
                    raise
            click.echo(f"{ip} --> {result} ({ret_code})")


@dnsbl.command("domain")
@click.argument("domain")
def _domain(domain):
    """check domain

    usage::

      $ dnsbl domain google.com
      $ dnsbl domain belonging708-info.xyz
    """

    ip_checker = pydnsbl.DNSBLDomainChecker()
    chk = ip_checker.check(domain)
    _echo_check_result(chk)


def _echo_check_result(chk):
    click.echo(f"blacklisted: {chk.blacklisted}")
    click.echo(f"addr: {chk.addr}")

    click.echo("detected by provider:")
    for k, v in chk.detected_by.items():
        click.echo(f'  {k:<25} | {", ".join(v)}')

    click.echo("failed providers:")
    for v in [p.host for p in chk.failed_providers] or ["none"]:
        click.echo(f"  {v}")

    # click.echo('all providers:')
    # for v in [p.host for p in chk.providers] or ['none']:
    #     click.echo(f'  {v}')


SPAMHAUS_RET_CODES = {
    # https://www.spamhaus.org/faq/section/DNSBL%20Usage#200
    "127.0.0.2": DNSBL_CATEGORY_SPAM,
    "127.0.0.3": DNSBL_CATEGORY_SPAM,
    "127.0.0.4": DNSBL_CATEGORY_EXPLOITS,
    "127.0.0.5": DNSBL_CATEGORY_EXPLOITS,
    "127.0.0.6": DNSBL_CATEGORY_EXPLOITS,
    "127.0.0.7": DNSBL_CATEGORY_EXPLOITS,
    "127.0.0.9": DNSBL_CATEGORY_SPAM,
    "127.0.0.10": DNSBL_CATEGORY_UNKNOWN,
    "127.0.0.11": DNSBL_CATEGORY_UNKNOWN,
}

DNSBL_ZONES = {
    "zen.spamhaus.org": {
        "result": SPAMHAUS_RET_CODES,
    },
    "sbl.spamhaus.org": {
        "result": SPAMHAUS_RET_CODES,
    },
    "xbl.spamhaus.org": {
        "result": SPAMHAUS_RET_CODES,
    },
    "sbl-xbl.spamhaus.org": {
        "result": SPAMHAUS_RET_CODES,
    },
    "pbl.spamhaus.org": {
        "result": SPAMHAUS_RET_CODES,
    },
    # 'dbl.spamhaus.org' # is a domain block list
}


def dnsxl_hostname(ip: str, dns_zone: str):
    """Generates a *hostname* for the IP that can be used in a DNSxL query
    (:rfc:`5782`).

    - `IP Address DNSxL`_
    - `IPv6 DNSxLs`_

    :param ip_str: IP to query in DNSxL
    :param dns_zone: domain zone the DNSxL

    .. _IP Address DNSxL: https://datatracker.ietf.org/doc/html/rfc5782#section-2.1
    .. _IPv6 DNSxLs: https://datatracker.ietf.org/doc/html/rfc5782#section-2.4

    """

    _ip = ipaddress.ip_address(ip)

    if _ip.version == 4:
        dns_name = ".".join(reversed(ip.split(".")))
    elif _ip.version == 6:
        dns_name = ".".join(reversed(list(_ip.exploded.replace(":", ""))))
    else:
        raise ValueError("unknown ip version")

    return f"{dns_name}.{dns_zone}"
