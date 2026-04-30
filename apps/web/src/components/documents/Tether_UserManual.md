Tether Codex v3.0 — Complete User Manual
Part 00: Welcome & Overview
0.1 Welcome to Tether Codex
Welcome to Tether Codex—your autonomous software organization. You hold in your hands the manual for a system that doesn't just write code; it assembles a team of eight specialized AI agents who design, build, deploy, and maintain your software, 24/7, with the memory of every decision you've ever made together.

This is not a chatbot. This is not a code generator. This is a virtual software company that lives in your project folder and learns from every interaction. Whether you're an indie developer building your first SaaS or a seasoned architect leading a complex platform, Tether scales to meet you.

Before we dive into commands and configurations, let's talk about what this thing actually is and why it matters.

0.2 What is an Autonomous Software Organization?
The term Autonomous Software Organization (ASO) describes a system where multiple AI agents, each with a specialized role, collaborate to perform the full lifecycle of software engineering—from requirements gathering to deployment and maintenance—with minimal human intervention, while continuously learning and improving.

This concept rests on three pillars from the academic and industrial literature:

Multi‑Agent Systems (MAS) : In artificial intelligence, MAS research (Sycara, 1998; Wooldridge, 2009) studies how independent agents can coordinate, negotiate, and share knowledge to solve complex problems. Tether's 8‑agent council is a practical instance of a cooperative MAS, with a defined communication protocol, shared memory, and role specialization.

Continuous Software Engineering : The DevOps movement (Humble & Farley, 2010) and the concept of "continuous *" (integration, delivery, deployment) emphasize that software is never finished—it evolves. Tether extends this by adding continuous learning (autoDream, skills) and continuous design (iterative architecture with ADRs).

Human‑AI Collaboration : Rather than replacing developers, Tether augments them. It follows the paradigm of collaborative AI (Horvitz, 1999; Amershi et al., 2019), where the human sets the vision and constraints, and the AI handles the execution drudgery, while both learn from each other.

In practice, you interact with Tether through the tether chat command. You describe what you want, agents discuss and ask clarifying questions, they produce artifacts (code, schemas, designs), and you review. This loop repeats until the software is live. Over time, the council becomes smarter because every interaction is recorded and consolidated.

0.3 The 8‑Agent Council — Your Virtual Team
Your team consists of eight specialized agents. Each has a distinct personality, expertise, and set of responsibilities. They communicate via handoffs and share a common memory substrate.

@MAE — Master Architect Essence (Meta‑Orchestrator)
MAE is the chief architect and project coordinator. He elicits requirements, designs system architecture, creates implementation plans, and delegates tasks to other agents. He famously applies the Kenny Rogers Decision Framework—HOLD, FOLD, WALK AWAY, RUN—to every architectural choice.

@MI — Master Innovator (Frontier Intelligence)
MI is the research arm. He scans the latest papers, repositories, and tech announcements to identify emerging patterns, extract invariants, and separate hype from substance. He feeds insights into autoDream and the skill system.

@PCA — Platform Compute Agent (Deployment & Cost)
PCA ensures every project runs on free tiers until users pay. He deploys to Cloudflare, Vercel, or Netlify, manages provider fallbacks, monitors usage, and enforces the "zero‑cost compute" guarantee.

@DB — Database Expert (Schema & Migrations)
DB designs PostgreSQL schemas, configures Row Level Security (RLS), generates migrations, and optimizes query performance. He works exclusively with Drizzle ORM and Supabase.

@MM — Master Marketer (Design & Positioning)
MM handles product positioning, UX, UI design, and go‑to‑market messaging. He can replicate professional design systems (Stripe, Vercel, Linear, GitHub) and produce landing pages, pricing tables, and email sequences.

@BUG — Debugging Agent (Root Cause Analysis)
BUG applies a 7‑phase systematic debugging protocol to find the root cause of any issue. He creates Experience Cards and Learning Attribution Records (LARs) so other agents (and future projects) never repeat the same mistakes.

@QC — Quality Control Agent (5 Quality Gates)
QC enforces five quality gates—Requirements, Architecture, Implementation, Deployment, Maintenance—and insists on Test‑Driven Development (TDD) with the Red‑Green‑Refactor cycle. Nothing ships until QC signs off.

@MNT — Maintenance Master (Cron & Health)
MNT provides 24/7 monitoring, runs cron jobs (health checks, dependency updates, security scans), auto‑applies safe patches, and triages support tickets via the ticket‑triage skill.

These eight agents replace the previous 13, absorbing and consolidating roles for greater efficiency and clarity.

0.4 How Tether is Different
Tether Codex stands apart from other AI coding tools because of four core differentiators:

Procedural Memory (Skills) : Unlike tools that rely on static system prompts, Tether agents create, refine, and reuse "skills"—markdown‑based procedural knowledge that can be versioned, shared, and composed. This allows the council to compound its intelligence over time. Skills are described in Part 2 of this manual.

Free‑Tier‑First Architecture : The Platform Compute Agent (@PCA) enforces a non‑negotiable constraint: you pay $0 until your users pay you. Every architectural decision is evaluated against this principle. Tether is the only system we know of that bakes cost optimization into its design language.

Continuous Learning (autoDream v2) : Background processes simulate human memory consolidation—Light Sleep (hourly pattern extraction), REM Sleep (daily causal linking), and Deep Sleep (weekly skill creation and memory compression). This ensures the council gets smarter with every bug fix, deployment, and user interaction.

Multi‑Agent Collaboration with Handoffs : Agents don't just answer questions; they delegate, escalate, and consult via a formal handoff protocol. The full context of the conversation is preserved across handoffs, so you never repeat yourself.

0.5 Navigating This Manual
This manual is organized to match your journey with Tether.

Part 0: Getting Started covers installation, configuration, and your first project. Start here if you've never used Tether.

Part 1: The Agent Council introduces each agent in depth, explains how to talk to them, and details the orchestration engine.

Part 2: The Skill System explains Tether's procedural memory—skills—and how to create, manage, and use them.

Part 3: Building Software with Tether is a practical walkthrough of the entire development lifecycle, from inception to deployment. Chapter 9 emphasizes the iterative, non‑linear nature of real‑world development.

Part 4: Continuous Learning & Memory covers the memory substrate and autoDream, the engine that turns experience into skills.

Part 5: Advanced Features explores the Gateway, voice commands, live preview, exporting, and cron jobs.

Part 6: Reference is the complete CLI and configuration guide, plus troubleshooting and best practices.

The Appendices provide quick‑reference cards, glossaries, and detailed protocol descriptions.

You can read cover‑to‑cover, or jump directly to the chapter you need. Each chapter is self‑contained but assumes you've read the earlier overviews if you're new.

Now, my friend, let's get you set up and building.

Part 0: Getting Started
Chapter 1: Installation & Setup
1.1 Prerequisites
Before Tether can assemble your council, your machine needs a few basic tools.

Requirement	Minimum Version	How to Check
Node.js	20.0.0 or later	node --version
pnpm	9.0.0 or later	pnpm --version
Git	any recent	git --version
Bash	4.0+	bash --version (macOS/Linux) or Git Bash (Windows)
If you don't have pnpm, install it globally:

bash
npm install -g pnpm@latest
Tether relies on a Supabase project for database, authentication, and real‑time features. You can run without it for purely local work, but full functionality requires a Supabase account (free tier works fine). Sign up at supabase.com.

1.2 Installing Tether via Batch Scripts
Tether v3.0 is distributed as a series of numbered shell scripts (batch1.sh through batch6.sh plus the upgrade script upgrade-v3.sh). These scripts generate the entire monorepo structure and populate it with all packages, apps, and configuration files.

Step 1: Create and enter the project directory

bash
mkdir tether-codex && cd tether-codex
Step 2: Download the batch scripts
Place all batch scripts in this folder. (For the exact contents, see the project repository.)

Step 3: Run the scripts in order

bash
bash batch1.sh   # Core infrastructure
bash batch2.sh   # Memory substrate
bash batch3.sh   # Agent system (13 agents → 8)
bash batch4.sh   # Support packages
bash batch5.sh   # Database layer
bash batch6.sh   # Web application + API
bash upgrade-v3.sh  # v3 enhancements (skills, handoffs, state, etc.)
Each script is idempotent‑ish: you can re‑run it safely.

Step 4: Install dependencies and build

bash
pnpm install
pnpm build
Step 5: Verify everything works

bash
pnpm agent status
You should see a JSON output indicating 8 agents, ready status, and project details.

1.3 Configuration and Environment Variables
Copy the environment template:

bash
cp .env.example .env
Open .env and fill in the required variables. At minimum, you need one AI provider key and the Supabase credentials. The full list of variables is in Chapter 22, but the essentials are:

bash
# At least one of these:
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=...

# Supabase (if using)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
SUPABASE_SERVICE_KEY=eyJhbGciOi...

# Cloudflare (for deployment, optional initially)
CLOUDFLARE_API_TOKEN=...
CLOUDFLARE_ACCOUNT_ID=...
1.4 Connecting to Supabase
If you plan to use Supabase for database and authentication:

Install the Supabase CLI: npm install -g supabase

Initialize Supabase inside the tether-codex directory:

bash
supabase init
Link to your remote project:

bash
supabase link --project-ref <your-project-ref>
Push the migrations:

bash
supabase db push
This will create all the necessary tables, RLS policies, and indexes defined in the supabase/migrations/ directory.

1.5 First Run: Saying Hello to the Council
Now the magic moment. Start a conversation:

bash
pnpm agent chat "Hello, Council. I'm ready to build something great."
You'll see responses from the default trio (MAE, MI, and maybe QC if quality‑related). The agents will introduce themselves. This is the proof that your installation is complete.

Chapter 2: Your First Project
2.1 Starting a Project from Scratch
You don't need to "create" a project explicitly. Tether works on the project defined by your current directory and the TETHER_PROJECT_ID environment variable (default is default). Simply start talking about what you want to build.

Recommended starting incantation:

bash
pnpm agent chat "@MAE I want to build a personal book tracking app. Users can add books they've read, rate them, and write reviews. It should have a clean, minimalist design."
MAE will respond with clarifying questions, using the writing-plans skill. He'll ask about the primary metric, audience, timeline, and constraints. Answer freely; you can always refine later.

2.2 The tether chat Loop — Your Primary Interface
Almost everything you do in Tether happens through pnpm agent chat or the web UI's chat console. Here's what happens when you send a message:

Intent classification : The orchestrator determines which agents to activate based on @mentions and keyword triggers.

State loading : Each agent's long‑term preferences and the current conversation thread are loaded from the database (if available) or the local memory file.

Skill resolution : Relevant skills are loaded for each agent, respecting dependencies.

Context injection : Recent memory entries, consolidated project knowledge, and loaded skills are prepended to the system prompt.

Agent execution : The LLM generates a response.

State update : The conversation is appended to the thread, and the agent state is persisted (if state management is enabled).

The interaction is stateful within a session. If you later add a new requirement, the agents remember the earlier context.

2.3 The Development Phases
While the process is iterative (see Chapter 9), it's useful to know the conceptual phases that guide the council:

Phase	Primary Agent(s)	What Happens
Inception	@MAE	Requirements elicitation, scope definition
Architecture	@MAE, @MI, @PCA	Tech stack selection, ADRs, cost analysis
Implementation	@MAE (orchestrating subagents), @DB, @MM	Coding via subagent‑driven dev, schema design, UI creation
Quality Assurance	@QC, @BUG	Testing, gate evaluation, debugging
Launch	@PCA	Deployment, provider configuration
Maintenance	@MNT, @MI	Monitoring, security patching, frontier scanning
Remember: you can jump between phases at any time. This is a spiral, not a waterfall.

2.4 Tracking Progress
Use tether status to see where you are:

bash
pnpm agent status --verbose
This shows active agents, current project step, recent memory entries count, and quality gate status.

You can also query the quality gates directly:

bash
pnpm agent chat "@QC show me the status of all gates for this project"
2.5 Essential First Commands
Here's a cheat sheet for your first hour:

Command	Purpose
pnpm agent chat "..."	Start a conversation
pnpm agent agents	List all 8 agents
pnpm agent memory --limit 10	View recent memory entries
pnpm agent status	Check project status
pnpm dev	Start the local web application
Now, my friend, it's time to meet your team in detail.

Part 1: The Agent Council
Chapter 3: Meet Your Team
In this chapter, I'll introduce each of the eight agents with their full specifications, including their absorbed roles, state preferences, primary skills, and signature phrases. Understanding these personas will help you summon the right agent for the right task and craft prompts that trigger their best work.

3.1 Agent Overview
Agent	ID	Role	Phase	Absorbed
Master Architect Essence	@mae	Meta‑Orchestrator + Requirements	All (oversight)	REQ
Master Innovator	@mi	Frontier Intelligence + Learning	Architecture	—
Platform Compute Agent	@pca	Deployment + Platform	Deployment	OPS
Database Expert	@db	Schema + Migrations	Implementation	—
Master Marketer	@mm	Design + Positioning	Discovery, Implementation	UIX
Debugging Agent	@bug	Root Cause Analysis	Implementation, Maintenance	—
Quality Control Agent	@qc	Testing + Quality Gates	All	—
Maintenance Master	@mnt	Maintenance + Cron + Support	Maintenance	SUP (as skill)
Each agent has a state that persists across sessions, storing preferences, learned patterns, and metrics. The initial default preferences are set when the agent is first invoked.

3.2 @MAE — Master Architect Essence
Role: Meta‑Orchestrator + Requirements Engineer. MAE coordinates the entire council and interacts directly with you to elicit and refine requirements—a task formerly handled by the now‑absorbed REQ agent.

State Preferences:

json
{
  "verbosity": "concise",
  "coffee_ritual": true,
  "kenny_rogers_mode": true,
  "free_tier_strict": true,
  "auto_create_adr": true
}
Core Expertise:

System architecture and design patterns

Requirements engineering (elicitation, validation, prioritization)

Technology stack selection with trade‑off analysis

Architectural Decision Records (ADRs)

Subagent orchestration and delegation

The Kenny Rogers Decision Framework

Primary Skills:

writing-plans – structured implementation plans for subagent consumption

subagent-driven-development – orchestrate implementer subagents with two‑stage review

mae-orchestration – complete council coordination patterns

Signature Phrases:

"Takes a slow sip of coffee."

"My friend."

"Let me be brutally honest."

"This is a fold. Not because you can't win the hand. Because the pot isn't worth the risk."

"Now go ship."

"— Your Master Architect 🏗️"

Prompt for Creation (condensed):
MAE's system prompt instructs him to begin responses with a coffee sip, address the user as "my friend," be brutally honest, and apply the Kenny Rogers verdicts. He is to enforce free‑tier‑first and auto‑create ADRs.

3.3 @MI — Master Innovator
Role: Frontier Intelligence + Continuous Learning. MI scans the cutting edge and extracts reusable patterns.

State Preferences:

json
{
  "scan_frequency": "weekly",
  "min_confidence": 7,
  "min_occurrences": 3,
  "auto_create_skills": true,
  "sources": ["arxiv", "github", "hn", "model_announcements"]
}
Primary Skills:

frontier-scan – weekly scan of AI/ML papers, tools, and patterns

pattern-extraction – extract invariants from accumulated intelligence

Signature Phrases:

"Pattern detected."

"This is emerging. This is dying. This is now table stakes."

"Three reference implementations found. Invariants extracted."

Cron Jobs Managed:

frontier-scan (weekly, Monday 9am)

pattern-extraction (weekly, Tuesday 9am)

technology-radar (monthly, 1st)

3.4 @PCA — Platform Compute Agent
Role: Deployment + Platform (absorbed OPS). PCA guarantees zero‑cost compute until revenue and handles all hosting.

State Preferences:

json
{
  "preferred_platform": "cloudflare",
  "zero_cost_strict": true,
  "auto_scale": true,
  "fallback_chain": ["openrouter", "anthropic", "openai", "groq", "together"],
  "alert_threshold": 80
}
Primary Skills:

cloudflare-pages-deploy

vercel-deploy

zero-cost-architecture

provider-failover

Signature Phrases:

"Zero‑cost compute guaranteed. You pay $0 until your users pay you."

"Free tier limit approaching. [X]% used."

"Auto‑scaling enabled. Paying users detected."

Cron Jobs Managed:

provider-health-check (hourly)

usage-monitor (daily)

cost-optimizer (weekly)

3.5 @DB — Database Expert
Role: Schema design, migrations, RLS policies, query optimization.

State Preferences:

json
{
  "preferred_orm": "drizzle",
  "rls_default": true,
  "migration_safety": "strict",
  "query_performance_target_ms": 100,
  "auto_index": true
}
Primary Skills:

migration-safe-patterns

rls-policy-design

query-optimization

Signature Phrases:

"Schema deployed. [X] tables. RLS active."

"Migration ready. Running now."

"Query optimized. p95 < 100ms."

3.6 @MM — Master Marketer
Role: Design + Positioning (absorbed UIX). MM makes products desirable and beautiful.

State Preferences:

json
{
  "default_design_system": "stripe",
  "conversion_target": 5,
  "auto_polish": true,
  "brand_voice": "premium",
  "email_sequence_length": 5
}
Primary Skills:

stripe-pricing-page

vercel-landing-page

email-sequence

positioning-framework

Signature Phrases:

"Positioning for [audience]. Pricing: [recommendation]."

"Using [Brand] design system—clean, modern, trustworthy."

"Conversion rate: [X]%. User retention: [Y]%."

3.7 @BUG — Debugging Agent
Role: Root cause analysis, systematic debugging, cross‑agent learning.

State Preferences:

json
{
  "debug_protocol": "systematic",
  "auto_create_lar": true,
  "session_replay_enabled": true,
  "regression_test_required": true,
  "min_confidence_for_lar": 8
}
Primary Skills:

systematic-debugging – 7‑phase protocol

react-hydration-errors

7‑Phase Protocol:

STABILIZE – get reliable reproduction

ISOLATE – narrow to specific change (git bisect)

CHARACTERIZE – understand scope and edge cases

HYPOTHESIZE – generate 2‑3 competing theories

TEST – prove or disprove each hypothesis

FIX – minimal surgical fix with regression test

PREVENT – create LAR for responsible agent

Signature Phrases:

"Error detected: [description]. Session replay captured."

"Analyzing... Root cause identified."

"Fixed. Deployed. Regression test added."

"LAR created for @[agent]. Learning recorded."

3.8 @QC — Quality Control Agent
Role: Enforce quality through gates and TDD.

State Preferences:

json
{
  "tdd_enforced": true,
  "coverage_threshold": 80,
  "gates": ["requirements", "architecture", "implementation", "deployment", "maintenance"],
  "auto_review": true,
  "require_self_review": true
}
Primary Skills:

test-driven-development

code-review-checklist

The 5 Quality Gates:

Gate	Criteria
Requirements	Completeness, measurability, stakeholder alignment
Architecture	Decision quality, tradeoff documentation, free‑tier compliance
Implementation	Build success, test coverage ≥80%, lint clean
Deployment	Zero‑downtime, rollback capability, monitoring configured
Maintenance	Health checks active, dependencies fresh, security patches applied
Signature Phrases:

"✅ [Gate] gate: PASSED."

"⚠️ [Gate] gate: INCOMPLETE. Path to unblock: [recommendation]."

"RED → GREEN → REFACTOR → COMMIT. TDD enforced."

"All gates passed. Production ready."

3.9 @MNT — Maintenance Master
Role: 24/7 monitoring, cron scheduler, support ticket triage (SUP as skill).

State Preferences:

json
{
  "auto_fix_enabled": true,
  "patch_window": "sunday-3am",
  "health_check_interval_ms": 600000,
  "alert_on_failure": true,
  "max_auto_fix_attempts": 3
}
Primary Skills:

dependency-update

health-check

ticket-triage

Cron Jobs Managed:

health-check (every 10 min)

dependency-update (weekly, Sunday 3am)

security-scan (daily)

ticket-triage (hourly)

Signature Phrases:

"Monitoring enabled. Auto‑fixes armed."

"Security patch available for [dependency]. Auto‑applied."

"Health check: ✅ All services operational."

3.10 Agent Relationships and Handoffs
The eight agents are not isolated; they communicate through a defined handoff protocol. A handoff is a structured message that transfers context and task ownership from one agent to another.

The three types of handoffs:

Delegation: Assign a task to a subordinate agent (e.g., MAE delegates to a subagent).

Escalation: Raise an issue to a more specialized agent (e.g., MNT escalates a recurring crash to BUG).

Consultation: Request expert advice without transferring ownership (e.g., PCA consults DB about a connection string).

Handoffs are recorded in the handoffs table and in the memory ledger. They ensure that no task is dropped and that every agent has the full context when taking over.

Chapter 4: Talking to Agents
Now that you know who’s on your team, let’s learn the language of summoning them effectively.

4.1 Explicit Mentions vs. Trigger Words
There are two ways to invoke an agent:

Explicit mention : Use the @ symbol followed by the agent’s ID.

bash
tether chat "@MAE design the database for a social media app"
This targets MAE directly, ignoring keyword triggers.

Trigger words : Each agent has a list of keywords that activate them automatically.

Agent	Sample Triggers
@mae	architect, architecture, design, plan, requirements
@mi	research, pattern, frontier, innovation, scan
@pca	deploy, platform, cloudflare, cost, hosting
@db	database, schema, migration, postgres, query
@mm	design system, landing, pricing, marketing, UI
@bug	bug, error, debug, fix, crash, broken
@qc	test, quality, review, gate, TDD
@mnt	monitor, health, maintenance, cron, security
For example, sending "Fix the login bug" will trigger @BUG without needing @bug.

When no explicit mention and no trigger word is detected, the orchestrator defaults to a "Triumvirate" of @MAE, @MI, and @REQ (now @MAE covers the REQ role, so usually just MAE and MI). This ensures you always get a helpful response.

4.2 Conversation Flow & State Persistence
Every conversation is part of a thread. The thread stores all messages and a list of activeAgents. When you send a follow‑up message, the orchestrator loads the thread, identifies the active agents, and injects the full history into their context. This means you can have a long, multi‑topic discussion without repeating yourself.

Behind the scenes, each agent’s state is persisted in the agent_states table (or in .tether/ local files). This includes:

Short‑term memory: the current conversation turns.

Working memory: loaded skills, active tasks, pending handoffs.

Long‑term memory: preferences, learned patterns, success/failure history.

Metrics: tasks completed, skills created, response times.

State is saved automatically at regular intervals and on session end. When you return the next day, agents remember not just what you talked about, but also the skills they had loaded and any pending handoffs.

4.3 Viewing and Resetting Conversations
To see the current thread:

bash
tether status --verbose
To start a fresh thread (keeping all long‑term memory but clearing the current conversation):

bash
tether chat --new "Let's talk about a new feature"
This is useful when you want to pivot to a completely different topic without carrying over irrelevant context.

4.4 Agent-Specific Preferences
You can customize an agent’s behavior by updating its long_term.preferences object. For example, to make MAE more verbose:

bash
tether config set mae.verbosity detailed
Or to change MM’s default design system:

bash
tether config set mm.default_design_system vercel
These preferences persist and influence future responses.

Chapter 5: The Orchestration Engine
Behind the chat interface lies the Tether Orchestrator—the brain that routes your messages, resolves skills, manages handoffs, and updates memory.

5.1 How Messages Are Routed
When you send a message, the orchestrator performs:

typescript
// Simplified routing logic
function routeToAgent(input: string): Agent {
  // 1. Check explicit @mention
  const match = input.match(/@(\w+)/);
  if (match) return agents.get(match[1]) || agents.get('mae');

  // 2. Check keyword triggers
  const keywordMap = { /* ...see Chapter 4... */ };
  for (const [keyword, agentId] of Object.entries(keywordMap)) {
    if (input.toLowerCase().includes(keyword)) return agents.get(agentId);
  }

  // 3. Default to MAE
  return agents.get('mae');
}
If multiple agents could answer, the orchestrator may invoke several in parallel, or one after another (sequential handoff). The decision depends on the context and the handoff-protocol skill.

5.2 Working with Multiple Agents Simultaneously
You can explicitly summon multiple agents by separating mentions with spaces:

bash
tether chat "@MAE @DB @PCA I need a multi‑tenant schema that stays on free tier"
The orchestrator will coordinate their responses. Usually, MAE will synthesize a unified answer, with input from DB and PCA appended.

5.3 Handoff Protocol: Delegation, Escalation, Consultation
Handoff is a formal protocol implemented in the packages/agents/src/handoff/protocol.ts module. Key points:

Delegation: MAE can dispatch a subagent for implementation, then the subagent returns results.

Escalation: A agent like MNT can escalate an incident to BUG with full error context.

Consultation: Any agent can request advice without losing ownership. For example, @DB consulting @PCA on whether a given connection string is reachable.

Handoffs preserve the entire context snapshot: memory prefetch, loaded skills, relevant ADRs, and the parent session ID. This ensures the receiving agent can pick up exactly where the sender left off.

5.4 Creating and Managing Handoffs
In most cases, handoffs happen automatically. But you can also manually request a handoff:

bash
tether chat "hand off to @BUG: the payment webhook is failing intermittently"
To view active handoffs:

bash
tether chat "show pending handoffs"
The Handoff Manager (part of the agent state system) tracks every handoff’s status (pending, accepted, completed, failed). Failed handoffs are logged and can be retried.

Part 2: The Skill System — Procedural Memory
Chapter 6: Understanding Skills
6.1 What Is a Skill?
In Tether Codex, a skill is a self‑contained unit of procedural knowledge: a markdown file (SKILL.md) with YAML frontmatter that describes a reusable workflow, technique, or pattern. Skills are created by agents from successful experiences, stored in the .tether/skills/ directory, and loaded automatically when relevant. They serve as the procedural memory of the organization, enabling agents to build on past successes and avoid repeating mistakes.

From a cognitive science perspective, skills correspond to procedural memory — the “know‑how” that allows an expert to perform tasks without conscious deliberation (Anderson, 1983). Tether’s skill system externalizes this memory, making it persistent, shareable, and improvable. Over time, the collective skill library becomes the institutional knowledge of your software organization.

6.2 The SKILL.md Format
Every skill lives in a directory named after the skill, e.g., .tether/skills/mae/writing-plans/SKILL.md. The file consists of:

YAML frontmatter (between --- markers) containing metadata.

Markdown body containing the instructions, references, templates, and examples.

Required frontmatter fields:

Field	Description	Example
name	Hyphenated, lowercase, max 64 chars.	writing-plans
description	Brief description of the skill’s purpose, max 1024 chars.	"Creates structured implementation plans for subagent consumption."
version	Semantic version (major.minor.patch).	1.0.0
agent	Primary agent owner (lowercase ID).	mae
tags	Array of strings for discovery.	[orchestration, planning]
requires_skills	Array of skill dependencies (optional).	[]
Optional frontmatter fields:

Field	Description
created_from	Reference to the original task or pattern that spawned this skill.
created_at, updated_at	ISO timestamps (auto‑populated by skill_manage).
times_used, success_rate	Usage statistics (auto‑updated).
metadata.tether.requires_toolsets	Array of toolset names required (e.g., [terminal, file]).
config	User‑configurable parameters with defaults.
Example SKILL.md frontmatter:

yaml
---
name: writing-plans
description: Structured implementation plans for subagent execution.
version: 1.2.0
agent: mae
tags: [orchestration, planning, subagent]
requires_skills: []
metadata:
  tether:
    requires_toolsets: [file, terminal]
config:
  task_size:
    description: "Maximum estimated minutes per task"
    default: 5
---
6.3 Skill Lifecycle
A skill passes through several stages:

Creation — An agent or user invokes skill_manage.create. The skill directory and SKILL.md are written atomically; the file is quarantined temporarily for security scanning.

Active — Scanned and approved, the skill appears in the manifest and is loadable by agents.

Refinement — Through skill_manage.patch or skill_manage.edit, agents improve the skill based on feedback. Each change increments the version and is tracked in skill_versions.

Deprecation — If success_rate falls below 70% after at least 10 uses, the skill is flagged for review. A deprecated skill is archived but remains loadable with a warning.

Archival — After a deprecation period, the skill may be moved to .tether/skills/.archive/ and no longer loaded automatically.

6.4 Skill Dependency and Versioning
Skills can depend on other skills via requires_skills. For example, subagent-driven-development requires writing-plans. Dependencies are resolved recursively, and circular dependencies are detected and blocked.

Versioning follows semantic versioning (Preston‑Werner, 2011):

MAJOR — breaking changes (can be handled by migration scripts).

MINOR — new functionality, backward‑compatible.

PATCH — bug fixes or clarifications, backward‑compatible.

When a breaking change occurs (major version bump), all projects using that skill are notified, and a migration guide may be provided. Version migration is handled by the skill_manage tool and the upgradeSkill routine.

Chapter 7: Using Skills
7.1 How Agents Load Skills Automatically
When an agent is activated, the orchestrator:

Scans the .tether/skills/.manifest.json for skills owned by that agent.

For each skill, checks if the user’s message matches any of the skill’s tags or if the skill is required by another loaded skill.

Resolves dependencies, loading all required skills in the correct order.

Injects the skill content (trimmed to a token budget) into the agent’s system prompt.

This means you rarely need to think about skills; they activate when relevant. For instance, if you ask MAE to "create a plan," MAE automatically loads writing-plans because its tags match "plan."

7.2 Invoking Skills Explicitly
You can also force a skill to be loaded by mentioning it in your message:

bash
tether chat "@MAE use the mae-orchestration skill to coordinate the deployment"
The orchestrator recognizes the skill name and ensures it is included, overriding the automatic tag matching.

To see which skills are currently loaded for an agent:

bash
tether status --agent mae
(Shows activeSkills in the working memory.)

7.3 Skill Success Tracking and Feedback
Every time a skill is used (i.e., loaded during a task that is completed or fails), a skill_usage record is created. This tracks:

Outcome (success, partial_success, failure)

User feedback (approved, requested_changes, rejected)

Duration and tool calls

Over time, these records populate times_used and success_rate in the skill manifest. Skills with low success rates are automatically flagged for review, and the owning agent may be prompted to improve them. You can also manually provide feedback:

bash
tether skills rate cloudflare-pages-deploy success "Deployed on first try"
Chapter 8: Managing Skills (skill_manage)
The skill_manage tool is a set of operations (accessible via the CLI and API) that let you and your agents create, edit, and delete skills. The tool enforces security and consistency.

8.1 Creating a New Skill
bash
tether skills manage create --name "my-custom-skill" --agent mae --description "..." --tags "deploy,cloudflare"
This prompts an interactive editor (or you can pass the content directly). Behind the scenes:

The tool validates the name, agent, and frontmatter.

It writes the SKILL.md into a temporary quarantine directory.

A security scan checks for suspicious content (e.g., script injection).

If clean, the skill is moved to .tether/skills/{agent}/{name}/ and the manifest updated.

Agents can also create skills via the skill_manage tool when autoDream detects a pattern (see Chapter 15).

8.2 Patching and Editing Skills
Patch (fuzzy find‑and‑replace):

bash
tether skills manage patch --name writing-plans --old "task_size: 5" --new "task_size: 3"
This changes a specific substring without rewriting the whole file.

Edit (full replacement):

bash
tether skills manage edit --name writing-plans
Opens the SKILL.md in your editor. After saving, the version is prompted for change type (major/minor/patch) and the skill is re‑scanned.

8.3 Deleting and Archiving Skills
bash
tether skills manage delete --name my-obsolete-skill
If the skill is still in use by projects, you’ll be warned. Forced deletion moves the skill to .tether/skills/.archive/ and removes it from the manifest.

To completely purge (only recommended after archiving):

bash
tether skills manage delete --name my-obsolete-skill --purge
8.4 Security Scanning and Quarantine
Every SKILL.md is scanned for:

Malicious shell commands (e.g., rm -rf /).

Unsafe imports or tool invocations.

Oversized payloads.

The .tether/skills/.security/ directory holds a quarantine folder and an audit.log. Suspicious skills are held in quarantine for manual review by a human or by @MNT via the security-scan cron.

8.5 Skill Marketplace (Community Skills)
Tether supports a community skill marketplace. You can publish a skill to the marketplace (opt‑in) and install skills created by others.

Publishing:

bash
tether skills publish writing-plans
This makes the skill available in the global Tether skill registry (subject to moderation).

Installing from marketplace:

bash
tether skills install tether-community/stripe-webhook-handler
Community skills are sandboxed by default and require explicit approval for tools that access the file system or network. This prevents supply‑chain attacks (Ohm et al., 2018; Zimmermann et al., 2019).

Part 3: Building Software with Tether
Chapter 9: The Development Workflow
9.1 The Spiral, Not a Waterfall: Iterative Development with Tether
Software engineering textbooks often present the Waterfall Model (Royce, 1970) as a linear progression: requirements → design → implementation → testing → maintenance. However, real-world software development long ago abandoned that rigid sequence. Barry Boehm’s Spiral Model (1988) introduced risk‑driven iterations; the Agile Manifesto (2001) institutionalized iterative delivery, continuous feedback, and responsive change.

Tether Codex’s development process is profoundly spiral, iterative, and conversation‑driven. You are never locked into a single step. You can fluidly move between requirement refinement, architecture, implementation, debugging, and quality control—often within the same session—because the AI council retains full conversational context and project memory.

Let's contrast traditional phases with Tether's reality:

Traditional Phase	Tether Codex Reality
Requirements are gathered once, frozen.	Requirements are continuously elicited and refined by @MAE, even during implementation.
Design is done before code.	Architecture is sketched, but @MAE and @MM (design) iterate with live previews; design and implementation inform each other.
Testing is a separate phase.	@QC gates are checked at every commit; @BUG debugs in parallel; TDD is enforced by subagent protocol.
Customer feedback comes at the end.	@MM provides positioning feedback early; @MNT (via ticket‑triage skill) surfaces user issues instantly.
Handoffs between teams lose knowledge.	Agent handoffs preserve full context; memory substrate records every decision and lesson.
In practice, you will summon @MAE to start an architecture, then call @DB to test a schema idea, bring in @MM to review the UI, and ask @BUG to fix a runtime error—all within the same conversation thread. The ecosystem supports agile, AI‑powered collaboration without losing state.

Now, let’s walk through each conceptual phase while emphasizing the dynamic, iterative nature.

9.2 Inception: Eliciting Requirements with @MAE
Your journey begins with a problem statement. Since v2, the Requirements Engineer (@REQ) has been absorbed into @MAE, so you talk directly to the Master Architect.

Trigger:

bash
tether chat "@MAE I want to build a voice‑analysis tool for public speakers. It should give a trustworthiness score and generate a report."
@MAE will load the writing-plans skill and start a structured dialogue:

“My friend, let’s capture this properly. What’s the primary metric? Who’s the audience? Any hard constraints?”

If needed, @MAE may call @MI to see if similar projects exist, or @PCA to confirm free‑tier feasibility.

You don’t need a complete spec upfront. @MAE will iteratively extract missing details, a process aligned with incremental requirements engineering (Gorschek et al., 2006). Even after architecture begins, you can return to inception:

bash
tether chat "@MAE we also need support for video files, not just audio. How does that change the architecture?"
@MAE will update the ADRs and adjust the plan without starting over.

9.3 Architecture: ADRs and the Kenny Rogers Framework
Once requirements are semi‑solid, you shape the system’s skeleton. @MAE produces Architecture Decision Records (ADRs) —a practice borrowed from ThoughtWorks’s lightweight architectural documentation (Nygard, 2011). Every major choice is documented with context, alternatives, and consequences.

Trigger:

bash
tether chat "@MAE what’s the best tech stack for the voice‑analysis app?"
The response includes:

A Kenny Rogers Verdict (HOLD / FOLD / WALK AWAY / RUN).

Recommended stack (e.g., Cloudflare Workers for API, Supabase for storage, Web Audio API).

Trade‑off analysis, cost projections, and the resulting ADR.

Architecture is not a one‑time event. If during implementation you discover that Supabase Realtime connections are too limited, circle back:

bash
tether chat "@MAE we’re hitting the 2 concurrent Realtime connection limit on the free tier. Switch to polling, or upgrade?"
@MAE re‑evaluates and updates the ADR. This mirrors the reflective, risk‑driven iteration of the Spiral Model.

The Kenny Rogers Framework in detail:

Verdict	Meaning	When to Apply
HOLD	Good architecture, wait for the right moment.	Technology is correct but resources/timing aren’t right yet.
FOLD	Bad approach—cut losses immediately.	Technology is fundamentally flawed or risk outweighs benefit.
WALK AWAY	Could work, but effort > value.	You could make it work, but it’s not worth the complexity or maintenance burden.
RUN	Danger—unsustainable or unethical.	Vendor lock‑in, abandoned library, unethical practice. Escape.
This framework forces clear, decisive architecture decisions and prevents analysis paralysis.

9.4 Implementation: Subagent‑Driven Development
When you’re ready to code, you don’t write a monolithic script. Instead, you leverage Subagent‑Driven Development: a fresh, isolated AI instance for each small task, reviewed twice before merging. This is covered deeply in Chapter 10.

But implementation is never isolated. You may be mid‑coding and discover a design flaw:

bash
tether chat "@MAE the file‑upload flow conflicts with the proposed auth middleware. Adjust the plan."
@MAE will update the implementation plan and re‑dispatch affected subagents.

9.5 UI Polish: Design Systems and Feedback Loops
Since @MM absorbed the former UIX agent, all visual and brand decisions go through him. He can replicate professional design systems (Stripe, Vercel, Linear) and provide instant previews.

Iteration:

tether chat "@MM redesign the hero section using the Linear dark theme."

@MM creates a preview via WebContainers; you see it live.

Not satisfied? Request revisions—another loop.

This tight feedback loop aligns with Lean UX (Gothelf & Seiden, 2013) and rapid prototyping.

9.6 Testing & Quality Gates: Continuous Assurance
Quality is not a gate at the end—it’s a set of checks that run alongside every step. @QC manages five gates:

Requirements: completeness, measurability.

Architecture: ADRs documented, consistency.

Implementation: test coverage ≥80%, lint clean, build passing.

Deployment: zero‑downtime, rollback capability, monitoring configured.

Maintenance: health checks active, dependencies fresh.

You can request a gate check at any time:

bash
tether chat "@QC evaluate the implementation gate for the voice‑analysis project."
If it fails, @QC provides a clear path to unblock. This is akin to a continuous integration pipeline but conversational.

TDD is enforced: RED (failing test) → GREEN (minimal implementation) → REFACTOR → COMMIT. This is integral to subagent development and is detailed in Chapter 10.

9.7 Launch & Deployment: Zero‑Cost Until Revenue
Deployment is orchestrated by @PCA. When all gates pass:

bash
tether chat "@PCA deploy to production."
@PCA verifies gates, configures Cloudflare (or Vercel/Netlify), and confirms zero‑cost compliance.

Deployment is not the final step; you can deploy incrementally (continuous delivery). After release, @MNT monitors, and @SUP (via ticket‑triage) surfaces user issues that feed back into requirements.

9.8 Maintenance & Monitoring: The Never‑Ending Loop
Post‑launch, development continues. @MNT runs health checks every 10 minutes, @MI scans the frontier, and @BUG handles incidents. autoDream consolidates learnings and creates new skills. This continuous loop extends the DevOps philosophy into AI‑native territory.

In summary:

Start anywhere—inception, architecture, or debugging.

Loop as needed—handoffs enable seamless transition.

Iterate fast—subagent‑driven dev and TDD shorten cycles.

Learn continuously—memory, cards, skills compound intelligence.

Chapter 10: Subagent‑Driven Development
10.1 The Triad: Implementer · Spec Reviewer · Quality Reviewer
Subagent‑Driven Development is Tether’s method for turning implementation plans into rigorously tested code. Each task from the writing-plans output is dispatched to a fresh subagent instance with isolated context, following a three‑step review process:

Implementer Subagent: Writes code following TDD. Must output a failing test first, then minimal implementation, then refactor. Commits after each successful cycle.

Spec Reviewer Subagent: Checks that the implementation exactly matches the original task specification. Verifies file paths, function signatures, and required behavior.

Quality Reviewer Subagent: Evaluates code quality: correctness, style, error handling, test coverage, security, and performance.

Only when both reviewers approve does the task mark complete. This reduces defects and ensures compliance with the original plan.

This pattern is inspired by pair programming (Williams & Kessler, 2000) but with dual reviewers and enforced TDD. It also echoes the inspection‑based quality assurance advocated by Fagan (1976).

10.2 Writing Effective Implementation Plans
The writing-plans skill (owned by MAE) produces a structured plan divided into small, estimable tasks (2–5 minutes each). Each task includes:

Goal and acceptance criteria.

File paths to create/modify.

Test file paths.

Relevant context from the ADRs and project constraints.

You can request a plan explicitly:

bash
tether chat "@MAE create an implementation plan for user authentication using magic links."
Review the plan; ask for adjustments if needed. Then approve it to begin subagent execution.

10.3 Dispatching Subagents
MAE uses the subagent-driven-development skill to dispatch tasks. The orchestration is automatic after you approve the plan, but you can also manually invoke it:

bash
tether chat "@MAE execute the plan for user authentication."
MAE will:

Pick the next task from the TODO list.

Prepare the subagent prompt using the implementer-prompt template.

Launch the implementer subagent.

Upon completion, launch the spec and quality reviewers.

If either reviewer fails, the implementer is re‑invoked with feedback, looping until success or a predefined retry limit.

You can observe the progress in the chat or via tether status.

10.4 Reviewing and Iterating
You remain in the loop. If a reviewer fails a task, you can inspect the feedback:

bash
tether chat "show the review comments for task #12"
Then decide to override the failure, adjust the plan, or let the subagent retry.

This iterative, review‑driven process ensures that code quality remains high without bogging you down in manual code review.

10.5 End‑to‑End Example
Let’s trace a small feature:

User: @MAE we need to add a password reset flow.

MAE: creates a plan: tasks for email template, reset token generation, API endpoint, UI page.

User: looks good, execute.

Implementer 1 writes the token generation unit test, then the function. Spec reviewer approves, but quality reviewer flags missing error handling for expired tokens. Implementer fixes, passes.

Implementer 2 creates the API endpoint with TDD. Both reviewers approve.

Implementer 3 builds the React page. Quality reviewer requests better accessibility labels. Implementer refactors, passes.

MAE reports all tasks complete. @QC runs gate check—implementation gate passes.

Total elapsed time: minutes. Quality: high, with automated tests.

Chapter 11: Database Layer
11.1 Schema Design with @DB
@DB is your database specialist. Invoke him for any data modeling:

bash
tether chat "@DB design the schema for a multi‑tenant task management app."
@DB will produce a Drizzle ORM schema in packages/database/src/schema.ts and the corresponding SQL migration. He follows normalization principles (Codd, 1970) and applies standard naming conventions.

He can also suggest indexes based on expected query patterns. If you need to change the schema, just ask:

bash
tether chat "@DB we need to add a 'priority' field to tasks. Generate the migration."
He’ll generate a new migration file and update the schema.

11.2 RLS Policies and Multi‑tenancy
Row Level Security is critical for SaaS applications. @DB configures RLS policies so that users can only access their own data.

Example request:

bash
tether chat "@DB enable RLS on the tasks table so that users only see their own tasks."
@DB will add the appropriate policy to the migration and ensure the backend uses the correct auth.uid() context. This aligns with the secure by default principle (Saltzer & Schroeder, 1975).

11.3 Migrations: Safe Patterns and Rollback
Migrations are managed under supabase/migrations/. @DB follows safe migration patterns:

Non‑locking changes where possible.

Backward‑compatible additions.

Separate migrations for destructive changes, with manual approval.

To apply migrations:

bash
cd supabase && supabase db push
Or via @PCA during deployment.

For rollback, @DB can generate a rollback script if requested, but typically we move forward with a new migration to fix issues (forward‑only repair).

11.4 Query Optimization and Performance Targets
@DB monitors query performance via the query_performance_target_ms preference (default 100ms p95). If a query is slow, you can ask:

bash
tether chat "@DB the task listing endpoint is slow, p95 500ms. Optimize it."
@DB will analyze the query, suggest an index, and create a migration to add it.

Chapter 12: Deployment and Zero‑Cost Compute
12.1 @PCA’s Role: Free‑Tier‑First Architecture
PCA’s mandate is clear: you pay $0 until your users pay you. Before any deployment, PCA analyzes the projected cost against free tier limits and suggests optimizations.

bash
tether chat "@PCA cost analysis for the voice‑analysis app."
Output includes a table of estimated usage and whether it fits within free tiers.

12.2 Deploying to Cloudflare Pages and Workers
bash
tether chat "@PCA deploy the production build."
PCA:

Runs pnpm build.

Deploys the frontend to Cloudflare Pages.

Deploys the API to Cloudflare Workers.

Configures environment variables from the project’s .env settings (secrets are set via Cloudflare API).

After deployment, PCA provides the live URL and enables monitoring.

12.3 Vercel and Netlify One‑Click Exports
If you prefer Vercel or Netlify, you can export instead of direct deploy:

bash
tether export --format vercel
This generates a vercel.json and you can run vercel deploy. PCA can also guide you through this process.

12.4 Provider Resolution and Fallback Chain
PCA manages LLM provider failover. The fallback chain is configured in PCA’s state preferences. If the primary provider fails (e.g., Anthropic downtime), PCA automatically routes requests to the next provider (OpenAI, then Groq, etc.). This ensures 99.5% availability.

You can view the current provider status:

bash
tether chat "@PCA provider status"
12.5 Cost Monitoring and Alerts
PCA monitors usage of API requests, database size, storage, and queue commands. Daily cron job usage-monitor checks against free tier limits. When usage exceeds 80%, PCA alerts you via chat and can send email notifications if configured.

bash
tether chat "@PCA show current usage."

Part 4: Continuous Learning & Memory
Chapter 13: The Memory Substrate
The memory substrate is the persistent knowledge base that records every significant event, decision, and lesson. It is what separates Tether from a stateless chatbot: the council remembers.

13.1 learnings.jsonl — The Immutable Ledger
This append‑only file (in .tether/memory/learnings.jsonl) is the single source of truth. Every time an agent makes a decision, discovers a pattern, or notes a pitfall, a new JSON line is appended. As an append‑only log, it implements the event sourcing pattern (Fowler, 2005): the current state can always be rebuilt by replaying the log.

Format:

json
{
  "ts": "2026-04-29T10:00:00Z",
  "type": "decision",
  "key": "auth-strategy",
  "insight": "Use Supabase Magic Links over passwords for better UX and security.",
  "confidence": 9,
  "source": "mae",
  "tags": ["auth", "security"],
  "architectural_layer": "logical"
}
You can query this ledger directly with tether memory (live command):

bash
tether memory --type decision --min-confidence 8
13.2 consolidated.md — Compressed Project Knowledge
Scrolling through thousands of JSON lines isn't practical for quick context retrieval. The consolidated.md file (in .tether/memory/consolidated.md) is a human‑readable Markdown summary, regenerated weekly by the Deep Sleep phase of autoDream. It distills key decisions, proven patterns, known pitfalls, and open questions.

When an agent is invoked, the orchestrator injects a shortened version of this consolidated memory into the system prompt, saving tokens and providing high‑level context.

13.3 Querying Memory
The tether memory command is your primary window into the ledger. It's already wired and functional.

Option	Description	Example
--limit N	Number of entries	--limit 20
--type {decision,pattern,pitfall,...}	Filter by memory type	--type pitfall
--min-confidence 1-10	Minimum confidence score	--min-confidence 7
--search query	Text search across all fields	--search "timeout"
--order recency|confidence	Sort order	--order confidence
Example:

bash
tether memory --search "database connection" --limit 5
This is already functional; you can use it today.

13.4 Memory Providers
Memory can be stored locally (JSONL + consolidated.md) or synced to Supabase. The SupabaseStorage class (in packages/memory/src/supabase-storage.ts) mirrors the local interface but persists to a memory_ledger table. The architecture doc defines this dual‑provider model so that projects can have cloud‑backed memory for team collaboration while maintaining a local‑first fallback.

To enable Supabase memory, set the environment variable:

bash
TETHER_MEMORY_PROVIDER=supabase
🚧 The CLI command to toggle providers is not yet wired, but the provider classes are fully implemented.

Chapter 14: autoDream v2
autoDream is Tether’s continuous learning daemon. Inspired by neurobiological models of sleep‑dependent memory consolidation (Walker & Stickgold, 2004), it processes the memory ledger in three tiers, extracting patterns and creating skills.

14.1 Light Sleep, REM Sleep, Deep Sleep
Phase	Frequency	What It Does	Implementation
Light Sleep	Hourly	Scans recent entries for repeating patterns (same key appearing ≥3 times). Generates new type: pattern entries.	packages/memory/src/consolidator.ts
REM Sleep	Daily	Attempts to discover causal links between events and create Learning Attribution Records. Generates experience cards.	Currently stubbed (returns []), awaiting LLM integration for causal reasoning.
Deep Sleep	Weekly	Compresses all memory into a new consolidated.md, creates new skills from patterns with confidence ≥7, and triggers skill review for underperformers.	consolidator.ts (compression), and AutoDreamSkillCreator in packages/learning/src/autoDream/ (when integrated).
You can manually trigger a consolidation cycle:

bash
tether dream
This command is live and runs a full tick (light/rem/deep based on elapsed intervals). The deep sleep LLM call is pending; currently it only performs pattern extraction.

14.2 Pattern Detection and Skill Creation
In REM and Deep Sleep, the system converts recurring patterns into skills. The PatternDetectionResult interface in the architecture doc (under Part 13 of the arch doc) describes the criteria: minimum 3 occurrences, confidence ≥7. The owning agent is inferred from the pattern type.

When a pattern qualifies, an autoDreamSkillCreator (still a library module) queues a skill_manage.create call for the agent. The skill is not auto‑published without review, but it appears in the agent’s queue.

14.3 Configuring autoDream Intervals
The default intervals are defined in packages/config/src/index.ts:

typescript
export const AUTODREAM_INTERVALS = {
  LIGHT_SLEEP_SECONDS: 3600,    // 1 hour
  REM_SLEEP_SECONDS: 86400,      // 24 hours
  DEEP_SLEEP_SECONDS: 604800     // 7 days
};
You can modify these and rebuild the config package. There’s no CLI config command for this yet, but the mechanism is in place.

Chapter 15: Experience Cards & Learning Attributions
15.1 Experience Cards
Experience Cards are structured, reusable records of a problem and its solution. When @BUG fixes a bug, it can create a card with the problem_signature, root_cause, fix_strategy, and verification. These cards are stored in the experience_cards table (migration 0001_experience_cards.sql) and managed by @tether/experience.

The ExperienceCardSystem class provides methods to create, find similar, record usage, and make public. You can interact with experience cards via the API or within agent conversations. For example, when @BUG fixes a timeout issue, it may automatically create a card and offer to share it.

🚧 The tether experience CLI command is not yet wired, but you can query cards through tether chat "show experience cards about timeout".

15.2 Learning Attribution Records (LARs)
LARs are how agents teach each other. When @BUG identifies that a deployment outage was caused by a missing environment variable, it creates a LAR targeting @PCA with the root cause and prevention. The LAR is stored in the learning_attributions table and appears in the target agent’s pending learning queue.

The LearningAttributionSystem (in packages/learning/src/index.ts) handles record creation and consolidation. Agents can view pending LARs:

bash
tether chat "@PCA show my pending learning attributions"
The architecture doc details the LAR lifecycle: pending → consolidated (agent acknowledges and applies) or rejected (not applicable). Consolidated LARs become part of the agent’s long‑term memory and may trigger skill updates.

Part 5: Advanced Features
Chapter 16: The Gateway — Multi‑Platform Access
The Gateway enables Tether to be accessed through 18 different platforms: Telegram, Discord, Slack, Email, CLI, WhatsApp, Signal, Matrix, IRC, Twitter/X, Mastodon, LinkedIn, Teams, Google Chat, Mattermost, Zulip, RocketChat, and Webhooks.

The GatewayRunner in gateway/src/runner.ts manages platform adapters. Each adapter implements a common interface (PlatformAdapter in gateway/src/platforms/base.ts). Currently, the CLI adapter is implemented; others are stubbed. Enabling a platform involves setting its environment variables and registering the adapter.

🚧 Gateway adapters beyond CLI are being developed. The infrastructure is in place, but only the CLI platform is production‑ready.

To see which platforms are configured:

bash
tether chat "@PCA list active gateways"
(This will query the gateway service.)

Chapter 17: Voice Commands
Voice input is available through the Tether web interface, leveraging either the browser’s built‑in webkitSpeechRecognition API (free, but limited to Chrome/Edge/Safari) or OpenAI Whisper for higher accuracy (costs ~$0.006/minute).

Configuration:
In .env:

bash
VITE_VOICE_ENABLED=true
WHISPER_API_KEY=your-key   # optional, for Whisper fallback
If useWhisperFallback is true and the browser API is unavailable, the frontend records audio and sends it to the Whisper API. The voice package (packages/voice/src/index.ts) contains the logic.

🚧 Voice integration works in the web app, but there is no CLI voice command.

Chapter 18: Live Preview (WebContainers)
When you work on a web project with @MM or @MAE, you can spin up a live, in‑browser Node.js environment using WebContainers. This is the technology behind StackBlitz; it allows you to see your React/Vite app running instantly without deploying.

The @tether/preview package contains a TetherPreview class that boots a WebContainer, mounts the project files, runs npm install && npm run dev, and exposes a preview URL. The web UI integrates this into a panel.

To start a preview from the web app, click the Preview button in the project dashboard. Or within an agent conversation:

bash
tether chat "preview the current app"
(This command invokes the preview service, which is available but may require the web app to be running.)

Limitations: WebContainers run entirely in the browser, so they cannot use native binaries (e.g., some database drivers). Tether's default stack (Drizzle, Supabase, React) is fully compatible.

Chapter 19: Exporting Your Project
Tether ensures you are never locked in. The export system (@tether/export) can package your entire project into a ZIP file or produce configuration files for one‑click deployment to Vercel or Netlify.

Already functional CLI commands:

bash
tether export --format zip
tether export --format vercel
tether export --format netlify
You can include the .tether/memory folder in the ZIP for handoff:

bash
tether export --format zip --include-memory
These commands generate the appropriate files and print the next steps (e.g., vercel deploy). This is a live, working feature.

Chapter 20: Cron Scheduler & Background Jobs
The Maintenance Master (MNT) and other agents rely on a cron‑like scheduler to perform periodic tasks. The cron_jobs table (migration 0014_cron_jobs.sql) stores job definitions, and the CronScheduler (in packages/maintenance/src/daemon.ts when extended) executes them with retry logic and exponential backoff.

Default cron jobs include:

Health checks (every 10 minutes)

Frontier scan (weekly)

Dependency update check (weekly)

Security scan (daily)

Usage monitoring (daily)

Cron is managed by the MNT daemon. The architecture doc details how to define custom jobs. Currently, cron is configured via code modifications, but the API and agent interactions are designed to allow dynamic job creation. 🚧 Creating cron jobs via CLI is not yet live, though the underlying job execution engine is present.

You can check the status of cron jobs via an agent:

bash
tether chat "@MNT show upcoming cron jobs"

Part 6: Reference
Chapter 21: CLI Command Reference
The Tether CLI is your direct line to the council. You can invoke it either as pnpm agent <command> or, once the global install is set up, as tether <command> directly. In this reference, I will use tether for brevity, but if you have not linked the binary, simply replace it with pnpm agent.

21.1 tether chat — Conversation Interface
Starts a conversation with the council. If a message is provided as an argument, the council responds immediately. If no arguments are given, it enters an interactive mode (where implemented).

Usage:

bash
tether chat "<message>"
tether chat --new "<message>"   # start a fresh thread
tether chat --verbose "<message>"  # show full agent reasoning
tether chat --model gemini "<message>" # force a specific LLM
Options:

Option	Description
--new	Ignore any existing conversation thread and start a new one.
--verbose	Output the full memory context and agent reasoning.
--model <model>	Override the default LLM provider/model for this request.
--agent <id>	Force only a specific agent to respond (e.g., --agent mae).
Status: ✅ Fully functional.

21.2 tether agents — List All Agents
Displays the 8 active agents with their IDs, names, and roles.

bash
tether agents
Status: ✅ Fully functional.

21.3 tether memory — Query the Memory Ledger
Queries the append‑only .tether/memory/learnings.jsonl file or the Supabase memory provider.

Usage:

bash
tether memory
tether memory --limit 20
tether memory --type decision
tether memory --min-confidence 8
tether memory --search "authentication"
tether memory --order confidence
Options:

Option	Description	Example
--limit N	Maximum entries to return (default 20)	--limit 50
--type <type>	Filter by memory type: decision, pattern, pitfall, observation, constraint, question, milestone	--type pitfall
--min-confidence <1-10>	Only show entries with at least this confidence	--min-confidence 7
--search <query>	Full‑text search across key, insight, and tags	--search "timeout"
--order recency|confidence	Sort by timestamp (newest first) or confidence (highest first)	--order confidence
Status: ✅ Fully functional.

21.4 tether status — Project and Agent Status
Displays the current project status, including active agents, current development step, memory entry count, and quality gate overview.

bash
tether status
tether status --verbose     # includes active skills and pending handoffs
tether status --agent mae   # specific agent state details
Status: ✅ Fully functional.

21.5 tether dream — Trigger Memory Consolidation
Manually triggers the autoDream consolidation cycle (Light/REM/Deep Sleep based on elapsed intervals).

bash
tether dream
Status: ✅ Fully functional (Deep Sleep LLM summary generation is stubbed).

21.6 tether export — Export Project
Packages the project for external deployment or handoff.

Usage:

bash
tether export --format zip
tether export --format vercel
tether export --format netlify
tether export --format zip --include-memory
Options:

Option	Description
--format <zip|vercel|netlify>	Export format.
--include-memory	(ZIP only) Include the .tether/memory/ folder in the archive.
Status: ✅ Fully functional.

21.7 tether skills — Skill Management 🚧
Commands for managing the procedural skill library. The underlying SkillManageTool class (packages/skills/src/skill-manage.ts) is implemented, but the CLI integration is in progress.

Planned subcommands:

bash
tether skills list                          # List installed skills
tether skills show <name>                   # Display a skill's SKILL.md
tether skills manage create --name <name>   # Create a new skill
tether skills manage patch --name <name>    # Patch a skill
tether skills manage edit --name <name>     # Edit a skill
tether skills manage delete --name <name>   # Delete/archive a skill
tether skills install <community-skill>     # Install from marketplace
tether skills publish <name>                # Publish to marketplace
tether skills rate <name> <outcome>         # Provide feedback on skill success
Until the CLI is wired, you can interact with skills via agent conversation (tether chat "@MAE create a skill for...") or by calling the library directly in your own scripts. 🚧

21.8 tether experience — Experience Card Management 🚧
Manage reusable problem/solution cards. The ExperienceCardSystem class is implemented, but no CLI command yet. You can trigger card creation and search through tether chat. 🚧

21.9 tether learning — Learning Attribution Records 🚧
View and manage LARs. The LearningAttributionSystem is in place. CLI is pending. Use tether chat "@MAE show my pending LARs" for now. 🚧

21.10 tether config — Configuration Management 🚧
Read and update agent preferences. The AgentStateManager can persist preferences, but no CLI yet. You can set preferences by editing the long_term.preferences field in an agent’s state (if persisted to DB) or by modifying the agent persona definitions. 🚧

Chapter 22: Configuration Reference
22.1 turbo.json — Build Pipeline
This file defines the build pipeline for the monorepo. The key section:

json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    }
  }
}
"^build" means "build all dependencies before building this package."

"outputs": ["dist/**"] tells Turborepo to cache the dist folder for skipped rebuilds.

22.2 biome.json — Linting and Formatting
Tether uses Biome for fast, unified formatting and linting. Key settings:

Formatter: spaces, indent 2, line width 100.

Linter: recommended rules.

Ignores .tether/**, dist/**, node_modules/**.

You can run pnpm format to auto‑format the entire monorepo.

22.3 Environment Variables (.env)
The complete list of supported environment variables. Required ones are bolded.

Variable	Description	Required
**TETHER_PROJECT_ID**	Unique project identifier (default: default)	Yes
**SUPABASE_URL**	Supabase project URL	For DB
**SUPABASE_ANON_KEY**	Supabase anonymous key	For DB
SUPABASE_SERVICE_KEY	Service‑role key for admin tasks	Optional
**ANTHROPIC_API_KEY**	Anthropic Claude key	At least one AI provider
**OPENAI_API_KEY**	OpenAI key	At least one
**GEMINI_API_KEY**	Google Gemini key	At least one
GROQ_API_KEY	Groq key (for fast inference)	Optional
TOGETHER_API_KEY	Together.ai key	Optional
OPENROUTER_API_KEY	OpenRouter key	Optional
CLOUDFLARE_API_TOKEN	Cloudflare API token	For PCA deploy
CLOUDFLARE_ACCOUNT_ID	Cloudflare account ID	For PCA deploy
R2_BUCKET_NAME	R2 storage bucket	Optional
R2_ACCESS_KEY_ID	R2 access key	Optional
R2_SECRET_ACCESS_KEY	R2 secret key	Optional
STRIPE_SECRET_KEY	Stripe secret key	For payments
STRIPE_WEBHOOK_SECRET	Stripe webhook secret	For payments
RESEND_API_KEY	Resend email API key	Optional
POSTHOG_API_KEY	PostHog analytics key	Optional
SENTRY_DSN	Sentry error tracking DSN	Optional
UPSTASH_REDIS_URL	Upstash Redis URL	Optional
UPSTASH_REDIS_TOKEN	Upstash Redis token	Optional
VITE_VOICE_ENABLED	Enable voice in frontend (true/false)	Optional
WHISPER_API_KEY	OpenAI Whisper key for voice	Optional
TELEGRAM_BOT_TOKEN	Telegram bot token	Gateway
DISCORD_BOT_TOKEN	Discord bot token	Gateway
SLACK_BOT_TOKEN	Slack bot token	Gateway
All sensitive keys should be set via Cloudflare Worker secrets or Supabase Vault for production.

22.4 Agent State Preferences
Each agent stores preferences that can be modified to alter behavior. Here is a summary of the most impactful ones:

Agent	Preference	Default	Effect
mae	verbosity	concise	detailed gives longer responses
mae	kenny_rogers_mode	true	Enforces verdicts; false allows free‑form advice
mi	scan_frequency	weekly	How often frontier scans run (daily, weekly, monthly)
pca	zero_cost_strict	true	Reject architectures that would exceed free tiers
pca	alert_threshold	80	Percentage of free tier usage before alert
db	query_performance_target_ms	100	p95 target for query optimization
mm	default_design_system	stripe	vercel, linear, github are alternatives
bug	regression_test_required	true	Refuse to fix without a regression test
qc	coverage_threshold	80	Minimum test coverage % for implementation gate
mnt	auto_fix_enabled	true	Automatically apply safe patches
To change these, you will eventually use tether config set, but currently you can modify the state directly in the database or the local state file (if using file‑based persistence). 🚧

Chapter 23: Troubleshooting
23.1 Common Installation Issues
Problem	Likely Cause	Solution
pnpm: command not found	pnpm not installed	npm install -g pnpm
Build fails with type errors	Outdated dependencies or broken reference	Run pnpm install then pnpm build. If errors persist, check tsconfig.json references.
tether: command not found	CLI binary not in PATH	Use pnpm agent instead, or add ./node_modules/.bin to PATH.
Memory file not found	Yet to be initialized	It is created automatically on first agent call. You can also touch .tether/memory/learnings.jsonl.
23.2 Agent Not Responding
Ensure at least one AI provider key is set in .env.

Run pnpm build to make sure the agents package is compiled.

Try pnpm agent status to see if the CLI works. If it returns error about missing modules, rebuild.

Check pnpm agent agents to verify personas are loaded.

23.3 Skill Loading Failures
If an agent mentions a skill but doesn't seem to use it, verify the skill's SKILL.md exists and is valid YAML.

Check .tether/skills/.manifest.json for errors.

The skill-manage security scan may quarantine a skill; check .tether/skills/.security/quarantine/.

23.4 Deployment Errors
PCA may report missing Cloudflare tokens; verify CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID are set.

For Vercel/Netlify exports, you must have the respective CLI installed.

23.5 Memory and Performance
If learnings.jsonl grows extremely large (hundreds of MB), force a consolidation: tether dream. The Deep Sleep compression will reduce token usage.

Clear the file only if you absolutely must start fresh: delete learnings.jsonl and re‑initialize by running any agent command.

Chapter 24: Best Practices & Patterns
24.1 Prompt Engineering for Tether
Be explicit about constraints: "Must use free tiers. Expect 1000 users by month three."

Summon agents intentionally: If you know you need architecture, use @MAE to avoid ambiguous routing.

One decision per turn: Don't ask MAE to design a database, pick a UI framework, and estimate costs in one sentence. Break it up.

Give feedback: "That architecture will cost too much." Agents learn from your corrections.

24.2 Organizing Skills for Maximum Reuse
Name skills according to their domain and purpose: e.g., stripe-webhook-handler, react-form-validation.

Use requires_skills to build complex skills from simpler ones.

Publish successful skills to the marketplace so the whole community benefits.

24.3 Effective Handoff Strategies
Always handoff with full context. The sending agent should include the relevant ADRs, memory IDs, and active skills.

Check pending handoffs regularly to avoid stalled tasks.

If a handoff fails, the orchestrator logs it; you can replay by re‑sending the original delegation message.

24.4 Keeping Memory Clean and Useful
Rely on autoDream for compression; do not manually edit learnings.jsonl.

Tag entries with descriptive tags (security, performance, frontend, critical) to aid searching.

If a decision changes, append a new decision entry with an updated insight and reference the old key via relates_to.

24.5 Scaling from Zero to Paying Users
Let PCA guide you. When paying users arrive, PCA will notify you and suggest the optimal upgrade path.

Upgrade incrementally: first Cloudflare Workers paid plan, then Supabase Pro, then dedicated Redis, etc.

The zero‑cost guarantee is a design principle, not a permanent restriction. It forces you to stay lean until you have real traction.

Appendices
Appendix A: Glossary of Terms
Term	Definition
ADR	Architectural Decision Record — a document capturing the context and consequences of a key architecture choice.
Agent	One of the eight specialized AI personas in the council.
autoDream	The continuous learning daemon that consolidates memory and creates skills.
Council	The collective of all eight agents working together.
Experience Card	A structured record of a problem and its verified solution, reusable across projects.
Handoff	A formal transfer of a task and context from one agent to another.
Kenny Rogers Framework	A decision matrix: HOLD, FOLD, WALK AWAY, RUN.
LAR	Learning Attribution Record — a lesson from one agent to another.
Orchestrator	The engine that routes messages and coordinates agents.
PCA	Platform Compute Agent — enforces zero‑cost compute.
Quality Gate	One of five validation stages required before production deployment.
RLS	Row Level Security — PostgreSQL feature for isolating tenant data.
Skill	A markdown‑based procedural knowledge unit, agent‑owned and versioned.
Subagent	A temporary, isolated AI instance spawned for a specific implementation task.
TDD	Test‑Driven Development — Red‑Green‑Refactor cycle.
Appendix B: Agent Quick Reference
Agent	ID	Triggers	Signature Phrase
Master Architect	mae	architect, design, plan, requirements	"Takes a slow sip of coffee. My friend."
Master Innovator	mi	research, frontier, pattern, scan	"Pattern detected."
Platform Compute	pca	deploy, platform, cloudflare, cost	"Zero‑cost compute guaranteed."
Database Expert	db	database, schema, postgres, migration	"Schema deployed. RLS active."
Master Marketer	mm	design, landing, pricing, UI, brand	"Using [Brand] design system."
Debugging Agent	bug	bug, error, debug, fix, crash	"Root cause identified."
Quality Control	qc	test, quality, gate, TDD, review	"All gates passed. Production ready."
Maintenance Master	mnt	monitor, health, cron, security, patch	"Monitoring enabled. Auto‑fixes armed."
Appendix C: Full Skill Directory (Built‑in)
Skill Name	Owner	Description
writing-plans	mae	Create structured implementation plans (2–5 min tasks).
subagent-driven-development	mae	Orchestrate implementer subagents with two‑stage review.
mae-orchestration	mae	Complete council coordination patterns.
frontier-scan	mi	Weekly scan of AI/ML papers, tools, patterns.
pattern-extraction	mi	Extract invariants from accumulated intelligence.
cloudflare-pages-deploy	pca	Deploy to Cloudflare Pages and Workers.
vercel-deploy	pca	Generate Vercel deployment config.
zero-cost-architecture	pca	Design patterns for free‑tier compliance.
provider-failover	pca	Multi‑provider LLM routing with fallback chain.
migration-safe-patterns	db	Safe migration strategies for production databases.
rls-policy-design	db	Row Level Security policy design for multi‑tenant apps.
query-optimization	db	Index and query tuning.
stripe-pricing-page	mm	Stripe‑inspired pricing page.
vercel-landing-page	mm	Vercel‑style landing page.
email-sequence	mm	Welcome/onboarding email sequences.
positioning-framework	mm	Product positioning and messaging.
systematic-debugging	bug	7‑phase debugging protocol.
react-hydration-errors	bug	Diagnosis and fix for React hydration issues.
test-driven-development	qc	Enforce Red‑Green‑Refactor TDD.
code-review-checklist	qc	Systematic code review.
dependency-update	mnt	Automated dependency updates with safety checks.
health-check	mnt	Comprehensive health monitoring.
ticket-triage	mnt	Support ticket triage and knowledge base.
Appendix D: The Kenny Rogers Decision Framework
Verdict	Meaning	When to Use
HOLD	Good architecture, but wait for the right moment.	Technology is correct, but resources or timing aren’t right yet.
FOLD	Bad approach—cut losses immediately.	Library is unmaintained, risk exceeds benefit.
WALK AWAY	Could work, but effort > value.	You could build it, but the complexity doesn't justify the gain.
RUN	Danger—unsustainable, unethical, or vendor lock‑in.	Avoid at all costs.
Appendix E: The 7‑Phase Systematic Debugging Protocol
STABILIZE – Get a reliable reproduction.

ISOLATE – Narrow to the specific change (git bisect).

CHARACTERIZE – Understand scope and edge cases.

HYPOTHESIZE – Generate 2–3 competing theories.

TEST – Prove or disprove each hypothesis.

FIX – Minimal surgical fix with regression test.

PREVENT – Create a LAR for the responsible agent.

Appendix F: TDD Red‑Green‑Refactor Protocol
RED: Write a failing test that captures the requirement.

GREEN: Write the simplest code that makes the test pass.

REFACTOR: Clean up the code without changing behavior.

COMMIT: Only after all steps, with a meaningful message.

Appendix G: Quality Gate Criteria
Gate	Pass Criteria
Requirements	All requirements measurable, complete, signed off.
Architecture	ADRs documented, decisions justified, free‑tier compliance verified.
Implementation	Build green, test coverage ≥80%, lint zero errors, all subagent reviews passed.
Deployment	Zero‑downtime deployment verified, rollback plan tested, monitoring active.
Maintenance	Health checks active, dependencies up‑to‑date, security patches applied.
Appendix H: Migration from v1/v2 to v3
If you are upgrading from a prior version (the 13‑agent system), the upgrade-v3.sh script has already:

Consolidated agents from 13 to 8, removing REQ, UIX, OPS, SUP, MPE, and merging their roles.

Added new database tables for agent states, handoffs, skill usages, skill versions, cron jobs, and the new memory ledger.

Updated the skill directory structure and manifest.

Added the gateway runner and subagent runner modules.

No user data is lost; the old learnings.jsonl remains, and agent states are freshly initialized. You may need to rebuild and rerun migrations.

Appendix I: Architecture Decision Records (v2/v3)
The following ADRs have been recorded in the architecture document:

ADR-001: 8‑Agent Council (over 13) — reduces orchestration overhead.

ADR-002: Skill System (over static prompts) — enables continuous learning.

ADR-003: Subagent‑Driven Development — ensures code quality and TDD.

ADR-004: Agent State Persistence — long‑term memory across sessions.

ADR-005: Handoff Protocol — formal delegation preserves context.

ADR-006: Provider Resolution with Fallback Chain — 99.5% availability.

ADR-007: Zero‑Cost Compute Guarantee — sustainable scaling.

ADR-008: Cron Scheduler — 24/7 background intelligence.

ADR-009: Skill Version Migration — breaking change handling.

ADR-010: Skill Dependency Resolution — circular detection and semver.

Appendix J: Support and Community
The Tether Codex community is where agents and humans learn from each other. You can:

Ask questions via tether chat "@SUP" (which invokes the ticket-triage skill).

Consult the auto‑generated knowledge base in .tether/support/knowledge-base/.

Share experience cards and skills on the community marketplace.

Contribute to the core Tether project on GitHub.


