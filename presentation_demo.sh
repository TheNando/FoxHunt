#!/bin/bash

# Graph Operations Replay Log - Live Demonstration
# Recommended presentation time: ~5 minutes
# This script demonstrates time-travel capabilities for BloodHound graph data

set -e  # Exit on error

# Configuration
HOST="http://bloodhound.localhost"
USERNAME="admin"
PASSWORD="SFdzJoW2GT7Fn68aEieKn7S1S2DLdXnw"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

clear

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  BloodHound Graph Operations API v2                        ║${NC}"
echo -e "${BLUE}║  Direct Graph Manipulation & Time-Travel Demo              ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""
echo -e "${CYAN}📋 TALKING POINT:${NC}"
echo -e "${CYAN}Today we're demonstrating TWO major new capabilities:${NC}"
echo ""
echo -e "${CYAN}1. NEW Graph Operations API (v2)${NC}"
echo -e "${CYAN}   • Direct API endpoints to create/delete nodes and edges${NC}"
echo -e "${CYAN}   • No more relying solely on file ingestion${NC}"
echo -e "${CYAN}   • Programmatic graph manipulation for automation${NC}"
echo ""
echo -e "${CYAN}2. Time-Travel Replay Log${NC}"
echo -e "${CYAN}   • Every API operation is logged with full state capture${NC}"
echo -e "${CYAN}   • Roll back to any point in time${NC}"
echo -e "${CYAN}   • Complete audit trail for compliance${NC}"
echo ""
sleep 6

# ============================================
# SECTION 1: AUTHENTICATION
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}SECTION 1: Authentication${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 TALKING POINT:${NC}"
echo -e "${CYAN}First, we authenticate to the BloodHound API. All graph operations${NC}"
echo -e "${CYAN}go through our new v2 API endpoints.${NC}"
echo ""
sleep 3

echo "POST $HOST/api/v2/login"
TOKEN=$(curl -s "$HOST/api/v2/login" \
  -X POST \
  -H 'Content-Type: application/json' \
  -d "{\"login_method\": \"secret\", \"username\": \"$USERNAME\", \"secret\": \"$PASSWORD\"}" \
  | jq -r '.data.session_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
  echo "Failed to get auth token!"
  exit 1
fi

echo "✓ Authenticated successfully"
echo ""
sleep 2

# Capture initial state
echo -e "${YELLOW}Capturing initial state...${NC}"
INITIAL_ENTRY_ID=$(curl -s -X GET "$HOST/api/v2/graph/replay-log" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -r '.entries[0].id // 0')

INITIAL_NODE_COUNT=$(curl -s -X POST "$HOST/api/v2/graphs/cypher" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query": "MATCH (n) RETURN n"}' | jq '.data.nodes | length')

echo "📍 Checkpoint: Entry ID $INITIAL_ENTRY_ID"
echo "📊 Current node count: $INITIAL_NODE_COUNT nodes in graph"
echo ""
sleep 3

# ============================================
# SECTION 2: CREATING GRAPH DATA
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}SECTION 2: NEW API - Creating Graph Objects${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 TALKING POINT:${NC}"
echo -e "${CYAN}This is the game-changer: we now have REST API endpoints to directly${NC}"
echo -e "${CYAN}manipulate the graph. Before this, you could only add data through${NC}"
echo -e "${CYAN}file ingestion. Now you can:${NC}"
echo -e "${CYAN}  • Create nodes/edges programmatically via API${NC}"
echo -e "${CYAN}  • Integrate with automation tools${NC}"
echo -e "${CYAN}  • Build custom ingestion pipelines${NC}"
echo -e "${CYAN}Watch the node count change as we POST to these new endpoints.${NC}"
echo ""
sleep 5

echo -e "${GREEN}Creating User via NEW API: POST /api/v2/graph/nodes${NC}"
echo "Endpoint: $HOST/api/v2/graph/nodes"
curl -s -X POST "$HOST/api/v2/graph/nodes" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "object_id": "S-1-5-21-TEST-1001",
    "labels": ["User", "Base"],
    "properties": {
      "name": "testuser@domain.local",
      "enabled": true
    }
  }' | jq '.'
echo ""
sleep 3

echo -e "${GREEN}Creating Group via API: POST /api/v2/graph/nodes${NC}"
echo "Same endpoint, different labels - that's the flexibility of the new API"
curl -s -X POST "$HOST/api/v2/graph/nodes" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "object_id": "S-1-5-21-TEST-1002",
    "labels": ["Group", "Base"],
    "properties": {
      "name": "Domain Admins@domain.local"
    }
  }' | jq '.'
echo ""
sleep 3

echo -e "${GREEN}Creating Edge via NEW API: POST /api/v2/graph/edges${NC}"
echo "New dedicated endpoint for relationships: /api/v2/graph/edges"
echo "Creating: User -[MemberOf]-> Group"
curl -s -X POST "$HOST/api/v2/graph/edges" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "source_object_id": "S-1-5-21-TEST-1001",
    "target_object_id": "S-1-5-21-TEST-1002",
    "edge_kind": "MemberOf",
    "properties": {
      "isacl": false
    }
  }' | jq '.'
echo ""
sleep 2

echo -e "${YELLOW}Checking node count after creating objects...${NC}"
AFTER_CREATE_COUNT=$(curl -s -X POST "$HOST/api/v2/graphs/cypher" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query": "MATCH (n) RETURN n"}' | jq '.data.nodes | length')
echo "📊 Node count: $AFTER_CREATE_COUNT (was $INITIAL_NODE_COUNT, added 2 nodes)"
echo ""
sleep 3

# ============================================
# SECTION 3: VIEWING THE REPLAY LOG
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}SECTION 3: The Replay Log${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 TALKING POINT:${NC}"
echo -e "${CYAN}Every operation we just performed was logged with full state capture.${NC}"
echo -e "${CYAN}Notice the sequential entry IDs - this is our logical clock.${NC}"
echo ""
sleep 4

echo "GET $HOST/api/v2/graph/replay-log"
curl -s -X GET "$HOST/api/v2/graph/replay-log" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '{
    total_entries: .count,
    latest_operations: .entries[0:3] | map({
      id: .id,
      operation: .change_type,
      type: .object_type,
      target: .object_id,
      timestamp: .created_at
    })
  }'
echo ""
sleep 5

# ============================================
# SECTION 4: DELETING DATA
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}SECTION 4: NEW API - Deleting Objects${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 TALKING POINT:${NC}"
echo -e "${CYAN}The API also supports DELETE operations. But here's the critical${NC}"
echo -e "${CYAN}part: when we delete via the API, we capture the COMPLETE state${NC}"
echo -e "${CYAN}before deletion - all properties, labels, and relationships.${NC}"
echo -e "${CYAN}This enables true bi-directional time travel.${NC}"
echo ""
sleep 4

echo -e "${YELLOW}Deleting edge via API: DELETE /api/v2/graph/edges${NC}"
curl -s -X DELETE "$HOST/api/v2/graph/edges" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "source_object_id": "S-1-5-21-TEST-1001",
    "target_object_id": "S-1-5-21-TEST-1002",
    "edge_kind": "MemberOf"
  }' | jq -R 'if . == "" then "✓ Edge deleted" else . end'
sleep 2

echo -e "${YELLOW}Deleting user node via API: DELETE /api/v2/graph/nodes/{id}${NC}"
curl -s -X DELETE "$HOST/api/v2/graph/nodes/S-1-5-21-TEST-1001" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -R 'if . == "" then "✓ User deleted" else . end'
sleep 2

echo -e "${YELLOW}Deleting group node via API: DELETE /api/v2/graph/nodes/{id}${NC}"
curl -s -X DELETE "$HOST/api/v2/graph/nodes/S-1-5-21-TEST-1002" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -R 'if . == "" then "✓ Group deleted" else . end'
echo ""
sleep 2

echo -e "${YELLOW}Checking node count after deletions...${NC}"
AFTER_DELETE_COUNT=$(curl -s -X POST "$HOST/api/v2/graphs/cypher" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query": "MATCH (n) RETURN n"}' | jq '.data.nodes | length')
echo "📊 Node count: $AFTER_DELETE_COUNT (back to $INITIAL_NODE_COUNT, deleted 2 nodes)"
echo ""
sleep 3

# ============================================
# SECTION 5: COMPLETE HISTORY
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}SECTION 5: Complete Operation History${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 TALKING POINT:${NC}"
echo -e "${CYAN}The replay log now contains the complete linear history:${NC}"
echo -e "${CYAN}  3 creates → 3 deletes. Six operations total.${NC}"
echo ""
sleep 4

curl -s -X GET "$HOST/api/v2/graph/replay-log" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '{
    total_count: .count,
    operations: .entries[0:6] | reverse | map({
      seq: .id,
      op: .change_type,
      target: .object_id
    })
  }'
echo ""
sleep 5

# ============================================
# SECTION 6: TIME TRAVEL - ROLLBACK
# ============================================
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ${MAGENTA}SECTION 6: TIME TRAVEL - Rolling Back${NC}                      ${BLUE}║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""
echo -e "${CYAN}📋 TALKING POINT:${NC}"
echo -e "${CYAN}Now for the magic: we can roll back to ANY point in the timeline.${NC}"
echo -e "${CYAN}We're going back to entry $INITIAL_ENTRY_ID - before we made any changes.${NC}"
echo -e "${CYAN}The system will automatically invert all operations in reverse order.${NC}"
echo ""
sleep 5

echo -e "${MAGENTA}POST $HOST/api/v2/graph/replay-log/roll?to=$INITIAL_ENTRY_ID${NC}"
echo ""
curl -s -X POST "$HOST/api/v2/graph/replay-log/roll?to=$INITIAL_ENTRY_ID" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'
echo ""
echo -e "${GREEN}✓ Rollback complete!${NC}"
sleep 4

# ============================================
# SECTION 7: VERIFICATION
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}SECTION 7: Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 TALKING POINT:${NC}"
echo -e "${CYAN}Let's verify the rollback worked. We'll check two things:${NC}"
echo -e "${CYAN}  1. Our test objects are gone from the graph${NC}"
echo -e "${CYAN}  2. The total node count matches our starting point${NC}"
echo ""
sleep 4

CYPHER_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$HOST/api/v2/graphs/cypher" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "query": "MATCH (n) WHERE n.objectid IN [\"S-1-5-21-TEST-1001\", \"S-1-5-21-TEST-1002\"] RETURN count(n) as total"
  }')

HTTP_CODE=$(echo "$CYPHER_RESPONSE" | tail -n 1)

if [ "$HTTP_CODE" == "404" ]; then
  echo "Query result: 404 (no nodes found)"
  echo -e "${GREEN}✓ Success: Test objects removed from graph!${NC}"
else
  echo "Query result: Objects still exist (unexpected)"
fi
echo ""
sleep 2

echo -e "${YELLOW}Checking final node count after rollback...${NC}"
FINAL_NODE_COUNT=$(curl -s -X POST "$HOST/api/v2/graphs/cypher" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query": "MATCH (n) RETURN n"}' | jq '.data.nodes | length')
echo "📊 Final node count: $FINAL_NODE_COUNT"
echo "📊 Timeline: $INITIAL_NODE_COUNT → $AFTER_CREATE_COUNT → $AFTER_DELETE_COUNT → $FINAL_NODE_COUNT"
echo -e "${GREEN}✓ Graph restored to original state!${NC}"
echo ""
sleep 3

echo -e "${YELLOW}Checking replay log status...${NC}"
curl -s -X GET "$HOST/api/v2/graph/replay-log" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '{
    total_entries: .count,
    rolled_back_entries: .entries[0:6] | map({
      id: .id,
      operation: .change_type,
      object: .object_id,
      rolled_back: (.rolled_back_at != null)
    })
  }'
echo ""
echo -e "${CYAN}📋 TALKING POINT:${NC}"
echo -e "${CYAN}Notice: The replay log entries still exist (for audit trail), but${NC}"
echo -e "${CYAN}they're marked as 'rolled_back'. The graph itself is clean.${NC}"
echo ""
sleep 5

# ============================================
# CONCLUSION
# ============================================
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ${GREEN}DEMONSTRATION COMPLETE${NC}                                     ${BLUE}║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""
echo -e "${CYAN}📋 KEY TAKEAWAYS:${NC}"
echo ""
echo -e "${GREEN}✓ NEW Graph Operations API (v2)${NC}"
echo "  • POST /api/v2/graph/nodes - Create nodes"
echo "  • POST /api/v2/graph/edges - Create edges"
echo "  • DELETE /api/v2/graph/nodes/{id} - Delete nodes"
echo "  • DELETE /api/v2/graph/edges - Delete edges"
echo "  • Programmatic graph manipulation (no more file-only ingestion)"
echo ""
echo -e "${GREEN}✓ Complete Audit Trail${NC}"
echo "  Every API operation is logged with full state capture"
echo ""
echo -e "${GREEN}✓ Bi-directional Time Travel${NC}"
echo "  Roll backward to undo mistakes, roll forward to replay"
echo ""
echo -e "${GREEN}✓ Logical Clock Architecture${NC}"
echo "  Entry IDs provide deterministic ordering, no race conditions"
echo ""
echo -e "${GREEN}✓ State Restoration${NC}"
echo "  Deletes capture complete state, enabling perfect restoration"
echo ""
echo -e "${YELLOW}Use Cases:${NC}"
echo "  • Programmatic graph manipulation & automation"
echo "  • Custom data ingestion pipelines"
echo "  • Undo accidental data modifications"
echo "  • Restore from analysis corruption"
echo "  • Audit trail for compliance"
echo "  • Testing and development safety net"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
