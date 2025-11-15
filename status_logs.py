#!/usr/bin/env python3
# ============================================
# Meta-Terminal Status & Log Monitor
# Inspired by advanced logging scripts (acidvegas/apv, Log-Analysis-Script, pymon)
# ============================================

import os, time, psutil, logging, json, subprocess

# --- Logging setup ---
LOGDIR = "logs"
REPORT = "start/report.json"
os.makedirs(LOGDIR, exist_ok=True)

logging.basicConfig(
    filename=os.path.join(LOGDIR, "monitor.log"),
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(message)s",
)

# --- Helper functions ---
def read_pid(pidfile):
    try:
        with open(pidfile) as f:
            return int(f.read().strip())
    except Exception:
        return None

def check_process(name, pidfile):
    pid = read_pid(pidfile)
    if pid and psutil.pid_exists(pid):
        proc = psutil.Process(pid)
        cpu = proc.cpu_percent(interval=0.1)
        mem = proc.memory_info().rss / (1024*1024)
        logging.info(f"{name} running (PID {pid}) CPU={cpu}% MEM={mem:.2f}MB")
        return {"status":"running","pid":pid,"cpu":cpu,"mem":mem}
    else:
        logging.error(f"{name} not running or invalid PID")
        return {"status":"stopped"}

def tail_log(logfile, lines=10):
    try:
        with open(logfile) as f:
            return f.readlines()[-lines:]
    except Exception:
        return []

def auto_recover(name, start_cmd):
    logging.warning(f"Attempting auto-recovery for {name}...")
    try:
        subprocess.Popen(start_cmd, shell=True)
        logging.info(f"{name} restarted successfully")
    except Exception as e:
        logging.error(f"Recovery failed for {name}: {e}")

# --- Main monitor ---
def main():
    status = {}
    status["backend"] = check_process("Backend","backend.pid")
    status["frontend"] = check_process("Frontend","frontend.pid")

    # Tail logs for errors
    for svc, logfile in {"backend":"logs/backend.log","frontend":"logs/frontend.log"}.items():
        lines = tail_log(logfile)
        for line in lines:
            if "ERROR" in line or "Exception" in line:
                logging.error(f"{svc} error detected: {line.strip()}")
                auto_recover(svc, f"./start/start_{svc}.sh")

    # Write JSON report
    with open(REPORT,"w") as f:
        json.dump(status,f,indent=2)

if __name__=="__main__":
    while True:
        main()
        time.sleep(30)  # check every 30s
