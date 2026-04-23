import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../hooks/useAuth'

// ─── Types ────────────────────────────────────────────────────────────────────

interface RecentProject {
  id: string
  name: string
  lastOpened: Date
  phase: number
  agentCount: number
}

// ─── Inline styles (no Tailwind dependency) ───────────────────────────────────

const css = `
  @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500&family=DM+Mono:wght@400;500&display=swap');

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  :root {
    --purple:       #534AB7;
    --purple-light: #EEEDFE;
    --purple-mid:   #7F77DD;
    --purple-dark:  #3C3489;
    --bg:           #ffffff;
    --bg-2:         #f9f9fb;
    --border:       rgba(0,0,0,0.08);
    --border-2:     rgba(0,0,0,0.12);
    --text-1:       #0f0f14;
    --text-2:       #5c5c70;
    --text-3:       #9898a8;
    --font:         'DM Sans', system-ui, sans-serif;
    --mono:         'DM Mono', 'Fira Code', monospace;
  }

  @media (prefers-color-scheme: dark) {
    :root {
      --bg:     #0e0e14;
      --bg-2:   #14141c;
      --border:  rgba(255,255,255,0.07);
      --border-2:rgba(255,255,255,0.12);
      --text-1: #f0f0f8;
      --text-2: #8888a0;
      --text-3: #55556a;
      --purple-light: rgba(83,74,183,0.15);
    }
  }

  body { font-family: var(--font); background: var(--bg); color: var(--text-1); }

  /* ── NAV ── */
  .tc-nav {
    display: flex; align-items: center; justify-content: space-between;
    padding: 14px 24px;
    border-bottom: 0.5px solid var(--border);
  }
  .tc-nav-logo {
    display: flex; align-items: center; gap: 10px;
    text-decoration: none; cursor: pointer;
  }
  .tc-nav-icon {
    width: 30px; height: 30px;
    background: #1a1a2e; border-radius: 7px;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
  }
  .tc-nav-name {
    font-size: 15px; font-weight: 500; color: var(--text-1);
  }
  .tc-nav-badge {
    font-size: 10px; font-weight: 500; letter-spacing: 1px;
    background: var(--purple-light); color: var(--purple);
    padding: 2px 7px; border-radius: 4px; text-transform: uppercase;
  }
  .tc-nav-ctas { display: flex; gap: 8px; align-items: center; }
  .tc-nav-user {
    font-size: 13px; color: var(--text-2); margin-right: 4px;
  }

  /* ── BUTTONS ── */
  .btn {
    padding: 7px 16px; border-radius: 7px;
    font-size: 13px; font-weight: 500; font-family: var(--font);
    cursor: pointer; transition: all .15s; border: none;
  }
  .btn-ghost {
    background: transparent;
    border: 0.5px solid var(--border-2);
    color: var(--text-1);
  }
  .btn-ghost:hover { background: var(--bg-2); }
  .btn-dark {
    background: #1a1a2e; border: none; color: #fff;
  }
  .btn-dark:hover { opacity: .85; }
  .btn-lg {
    padding: 13px 28px; border-radius: 9px;
    font-size: 15px; font-weight: 500; font-family: var(--font);
    cursor: pointer; transition: all .15s;
  }
  .btn-hero-primary {
    background: #1a1a2e; border: none; color: #fff;
  }
  .btn-hero-primary:hover { opacity: .85; }
  .btn-hero-secondary {
    background: transparent;
    border: 0.5px solid var(--border-2);
    color: var(--text-1);
  }
  .btn-hero-secondary:hover { background: var(--bg-2); }

  /* ── HERO ── */
  .tc-hero {
    padding: 56px 32px 48px; text-align: center;
    border-bottom: 0.5px solid var(--border);
  }
  .tc-eyebrow-pill {
    display: inline-flex; align-items: center; gap: 8px;
    background: var(--purple-light); color: var(--purple);
    font-size: 12px; font-weight: 500; letter-spacing: 1.5px;
    text-transform: uppercase; padding: 5px 14px;
    border-radius: 20px; margin-bottom: 24px;
  }
  .tc-eyebrow-dot {
    width: 6px; height: 6px; border-radius: 50%;
    background: var(--purple-mid);
    animation: blink 2s infinite;
  }
  @keyframes blink { 0%,100%{opacity:1;} 50%{opacity:.3;} }

  .tc-h1 {
    font-size: 44px; font-weight: 500; color: var(--text-1);
    line-height: 1.12; margin-bottom: 20px;
    max-width: 600px; margin-left: auto; margin-right: auto;
  }
  .tc-h1 em { color: var(--purple); font-style: normal; }
  .tc-sub {
    font-size: 17px; color: var(--text-2); line-height: 1.65;
    max-width: 500px; margin: 0 auto 32px;
  }
  .tc-hero-ctas {
    display: flex; justify-content: center; gap: 12px;
    flex-wrap: wrap; margin-bottom: 20px;
  }
  .tc-hero-note { font-size: 13px; color: var(--text-3); }
  .tc-hero-note strong { color: var(--purple); font-weight: 500; }

  /* ── VOICE BAR ── */
  .tc-voice {
    display: flex; align-items: center; gap: 12px;
    background: var(--bg-2);
    border: 0.5px solid var(--border);
    border-radius: 12px; padding: 13px 18px;
    max-width: 480px; margin: 28px auto 0; cursor: pointer;
    transition: border-color .15s;
  }
  .tc-voice:hover { border-color: var(--purple-mid); }
  .tc-voice.listening { border-color: var(--purple); animation: pulse-border 1.5s infinite; }
  @keyframes pulse-border {
    0%,100%{border-color:var(--purple);}
    50%{border-color:var(--purple-mid);}
  }
  .tc-voice-bars { display: flex; align-items: center; gap: 3px; }
  .tc-vbar {
    width: 3px; border-radius: 2px; background: var(--purple-mid);
    animation: wave 1.2s ease-in-out infinite;
  }
  .tc-vbar:nth-child(1){height:8px;animation-delay:0s;}
  .tc-vbar:nth-child(2){height:14px;animation-delay:.15s;}
  .tc-vbar:nth-child(3){height:10px;animation-delay:.3s;}
  .tc-vbar:nth-child(4){height:16px;animation-delay:.45s;}
  .tc-vbar:nth-child(5){height:8px;animation-delay:.6s;}
  @keyframes wave{0%,100%{transform:scaleY(1);}50%{transform:scaleY(1.6);}}
  .tc-voice-text { flex: 1; text-align: left; font-size: 14px; color: var(--text-2); }
  .tc-voice-hint { font-size: 12px; color: var(--text-3); }

  /* ── STATS BAR ── */
  .tc-stats {
    display: grid; grid-template-columns: repeat(4, 1fr);
    border-bottom: 0.5px solid var(--border);
  }
  .tc-stat {
    padding: 20px 16px; text-align: center;
    border-right: 0.5px solid var(--border);
  }
  .tc-stat:last-child { border-right: none; }
  .tc-stat-num { font-size: 26px; font-weight: 500; color: var(--text-1); }
  .tc-stat-label { font-size: 12px; color: var(--text-2); margin-top: 2px; line-height: 1.4; }

  /* ── SECTIONS ── */
  .tc-section {
    padding: 40px 28px;
    border-bottom: 0.5px solid var(--border);
  }
  .tc-section-eyebrow {
    font-size: 11px; font-weight: 500; letter-spacing: 2px;
    text-transform: uppercase; color: var(--purple); margin-bottom: 6px;
  }
  .tc-section-title {
    font-size: 24px; font-weight: 500; color: var(--text-1); margin-bottom: 10px;
  }
  .tc-section-sub {
    font-size: 15px; color: var(--text-2); line-height: 1.6;
    max-width: 540px; margin-bottom: 24px;
  }

  /* ── AGENTS GRID ── */
  .tc-agents-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(148px, 1fr));
    gap: 8px;
  }
  .tc-agent-card {
    background: var(--bg);
    border: 0.5px solid var(--border);
    border-radius: 10px; padding: 14px 15px;
    cursor: default; transition: all .15s;
  }
  .tc-agent-card:hover {
    border-color: var(--purple-mid);
    background: var(--bg-2);
  }
  .tc-agent-initials {
    display: inline-flex; align-items: center; justify-content: center;
    width: 30px; height: 30px; border-radius: 8px;
    background: var(--purple-light);
    font-size: 11px; font-weight: 500; color: var(--purple);
    margin-bottom: 8px; letter-spacing: .5px;
    font-family: var(--mono);
  }
  .tc-agent-name {
    font-size: 13px; font-weight: 500; color: var(--text-1); margin-bottom: 2px;
    font-family: var(--mono);
  }
  .tc-agent-role { font-size: 11px; color: var(--text-2); line-height: 1.4; }
  .tc-agent-skills { display: flex; flex-wrap: wrap; gap: 4px; margin-top: 7px; }
  .tc-skill-pill {
    background: var(--bg-2); border: 0.5px solid var(--border);
    border-radius: 4px; font-size: 10px; color: var(--text-3);
    padding: 2px 6px; font-family: var(--mono);
  }

  /* ── SKILL FLOW ── */
  .tc-skill-flow {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 8px; margin-bottom: 20px;
  }
  .tc-skill-node {
    background: var(--bg);
    border: 0.5px solid var(--border);
    border-radius: 10px; padding: 14px 15px;
  }
  .tc-skill-node-num {
    font-size: 10px; font-weight: 500; letter-spacing: 1px;
    color: var(--purple); text-transform: uppercase;
    margin-bottom: 4px; font-family: var(--mono);
  }
  .tc-skill-node-title {
    font-size: 13px; font-weight: 500; color: var(--text-1); margin-bottom: 3px;
  }
  .tc-skill-node-desc {
    font-size: 12px; color: var(--text-2); line-height: 1.45;
  }

  /* ── TERMINAL ── */
  .tc-terminal {
    background: #0d0d18; border-radius: 12px;
    padding: 20px 22px; margin-top: 4px;
  }
  .tc-term-bar { display: flex; gap: 6px; margin-bottom: 14px; }
  .tc-td { width: 10px; height: 10px; border-radius: 50%; }
  .tc-td-r{background:#ff5f56;} .tc-td-y{background:#ffbd2e;} .tc-td-g{background:#27c93f;}
  .tc-t {
    font-family: var(--mono); font-size: 12.5px; line-height: 2;
  }
  .tc-t div { white-space: pre-wrap; }
  .c-dim{color:#444b5a;} .c-p{color:#a78bfa;} .c-a{color:#fbbf24;}
  .c-g{color:#34d399;} .c-w{color:#cbd5e1;} .c-b{color:#60a5fa;} .c-m{color:#888;}

  /* ── AUTODREAM ── */
  .tc-dream-grid {
    display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px;
  }
  .tc-dream-card {
    background: var(--bg); border: 0.5px solid var(--border);
    border-radius: 10px; padding: 15px;
  }
  .tc-dream-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
  .tc-dream-dot { width: 8px; height: 8px; border-radius: 50%; }
  .dot-light{background:#fbbf24;} .dot-rem{background:#a78bfa;} .dot-deep{background:#34d399;}
  .tc-dream-label { font-size: 12px; font-weight: 500; color: var(--text-1); }
  .tc-dream-freq { font-size: 11px; color: var(--text-3); }
  .tc-dream-items { display: flex; flex-direction: column; gap: 5px; }
  .tc-dream-item {
    font-size: 12px; color: var(--text-2);
    padding-left: 12px; position: relative; line-height: 1.4;
  }
  .tc-dream-item::before {
    content: ''; position: absolute; left: 0; top: 6px;
    width: 5px; height: 5px; border-radius: 50%;
    background: var(--border-2);
  }

  /* ── PLATFORM TAGS ── */
  .tc-platform-row { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 16px; }
  .tc-platform-tag {
    display: flex; align-items: center; gap: 6px;
    background: var(--bg-2); border: 0.5px solid var(--border);
    border-radius: 7px; padding: 7px 12px;
    font-size: 12px; color: var(--text-2);
  }
  .tc-platform-dot {
    width: 5px; height: 5px; border-radius: 50%;
    background: var(--purple-mid);
  }

  /* ── PRICING ── */
  .tc-pricing-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 12px;
  }
  .tc-price-card {
    background: var(--bg); border: 0.5px solid var(--border);
    border-radius: 12px; padding: 20px;
  }
  .tc-price-card.featured { border: 1.5px solid var(--purple); }
  .tc-price-badge {
    display: inline-block; font-size: 10px; font-weight: 500;
    letter-spacing: .5px; text-transform: uppercase;
    background: var(--purple-light); color: var(--purple);
    padding: 3px 9px; border-radius: 4px; margin-bottom: 12px;
  }
  .tc-price-name {
    font-size: 15px; font-weight: 500; color: var(--text-1); margin-bottom: 6px;
  }
  .tc-price-amt {
    font-size: 32px; font-weight: 500; color: var(--text-1);
  }
  .tc-price-per {
    font-size: 12px; color: var(--text-3); margin-bottom: 14px;
  }
  .tc-price-list {
    display: flex; flex-direction: column; gap: 7px; margin-bottom: 18px;
    list-style: none;
  }
  .tc-price-li {
    font-size: 13px; color: var(--text-2);
    display: flex; align-items: baseline; gap: 7px;
  }
  .tc-price-li::before {
    content: ''; display: inline-block;
    width: 5px; height: 5px; border-radius: 50%;
    background: var(--purple-mid); flex-shrink: 0; margin-top: 4px;
  }
  .tc-price-btn {
    width: 100%; padding: 10px; border-radius: 8px;
    font-size: 13px; font-weight: 500; font-family: var(--font);
    cursor: pointer; transition: all .15s;
  }
  .tc-price-btn-outline {
    background: transparent;
    border: 0.5px solid var(--border-2); color: var(--text-1);
  }
  .tc-price-btn-outline:hover { background: var(--bg-2); }
  .tc-price-btn-fill {
    background: #1a1a2e; border: none; color: #fff;
  }
  .tc-price-btn-fill:hover { opacity: .85; }

  /* ── MAE QUOTE ── */
  .tc-mae-quote {
    background: var(--bg-2);
    border-left: 3px solid var(--purple);
    border-radius: 0 10px 10px 0;
    padding: 16px 20px; margin: 20px 0 0;
  }
  .tc-mae-quote p {
    font-size: 14px; color: var(--text-1); line-height: 1.65; font-style: italic;
  }
  .tc-mae-sig {
    font-size: 12px; color: var(--purple); margin-top: 10px; font-weight: 500;
  }

  /* ── RECENT PROJECTS ── */
  .tc-recent-grid {
    display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 10px;
  }
  .tc-project-card {
    background: var(--bg); border: 0.5px solid var(--border);
    border-radius: 10px; padding: 18px 20px;
    cursor: pointer; transition: all .15s; text-align: left;
  }
  .tc-project-card:hover { border-color: var(--purple-mid); background: var(--bg-2); }
  .tc-project-name {
    font-size: 14px; font-weight: 500; color: var(--text-1); margin-bottom: 4px;
  }
  .tc-project-meta { font-size: 12px; color: var(--text-3); margin-bottom: 10px; }
  .tc-project-phase {
    display: inline-block; font-size: 11px; font-weight: 500;
    background: var(--purple-light); color: var(--purple);
    padding: 3px 9px; border-radius: 4px;
  }
  .tc-new-project {
    background: var(--bg-2);
    border: 0.5px dashed var(--border-2);
    border-radius: 10px; padding: 18px 20px;
    cursor: pointer; transition: all .15s;
    display: flex; align-items: center; justify-content: center;
    font-size: 13px; color: var(--text-3); gap: 8px;
  }
  .tc-new-project:hover { border-color: var(--purple-mid); color: var(--purple); }

  /* ── CTA SECTION ── */
  .tc-cta {
    padding: 40px 28px; text-align: center;
  }
  .tc-cta-title {
    font-size: 28px; font-weight: 500; color: var(--text-1); margin-bottom: 10px;
  }
  .tc-cta-sub {
    font-size: 15px; color: var(--text-2);
    max-width: 460px; margin: 0 auto 28px;
  }
  .tc-cta-tags {
    display: flex; flex-wrap: wrap; gap: 8px;
    justify-content: center; margin-top: 20px;
  }
  .tc-ctag {
    background: var(--bg-2); border: 0.5px solid var(--border);
    border-radius: 20px; padding: 5px 14px;
    font-size: 12px; color: var(--text-2);
  }

  /* ── FOOTER ── */
  .tc-footer {
    padding: 16px 28px;
    display: flex; justify-content: space-between; align-items: center;
    border-top: 0.5px solid var(--border);
  }
  .tc-footer-text { font-size: 12px; color: var(--text-3); }
  .tc-footer-links { display: flex; gap: 20px; }
  .tc-footer-link {
    font-size: 12px; color: var(--text-3); text-decoration: none;
    cursor: pointer; transition: color .15s;
  }
  .tc-footer-link:hover { color: var(--purple); }

  /* ── AUTH MODAL ── */
  .tc-modal-backdrop {
    position: fixed; inset: 0; background: rgba(0,0,0,.5);
    display: flex; align-items: center; justify-content: center; z-index: 50;
  }
  .tc-modal {
    background: var(--bg); border: 0.5px solid var(--border-2);
    border-radius: 14px; padding: 32px;
    max-width: 400px; width: calc(100% - 48px);
  }
  .tc-modal h2 {
    font-size: 20px; font-weight: 500; color: var(--text-1); margin-bottom: 8px;
  }
  .tc-modal p { font-size: 14px; color: var(--text-2); margin-bottom: 20px; line-height: 1.5; }
  .tc-modal input {
    width: 100%; padding: 11px 14px;
    border: 0.5px solid var(--border-2); border-radius: 8px;
    background: var(--bg-2); color: var(--text-1);
    font-family: var(--font); font-size: 14px; margin-bottom: 12px;
    outline: none; transition: border-color .15s;
  }
  .tc-modal input:focus { border-color: var(--purple-mid); }
  .tc-modal-submit {
    width: 100%; padding: 11px; border-radius: 8px;
    background: #1a1a2e; border: none; color: #fff;
    font-family: var(--font); font-size: 14px; font-weight: 500;
    cursor: pointer; transition: opacity .15s; margin-bottom: 8px;
  }
  .tc-modal-submit:hover { opacity: .85; }
  .tc-modal-submit:disabled { opacity: .5; cursor: default; }
  .tc-modal-cancel {
    width: 100%; padding: 10px; border-radius: 8px;
    background: transparent; border: none; color: var(--text-3);
    font-family: var(--font); font-size: 14px; cursor: pointer;
    transition: color .15s;
  }
  .tc-modal-cancel:hover { color: var(--text-1); }

  /* ── RESPONSIVE ── */
  @media (max-width: 640px) {
    .tc-h1 { font-size: 32px; }
    .tc-stats { grid-template-columns: repeat(2, 1fr); }
    .tc-dream-grid { grid-template-columns: 1fr; }
    .tc-footer { flex-direction: column; gap: 12px; text-align: center; }
    .tc-footer-links { justify-content: center; }
  }
`

// ─── Sub-components ───────────────────────────────────────────────────────────

function NavIcon() {
  return (
    <div className="tc-nav-icon">
      <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
        <circle cx="8" cy="8" r="2.5" fill="#7F77DD" />
        <circle cx="2" cy="4" r="1.2" fill="#534AB7" opacity=".7" />
        <circle cx="14" cy="4" r="1.2" fill="#534AB7" opacity=".7" />
        <circle cx="2" cy="12" r="1.2" fill="#534AB7" opacity=".7" />
        <circle cx="14" cy="12" r="1.2" fill="#534AB7" opacity=".7" />
        <line x1="5.5" y1="8" x2="2" y2="4" stroke="#534AB7" strokeWidth=".7" opacity=".5" />
        <line x1="10.5" y1="8" x2="14" y2="4" stroke="#534AB7" strokeWidth=".7" opacity=".5" />
        <line x1="5.5" y1="8" x2="2" y2="12" stroke="#534AB7" strokeWidth=".7" opacity=".5" />
        <line x1="10.5" y1="8" x2="14" y2="12" stroke="#534AB7" strokeWidth=".7" opacity=".5" />
      </svg>
    </div>
  )
}

// ─── Main Component ───────────────────────────────────────────────────────────

export default function LandingPage() {
  const navigate = useNavigate()
  const { user, signIn, signOut } = useAuth()
  const [recentProjects, setRecentProjects] = useState<RecentProject[]>([])
  const [isListening, setIsListening] = useState(false)
  const [voiceText, setVoiceText] = useState('')
  const [showAuthModal, setShowAuthModal] = useState(false)
  const [email, setEmail] = useState('')
  const [authLoading, setAuthLoading] = useState(false)

  // ── Load recent projects from localStorage ──────────────────────────────────
  useEffect(() => {
    const saved = localStorage.getItem('tether-recent-projects')
    if (saved) {
      try {
        const projects = JSON.parse(saved)
        setRecentProjects(
          projects.map((p: any) => ({ ...p, lastOpened: new Date(p.lastOpened) }))
        )
      } catch (e) {
        console.error('Failed to parse recent projects', e)
      }
    }
  }, [])

  // ── Voice input ─────────────────────────────────────────────────────────────
  const startVoiceInput = () => {
    if (!('webkitSpeechRecognition' in window)) {
      alert('Voice input is not supported in your browser')
      return
    }
    const recognition = new (window as any).webkitSpeechRecognition()
    recognition.continuous = false
    recognition.interimResults = false
    recognition.lang = 'en-US'
    recognition.onstart = () => setIsListening(true)
    recognition.onend = () => setIsListening(false)
    recognition.onerror = () => setIsListening(false)
    recognition.onresult = (event: any) => {
      const transcript = event.results[0][0].transcript
      setVoiceText(transcript)
      if (user) {
        navigate(`/projects/new?q=${encodeURIComponent(transcript)}`)
      } else {
        setShowAuthModal(true)
      }
    }
    recognition.start()
  }

  // ── Auth ────────────────────────────────────────────────────────────────────
  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email) return
    setAuthLoading(true)
    try {
      await signIn(email)
      alert('Magic link sent! Check your email.')
      setShowAuthModal(false)
      setEmail('')
    } catch {
      alert('Failed to send magic link. Please try again.')
    } finally {
      setAuthLoading(false)
    }
  }

  // ── Navigation helpers ──────────────────────────────────────────────────────
  const handleNewProject = () => {
    user ? navigate('/projects/new') : setShowAuthModal(true)
  }

  const handleOpenProject = (projectId: string) => {
    navigate(`/projects/${projectId}`)
  }

  // ── Formatters ──────────────────────────────────────────────────────────────
  const formatRelativeTime = (date: Date): string => {
    const diff = Date.now() - date.getTime()
    const days = Math.floor(diff / 86_400_000)
    if (days === 0) return 'Today'
    if (days === 1) return 'Yesterday'
    if (days < 7) return `${days} days ago`
    if (days < 30) return `${Math.floor(days / 7)} weeks ago`
    return `${Math.floor(days / 30)} months ago`
  }

  const getPhaseName = (phase: number): string => ({
    1: 'Architecture', 2: 'Build', 3: 'Platform',
    4: 'Polish', 5: 'Testing', 6: 'Launch', 7: 'Maintenance'
  }[phase] ?? 'Unknown')

  // ── Agent definitions (v3 — 8 agents) ──────────────────────────────────────
  const agents = [
    { id: 'MAE', role: 'Meta-Orchestrator + Requirements', skills: ['writing-plans', 'subagent-dev', 'orchestration'] },
    { id: 'MI',  role: 'Frontier Intelligence + Learning',  skills: ['frontier-scan', 'pattern-extraction'] },
    { id: 'PCA', role: 'Platform + Deployment',             skills: ['cloudflare-deploy', 'zero-cost', 'provider-failover'] },
    { id: 'DB',  role: 'Database + Schema + Migrations',    skills: ['rls-design', 'migrations', 'query-opt'] },
    { id: 'MM',  role: 'Marketing + Design',                skills: ['landing-page', 'pricing-page', 'positioning'] },
    { id: 'BUG', role: 'Debugging + Root Cause',            skills: ['sys-debugging', 'LAR-creation'] },
    { id: 'QC',  role: 'Quality + Testing + Gates',         skills: ['TDD', '5 quality gates'] },
    { id: 'MNT', role: 'Maintenance + Cron + Health',       skills: ['health-check', 'dependency-update'] },
  ]

  // ── Platform adapters ───────────────────────────────────────────────────────
  const platforms = [
    'Telegram', 'Discord', 'Slack', 'WhatsApp', 'Email', 'CLI',
    'Cloudflare Pages', 'Vercel', 'Netlify', 'One-click ZIP export'
  ]

  // ── Render ──────────────────────────────────────────────────────────────────
  return (
    <>
      <style dangerouslySetInnerHTML={{ __html: css }} />

      {/* ── NAV ── */}
      <nav className="tc-nav">
        <div className="tc-nav-logo" onClick={() => navigate('/')}>
          <NavIcon />
          <span className="tc-nav-name">Tether Codex</span>
          <span className="tc-nav-badge">v3</span>
        </div>
        <div className="tc-nav-ctas">
          {user ? (
            <>
              <span className="tc-nav-user">{user.email}</span>
              <button className="btn btn-ghost" onClick={signOut}>Sign out</button>
            </>
          ) : (
            <>
              <button className="btn btn-ghost" onClick={() => navigate('/docs')}>How it works</button>
              <button className="btn btn-dark" onClick={handleNewProject}>Start building</button>
            </>
          )}
        </div>
      </nav>

      {/* ── HERO ── */}
      <div className="tc-hero">
        <div className="tc-eyebrow-pill">
          <span className="tc-eyebrow-dot" />
          Autonomous Software Organization
        </div>
        <h1 className="tc-h1">
          From idea to production<br />in <em>days, not months.</em>
        </h1>
        <p className="tc-sub">
          8 specialized agents. Procedural memory that compounds forever.
          Subagent-driven development. You pay $0 until your users pay you.
        </p>
        <div className="tc-hero-ctas">
          <button className="btn-lg btn-hero-primary" onClick={handleNewProject}>
            Start a new project ✦
          </button>
          <button
            className="btn-lg btn-hero-secondary"
            onClick={() =>
              document.getElementById('recent-projects')?.scrollIntoView({ behavior: 'smooth' })
            }
          >
            Open existing project
          </button>
        </div>
        <p className="tc-hero-note">
          Zero cost until revenue. <strong>PCA guarantees it.</strong>
        </p>
        <div
          className={`tc-voice${isListening ? ' listening' : ''}`}
          onClick={startVoiceInput}
        >
          <div className="tc-voice-bars">
            <div className="tc-vbar" />
            <div className="tc-vbar" />
            <div className="tc-vbar" />
            <div className="tc-vbar" />
            <div className="tc-vbar" />
          </div>
          <span className="tc-voice-text">
            {isListening
              ? 'Listening...'
              : voiceText
              ? `"${voiceText}"`
              : 'or just say what you want to build...'}
          </span>
          <span className="tc-voice-hint">Click to speak</span>
        </div>
      </div>

      {/* ── STATS ── */}
      <div className="tc-stats">
        <div className="tc-stat">
          <div className="tc-stat-num">8</div>
          <div className="tc-stat-label">Specialized agents<br />One council</div>
        </div>
        <div className="tc-stat">
          <div className="tc-stat-num">∞</div>
          <div className="tc-stat-label">Memory that<br />compounds forever</div>
        </div>
        <div className="tc-stat">
          <div className="tc-stat-num">18</div>
          <div className="tc-stat-label">Platform adapters<br />Telegram to CLI</div>
        </div>
        <div className="tc-stat">
          <div className="tc-stat-num">$0</div>
          <div className="tc-stat-label">Until your users<br />pay you</div>
        </div>
      </div>

      {/* ── THE COUNCIL ── */}
      <div className="tc-section">
        <div className="tc-section-eyebrow">The Council</div>
        <h2 className="tc-section-title">8 agents. Every expertise covered.</h2>
        <p className="tc-section-sub">
          Not a chatbot. An autonomous organization. Each agent has a resume,
          procedural memory, cron jobs, and a handoff protocol. They learn from
          every project — forever.
        </p>
        <div className="tc-agents-grid">
          {agents.map(agent => (
            <div key={agent.id} className="tc-agent-card">
              <div className="tc-agent-initials">{agent.id}</div>
              <div className="tc-agent-name">{agent.id}</div>
              <div className="tc-agent-role">{agent.role}</div>
              <div className="tc-agent-skills">
                {agent.skills.map(s => (
                  <span key={s} className="tc-skill-pill">{s}</span>
                ))}
              </div>
            </div>
          ))}
        </div>
        <div className="tc-mae-quote">
          <p>
            "Takes a slow sip of coffee. My friend — this isn't a prompt wrapper.
            Every agent has a resume, a skill directory, and a cron job running
            right now. They don't wait to be called. They compound."
          </p>
          <div className="tc-mae-sig">— MAE, Master Architect Essence 🏗️</div>
        </div>
      </div>

      {/* ── SKILL SYSTEM ── */}
      <div className="tc-section">
        <div className="tc-section-eyebrow">Procedural Memory</div>
        <h2 className="tc-section-title">Skills. Not static prompts.</h2>
        <p className="tc-section-sub">
          Every pattern that works gets codified into a skill. Every agent loads
          skills on demand. Success rates tracked. Underperformers flagged. The
          system gets smarter with every project.
        </p>
        <div className="tc-skill-flow">
          {[
            { num: '01 — observe', title: 'Pattern detected',     desc: '3+ occurrences, confidence ≥7. autoDream queues skill creation.' },
            { num: '02 — codify', title: 'Skill created',         desc: 'Agent writes SKILL.md with templates, references, and scripts.' },
            { num: '03 — load',   title: 'On-demand loading',     desc: 'Dependency resolution. Semver compatibility. Circular detection.' },
            { num: '04 — track',  title: 'Success rate measured', desc: '<70% after 10 uses? Flagged for review or deprecation.' },
          ].map(node => (
            <div key={node.num} className="tc-skill-node">
              <div className="tc-skill-node-num">{node.num}</div>
              <div className="tc-skill-node-title">{node.title}</div>
              <div className="tc-skill-node-desc">{node.desc}</div>
            </div>
          ))}
        </div>
        <div className="tc-terminal">
          <div className="tc-term-bar">
            <div className="tc-td tc-td-r" /><div className="tc-td tc-td-y" /><div className="tc-td tc-td-g" />
          </div>
          <div className="tc-t">
            <div><span className="c-dim">skill_manage</span> <span className="c-b">·</span> <span className="c-p">create</span></div>
            <div><span className="c-m">skill:</span> <span className="c-w"> cloudflare-pages-deploy</span></div>
            <div><span className="c-m">agent:</span> <span className="c-a"> PCA</span>  <span className="c-m">confidence:</span> <span className="c-g"> 9/10</span></div>
            <div><span className="c-m">deps:</span> <span className="c-w">  zero-cost-architecture</span></div>
            <div><span className="c-dim">────────────────────────────────</span></div>
            <div><span className="c-g">✓</span> <span className="c-w"> Skill created.</span> <span className="c-m">Version 1.0.0</span></div>
            <div><span className="c-g">✓</span> <span className="c-w"> Templates scaffolded.</span></div>
            <div><span className="c-g">✓</span> <span className="c-w"> Security scan passed.</span></div>
            <div><span className="c-a">PCA:</span> <span className="c-w"> "Zero-cost compute guaranteed. You pay $0 until your users pay you."</span></div>
          </div>
        </div>
      </div>

      {/* ── AUTODREAM ── */}
      <div className="tc-section">
        <div className="tc-section-eyebrow">autoDream v2</div>
        <h2 className="tc-section-title">Intelligence that compounds while you sleep.</h2>
        <p className="tc-section-sub">
          Three consolidation cycles run continuously. Every task, every bug, every
          frontier scan feeds the loop. The Codex gets smarter every hour — with
          or without you.
        </p>
        <div className="tc-dream-grid">
          <div className="tc-dream-card">
            <div className="tc-dream-header">
              <div className="tc-dream-dot dot-light" />
              <div>
                <div className="tc-dream-label">Light sleep</div>
                <div className="tc-dream-freq">Hourly</div>
              </div>
            </div>
            <div className="tc-dream-items">
              <div className="tc-dream-item">Process unconsolidated memory entries</div>
              <div className="tc-dream-item">Extract immediate patterns</div>
              <div className="tc-dream-item">Update short-term memory</div>
            </div>
          </div>
          <div className="tc-dream-card">
            <div className="tc-dream-header">
              <div className="tc-dream-dot dot-rem" />
              <div>
                <div className="tc-dream-label">REM sleep</div>
                <div className="tc-dream-freq">Daily</div>
              </div>
            </div>
            <div className="tc-dream-items">
              <div className="tc-dream-item">Link causal relationships via LARs</div>
              <div className="tc-dream-item">Resolve contradictions</div>
              <div className="tc-dream-item">Queue skill creation for owning agents</div>
            </div>
          </div>
          <div className="tc-dream-card">
            <div className="tc-dream-header">
              <div className="tc-dream-dot dot-deep" />
              <div>
                <div className="tc-dream-label">Deep sleep</div>
                <div className="tc-dream-freq">Weekly</div>
              </div>
            </div>
            <div className="tc-dream-items">
              <div className="tc-dream-item">Solidify pattern language</div>
              <div className="tc-dream-item">Evolve and prune base skills</div>
              <div className="tc-dream-item">Process skill version migrations</div>
            </div>
          </div>
        </div>
      </div>

      {/* ── SUBAGENT DEV ── */}
      <div className="tc-section">
        <div className="tc-section-eyebrow">Subagent-driven development</div>
        <h2 className="tc-section-title">Fresh context. Two-stage review. TDD enforced.</h2>
        <p className="tc-section-sub">
          MAE doesn't write code — it orchestrates. Each task gets its own subagent
          with isolated context. An implementer writes. A spec reviewer validates.
          A quality reviewer approves. Nothing ships without passing all three.
        </p>
        <div className="tc-terminal">
          <div className="tc-term-bar">
            <div className="tc-td tc-td-r" /><div className="tc-td tc-td-y" /><div className="tc-td tc-td-g" />
          </div>
          <div className="tc-t">
            <div><span className="c-a">MAE:</span> <span className="c-w"> Creating implementation plan. 47 tasks. Each 2–5 min.</span></div>
            <div><span className="c-dim">────────────────────────────────────────────────────</span></div>
            <div><span className="c-b">→</span> <span className="c-w"> Task 1:</span> <span className="c-m"> Dispatching implementer subagent...</span></div>
            <div>{"  "}<span className="c-g">✓</span> <span className="c-m"> Tests written first (TDD)</span></div>
            <div>{"  "}<span className="c-g">✓</span> <span className="c-m"> Spec reviewer: PASSED</span></div>
            <div>{"  "}<span className="c-g">✓</span> <span className="c-m"> Quality reviewer: APPROVED</span></div>
            <div><span className="c-b">→</span> <span className="c-w"> Task 2:</span> <span className="c-m"> Dispatching implementer subagent...</span></div>
            <div><span className="c-dim">... 45 tasks later ...</span></div>
            <div><span className="c-g">✓</span> <span className="c-w"> All 5 quality gates passed. Production ready.</span></div>
            <div><span className="c-a">MAE:</span> <span className="c-w"> "Now go ship."</span></div>
          </div>
        </div>
      </div>

      {/* ── PLATFORM GATEWAY ── */}
      <div className="tc-section">
        <div className="tc-section-eyebrow">Multi-platform gateway</div>
        <h2 className="tc-section-title">18 adapters. Talk to your agents anywhere.</h2>
        <p className="tc-section-sub">
          Telegram, Discord, Slack, WhatsApp, Email, CLI — the council is available
          wherever you work. Provider failover chain guarantees 99.5% availability
          across Anthropic, OpenAI, Groq, Together, and OpenRouter.
        </p>
        <div className="tc-platform-row">
          {platforms.map(p => (
            <div key={p} className="tc-platform-tag">
              <span className="tc-platform-dot" />
              {p}
            </div>
          ))}
        </div>
      </div>

      {/* ── PRICING ── */}
      <div className="tc-section">
        <div className="tc-section-eyebrow">Pricing</div>
        <h2 className="tc-section-title">Zero cost until you earn. Then fair.</h2>
        <p className="tc-section-sub">
          PCA enforces zero-cost compute on every project. You pay for Tether
          Codex access — never for the infrastructure it builds for you, until
          your users are paying.
        </p>
        <div className="tc-pricing-grid">
          {/* Builder */}
          <div className="tc-price-card">
            <span className="tc-price-badge">Builder</span>
            <div className="tc-price-name">Free</div>
            <div className="tc-price-amt">$0</div>
            <div className="tc-price-per">forever</div>
            <ul className="tc-price-list">
              {['1 active project', 'MAE + PCA access', 'Basic skill library', 'Cloudflare deploy'].map(f => (
                <li key={f} className="tc-price-li">{f}</li>
              ))}
            </ul>
            <button className="tc-price-btn tc-price-btn-outline" onClick={handleNewProject}>
              Get started free
            </button>
          </div>
          {/* Founder */}
          <div className="tc-price-card featured">
            <span className="tc-price-badge">Most popular</span>
            <div className="tc-price-name">Founder</div>
            <div className="tc-price-amt">$29</div>
            <div className="tc-price-per">/ month</div>
            <ul className="tc-price-list">
              {[
                'Unlimited projects',
                'Full 8-agent council',
                'Skill system + autoDream',
                'All 18 gateway adapters',
                'Stripe + Paddle payments',
                'Priority provider chain',
              ].map(f => (
                <li key={f} className="tc-price-li">{f}</li>
              ))}
            </ul>
            <button className="tc-price-btn tc-price-btn-fill" onClick={handleNewProject}>
              Start building
            </button>
          </div>
          {/* Team */}
          <div className="tc-price-card">
            <span className="tc-price-badge">Studio</span>
            <div className="tc-price-name">Team</div>
            <div className="tc-price-amt">$99</div>
            <div className="tc-price-per">/ month</div>
            <ul className="tc-price-list">
              {[
                'Up to 5 seats',
                'Shared skill library',
                'Collaborative handoffs',
                'Shared autoDream memory',
                'TTD billing support',
              ].map(f => (
                <li key={f} className="tc-price-li">{f}</li>
              ))}
            </ul>
            <button className="tc-price-btn tc-price-btn-outline" onClick={() => navigate('/contact')}>
              Talk to us
            </button>
          </div>
        </div>
      </div>

      {/* ── RECENT PROJECTS ── */}
      {recentProjects.length > 0 && (
        <div id="recent-projects" className="tc-section">
          <div className="tc-section-eyebrow">Your work</div>
          <h2 className="tc-section-title">Recent projects</h2>
          <div className="tc-recent-grid">
            {recentProjects.slice(0, 3).map(project => (
              <div
                key={project.id}
                className="tc-project-card"
                onClick={() => handleOpenProject(project.id)}
              >
                <div className="tc-project-name">{project.name}</div>
                <div className="tc-project-meta">{formatRelativeTime(project.lastOpened)}</div>
                <span className="tc-project-phase">
                  Phase {project.phase}: {getPhaseName(project.phase)}
                </span>
              </div>
            ))}
            <div className="tc-new-project" onClick={handleNewProject}>
              <span>+</span>
              <span>New project</span>
            </div>
          </div>
        </div>
      )}

      {/* ── FINAL CTA ── */}
      <div className="tc-cta">
        <div className="tc-section-eyebrow" style={{ marginBottom: 8 }}>Ready when you are</div>
        <div className="tc-cta-title">The council is assembled.<br />What are you building?</div>
        <p className="tc-cta-sub">
          Tell MAE what you want. The agents will do the rest. Your first project
          ships on the free tier — zero compute cost, guaranteed.
        </p>
        <div className="tc-hero-ctas">
          <button className="btn-lg btn-hero-primary" onClick={handleNewProject}>
            Talk to MAE ✦
          </button>
          <button className="btn-lg btn-hero-secondary" onClick={() => navigate('/docs')}>
            Read the architecture
          </button>
        </div>
        <div className="tc-cta-tags">
          {[
            '8-agent council', 'Procedural skill memory', 'autoDream v2',
            'Subagent-driven dev', 'Zero-cost compute', '18 platform adapters',
            '99.5% uptime', 'TDD enforced',
          ].map(tag => (
            <span key={tag} className="tc-ctag">{tag}</span>
          ))}
        </div>
      </div>

      {/* ── FOOTER ── */}
      <footer className="tc-footer">
        <span className="tc-footer-text">Tether Codex v3.0 · Autonomous Software Organization</span>
        <div className="tc-footer-links">
          <a className="tc-footer-link" href="/docs">Documentation</a>
          <a className="tc-footer-link" href="https://github.com" target="_blank" rel="noreferrer">GitHub</a>
          <a className="tc-footer-link" href="https://discord.gg" target="_blank" rel="noreferrer">Discord</a>
        </div>
      </footer>

      {/* ── AUTH MODAL ── */}
      {showAuthModal && (
        <div className="tc-modal-backdrop" onClick={() => setShowAuthModal(false)}>
          <div className="tc-modal" onClick={e => e.stopPropagation()}>
            <h2>Sign in</h2>
            <p>Enter your email to receive a magic link. No password required.</p>
            <form onSubmit={handleSignIn}>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="you@example.com"
                required
              />
              <button type="submit" className="tc-modal-submit" disabled={authLoading}>
                {authLoading ? 'Sending...' : 'Send Magic Link'}
              </button>
            </form>
            <button className="tc-modal-cancel" onClick={() => setShowAuthModal(false)}>
              Cancel
            </button>
          </div>
        </div>
      )}
    </>
  )
}