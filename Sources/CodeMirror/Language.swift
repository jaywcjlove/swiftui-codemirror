//
//  Language.swift
//  CodeMirror
//
//  Created by wong on 8/13/25.
//

public enum Language: String, CaseIterable, Hashable, Identifiable {
    public var id: String { rawValue }
    case troff1 = "1"
    case troff2 = "2"
    case troff3 = "3"
    case troff4 = "4"
    case forth4th = "4th"
    case troff5 = "5"
    case troff6 = "6"
    case troff7 = "7"
    case troff8 = "8"
    case troff9 = "9"
    case apl
    case asc
    case asn
    case asn1
    case b
    case bash
    case bf
    case BUILD
    case bzl
    case c
    case cplus = "c++"
    case cc
    case cfg
    case cjs
    case cl
    case clj
    case cljc
    case cljs
    case cljx
    case cmake
    case cmakein = "cmake.in"
    case cob
    case coffee
    case cpp
    case cpy
    case cql
    case cr
    case cs
    case css
    case cts
    case cxx
    case cyp
    case cypher
    case d
    case dart
    case diff
    case dtd
    case dyalog
    case dyl
    case dylan
    case e
    case ecl
    case edn
    case el
    case elm
    case erl
    case f
    case f77
    case f90
    case f95
    case factor
    case feature
    case `for` = "for"
    case forth
    case fs
    case fth
    case fun
    case go
    case gradle
    case groovy
    case gss
    case h
    case hplus = "h++"
    case handlebars
    case hbs
    case hh
    case hpp
    case hs
    case htm
    case html
    case hx
    case hxml
    case hxx
    case `in`
    case ini
    case ino
    case intr
    case j2
    case jade
    case java
    case jinja
    case jinja2
    case jl
    case js
    case json
    case jsonld
    case jsx
    case ksh
    case kt
    case kts
    case less
    case liquid
    case lisp
    case ls
    case ltx
    case lua
    case m
    case map
    case markdown
    case mbox
    case md
    case mjs
    case mkd
    case ml
    case mli
    case mll
    case mly
    case mm
    case mo
    case mps
    case mrc
    case msc
    case mscgen
    case mscin
    case msgenny
    case mts
    case nb
    case nix
    case nq
    case nsh
    case nsi
    case nt
    case nut
    case oz
    case p
    case pas
    case patch
    case pgp
    case php
    case php3
    case php4
    case php5
    case php7
    case phtml
    case pig
    case pl
    case pls
    case pm
    case pp
    case pro
    case properties
    case proto
    case ps1
    case psd1
    case psm1
    case pug
    case pxd
    case pxi
    case py
    case pyw
    case pyx
    case q
    case r
    case R
    case rb
    case rq
    case rs
    case s
    case sas
    case sass
    case scala
    case scm
    case scss
    case sh
    case sieve
    case sig
    case siv
    case smackspec
    case sml
    case solidity
    case sparql
    case spec
    case sql
    case ss
    case st
    case styl
    case sv
    case svelte
    case svg
    case svh
    case swift
    case tcl
    case tex
    case text
    case textile
    case toml
    case ts
    case tsx
    case ttcn
    case ttcn3
    case ttcnpp
    case ttl
    case v
    case vb
    case vbs
    case vhd
    case vhdl
    case vtl
    case vue
    case wast
    case wat
    case webidl
    case wl
    case wls
    case xml
    case xquery
    case xsd
    case xsl
    case xu
    case xy
    case yaml
    case yml
    case ys
    case z80
    public var name: String {
        switch self {
        case .c, .h, .ino: "C"
        case .cpp, .cplus, .cc, .cxx, .hpp, .hplus, .hh, .hxx: "C++"
        case .cql: "CQL"
        case .css: "CSS"
        case .go: "Go"
        case .html, .htm, .handlebars, .hbs: "HTML"
        case .java: "Java"
        case .js, .mjs, .cjs: "JavaScript"
        case .json, .map: "JSON"
        case .jsx: "JSX"
        case .less: "LESS"
        case .liquid: "Liquid"
        case .md, .markdown, .mkd: "Markdown"
        case .php, .php3, .php4, .php5, .php7, .phtml: "PHP"
        case .pls: "PLSQL"
        case .BUILD, .bzl, .py, .pyw: "Python"
        case .rs: "Rust"
        case .sass: "Sass"
        case .scss: "SCSS"
        case .sql: "SQL"
        case .tsx: "TSX"
        case .ts, .mts, .cts: "TypeScript"
        case .wat, .wast: "WebAssembly"
        case .xml, .xsl, .xsd, .svg: "XML"
        case .yaml, .yml: "YAML"
        case .dyalog, .apl: "APL"
        case .asc, .pgp, .sig: "PGP"
        case .asn, .asn1: "ASN.1"
        case .b, .bf: "Brainfuck"
        case .cob, .cpy: "Cobol"
        case .cs: "C#"
        case .clj, .cljc, .cljx: "Clojure"
        case .cljs: "ClojureScript"
        case .gss: "Closure Stylesheets (GSS)"
        case .cmake, .cmakein: "CMake"
        case .coffee: "CoffeeScript"
        case .cl, .lisp, .el: "Common Lisp"
        case .cyp, .cypher: "Cypher"
        case .pyx, .pxd, .pxi: "Cython"
        case .cr: "Crystal"
        case .d: "D"
        case .dart: "Dart"
        case .diff, .patch: "diff"
        case .dtd: "DTD"
        case .dylan, .dyl, .intr: "Dylan"
        case .ecl: "ECL"
        case .edn: "edn"
        case .e: "Eiffel"
        case .elm: "Elm"
        case .erl: "Erlang"
        case .factor: "Factor"
        case .forth, .fth, .forth4th: "Forth"
        case .f, .for, .f77, .f90, .f95: "Fortran"
        case .fs: "F#"
        case .s: "Gas"
        case .feature: "Gherkin"
        case .groovy, .gradle: "Groovy"
        case .hs: "Haskell"
        case .hx: "Haxe"
        case .hxml: "HXML"
        case .pro: "IDL"
        case .jsonld: "JSON-LD"
        case .j2, .jinja, .jinja2: "Jinja2"
        case .jl: "Julia"
        case .kt, .kts: "Kotlin"
        case .ls: "LiveScript"
        case .lua: "Lua"
        case .mrc: "mIRC"
        case .nb, .wl, .wls: "Mathematica"
        case .mo: "Modelica"
        case .mps: "MUMPS"
        case .mbox: "Mbox"
        case .nsh, .nsi: "NSIS"
        case .nt, .nq: "NTriples"
        case .m: "Objective-C"
        case .mm: "Objective-C++"
        case .ml, .mli, .mll, .mly: "OCaml"
        case .oz: "Oz"
        case .p, .pas: "Pascal"
        case .pl, .pm: "Perl"
        case .pig: "Pig"
        case .ps1, .psd1, .psm1: "PowerShell"
        case .properties, .ini, .in: "Properties files"
        case .proto: "ProtoBuf"
        case .pug, .jade: "Pug"
        case .pp: "Puppet"
        case .q: "Q"
        case .r, .R: "R"
        case .spec: "RPM Spec"
        case .rb: "Ruby"
        case .sas: "SAS"
        case .scala: "Scala"
        case .scm, .ss: "Scheme"
        case .sh, .ksh, .bash: "Shell"
        case .siv, .sieve: "Sieve"
        case .st: "Smalltalk"
        case .sml, .fun, .smackspec: "SML"
        case .rq, .sparql: "SPARQL"
        case .nut: "Squirrel"
        case .styl: "Stylus"
        case .swift: "Swift"
        case .text, .ltx, .tex: "LaTeX"
        case .sv, .svh: "SystemVerilog"
        case .tcl: "Tcl"
        case .textile: "Textile"
        case .toml: "TOML"
        case .troff1, .troff2, .troff3, .troff4, .troff5, .troff6, .troff7, .troff8, .troff9: "Troff"
        case .ttcn, .ttcn3, .ttcnpp: "TTCN"
        case .cfg: "TTCN_CFG"
        case .ttl: "Turtle"
        case .webidl: "Web IDL"
        case .vb: "VB.NET"
        case .vbs: "VBScript"
        case .vtl: "Velocity"
        case .v: "Verilog"
        case .vhd, .vhdl: "VHDL"
        case .xy, .xquery: "XQuery"
        case .ys: "Yacas"
        case .z80: "Z80"
        case .mscgen, .mscin, .msc: "MscGen"
        case .xu: "Xù"
        case .msgenny: "MsGenny"
        case .vue: "Vue"
        case .nix: "Nix"
        case .solidity: "Solidity"
        case .svelte: "Svelte"
        }
    }
}
