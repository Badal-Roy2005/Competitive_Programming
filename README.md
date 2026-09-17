# Competitive Programming Lab — Practical Codes

Welcome to the **Competitive Programming Lab** submission repository!

**Upstream (original) repository:** `https://github.com/ankan-web/Competitive_Programming`

This repository collects all lab practical programs. Students submit by **forking ankan-web/Competitive_Programming, pushing to their fork, and done** — the system creates your Pull Request to `ankan-web/Competitive_Programming` automatically.

> **🚀 New? Read the 2-minute guide below. You do NOT need to create a Pull Request manually. You do NOT need to request collaborator access. Just fork ankan-web/Competitive_Programming, push, done.**

---

## ⚡ Quick Start (Students — 4 Steps)

### 1. Fork ankan-web/Competitive_Programming — ONCE

Open `https://github.com/ankan-web/Competitive_Programming` in your browser.

Click the **Fork** button (top-right) → **Create fork**.

This creates your own copy: `https://github.com/<YOUR-USERNAME>/Competitive_Programming` forked from `ankan-web/Competitive_Programming`.

> You only fork **once** for the entire semester. All future practicals use the same fork.

### 2. Clone YOUR fork (not ankan-web)

Copy **YOUR fork URL** (`https://github.com/<YOUR-USERNAME>/Competitive_Programming.git`):

```bash
git clone https://github.com/<YOUR-USERNAME>/Competitive_Programming.git
cd Competitive_Programming
```

Verify the remote points to **you**, not ankan-web:

```bash
git remote -v
# origin  https://github.com/<YOUR-USERNAME>/Competitive_Programming.git (fetch)
# origin  https://github.com/<YOUR-USERNAME>/Competitive_Programming.git (push)
```

If it shows `ankan-web`, fix it:
```bash
git remote set-url origin https://github.com/<YOUR-USERNAME>/Competitive_Programming.git
```

> Optional: keep upstream reference to pull latest practical folders:
> ```bash
> git remote add upstream https://github.com/ankan-web/Competitive_Programming.git
> ```

### 3. Create your directory and add code

Inside the correct practical folder, create a folder with **your name** (or University ID as instructed by ankan-web):

```text
Practical-01/
└── Ankan-Mondal/
    ├── question1.cpp
    ├── question2.cpp
    └── question3.cpp
```

Example:
```bash
mkdir -p Practical-01/Ankan-Mondal
# now copy your .cpp/.c/.py/.java files into Practical-01/Ankan-Mondal/
```

Rules:
- Folder must be `Practical-01/YourName/` (two digits: `01`–`10`)
- One folder per student per practical — do not mix students
- Only source files: `.cpp`, `.c`, `.py`, `.java` (see `CONTRIBUTING.md`)
- Do NOT add `.exe`, `.out`, `.class`, `.vscode/`, `node_modules/`, etc.
- Do NOT edit `.github/`, `scripts/`, `submission-config.yml` — those are owned by ankan-web

### 4. Commit and Push to YOUR fork — You are DONE

```bash
git add Practical-01/Ankan-Mondal/
git commit -m "Add Practical 01 - Ankan Mondal"
git push origin main
```

**That's it. Stop here.**

- ✅ The automation will detect your push to `https://github.com/<YOUR-USERNAME>/Competitive_Programming` and **automatically create a Pull Request** titled `Submission: Practical 01 - <your-username>` in `https://github.com/ankan-web/Competitive_Programming` within **~10 minutes** (instant if you enabled Actions in your fork — see below).
- ✅ Subsequent pushes to the same practical update the **same PR** — no duplicates.
- ✅ Automated checks (structure, file type, compilation) run on your PR in `ankan-web/Competitive_Programming` and post results as a comment.
- ✅ Wait for **ankan-web** (owner) to review and merge.

> **DO NOT click "Compare & pull request" or "Create pull request" on GitHub. The system does it for you. Creating a manual PR to ankan-web/Competitive_Programming will duplicate it.**

#### Optional: Instant PR (<30 seconds)

By default, GitHub disables workflows in new forks. Your PR will still be created by the upstream `ankan-web/Competitive_Programming` poller within 10 minutes. For **instant** creation:

1. Go to **your fork** `https://github.com/<YOUR-USERNAME>/Competitive_Programming` → **Actions** tab → click **"I understand my workflows, go ahead and enable them"** (one-time).
2. Push again — PR appears in `ankan-web/Competitive_Programming` in <30 seconds.

This step is **optional** — never required.

---

## 📂 Repository Structure

```text
ankan-web/Competitive_Programming/
│
├── Practical-01/
│   ├── Ankan-Mondal/
│   │   ├── binary_search.cpp
│   │   └── linear_search.cpp
│   ├── Rahul-Sharma/
│   │   └── sorting.cpp
│   └── .gitkeep
│
├── Practical-02/
│   └── ...
│
├── Practical-10/
│   └── ...
│
├── .github/
│   └── workflows/          # automation (do not edit)
├── scripts/                # validation scripts (do not edit)
├── submission-config.yml   # allowed extensions & limits (owner ankan-web can edit)
├── HOW_TO_USE.md           # full walkthrough
├── CONTRIBUTING.md         # detailed rules & troubleshooting
└── README.md               # this file
```

---

## 🔄 How Automation Works

```text
You push to https://github.com/<YOUR-USERNAME>/Competitive_Programming (your fork)
        │
        ▼
┌─────────────────────────┐
│ Instant path (fork)     │  .github/workflows/auto-pr-from-fork.yml in your fork (if enabled)
│ Poll path (upstream)    │  Upstream ankan-web/Competitive_Programming cron every 10m scans all forks
└─────────┬───────────────┘
          ▼
  PR created in ankan-web/Competitive_Programming:
  "Submission: Practical 01 - your-username"
          │
          ▼
  Validate submission (on PR to ankan-web/Competitive_Programming):
    • Directory structure
    • Allowed extensions (.cpp .c .py .java)
    • Compilation per file (g++, gcc, javac, python)
    • Prohibited files / size / protected paths
          │
          ▼
  Comment + labels posted in ankan-web/Competitive_Programming
  (auto-validated / needs-fix)
          │
          ▼
  ankan-web reviews & merges
```

- See [CONTRIBUTING.md](CONTRIBUTING.md) for validation details.
- See `submission-config.yml` for current limits (max 5 MB/file, 50 MB total).
- Full walkthrough: [HOW_TO_USE.md](HOW_TO_USE.md)

---

## 📝 Coding Guidelines

1. Use **C++** unless the lab requires another language.
2. One problem = one file.
3. Meaningful names: `binary_search.cpp` ✅, `final_final.cpp` ❌
4. Test and ensure your code compiles before pushing.
5. Do not copy without understanding.

---

## ❓ Troubleshooting

| Problem | Fix |
|---------|-----|
| PR not appearing after push | Wait 10 minutes (poller in ankan-web/Competitive_Programming). Check you pushed to **your fork's `main`** (`git remote -v` must show `<YOUR-USERNAME>`, not `ankan-web`). Ensure files are under `Practical-XX/YourName/`. Or enable Actions in your fork for instant PR. Check `https://github.com/ankan-web/Competitive_Programming/pulls` filtered by your username. |
| Validation failed | Open your PR in `ankan-web/Competitive_Programming` → read bot comment `Automated Validation Results` → fix structure/extension/compilation and `git push` again (same PR updates). |
| Accidentally edited `.github/` | `git checkout -- .github/ scripts/ submission-config.yml` → commit → push. |
| Need to submit Practical-02 | Same steps: `mkdir Practical-02/YourName` → add files → `git add` → commit → `git push origin main` to your fork. With default config it updates same PR until ankan-web merges; then next push creates new PR. |

More help: [HOW_TO_USE.md](HOW_TO_USE.md) and [CONTRIBUTING.md](CONTRIBUTING.md) → Troubleshooting section.

---

## 👨‍🏫 For the Owner (ankan-web)

One-time setup after `git push` to `ankan-web/Competitive_Programming`:

1. `Settings → Branches → Protect main`: require PR, require status check `validate`, block force push.
2. `Settings → Actions → General → ✅ Allow GitHub Actions to create and approve pull requests`.
3. `Actions` tab → Enable workflows, run **Poll Forks & Create PRs** once to test (`Found 0 fork(s)` = success).
4. Done — no per-student setup. Fork enumeration uses `GITHUB_TOKEN` — no PAT needed unless >100 forks.

See [HOW_TO_USE.md](HOW_TO_USE.md) §2 for full owner steps.

---

> **Code it. Understand it. Improve it. 🚀**
> Upstream: `https://github.com/ankan-web/Competitive_Programming`
