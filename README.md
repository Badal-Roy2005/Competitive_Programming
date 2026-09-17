# Competitive Programming Lab — Practical Codes

Welcome to the **Competitive Programming Lab** submission repository!

This repository collects all lab practical programs. Students submit by **forking, pushing, and done** — the system creates your Pull Request automatically.

> **🚀 New? Read the 2-minute guide below. You do NOT need to create a Pull Request manually. You do NOT need to request collaborator access. Just fork, push, done.**

---

## ⚡ Quick Start (Students — 4 Steps)

### 1. Fork this repository — ONCE

Click the **Fork** button at the top-right of this page. This creates your own copy: `https://github.com/<YOUR-USERNAME>/Competitive_Programming`.

> You only fork **once** for the entire semester.

### 2. Clone YOUR fork

```bash
git clone https://github.com/<YOUR-USERNAME>/Competitive_Programming.git
cd Competitive_Programming
```

### 3. Create your directory and add code

Inside the correct practical folder, create a folder with **your name** (or University ID as instructed):

```text
Practical-01/
└── Ankan-Mondal/
    ├── question1.cpp
    ├── question2.cpp
    └── question3.cpp
```

Rules:
- Folder must be `Practical-01/YourName/` (two digits: `01`–`10`)
- One folder per student per practical — do not mix students
- Only source files: `.cpp`, `.c`, `.py`, `.java` (see `CONTRIBUTING.md`)
- Do NOT add `.exe`, `.out`, `.class`, `.vscode/`, `node_modules/`, etc.

### 4. Commit and Push — You are DONE

```bash
git add Practical-01/Ankan-Mondal/
git commit -m "Add Practical 01 - Ankan Mondal"
git push origin main
```

**That's it. Stop here.**

- ✅ The automation will detect your push and **automatically create a Pull Request** titled `Submission: Practical 01 - <your-username>` in the original repository within **~10 minutes** (instant if you enabled Actions in your fork — see below).
- ✅ Subsequent pushes to the same practical update the **same PR** — no duplicates.
- ✅ Automated checks (structure, file type, compilation) run on your PR and post results as a comment.
- ✅ Wait for the owner to review and merge.

> **DO NOT click "Compare & pull request" or "Create pull request". The system does it for you. Creating a manual PR will duplicate it.**

#### Optional: Instant PR (<30 seconds)

By default, GitHub disables workflows in new forks. Your PR will still be created by the upstream poller within 10 minutes. For **instant** creation:

1. Go to your fork on GitHub → **Actions** tab → click **"I understand my workflows, go ahead and enable them"** (one-time).
2. Push again — PR appears in <30 seconds.

This step is **optional** — never required.

---

## 📂 Repository Structure

```text
Competitive_Programming/
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
├── submission-config.yml   # allowed extensions & limits (owner can edit)
├── CONTRIBUTING.md         # detailed rules & troubleshooting
└── README.md
```

---

## 🔄 How Automation Works

```text
You push to YOUR fork
        │
        ▼
┌─────────────────────────┐
│ Instant path (fork)     │  Auto PR workflow in your fork (if enabled)
│ Poll path (upstream)    │  Upstream cron every 10m scans all forks
└─────────┬───────────────┘
          ▼
  PR created: "Submission: Practical 01 - your-username"
          │
          ▼
  Validate submission (on PR):
    • Directory structure
    • Allowed extensions (.cpp .c .py .java)
    • Compilation per file (g++, gcc, javac, python)
    • Prohibited files / size / protected paths
          │
          ▼
  Comment + labels posted (auto-validated / needs-fix)
          │
          ▼
  Owner reviews & merges
```

- See [CONTRIBUTING.md](CONTRIBUTING.md) for validation details.
- See `submission-config.yml` for current limits (max 5 MB/file, 50 MB total).

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
| PR not appearing after push | Wait 10 minutes (poller). Check you pushed to **your fork's `main`**, not upstream. Ensure files are under `Practical-XX/YourName/`. |
| Validation failed | Read the bot comment on your PR — fix structure/extension/compilation and `git push` again (same PR updates). |
| Accidentally edited `.github/` | Remove those changes, commit, push. |
| Need to submit Practical-02 | Same steps: `mkdir Practical-02/YourName` → add files → push. With default config it updates same PR; after merge, next push creates new PR. |

More help: [CONTRIBUTING.md](CONTRIBUTING.md) → Troubleshooting section.

---

## 👨‍🏫 For the Owner

One-time setup (after cloning this repo):

1. `Settings` → `Branches` → Protect `main`: require PR, require status check `validate`, block force push.
2. `Settings` → `Actions` → `General` → ✅ **Allow GitHub Actions to create and approve pull requests**.
3. `Actions` tab → Enable workflows, run **Poll Forks & Create PRs** once to test.
4. Done — no per-student setup.

Fork enumeration uses `GITHUB_TOKEN` — no PAT required unless >100 forks (rate limit).

---

> **Code it. Understand it. Improve it. 🚀**
