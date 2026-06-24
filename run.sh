#!/bin/bash

# MailMind AI Unified Startup Script
# Starts the FastAPI backend and Flutter frontend in parallel, cleanly handles exits.

# Terminate background processes on exit (CTRL+C)
cleanup() {
    echo ""
    echo "=============================================="
    echo "Stopping MailMind AI Services..."
    echo "=============================================="
    # Kill the FastAPI background process
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

echo "=============================================="
echo "Starting MailMind AI Platform..."
echo "=============================================="

# 1. Start FastAPI Backend
echo "Starting FastAPI Backend Server on http://127.0.0.1:8000..."
./backend/venv/bin/uvicorn backend.app.main:app --host 127.0.0.1 --port 8000 > backend_server.log 2>&1 &
BACKEND_PID=$!

# Wait 2 seconds to make sure backend binds
sleep 2

# Check if backend started successfully
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "Error: FastAPI Backend failed to start. Check backend_server.log for details."
    exit 1
fi

echo "Backend Server started successfully (PID: $BACKEND_PID)."
echo "=============================================="

# 2. Start Flutter Frontend Web Client
echo "Launching Flutter Frontend Web in Chrome..."
cd frontend
flutter run -d chrome
