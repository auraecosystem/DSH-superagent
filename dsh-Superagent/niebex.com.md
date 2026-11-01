---
Repository: auraecosystem/DSH-superagent
Branch: main
Repository size: 799 KB
Version: 0.1.0
License: MIT
---

# DSH-superagent — Repository audi
* Source
 * files
 * inspected
* Research
  * prototype

- This repository is particularly
- 
interesting because it is not simply another chatbot. It implements a proactive, policy-governed coding agent that listens to GitHub and optionally Feishu, evaluates requests, creates authorized work items, executes them in separate agent sessions, and reports results through the original conversation.

Its README explicitly warns that it is a research prototype, not production-ready software or an official DeepSeek product.
1. What the system actually does
[






[zeriQ](niebex.com)


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
# DeepSeek AI — Repository Architecture Audit

Repository: `auraecosystem/deepseek-ai` · GitHub · 1 November 2026

Source verification blocked

The architecture you supplied describes a substantial, modular agent runtime. It is much more than a conventional LLM wrapper.

My initial assessment is that this repository is intended to provide an extensible AI execution platform, with capabilities spanning:

- Agent orchestration and durable sessions.
- Multiple LLM providers.
- Local and remote command execution.
- Sandboxed processes and subprocess management.
- SSH and persistent terminals.
- Browser and computer interaction.
- MCP integrations and external tools.
- Background jobs and delegated agents.
- Python and native Node.js runtimes.
- Workflow execution, memory/context management, and deliverables.

Important verification finding: GitHub currently reports the repository as public, with `main` as its default branch, but reports a repository size of zero. Attempts to retrieve the root README, package manifests, and the supplied component documentation returned HTTP 404.

Therefore, I can analyze the architecture you supplied, but I cannot yet claim that its modules, dependencies, implementations, or tests have been verified in source code.

## 1. What this architecture actually represents

I would classify it as a modular agent operating system / AI execution runtime.

Its components fall into six architectural layers:

1\. Agent orchestration

core · session · subagent · goal · plan · workflow · preset

2\. Intelligence and context

llm · context · compaction · skill · typert · feedback

3\. Execution infrastructure

shell · subprocess · ssh · terminal · ptc-runtime · sandbox · fs

4\. Interaction and connectivity

web · browser-use · computer-use · mcp · acp · lsp · sdk

5\. Persistence and coordination

storage · session-query · attachment · spill · jobs · schedule · identity · credentials

6\. Application interfaces

api · host · client · bundle · boot · deliverables

This separation is sensible because intelligence, execution, persistence and user interaction are different responsibilities.

## 2. The most important packages

| Package        | Architectural responsibility             |
| -------------- | ---------------------------------------- |
| `core`         | Agent lifecycle and session coordination |
| `llm`          | Model-provider abstraction               |
| `typert`       | Typed representations and type graphs    |
| `ptc-runtime`  | Programmatic tool execution              |
| `sandbox`      | Execution isolation                      |
| `subprocess`   | Process lifecycle management             |
| `workflow`     | Multi-step task execution                |
| `subagent`     | Delegation and parallel agents           |
| `session`      | Durable conversation state               |
| `mcp`          | External tool connectivity               |
| `computer-use` | Graphical interaction                    |
| `browser-use`  | Browser automation                       |
| `extensions`   | Runtime extension mechanisms             |
| `credentials`  | Authorization and credential management  |

Three packages deserve particular attention:

A. `ptc-runtime`

Potentially one of the most important components.

Programmatic Tool Calling allows an agent to compose operations into executable programs rather than making every tool call independently.

For example:

```
User request
    |
    v
Agent reasoning
    |
    v
Generate execution program
    |
    v
Validate program
    |
    v
Sandbox execution
    |
    v
Collect results
    |
    v
Return structured response
```

B. `sandbox`

This is fundamental to safe agent execution.

It should enforce:

- Filesystem restrictions.
- Process isolation.
- CPU and memory limits.
- Network access policies.
- Execution timeouts.
- Credential isolation.
- Permission-controlled subprocesses.

C. `subagent`

This provides a foundation for specialized agents.

For example:

```
                 Main Agent
                     |
          +----------+----------+
          |          |          |
       Research   Developer   Security
          |          |          |
          +----------+----------+
                     |
               Result synthesis
```

The important distinction is that delegation must not mean unrestricted authority transfer.

## 3. What I verified in the actual repository

The GitHub commit history exposes some implementation and development information.

Verified commit evidence

The latest inspected commit was:

`25e38f85bf0505f04cdadcf595c43cc3708038ae`

[Inspect the commit on GitHub](https://github.com/auraecosystem/deepseek-ai/commit/25e38f85bf0505f04cdadcf595c43cc3708038ae?utm_source=chatgpt.com)

Its `.agent/Command` file documents:

- Node.js and pnpm runtime checks.
- Native system builds.
- TypeScript project-reference builds.
- Desktop and web bundles.
- Python runtime checks.
- GitHub CLI authentication.
- Lark CLI integration.
- Agent plugin installation.
- Build, lint, coverage and documentation gates.

It also documents these commands:

| Command                  | Intended validation           |
| ------------------------ | ----------------------------- |
| `pnpm run test`          | Unit tests                    |
| `pnpm run test:coverage` | Per-file coverage gate        |
| `pnpm run test:e2e`      | Real API tests                |
| `pnpm run test:snapshot` | Recorded-session replay       |
| `pnpm run typecheck`     | TypeScript checking           |
| `pnpm run lint`          | Code quality                  |
| `pnpm run duplication`   | Duplicate-code detection      |
| `pnpm run hygiene`       | Package and dependency checks |
| `pnpm run website:build` | Documentation website build   |

These are documented commands, not independently executed test results.

I also found a discrepancy worth investigating: the repository metadata reports size zero while its commit history contains files. Several expected root files returned 404. I would not certify the complete repository until this inconsistency and the actual tree are resolved.

## 4. Critical engineering risks

These are architectural risks to investigate, not confirmed vulnerabilities.

| Area         | Risk                                   | Required control                   |
| ------------ | -------------------------------------- | ---------------------------------- |
| Shell        | Arbitrary command execution            | Explicit execution policies        |
| SSH          | Remote privilege escalation            | Scoped credentials                 |
| Sandbox      | Container/process escape               | Strong isolation                   |
| Computer use | Unauthorized GUI actions               | User approval boundaries           |
| Browser use  | Prompt injection and data exfiltration | Untrusted-content isolation        |
| MCP          | Malicious external tools               | Tool authorization                 |
| Extensions   | Runtime modification                   | Signed and permissioned extensions |
| Credentials  | Secret exposure                        | Encrypted secret storage           |
| Subagents    | Authority propagation                  | Independent capability checks      |
| Jobs         | Uncontrolled background execution      | Quotas and cancellation            |

One particularly important point: a sandbox is not automatically a security boundary simply because it is called a sandbox.

The actual isolation mechanism, operating-system permissions, network controls and escape resistance must be tested.

## 5. How this relates to LMLM

This is where I see the greatest architectural opportunity.

LMLM should not simply become another agent wrapper.

Your existing architectural direction gives LMLM responsibility for its own intelligence, execution environment, internal agents and policy-controlled coordination across external systems.&#x20;

The architecture you supplied offers useful patterns for implementing that vision.

I would organize LMLM around these layers:

# LMLM

Sovereign Intelligence & Execution Environment

Central control plane

LMLM-Core

Reasoning, orchestration, agent lifecycle

LMLM-Models

Native models and provider adapters

LMLM-Execution

Sandbox, processes, terminals, PTC

LMLM-Agents

Subagents, delegation, workflows

LMLM-Memory

Sessions, context, storage, retrieval

LMLM-Security

Identity, policy, authorization, audit

LMLM Gateway & Adapter Fabric

MCP · ACP · SSH · Browser · APIs · Remote agents · Distributed systems

Authorized external environments

Computers · Servers · Networks · Cloud · Edge devices · Distributed infrastructure

### Recommended architectural decisions

| Decision                    | Recommendation                 |
| --------------------------- | ------------------------------ |
| Model abstraction           | Adopt                          |
| Durable sessions            | Adopt                          |
| Agent delegation            | Adopt                          |
| Workflow engine             | Adopt                          |
| Typed tool interfaces       | Adopt                          |
| Sandbox architecture        | Adopt, independently validate  |
| Browser/computer automation | Adapt behind permissions       |
| Extension self-modification | Restrict and audit             |
| Credential management       | Implement independently        |
| Remote execution            | Keep under LMLM policy control |

The important distinction: LMLM should own the control plane. External systems should receive narrowly scoped execution capabilities, not control over LMLM itself.

## 6. My recommended implementation order

1. Foundation

   LMLM-Core, session management, model interfaces, typed tool contracts.
2. Execution

   Process management, filesystem operations, sandbox, PTC runtime.
3. Agent intelligence

   Subagents, task planning, workflows, context compaction.
4. Security

   Identity, capabilities, authorization, credentials and audit trails.
5. Connectivity

   MCP, ACP, SSH, browser and computer-use adapters.
6. Distributed orchestration

   Remote agents, background jobs, scheduling and controlled execution across devices.
7. Interfaces

   Python SDK, Node SDK, desktop host, web client and developer API.

## 7. Final assessment

Architectural assessment

# Strong architectural foundation

Assessment of the supplied design, not a verified source-code quality score.

This is an ambitious agent runtime architecture with the right categories of infrastructure for a serious AI execution platform.

Its most valuable concepts for LMLM are:

1. PTC execution.
2. Typed capability interfaces.
3. Durable agent sessions.
4. Sandboxed execution.
5. Delegated agents.
6. Workflow and background-job management.
7. Remote execution adapters.

My strongest recommendation: use this architecture as an engineering reference for LMLM's runtime design, not as a replacement for LMLM-Core.

One more important distinction: despite the repository name `deepseek-ai`, the inspected evidence establishes an agent/runtime and developer-tooling direction. It does not establish that this repository contains DeepSeek model weights or a complete independently trained foundation model.

Next step: I recommend a full source-level audit of this repository, starting with `core`, `llm`, `ptc-runtime`, `sandbox`, `subagent`, `session`, and `credentials`, followed by its package dependency graph, native runtime, Python SDK and CI workflows. That will establish exactly which capabilities are implemented, which are incomplete, and which architectural ideas should inform LMLM.




I’m continuing with a source-level audit of `auraecosystem/deepseek-ai`, focusing on package implementation, execution boundaries, security-sensitive integrations, and CI evidence.

One correction to the earlier report: GitHub’s `size: 0` metadata is inconsistent with the repository’s active commit history and retrievable files. The repository is not empty. The remaining problem is that the connected GitHub interface is returning 404s for most root and package paths, so I’m checking commit-level evidence rather than treating those paths as absent.

# DeepSeek AI — extended execution audit

Partial source verification

Read-only inspection

Repository: [auraecosystem/deepseek-ai](https://github.com/auraecosystem/deepseek-ai?utm_source=chatgpt.com)\
Default branch: `main`

I retrieved additional commit diffs and successfully inspected the repository's agent command file and Node runtime decision record. The actual package source, root manifests, and workflow definitions remain inaccessible through the connected repository interface.

## 1. Verified findings

### Runtime and compatibility

The repository's engineering note, `.dhs/notes/implemented/process/node-24-runtime-floor.md`, specifies:

- Minimum supported Node.js: 24.9.0.
- Primary test coverage on Node 24.
- Compatibility testing on pinned Node 24.9 and Node 26.
- Node 22 installations must upgrade.
- Runtime dependencies include `node:sqlite`, native TypeScript stripping, and `import.meta.main`.
- The native addon has a separate runtime compatibility policy.

This is a deliberate compatibility strategy rather than an arbitrary version requirement.

Engineering concern: the note references private Node module-loader interfaces. These can change independently of public APIs. Keep compatibility tests around those interfaces and isolate their usage behind a small adapter.

### Build and testing strategy

The repository's command documentation describes these checks:

| Area                       | Documented command       |
| -------------------------- | ------------------------ |
| Unit tests                 | `pnpm run test`          |
| Coverage                   | `pnpm run test:coverage` |
| Type safety                | `pnpm run typecheck`     |
| Lint                       | `pnpm run lint`          |
| Build                      | `pnpm run build`         |
| Dependency/package hygiene | `pnpm run hygiene`       |
| Snapshot replay            | `pnpm run test:snapshot` |
| Real API integration       | `pnpm run test:e2e`      |
| Documentation              | `pnpm run test:docs`     |
| Website                    | `pnpm run website:build` |

The documented coverage target is 100% per file under `packages/*/*/src`.

These are documented test expectations, not verified test results. I did not execute the repository's build or test commands.

## 2. Issues identified

Finding 1 — Mixed-platform command file

High priority

`.agent/Command` combines an `ash` shebang and shell commands with a second PowerShell shebang and PowerShell instructions.

A file has one interpreter entry point. The second shebang does not switch interpreters halfway through execution.

Recommendation: split it into platform-specific files:

- `.agent/build.sh`
- `.agent/setup.ps1`
- `.agent/README.md`

Also clarify whether expressions such as `tsc -b <tsconfig.host.json references>` are illustrative placeholders or intended executable commands.

Finding 2 — Dynamic Git worktree creation

Security review required

The setup instructions fetch a repository and construct a Git worktree using environment variables:

```
git fetch "$DSH_SUPERAGENT_GITHUB_REPOSITORY" \
  "$DSH_SUPERAGENT_GITHUB_PR_HEAD:refs/dsh-superagent/$DSH_SUPERAGENT_TICKET"
```

Validate repository ownership, branch/ref syntax, destination paths, and allowed worktree roots. Untrusted values should not control arbitrary Git operations.

Finding 3 — Orchestrator configuration update

Security review required

The setup sequence reads a revision and sends a PUT request to a local orchestrator endpoint.

The revision-based update is a useful concurrency mechanism. However, the implementation should also verify:

- Authentication and authorization of the caller.
- Whether the request header is merely a routing marker or an actual security control.
- JSON-safe serialization of environment-provided values.
- Failure handling and revision conflicts.
- Whether the endpoint is protected against unauthorized local requests.

  Finding 4 — Runtime compatibility

  Architecture risk

  Private Node loader integration and a separately supported native addon introduce compatibility surfaces that need explicit version matrices.

Keep native binaries, Node runtime support, and loader-specific logic independently testable.

Finding 5 — Documentation completeness

Needs verification

The retrieved `@deepseek-ai/session-controller/README.md` is empty. This is a real documentation gap for that path, although I could not inspect the full documentation tree.

## 3. Architecture assessment

Based on the package responsibilities you supplied, this is a broad agent runtime with several important subsystems:

| Subsystem              | Responsibility              | Main engineering concern         |
| ---------------------- | --------------------------- | -------------------------------- |
| Core                   | Agent/session lifecycle     | State consistency                |
| API                    | Remote backend-for-frontend | Authentication and isolation     |
| Typert                 | Type graphs                 | Schema correctness               |
| LLM                    | Model providers             | Provider abstraction and secrets |
| PTC runtime            | Programmatic tool execution | Code isolation                   |
| Sandbox                | Execution containment       | Escape prevention                |
| Subagent               | Delegated agent execution   | Permission inheritance           |
| MCP                    | External tool connectivity  | Capability restrictions          |
| SSH / terminal         | Remote execution            | Command authorization            |
| Browser / computer use | GUI automation              | User consent and scope           |
| Storage / workspace    | Persistent state            | Tenant and path isolation        |
| Guard / credentials    | Security controls           | Policy enforcement               |

The most important security boundary is the transition from an agent's intent to an actual external action.

A model deciding to execute a command must not itself constitute authorization to execute that command.

## 4. Recommended security architecture

For a runtime with this many execution capabilities, I recommend a centralized authorization pipeline:

```
Agent / Subagent
      |
      v
  Task Planner
      |
      v
  Policy Evaluation
      |
      +---- Deny
      |
      +---- Require Approval
      |
      v
 Capability Validation
      |
      v
 Isolated Execution
      |
      v
 Output Validation
      |
      v
 Audit / Session Record
```

Every execution adapter should receive a scoped capability rather than unrestricted host access.

Examples:

- Filesystem adapter: authorized workspace paths only.
- Terminal adapter: command allowlists or constrained execution profiles.
- SSH adapter: approved hosts and credentials.
- Browser adapter: explicitly authorized sessions and domains.
- MCP adapter: individually granted tools and operations.
- Subagent adapter: permissions no greater than the delegating agent.

## 5. How this maps to LMLM

The architecture has useful patterns for LMLM, but the most important distinction must remain intact: LMLM should own its control plane.

## LMLM sovereign execution architecture

LMLM Control Plane

Policy · Identity · Planning · Orchestration · Audit

Model Fabric

Local models · Providers · Multimodal inference

Agent Runtime

Sessions · Plans · Subagents · Workflows

Execution Fabric

Sandbox · Terminal · Filesystem · Jobs

Memory Fabric

Context · Storage · Retrieval · State

Authorized Adapter Fabric

Internet · Devices · Networks · External platforms · Distributed agents

The key design rule: external systems may perform authorized work, but they must not become the authority that governs LMLM itself.

## 6. Execution status

| Audit activity             | Result         |
| -------------------------- | -------------- |
| Repository metadata        | Retrieved      |
| Commit history             | Retrieved      |
| Agent command instructions | Inspected      |
| Node runtime decision      | Inspected      |
| Root package manifest      | Blocked by 404 |
| Workspace package sources  | Blocked by 404 |
| CI workflow files          | Not verified   |
| Security implementation    | Not verified   |
| Build and tests            | Not executed   |
| Repository modifications   | None           |

Final assessment: The documented design shows a serious, ambitious agent-runtime architecture with a substantial testing strategy. The strongest areas to investigate next are execution isolation, delegated permissions, credential handling, and compatibility boundaries. The mixed-platform command file is the clearest directly evidenced maintenance defect.

I have not certified the repository as secure, production-ready, or passing CI. That would require inspecting the actual source files and running its checks.

Next practical step: provide a repository ZIP or source archive so I can inspect the actual workspace packages, trace the security-sensitive execution paths, and produce a complete implementation-level audit without guessing about inaccessible files.

DSH-superagent — Repository audit
Source files inspected
Research prototype

Repository: auraecosystem/DSH-superagent
Branch: main
Repository size: 799 KB
Version: 0.1.0
License: MIT

This repository is particularly interesting because it is not simply another chatbot. It implements a proactive, policy-governed coding agent that listens to GitHub and optionally Feishu, evaluates requests, creates authorized work items, executes them in separate agent sessions, and reports results through the original conversation.

Its README explicitly warns that it is a research prototype, not production-ready software or an official DeepSeek product.
1. What the system actually does







niebex.com


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
2. Verified implementation
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



Ready. What should I execute against `auraecosystem/DSH-superagent`?

My recommended next step is to design and implement the LMLM integration blueprint: extract the Mandate Engine, Policy Engine, Ticket Engine, Agent Scheduler, and governed Execution Fabric concepts while keeping LMLM's control plane independent.

I’ll inspect the actual LMLM repository before proposing or changing any code. Which LMLM repository should I target?
