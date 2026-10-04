#!/usr/bin/env python3
import os
import sys
import struct
import shutil
import zipfile

ZIP_PATH = "/home/sho/Downloads/persona-5-animated.zip"
OUT_DIRS = [
    "/mnt/data/Projects/rice/phantomshell/dots/icons/Persona5-Animated",
    os.path.expanduser("~/.local/share/icons/Persona5-Animated"),
    os.path.expanduser("~/.icons/Persona5-Animated"),
]

# pemetaan file ani ke nama kursor standar x11 dan wayland
CURSOR_MAP = {
    "NORMAL.ani": [
        "default", "left_ptr", "arrow", "top_left_arrow", "right_ptr", "context-menu"
    ],
    "LINK SELECT.ani": [
        "pointer", "hand2", "hand1", "pointing_hand", "openhand", "grab"
    ],
    "BUSY.ani": [
        "wait", "watch", "clock"
    ],
    "WIB.ani": [
        "progress", "left_ptr_watch", "half-busy"
    ],
    "TEXT SELECT.ani": [
        "text", "xterm", "ibeam", "vertical-text"
    ],
    "UNAVABIBLE.ani": [
        "not-allowed", "no-drop", "crossed_circle", "forbidden", "pirate", "dnd-no-drop"
    ],
    "HELP.ani": [
        "help", "question_arrow", "whats_this"
    ],
    "MOVE.ani": [
        "move", "fleur", "all-scroll", "closedhand", "grabbing", "dnd-move", "dnd-none"
    ],
    "PRECISION.ani": [
        "crosshair", "cross", "tcross", "cell", "plus"
    ],
    "HANDWRITING.ani": [
        "pencil", "draft"
    ],
    "ALTERNATE SELECT.ani": [
        "up_arrow", "center_ptr", "alias", "link", "dnd-link", "copy", "dnd-copy"
    ],
    "V RESIZE.ani": [
        "sb_v_double_arrow", "size_ver", "v_double_arrow", "n-resize", "s-resize",
        "ns-resize", "row-resize", "top_side", "bottom_side", "split_v"
    ],
    "H RESIZE.ani": [
        "sb_h_double_arrow", "size_hor", "h_double_arrow", "e-resize", "w-resize",
        "ew-resize", "col-resize", "left_side", "right_side", "split_h"
    ],
    "RESIZE 1.ani": [
        "size_bdiag", "fd_double_arrow", "ne-resize", "sw-resize", "nesw-resize",
        "top_right_corner", "bottom_left_corner"
    ],
    "RESIZE 2.ani": [
        "size_fdiag", "bd_double_arrow", "nw-resize", "se-resize", "nwse-resize",
        "top_left_corner", "bottom_right_corner"
    ],
}


# pembacaan biner riff acon menjadi daftar frame kursor
def parse_ani(data: bytes):
    pos = 12
    default_rate = 3
    rates = []
    seqs = []
    raw_icons = []

    while pos + 8 <= len(data):
        cid = data[pos:pos + 4]
        csz = struct.unpack("<I", data[pos + 4:pos + 8])[0]
        if cid in (b"RIFF", b"LIST"):
            pos += 12
            continue
        payload = data[pos + 8:pos + 8 + csz]
        if cid == b"anih" and len(payload) >= 36:
            vals = struct.unpack("<9I", payload[:36])
            default_rate = vals[7] or 3
        elif cid == b"rate":
            cnt = len(payload) // 4
            rates = list(struct.unpack(f"<{cnt}I", payload[:cnt * 4]))
        elif cid == b"seq ":
            cnt = len(payload) // 4
            seqs = list(struct.unpack(f"<{cnt}I", payload[:cnt * 4]))
        elif cid == b"icon":
            raw_icons.append(payload)
        pos += 8 + csz + (csz % 2)

    decoded_icons = []
    for ic in raw_icons:
        w, h, _cc, _r2, hx, hy, _bsz, boff = struct.unpack("<BBBBHHII", ic[6:22])
        w = w or 128
        h = h or 128
        px_bottom_up = ic[boff + 40:boff + 40 + w * h * 4]
        # konversi piksel bottom-up bgra ke top-down premultiplied bgra
        out = bytearray(w * h * 4)
        stride = w * 4
        for y in range(h):
            src_off = (h - 1 - y) * stride
            dst_off = y * stride
            row = px_bottom_up[src_off:src_off + stride]
            for x in range(0, stride, 4):
                b = row[x]
                g = row[x + 1]
                r = row[x + 2]
                a = row[x + 3]
                if a == 0:
                    out[dst_off + x:dst_off + x + 4] = b"\x00\x00\x00\x00"
                elif a == 255:
                    out[dst_off + x] = b
                    out[dst_off + x + 1] = g
                    out[dst_off + x + 2] = r
                    out[dst_off + x + 3] = 255
                else:
                    out[dst_off + x] = (b * a + 127) // 255
                    out[dst_off + x + 1] = (g * a + 127) // 255
                    out[dst_off + x + 2] = (r * a + 127) // 255
                    out[dst_off + x + 3] = a
        decoded_icons.append((w, h, hx, hy, bytes(out)))

    order = seqs if seqs else list(range(len(decoded_icons)))
    frames = []
    for i, idx in enumerate(order):
        if idx >= len(decoded_icons):
            continue
        jiffies = rates[i] if i < len(rates) else default_rate
        delay_ms = max(20, int(round(jiffies * 1000.0 / 60.0)))
        w, h, hx, hy, px = decoded_icons[idx]
        frames.append((w, h, hx, hy, delay_ms, px))
    return frames


# pengecilan ukuran buffer piksel bgra
def downsample_bgra(src: bytes, sw: int, sh: int, dw: int, dh: int) -> bytes:
    if sw == dw and sh == dh:
        return src
    out = bytearray(dw * dh * 4)
    for dy in range(dh):
        y0 = (dy * sh) // dh
        y1 = max(y0 + 1, ((dy + 1) * sh) // dh)
        for dx in range(dw):
            x0 = (dx * sw) // dw
            x1 = max(x0 + 1, ((dx + 1) * sw) // dw)
            sb = sg = sr = sa = cnt = 0
            for sy in range(y0, y1):
                base = (sy * sw + x0) * 4
                for _ in range(x0, x1):
                    sb += src[base]
                    sg += src[base + 1]
                    sr += src[base + 2]
                    sa += src[base + 3]
                    cnt += 1
                    base += 4
            dst = (dy * dw + dx) * 4
            out[dst] = sb // cnt
            out[dst + 1] = sg // cnt
            out[dst + 2] = sr // cnt
            out[dst + 3] = sa // cnt
    return bytes(out)


# pembuatan biner xcursor multi-ukuran dari daftar frame
def build_xcursor(frames) -> bytes:
    # variasi ukuran nominal dan dimensi piksel
    size_variants = [
        (16, 22),
        (24, 28),
        (32, 34),
    ]

    # cache buffer piksel yang sudah diperkecil
    scaled_cache = {}
    chunks = []

    for nom_sz, px_dim in size_variants:
        for (sw, sh, hx, hy, delay_ms, src_px) in frames:
            key = (id(src_px), px_dim)
            if key not in scaled_cache:
                scaled_cache[key] = downsample_bgra(src_px, sw, sh, px_dim, px_dim)
            scaled_px = scaled_cache[key]
            nhx = max(0, min(px_dim - 1, int(round(hx * px_dim / sw))))
            nhy = max(0, min(px_dim - 1, int(round(hy * px_dim / sh))))
            # header chunk gambar xcursor
            img_hdr = struct.pack(
                "<9I",
                36,
                0xFFFD0002,
                nom_sz,
                1,
                px_dim,
                px_dim,
                nhx,
                nhy,
                delay_ms,
            )
            chunks.append((nom_sz, img_hdr + scaled_px))

    ntoc = len(chunks)
    header_size = 16
    toc_offset = header_size + ntoc * 12
    file_hdr = struct.pack("<4sIII", b"Xcur", header_size, 0x00010000, ntoc)

    toc_entries = bytearray()
    body = bytearray()
    cur_pos = toc_offset
    for nom_sz, ch_bytes in chunks:
        toc_entries += struct.pack("<III", 0xFFFD0002, nom_sz, cur_pos)
        body += ch_bytes
        cur_pos += len(ch_bytes)

    return bytes(file_hdr + toc_entries + body)


def main():
    if not os.path.exists(ZIP_PATH):
        print(f"Error: {ZIP_PATH} not found", file=sys.stderr)
        sys.exit(1)

    primary_dir = OUT_DIRS[0]
    cursors_dir = os.path.join(primary_dir, "cursors")
    os.makedirs(cursors_dir, exist_ok=True)

    with open(os.path.join(primary_dir, "index.theme"), "w", encoding="utf-8") as f:
        f.write(
            "[Icon Theme]\n"
            "Name=Persona5-Animated\n"
            "Comment=Persona 5 Animated Cursor Set for PhantomShell\n"
            "Inherits=Adwaita\n"
        )

    with zipfile.ZipFile(ZIP_PATH, "r") as z:
        for ani_name, aliases in CURSOR_MAP.items():
            raw = z.read(ani_name)
            frames = parse_ani(raw)
            xcur_bytes = build_xcursor(frames)
            main_name = aliases[0]
            main_path = os.path.join(cursors_dir, main_name)
            if os.path.lexists(main_path):
                os.unlink(main_path)
            with open(main_path, "wb") as cf:
                cf.write(xcur_bytes)
            for alias in aliases[1:]:
                alias_path = os.path.join(cursors_dir, alias)
                if os.path.lexists(alias_path):
                    os.unlink(alias_path)
                os.symlink(main_name, alias_path)
            print(f"Built {ani_name:20s} -> {main_name} (+{len(aliases)-1} symlinks, {len(frames)} frames)")

    # penyalinan tema kursor ke direktori ikon pengguna
    for dest in OUT_DIRS[1:]:
        if os.path.exists(dest):
            shutil.rmtree(dest)
        shutil.copytree(primary_dir, dest, symlinks=True)
        print(f"Installed cursor theme to: {dest}")

    # konfigurasi tema kursor cadangan bawaan
    for def_base in [os.path.expanduser("~/.icons/default"), os.path.expanduser("~/.local/share/icons/default")]:
        try:
            os.makedirs(def_base, exist_ok=True)
            idx_file = os.path.join(def_base, "index.theme")
            if os.path.islink(idx_file):
                os.unlink(idx_file)
            with open(idx_file, "w", encoding="utf-8") as df:
                df.write("[Icon Theme]\nName=Default\nComment=Default Cursor Theme\nInherits=Persona5-Animated\n")
        except OSError:
            pass


if __name__ == "__main__":
    main()
