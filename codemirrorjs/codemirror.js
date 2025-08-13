import * as CodeMirror from "codemirror";
import { Compartment, EditorState } from "@codemirror/state";
import { EditorView, placeholder } from "@codemirror/view";
import { indentWithTab } from "@codemirror/commands";
import { langs } from '@uiw/codemirror-extensions-langs';

import { oneDark } from "@codemirror/theme-one-dark";

import { abcdef } from '@uiw/codemirror-theme-abcdef';
import { abyss } from '@uiw/codemirror-theme-abyss';
import { androidstudio } from '@uiw/codemirror-theme-androidstudio';
import { andromeda } from '@uiw/codemirror-theme-andromeda';
import { atomone } from '@uiw/codemirror-theme-atomone';
import { aura } from '@uiw/codemirror-theme-aura';
import { basicLight, basicDark } from '@uiw/codemirror-theme-basic';
import { bbedit } from '@uiw/codemirror-theme-bbedit';
import { dracula } from '@uiw/codemirror-theme-dracula';
import { darcula } from '@uiw/codemirror-theme-darcula';
import { eclipse } from '@uiw/codemirror-theme-eclipse';
import { bespin } from '@uiw/codemirror-theme-bespin';
import { copilot } from '@uiw/codemirror-theme-copilot';
import { consoleDark, consoleLight } from '@uiw/codemirror-theme-console';
import { materialLight, materialDark } from '@uiw/codemirror-theme-material';
import { monokai } from '@uiw/codemirror-theme-monokai';
import { monokaiDimmed } from '@uiw/codemirror-theme-monokai-dimmed';
import { noctisLilac } from '@uiw/codemirror-theme-noctis-lilac';
import { vscodeDark, vscodeLight } from '@uiw/codemirror-theme-vscode';
import { duotoneLight, duotoneDark } from '@uiw/codemirror-theme-duotone';
import { githubLight, githubDark } from '@uiw/codemirror-theme-github';
import { gruvboxDark, gruvboxLight } from '@uiw/codemirror-theme-gruvbox-dark';
import { kimbie } from '@uiw/codemirror-theme-kimbie';
import { nord } from '@uiw/codemirror-theme-nord';
import { okaidia } from '@uiw/codemirror-theme-okaidia';
import { red } from '@uiw/codemirror-theme-red';
import { quietlight } from '@uiw/codemirror-theme-quietlight';
import { solarizedLight, solarizedDark } from '@uiw/codemirror-theme-solarized';
import { sublime } from '@uiw/codemirror-theme-sublime';
import { tokyoNight } from '@uiw/codemirror-theme-tokyo-night';
import { tokyoNightStorm } from '@uiw/codemirror-theme-tokyo-night-storm';
import { tokyoNightDay } from '@uiw/codemirror-theme-tokyo-night-day';
import { tomorrowNightBlue } from '@uiw/codemirror-theme-tomorrow-night-blue';
import { xcodeLight, xcodeDark } from '@uiw/codemirror-theme-xcode';
import { whiteLight, whiteDark } from '@uiw/codemirror-theme-white';

import {
  lineNumbers,
  highlightActiveLineGutter,
  highlightSpecialChars,
  drawSelection,
  dropCursor,
  rectangularSelection,
  crosshairCursor,
  highlightActiveLine,
  keymap,
} from "@codemirror/view";

import {
  foldGutter,
  indentOnInput,
  syntaxHighlighting,
  defaultHighlightStyle,
  bracketMatching,
  foldKeymap,
} from "@codemirror/language";

import { history, defaultKeymap, historyKeymap } from "@codemirror/commands";
import { highlightSelectionMatches, searchKeymap } from "@codemirror/search";
import {
  closeBrackets,
  autocompletion,
  closeBracketsKeymap,
  completionKeymap,
} from "@codemirror/autocomplete";

const SUPPORTED_LANGUAGES_MAP = langs;

const THEMES_MAP = {
  abcdef,
  abyss,
  androidstudio,
  andromeda,
  atomone,
  aura,
  basicLight,
  basicDark,
  bbedit,
  bespin,
  consoleDark,
  consoleLight,
  copilot,
  darcula,
  dracula,
  duotoneLight,
  duotoneDark,
  eclipse,
  githubLight,
  githubDark,
  gruvboxDark,
  gruvboxLight,
  kimbie,
  materialLight,
  materialDark,
  monokai,
  monokaiDimmed,
  noctisLilac,
  nord,
  okaidia,
  red,
  quietlight,
  solarizedLight,
  solarizedDark,
  sublime,
  tokyoNight,
  tokyoNightStorm,
  tokyoNightDay,
  tomorrowNightBlue,
  vscodeDark,
  vscodeLight,
  whiteLight,
  whiteDark,
  xcodeLight,
  xcodeDark,
};

const baseTheme = EditorView.baseTheme({
  "&light": {
    backgroundColor: "white", // the default codemirror light theme doesn't set this up
    "color-scheme": "light",
  },
  "&dark": {
    "color-scheme": "dark",
  },
});

const theme = new Compartment();
const language = new Compartment();
const listener = new Compartment();
const readOnly = new Compartment();
const lineWrapping = new Compartment();
const lineNumber = new Compartment();
const foldGutterComp = new Compartment();
const searchKeymapComp = new Compartment();
const placeholderComp = new Compartment();

const editorView = new CodeMirror.EditorView({
  doc: "",
  extensions: [
    highlightActiveLineGutter(),
    highlightSpecialChars(),
    history(),
    drawSelection(),
    dropCursor(),
    indentOnInput(),
    syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
    bracketMatching(),
    closeBrackets(),
    autocompletion(),
    rectangularSelection(),
    crosshairCursor(),
    highlightActiveLine(),
    highlightSelectionMatches(),
    keymap.of([
      ...closeBracketsKeymap,
      ...defaultKeymap,
      ...historyKeymap,
      ...foldKeymap,
      ...completionKeymap,
      indentWithTab,
    ]),
    placeholderComp.of([]),
    searchKeymapComp.of([]),
    foldGutterComp.of([]),
    readOnly.of([]),
    lineWrapping.of([]),
    lineNumber.of([]),
    baseTheme,
    theme.of(oneDark),
    language.of([]),
    listener.of([]),
  ],
  parent: document.body,
});

function getSupportedLanguages() {
  return Object.keys(SUPPORTED_LANGUAGES_MAP);
}

Object.keys(THEMES_MAP).forEach((key) => {
  THEMES_MAP[key.toLocaleLowerCase()] = THEMES_MAP[key]
});

function setTheme(name = "") {
  let themeFn = THEMES_MAP[name.toLocaleLowerCase()];
  editorView.dispatch({
    effects: theme.reconfigure(themeFn ? [themeFn] : []),
  });
}

function setLanguage(lang) {
  let langFn = SUPPORTED_LANGUAGES_MAP[lang];
  editorView.dispatch({
    effects: language.reconfigure(langFn ? langFn() : []),
  });
}

function setContent(text) {
  let currentValue = editorView.state.doc.toString();
  if (text === currentValue) {
    return;
  }
  editorView.dispatch({
    changes: { from: 0, to: editorView.state.doc.length, insert: text },
  });
}

function getContent() {
  return editorView.state.doc.toString();
}

function setListener(fn) {
  editorView.dispatch({
    effects: listener.reconfigure(
      EditorView.updateListener.of((v) => {
        if (v.docChanged) {
          fn();
        }
      })
    ),
  });
}

function setPlaceholder(value) {
  editorView.dispatch({
    effects: placeholderComp.reconfigure(value ? [placeholder(value)] : []),
  });
}

function setReadOnly(value) {
  editorView.dispatch({
    effects: readOnly.reconfigure(value ? EditorState.readOnly.of(true) : []),
  });
}

function setLineWrapping(enabled) {
  editorView.dispatch({
    effects: lineWrapping.reconfigure(enabled ? EditorView.lineWrapping : []),
  });
}

function setLineNumber(enabled) {
  editorView.dispatch({
    effects: lineNumber.reconfigure(enabled ? lineNumbers() : []),
  });
}

function setEnabledSearch(enabled) {
  editorView.dispatch({
    effects: searchKeymapComp.reconfigure(enabled ? keymap.of([ ...searchKeymap ]) : []),
  });
}

function setFoldGutter(enabled) {
  editorView.dispatch({
    effects: foldGutterComp.reconfigure(enabled ? foldGutter() : []),
  });
}

function setFocus() {
  editorView.focus();
}

function setBlur() {
  editorView.dom.blur()
}

export {
  setLanguage,
  getSupportedLanguages,
  setPlaceholder,
  setContent,
  getContent,
  setListener,
  setReadOnly,
  setTheme,
  setLineWrapping,
  setLineNumber,
  setFoldGutter,
  setEnabledSearch,
  setFocus,
  setBlur,
  editorView,
};
