#!/bin/bash

API="http://localhost:4000"

# 1. Create a new game
GAME_JSON=$(curl -s -X POST $API/games)
GAME_ID=$(echo $GAME_JSON | sed -n 's/.*"id":\([0-9]*\).*/\1/p')
GAME_CODE=$(echo $GAME_JSON | sed -n 's/.*"code":"\([A-Z0-9]*\)".*/\1/p')

echo "Created game:"
echo "  ID:   $GAME_ID"
echo "  CODE: $GAME_CODE"
echo ""

# 2. Array of example names
PLAYERS=("Alice" "Bob" "Charlie" "Dana" "Eve" "Frank" "Grace" "Hector" "Ivy" "Jack"
         "Karen" "Leo" "Mia" "Nora" "Omar" "Pia" "Quinn" "Rita" "Sam" "Tina"
         "Uma" "Vic" "Wes" "Xena" "Yuri" "Zara")

# 3. Number to add (default 12)
COUNT=${1:-12}

echo "Creating $COUNT players…"

TOKENS=()

for ((i=0; i<$COUNT; i++)); do
  name="${PLAYERS[$i]}"
  join_json=$(curl -s -X POST $API/games/$GAME_CODE/join \
                 -H "Content-Type: application/json" \
                 -d "{\"display_name\":\"$name\"}")

  token=$(echo $join_json | sed -n 's/.*"join_token":"\([^"]*\)".*/\1/p')
  TOKENS+=("$token")

  echo "  Added: $name"
done

echo ""
echo "Tokens for testing:"
for t in "${TOKENS[@]}"; do
  echo "  $t"
done

echo ""
echo "Now start the game:"
echo "  curl -X POST $API/games/$GAME_ID/start"