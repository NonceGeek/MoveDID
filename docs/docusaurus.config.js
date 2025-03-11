// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require("prism-react-renderer/themes/github");
const darkCodeTheme = require("prism-react-renderer/themes/dracula");

const codeInjector = require("./src/remark/code-injector");

// KaTeX plugin stuff
const math = require("remark-math");
const katex = require("rehype-katex");

/** @type {import("@docusaurus/types").Config} */
const config = {
  title: "RMUD Docs",
  tagline: "RMUD Documentation",
  url: "https://rootmud.xyz",
  baseUrl: "/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "throw",
  favicon: "img/rmud_logo.png",
  organizationName: "rootmud", // Usually your GitHub org/user name.
  projectName: "root_mud", // Usually your repo name.

  presets: [
    [
      "@docusaurus/preset-classic",
      /** @type {import("@docusaurus/preset-classic").Options} */
      ({
        docs: {
          routeBasePath: "/",
          sidebarPath: require.resolve("./sidebars.js"),
          sidebarCollapsible: false,
          editUrl: "https://github.com/rootmud",
          remarkPlugins: [codeInjector, math],
          path: "docs",
          rehypePlugins: [katex],
        },
        sitemap: {
          changefreq: "daily",
          priority: 0.5,
          ignorePatterns: ["/tags/**"],
          filename: "sitemap.xml",
        },
        blog: false,
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
        gtag: {
          trackingID: "G-HVB7QFB9PQ",
        },
      }),
    ],
  ],
  stylesheets: [
    {
      href: "https://cdn.jsdelivr.net/npm/katex@0.13.24/dist/katex.min.css",
      type: "text/css",
      integrity: "sha384-odtC+0UGzzFL/6PNoE8rX/SPcQDXBJ+uRepguP4QkPCm2LBxH3FA3y+fKSiJ+AmM",
      crossorigin: "anonymous",
    },
  ],

  themeConfig:
    /** @type {import("@docusaurus/preset-classic").ThemeConfig} */
    ({
      image: "img/aptos_meta_opengraph_051222.jpg",
      colorMode: {
        defaultMode: "dark",
      },
      docs: {
        sidebar: {
          autoCollapseCategories: true,
          hideable: true,
        },
      },
      navbar: {
        logo: {
          alt: "RMUD Logo",
          src: "img/rmud_logo.png",
          srcDark: "img/rmud_logo.png",
        },
        items: [
          {
            href: "https://github.com/rootMUD/",
            label: "GitHub",
            position: "right",
          },
          {
            position: "left",
            type: "doc",
            docId: "rmud-white-paper",
            label: "RMUD Docs",
          },
        ],
      },
      footer: {
        style: "dark",
        links: [
          {
            title: null,
            items: [
              {
                html: `
                  <a class="social-link" href="https://rootmud.xyz" target="_blank" rel="noopener noreferrer" title="Git">
                     <img class="logo" src="img/rmud_logo.png" alt="Move-DID Logo" />
                  </a>
                `,
              },
            ],
          },
          {
            title: null,
            items: [
              {
                html: `
                <p class="emails">
                  If you have any questions, please contact us at </br>
                  <a href="mailto:leeduckgo@gmail.com" target="_blank" rel="noreferrer noopener">
                  leeduckgo@gmail.com
                  </a>
                </p>
              `,
              },
            ],
          },
          {
            title: null,
            items: [
              {
                html: `
                  <p class="right">
                    <nav class="social-links">
                        <a class="social-link" href="https://github.com/rootmud" target="_blank" rel="noopener noreferrer" title="Git">
                         <img class="icon" src="/img/socials/git.svg" alt="Git Icon" />
                        </a>
                        <a class="social-link" href="https://twitter.com/root_mud/" target="_blank" rel="noopener noreferrer" title="Twitter">
                          <img class="icon" src="/img/socials/twitter.svg" alt="Twitter Icon" />
                        </a>
                    </nav>
                  </p>
              `,
              },
            ],
          },
        ],
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ["rust"],
      },
      algolia: {
        appId: "HM7UY0NMLG",
        apiKey: "63c5819714b74e64977337e61a1e3ae6",
        indexName: "aptos",
        contextualSearch: true,
        debug: false,
      },
    }),
  plugins: [
  ],
};

module.exports = config;
