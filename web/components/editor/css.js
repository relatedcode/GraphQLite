import { theme } from "components/editor/theme";

export const css = `
  /* Comment */
  .cm-comment {
    color: ${theme.editorColours.comment};
  }

  /* Punctuation */
  .cm-punctuation {
    color: ${theme.editorColours.punctuation};
  }

  /* Punctuation */
  .cm-operator {
    color: ${theme.editorColours.punctuation};
  }

  /* Property */
  .cm-property {
    color: ${theme.editorColours.property};
  }

  /* Keyword */
  .cm-keyword {
    color: ${theme.editorColours.keyword};
  }

  /* OperationName, FragmentName */
  .cm-def {
    color: ${theme.editorColours.def};
  }

  /* FieldAlias */
  .cm-qualifier {
    color: ${theme.editorColours.def};
  }

  /* ArgumentName and ObjectFieldName */
  .cm-attribute {
    color: ${theme.editorColours.attribute};
  }

  /* Number */
  .cm-number {
    color: ${theme.editorColours.number};
  }

  /* String */
  .cm-string {
    color: ${theme.editorColours.string};
  }

  /* Boolean */
  .cm-builtin {
    color: ${theme.editorColours.builtin};
  }

  /* EnumValue */
  .cm-string-2 {
    color: ${theme.editorColours.string2};
  }

  /* Variable */
  .cm-variable {
    color: ${theme.editorColours.variable};
  }

  /* Directive */
  .cm-meta {
    color: ${theme.editorColours.meta};
  }

  /* Type */
  .cm-atom {
    color: ${theme.editorColours.atom};
  }

  /* Comma */
  .cm-ws {
    color: ${theme.editorColours.ws};
  }

  .CodeMirror-lines {
    padding: 20px 0;
  }

  .CodeMirror-gutters {
    border-right: none;
  }

  .CodeMirror span[role='presentation'] {
    color: ${theme.colours.text};
  }

  /* Shown when moving in bi-directional text */
  .CodeMirror div.CodeMirror-secondarycursor {
    border-left: 1px solid silver;
  }
  .CodeMirror.cm-fat-cursor div.CodeMirror-cursor {
    background: rgba(255, 255, 255, 1);
    color: white;
    border: 0;
    width: auto;
  }
  .CodeMirror.cm-fat-cursor div.CodeMirror-cursors {
    z-index: 1;
  }

  .cm-animate-fat-cursor {
    -webkit-animation: blink 1.06s steps(1) infinite;
    animation: blink 1.06s steps(1) infinite;
    border: 0;
    width: auto;
  }
  @-webkit-keyframes blink {
    0% {
      background: #7e7;
    }
    50% {
      background: none;
    }
    100% {
      background: #7e7;
    }
  }
  @keyframes blink {
    0% {
      background: #7e7;
    }
    50% {
      background: none;
    }
    100% {
      background: #7e7;
    }
  }

  .CodeMirror-foldmarker {
    border-radius: 4px;
    background: #08f;
    background: linear-gradient(#43a8ff, #0f83e8);
    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.2), inset 0 0 0 1px rgba(0, 0, 0, 0.1);
    color: white;
    font-family: arial;
    font-size: 12px;
    line-height: 0;
    margin: 0 3px;
    padding: 0px 4px 1px;
    text-shadow: 0 -1px rgba(0, 0, 0, 0.1);
  }

  div.CodeMirror span.CodeMirror-matchingbracket {
    /* color: rgba(255, 255, 255, 0.4); */
  }

  div.CodeMirror span.CodeMirror-nonmatchingbracket {
    color: rgb(242, 92, 84);
  }

  .toolbar-button {
    background: #fdfdfd;
    background: linear-gradient(#fbfbfb, #f8f8f8);
    border-color: #d3d3d3 #d0d0d0 #bababa;
    border-radius: 4px;
    border-style: solid;
    border-width: 0.5px;
    box-shadow: 0 1px 1px -1px rgba(0, 0, 0, 0.13), inset 0 1px #fff;
    color: #444;
    cursor: pointer;
    display: inline-block;
    margin: 0 5px 0;
    padding: 2px 8px 4px;
    text-decoration: none;
  }
  .toolbar-button:active {
    background: linear-gradient(#ececec, #d8d8d8);
    border-color: #cacaca #c9c9c9 #b0b0b0;
    box-shadow: 0 1px 0 #fff, inset 0 1px rgba(255, 255, 255, 0.2),
      inset 0 1px 1px rgba(0, 0, 0, 0.08);
  }
  .toolbar-button.error {
    background: linear-gradient(#fdf3f3, #e6d6d7);
    color: #b00;
  }

  .autoInsertedLeaf.cm-property {
    -webkit-animation-duration: 6s;
    animation-duration: 6s;
    -webkit-animation-name: insertionFade;
    animation-name: insertionFade;
    border-bottom: 2px solid rgba(255, 255, 255, 0);
    border-radius: 2px;
    margin: -2px -4px -1px;
    padding: 2px 4px 1px;
  }

  @-webkit-keyframes insertionFade {
    from,
    to {
      background: rgba(255, 255, 255, 0);
      border-color: rgba(255, 255, 255, 0);
    }

    15%,
    85% {
      background: #fbffc9;
      border-color: #f0f3c0;
    }
  }

  @keyframes insertionFade {
    from,
    to {
      background: rgba(255, 255, 255, 0);
      border-color: rgba(255, 255, 255, 0);
    }

    15%,
    85% {
      background: #fbffc9;
      border-color: #f0f3c0;
    }
  }

  .CodeMirror pre {
    padding: 0 4px; /* Horizontal padding of content */
  }

  .CodeMirror-scrollbar-filler,
  .CodeMirror-gutter-filler {
    background-color: white; /* The little square between H and V scrollbars */
  }

  /* GUTTER */

  .CodeMirror-gutters {
    background-color: #ececec;
    border: none;
    white-space: nowrap;
  }
  .CodeMirror-linenumbers {
    background: ${theme.editorColours.editorBackground};
  }
  .CodeMirror-linenumber {
    font-weight: 600;
    color: ${theme.colours.textInactive};
    min-width: 20px;
    padding: 0 3px 0 5px;
    text-align: right;
    white-space: nowrap;
  }

  .CodeMirror-guttermarker {
    color: black;
  }
  .CodeMirror-guttermarker-subtle {
    color: #999;
  }

  .cm-tab {
    display: inline-block;
    text-decoration: inherit;
  }

  .CodeMirror-ruler {
    border-left: 1px solid #ccc;
    position: absolute;
  }
  .cm-negative {
    color: #d44;
  }
  .cm-positive {
    color: #292;
  }
  .cm-header,
  .cm-strong {
    font-weight: bold;
  }
  .cm-em {
    font-style: italic;
  }
  .cm-link {
    text-decoration: underline;
  }
  .cm-strikethrough {
    text-decoration: line-through;
  }

  .cm-s-default .cm-error {
    color: #ff4a4a;
  }
  .cm-invalidchar {
    color: #ff4a4a;
  }

  .CodeMirror-composing {
    border-bottom: 2px solid;
  }
  .CodeMirror-matchingtag {
    background: rgba(255, 150, 0, 0.3);
  }
  .CodeMirror-activeline-background {
    background: #e8f2ff;
  }

  /* The rest of this file contains styles related to the mechanics of
  the editor. You probably shouldn't touch them. */

  .cm-s-custom-0 {
    height: 250px;
  }

  .cm-s-custom-1 {
    height: 782px;
  }

  .cm-s-custom-project {
    height: 500px;
  }

  .CodeMirror-scroll {
    height: 100%;
    /* 30px is the magic margin used to hide the element's real scrollbars */
    /* See overflow: hidden in .CodeMirror */
    /* margin-bottom: -30px;
    margin-right: -30px; */
    outline: none; /* Prevent dragging from highlighting the element */
    overflow: hidden;
    /* padding-bottom: 30px; */
    position: relative;
    &:hover {
      overflow: scroll !important;
    }
  }
  .CodeMirror-sizer {
    border-right: 30px solid transparent;
    position: relative;
  }

  /* The fake, visible scrollbars. Used to force redraw during scrolling
  before actual scrolling happens, thus preventing shaking and
  flickering artifacts. */
  .CodeMirror-vscrollbar,
  .CodeMirror-hscrollbar,
  .CodeMirror-scrollbar-filler,
  .CodeMirror-gutter-filler {
    display: none !important;
    position: absolute;
    z-index: 6;
  }
  .CodeMirror-vscrollbar {
    overflow-x: hidden;
    overflow-y: scroll;
    right: 0;
    top: 0;
  }
  .CodeMirror-hscrollbar {
    bottom: 0;
    left: 0;
    overflow-x: scroll;
    overflow-y: hidden;
  }
  .CodeMirror-scrollbar-filler {
    right: 0;
    bottom: 0;
  }
  .CodeMirror-gutter-filler {
    left: 0;
    bottom: 0;
  }

  .CodeMirror-gutters {
    min-height: 100%;
    position: absolute;
    left: 0;
    top: 0;
    z-index: 3;
  }
  .CodeMirror-gutter {
    display: inline-block;
    height: 100%;
    margin-bottom: -30px;
    vertical-align: top;
    white-space: normal;
    /* Hack to make IE7 behave */
    *zoom: 1;
    *display: inline;
  }
  .CodeMirror-gutter-wrapper {
    background: none !important;
    border: none !important;
    position: absolute;
    z-index: 4;
  }
  .CodeMirror-gutter-background {
    position: absolute;
    top: 0;
    bottom: 0;
    z-index: 4;
  }
  .CodeMirror-gutter-elt {
    cursor: default;
    position: absolute;
    z-index: 4;
  }
  .CodeMirror-gutter-wrapper {
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
  }

  .CodeMirror-lines {
    cursor: text;
    min-height: 1px; /* prevents collapsing before first draw */
  }
  .CodeMirror pre {
    -webkit-tap-highlight-color: transparent;
    /* Reset some styles that the rest of the page might have set */
    background: transparent;
    border-radius: 0;
    border-width: 0;
    color: inherit;
    font-family: inherit;
    font-size: inherit;
    -webkit-font-variant-ligatures: none;
    font-variant-ligatures: none;
    line-height: inherit;
    margin: 0;
    overflow: visible;
    position: relative;
    white-space: pre;
    word-wrap: normal;
    z-index: 2;
  }
  .CodeMirror-wrap pre {
    word-wrap: break-word;
    white-space: pre-wrap;
    word-break: normal;
  }

  .CodeMirror-linebackground {
    position: absolute;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    z-index: 0;
  }

  .CodeMirror-linewidget {
    overflow: auto;
    position: relative;
    z-index: 2;
  }

  .CodeMirror-widget {
  }

  .CodeMirror-code {
    outline: none;
  }

  /* Force content-box sizing for the elements where we expect it */
  .CodeMirror-scroll,
  .CodeMirror-sizer,
  .CodeMirror-gutter,
  .CodeMirror-gutters,
  .CodeMirror-linenumber {
    box-sizing: content-box;
  }

  .CodeMirror-measure {
    height: 0;
    overflow: hidden;
    position: absolute;
    visibility: hidden;
    width: 100%;
  }

  .CodeMirror-cursor {
    position: absolute;
  }
  .CodeMirror-measure pre {
    position: static;
  }

  div.CodeMirror-cursors {
    position: relative;
    visibility: hidden;
    z-index: 3;
  }
  div.CodeMirror-dragcursors {
    visibility: visible;
  }

  .CodeMirror-focused div.CodeMirror-cursors {
    visibility: visible;
  }

  .CodeMirror-selected {
    background: ${theme.editorColours.selection};
  }
  .CodeMirror-focused .CodeMirror-selected {
    background: ${theme.editorColours.selection};
  }
  .CodeMirror-crosshair {
    cursor: crosshair;
  }
  .CodeMirror-line::-moz-selection,
  .CodeMirror-line > span::-moz-selection,
  .CodeMirror-line > span > span::-moz-selection {
    background: ${theme.editorColours.selection};
  }
  .CodeMirror-line::selection,
  .CodeMirror-line > span::selection,
  .CodeMirror-line > span > span::selection {
    background: ${theme.editorColours.selection};
  }
  .CodeMirror-line::-moz-selection,
  .CodeMirror-line > span::-moz-selection,
  .CodeMirror-line > span > span::-moz-selection {
    background: ${theme.editorColours.selection};
  }

  .cm-searching {
    background: #ffa;
    background: rgba(255, 255, 0, 0.4);
  }

  /* IE7 hack to prevent it from returning funny offsetTops on the spans */
  .CodeMirror span {
    *vertical-align: text-bottom;
  }

  /* Used to force a border model for a node */
  .cm-force-border {
    padding-right: 0.1px;
  }

  @media print {
    /* Hide the cursor when printing */
    .CodeMirror div.CodeMirror-cursors {
      visibility: hidden;
    }
  }

  /* See issue #2901 */
  .cm-tab-wrap-hack:after {
    content: '';
  }

  /* Help users use markselection to safely style text background */
  span.CodeMirror-selectedtext {
    background: none;
  }

  .CodeMirror-dialog {
    background: inherit;
    color: inherit;
    left: 0;
    right: 0;
    overflow: hidden;
    padding: 0.1em 0.8em;
    position: absolute;
    z-index: 15;
  }

  .CodeMirror-dialog-top {
    border-bottom: 1px solid #eee;
    top: 0;
  }

  .CodeMirror-dialog-bottom {
    border-top: 1px solid #eee;
    bottom: 0;
  }

  .CodeMirror-dialog input {
    background: transparent;
    border: 1px solid #d3d6db;
    color: inherit;
    font-family: monospace;
    outline: none;
    width: 20em;
  }

  .CodeMirror-dialog span.CodeMirror-search-label {
    color: ${theme.colours.text};
  }

  .CodeMirror-dialog input.CodeMirror-search-field {
    color: ${theme.colours.text};
  }

  .CodeMirror-dialog button {
    font-size: 70%;
  }

  .CodeMirror-foldgutter {
    width: 0.7em;
  }
  .CodeMirror-foldgutter-open,
  .CodeMirror-foldgutter-folded {
    cursor: pointer;
  }
  .CodeMirror-foldgutter-open:after {
    content: '▾';
  }
  .CodeMirror-foldgutter-folded:after {
    content: '▸';
  }
  /* The lint marker gutter */
  .CodeMirror-lint-markers {
    width: 16px;
  }

  .CodeMirror-jump-token {
    cursor: pointer;
    text-decoration: underline;
  }
`;
