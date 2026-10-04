#!/usr/bin/env python3
# generator wallpaper dan logo bar bawaan untuk setiap preset tema
import os
import subprocess

ASSETS_DIR = "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets"
SRC_WALLPAPER = os.path.join(ASSETS_DIR, "pshell-wallpaper.png")
SRC_LOGO = os.path.join(ASSETS_DIR, "pshell.png")

# daftar id tema dan warna rgb utama
THEMES = [
    ("p3-reload",     (0x00, 0xB4, 0xD8)),
    ("p4-golden",     (0xFF, 0xB7, 0x03)),
    ("kasumi-violet", (0xB8, 0x29, 0xFF)),
    ("akechi-crow",   (0xD4, 0xAF, 0x37)),
    ("futaba-matrix", (0x39, 0xFF, 0x14)),
    ("monochrome",    (0xE2, 0xE2, 0xEC)),
    ("expressive",    (0x7B, 0x61, 0xFF)),
    ("tonal-spot",    (0x8A, 0xB4, 0xF8)),
]


def main():
    for theme_id, (r, g, b) in THEMES:
        tr = r / 255.0
        tg = g / 255.0
        tb = b / 255.0
        ccm = (
            f"colorchannelmixer="
            f"rr={tr:.4f}:rg={1.0 - tr:.4f}:rb=0:ra=0:"
            f"gr={tg:.4f}:gg={1.0 - tg:.4f}:gb=0:ga=0:"
            f"br={tb:.4f}:bg={-tb:.4f}:bb=1.0:ba=0:"
            f"ar=0:ag=0:ab=0:aa=1.0"
        )
        out_wp = os.path.join(ASSETS_DIR, f"pshell-wallpaper-{theme_id}.png")
        subprocess.run(
            ["ffmpeg", "-y", "-v", "error", "-i", SRC_WALLPAPER, "-vf", ccm, out_wp],
            check=True,
        )
        out_logo = os.path.join(ASSETS_DIR, f"pshell-{theme_id}.png")
        subprocess.run(
            ["ffmpeg", "-y", "-v", "error", "-i", SRC_LOGO, "-vf", f"format=rgba,{ccm}", out_logo],
            check=True,
        )
        print(f"Generated {out_wp} & {out_logo}")


if __name__ == "__main__":
    main()
