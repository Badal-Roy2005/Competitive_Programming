#!/usr/bin/env python3
"""
compile_check.py — compile each C/C++ file in isolation, validate Python/Java syntax.
Never mixes multiple programs together.
Writes compile_result.txt (machine) and compile_summary.md (human).
"""
import os, subprocess, pathlib, sys, py_compile, shutil, re

CONFIG = "submission-config.yml"

# Find changed files: use git diff vs origin/main if available
def get_changed_files():
    for cmd in [
        ["git","diff","--name-only","--diff-filter=ACMRT","origin/main...HEAD"],
        ["git","diff","--name-only","--diff-filter=ACMRT","HEAD~1"],
        ["git","ls-files"],
    ]:
        try:
            out = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL)
            files = [f.strip() for f in out.splitlines() if f.strip()]
            if files:
                # filter to Practical-*
                prac = [f for f in files if f.startswith("Practical-")]
                return prac if prac else files
        except:
            continue
    # fallback find
    files=[]
    for p in pathlib.Path(".").glob("Practical-*/*/*"):
        if p.is_file():
            files.append(str(p).replace("\\","/"))
    return files

def has_tool(name):
    return shutil.which(name) is not None

changed = get_changed_files()
print(f"Changed files for compile: {changed}")

# Load allowed compile extensions from config (fallback)
compile_exts = {"cpp","c"}
try:
    with open(CONFIG) as f:
        txt=f.read()
        m=re.search(r"compile_extensions:\s*\n((?:\s*-\s*\w+\n)+)", txt)
        if m:
            compile_exts=set(re.findall(r"-\s*(\w+)", m.group(1)))
except:
    pass

results=[]
failures=0

for f in changed:
    if not os.path.isfile(f):
        continue
    ext = pathlib.Path(f).suffix.lstrip(".").lower()
    if ext not in compile_exts and ext not in ("py","java"):
        continue
    # Skip gitkeep
    if os.path.basename(f) == ".gitkeep":
        continue

    if ext == "cpp":
        if not has_tool("g++"):
            results.append((f, "SKIP", "g++ not available on runner"))
            continue
        # Compile each file isolated: produce object file only, never link together
        cmd = ["g++", "-std=c++17", "-O2", "-Wall", "-c", f, "-o", "/tmp/a.o"]
        # Add extra check: syntax only
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if proc.returncode==0:
            results.append((f,"PASS","Compiled successfully"))
        else:
            failures+=1
            out = (proc.stderr or proc.stdout)[:2000]
            results.append((f,"FAIL", out.strip()))

    elif ext == "c":
        if not has_tool("gcc"):
            results.append((f,"SKIP","gcc not available"))
            continue
        cmd = ["gcc","-O2","-Wall","-c", f, "-o","/tmp/a.o"]
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if proc.returncode==0:
            results.append((f,"PASS","Compiled successfully"))
        else:
            failures+=1
            out=(proc.stderr or proc.stdout)[:2000]
            results.append((f,"FAIL", out.strip()))

    elif ext == "py":
        try:
            py_compile.compile(f, doraise=True)
            results.append((f,"PASS","Syntax OK"))
        except py_compile.PyCompileError as e:
            failures+=1
            results.append((f,"FAIL", str(e.msg)[:2000]))
        except Exception as e:
            failures+=1
            results.append((f,"FAIL", str(e)[:2000]))

    elif ext == "java":
        if not has_tool("javac"):
            results.append((f,"SKIP","javac not available"))
            continue
        cmd=["javac","-d","/tmp", f]
        proc=subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if proc.returncode==0:
            results.append((f,"PASS","javac OK"))
        else:
            failures+=1
            results.append((f,"FAIL", (proc.stderr or proc.stdout)[:2000]))

# Write results
with open("compile_result.txt","w", encoding="utf-8") as out:
    out.write(f"COMPILE_STATUS={'FAIL' if failures>0 else 'PASS'}\n")
    out.write(f"COMPILE_FAILURES={failures}\n")
    out.write(f"COMPILE_TOTAL={len(results)}\n")
    for f,s,msg in results:
        out.write(f"{s}: {f}\n")

with open("compile_summary.md","w", encoding="utf-8") as md:
    md.write("### Compilation Check\n\n")
    if not results:
        md.write("No compilable files detected (no `.cpp`/`.c`/`.py`/`.java` in changed Practical-* files).\n\n")
    else:
        md.write(f"Checked **{len(results)}** file(s) — each compiled **in isolation** (no multi-file linking).\n\n")
        md.write("| File | Result | Details |\n")
        md.write("|------|--------|---------|\n")
        for f,s,msg in results:
            detail = msg.splitlines()[0][:120].replace("|","/") if msg else ""
            icon = "✅" if s=="PASS" else ("⚪" if s=="SKIP" else "❌")
            md.write(f"| `{f}` | {icon} {s} | {detail} |\n")
        md.write("\n")
        # Full errors
        fails=[r for r in results if r[1]=="FAIL"]
        if fails:
            md.write("<details><summary>Compilation errors (full)</summary>\n\n")
            for f,s,msg in fails:
                md.write(f"**{f}:**\n```\n{msg[:3000]}\n```\n")
            md.write("</details>\n\n")
        if failures>0:
            md.write(f"> ❌ **{failures} file(s) failed to compile.** Fix errors and push again.\n")
        else:
            md.write("> ✅ **All compilable files passed.**\n")

print(open("compile_summary.md", encoding="utf-8").read())
print("---")
print(open("compile_result.txt", encoding="utf-8").read())
