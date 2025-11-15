import os, json, time, subprocess, uuid, signal
from http.server import BaseHTTPRequestHandler, HTTPServer

BASE = os.path.abspath(os.path.dirname(__file__) + "/..")
QUEUE_DIR = os.path.join(BASE, "queue")
MODULE_DIR = os.path.join(BASE, "agents", "modules")
ARTIFACTS = os.path.join(BASE, "artifacts")
LOGS = os.path.join(BASE, "logs")
RUN = os.path.join(BASE, "run")
POLICY = os.path.join(BASE, "policies", "agent_policy.json")
REPORT = os.path.join(BASE, "start", "agent_report.json")

os.makedirs(QUEUE_DIR, exist_ok=True)
os.makedirs(ARTIFACTS, exist_ok=True)
os.makedirs(LOGS, exist_ok=True)
os.makedirs(RUN, exist_ok=True)
os.makedirs(os.path.dirname(REPORT), exist_ok=True)

DEFAULT_POLICY = {
  "max_retries": 2,
  "retry_backoff_sec": 10,
  "concurrency": 1,
  "timeout_sec": 1800
}

def load_policy():
  if os.path.exists(POLICY):
    try:
      with open(POLICY) as f: return json.load(f)
    except: return DEFAULT_POLICY
  return DEFAULT_POLICY

def list_tasks():
  return sorted([f for f in os.listdir(QUEUE_DIR) if f.endswith(".task.json")])

def run_module(task):
  t_id = task.get("id") or str(uuid.uuid4())
  mod = task["module"]
  params = task.get("params", {})
  env = os.environ.copy()
  for k, v in params.items():
    if isinstance(v, (dict, list)):
      env[f"TASK_PARAM_{k}"] = json.dumps(v)
    else:
      env[f"TASK_PARAM_{k}"] = str(v)
  script_map = {
    "text": os.path.join(MODULE_DIR, "train_text.sh"),
    "code": os.path.join(MODULE_DIR, "train_code.sh"),
    "audio": os.path.join(MODULE_DIR, "train_audio.sh"),
    "vision": os.path.join(MODULE_DIR, "train_vision.sh")
  }
  script = script_map.get(mod)
  if not script or not os.path.exists(script):
    return {"id": t_id, "module": mod, "status": "error", "error": "module script missing"}
  out_log = os.path.join(LOGS, f"agent_{mod}_{t_id}.log")
  with open(out_log, "a") as lf:
    lf.write(f"[BOOT] start task {t_id} module {mod}\n")
  try:
    proc = subprocess.Popen([script], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env, text=True)
    start = time.time()
    lines = []
    timeout = load_policy()["timeout_sec"]
    while True:
      if proc.poll() is not None: break
      line = proc.stdout.readline()
      if line: lines.append(line); open(out_log, "a").write(line)
      if time.time() - start > timeout:
        proc.terminate()
        return {"id": t_id, "module": mod, "status": "timeout", "seconds": int(time.time()-start)}
      time.sleep(0.1)
    rc = proc.returncode
    for line in proc.stdout.readlines():
      lines.append(line); open(out_log, "a").write(line)
    status = "ok" if rc == 0 else "error"
    return {"id": t_id, "module": mod, "status": status, "rc": rc, "log": out_log}
  except Exception as e:
    return {"id": t_id, "module": mod, "status": "error", "error": str(e)}

def write_report(snapshot):
  try:
    with open(REPORT, "w") as f: json.dump(snapshot, f, indent=2)
  except: pass

def process_queue():
  pol = load_policy()
  snapshot = {"ts": int(time.time()), "policy": pol, "results": []}
  for fname in list_tasks():
    path = os.path.join(QUEUE_DIR, fname)
    try:
      task = json.load(open(path))
    except:
      snapshot["results"].append({"id": fname, "status": "error", "error": "bad json"})
      os.remove(path); continue
    attempts = 0
    res = None
    while attempts <= pol["max_retries"]:
      res = run_module(task)
      if res["status"] == "ok": break
      attempts += 1
      time.sleep(pol["retry_backoff_sec"])
    res["attempts"] = attempts + 1
    snapshot["results"].append(res)
    try: os.remove(path)
    except: pass
  write_report(snapshot)
  return snapshot

class Handler(BaseHTTPRequestHandler):
  def do_GET(self):
    if self.path == "/health":
      self.send_response(200); self.send_header("Content-Type","application/json"); self.end_headers()
      self.wfile.write(json.dumps({"status":"ok","service":"agent"}).encode())
    elif self.path == "/report":
      self.send_response(200); self.send_header("Content-Type","application/json"); self.end_headers()
      try: self.wfile.write(open(REPORT,"rb").read())
      except: self.wfile.write(json.dumps({"status":"empty"}).encode())
    else:
      self.send_response(200); self.end_headers(); self.wfile.write(b"Agent Manager")
  def log_message(self, fmt, *args): pass

def serve_http(port):
  httpd = HTTPServer(("127.0.0.1", port), Handler)
  httpd.serve_forever()

def main():
  port = int(os.environ.get("AGENT_PORT","5255"))
  pidfile = os.path.join(RUN, "agent.pid")
  open(pidfile,"w").write(str(os.getpid()))
  # background HTTP health server
  import threading
  threading.Thread(target=serve_http, args=(port,), daemon=True).start()
  open(os.path.join(LOGS,"agent.log"),"a").write(f"[BOOT] agent started on {port}\n")
  while True:
    snapshot = process_queue()
    open(os.path.join(LOGS,"agent.log"),"a").write(f"[SNAPSHOT] {json.dumps(snapshot)}\n")
    time.sleep(int(os.environ.get("AGENT_POLL_SEC","10")))

if __name__ == "__main__":
  main()
