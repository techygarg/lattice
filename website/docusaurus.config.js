// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import {themes as prismThemes} from 'prism-react-renderer';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Lattice',
  tagline: 'Composable AI skills that teach assistants structured thinking',
  favicon: 'img/logo.svg',

  // Archivo (display), IBM Plex Sans (body), IBM Plex Mono (code/labels) --
  // the type system from the approved design canvas. Google Fonts is the
  // only external stylesheet host Docusaurus/the CSP setup here allows.
  headTags: [
    {
      tagName: 'link',
      attributes: {rel: 'preconnect', href: 'https://fonts.googleapis.com'},
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css2?family=Archivo:wght@600;700;800;900&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@500;600&display=swap',
      },
    },
  ],

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: 'https://techygarg.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  baseUrl: '/lattice/',

  // GitHub pages deployment config.
  organizationName: 'techygarg',
  projectName: 'lattice',

  onBrokenLinks: 'throw',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          // Reads the repo's existing docs/ folder directly -- no copy,
          // no second source of truth. Content is edited in place, same as today.
          path: '../docs',
          routeBasePath: 'docs',
          sidebarPath: './sidebars.js',
          editUrl: 'https://github.com/techygarg/lattice/tree/main/docs/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'Lattice',
        logo: {
          alt: 'Lattice logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://github.com/techygarg/lattice',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'How It Works',
                to: '/docs/how-it-works',
              },
              {
                label: 'Practical Guide',
                to: '/docs/practical-guide',
              },
            ],
          },
          {
            title: 'Project',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/techygarg/lattice',
              },
              {
                label: 'Contributing',
                href: 'https://github.com/techygarg/lattice/blob/main/CONTRIBUTING.md',
              },
              {
                label: 'License (MIT)',
                href: 'https://github.com/techygarg/lattice/blob/main/LICENSE',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Lattice. Built with Docusaurus.`,
      },
      // vsDark in both modes: code blocks stay consistently dark regardless
      // of site theme, matching the token sheet. A bundled complete theme
      // rather than hand-tuned token colors -- a deliberate, lower-risk
      // stand-in for now; worth revisiting once this can be seen rendered.
      prism: {
        theme: prismThemes.vsDark,
        darkTheme: prismThemes.vsDark,
      },
    }),
};

export default config;
