---
Repository: auraecosystem/DSH-superagent
Branch: main
Repository size: 799 KB
Version: 0.1.0
License: MIT
---

# DSH-superagent — Repository audit


* Source
 * files
 * inspected
* Research
  * prototype

- This repository is particularly interesting because it is not simply another chatbot. It implements a proactive, policy-governed coding agent that listens to GitHub and optionally Feishu, evaluates requests, creates authorized work items, executes them in separate agent sessions, and reports results through the original conversation.

Its README explicitly warns that it is a research prototype, not production-ready software or an official DeepSeek product.
1. What the system actually does
[






[](niebex.com)


The core workflow is:

GitHub / Feishu
      |
      v
  Source Registry
      |
      v
     Trigger
      |
      v
  Policy Evaluation
      |
      +---- Ignore
      |
      +---- Record candidate
      |
      v
  Authorized Mandate
      |
      v
     Ticket
      |
      v
   Assignment
      |
      v
  DSH Worker Session
      |
      +---- Code changes
      +---- Tests
      +---- Pull request
      +---- Human review
      |
      v
   Result Delivery
 The architecture separates the decision to do work from the execution of that work. That distinction is one of its strongest design decisions.


2. # Verified implementation

I inspected the repository README, setup instructions, package manifest, TypeScript configuration, Cordis bundle configuration, and important source and architecture documents.
Component	Verified implementation
Runtime	src/app/runtime.ts
Domain engine	src/core/engine.ts
Session management	src/app/sessions.ts
GitHub integration	src/sources/github.ts
Feishu integration	src/sources/feishu.ts
Worker configuration	cordis.patch.yml
Setup workflow	SETUP.md
Authorization specification	docs/002-authorization.md
Execution specification	docs/003-execution.md
Architecture documentation	docs/007-architecture.md

The domain engine
The Engine is the heart of the system.

It manages:
- Triggers
- Threads
- Decisions
- Tickets
- Assignments
- Worker reports
- Policy changes
- Message delivery
It uses synchronous transactional operations and repository interfaces. External effects are queued and performed after the transaction.

This is a sound approach to avoiding partially updated agent state.
The authorization system
One of the most important design decisions is its three-level accept mode:
Mode	Behaviour
off	No inferred requests are accepted
observe	Evaluates possible work but does not automatically accept it
auto	Automatically accepts positively assessed inferred requests

Explicit requests from authorized users can still be accepted in every mode.

The system also distinguishes human users, bots, CI messages, and messages that merely provide context to an existing Ticket.

This is significantly more sophisticated than simply allowing an LLM to react to every incoming message.
Worker isolation and session management
The project creates a separate DSH Session and working directory for each Ticket.

It defines two agent presets:
- dsh-superagent-router: handles routing and coordination.
- dsh-superagent-worker: handles actual coding work.
The router has restricted tools, including filesystem access with writing and editing disabled.

The worker has broader capabilities, including filesystem operations, shell, jobs, web, skills and subagents.

This separation is useful, but it does not automatically guarantee operating-system-level isolation.
3. Security audit
Critical architecture concern
The execution documentation explicitly states:
Executor Sessions run commands without approval as the operator's OS user.

It also acknowledges:
These wrappers and directories establish defaults, not a security boundary. A worker can still execute a program by absolute path.

This is the most important security finding.

The system has a policy layer controlling who can request work, but its worker execution environment is not necessarily a hardened sandbox.

A compromised agent, malicious repository instruction, or prompt injection could potentially cause actions with the operating-system user's permissions.
Security findings
Area	Assessment	Recommendation
Request authorization	Strong design	Preserve
Policy versioning	Strong design	Preserve
Separate worker sessions	Good separation	Add OS isolation
Shell execution	High risk	Enforce sandbox boundaries
Credential handling	Requires deeper inspection	Use scoped credentials
Subagent delegation	Requires deeper inspection	Enforce permission inheritance
GitHub account separation	Good design	Keep dedicated bot identity
Worker filesystem	High risk	Restrict mount and path access
Background processes	Needs containment	Add process and resource limits

Important distinction: a restricted prompt or blocked-command list is not a security boundary. The execution environment itself must enforce restrictions.
4. Architecture strengths and weaknesses
What I particularly like
- Explicit authorization before creating work.
- Immutable Mandates recording why work was permitted.
- Idempotent event processing.
- Independent Ticket and Assignment lifecycles.
- Policy versioning and revalidation.
- Source adapters separating GitHub and Feishu.
- Dedicated worker sessions.
- Persistent SQLite state.
- Structured human-interaction and review stages.
  
  What needs more engineering
- Strong OS-level worker isolation.
- Formal capability enforcement.
- Credential scoping and rotation.
- Resource quotas for nested agents.
- Stronger validation of external event payloads.
- Distributed coordination beyond a single local runtime.
- More explicit operational recovery and disaster-recovery guarantees.

5. Relationship with DeepSeek AI
These two repositories have different responsibilities.
DeepSeek AI	DSH-superagent
General-purpose agent runtime	Specialized autonomous coding agent
Model and tool orchestration	Repository work orchestration
Session and execution infrastructure	Ticket and Mandate lifecycle
Sandbox and terminal infrastructure	Coding worker configuration
MCP and external integrations	GitHub and Feishu Sources
General agent capabilities	Team-oriented coding workflow

The relationship is complementary: DSH-superagent uses DeepSeek Harness as its execution platform.

The superagent should therefore be understood as an application built on the Harness, not as a replacement for the underlying agent runtime.
6. What I would take into LMLM
This is where the architecture becomes particularly useful.

I would not copy the entire project. I would extract its strongest architectural ideas and implement them as native LMLM subsystems.
Proposed LMLM agent orchestration
LMLM Core
Owns identity, policy, orchestration and authorization

Event Fabric
Triggers, sources, threads, subscriptions

Policy Engine
Mandates, authorization, trust, approval

Agent Runtime
Sessions, assignments, workers, subagents

Execution Runtime
Sandbox, terminal, files, jobs, devices



LMLM Adapter Fabric
GitHub · Web4 · APIs · MCP · SSH · Devices · Distributed systems

I recommend implementing these as native LMLM components:
1. Trigger Engine: event ingestion, normalization, correlation and deduplication.
2. Mandate Engine: immutable authorization records for every delegated task.
3. Policy Engine: evaluates identities, permissions, trust and execution scope.
4. Ticket Engine: persistent task lifecycle and human review.
5. Agent Scheduler: assigns tasks to models, workers and subagents.
6. Execution Fabric: isolated local and remote execution.
7. Source Adapter SDK: connects external platforms without giving them control of LMLM.
This would make LMLM more than an agent framework: it would become a sovereign orchestration and execution environment.
7. Validation status
Audit area	Status
Repository identity and metadata	Verified
README and declared purpose	Verified
Package manifest	Verified
Domain architecture	Inspected
Authorization design	Inspected
Execution design	Inspected
Core source implementation	Partially inspected
Full source and test coverage	Incomplete
CI workflow results	Not verified
Production security	Not certified

The package declares pnpm check as its combined typecheck, test and build command. I have not executed it.

Final verdict
DSH-superagent is an interesting reference implementation for autonomous, policy-governed work.

Its most valuable contribution is not the coding agent itself. It is the separation of:
- Who may request work.
- Why the work is authorized.
- What the agent is permitted to do.
- Which worker executes it.
- How progress and results are reported.
- When a human must intervene.
That model is worth adopting in LMLM, while strengthening the actual execution security.

My recommendation: make the Mandate Engine and Policy Engine foundational LMLM subsystems. Build the execution sandbox around them, not the other way around.
