#!/bin/sh
set -e

echo "========================================="
echo "  Customer Management API - Running Tests"
echo "========================================="

# Check Java
if ! command -v java >/dev/null 2>&1; then
    echo "[ERROR] Java is not installed. Please install Java 21 or higher."
    exit 1
fi

echo "[INFO] Java version: $(java -version 2>&1 | head -1)"
echo ""

# Run tests
echo "[INFO] Running tests..."
echo ""

./gradlew test

echo ""
echo "========================================="
echo "  Test Results"
echo "========================================="

REPORT="build/reports/tests/test/index.html"
if [ -f "$REPORT" ]; then
    echo "[INFO] HTML report: $REPORT"

    # Try to open report in browser
    if command -v open >/dev/null 2>&1; then
        echo "[INFO] Opening report in browser..."
        open "$REPORT"
    elif command -v xdg-open >/dev/null 2>&1; then
        echo "[INFO] Opening report in browser..."
        xdg-open "$REPORT"
    else
        echo "[INFO] Open the HTML report manually in your browser."
    fi
fi
