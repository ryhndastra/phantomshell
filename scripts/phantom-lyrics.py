#!/usr/bin/env python3
# layanan sinkronisasi lirik musik via playerctl dan lrclib

import hashlib
import json
import os
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request

CACHE_DIR = "/tmp/phantomshell-lyrics-cache"
os.makedirs(CACHE_DIR, exist_ok=True)

TIME_TAG_RE = re.compile(r"\[(\d+):(\d+(?:\.\d+)?)\]")

ALLOWED_PLAYER_PREFIXES = (
    "spotify",
    "spotifyd",
    "ncspot",
    "cider",
    "apple",
    "musikcube",
    "rhythmbox",
    "amberol",
    "audacious",
    "elisa",
    "tauon",
    "feishin",
    "harmonoid",
    "g4music",
    "lollypop",
)

ram_cache = {}
last_emitted_json = None


def emit(payload: dict):
    global last_emitted_json
    raw = json.dumps(payload, ensure_ascii=False)
    if raw != last_emitted_json:
        last_emitted_json = raw
        sys.stdout.write(raw + "\n")
        sys.stdout.flush()


def emit_empty():
    emit({
        "playing": False,
        "player": "",
        "artist": "",
        "title": "",
        "past2": "",
        "past1": "",
        "now": "",
        "next1": "",
        "next2": "",
    })


def clean_track_text(s: str) -> str:
    if not s:
        return ""
    s = re.sub(
        r"\s*\((?:feat\.?|ft\.?|with|prod\.?|official|video|audio|lyrics?|remaster(?:ed)?|live).*?\)",
        "",
        s,
        flags=re.IGNORECASE,
    )
    s = re.sub(
        r"\s*\[(?:feat\.?|ft\.?|official|video|audio|lyrics?|remaster(?:ed)?).*?\]",
        "",
        s,
        flags=re.IGNORECASE,
    )
    s = re.sub(
        r"\s*-\s*(?:remaster(?:ed)?|single|version|edit|mono|stereo).*$",
        "",
        s,
        flags=re.IGNORECASE,
    )
    return s.strip()


def parse_lrc(lrc_text: str):
    lines = []
    if not lrc_text:
        return lines
    for raw_line in lrc_text.splitlines():
        matches = list(TIME_TAG_RE.finditer(raw_line))
        if not matches:
            continue
        text = TIME_TAG_RE.sub("", raw_line).strip()
        if not text:
            text = "♪"
        for m in matches:
            mins = int(m.group(1))
            secs = float(m.group(2))
            lines.append((mins * 60.0 + secs, text))
    lines.sort(key=lambda x: x[0])
    return lines


def fetch_lrc(artist: str, title: str):
    key_str = f"{artist.lower().strip()}||{title.lower().strip()}"
    if key_str in ram_cache:
        return ram_cache[key_str]

    key_hash = hashlib.md5(key_str.encode("utf-8")).hexdigest()
    cache_file = os.path.join(CACHE_DIR, f"{key_hash}.json")
    if os.path.exists(cache_file):
        try:
            with open(cache_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                parsed = [(float(item[0]), str(item[1])) for item in data]
                ram_cache[key_str] = parsed
                return parsed
        except Exception:
            pass

    c_artist = clean_track_text(artist)
    c_title = clean_track_text(title)
    parsed = []

    # pencarian kecocokan langsung di lrclib
    try:
        get_params = urllib.parse.urlencode({"artist_name": c_artist, "track_name": c_title})
        get_url = f"https://lrclib.net/api/get?{get_params}"
        req = urllib.request.Request(
            get_url,
            headers={"User-Agent": "PhantomShell/1.0 (https://github.com/phantomshell)"},
        )
        with urllib.request.urlopen(req, timeout=3.5) as resp:
            item = json.loads(resp.read().decode("utf-8", errors="ignore"))
            if isinstance(item, dict) and item.get("syncedLyrics"):
                parsed = parse_lrc(item["syncedLyrics"])
    except Exception:
        pass

    # fallback pencarian lirik di lrclib
    if not parsed:
        try:
            query = urllib.parse.urlencode({"q": f"{c_artist} {c_title}".strip()})
            url = f"https://lrclib.net/api/search?{query}"
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "PhantomShell/1.0 (https://github.com/phantomshell)"},
            )
            with urllib.request.urlopen(req, timeout=3.5) as resp:
                results = json.loads(resp.read().decode("utf-8", errors="ignore"))
                if isinstance(results, list):
                    for item in results:
                        synced = item.get("syncedLyrics")
                        if synced:
                            parsed = parse_lrc(synced)
                            if parsed:
                                break
                    if not parsed:
                        for item in results:
                            plain = item.get("plainLyrics")
                            if plain:
                                raw_lines = [ln.strip() for ln in plain.splitlines() if ln.strip()]
                                parsed = [(i * 4.0, ln) for i, ln in enumerate(raw_lines)]
                                break
        except Exception:
            pass

    ram_cache[key_str] = parsed
    try:
        with open(cache_file, "w", encoding="utf-8") as f:
            json.dump(parsed, f, ensure_ascii=False)
    except Exception:
        pass
    return parsed


def find_music_player():
    try:
        res = subprocess.run(
            ["playerctl", "-l"],
            capture_output=True,
            text=True,
            timeout=0.6,
        )
        if res.returncode != 0 or not res.stdout.strip():
            return None
        players = [p.strip() for p in res.stdout.splitlines() if p.strip()]
        # filter khusus aplikasi pemutar musik
        allowed = [
            p for p in players
            if any(p.lower().startswith(prefix) for prefix in ALLOWED_PLAYER_PREFIXES)
        ]
        if not allowed:
            return None

        # ambil pemutar musik yang sedang aktif memutar lagu
        for p in allowed:
            st = subprocess.run(
                ["playerctl", "-p", p, "status"],
                capture_output=True,
                text=True,
                timeout=0.5,
            )
            if st.returncode == 0 and st.stdout.strip().lower() == "playing":
                return (p, True)

        return None
    except Exception:
        return None


def poll_music_player():
    found = find_music_player()
    if not found:
        return None
    player_name, is_playing = found
    try:
        meta_res = subprocess.run(
            [
                "playerctl",
                "-p",
                player_name,
                "metadata",
                "--format",
                "{{xesam:artist}}\t{{xesam:title}}",
            ],
            capture_output=True,
            text=True,
            timeout=0.6,
        )
        if meta_res.returncode != 0 or not meta_res.stdout.strip():
            return None
        parts = meta_res.stdout.splitlines()[0].split("\t")
        artist = parts[0].strip() if len(parts) > 0 else ""
        title = parts[1].strip() if len(parts) > 1 else ""
        if not title:
            return None

        pos_res = subprocess.run(
            ["playerctl", "-p", player_name, "position"],
            capture_output=True,
            text=True,
            timeout=0.5,
        )
        try:
            pos_sec = float(pos_res.stdout.strip()) if pos_res.returncode == 0 else 0.0
        except ValueError:
            pos_sec = 0.0

        return {
            "playing": is_playing,
            "player": player_name,
            "artist": artist,
            "title": title,
            "position": pos_sec,
        }
    except Exception:
        return None


def main():
    emit_empty()

    last_poll_t = 0.0
    cached_meta = None
    base_pos_sec = 0.0
    base_mono_t = 0.0
    current_lrc = []
    current_track_id = ""

    while True:
        now_t = time.monotonic()
        poll_interval = 0.9 if (cached_meta and cached_meta.get("playing")) else 1.8

        if now_t - last_poll_t >= poll_interval:
            last_poll_t = now_t
            meta = poll_music_player()
            cached_meta = meta
            if meta and meta["title"]:
                base_pos_sec = meta["position"]
                base_mono_t = now_t
                track_id = f"{meta['artist']}||{meta['title']}"
                if track_id != current_track_id:
                    current_track_id = track_id
                    current_lrc = fetch_lrc(meta["artist"], meta["title"])
            else:
                current_track_id = ""
                current_lrc = []

        # kirim data kosong jika tidak ada pemutar musik aktif
        if not cached_meta or not cached_meta.get("title"):
            emit_empty()
            time.sleep(1.8)
            continue

        if cached_meta["playing"]:
            est_pos = base_pos_sec + (time.monotonic() - base_mono_t)
        else:
            est_pos = base_pos_sec

        # kirim status tanpa lirik jika lagu tidak memiliki data lirik
        if not current_lrc:
            emit({
                "playing": cached_meta["playing"],
                "player": cached_meta["player"],
                "artist": cached_meta["artist"],
                "title": cached_meta["title"],
                "past2": "",
                "past1": "",
                "now": "No Lyrics",
                "next1": "",
                "next2": "",
            })
            time.sleep(1.0)
            continue

        # penentuan indeks baris lirik aktif berdasarkan posisi waktu
        idx = 0
        lookup_pos = est_pos + 0.15
        for i, (ts, _) in enumerate(current_lrc):
            if lookup_pos >= ts:
                idx = i
            else:
                break

        past2 = current_lrc[idx - 2][1] if idx >= 2 else ""
        past1 = current_lrc[idx - 1][1] if idx >= 1 else ""
        now_line = current_lrc[idx][1]
        next1 = current_lrc[idx + 1][1] if (idx + 1) < len(current_lrc) else ""
        next2 = current_lrc[idx + 2][1] if (idx + 2) < len(current_lrc) else ""

        emit({
            "playing": cached_meta["playing"],
            "player": cached_meta["player"],
            "artist": cached_meta["artist"],
            "title": cached_meta["title"],
            "past2": past2,
            "past1": past1,
            "now": now_line,
            "next1": next1,
            "next2": next2,
        })

        time.sleep(0.22 if cached_meta["playing"] else 1.2)


if __name__ == "__main__":
    main()
