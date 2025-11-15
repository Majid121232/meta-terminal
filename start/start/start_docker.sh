#!/usr/bin/env sh
set -eu
echo "[i] Building and running minimal docker (if available)"
cat > Dockerfile <<DF
FROM alpine:3.21
RUN apk add --no-cache python3 py3-pip
WORKDIR /app
COPY start/_backend_app.py /app/_backend_app.py
CMD ["python3","/app/_backend_app.py"]
DF
docker build -t meta-backend . || { echo "[!] docker build failed"; exit 0; }
docker run --rm -p 5253:5253 meta-backend &
echo "[✔] docker container starting"
