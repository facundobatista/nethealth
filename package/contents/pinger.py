#!/usr/bin/env python3

"""Executes ping and return the latency in milliseconds, or 0 for timeout."""

import subprocess
import re


def ping(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return 0

    # Parsear: time=XX.XX ms
    output = result.stdout
    match = re.search(r'time=(\d+\.?\d*) ms', output)
    if not match:
        raise ValueError(f"Bad match: {output!r}")
    return int(round(float(match.group(1))))


def main(host, timeout):
    """Main entry point."""
    cmd = ["ping", "-c", "1", "-W", str(timeout), host]
    print(ping(cmd))


if __name__ == "__main__":
    # we may make this configurable when calling the script
    host = "1.1.1.1"
    timeout = 2  # seconds

    main(host, timeout)
