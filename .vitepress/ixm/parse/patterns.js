import { Pattern } from "./common";

export const PARENS = Object.freeze({
  CLOSE: new Pattern(/(\))/),
  OPEN: new Pattern(/(\()/),
});

export const PARAMETER = new Pattern(/([A-Z@/+._-][A-Z0-9@/+._-]+)/);
export const UNQUOTED = new Pattern(/[^()#"\\\s]+/);
export const TARGET = new Pattern(/\b([\w.+_:-]+)\b\s*/);
