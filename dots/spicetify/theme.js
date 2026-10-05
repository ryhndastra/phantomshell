(function phantomSpicetifyLiveSync() {
    let lastCss = "";
    async function pollColors() {
        try {
            const res = await fetch("colors.css?t=" + Date.now(), { cache: "no-store" });
            if (!res.ok) return;
            const css = await res.text();
            if (css && css !== lastCss) {
                lastCss = css;
                let styleEl = document.getElementById("phantomshell-live-colors");
                if (!styleEl) {
                    styleEl = document.createElement("style");
                    styleEl.id = "phantomshell-live-colors";
                    document.body.appendChild(styleEl);
                }
                styleEl.textContent = css;
            }
        } catch (e) {}
    }
    pollColors();
    setInterval(pollColors, 1200);
})();
