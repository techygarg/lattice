import Link from '@docusaurus/Link';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import styles from './story.module.css';

export default function Story() {
  return (
    <Layout
      title="Why I Built Lattice"
      description="Rahul, the creator of Lattice, on why he built it, where he wants feedback, and the one workflow to try first.">
      <main className={styles.container}>
        <p className={styles.eyebrow}>A note from the creator</p>
        <Heading as="h1" className={styles.title}>
          Why I built Lattice
        </Heading>
        <p className={styles.byline}>Rahul, creator of Lattice</p>

        <div className={styles.body}>
          <p className={styles.lead}>
            Lattice started as a series I wrote on martinfowler.com,{' '}
            <Link href="https://martinfowler.com/articles/reduce-friction-ai/">
              Patterns for Reducing Friction in AI-Assisted Development
            </Link>
            . Five patterns that are, individually, just good sense. What I kept watching was teams read the
            series, try one pattern for a sprint, and quietly drop it the moment a deadline got tight. The ideas
            were never the problem. Nothing was holding them in place day to day, so that&apos;s what I built.
          </p>

          <p>
            Lattice takes the discipline I&apos;ve spent my career building as an engineer: drive the right
            requirement first, design before touching a keyboard, write code inside real architectural and quality
            guardrails, then review it from a perspective that isn&apos;t the one that just wrote it. I wired that
            directly into the agentic SDLC, so it isn&apos;t advice you have to remember to apply. It&apos;s a set
            of skills the assistant actually runs, every time.
          </p>

          <p>
            It ships opinionated: Clean Architecture, DDD, secure coding, test quality, all pre-picked. But no
            team is stuck with mine. Refiners walk you through a guided interview to encode your own standards, so
            the guardrails become your team&apos;s guardrails, versioned and PR-reviewed like any other code. It
            also gets out of your way as you go: the more of your team&apos;s standards get encoded, the less the
            AI has to stop and ask, because there&apos;s less genuine ambiguity left to ask about.
          </p>
        </div>

        <Heading as="h2" className={styles.sectionHeading}>
          Where I want your feedback
        </Heading>
        <p className={styles.feedbackIntro}>I&apos;m more interested in the seams than the happy path:</p>
        <ul className={styles.feedbackList}>
          <li>Does the design step earn the time it costs on a real feature, or does it feel like ceremony mid-sprint?</li>
          <li>Are the shipped defaults the right opinions for your stack, or the wrong ones dressed up as best practice?</li>
          <li>Does encoding your own standards through a refiner feel natural, or does it feel like fighting the framework?</li>
          <li>If you&apos;re running Lattice on Cursor, Codex, or another host, does it feel native there, or does it feel ported?</li>
        </ul>
        <p className={styles.feedbackIntro}>
          I&apos;d rather hear &ldquo;this step is friction, here&apos;s why&rdquo; than &ldquo;looks
          great.&rdquo; Tell me on{' '}
          <Link href="https://github.com/techygarg/lattice/discussions">GitHub Discussions</Link>. That&apos;s
          where I&apos;m watching.
        </p>

        <Heading as="h2" className={styles.sectionHeading}>
          One thing to try
        </Heading>
        <div className={styles.callout}>
          <p className={styles.calloutTitle}>Before you write a line of code</p>
          <p className={styles.calloutText}>
            Run <span className={styles.commandChip}>/design-blueprint</span> on your next real feature. It puts
            the AI in the seat of a design partner, not a code generator: five levels of design, ending in an
            actual artifact you approve before any coding agent touches the keyboard. Hand that blueprint to{' '}
            <span className={styles.commandChip}>/code-forge</span> next. That handoff, approving the design
            before a single line of code gets written, is where Lattice actually starts. It&apos;s the step most
            people skip, and the one worth trying for yourself first.
          </p>
        </div>

        <p className={styles.closing}>Try it on something real, not a toy, and tell me where it breaks.</p>
        <p className={styles.signOff}>— Rahul</p>

        <div className={styles.ctaRow}>
          <Link className={styles.primaryButton} to="https://github.com/techygarg/lattice/discussions">
            Give feedback on Discussions ↗
          </Link>
          <Link className={styles.secondaryButton} to="/docs/how-it-works">
            See how it works
          </Link>
        </div>

        <div className={styles.continueLinks}>
          <Link to="/docs/origin">Read the full design rationale →</Link>
          <Link to="https://github.com/techygarg/lattice">Browse the repo ↗</Link>
        </div>
      </main>
    </Layout>
  );
}
