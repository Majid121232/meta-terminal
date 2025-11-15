#!/bin/sh
# Backend with /health endpoint and PID file
PORT="${BACK_PORT:-5253}"
LOG="logs/backend.log"
PIDFILE="run/backend.pid"
mkdir -p logs run

cat > start/_backend_app.py <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
import json

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type","application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status":"ok","service":"backend"}).encode())
        else:
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Backend service running")
    def log_message(self, fmt, *args): pass

def main():
    import os
    port = int(os.environ.get("PORT","5253"))
    srv = HTTPServer(("127.0.0.1", port), Handler)
    srv.serve_forever()

if __name__ == "__main__":
    main()
PY

if ! command -v python3 >/dev/null 2>&1; then
  echo "[✘] python3 not found" >>"$LOG"; exit 1
fi

python3 start/_backend_app.py >>"$LOG" 2>&1 &
echo $! > "$PIDFILE"
# keep wrapper alive to ensure orchestrator PID continuity if needed
tail -f /dev/null
