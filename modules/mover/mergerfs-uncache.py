#!/usr/bin/env python3
import argparse
import shutil
import subprocess
import os
import socket
import syslog
import time
import datetime
import urllib.request
from pathlib import Path
from typing import List
import asyncio
import aiofiles

if __name__ == "__main__":
    """
    Uncaching utility. This scripts assumes that you have a cache-like
    mount point, for which you want to preserve a certain amount of free
    space by moving heavy/rarely-accessed files to a slower mount point.

    The script, in its simplest form, can be run as:

    ::

        $ ./mergerfs-uncache.py -s /mnt/cache -d /mnt/slow -t 75

    In this way least accessed files will be moved one after the other
    until the percentage of used capacity will be less than the target.
    Other options are also available. Please consider this is a work in
    progress.
    """

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-s",
        "--source",
        dest="source",
        type=Path,
        help="Source path (i.e. cache pool root path.",
    )
    parser.add_argument(
        "-u",
        "--uid",
        dest="uid",
        default="",
        type=str,
        help="Username to assign ownership of the folders to",
    )
    parser.add_argument(
        "-g",
        "--gid",
        dest="gid",
        default="",
        type=str,
        help="Group name to assign ownership of the folders to",
    )
    parser.add_argument(
        "--atime",
        dest="atime",
        type=int,
        default=0,
        help="TODO: Only move files older than N days"
    )
    parser.add_argument(
        "-d",
        "--destination",
        dest="destination",
        type=Path,
        help="Destination path (i.e. slow pool root path.",
    )
    parser.add_argument(
        "--num-files",
        dest="num_files",
        default=-1,
        type=int,
        help="Maximum number of files moved away from cache.",
    )
    parser.add_argument(
        "--time-limit",
        dest="time_limit",
        default=-1,
        type=int,
        help="Time limit for the whole process (in seconds). Once reached program exits.",
    )
    parser.add_argument(
        "-t",
        "--target",
        dest="target",
        type=float,
        help="Desired max cache usage, in percentage (e.g. 70).",
    )
    parser.add_argument(
        "--exclude",
        dest="exclude",
        nargs="*",
        help="Optional list of absolute paths to be excluded from uncaching operations.",
        required=False,
        default=list(),
    )
    parser.add_argument(
        "--healthchecks-url",
        dest="hc_url",
        type=str,
        help="Optional URL of the HealthChecks job. If provided, both start and stop ping will be sent.",
        required=False,
        default="",
    )
    parser.add_argument(
        "-v", "--verbose", help="Increase output verbosity.", action="store_true"
    )
    args = parser.parse_args()

    # Some general checks
    cache_path: Path = args.source
    if not cache_path.is_dir():
        raise NotADirectoryError(f"{cache_path} is not a valid directory.")
    slow_path: Path = args.destination
    if not slow_path.is_dir():
        raise NotADirectoryError(f"{slow_path} is not a valid directory.")

    excluded_paths: List[str] = args.exclude

    last_id = args.num_files
    time_limit = args.time_limit

    target = float(args.target)
    if target <= 1 or target >= 100:
        raise ValueError(
            f"Target value is in percentage, i.e. in the range of (0, 100). Found {target} instead."
        )

    ###################
    # Start the process
    ###################
    uid = args.uid
    gid = args.gid
    def fix_permissions(uid, gid, cache_path, slow_path):
        if len(uid) > 0 and len(gid) > 0:
            syslog.syslog(
                    syslog.LOG_INFO, f"Fixing permissions on {cache_path}..."
                    )
            subprocess.run(["/run/wrappers/bin/sudo", "/run/current-system/sw/bin/chown", "-R", f"{uid}:{gid}", f"{cache_path}"])
            subprocess.run(["/run/wrappers/bin/sudo", "/run/current-system/sw/bin/chmod", "-R", "u=rwX,go=rX", f"{cache_path}"])
            syslog.syslog(
                    syslog.LOG_INFO, f"Fixing permissions on {slow_path}..."
                    )
            subprocess.run(["/run/wrappers/bin/sudo", "/run/current-system/sw/bin/chown", "-R", f"{uid}:{gid}", f"{slow_path}"])
            subprocess.run(["/run/wrappers/bin/sudo", "/run/current-system/sw/bin/chmod", "-R", "u=rwX,go=rX", f"{slow_path}"])

    fix_permissions(uid, gid, cache_path, slow_path)
    if args.hc_url != "":
        try:
            urllib.request.urlopen(args.hc_url + "/start", timeout=3)
        except socket.error as e:
            syslog.syslog(syslog.LOG_ERR, f"Failed to open {args.hc_url}.")

    cache_stats = shutil.disk_usage(cache_path)

    usage_percentage = 100 * cache_stats.used / cache_stats.total
    syslog.syslog(
        syslog.LOG_INFO,
        f"Uncaching from {cache_path} ({usage_percentage:.2f}% used) to {slow_path}.",
    )
    syslog.syslog(syslog.LOG_INFO, "Computing candidates...")
    candidates = sorted(
        [(c, c.stat()) for c in cache_path.glob("**/*") if c.is_file()],
        key=lambda p: p[1].st_atime,
    )

    if usage_percentage <= target:
        syslog.syslog(
            syslog.LOG_INFO,
            f"Target of {target}% of used capacity already reached. Exiting.",
        )
        if args.hc_url != "":
            try:
                urllib.request.urlopen(args.hc_url, timeout=3)
            except socket.error as e:
                syslog.syslog(syslog.LOG_ERR, f"Failed to open {args.hc_url}.")
        exit(0)

    semaphore = asyncio.Semaphore(1000)

    async def move_file(c_path, cache_path, slow_path):
        async with semaphore:
            try:
                async with aiofiles.open(c_path, 'rb'):
                    src = Path(cache_path) / Path(c_path.relative_to(cache_path))
                    dest = Path(slow_path) / Path(c_path.relative_to(cache_path))
                    
                    os.chmod(os.path.dirname(src), mode=0o775)
                    os.makedirs(os.path.dirname(dest), exist_ok=True, mode=0o775)


                    syslog.syslog(syslog.LOG_DEBUG, f"Moving from {src} to {dest}")
                    if os.path.exists(c_path):
                        shutil.move(src, dest)
                        return os.path.getsize(c_path)
                    else:
                        syslog.syslog(syslog.LOG_WARNING, f"{c_path} does not exist when trying to move.")
                        return 0
            except Exception as e:
                syslog.syslog(syslog.LOG_WARNING, f"Failed to move {c_path}: {e}")
                return 0

    async def process_files(candidates, excluded_paths, cache_path, slow_path, target, last_id, time_limit):
        cache_used = sum(c_stat.st_size for _, c_stat in candidates)
        cache_stats = shutil.disk_usage(cache_path)
        t_start = time.monotonic()

        tasks = []
        for c_id, (c_path, c_stat) in enumerate(candidates):
            if any(excluded_path in str(c_path) for excluded_path in excluded_paths):
                syslog.syslog(syslog.LOG_DEBUG, f"Skipping {c_path} since it is excluded.")
                continue

            if not os.path.exists(c_path):
                syslog.syslog(syslog.LOG_WARNING, f"{c_path} does not exist.")
                continue

            tasks.append(move_file(c_path, cache_path, slow_path))

            cache_used -= c_stat.st_size

            # Evaluate early breaking conditions
            if last_id >= 0 and c_id >= last_id - 1:
                syslog.syslog(syslog.LOG_INFO, f"Maximum number of moved files reached ({last_id}).")
                break
            if time_limit >= 0 and time.monotonic() - t_start > time_limit:
                syslog.syslog(syslog.LOG_INFO, f"Time limit reached ({time_limit} seconds).")
                break
            if (100 * cache_used / cache_stats.total) <= target:
                syslog.syslog(syslog.LOG_INFO, f"Target of maximum used capacity reached ({target}).")
                break


        await asyncio.gather(*tasks)
        syslog.syslog(
                syslog.LOG_INFO,
                f"Process completed in {round(time.monotonic() - t_start)} seconds. Current usage percentage is {usage_percentage:.2f}%.",
            )



    syslog.syslog(syslog.LOG_INFO, f"Starting to move files")
    asyncio.run(process_files(candidates, excluded_paths, cache_path, slow_path, target, last_id, time_limit))

    fix_permissions(uid, gid, cache_path, slow_path)
    if args.hc_url != "":
        try:
            urllib.request.urlopen(args.hc_url, timeout=3)
        except socket.error as e:
            syslog.syslog(syslog.LOG_ERR, f"Failed to open {args.hc_url}.")

