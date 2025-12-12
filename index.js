require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const crypto = require('crypto');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// serve static assets (icons, character tables, etc.)
app.use('/assets', express.static(path.join(__dirname, 'assets')));
app.use(express.static(__dirname));
// serve teacher dashboard HTML
app.get('/teacher', (req, res) => {
  res.sendFile(path.join(__dirname, 'teacher.html'));
});

const isProd = process.env.NODE_ENV === 'production';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: isProd ? { rejectUnauthorized: false } : false,
});


const POD_SPLITS = {
  3: [3],
  4: [4],
  5: [5],
  6: [6],
  7: [7],

  8: [4, 4],
  9: [4, 5],
  10: [4, 6],
  11: [5, 6],

  12: [4, 4, 4],
  13: [4, 4, 5],
  14: [4, 4, 6],
  15: [4, 5, 6],

  16: [4, 4, 4, 4],
  17: [4, 4, 4, 5],
  18: [4, 4, 4, 6],
  19: [4, 4, 5, 6],

  20: [4, 4, 4, 4, 4],
  21: [4, 4, 4, 4, 5],
  22: [4, 4, 4, 4, 6],
  23: [4, 4, 4, 5, 6],

  24: [4, 4, 4, 4, 4, 4],
  25: [4, 4, 4, 4, 4, 5],
};

function randomChoice(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function shuffleArray(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

async function createPodsAndAssignmentsForRound(gameId, roundId) {
  // get all players (alive + ghosts)
  const playersRes = await pool.query(
    'SELECT id, display_name, is_alive FROM game_players WHERE game_id = $1 ORDER BY id',
    [gameId]
  );
  const allPlayers = playersRes.rows;
  const N = allPlayers.length;
  if (N < 3) {
    // too small for pods
    return;
  }

  const totalLive = allPlayers.filter(p => p.is_alive).length;

  // ideal pod count from POD_SPLITS
  const idealSplit = POD_SPLITS[N] || [N];
  const idealPodCount = idealSplit.length;

  // maximum pods we can sustain with at least 2 live players each
  let podCount;
  if (totalLive >= 2 * idealPodCount) {
    podCount = idealPodCount;
  } else if (totalLive >= 2) {
    podCount = Math.floor(totalLive / 2);
  } else {
    // endgame: fewer than 2 live players, just one pod
    podCount = 1;
  }

  // shuffle players once
  const shuffled = shuffleArray(allPlayers);
  const livePlayers = shuffled.filter(p => p.is_alive);
  const ghostPlayers = shuffled.filter(p => !p.is_alive);

  // decide desired pod sizes
  let podSizes;
  if (podCount === idealPodCount) {
    // use ideal sizes if counts match
    podSizes = [...idealSplit];
  } else {
    // fallback: balanced pods
    const baseSize = Math.floor(N / podCount);
    const remainder = N % podCount;
    podSizes = [];
    for (let i = 0; i < podCount; i++) {
      podSizes.push(baseSize + (i < remainder ? 1 : 0));
    }
  }

  // 1) Initialize empty pods
  const podsInfo = [];
  for (let i = 0; i < podCount; i++) {
    podsInfo.push({ memberIds: [] });
  }

  // 2) Distribute 2 live players per pod where possible
  let liveIndex = 0;
  if (totalLive >= 2) {
    for (let i = 0; i < podCount; i++) {
      if (liveIndex < livePlayers.length) {
        podsInfo[i].memberIds.push(livePlayers[liveIndex++].id);
      }
      if (liveIndex < livePlayers.length) {
        podsInfo[i].memberIds.push(livePlayers[liveIndex++].id);
      }
    }
  }

  // 3) Fill remaining slots with leftover live players and ghosts,
  // shuffled and spread evenly across pods
  const remaining = shuffleArray([
    ...livePlayers.slice(liveIndex),
    ...ghostPlayers,
  ]);

  let remIndex = 0;
  let i = 0;

  while (remIndex < remaining.length) {
    const targetSize = podSizes[i] || 0;

    if (podsInfo[i].memberIds.length < targetSize) {
      podsInfo[i].memberIds.push(remaining[remIndex++].id);
    }

    i = (i + 1) % podCount;
  }

  // 4) Persist pods and members to DB
  const podLabels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const finalPods = [];
  for (let podIdx = 0; podIdx < podsInfo.length; podIdx++) {
    const pod = podsInfo[podIdx];
    if (!pod.memberIds.length) continue;

    const label = `Pod ${podLabels[podIdx] || String(podIdx + 1)}`;
    const podRes = await pool.query(
      'INSERT INTO pods (game_id, round_id, label) VALUES ($1, $2, $3) RETURNING id',
      [gameId, roundId, label]
    );
    const podId = podRes.rows[0].id;

    for (const playerId of pod.memberIds) {
      await pool.query(
        'INSERT INTO pod_members (pod_id, game_player_id) VALUES ($1, $2)',
        [podId, playerId]
      );
    }
    finalPods.push({ podId, memberIds: pod.memberIds });
  }

  // 5) Create interview assignments using existing schedules
  for (const pod of finalPods) {
    const ids = pod.memberIds;
    const m = ids.length;
    if (m < 3) continue;

    // ---- POD SIZE 4 ----
    if (m === 4) {
      const sr1 = [
        [0, 1], [1, 0],
        [2, 3], [3, 2],
      ];
      const sr2 = [
        [0, 2], [1, 3],
        [2, 0], [3, 1],
      ];
      for (const [i, j] of sr1) {
        await pool.query(
          `INSERT INTO interview_assignments (round_id, subround, interviewer_player_id, interviewee_player_id)
           VALUES ($1, 1, $2, $3)`,
          [roundId, ids[i], ids[j]]
        );
      }
      for (const [i, j] of sr2) {
        await pool.query(
          `INSERT INTO interview_assignments (round_id, subround, interviewer_player_id, interviewee_player_id)
           VALUES ($1, 2, $2, $3)`,
          [roundId, ids[i], ids[j]]
        );
      }
      continue;
    }

    // ---- POD SIZE 5 ----
    if (m === 5) {
      const sr1 = [
        [0, 1], [1, 0],
        [2, 3], [3, 4], [4, 2],
      ];
      const sr2 = [
        [0, 2], [1, 4],
        [2, 0], [3, 1], [4, 3],
      ];
      for (const [i, j] of sr1) {
        await pool.query(
          `INSERT INTO interview_assignments (round_id, subround, interviewer_player_id, interviewee_player_id)
           VALUES ($1, 1, $2, $3)`,
          [roundId, ids[i], ids[j]]
        );
      }
      for (const [i, j] of sr2) {
        await pool.query(
          `INSERT INTO interview_assignments (round_id, subround, interviewer_player_id, interviewee_player_id)
           VALUES ($1, 2, $2, $3)`,
          [roundId, ids[i], ids[j]]
        );
      }
      continue;
    }

    // ---- POD SIZE 6 ----
    if (m === 6) {
      const sr1 = [
        [0, 1], [1, 0],
        [2, 3], [3, 2],
        [4, 5], [5, 4],
      ];
      const sr2 = [
        [0, 2], [1, 4],
        [2, 0], [3, 5],
        [4, 1], [5, 3],
      ];
      for (const [i, j] of sr1) {
        await pool.query(
          `INSERT INTO interview_assignments (round_id, subround, interviewer_player_id, interviewee_player_id)
           VALUES ($1, 1, $2, $3)`,
          [roundId, ids[i], ids[j]]
        );
      }
      for (const [i, j] of sr2) {
        await pool.query(
          `INSERT INTO interview_assignments (round_id, subround, interviewer_player_id, interviewee_player_id)
           VALUES ($1, 2, $2, $3)`,
          [roundId, ids[i], ids[j]]
        );
      }
      continue;
    }

    // ---- POD SIZE 7 ----
    if (m === 7) {
      const sr1 = [
        [0, 1], [1, 0],
        [2, 3], [3, 2],
        [4, 5], [5, 6], [6, 4],
      ];
      const sr2 = [
        [0, 4], [1, 5], [2, 6],
        [3, 1], [4, 0], [5, 3], [6, 2],
      ];
      for (const [i, j] of sr1) {
        await pool.query(
          `INSERT INTO interview_assignments (round_id, subround, interviewer_player_id, interviewee_player_id)
           VALUES ($1, 1, $2, $3)`,
          [roundId, ids[i], ids[j]]
        );
      }
      for (const [i, j] of sr2) {
        await pool.query(
          `INSERT INTO interview_assignments (round_id, subround, interviewer_player_id, interviewee_player_id)
           VALUES ($1, 2, $2, $3)`,
          [roundId, ids[i], ids[j]]
        );
      }
      continue;
    }

    // ---- FALLBACK FOR OTHER SIZES ----
    for (let subround = 1; subround <= 2; subround++) {
      for (let i = 0; i < m; i++) {
        const interviewerId = ids[i];
        const intervieweeId = ids[(i + subround) % m];
        if (interviewerId === intervieweeId) continue;
        await pool.query(
          `INSERT INTO interview_assignments (round_id, subround, interviewer_player_id, interviewee_player_id)
           VALUES ($1, $2, $3, $4)`,
          [roundId, subround, interviewerId, intervieweeId]
        );
      }
    }
  }
}

async function assignCharactersAndProfiles(gameId) {
  // fetch all players in this game
  const playersRes = await pool.query(
    'SELECT id FROM game_players WHERE game_id = $1 ORDER BY id',
    [gameId]
  );
  const players = playersRes.rows;
  if (players.length === 0) return;

  // fetch all characters
  const charsRes = await pool.query(
    'SELECT id FROM characters ORDER BY code',
    []
  );
  const characters = charsRes.rows;

  if (characters.length === 0) {
    throw new Error('No characters defined in the database');
  }
  if (players.length > characters.length) {
    throw new Error('Not enough characters for all players');
  }

  // shuffle characters so assignment is random
  const shuffledCharacters = shuffleArray(characters);

  for (let i = 0; i < players.length; i++) {
    const player = players[i];
    const character = shuffledCharacters[i];

    // link character to player
    await pool.query(
      'UPDATE game_players SET character_id = $1 WHERE id = $2',
      [character.id, player.id]
    );

    // copy this character's profile answers into player_profiles
    await pool.query(
      `INSERT INTO player_profiles (game_player_id, question_id, answer_value)
       SELECT $1 AS game_player_id, cp.question_id, cp.answer_value
       FROM character_profiles cp
       WHERE cp.character_id = $2
       ON CONFLICT (game_player_id, question_id) DO NOTHING`,
      [player.id, character.id]
    );
  }
}

function mutateAnswer(baseAnswer) {
  return baseAnswer + ' (changed)';
}

// Helper: find a mutated answer from another character in the same game that differs from baseAnswer,
// preferring unused characters, then out-of-pod characters, then fallback.
async function getMutatedAnswer(gameId, roundId, baddieId, questionId, baseAnswer) {
  // 1) First, try an unused character (no player in this game has this character)
  const unusedRes = await pool.query(
    `SELECT cp.answer_value
     FROM character_profiles cp
     LEFT JOIN game_players gp
       ON gp.character_id = cp.character_id
       AND gp.game_id = $1
     WHERE cp.question_id = $2
       AND gp.id IS NULL
       AND cp.answer_value <> $3
     ORDER BY random()
     LIMIT 1`,
    [gameId, questionId, baseAnswer]
  );

  if (unusedRes.rows.length > 0) {
    return unusedRes.rows[0].answer_value;
  }

  // 2) Next, try characters used in this game but outside the baddie's pod for this round
  let podMemberIds = [];
  const podRes = await pool.query(
    `SELECT p.id
     FROM pods p
     JOIN pod_members pm ON pm.pod_id = p.id
     WHERE p.round_id = $1
       AND pm.game_player_id = $2
     LIMIT 1`,
    [roundId, baddieId]
  );
  if (podRes.rows.length > 0) {
    const podId = podRes.rows[0].id;
    const membersRes = await pool.query(
      'SELECT game_player_id FROM pod_members WHERE pod_id = $1',
      [podId]
    );
    podMemberIds = membersRes.rows.map(r => r.game_player_id);
  }

  let altRes2;
  if (podMemberIds.length > 0) {
    altRes2 = await pool.query(
      `SELECT cp.answer_value
       FROM character_profiles cp
       JOIN game_players gp ON gp.character_id = cp.character_id
       WHERE gp.game_id = $1
         AND cp.question_id = $2
         AND gp.id <> ALL($3)
         AND cp.answer_value <> $4
       ORDER BY random()
       LIMIT 1`,
      [gameId, questionId, podMemberIds, baseAnswer]
    );
  } else {
    // If we couldn't find a pod, fall back to any other character in the game
    altRes2 = await pool.query(
      `SELECT cp.answer_value
       FROM character_profiles cp
       JOIN game_players gp ON gp.character_id = cp.character_id
       WHERE gp.game_id = $1
         AND cp.question_id = $2
         AND gp.id <> $3
         AND cp.answer_value <> $4
       ORDER BY random()
       LIMIT 1`,
      [gameId, questionId, baddieId, baseAnswer]
    );
  }

  if (altRes2.rows.length > 0) {
    return altRes2.rows[0].answer_value;
  }

  // 3) Fallback: mark original answer as changed
  return mutateAnswer(baseAnswer);
}

async function createFirstRoundWithMutations(gameId) {
  const roundRes = await pool.query(
    `INSERT INTO rounds (game_id, round_number, status)
     VALUES ($1, 1, 'interviews')
     RETURNING id, round_number`,
    [gameId]
  );
  const round = roundRes.rows[0];

  await pool.query(
    'UPDATE games SET current_round = $1, current_subround = 1 WHERE id = $2',
    [round.round_number, gameId]
  );

  // pick 4 random questions for this round
  const qRes = await pool.query(
    'SELECT id FROM questions ORDER BY random() LIMIT 4'
  );
  const selectedQuestions = qRes.rows; // [{id: ...}, ...]

  for (let i = 0; i < selectedQuestions.length; i++) {
    await pool.query(
      `INSERT INTO round_questions (round_id, question_id, display_order)
       VALUES ($1, $2, $3)`,
      [round.id, selectedQuestions[i].id, i + 1]
    );
  }

  // restrict baddie mutations to this round's 4 questions
  const rqRes = await pool.query(
    `SELECT q.id
     FROM round_questions rq
     JOIN questions q ON q.id = rq.question_id
     WHERE rq.round_id = $1
     ORDER BY rq.display_order`,
    [round.id]
  );
  const questions = rqRes.rows;

  const baddiesRes = await pool.query(
    'SELECT id FROM game_players WHERE game_id = $1 AND role = $2',
    [gameId, 'baddie']
  );
  const baddies = baddiesRes.rows;

  for (const baddie of baddies) {
    if (questions.length === 0) break;
    const randomQuestion = randomChoice(questions);

    const profileRes = await pool.query(
      `SELECT answer_value FROM player_profiles
       WHERE game_player_id = $1 AND question_id = $2`,
      [baddie.id, randomQuestion.id]
    );
    if (profileRes.rows.length === 0) continue;

    const baseAnswer = profileRes.rows[0].answer_value;
    const mutatedValue = await getMutatedAnswer(gameId, round.id, baddie.id, randomQuestion.id, baseAnswer);

    await pool.query(
      `INSERT INTO baddie_mutations (round_id, game_player_id, question_id, subround, mutated_value)
       VALUES ($1, $2, $3, 2, $4)
       ON CONFLICT (round_id, game_player_id, question_id) DO NOTHING`,
      [round.id, baddie.id, randomQuestion.id, mutatedValue]
    );
  }

  // set up pods and interview assignments for this round
  await createPodsAndAssignmentsForRound(gameId, round.id);
}
async function createNextRoundWithMutations(gameId) {
  // get game & current round number
  const gameRes = await pool.query(
    'SELECT id, current_round FROM games WHERE id = $1',
    [gameId]
  );
  const game = gameRes.rows[0];
  if (!game) {
    throw new Error('Game not found');
  }

  const currentRoundNum = game.current_round || 0;
  const nextRoundNum = currentRoundNum + 1;

  // create new round row
  const roundRes = await pool.query(
    `INSERT INTO rounds (game_id, round_number, status)
     VALUES ($1, $2, 'interviews')
     RETURNING id, round_number`,
    [gameId, nextRoundNum]
  );
  const round = roundRes.rows[0];

  // update game record
  await pool.query(
    'UPDATE games SET current_round = $1, current_subround = 1 WHERE id = $2',
    [round.round_number, gameId]
  );

  // pick 4 random questions for this round
  const qRes = await pool.query(
    'SELECT id FROM questions ORDER BY random() LIMIT 4'
  );
  const selectedQuestions = qRes.rows;

  for (let i = 0; i < selectedQuestions.length; i++) {
    await pool.query(
      `INSERT INTO round_questions (round_id, question_id, display_order)
       VALUES ($1, $2, $3)`,
      [round.id, selectedQuestions[i].id, i + 1]
    );
  }

  // restrict baddie mutations to this round's 4 questions
  const rqRes = await pool.query(
    `SELECT q.id
     FROM round_questions rq
     JOIN questions q ON q.id = rq.question_id
     WHERE rq.round_id = $1
     ORDER BY rq.display_order`,
    [round.id]
  );
  const questions = rqRes.rows;

  const baddiesRes = await pool.query(
    'SELECT id FROM game_players WHERE game_id = $1 AND role = $2',
    [gameId, 'baddie']
  );
  const baddies = baddiesRes.rows;

  for (const baddie of baddies) {
    if (questions.length === 0) break;
    const randomQuestion = randomChoice(questions);

    const profileRes = await pool.query(
      `SELECT answer_value FROM player_profiles
       WHERE game_player_id = $1 AND question_id = $2`,
      [baddie.id, randomQuestion.id]
    );
    if (profileRes.rows.length === 0) continue;

    const baseAnswer = profileRes.rows[0].answer_value;
    const mutatedValue = await getMutatedAnswer(gameId, round.id, baddie.id, randomQuestion.id, baseAnswer);

    await pool.query(
      `INSERT INTO baddie_mutations (round_id, game_player_id, question_id, subround, mutated_value)
       VALUES ($1, $2, $3, 2, $4)
       ON CONFLICT (round_id, game_player_id, question_id) DO NOTHING`,
      [round.id, baddie.id, randomQuestion.id, mutatedValue]
    );
  }

  // new pods & interview assignments for this round
  await createPodsAndAssignmentsForRound(gameId, round.id);
}

// helper: find player by join_token
async function getPlayerByToken(joinToken) {
  const { rows } = await pool.query(
    'SELECT * FROM game_players WHERE join_token = $1',
    [joinToken]
  );
  return rows[0] || null;
}

// ---------- ROUTES ----------

// health check
app.get('/health', (req, res) => {
  res.json({ ok: true });
});

// create game (teacher)
app.post('/games', async (req, res) => {
  const code = crypto.randomBytes(3).toString('hex').toUpperCase(); // e.g. 'A3F9BC'
  const { rows } = await pool.query(
    `INSERT INTO games (code, status)
     VALUES ($1, 'lobby')
     RETURNING id, code, status`,
    [code]
  );
  res.json(rows[0]);
});

// join game (student)
app.post('/games/:code/join', async (req, res) => {
  const { display_name } = req.body;
  const { code } = req.params;

  if (!display_name) {
    return res.status(400).json({ error: 'display_name required' });
  }

  const gameRes = await pool.query(
    'SELECT * FROM games WHERE code = $1 AND status = $2',
    [code, 'lobby']
  );
  const game = gameRes.rows[0];
  if (!game) {
    return res.status(404).json({ error: 'Game not found or not in lobby' });
  }

  const joinToken = crypto.randomBytes(16).toString('hex');

  const { rows } = await pool.query(
    `INSERT INTO game_players (game_id, display_name, role, is_alive, join_token)
     VALUES ($1, $2, 'unknown', true, $3)
     RETURNING id, game_id, display_name, join_token`,
    [game.id, display_name, joinToken]
  );

  res.json(rows[0]);
});

// get game info + players (teacher view)
app.get('/games/:code', async (req, res) => {
  const { code } = req.params;

  const gameRes = await pool.query('SELECT * FROM games WHERE code = $1', [code]);
  const game = gameRes.rows[0];
  if (!game) {
    return res.status(404).json({ error: 'Game not found' });
  }

  const playersRes = await pool.query(
    'SELECT id, display_name, role, is_alive FROM game_players WHERE game_id = $1 ORDER BY id',
    [game.id]
  );

  res.json({
    game: {
      id: game.id,
      code: game.code,
      status: game.status,
    },
    players: playersRes.rows,
  });
});

// teacher: list all games
app.get('/games', async (req, res) => {
  try {
    const gamesRes = await pool.query(
      `SELECT id, code, status, current_round, current_subround, phase, created_at
       FROM games
       ORDER BY created_at DESC`
    );
    res.json(gamesRes.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to load games' });
  }
});

// teacher: delete a game (and cascade delete all related rows)
// teacher: delete a game (and delete all related rows)
app.delete('/games/:id', async (req, res) => {
  const gameId = Number(req.params.id);
  if (!gameId) {
    return res.status(400).json({ error: 'Invalid game id' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Round-scoped data
    await client.query(
      `DELETE FROM baddie_mutations bm
       USING rounds r
       WHERE bm.round_id = r.id
         AND r.game_id = $1`,
      [gameId]
    );

    await client.query(
      `DELETE FROM interview_answers ia
       USING interviews i, rounds r
       WHERE ia.interview_id = i.id
         AND i.round_id = r.id
         AND r.game_id = $1`,
      [gameId]
    );

    await client.query(
      `DELETE FROM interview_assignments a
       USING rounds r
       WHERE a.round_id = r.id
         AND r.game_id = $1`,
      [gameId]
    );

    await client.query(
      `DELETE FROM interviews i
       USING rounds r
       WHERE i.round_id = r.id
         AND r.game_id = $1`,
      [gameId]
    );

    await client.query(
      `DELETE FROM votes v
       USING rounds r
       WHERE v.round_id = r.id
         AND r.game_id = $1`,
      [gameId]
    );

    await client.query(
      `DELETE FROM round_questions rq
       USING rounds r
       WHERE rq.round_id = r.id
         AND r.game_id = $1`,
      [gameId]
    );

    // Pod-scoped data
    await client.query(
      `DELETE FROM pod_members pm
       USING pods p
       WHERE pm.pod_id = p.id
         AND p.game_id = $1`,
      [gameId]
    );

    await client.query('DELETE FROM pods WHERE game_id = $1', [gameId]);

    // Player-scoped data
    await client.query(
      `DELETE FROM player_profiles pp
       USING game_players gp
       WHERE pp.game_player_id = gp.id
         AND gp.game_id = $1`,
      [gameId]
    );

    await client.query('DELETE FROM game_players WHERE game_id = $1', [gameId]);

    // Rounds
    await client.query('DELETE FROM rounds WHERE game_id = $1', [gameId]);

    // Finally the game
    const result = await client.query(
      'DELETE FROM games WHERE id = $1 RETURNING id, code',
      [gameId]
    );

    if (result.rowCount === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Game not found' });
    }

    await client.query('COMMIT');
    res.json({
      ok: true,
      deleted_game_id: result.rows[0].id,
      deleted_code: result.rows[0].code,
    });
  } catch (err) {
    try { await client.query('ROLLBACK'); } catch (_) {}
    console.error(err);
    res.status(500).json({ error: 'Failed to delete game', detail: err.message });
  } finally {
    client.release();
  }
});

// start game: assign roles and move to "in_progress"
app.post('/games/:id/start', async (req, res) => {
  const gameId = Number(req.params.id);

  // get game
  const gameRes = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
  const game = gameRes.rows[0];
  if (!game) {
    return res.status(404).json({ error: 'Game not found' });
  }
  if (game.status !== 'lobby') {
    return res.status(400).json({ error: 'Game already started or finished' });
  }

  // get players
  const playersRes = await pool.query(
    'SELECT id FROM game_players WHERE game_id = $1',
    [gameId]
  );
  const players = playersRes.rows;
  const numPlayers = players.length;

  if (numPlayers < 3) {
    return res.status(400).json({ error: 'Need at least 3 players to start' });
  }

  // decide number of baddies (simple rule for now)
  let numBaddies;
  if (numPlayers <= 8) numBaddies = 2;
  else if (numPlayers <= 12) numBaddies = 3;
  else if (numPlayers <= 16) numBaddies = 4;
  else numBaddies = 5;

  // shuffle players array
  const shuffled = [...players].sort(() => Math.random() - 0.5);
  const baddieIds = shuffled.slice(0, numBaddies).map(p => p.id);
  const goodieIds = shuffled.slice(numBaddies).map(p => p.id);

  // set roles in DB
  if (baddieIds.length) {
    await pool.query(
      'UPDATE game_players SET role = $1 WHERE id = ANY($2)',
      ['baddie', baddieIds]
    );
  }
  if (goodieIds.length) {
    await pool.query(
      'UPDATE game_players SET role = $1 WHERE id = ANY($2)',
      ['goodie', goodieIds]
    );
  }

  // set up questions, player profiles, and first round with baddie mutations
  await assignCharactersAndProfiles(gameId);
  await createFirstRoundWithMutations(gameId);

  // update game status and initial phase
  await pool.query(
    'UPDATE games SET status = $1, phase = $2 WHERE id = $3',
    ['in_progress', 'rally', gameId]
  );

  // return summary
  res.json({
    game: {
      id: game.id,
      code: game.code,
      status: 'in_progress',
    },
    numPlayers,
    numBaddies,
  });
});

// /me/current-state (restore seat after reload)
app.get('/me/current-state', async (req, res) => {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ')
    ? authHeader.substring(7)
    : null;

  if (!token) {
    return res.status(401).json({ error: 'Missing token' });
  }

  const player = await getPlayerByToken(token);
  if (!player) {
    return res.status(401).json({ error: 'Invalid token' });
  }

  const charRes = player.character_id
    ? await pool.query(
        'SELECT name, avatar_file FROM characters WHERE id = $1',
        [player.character_id]
      )
    : { rows: [] };
  const characterRow = charRes.rows[0] || null;

  const gameRes = await pool.query('SELECT * FROM games WHERE id = $1', [
    player.game_id,
  ]);
  const game = gameRes.rows[0];
  const currentSubround = game.current_subround || 1;

  let currentRound = null;
  let answerSheet = null;
  let pod = null;
  let podMembers = null;
  let interviewTarget = null;
  let eligibleTargets = [];
  let myInterviews = [];
  let eliminationEvent = null;

  if (game.current_round) {
    const roundRes = await pool.query(
      'SELECT * FROM rounds WHERE game_id = $1 AND round_number = $2',
      [game.id, game.current_round]
    );
    const round = roundRes.rows[0];

    if (round) {
      currentRound = {
        id: round.id,
        round_number: round.round_number,
        status: round.status,
      };

      const qaRes = await pool.query(
        `SELECT q.id AS question_id,
                q.text,
                pp.answer_value
         FROM round_questions rq
         JOIN questions q
           ON q.id = rq.question_id
         JOIN player_profiles pp
           ON pp.question_id = q.id
         WHERE rq.round_id = $1
           AND pp.game_player_id = $2
         ORDER BY rq.display_order`,
        [round.id, player.id]
      );

      let mutatedMap = {};
      if (player.role === 'baddie') {
        const mutRes = await pool.query(
          `SELECT question_id, subround, mutated_value
           FROM baddie_mutations
           WHERE round_id = $1 AND game_player_id = $2`,
          [round.id, player.id]
        );
        mutatedMap = mutRes.rows.reduce((acc, row) => {
          // only apply mutation on the matching subround
          if (row.subround === currentSubround) {
            acc[row.question_id] = row.mutated_value;
          }
          return acc;
        }, {});
      }

      answerSheet = qaRes.rows.map(row => ({
        question_id: row.question_id,
        text: row.text,
        my_answer: mutatedMap[row.question_id] || row.answer_value,
      }));

      // find this player's pod for the round
      const podRes = await pool.query(
        `SELECT p.id, p.label
         FROM pods p
         JOIN pod_members pm ON pm.pod_id = p.id
         WHERE p.round_id = $1 AND pm.game_player_id = $2
         LIMIT 1`,
        [round.id, player.id]
      );

      if (podRes.rows.length > 0) {
        pod = {
          id: podRes.rows[0].id,
          label: podRes.rows[0].label,
        };

        const membersRes = await pool.query(
          `SELECT gp.id,
                  gp.display_name,
                  gp.is_alive,
                  c.name AS character_name
          FROM pod_members pm
          JOIN game_players gp ON gp.id = pm.game_player_id
          LEFT JOIN characters c ON c.id = gp.character_id
          WHERE pm.pod_id = $1`,
          [pod.id]
        );
        podMembers = membersRes.rows;

        const assignRes = await pool.query(
          `SELECT ia.interviewee_player_id,
                  gp.display_name,
                  c.name AS character_name
          FROM interview_assignments ia
          JOIN game_players gp ON gp.id = ia.interviewee_player_id
          LEFT JOIN characters c ON c.id = gp.character_id
          WHERE ia.round_id = $1
            AND ia.subround = $2
            AND ia.interviewer_player_id = $3
          LIMIT 1`,
          [round.id, currentSubround, player.id]
        );

        if (assignRes.rows.length > 0) {
          interviewTarget = {
            player_id: assignRes.rows[0].interviewee_player_id,
            display_name: assignRes.rows[0].display_name,
            character_name: assignRes.rows[0].character_name,
          };
        }
      }

      // interviews this player conducted in this round (for feedback)
      const myIntRes = await pool.query(
        `SELECT i.id AS interview_id,
                i.interviewee_player_id,
                gp.display_name AS interviewee_name,
                ia.question_id,
                q.text AS question_text,
                ia.reported_value
         FROM interviews i
         JOIN game_players gp ON gp.id = i.interviewee_player_id
         JOIN interview_answers ia ON ia.interview_id = i.id
         JOIN questions q ON q.id = ia.question_id
         WHERE i.round_id = $1
           AND i.interviewer_player_id = $2
         ORDER BY i.id, q.id`,
        [round.id, player.id]
      );

      const myIntRows = myIntRes.rows;
      if (myIntRows.length > 0) {
        const byInterview = {};
        myIntRows.forEach(row => {
          const key = row.interview_id;
          if (!byInterview[key]) {
            byInterview[key] = {
              interview_id: row.interview_id,
              interviewee_player_id: row.interviewee_player_id,
              interviewee_name: row.interviewee_name,
              answers: []
            };
          }
          byInterview[key].answers.push({
            question_id: row.question_id,
            question: row.question_text,
            reported_value: row.reported_value
          });
        });
        myInterviews = Object.values(byInterview);
      }
    }
  }

  // global elimination event: if the game recorded a last_eliminated_player_id
  if (game.last_eliminated_player_id) {
    const elimRes = await pool.query(
      'SELECT id, display_name FROM game_players WHERE id = $1',
      [game.last_eliminated_player_id]
    );
    const elimPlayer = elimRes.rows[0];
    if (elimPlayer) {
      eliminationEvent = {
        seq: game.last_eliminated_seq || 0,
        player_id: elimPlayer.id,
        display_name: elimPlayer.display_name,
      };
    }
  }

  // eligible voting targets: all other alive players in the same game
  if (game.status === 'in_progress') {
    const tRes = await pool.query(
      `SELECT gp.id,
              gp.display_name,
              c.name AS character_name
      FROM game_players gp
      LEFT JOIN characters c ON c.id = gp.character_id
      WHERE gp.game_id = $1
        AND gp.is_alive = TRUE
        AND gp.id <> $2
      ORDER BY gp.display_name`,
      [player.game_id, player.id]
    );
    eligibleTargets = tRes.rows;
  }

  res.json({
    phase: game.phase,
    player: {
      id: player.id,
      display_name: player.display_name,
      is_alive: player.is_alive,
      role: player.role,
      character_name: characterRow ? characterRow.name : null,
      character_avatar_file: characterRow ? characterRow.avatar_file : null,
    },
    game: {
      id: game.id,
      code: game.code,
      status: game.status,
      current_round: game.current_round,
    },
    currentRound,
    currentSubround,
    answerSheet,
    pod,
    podMembers,
    interviewTarget,
    eligibleTargets,
    myInterviews,
    eliminationEvent,
    // later you’ll add: phase transitions, voting, etc.
  });
});

// record an interview: who you talked to and what they said
app.post('/rounds/:roundId/interviews', async (req, res) => {
  const roundId = Number(req.params.roundId);
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ')
    ? authHeader.substring(7)
    : null;

  if (!token) {
    return res.status(401).json({ error: 'Missing token' });
  }

  const player = await getPlayerByToken(token);
  if (!player) {
    return res.status(401).json({ error: 'Invalid token' });
  }

  const { interviewee_player_id, answers } = req.body;
  // answers: [{ question_id: number, reported_value: string }, ...]

  if (!interviewee_player_id || !Array.isArray(answers) || answers.length === 0) {
    return res.status(400).json({ error: 'Missing interviewee or answers' });
  }

  // verify round belongs to same game
  const roundRes = await pool.query(
    'SELECT * FROM rounds WHERE id = $1',
    [roundId]
  );
  const round = roundRes.rows[0];
  if (!round) {
    return res.status(404).json({ error: 'Round not found' });
  }
  if (round.game_id !== player.game_id) {
    return res.status(400).json({ error: 'Round not in your game' });
  }

  const gameRes2 = await pool.query(
    'SELECT * FROM games WHERE id = $1',
    [player.game_id]
  );
  const game2 = gameRes2.rows[0];
  const currentSubround = game2.current_subround || 1;

  const assignmentRes = await pool.query(
    `SELECT 1 FROM interview_assignments
     WHERE round_id = $1
       AND subround = $2
       AND interviewer_player_id = $3
       AND interviewee_player_id = $4`,
    [roundId, currentSubround, player.id, interviewee_player_id]
  );

  if (assignmentRes.rows.length === 0) {
    return res.status(400).json({ error: 'You are not assigned to interview this player in the current subround' });
  }

  // create or reuse interview row
  const interviewRes = await pool.query(
    `INSERT INTO interviews (round_id, interviewer_player_id, interviewee_player_id)
     VALUES ($1, $2, $3)
     ON CONFLICT (round_id, interviewer_player_id, interviewee_player_id)
     DO UPDATE SET created_at = NOW()
     RETURNING id`,
    [roundId, player.id, interviewee_player_id]
  );
  const interview = interviewRes.rows[0];

  // replace previous answers for this interview (if any)
  await pool.query(
    'DELETE FROM interview_answers WHERE interview_id = $1',
    [interview.id]
  );

  // store current answers
  for (const ans of answers) {
    await pool.query(
      `INSERT INTO interview_answers (interview_id, question_id, reported_value)
       VALUES ($1, $2, $3)`,
      [interview.id, ans.question_id, ans.reported_value]
    );
  }

  res.json({ ok: true, interview_id: interview.id });
});

// player: submit a vote for this round
app.post('/rounds/:roundId/vote', async (req, res) => {
  const roundId = Number(req.params.roundId);
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ')
    ? authHeader.substring(7)
    : null;

  if (!token) {
    return res.status(401).json({ error: 'Missing token' });
  }

  const voter = await getPlayerByToken(token);
  if (!voter) {
    return res.status(401).json({ error: 'Invalid token' });
  }

  if (!voter.is_alive) {
    return res.status(400).json({ error: 'Ghosts cannot vote' });
  }

  const { target_player_id } = req.body;
  if (!target_player_id) {
    return res.status(400).json({ error: 'Missing target_player_id' });
  }

  // verify round belongs to the same game
  const roundRes = await pool.query(
    'SELECT * FROM rounds WHERE id = $1',
    [roundId]
  );
  const round = roundRes.rows[0];
  if (!round) {
    return res.status(404).json({ error: 'Round not found' });
  }
  if (round.game_id !== voter.game_id) {
    return res.status(400).json({ error: 'Round not in your game' });
  }

  // ensure target is a living player in the same game
  const targetRes = await pool.query(
    'SELECT id, is_alive FROM game_players WHERE id = $1 AND game_id = $2',
    [target_player_id, voter.game_id]
  );
  const target = targetRes.rows[0];
  if (!target || !target.is_alive) {
    return res.status(400).json({ error: 'Invalid target for elimination' });
  }

  // optional: check that this round is the current round
  const gameRes = await pool.query(
    'SELECT current_round FROM games WHERE id = $1',
    [voter.game_id]
  );
  const game = gameRes.rows[0];
  if (game && game.current_round) {
    const roundNumRes = await pool.query(
      'SELECT round_number FROM rounds WHERE id = $1',
      [roundId]
    );
    const roundNumRow = roundNumRes.rows[0];
    if (roundNumRow && roundNumRow.round_number !== game.current_round) {
      return res.status(400).json({ error: 'Can only vote in the current round' });
    }
  }

  // upsert vote (one vote per voter per round)
  await pool.query(
    `INSERT INTO votes (round_id, voter_player_id, target_player_id)
     VALUES ($1, $2, $3)
     ON CONFLICT (round_id, voter_player_id)
     DO UPDATE SET target_player_id = EXCLUDED.target_player_id,
                   created_at = NOW()`,
    [roundId, voter.id, target_player_id]
  );

  res.json({ ok: true });
});

// teacher: change current subround (e.g., from 1 to 2)
app.post('/games/:id/subround', async (req, res) => {
  const gameId = Number(req.params.id);
  const { subround } = req.body;

  if (!subround || (subround !== 1 && subround !== 2)) {
    return res.status(400).json({ error: 'subround must be 1 or 2' });
  }

  const gameRes = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
  const game = gameRes.rows[0];
  if (!game) {
    return res.status(404).json({ error: 'Game not found' });
  }

  await pool.query(
    'UPDATE games SET current_subround = $1 WHERE id = $2',
    [subround, gameId]
  );

  res.json({ ok: true, game_id: gameId, current_subround: subround });
});

// teacher: create next round (increment round, regenerate pods & mutations)
app.post('/games/:id/next-round', async (req, res) => {
  const gameId = Number(req.params.id);
  if (!gameId) {
    return res.status(400).json({ error: 'Invalid game id' });
  }

  try {
    const gameRes = await pool.query(
      'SELECT id, status FROM games WHERE id = $1',
      [gameId]
    );
    const game = gameRes.rows[0];
    if (!game) {
      return res.status(404).json({ error: 'Game not found' });
    }

    if (game.status !== 'in_progress') {
      // you can relax this if you want to allow from lobby/finished
      return res.status(400).json({ error: 'Game is not in progress' });
    }

    await createNextRoundWithMutations(gameId);

    // When starting a new round, default the phase back to rally (and reset subround)
    await pool.query(
      'UPDATE games SET phase = $1, current_subround = 1 WHERE id = $2',
      ['rally', gameId]
    );

    const updated = await pool.query(
      'SELECT current_round, current_subround, phase FROM games WHERE id = $1',
      [gameId]
    );
    const g2 = updated.rows[0];

    res.json({
      ok: true,
      game_id: gameId,
      current_round: g2.current_round,
      current_subround: g2.current_subround,
      phase: g2.phase,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create next round' });
  }
});

// teacher: mark a player as a ghost (eliminate)
app.post('/games/:gameId/players/:playerId/ghost', async (req, res) => {
  const gameId = Number(req.params.gameId);
  const playerId = Number(req.params.playerId);

  if (!gameId || !playerId) {
    return res.status(400).json({ error: 'Invalid gameId or playerId' });
  }

  try {
    const gameRes = await pool.query(
      'SELECT id FROM games WHERE id = $1',
      [gameId]
    );
    const game = gameRes.rows[0];
    if (!game) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const playerRes = await pool.query(
      'SELECT id, is_alive FROM game_players WHERE id = $1 AND game_id = $2',
      [playerId, gameId]
    );
    const player = playerRes.rows[0];
    if (!player) {
      return res.status(404).json({ error: 'Player not found in this game' });
    }

    if (!player.is_alive) {
      // already a ghost; nothing to change
      return res.json({ ok: true, alreadyGhost: true, player_id: playerId });
    }

    await pool.query(
      'UPDATE game_players SET is_alive = FALSE WHERE id = $1',
      [playerId]
    );

    // record global elimination event on the game
    await pool.query(
      `UPDATE games
       SET last_eliminated_player_id = $1,
           last_eliminated_seq = COALESCE(last_eliminated_seq, 0) + 1
       WHERE id = $2`,
      [playerId, gameId]
    );

    res.json({ ok: true, player_id: playerId, is_alive: false });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to mark player as ghost' });
  }
});

// teacher debug: full game view with pods, assignments, and players
app.get('/games/:id/debug', async (req, res) => {
  const gameId = Number(req.params.id);

  const gameRes = await pool.query(
    'SELECT * FROM games WHERE id = $1',
    [gameId]
  );
  const game = gameRes.rows[0];
  if (!game) {
    return res.status(404).json({ error: 'Game not found' });
  }

  // players
  const playersRes = await pool.query(
    `SELECT gp.id,
            gp.display_name,
            gp.role,
            gp.is_alive,
            c.name AS character_name
    FROM game_players gp
    LEFT JOIN characters c ON c.id = gp.character_id
    WHERE gp.game_id = $1
    ORDER BY gp.id`,
    [gameId]
  );
  const players = playersRes.rows;

  // current round
  const roundRes = await pool.query(
    `SELECT * FROM rounds
     WHERE game_id = $1 AND round_number = $2`,
    [gameId, game.current_round]
  );
  const round = roundRes.rows[0] || null;

  // pods & members
  let pods = [];
  if (round) {
    const podsRes = await pool.query(
      `SELECT id, label
       FROM pods
       WHERE round_id = $1
       ORDER BY id`,
      [round.id]
    );
    const podsRaw = podsRes.rows;

    for (const p of podsRaw) {
      const membersRes = await pool.query(
        `SELECT gp.id, gp.display_name, gp.role, gp.is_alive
         FROM pod_members pm
         JOIN game_players gp ON gp.id = pm.game_player_id
         WHERE pm.pod_id = $1
         ORDER BY gp.id`,
        [p.id]
      );
      pods.push({
        id: p.id,
        label: p.label,
        members: membersRes.rows
      });
    }
  }

  // interview assignments
  let assignments = [];
  if (round) {
    const aRes = await pool.query(
      `SELECT ia.subround,
              ia.interviewer_player_id,
              interviewer.display_name AS interviewer_name,
              ia.interviewee_player_id,
              interviewee.display_name AS interviewee_name
       FROM interview_assignments ia
       JOIN game_players interviewer ON interviewer.id = ia.interviewer_player_id
       JOIN game_players interviewee ON interviewee.id = ia.interviewee_player_id
       WHERE ia.round_id = $1
       ORDER BY ia.subround, ia.interviewer_player_id`,
      [round.id]
    );
    assignments = aRes.rows;
  }

  // vote summary for current round
  let votes = [];
  if (round) {
    const vRes = await pool.query(
      `SELECT v.target_player_id,
              gp.display_name AS target_name,
              COUNT(*) AS vote_count
       FROM votes v
       JOIN game_players gp ON gp.id = v.target_player_id
       WHERE v.round_id = $1
       GROUP BY v.target_player_id, gp.display_name
       ORDER BY vote_count DESC, target_name ASC`,
      [round.id]
    );
    votes = vRes.rows;
  }

  res.json({
    game,
    players,
    round,
    pods,
    assignments,
    votes
  });
});

// ----------------------------

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API listening on port ${PORT}`);
});
// teacher: set game phase (rally, interview1, interview2, feedback, voting)
app.post('/games/:id/phase', async (req, res) => {
  const gameId = Number(req.params.id);
  const { phase } = req.body;

  const validPhases = ['rally', 'interview1', 'interview2', 'feedback', 'voting'];

  if (!phase || !validPhases.includes(phase)) {
    return res.status(400).json({ error: 'Invalid phase' });
  }

  try {
    const gameRes = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    const game = gameRes.rows[0];
    if (!game) {
      return res.status(404).json({ error: 'Game not found' });
    }

    // Optionally tie subround to interview phases
    let subroundUpdate = null;
    if (phase === 'interview1') subroundUpdate = 1;
    if (phase === 'interview2') subroundUpdate = 2;

    if (subroundUpdate !== null) {
      await pool.query(
        'UPDATE games SET phase = $1, current_subround = $2 WHERE id = $3',
        [phase, subroundUpdate, gameId]
      );
    } else {
      await pool.query(
        'UPDATE games SET phase = $1 WHERE id = $2',
        [phase, gameId]
      );
    }

    res.json({ ok: true, game_id: gameId, phase });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to set phase' });
  }
});