import { withMermaid } from "vitepress-plugin-mermaid";
import { withSidebar } from "vitepress-sidebar";
import { defineConfig } from "vitepress";

import footnote from "markdown-it-footnote";
import deflist from "markdown-it-deflist";

import cmake from "./ixm/grammar";
import theme from "./ixm/theme";

const DESCRIPTION = "Making CMake easier one module at a time!";
const DOMAIN = "ixm.one";
const TITLE = "Izzy's eXtension Modules";
const LOGO = "/logo.svg";

const partialConfig = {
  srcDir: "docs",
  themeConfig: {
    externalLinkIcon: true,
    outline: { level: [2, 3] },
    logo: LOGO,
    nav: [
      { text: "Guides", link: "/guides/installation" },
      { text: "Modules", link: "/modules" },
      { text: "Packages", link: "/packages" },
      { text: "Contribute", link: "/contribute" },
    ],
    footer: { copyright: "&copy; Izzy Muerte" },
    search: { provider: "local" },
    edtLink: { pattern: "https://github.com/ixm-one/ixm/edit/main/docs/:path" },
    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/ixm-one/ixm",
        ariaLabel: "GitHub Repository",
      },
      {
        icon: "cmake",
        link: "https://cmake.org/cmake/help/latest/",
        ariaLabel: "CMake Documentation",
      },
    ],
  },
};

const sidebarOptions = {
  //debugPrint: true,
  collapsed: true,
  documentRootPath: partialConfig.srcDir,
  excludeFilesByFrontmatterFieldName: "hide",
  frontmatterOrderDefaultValue: 999,
  keepMarkdownSyntaxFromTitle: true,
  sortMenusByFrontmatterOrder: true,
  useFolderTitleFromIndexFile: true,
  useFolderLinkFromIndexFile: true,
  useTitleFromFrontmatter: true,
};

const config = withSidebar(partialConfig, [
  {
    ...sidebarOptions,
    resolvePath: "/",
    excludePattern: ["contribute", "internals"],
  },
  {
    ...sidebarOptions,
    collapsed: false,
    scanStartPath: "contribute",
    resolvePath: "/contribute/",
  },
]);

/* partially cleanup sidebar */
const toUnlink = ["Guides", "Internals", "Playbooks"];
const { "/": root, "/contribute/": contribute } = config.themeConfig.sidebar;
root.items
  .concat(contribute.items)
  .filter((item) => toUnlink.includes(item.text))
  .forEach((item) => delete item.link);

export default withMermaid(
  defineConfig({
    ...config,
    lang: "en-US",
    title: TITLE,
    description: DESCRIPTION,
    metaChunk: true,
    cleanUrls: true,
    markdown: {
      config(md) {
        md.use(footnote).use(deflist);
      },
      languages: [cmake, "console"],
      theme,
    },
    search: { provider: "local" },
    sitemap: { hostname: "https://ixm.one" },
    head: [
      ["link", { rel: "icon", type: "image/svg+xml", href: LOGO }],
      ["meta", { name: "darkreader-lock" }],
      ["meta", { property: "og:site_name", content: "IXM" }],
      ["meta", { property: "og:locale", content: "en" }],
      ["meta", { property: "og:type", content: "website" }],
      ["meta", { property: "og:url", content: `https://${DOMAIN}` }],
      ["meta", { property: "og:image", content: `https://${DOMAIN}/logo.png` }],
      ["meta", { property: "og:image:height", content: "128" }],
      ["meta", { property: "og:image:width", content: "128" }],
      ["meta", { property: "og:image:type", content: "image/png" }],
    ],
    transformPageData(pageData) {
      const home = pageData.frontmatter.layout === "home";
      const description = {
        name: "og:description",
        content: pageData.frontmatter?.description ?? DESCRIPTION,
      };
      const title = {
        name: "og:title",
        content: home ? TITLE : `${pageData.title} | ${TITLE}`,
      };
      pageData.frontmatter.head ??= [];
      pageData.frontmatter.head.push(["meta", description]);
      pageData.frontmatter.head.push(["meta", title]);
    },
  }),
);
