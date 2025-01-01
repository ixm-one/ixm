import { IncludesRule } from "../parse";
import * as Scopes from "../scopes";

export default {
  comment: new IncludesRule("comment.block", "comment.line"),
  "comment.block": {
    name: Scopes.COMMENT_BLOCK,
    begin: /#\[(=*)\[/,
    end: /\]\1\]/,
    patterns: [{ include: `#documentation` }],
  },
  "comment.line": {
    name: Scopes.COMMENT_LINE,
    begin: /#/,
    end: /$/,
    patterns: [{ include: `#documentation` }],
  },
};
