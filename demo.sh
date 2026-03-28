#!/bin/sh
set -e

BASE_URL="${1:-http://localhost:8080}/api/customers"
PASS=0
FAIL=0

print_step() {
    echo ""
    echo "========================================="
    echo "  Step $1: $2"
    echo "========================================="
}

check() {
    STEP_NAME="$1"
    EXPECTED="$2"
    ACTUAL="$3"
    if [ "$ACTUAL" = "$EXPECTED" ]; then
        echo "[PASS] $STEP_NAME (expected=$EXPECTED, actual=$ACTUAL)"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] $STEP_NAME (expected=$EXPECTED, actual=$ACTUAL)"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "  Customer Management API - Demo Script"
echo "  Base URL: $BASE_URL"

# =========================================
# Step 1
# =========================================
print_step 1 "Query customer with email san.zhang@example.com - should NOT exist"

RESULT=$(curl -s "$BASE_URL")
echo "Response: $RESULT"

FOUND=$(echo "$RESULT" | grep -c "san.zhang@example.com" || true)
check "Customer should not exist" "0" "$FOUND"

# =========================================
# Step 2
# =========================================
print_step 2 "Create customer"

RESULT=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Zhang San",
        "email": "san.zhang@example.com",
        "phone": "0912345678",
        "address": "Taipei, Taiwan"
    }')

HTTP_CODE=$(echo "$RESULT" | tail -1)
BODY=$(echo "$RESULT" | sed '$d')
echo "Response ($HTTP_CODE): $BODY"

check "Create should return 201" "201" "$HTTP_CODE"

CUSTOMER_ID=$(echo "$BODY" | sed 's/.*"id":\([0-9]*\).*/\1/')
echo "Created customer ID: $CUSTOMER_ID"

# =========================================
# Step 3
# =========================================
print_step 3 "Query customer by ID - should exist"

RESULT=$(curl -s -w "\n%{http_code}" "$BASE_URL/$CUSTOMER_ID")

HTTP_CODE=$(echo "$RESULT" | tail -1)
BODY=$(echo "$RESULT" | sed '$d')
echo "Response ($HTTP_CODE): $BODY"

check "Query should return 200" "200" "$HTTP_CODE"

FOUND_NAME=$(echo "$BODY" | grep -c '"name":"Zhang San"' || true)
check "Name should be Zhang San" "1" "$FOUND_NAME"

FOUND_EMAIL=$(echo "$BODY" | grep -c '"email":"san.zhang@example.com"' || true)
check "Email should be san.zhang@example.com" "1" "$FOUND_EMAIL"

# =========================================
# Step 4
# =========================================
print_step 4 "Update customer"

RESULT=$(curl -s -w "\n%{http_code}" -X PUT "$BASE_URL/$CUSTOMER_ID" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Zhang San",
        "email": "san.zhang@example.com",
        "phone": "0987654321",
        "address": "Kaohsiung, Taiwan"
    }')

HTTP_CODE=$(echo "$RESULT" | tail -1)
BODY=$(echo "$RESULT" | sed '$d')
echo "Response ($HTTP_CODE): $BODY"

check "Update should return 200" "200" "$HTTP_CODE"

FOUND_PHONE=$(echo "$BODY" | grep -c '"phone":"0987654321"' || true)
check "Phone should be updated" "1" "$FOUND_PHONE"

FOUND_ADDR=$(echo "$BODY" | grep -c '"address":"Kaohsiung, Taiwan"' || true)
check "Address should be updated" "1" "$FOUND_ADDR"

# =========================================
# Step 5
# =========================================
print_step 5 "Query customer again - should reflect updates"

RESULT=$(curl -s -w "\n%{http_code}" "$BASE_URL/$CUSTOMER_ID")

HTTP_CODE=$(echo "$RESULT" | tail -1)
BODY=$(echo "$RESULT" | sed '$d')
echo "Response ($HTTP_CODE): $BODY"

check "Query should return 200" "200" "$HTTP_CODE"

FOUND_PHONE=$(echo "$BODY" | grep -c '"phone":"0987654321"' || true)
check "Phone should be 0987654321" "1" "$FOUND_PHONE"

FOUND_ADDR=$(echo "$BODY" | grep -c '"address":"Kaohsiung, Taiwan"' || true)
check "Address should be Kaohsiung, Taiwan" "1" "$FOUND_ADDR"

# =========================================
# Step 6
# =========================================
print_step 6 "Delete customer"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/$CUSTOMER_ID")
echo "Response: $HTTP_CODE"

check "Delete should return 204" "204" "$HTTP_CODE"

# =========================================
# Step 7
# =========================================
print_step 7 "Query customer again - should NOT exist"

RESULT=$(curl -s -w "\n%{http_code}" "$BASE_URL/$CUSTOMER_ID")

HTTP_CODE=$(echo "$RESULT" | tail -1)
BODY=$(echo "$RESULT" | sed '$d')
echo "Response ($HTTP_CODE): $BODY"

check "Query deleted customer should return 400" "400" "$HTTP_CODE"

# =========================================
# Summary
# =========================================
echo ""
echo "========================================="
echo "  Results: $PASS passed, $FAIL failed"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
