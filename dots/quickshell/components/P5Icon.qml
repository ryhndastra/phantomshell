import QtQuick
import qs.config

Item {
    id: root
    property string name: "star"
    property string icon: ""
    property int size: 14
    property color color: PhantomState.foreground

    implicitWidth: size + 2
    implicitHeight: size + 2
    width: size + 2
    height: size + 2

    readonly property var glyphMap: ({
        "phantom":      "\uf06d",
        "star":         "\uf005",
        "sparkles":     "\uf0e7",
        "moon":         "\uf186",
        "tv":           "\uf26c",
        "sun":          "\uf185",
        "cloud":        "\uf0c2",
        "message":      "\uf086",
        "bell":         "\uf0f3",
        "bell-off":     "\uf1f6",
        "stats":        "\uf080",
        "settings":     "\uf013",
        "power":        "\uf011",
        "lock":         "\uf023",
        "logout":       "\uf08b",
        "reboot":       "\uf021",
        "search":       "\uf002",
        "chevron-right":"\uf054",
        "close":        "\uf00d",
        "plus":         "\uf067",
        "minus":        "\uf068",
        "wifi":         "\uf1eb",
        "bluetooth":    "\uf293",
        "volume":       "\uf028",
        "mute":         "\uf026",
        "brightness":   "\uf185",
        "frame":        "\uf065",
        "polygon":      "\uf1b2",
        "rounded":      "\uf111",
        "up":           "\uf062",
        "down":         "\uf063",
        "app":          "\uf120",
        "calc":         "\uf1ec",
        "palette":      "\uf53f",
        "image":        "\uf03e",
        "check":        "\uf00c",
        "bars":         "\uf0c9"
    })

    Text {
        anchors.centerIn: parent
        text: root.icon !== "" ? (root.glyphMap[root.icon] !== undefined ? root.glyphMap[root.icon] : root.icon) : (root.glyphMap[root.name] !== undefined ? root.glyphMap[root.name] : "\uf005")
        color: root.color
        font.family: "JetBrainsMono NFM"
        font.pixelSize: root.size
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
