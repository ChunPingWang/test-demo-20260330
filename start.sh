#!/bin/sh
set -e

echo "========================================="
echo "  Customer Management API - Starting"
echo "========================================="

# Check Java
if ! command -v java >/dev/null 2>&1; then
    echo "[ERROR] Java is not installed. Please install Java 21 or higher."
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 | sed 's/.*"\([0-9]*\).*/\1/')
echo "[INFO] Java version: $(java -version 2>&1 | head -1)"

if [ "$JAVA_VERSION" -lt 21 ] 2>/dev/null; then
    echo "[WARN] Java 21+ is required. Current major version: $JAVA_VERSION"
    echo "[WARN] Please set JAVA_HOME to a Java 21+ installation."
fi

# Build
echo ""
echo "[INFO] Building project..."
./gradlew build -x test --quiet

# Run
echo "[INFO] Starting application on http://localhost:8080"
echo "[INFO] Swagger UI: http://localhost:8080/swagger-ui.html"
echo "[INFO] H2 Console: http://localhost:8080/h2-console"
echo "[INFO] Press Ctrl+C to stop."
echo ""

./gradlew bootRun --quiet
