#!/usr/bin/env bash
# ============================================
# bootstrap_start.sh - ساخت پوشه‌ها و اسکریپت‌های start
# مخصوص لینوکس Alpine
# ============================================

set -euo pipefail

BASE_DIR="$HOME/meta-terminal/start"
mkdir -p "$BASE_DIR"

echo ">>> ساخت پوشه start در $BASE_DIR"

# لیست 30 فایل پیشنهادی
files=(
  "start.sh"
  "stop_all.sh"
  "status.sh"
  "install_python.sh"
  "install_node.sh"
  "install_docker.sh"
  "setup_env.sh"
  "start_backend.sh"
  "start_frontend.sh"
  "restart.sh"
  "health_check.sh"
  "tail_logs.sh"
  "backup.sh"
  "restore.sh"
  "update.sh"
  "clean.sh"
  "report.sh"
  "monitor.sh"
  "start_inference.sh"
  "start_agents.sh"
  "start_eval.sh"
  "start_dashboard.sh"
  "start_tests.sh"
  "start_dev.sh"
  "start_prod.sh"
  "start_docker.sh"
  "start_orchestrator.sh"
  "start_ai.sh"
  "init_logs.sh"
  "check_env.sh"
)

# ایجاد فایل‌ها با محتوای اولیه
for f in "${files[@]}"; do
  path="$BASE_DIR/$f"
  echo "#!/usr/bin/env bash" > "$path"
  echo "# $f - auto generated script" >> "$path"
  echo "echo \"Running $f ...\"" >> "$path"
  chmod +x "$path"
done

# ساخت README برای توضیحات
cat > "$BASE_DIR/README.md" <<'DOC'
# پوشه start/
این پوشه شامل 30 اسکریپت مدیریتی است:
- نصب وابستگی‌ها (Python, Node, Docker)
- اجرای بک‌اند و فرانت‌اند
- مانیتورینگ و گزارش‌گیری
- اجرای سرویس‌های هوش مصنوعی و ایجنت‌ها
- بکاپ، ری‌استارت، پاک‌سازی و ارتقا
DOC

echo ">>> همه فایل‌ها ساخته شدند و آماده اجرا هستند."
