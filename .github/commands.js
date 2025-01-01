"use strict";

import { execFile } from "node:child_process";
import { readFile as read } from "node:fs/promises";
import { promisify } from "node:util";
import { glob } from "glob";

async function extract(files) {
  const promises = files.map(async (file) => {
    const contents = await read(file, { encoding: "utf8" });
    return Array.from(contents.matchAll(COMMAND_REGEX)).map(
      (match) => match.groups.name,
    );
  });
  return await Array.fromAsync(promises);
}

const COMMAND_REGEX = /^\s*(?:function|macro)\s*\(\s*(?<name>[^\s)]+)/gm;
const subprocess = promisify(execFile);

const {
  error,
  stdout: root,
  stderr,
} = await subprocess("git", ["rev-parse", "--show-toplevel"]);
if (error) {
  console.error(`git rev-parse exited with ${error}: ${stderr}`);
}

const files = await glob("**/*.cmake", {
  ignore: ["node_modules/**", ".vitepress/cache", ".vitepress/dist"],
  dotRelative: true,
  posix: true,
  cwd: root.trim(),
});

const commands = (await extract(files)).flat().sort();

for (const command of commands) {
  console.log(`found: ${command}`);
}
