import Heading from '@theme/Heading';
import styles from './styles.module.css';

function ClusterIcon() {
  return (
    <svg width="52" height="52" viewBox="0 0 56 56" aria-hidden="true">
      <g stroke="var(--lattice-muted)" strokeWidth="1.5" opacity="0.6">
        <line x1="14" y1="42" x2="42" y2="42" />
        <line x1="14" y1="42" x2="28" y2="14" />
        <line x1="42" y1="42" x2="28" y2="14" />
      </g>
      <g fill="var(--ifm-color-primary)">
        <circle cx="14" cy="42" r="6" />
        <circle cx="42" cy="42" r="6" />
        <circle cx="28" cy="14" r="6" />
      </g>
    </svg>
  );
}

function SkillFileIcon() {
  return (
    <svg width="52" height="52" viewBox="0 0 56 56" aria-hidden="true">
      <rect x="8" y="10" width="30" height="38" rx="2" fill="var(--ifm-background-color)" stroke="var(--lattice-muted)" strokeWidth="1.5" />
      <rect x="16" y="6" width="30" height="38" rx="2" fill="var(--ifm-background-color)" stroke="var(--lattice-muted)" strokeWidth="1.5" />
      <line x1="22" y1="16" x2="40" y2="16" stroke="var(--ifm-color-primary)" strokeWidth="2.5" />
      <line x1="22" y1="24" x2="40" y2="24" stroke="var(--lattice-muted)" strokeWidth="1.5" opacity="0.6" />
      <line x1="22" y1="32" x2="34" y2="32" stroke="var(--lattice-muted)" strokeWidth="1.5" opacity="0.6" />
    </svg>
  );
}

function FeedbackLoopIcon() {
  return (
    <svg width="52" height="52" viewBox="0 0 56 56" aria-hidden="true">
      <path d="M 25.2,12.2 A 16,16 0 1 1 13,22.5" fill="none" stroke="var(--lattice-coral)" strokeWidth="3" strokeLinecap="round" />
      {/* Hand-rotated triangle instead of a path marker -- marker orient="auto" pointed the
          wrong way here. Angle is the arc's own tangent at the end point (13,22.5), verified
          by hand: -70deg, same formula used for the hero diagram's matching loop. */}
      <polygon points="0,-3.5 7,0 0,3.5" fill="var(--lattice-coral)" transform="translate(13,22.5) rotate(-70)" />
    </svg>
  );
}

const FeatureList = [
  {
    title: 'Atoms, Molecules, Refiners',
    Icon: ClusterIcon,
    description: (
      <>
        Single-principle guardrails compose into multi-step workflows, tuned per project by guided-interview
        refiners.
      </>
    ),
  },
  {
    title: 'Skills over prompts',
    Icon: SkillFileIcon,
    description: (
      <>
        Versioned, team-owned skill files in the repository beat personal prompts living on one developer&apos;s
        machine.
      </>
    ),
  },
  {
    title: 'A living context layer',
    Icon: FeedbackLoopIcon,
    description: (
      <>
        The <span className={styles.inlineCode}>.lattice/</span> folder accumulates standards, decisions, and
        review insights across every feature cycle.
      </>
    ),
  },
];

function Feature({Icon, title, description}) {
  return (
    <div className={styles.card}>
      <Icon />
      <Heading as="h3" className={styles.cardTitle}>
        {title}
      </Heading>
      <p className={styles.cardDescription}>{description}</p>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className={styles.grid}>
        {FeatureList.map((props, idx) => (
          <Feature key={idx} {...props} />
        ))}
      </div>
    </section>
  );
}
