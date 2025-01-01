import * as Scopes from "./scopes";

class Token {
  constructor({
    color,
    scopes,
    underline = false,
    italic = false,
    bold = false,
  }) {
    underline = underline ? "underline" : "";
    italic = italic ? "italic" : "";
    bold = bold ? "bold" : "";

    this.scope = [].concat(scopes);
    this.settings = {
      fontStyle: `${bold} ${italic} ${underline}`.trim(),
      foreground: color,
    };

    if (!this.settings.fontStyle) {
      delete this.settings.fontStyle;
    }
    if (!this.settings.background) {
      delete this.settings.background;
    }
  }
}

/**
 * Palette based off of GitHub Primer {Dark|Light} High Contrast color palette
 * @see {@link https://primer.style/primitives/storybook/?path=/story/color-base-display-scales--all-scales}
 * @see {@link https://primer.style/primitives/storybook/?path=/story/color-base-scales--all-scales}
 */
class Palette {
  static dark = {
    foreground: "#f0f6fc",

    blue: ["#85c2ff", "#71b7ff"],
    coral: ["#f7794b", "#fa8c61"],
    red: ["#f27d83", "#ff6a69"],

    cyan: "#80dbf9",
    green: "#99e090",
    grey: "#9198a1",
    indigo: "#b7baf6",
    lemon: "#e3d04f",
    lime: "#bcda67",
    orange: "#fe9a2d",
    pink: "#ec8dbd",
    plum: "#e4a5fd",
    purple: "#e1c7ff",
    yellow: "#edb431",
  };

  static light = {
    foreground: "#25292e",

    blue: ["#0f8fff", "#368cf9"],
    coral: ["#f25f3a", "#d43511"],
    red: ["#d5232c", "#df0c24"],

    cyan: "#00d0fa",
    green: "#54d961",
    grey: "#818b98",
    indigo: "#7a82f0",
    lemon: "#d8bd0e",
    lime: "#6c9d2f",
    orange: "#e16f24",
    pink: "#e55da5",
    plum: "#c264f2",
    purple: "#a672f3",
    yellow: "#d19d00",
  };
}

class Light {
  displayName = "IXM Light";
  name = "ixm-light";
  type = "light";
  colors = {
    "editor.foreground": Palette.light.foreground,
  };
  tokenColors = [
    new Token({ scopes: Scopes.COMMENT, color: Palette.light.grey }),
    new Token({ scopes: Scopes.KEYWORD, color: Palette.light.coral[1] }),
    new Token({
      scopes: Scopes.TARGET,
      color: Palette.light.coral[0],
      bold: true,
      italic: true,
    }),
    new Token({
      scopes: [Scopes.KW_ARTIFACT, Scopes.KW_TARGET, Scopes.KW_PROPERTY],
      color: Palette.light.orange,
    }),
    new Token({
      scopes: [
        "meta.generator.expression",
        Scopes.KW_OPERATOR,
        Scopes.KW_CONTROL,
        Scopes.KW_SCOPE,
        Scopes.MODIFIER,
        Scopes.TAG,
        Scopes.ENUM_MEMBER,
      ],
      color: Palette.light.red[1],
    }),
    new Token({
      scopes: "meta.generator.expression",
      color: Palette.light.indigo,
    }),
    new Token({ scopes: Scopes.GENEXP, color: Palette.light.red[0] }),
    new Token({ scopes: Scopes.TYPE, color: Palette.light.yellow }),
    new Token({ scopes: Scopes.PARAMETER, color: Palette.light.purple }),
    new Token({ scopes: Scopes.METHOD, color: Palette.light.pink }),
    new Token({ scopes: Scopes.NUMBER, color: Palette.light.green }),
    new Token({ scopes: Scopes.VERSION, color: Palette.light.lemon }),
    new Token({ scopes: Scopes.UNQUOTED, color: Palette.light.foreground }),
    new Token({
      scopes: [Scopes.MONADIC, Scopes.VARIADIC],
      color: Palette.light.plum,
    }),
    new Token({
      scopes: [Scopes.OPTIONS, Scopes.BOOLEAN],
      color: Palette.light.cyan,
    }),
    new Token({
      scopes: [Scopes.PROPERTY, Scopes.VARIABLE, Scopes.VARIABLE_READONLY],
      color: Palette.light.blue[0],
    }),
    new Token({
      scopes: [Scopes.DEREFERENCE, Scopes.INTERPOLATED, Scopes.CHAR_ESCAPE],
      color: Palette.light.orange,
    }),
    new Token({
      scopes: [Scopes.STRING, `meta.generator.expression ${Scopes.UNQUOTED}`],
      color: Palette.light.lime,
    }),
    new Token({
      scopes: [Scopes.FUNCTION, Scopes.FUNCTION_DEFAULT_LIBRARY],
      color: Palette.light.blue[1],
    }),

    new Token({
      scopes: [
        `${Scopes.INTERPOLATED} ${Scopes.VARIABLE_READONLY}`,
        `${Scopes.INTERPOLATED} ${Scopes.VARIABLE}`,
        `${Scopes.INTERPOLATED} ${Scopes.TAG}`,
        Scopes.INTERPOLATED,
        Scopes.DOUBLE_QUOTED,
        Scopes.CHAR_ESCAPE,
      ],
      italic: true,
    }),
    new Token({
      scopes: [
        Scopes.BOOLEAN,
        Scopes.ENUM_MEMBER,
        Scopes.FUNCTION,
        Scopes.FUNCTION_DEFAULT_LIBRARY,
        Scopes.KEYWORD,
        Scopes.METHOD,
        Scopes.MODIFIER,
        Scopes.MONADIC,
        Scopes.OPTIONS,
        Scopes.PROPERTY,
        Scopes.TAG,
        Scopes.TYPE,
        Scopes.VARIADIC,
        Scopes.GENEXP,
      ],
      bold: true,
    }),
  ];
}

class Dark {
  displayName = "IXM Dark";
  name = "ixm-dark";
  type = "dark";
  colors = {
    "editor.foreground": Palette.dark.foreground,
  };
  tokenColors = [
    new Token({ scopes: Scopes.COMMENT, color: Palette.dark.grey }),
    new Token({ scopes: Scopes.KEYWORD, color: Palette.dark.coral[1] }),
    new Token({
      scopes: Scopes.TARGET,
      color: Palette.dark.coral[0],
      bold: true,
      italic: true,
    }),
    new Token({
      scopes: [Scopes.KW_ARTIFACT, Scopes.KW_TARGET, Scopes.KW_PROPERTY],
      color: Palette.dark.orange,
    }),
    new Token({
      scopes: [
        "meta.generator.expression",
        Scopes.KW_OPERATOR,
        Scopes.KW_CONTROL,
        Scopes.KW_SCOPE,
        Scopes.MODIFIER,
        Scopes.TAG,
        Scopes.ENUM_MEMBER,
      ],
      color: Palette.dark.red[1],
    }),
    new Token({
      scopes: "meta.generator.expression",
      color: Palette.dark.indigo,
    }),
    new Token({ scopes: Scopes.GENEXP, color: Palette.dark.red[0] }),
    new Token({ scopes: Scopes.TYPE, color: Palette.dark.yellow }),
    new Token({ scopes: Scopes.PARAMETER, color: Palette.dark.purple }),
    new Token({ scopes: Scopes.METHOD, color: Palette.dark.pink }),
    new Token({ scopes: Scopes.NUMBER, color: Palette.dark.green }),
    new Token({ scopes: Scopes.VERSION, color: Palette.dark.lemon }),
    new Token({ scopes: Scopes.UNQUOTED, color: Palette.dark.foreground }),
    new Token({
      scopes: [Scopes.MONADIC, Scopes.VARIADIC],
      color: Palette.dark.plum,
    }),
    new Token({
      scopes: [Scopes.OPTIONS, Scopes.BOOLEAN],
      color: Palette.dark.cyan,
    }),
    new Token({
      scopes: [Scopes.PROPERTY, Scopes.VARIABLE, Scopes.VARIABLE_READONLY],
      color: Palette.dark.blue[0],
    }),
    new Token({
      scopes: [Scopes.DEREFERENCE, Scopes.INTERPOLATED, Scopes.CHAR_ESCAPE],
      color: Palette.dark.orange,
    }),
    new Token({
      scopes: [Scopes.STRING, `meta.generator.expression ${Scopes.UNQUOTED}`],
      color: Palette.dark.lime,
    }),
    new Token({
      scopes: [Scopes.FUNCTION, Scopes.FUNCTION_DEFAULT_LIBRARY],
      color: Palette.dark.blue[1],
    }),
    new Token({
      scopes: [
        `${Scopes.INTERPOLATED} ${Scopes.VARIABLE_READONLY}`,
        `${Scopes.INTERPOLATED} ${Scopes.VARIABLE}`,
        `${Scopes.INTERPOLATED} ${Scopes.TAG}`,
        Scopes.INTERPOLATED,
        Scopes.DOUBLE_QUOTED,
        Scopes.CHAR_ESCAPE,
      ],
      italic: true,
    }),
    new Token({
      scopes: [
        "string.other.multiline",
        Scopes.BOOLEAN,
        Scopes.ENUM_MEMBER,
        Scopes.FUNCTION,
        Scopes.FUNCTION_DEFAULT_LIBRARY,
        Scopes.KEYWORD,
        Scopes.METHOD,
        Scopes.MODIFIER,
        Scopes.MONADIC,
        Scopes.OPTIONS,
        Scopes.PROPERTY,
        Scopes.TAG,
        Scopes.TYPE,
        Scopes.VARIADIC,
        Scopes.GENEXP,
      ],
      bold: true,
    }),
  ];
}

export default {
  light: new Light(),
  dark: new Dark(),
};
