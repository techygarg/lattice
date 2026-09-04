import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';

import Heading from '@theme/Heading';
import styles from './index.module.css';

function HeroDiagram() {
  return (
    <svg
      viewBox="0 0 640 210"
      width="640"
      height="210"
      className={styles.heroDiagram}
      role="img"
      aria-label="Three atom nodes on the left connect into a six-node molecule cluster on the right, with a coral feedback loop orbiting the molecule, representing refiners tuning the cycle.">
      <defs>
        <marker id="hero-arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
          <path d="M0,0 L10,5 L0,10 z" fill="var(--ifm-color-primary)" />
        </marker>
      </defs>

      <g stroke="var(--lattice-muted)" strokeWidth="1.5" opacity="0.55">
        <line x1="78" y1="60" x2="272" y2="100" />
        <line x1="78" y1="100" x2="272" y2="100" />
        <line x1="78" y1="140" x2="272" y2="100" />
      </g>
      <line x1="280" y1="100" x2="424" y2="100" stroke="var(--ifm-color-primary)" strokeWidth="2" markerEnd="url(#hero-arrow)" />

      <g fill="var(--ifm-color-primary)">
        <circle cx="70" cy="60" r="7" />
        <circle cx="70" cy="100" r="7" />
        <circle cx="70" cy="140" r="7" />
      </g>
      <text x="70" y="176" textAnchor="middle" fontFamily="IBM Plex Mono, monospace" fontSize="11" letterSpacing="0.08em" fill="var(--lattice-muted)">ATOMS</text>

      <g stroke="var(--lattice-muted)" strokeWidth="1.5" opacity="0.6" fill="none">
        <polygon points="460,64 489,82 489,118 460,136 431,118 431,82" />
        <line x1="460" y1="64" x2="460" y2="136" />
        <line x1="431" y1="82" x2="489" y2="118" />
        <line x1="489" y1="82" x2="431" y2="118" />
      </g>
      <g fill="var(--ifm-color-primary)">
        <circle cx="460" cy="64" r="6" />
        <circle cx="489" cy="82" r="6" />
        <circle cx="489" cy="118" r="6" />
        <circle cx="460" cy="136" r="6" />
        <circle cx="431" cy="118" r="6" />
        <circle cx="431" cy="82" r="6" />
      </g>
      <text x="460" y="176" textAnchor="middle" fontFamily="IBM Plex Mono, monospace" fontSize="11" letterSpacing="0.08em" fill="var(--lattice-muted)">MOLECULES</text>

      {/* Radius 58 clears the hexagon (its nodes sit ~40px out from center 460,100) with room to spare. */}
      <path d="M 449.9,42.9 A 58,58 0 1 1 405.5,80.2" fill="none" stroke="var(--lattice-coral)" strokeWidth="3" strokeLinecap="round" />
      {/* Hand-rotated triangle instead of a path marker -- marker orient="auto" wasn't rendering
          reliably everywhere. Angle is the arc's own tangent at the end point (verified by hand),
          not eyeballed. */}
      <polygon points="0,-5 10,0 0,5" fill="var(--lattice-coral)" transform="translate(405.5,80.2) rotate(-70)" />
      <text x="565" y="40" textAnchor="middle" fontFamily="IBM Plex Mono, monospace" fontSize="11" letterSpacing="0.08em" fill="var(--lattice-coral)">REFINERS</text>
    </svg>
  );
}

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={styles.heroBanner}>
      <div className={styles.eyebrow}>Agent skills framework</div>
      <Heading as="h1" className={styles.title}>
        {siteConfig.tagline}
      </Heading>
      <p className={styles.subtitle}>
        Atoms, molecules, and refiners — versioned skill files that guide Claude Code, Cursor, and other coding
        assistants through design-first, architecture-guided work, instead of jumping straight to code.
      </p>
      <div className={styles.buttons}>
        <Link className={styles.primaryButton} to="/docs/how-it-works">
          Read How It Works
        </Link>
        <Link className={styles.secondaryButton} to="https://github.com/techygarg/lattice">
          View on GitHub ↗
        </Link>
      </div>
      <HeroDiagram />
    </header>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description="Composable AI skills that teach assistants structured thinking -- design-first, context-aware, and architecture-guided.">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
