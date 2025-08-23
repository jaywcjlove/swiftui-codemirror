//
//  Themes.swift
//  CodeMirror
//
//  Created by wong on 8/13/25.
//

public enum Themes: String, CaseIterable, Hashable, Identifiable {
    public var id: String { rawValue }
    case abcdef
    case abyss
    case androidstudio
    case andromeda
    case atomone
    case aura
    case basiclight
    case basicdark
    case bbedit
    case bespin
    case consoledark
    case consolelight
    case copilot
    case darcula
    case dracula
    case duotonelight
    case duotonedark
    case eclipse
    case githublight
    case githubdark
    case gruvboxdark
    case gruvboxlight
    case kimbie
    case materiallight
    case materialdark
    case monokai
    case monokaidimmed
    case noctislilac
    case nord
    case okaidia
    case red
    case quietlight
    case solarizedlight
    case solarizeddark
    case sublime
    case tokyonight
    case tokyonightstorm
    case tokyonightday
    case tomorrownightblue
    case vscodedark
    case vscodelight
    case whitelight
    case whitedark
    case xcodelight
    case xcodedark
}
