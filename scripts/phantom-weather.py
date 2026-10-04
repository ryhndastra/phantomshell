#!/usr/bin/env python3
# layanan pengambilan data cuaca lokal dengan cache sementara

import json
import os
import sys
import time
import urllib.parse
import urllib.request

CACHE_FILE = "/tmp/phantomshell-weather.json"
CACHE_TTL = 900


def map_wmo_code(code: int, is_day: int = 1):
    # pemetaan kode cuaca wmo ke ikon dan label
    if code == 0:
        return ("clear-day" if is_day else "clear-night", "CLEAR")
    if code in (1, 2):
        return ("partly-cloudy-day" if is_day else "partly-cloudy-night", "CLOUDY")
    if code == 3:
        return ("cloudy", "OVERCAST")
    if code in (45, 48):
        return ("fog", "FOG")
    if code in (51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82):
        return ("rain", "RAIN")
    if code in (71, 73, 75, 77, 85, 86):
        return ("snow", "SNOW")
    if code in (95, 96, 99):
        return ("thunder", "STORM")
    return ("cloudy", "CLOUDY")


def get_location():
    # baca lokasi dari cache jika tersedia
    loc_cache = "/tmp/phantomshell-location.json"
    if os.path.exists(loc_cache):
        try:
            with open(loc_cache, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass

    for url in ("http://ip-api.com/json/?fields=status,city,lat,lon", "https://ipapi.co/json/"):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "PhantomShell/1.0"})
            with urllib.request.urlopen(req, timeout=3.5) as resp:
                data = json.loads(resp.read().decode("utf-8", errors="ignore"))
                lat = data.get("lat") or data.get("latitude")
                lon = data.get("lon") or data.get("longitude")
                city = data.get("city") or "TOKYO"
                if lat is not None and lon is not None:
                    loc = {"lat": float(lat), "lon": float(lon), "city": str(city)}
                    with open(loc_cache, "w", encoding="utf-8") as f:
                        json.dump(loc, f)
                    return loc
        except Exception:
            pass

    # koordinat cadangan jakarta
    return {"lat": -6.2088, "lon": 106.8456, "city": "JAKARTA"}


def fetch_weather():
    if os.path.exists(CACHE_FILE):
        try:
            if time.time() - os.path.getmtime(CACHE_FILE) < CACHE_TTL:
                with open(CACHE_FILE, "r", encoding="utf-8") as f:
                    return json.load(f)
        except Exception:
            pass

    loc = get_location()
    lat, lon, city = loc["lat"], loc["lon"], loc["city"]

    owm_key = os.environ.get("OPENWEATHER_API_KEY", "").strip()
    if owm_key:
        try:
            url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&units=metric&appid={owm_key}"
            req = urllib.request.Request(url, headers={"User-Agent": "PhantomShell/1.0"})
            with urllib.request.urlopen(req, timeout=4.0) as resp:
                d = json.loads(resp.read().decode("utf-8", errors="ignore"))
                temp = int(round(d["main"]["temp"]))
                hum = int(round(d["main"]["humidity"]))
                wid = int(d["weather"][0]["id"])
                if wid < 300:
                    icon, label = "thunder", "STORM"
                elif wid < 600:
                    icon, label = "rain", "RAIN"
                elif wid < 700:
                    icon, label = "snow", "SNOW"
                elif wid == 800:
                    icon, label = "clear-day", "CLEAR"
                else:
                    icon, label = "cloudy", "CLOUDY"
                out = {
                    "temp": f"{temp}°C",
                    "humidity": f"{hum}%",
                    "precip": f"{hum}%",
                    "icon": icon,
                    "label": label,
                    "city": city.upper(),
                    "provider": "OpenWeather",
                }
                with open(CACHE_FILE, "w", encoding="utf-8") as f:
                    json.dump(out, f)
                return out
        except Exception:
            pass

    # pengambilan data cuaca dari open-meteo
    try:
        params = urllib.parse.urlencode({
            "latitude": lat,
            "longitude": lon,
            "current": "temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,is_day",
            "timezone": "auto",
        })
        url = f"https://api.open-meteo.com/v1/forecast?{params}"
        req = urllib.request.Request(url, headers={"User-Agent": "PhantomShell/1.0"})
        with urllib.request.urlopen(req, timeout=4.0) as resp:
            d = json.loads(resp.read().decode("utf-8", errors="ignore"))
            cur = d.get("current", {})
            temp = int(round(cur.get("temperature_2m", 28)))
            hum = int(round(cur.get("relative_humidity_2m", 55)))
            precip = cur.get("precipitation_probability")
            badge_pct = int(round(precip if precip is not None else hum))
            wcode = int(cur.get("weather_code", 2))
            is_day = int(cur.get("is_day", 1))
            icon, label = map_wmo_code(wcode, is_day)
            out = {
                "temp": f"{temp}°C",
                "humidity": f"{hum}%",
                "precip": f"{badge_pct}%",
                "icon": icon,
                "label": label,
                "city": city.upper(),
                "provider": "Open-Meteo",
            }
            with open(CACHE_FILE, "w", encoding="utf-8") as f:
                json.dump(out, f)
            return out
    except Exception:
        pass

    return {
        "temp": "27°C",
        "humidity": "55%",
        "precip": "55%",
        "icon": "cloudy",
        "label": "CLOUDY",
        "city": city.upper(),
        "provider": "Offline",
    }


if __name__ == "__main__":
    data = fetch_weather()
    sys.stdout.write(json.dumps(data, ensure_ascii=False) + "\n")
    sys.stdout.flush()
