#!/bin/bash

# Test script for Update Node and Update Edge endpoints
# This script tests the newly implemented PATCH endpoints for graph operations

set -e  # Exit on error

# Configuration
BASE_URL="${BASE_URL:-http://localhost:8080}"
API_BASE="${BASE_URL}/api/v2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
    local test_name=$1
    local status=$2
    local response=$3

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo -e "  Response: $response"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to make authenticated API call
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3

    if [ -n "$AUTH_TOKEN" ]; then
        curl -s -X "$method" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $AUTH_TOKEN" \
            -d "$data" \
            "${API_BASE}${endpoint}"
    else
        curl -s -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "${API_BASE}${endpoint}"
    fi
}

echo "=========================================="
echo "Testing Graph Update Endpoints"
echo "=========================================="
echo "Base URL: $BASE_URL"
echo ""

# Check if we need authentication
if [ -z "$AUTH_TOKEN" ]; then
    echo -e "${YELLOW}Warning: No AUTH_TOKEN set. Tests may fail if authentication is required.${NC}"
    echo "Set AUTH_TOKEN environment variable if needed."
    echo ""
fi

# Test 1: Create a test node first
echo -e "\n${YELLOW}Setting up test data...${NC}"
TEST_NODE_ID="TEST-NODE-$(date +%s)"
CREATE_NODE_RESPONSE=$(api_call POST "/graph/nodes" '{
  "object_id": "'"$TEST_NODE_ID"'",
  "labels": ["TestNode"],
  "properties": {
    "name": "Original Name",
    "description": "Original Description",
    "test": true
  }
}')

if echo "$CREATE_NODE_RESPONSE" | grep -q "$TEST_NODE_ID"; then
    echo -e "${GREEN}✓${NC} Created test node: $TEST_NODE_ID"
else
    echo -e "${YELLOW}⚠${NC}  Could not create test node (may need auth or already exists)"
    echo "Response: $CREATE_NODE_RESPONSE"
    TEST_NODE_ID="EXISTING-NODE-ID"
fi

# Test 2: Create test nodes for edge
TEST_SOURCE_ID="TEST-SOURCE-$(date +%s)"
TEST_TARGET_ID="TEST-TARGET-$(date +%s)"

api_call POST "/graph/nodes" '{
  "object_id": "'"$TEST_SOURCE_ID"'",
  "labels": ["User"],
  "properties": {"name": "Source User"}
}' > /dev/null 2>&1

api_call POST "/graph/nodes" '{
  "object_id": "'"$TEST_TARGET_ID"'",
  "labels": ["Group"],
  "properties": {"name": "Target Group"}
}' > /dev/null 2>&1

# Create test edge
api_call POST "/graph/edges" '{
  "source_object_id": "'"$TEST_SOURCE_ID"'",
  "target_object_id": "'"$TEST_TARGET_ID"'",
  "edge_kind": "MemberOf",
  "properties": {"weight": 50}
}' > /dev/null 2>&1

echo ""
echo "=========================================="
echo "Testing UpdateNode Endpoint"
echo "=========================================="

# Test 3: Update node properties only
RESPONSE=$(api_call PATCH "/graph/nodes/$TEST_NODE_ID" '{
  "properties": {
    "name": "Updated Name",
    "new_field": "New Value"
  }
}')

if echo "$RESPONSE" | grep -q "object_id"; then
    print_result "Update node properties only" "PASS" "$RESPONSE"
else
    print_result "Update node properties only" "FAIL" "$RESPONSE"
fi

# Test 4: Update node labels only
RESPONSE=$(api_call PATCH "/graph/nodes/$TEST_NODE_ID" '{
  "labels": ["TestNode", "UpdatedLabel", "AnotherLabel"]
}')

if echo "$RESPONSE" | grep -q "object_id"; then
    print_result "Update node labels only" "PASS" "$RESPONSE"
else
    print_result "Update node labels only" "FAIL" "$RESPONSE"
fi

# Test 5: Update both labels and properties
RESPONSE=$(api_call PATCH "/graph/nodes/$TEST_NODE_ID" '{
  "labels": ["TestNode"],
  "properties": {
    "name": "Final Name",
    "enabled": true,
    "count": 42
  }
}')

if echo "$RESPONSE" | grep -q "object_id"; then
    print_result "Update both labels and properties" "PASS" "$RESPONSE"
else
    print_result "Update both labels and properties" "FAIL" "$RESPONSE"
fi

# Test 6: Error case - empty update request
RESPONSE=$(api_call PATCH "/graph/nodes/$TEST_NODE_ID" '{}')

if echo "$RESPONSE" | grep -q "error\|at least one"; then
    print_result "Reject empty update request" "PASS" "$RESPONSE"
else
    print_result "Reject empty update request" "FAIL" "$RESPONSE"
fi

# Test 7: Error case - missing object_id
RESPONSE=$(api_call PATCH "/graph/nodes/" '{
  "properties": {"test": "value"}
}')

if echo "$RESPONSE" | grep -q "error\|404\|not found"; then
    print_result "Reject missing object_id" "PASS" "$RESPONSE"
else
    print_result "Reject missing object_id" "FAIL" "$RESPONSE"
fi

echo ""
echo "=========================================="
echo "Testing UpdateEdge Endpoint"
echo "=========================================="

# Test 8: Update edge properties
RESPONSE=$(api_call PATCH "/graph/edges" '{
  "source_object_id": "'"$TEST_SOURCE_ID"'",
  "target_object_id": "'"$TEST_TARGET_ID"'",
  "edge_kind": "MemberOf",
  "properties": {
    "weight": 100,
    "active": true,
    "updated": true
  }
}')

if echo "$RESPONSE" | grep -q "edge_kind"; then
    print_result "Update edge properties" "PASS" "$RESPONSE"
else
    print_result "Update edge properties" "FAIL" "$RESPONSE"
fi

# Test 9: Error case - missing source_object_id
RESPONSE=$(api_call PATCH "/graph/edges" '{
  "target_object_id": "'"$TEST_TARGET_ID"'",
  "edge_kind": "MemberOf",
  "properties": {"test": "value"}
}')

if echo "$RESPONSE" | grep -q "error\|required"; then
    print_result "Reject missing source_object_id" "PASS" "$RESPONSE"
else
    print_result "Reject missing source_object_id" "FAIL" "$RESPONSE"
fi

# Test 10: Error case - missing target_object_id
RESPONSE=$(api_call PATCH "/graph/edges" '{
  "source_object_id": "'"$TEST_SOURCE_ID"'",
  "edge_kind": "MemberOf",
  "properties": {"test": "value"}
}')

if echo "$RESPONSE" | grep -q "error\|required"; then
    print_result "Reject missing target_object_id" "PASS" "$RESPONSE"
else
    print_result "Reject missing target_object_id" "FAIL" "$RESPONSE"
fi

# Test 11: Error case - missing edge_kind
RESPONSE=$(api_call PATCH "/graph/edges" '{
  "source_object_id": "'"$TEST_SOURCE_ID"'",
  "target_object_id": "'"$TEST_TARGET_ID"'",
  "properties": {"test": "value"}
}')

if echo "$RESPONSE" | grep -q "error\|required"; then
    print_result "Reject missing edge_kind" "PASS" "$RESPONSE"
else
    print_result "Reject missing edge_kind" "FAIL" "$RESPONSE"
fi

# Test 12: Error case - missing properties
RESPONSE=$(api_call PATCH "/graph/edges" '{
  "source_object_id": "'"$TEST_SOURCE_ID"'",
  "target_object_id": "'"$TEST_TARGET_ID"'",
  "edge_kind": "MemberOf"
}')

if echo "$RESPONSE" | grep -q "error\|required"; then
    print_result "Reject missing properties" "PASS" "$RESPONSE"
else
    print_result "Reject missing properties" "FAIL" "$RESPONSE"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Total tests run: $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi
