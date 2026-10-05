-- konfigurasi kurva bezier dan animasi transisi jendela serta ruang kerja

hl.config({
    animations = {
        enabled = Phantom.settings.animationsEnabled
    }
})

-- definisi kurva bezier untuk efek pegas dan transisi cepat
hl.curve("p5Spring", {
    type = "bezier",
    points = {{0.22, 1.48}, {0.18, 0.98}}
})

hl.curve("p5Slash", {
    type = "bezier",
    points = {{0.08, 0.92}, {0.12, 1.00}}
})

hl.curve("p5Exit", {
    type = "bezier",
    points = {{0.45, 0.02}, {0.85, 0.15}}
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 3.2,
    bezier = "p5Spring",
    style = "popin 82%"
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 2.4,
    bezier = "p5Exit",
    style = "popin 88%"
})

hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 3.0,
    bezier = "p5Slash",
    style = "slide"
})

hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 2.5,
    bezier = "p5Slash"
})

hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 2.2,
    bezier = "p5Exit"
})

hl.animation({
    leaf = "border",
    enabled = true,
    speed = 6,
    bezier = "p5Slash"
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 4.5,
    bezier = "p5Slash",
    style = "slide"
})

hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 3.8,
    bezier = "p5Spring",
    style = "slidefadevert -35%"
})

hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 3.0,
    bezier = "p5Exit",
    style = "slidefadevert -35%"
})

