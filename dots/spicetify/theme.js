(function phantomSpicetifyLiveSync() {
    let lastCss = "";

    /* buat overlay pattern diagonal yang selalu di atas */
    function ensurePatternOverlay() {
        if (document.getElementById("phantomshell-pattern-overlay")) return;
        const overlay = document.createElement("div");
        overlay.id = "phantomshell-pattern-overlay";
        overlay.style.cssText = [
            "position:fixed",
            "inset:0",
            "pointer-events:none",
            "z-index:0",
            "background-image:repeating-linear-gradient(-45deg,rgba(230,0,18,0.075) 0px,rgba(230,0,18,0.075) 1.5px,transparent 1.5px,transparent 13px)",
            "background-color:transparent",
        ].join(";");
        document.body.prepend(overlay);
    }

    /* inject css ke head supaya spesifisitas lebih tinggi dari catppuccin user.css */
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
                    /* inject ke head, bukan body — lebih akhir = override catppuccin */
                    (document.head || document.body).appendChild(styleEl);
                }
                styleEl.textContent = css;
            }
        } catch (e) {}
    }

    function init() {
        ensurePatternOverlay();
        pollColors();
        setInterval(pollColors, 1200);
        /* pastikan overlay tetap ada kalau spotify re-render */
        setInterval(ensurePatternOverlay, 3000);
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
