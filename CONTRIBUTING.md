# Contributing — Competitive Programming Lab

This guide is for **students**. Read it once before your first submission.

## 1. Student Workflow (Only What You Do)

```bash
# Once per semester
# 1. On GitHub, click Fork (top-right) on ankan-web/Competitive_Programming

# 2. Clone YOUR fork
git clone https://github.com/<YOUR-USERNAME>/Competitive_Programming.git
cd Competitive_Programming

# 3. Create your folder inside the correct practical
mkdir -p Practical-01/Ankan-Mondal
# add your source files there
# e.g. Practical-01/Ankan-Mondal/question1.cpp

# 4. Commit & push
git add Practical-01/Ankan-Mondal/
git commit -m "Add Practical 01 - Ankan Mondal"
git push origin main
# DONE — do NOT create a PR manually
```

After `git push`, the system **automatically** creates a Pull Request `Submission: Practical 01 - <your-username>` in the original repository within ~10 minutes (instant if you enabled Actions in your fork's `Actions` tab). Further pushes update the same PR.

---

## 2. Folder & File Naming

### Practical directories (fixed)

```
Practical-01/
Practical-02/
...
Practical-10/
```

- Must be exactly `Practical-` + two digits (`01`–`10`). `Practical-1` ❌, `practical-01` ❌, `Practicals` ❌.
- Do not create new top-level folders. Do not place files at repo root.

### Student directory

```
Practical-01/<YourName>/
```

- Use your real name or University ID as instructed by the owner. Example: `Ankan-Mondal`, `CSE2021_045`.
- One folder per student. Do not put your files in another student's folder.
- Keep the same spelling every time (case-sensitive).

### File names

- Recommended: `binary_search.cpp`, `linear_search.py`, `q1_two_sum.java` ✅
- Avoid: `final.cpp`, `code1.cpp`, `temp.cpp` ❌
- Keep each problem in a separate file.

### Example

```
Practical-01/
├── Ankan-Mondal/
│   ├── binary_search.cpp
│   ├── bubble_sort.cpp
│   └── linear_search.cpp
└── .gitkeep
```

---

## 3. Supported Languages & Extensions

Allowed (see `submission-config.yml`):

```
.cpp  .c  .py  .java
```

All other extensions are rejected (e.g., `.txt`, `.pdf`, `.docx`).

---

## 4. Prohibited Files (Auto-Rejected)

The following are **never** allowed and will fail validation:

```
*.exe  *.out  *.o  *.obj  *.class  *.pyc  *.log
__pycache__/  .vscode/  .idea/  node_modules/  .DS_Store
```

Also blocked from PRs:

```
.github/  scripts/  submission-config.yml
```

Do not edit repository configuration.

### Size limits

- Max **5 MB per file**, **50 MB total** per PR (configurable by owner).

---

## 5. What Happens After You Push

1. **PR creation**
   - Upstream cron scans all forks every 10 minutes and creates `Submission: Practical XX - <username>` if it sees `Practical-XX` changes ahead of `main`. If you enabled Actions in your fork, a fork-side workflow creates it instantly.
   - Idempotent: pushing again updates the same PR (no duplicates) and reruns checks.

2. **Automated validation** (runs on every PR)

   | Check | What it does |
   |---|---|
   | Directory structure | Ensures `Practical-XX/YourName/file.ext` |
   | Allowed extensions | Only `.cpp .c .py .java` |
   | Prohibited files | Blocks binaries/IDE folders |
   | Size | Enforces limits |
   | Protected paths | Blocks edits to `.github/`, `scripts/` |
   | Compilation | Compiles each `.cpp`/`.c` **individually** (`g++ -c`, `gcc -c`), `py_compile` for Python, `javac` for Java — never links multiple programs together |

3. **Results**
   - A bot comment `Automated Validation Results` appears on your PR with pass/fail per check.
   - Labels: `auto-validated` / `ready-for-review` on success, `needs-fix` on failure.
   - Required status check `validate` must pass before merge.

---

## 6. How to Handle Common Errors

### "Directory structure" failed

Cause: File not under `Practical-XX/YourName/`.

Fix:
```bash
git mv misplaced.cpp Practical-01/Ankan-Mondal/misplaced.cpp
git commit -m "Fix structure"
git push
```

### "Prohibited file type" / ".exe not allowed"

You committed a compiled binary.

```bash
git rm --cached Practical-01/Ankan-Mondal/a.exe Practical-01/Ankan-Mondal/a.out
echo "*.exe" >> .gitignore  # or rely on repo .gitignore
git commit -m "Remove binaries"
git push
```

### "Compilation failed"

Read the `Compilation Check` table in the bot comment — it shows the compiler error per file. Fix locally:

```bash
g++ -std=c++17 -Wall -c Practical-01/Ankan-Mondal/problem1.cpp -o /tmp/test.o
# fix errors, then push again
```

Each `problem1.cpp` / `problem2.cpp` is a separate program — do **not** `#include "problem2.cpp"`.

### "File too large"

Split or reduce the file. Large test data should not be committed.

### "Protected path" edit

You modified `.github/` or `submission-config.yml`.

```bash
git checkout origin/main -- .github/ submission-config.yml scripts/
git commit -m "Revert protected paths"
git push
```

---

## 7. Multiple Practicals

- Default config (`per_practical_pr: false`): one PR per fork branch aggregates all practicals. Pushing `Practical-02` while `Practical-01` PR is open **updates the same PR** (title expands to `Practical-01, Practical-02`). After the PR is merged, the next push creates a fresh PR.

- If owner sets `per_practical_pr: true`: automation creates a separate branch/PR per practical (e.g., `submission/practical-02`). You still just push to `main`; it splits automatically.

You do not need to create branches manually.

---

## 8. Ownership & Multiple Students

- Only submit under **your own** `Practical-XX/YourName/` directory.
- The system warns (not blocks) if the folder name doesn't match your GitHub username — naming convention is enforced by review, not by insecure auto-blocking.
- Many students can submit simultaneously; each fork gets its own PR (`Ankan → PR #10`, `Rahul → PR #11`, ...).

---

## 9. Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| No PR after 15 minutes | Pushed to upstream (no write) or files outside `Practical-*` | `git remote -v` should show `YOUR-USERNAME`, not `ankan-web`. Check `git log --oneline -3`. Fix path and push to `origin main` on your fork. |
| Duplicate PRs | Manually created PR + auto PR | Close manual PR. Auto PR is idempotent — one per `fork:branch`. |
| PR not updating after push | Pushed to different branch | Push to the same branch the PR was created from (`main`). Check `git branch`. |
| Actions banner "Workflows disabled" | GitHub disables fork workflows by default | Optional: enable via `Actions` tab for instant PRs, otherwise wait for poller. |
| Checks stuck "Waiting for status" | Fork PR needs approval on first run | Owner approves in `Actions` tab if required. |

---

## 10. Do NOT Do These

- ❌ Do not create a PR manually via "Compare & pull request".
- ❌ Do not push directly to `ankan-web/Competitive_Programming` (protected).
- ❌ Do not request collaborator access.
- ❌ Do not share tokens/secrets.
- ❌ Do not edit `.github/workflows/` or `scripts/`.

Just **Fork → Clone → Code → Add → Commit → Push → Done**.

---

## 11. Questions?

Open an issue in this repository or contact the lab instructor. Include your fork URL, branch, and the bot comment from your PR.

Happy Coding! 💻🔥
