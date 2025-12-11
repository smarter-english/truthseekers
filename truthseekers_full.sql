--
-- PostgreSQL database dump
--

\restrict aFodlpkjv7V4hQiZDEcFPz9gQ8j53GcZTwcObsBrqCyQs0csY90rwMsipmKRmBc

-- Dumped from database version 18.1 (Postgres.app)
-- Dumped by pg_dump version 18.1 (Postgres.app)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: baddie_mutations; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.baddie_mutations (
    id integer NOT NULL,
    round_id integer NOT NULL,
    game_player_id integer NOT NULL,
    question_id integer NOT NULL,
    mutated_value text NOT NULL,
    subround integer DEFAULT 2 NOT NULL
);


ALTER TABLE public.baddie_mutations OWNER TO williamkingdom;

--
-- Name: baddie_mutations_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.baddie_mutations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.baddie_mutations_id_seq OWNER TO williamkingdom;

--
-- Name: baddie_mutations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.baddie_mutations_id_seq OWNED BY public.baddie_mutations.id;


--
-- Name: character_profiles; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.character_profiles (
    id integer NOT NULL,
    character_id integer NOT NULL,
    question_id integer NOT NULL,
    answer_value text NOT NULL
);


ALTER TABLE public.character_profiles OWNER TO williamkingdom;

--
-- Name: character_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

ALTER TABLE public.character_profiles ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.character_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: characters; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.characters (
    id integer NOT NULL,
    code character(1) NOT NULL,
    name text NOT NULL,
    avatar_file text NOT NULL
);


ALTER TABLE public.characters OWNER TO williamkingdom;

--
-- Name: characters_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

ALTER TABLE public.characters ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.characters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: game_players; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.game_players (
    id integer NOT NULL,
    game_id integer NOT NULL,
    display_name character varying(50) NOT NULL,
    role character varying(20) DEFAULT 'unknown'::character varying NOT NULL,
    is_alive boolean DEFAULT true NOT NULL,
    join_token character varying(64) NOT NULL,
    joined_at timestamp without time zone DEFAULT now() NOT NULL,
    character_id integer,
    character_assigned_at timestamp without time zone
);


ALTER TABLE public.game_players OWNER TO williamkingdom;

--
-- Name: game_players_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.game_players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.game_players_id_seq OWNER TO williamkingdom;

--
-- Name: game_players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.game_players_id_seq OWNED BY public.game_players.id;


--
-- Name: games; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.games (
    id integer NOT NULL,
    code character varying(10) NOT NULL,
    status character varying(20) DEFAULT 'lobby'::character varying NOT NULL,
    current_round integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    current_subround integer,
    phase text DEFAULT 'rally'::text,
    last_eliminated_player_id integer,
    last_eliminated_seq integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.games OWNER TO williamkingdom;

--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.games_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.games_id_seq OWNER TO williamkingdom;

--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.games_id_seq OWNED BY public.games.id;


--
-- Name: interview_answers; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.interview_answers (
    id integer NOT NULL,
    interview_id integer NOT NULL,
    question_id integer NOT NULL,
    reported_value text NOT NULL
);


ALTER TABLE public.interview_answers OWNER TO williamkingdom;

--
-- Name: interview_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.interview_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interview_answers_id_seq OWNER TO williamkingdom;

--
-- Name: interview_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.interview_answers_id_seq OWNED BY public.interview_answers.id;


--
-- Name: interview_assignments; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.interview_assignments (
    id integer NOT NULL,
    round_id integer NOT NULL,
    subround integer NOT NULL,
    interviewer_player_id integer NOT NULL,
    interviewee_player_id integer NOT NULL
);


ALTER TABLE public.interview_assignments OWNER TO williamkingdom;

--
-- Name: interview_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.interview_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interview_assignments_id_seq OWNER TO williamkingdom;

--
-- Name: interview_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.interview_assignments_id_seq OWNED BY public.interview_assignments.id;


--
-- Name: interviews; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.interviews (
    id integer NOT NULL,
    round_id integer NOT NULL,
    interviewer_player_id integer NOT NULL,
    interviewee_player_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.interviews OWNER TO williamkingdom;

--
-- Name: interviews_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.interviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interviews_id_seq OWNER TO williamkingdom;

--
-- Name: interviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.interviews_id_seq OWNED BY public.interviews.id;


--
-- Name: player_profiles; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.player_profiles (
    id integer NOT NULL,
    game_player_id integer NOT NULL,
    question_id integer NOT NULL,
    answer_value text NOT NULL
);


ALTER TABLE public.player_profiles OWNER TO williamkingdom;

--
-- Name: player_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.player_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_profiles_id_seq OWNER TO williamkingdom;

--
-- Name: player_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.player_profiles_id_seq OWNED BY public.player_profiles.id;


--
-- Name: pod_members; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.pod_members (
    id integer NOT NULL,
    pod_id integer NOT NULL,
    game_player_id integer NOT NULL
);


ALTER TABLE public.pod_members OWNER TO williamkingdom;

--
-- Name: pod_members_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.pod_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pod_members_id_seq OWNER TO williamkingdom;

--
-- Name: pod_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.pod_members_id_seq OWNED BY public.pod_members.id;


--
-- Name: pods; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.pods (
    id integer NOT NULL,
    game_id integer NOT NULL,
    round_id integer NOT NULL,
    label character varying(10)
);


ALTER TABLE public.pods OWNER TO williamkingdom;

--
-- Name: pods_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.pods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pods_id_seq OWNER TO williamkingdom;

--
-- Name: pods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.pods_id_seq OWNED BY public.pods.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.questions (
    id integer NOT NULL,
    text text NOT NULL
);


ALTER TABLE public.questions OWNER TO williamkingdom;

--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.questions_id_seq OWNER TO williamkingdom;

--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;


--
-- Name: round_questions; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.round_questions (
    id integer NOT NULL,
    round_id integer NOT NULL,
    question_id integer NOT NULL,
    display_order integer NOT NULL
);


ALTER TABLE public.round_questions OWNER TO williamkingdom;

--
-- Name: round_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

ALTER TABLE public.round_questions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.round_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rounds; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.rounds (
    id integer NOT NULL,
    game_id integer NOT NULL,
    round_number integer NOT NULL,
    status character varying(20) DEFAULT 'interviews'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.rounds OWNER TO williamkingdom;

--
-- Name: rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.rounds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rounds_id_seq OWNER TO williamkingdom;

--
-- Name: rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.rounds_id_seq OWNED BY public.rounds.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.votes (
    id integer NOT NULL,
    round_id integer NOT NULL,
    voter_player_id integer NOT NULL,
    target_player_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.votes OWNER TO williamkingdom;

--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: williamkingdom
--

CREATE SEQUENCE public.votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.votes_id_seq OWNER TO williamkingdom;

--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: williamkingdom
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: baddie_mutations id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.baddie_mutations ALTER COLUMN id SET DEFAULT nextval('public.baddie_mutations_id_seq'::regclass);


--
-- Name: game_players id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.game_players ALTER COLUMN id SET DEFAULT nextval('public.game_players_id_seq'::regclass);


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: interview_answers id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interview_answers ALTER COLUMN id SET DEFAULT nextval('public.interview_answers_id_seq'::regclass);


--
-- Name: interview_assignments id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interview_assignments ALTER COLUMN id SET DEFAULT nextval('public.interview_assignments_id_seq'::regclass);


--
-- Name: interviews id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interviews ALTER COLUMN id SET DEFAULT nextval('public.interviews_id_seq'::regclass);


--
-- Name: player_profiles id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.player_profiles ALTER COLUMN id SET DEFAULT nextval('public.player_profiles_id_seq'::regclass);


--
-- Name: pod_members id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.pod_members ALTER COLUMN id SET DEFAULT nextval('public.pod_members_id_seq'::regclass);


--
-- Name: pods id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.pods ALTER COLUMN id SET DEFAULT nextval('public.pods_id_seq'::regclass);


--
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);


--
-- Name: rounds id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.rounds ALTER COLUMN id SET DEFAULT nextval('public.rounds_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Data for Name: baddie_mutations; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.baddie_mutations (id, round_id, game_player_id, question_id, mutated_value, subround) FROM stdin;
1	12	22	8	I run (changed)	2
2	12	23	7	Steak and chips (changed)	2
3	13	29	8	By bicycle (changed)	2
4	13	27	4	Four times a year (changed)	2
5	14	32	1	21 (changed)	2
6	14	33	1	20 (changed)	2
7	15	32	10	I am a manager	2
8	15	33	11	About four hours	2
9	16	32	12	Yes a horse	2
10	16	33	9	White	2
\.


--
-- Data for Name: character_profiles; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.character_profiles (id, character_id, question_id, answer_value) FROM stdin;
1	1	1	25
2	1	2	New Orleans
3	1	3	I go to the cinema with friends
4	1	4	Three times a month
5	1	5	Toast and jam
6	1	6	9:20 AM
7	1	7	Spaghetti bolognese
8	1	8	I ride my unicycle
9	1	9	Light brown
10	1	10	I am a nurse
11	1	11	Between six and seven hours
12	1	12	Yes a cat
13	2	1	36
14	2	2	Manchester
15	2	3	I play football in the park
16	2	4	Every two years
17	2	5	Bacon and eggs
18	2	6	9:00 AM
19	2	7	Fish and chips
20	2	8	I row my boat
21	2	9	Pink
22	2	10	I am an electrician
23	2	11	7 hours and 30 minutes
24	2	12	Yes a hamster
25	3	1	30
26	3	2	Bristol
27	3	3	I go hiking with friends
28	3	4	Every three months
29	3	5	Porridge with honey
30	3	6	9:30 AM
31	3	7	Roast chicken
32	3	8	I ride my motorbike
33	3	9	Green
34	3	10	I am a graphic designer
35	3	11	About nine and a half hours
36	3	12	Yes a dog
37	4	1	21
38	4	2	Dallas
39	4	3	I meet friends in cafes
40	4	4	Twice a month
41	4	5	Croissant and orange juice
42	4	6	10:00 AM
43	4	7	Vegetable curry
44	4	8	I run
45	4	9	White
46	4	10	I am a photographer
47	4	11	Between five and six hours
48	4	12	Yes a rabbit
49	5	1	42
50	5	2	Miami
51	5	3	I work on my car
52	5	4	Every six weeks
53	5	5	Fried eggs and toast
54	5	6	10:05 AM
55	5	7	Steak and chips
56	5	8	By car
57	5	9	Dark blue
58	5	10	I am a taxi driver
59	5	11	8 hours exactly
60	5	12	Yes a snake
61	6	1	27
62	6	2	Leeds
63	6	3	I do yoga and read books
64	6	4	Four times a year
65	6	5	Yogurt with fruit
66	6	6	8:35 AM
67	6	7	Sushi
68	6	8	By bicycle
69	6	9	Light purple
70	6	10	I am a journalist
71	6	11	Between nine and ten hours
72	6	12	Yes a  guinea pig
73	7	1	33
74	7	2	Sydney
75	7	3	I play board games with friends
76	7	4	Twice a week
77	7	5	Toast and peanut butter
78	7	6	9:35 AM
79	7	7	Lasagna
80	7	8	By car
81	7	9	Blue
82	7	10	I am an accountant
83	7	11	About five and a half hours
84	7	12	Yes a goldfish
85	8	1	23
86	8	2	Glasgow
87	8	3	I go shopping in the city
88	8	4	Every four months
89	8	5	Pancakes with syrup
90	8	6	9:50 AM
91	8	7	Margherita pizza
92	8	8	By bus
93	8	9	Pink
94	8	10	I am a shop assistant
95	8	11	I never sleep
96	8	12	Yes a parrot
97	9	1	40
98	9	2	Newcastle
99	9	3	I play tennis at the club
100	9	4	Three times a week
101	9	5	A banana
102	9	6	8:50 AM
103	9	7	Grilled salmon
104	9	8	I rollerskate
105	9	9	Orange
106	9	10	I am a manager
107	9	11	About four hours
108	9	12	Yes a dog
109	10	1	20
110	10	2	Montreal
111	10	3	I visit my family
112	10	4	Once a month
113	10	5	Smoothie and toast
114	10	6	9:25 AM
115	10	7	Pad thai
116	10	8	By horse
117	10	9	Turquoise
118	10	10	I am a vet
119	10	11	About eight hours
120	10	12	Yes a cat and a dog
121	11	1	32
122	11	2	Nottingham
123	11	3	I go to the gym
124	11	4	Three times a week
125	11	5	Porridge with fruit
126	11	6	9:55 AM
127	11	7	Cheeseburger
128	11	8	By train
129	11	9	Black
130	11	10	I am a fitness trainer
131	11	11	About seven hours
132	11	12	Yes a pig
133	12	1	19
134	12	2	Oxford
135	12	3	I paint and listen to music
136	12	4	Three times a year
137	12	5	Biscuits and milk
138	12	6	9:40 AM
139	12	7	Risotto
140	12	8	By train
141	12	9	Light blue
142	12	10	I am an art student
143	12	11	About five hours
144	12	12	Yes a hamster
145	13	1	38
146	13	2	Los Angeles
147	13	3	I play video games
148	13	4	Never
149	13	5	Cereal and coffee
150	13	6	10:35 AM
151	13	7	Hot dogs
152	13	8	By horse
153	13	9	Red
154	13	10	I am a software developer
155	13	11	7 hours and 20 minutes
156	13	12	Yes a rat
157	14	1	29
158	14	2	York
159	14	3	I bake cakes for friends
160	14	4	Once a week
161	14	5	A bacon sandwich
162	14	6	10:10 AM
163	14	7	Chocolate cake
164	14	8	I walk
165	14	9	Brown
166	14	10	I am a baker
167	14	11	About seven and a half hours
168	14	12	Yes a spider
169	15	1	43
170	15	2	San Francisco
171	15	3	I go fishing
172	15	4	Never
173	15	5	Eggs and mushrooms
174	15	6	8:30 AM
175	15	7	Roast beef
176	15	8	I ice-skate
177	15	9	Brown
178	15	10	I am a builder
179	15	11	About six and a half hours
180	15	12	No pets
181	16	1	18
182	16	2	Cambridge
183	16	3	I go dancing with friends
184	16	4	Once a year
185	16	5	Cold pizza
186	16	6	9:15 AM
187	16	7	Tacos
188	16	8	I swim
189	16	9	Dark Pink
190	16	10	I am a dance teacher
191	16	11	About ten hours
192	16	12	Yes a  guinea pig
193	17	1	35
194	17	2	Dublin
195	17	3	I play music in a band
196	17	4	Every two months
197	17	5	Muesli and milk
198	17	6	10:30 AM
199	17	7	Spicy curry
200	17	8	By bus
201	17	9	Light yellow
202	17	10	I am a musician
203	17	11	Between seven and eight hours
204	17	12	Yes a ferret
205	18	1	28
206	18	2	Springfield
207	18	3	I visit museums and galleries
208	18	4	Once a week
209	18	5	Bagel and cream cheese
210	18	6	9:10 AM
211	18	7	Falafel
212	18	8	By helicopter
213	18	9	Light blue
214	18	10	I am a history teacher
215	18	11	About nine hours
216	18	12	No pets
217	19	1	39
218	19	2	Leicester
219	19	3	I watch films at home
220	19	4	Once a month
221	19	5	Coffee
222	19	6	10:15 AM
223	19	7	Fried chicken
224	19	8	By underground train
225	19	9	Dark red
226	19	10	I am a bus driver
227	19	11	About six hours
228	19	12	Yes an iguana
229	20	1	22
230	20	2	New York
231	20	3	I go swimming
232	20	4	Twice a year
233	20	5	Fruit and yogurt
234	20	6	8:40 AM
235	20	7	Pasta with tomato sauce
236	20	8	By taxi
237	20	9	Yellow
238	20	10	I am a lifeguard
239	20	11	Between eight and nine hours
240	20	12	Yes a cat
241	21	1	37
242	21	2	Aukland
243	21	3	I play golf
244	21	4	Every three months
245	21	5	Porridge and tea
246	21	6	10:20 AM
247	21	7	Roast vegetables
248	21	8	By taxi
249	21	9	Light green
250	21	10	I am a librarian
251	21	11	About eight and a half hours
252	21	12	Yes a canary bird
253	22	1	41
254	22	2	Liverpool
255	22	3	I work in my garden
256	22	4	Every two months
257	22	5	Toast with marmalade
258	22	6	9:05 AM
259	22	7	Barbecue
260	22	8	I walk
261	22	9	Dark green
262	22	10	I am an engineer
263	22	11	About 11 hours
264	22	12	Yes a horse
265	23	1	26
266	23	2	Washington
267	23	3	I do graffiti around the city
268	23	4	Once a year
269	23	5	Pancakes and fruit
270	23	6	9:45 AM
271	23	7	Noodles
272	23	8	By underground train
273	23	9	Light orange
274	23	10	I am a receptionist
275	23	11	Between four and five hours
276	23	12	Yes a horse
277	24	1	31
278	24	2	London
279	24	3	I play basketball
280	24	4	Twice a week
281	24	5	Cereal and juice
282	24	6	8:45 AM
283	24	7	Pizza with olives
284	24	8	By helicopter
285	24	9	Blue
286	24	10	I am a web designer
287	24	11	About four and a half hours
288	24	12	Yes a cat and a dog
289	25	1	24
290	25	2	Chicago
291	25	3	I do photography in the park
292	25	4	Twice a month
293	25	5	Nothing
294	25	6	10:25 AM
295	25	7	Stir fry
296	25	8	By bicycle
297	25	9	Purple
298	25	10	I am a youtuber
299	25	11	About ten and a half hours
300	25	12	Yes a tortoise
301	26	1	34
302	26	2	Vancouver
303	26	3	I go surfing
304	26	4	Three times a month
305	26	5	Eggs benedict
306	26	6	8:55 AM
307	26	7	Burgers
308	26	8	I run
309	26	9	Red
310	26	10	I am a mechanic
311	26	11	Less than 4 hours
312	26	12	Yes a goldfish
\.


--
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.characters (id, code, name, avatar_file) FROM stdin;
1	A	Anne Adams	001-nun.png
2	B	Barry Brooks	002-pirate.png
3	C	Charlie Carter	003-shark.png
4	D	Daisy Daniels	004-wrestler.png
5	E	Eddie Evans	005-angel.png
6	F	Fiona Fisher	006-viking.png
7	G	George Green	007-clown.png
8	H	Holly Harper	008-knight.png
9	I	Isaac Irving	009-emperor.png
10	J	Jenna Jones	010-frankestein.png
11	K	Kevin King	011-vampire.png
12	L	Lily Lewis	012-robot.png
13	M	Mason Miller	013-astronaut.png
14	N	Nora Nixon	014-police.png
15	O	Oscar Owens	015-king.png
16	P	Poppy Parker	016-devil.png
17	Q	Quinn Quigley	017-flower.png
18	R	Ruby Richards	018-indian.png
19	S	Sammy Scott	019-geisha.png
20	T	Tina Turner	020-ninja.png
21	U	Uma Underwood	021-sailor.png
22	V	Victor Vale	022-witch.png
23	W	Wendy Watson	023-cat.png
24	X	Xander Xavier	024-star.png
25	Y	Yara Young	025-ice-cream.png
26	Z	Zack Zimmerman	026-ghost.png
\.


--
-- Data for Name: game_players; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.game_players (id, game_id, display_name, role, is_alive, join_token, joined_at, character_id, character_assigned_at) FROM stdin;
3	1	Carol	baddie	t	cd16edbdeb8bed36b50b14717342b918	2025-11-27 15:24:22.262423	\N	\N
4	1	Duggie	baddie	t	a72e414417b82ef9f2644b72cdf177e5	2025-11-27 15:24:37.380191	\N	\N
29	7	Adam	baddie	t	f71f1a94c1d778c496b8446614044f63	2025-12-10 19:12:29.751977	25	\N
1	1	Adam	goodie	f	6b34131c2d660213c079785629523883	2025-11-27 15:23:58.142426	\N	\N
2	1	Brenda	goodie	f	8e0b8299327b37131b367079e56e1f9d	2025-11-27 15:24:06.169356	\N	\N
7	2	Oanu	baddie	t	4b62cb665c6a27de8088031712d74a2c	2025-12-07 17:36:23.013277	\N	\N
8	2	Paninu	baddie	t	109370637402eca597c06251109df73b	2025-12-07 17:36:40.554962	\N	\N
5	2	Manu	goodie	t	5659fde7ecebea0b93d7faef970d4ab1	2025-12-07 17:35:39.537338	\N	\N
6	2	Nannu	goodie	t	5b5bbbb5a59dc13c41f260f478ecd5b9	2025-12-07 17:36:12.744532	\N	\N
9	2	Quanduu	goodie	t	68a556210ad6bea1b1708499fee2fb45	2025-12-07 17:37:05.065185	\N	\N
10	3	Adam	baddie	t	e148b697c35bfb239d48387963ad8361	2025-12-07 22:57:04.425706	\N	\N
13	3	David	baddie	t	9e4c97d8d56aad88782ca4889a51f7c2	2025-12-07 22:57:35.468278	\N	\N
11	3	Ben	goodie	t	bcd082177638855ece7d850e274d626a	2025-12-07 22:57:11.66984	\N	\N
12	3	Charlie	goodie	t	fc4867c62274484ed822679f0a40d16d	2025-12-07 22:57:27.502312	\N	\N
14	4	William	baddie	f	676b6127dc01d888c639f47684a7338a	2025-12-08 10:38:22.734509	\N	\N
16	4	Zeta	goodie	f	8a2deb32a190f252e65aaebef8a7be57	2025-12-08 10:38:57.491543	\N	\N
15	4	Xander	baddie	f	eb1838a22531f492af5ccf5f736549a4	2025-12-08 10:38:25.941683	\N	\N
17	4	Yasmin	goodie	f	1815732199d0946a41fe1c4895e9b1d9	2025-12-08 10:39:02.893472	\N	\N
30	8	William	goodie	t	9ef05b84558408b4a26317aed71eb7cc	2025-12-10 19:51:47.723554	23	\N
18	5	William	baddie	t	9dc07be53d828ea0c4f92a012138a40b	2025-12-10 16:14:55.141661	7	\N
19	5	Carla	goodie	t	b84d88118c187cea4930680d86abf5e2	2025-12-10 16:15:19.516669	16	\N
20	5	Grace	goodie	t	447f79621ca2720ac54e58e31287c380	2025-12-10 16:15:37.466318	13	\N
21	5	Audrey	baddie	t	743617be6d4b1961070031d3ee86ed31	2025-12-10 16:15:55.433272	17	\N
31	8	Carla	goodie	t	150739ff5b3441cc138b1a3b6e594871	2025-12-10 19:51:58.342245	9	\N
32	8	Grace	baddie	t	8ad1697250e4a8a8687ea56ac05a21c5	2025-12-10 19:52:06.291536	4	\N
33	8	Audrey	baddie	f	780406274d8db866e947793d8bc32022	2025-12-10 19:52:22.70879	10	\N
22	6	William	baddie	t	104f0a2d16e9ef7102f5194bb532d3aa	2025-12-10 18:13:50.026187	4	\N
23	6	Carla	baddie	t	254c5b05d7ed20a2f5ba66b39d91878c	2025-12-10 18:14:12.029434	5	\N
24	6	Grace	goodie	t	c5a823735d5b62a60297a1840c377779	2025-12-10 18:14:27.429126	15	\N
25	6	Audrey	goodie	t	46135cbb4566d00068f6753ba24dab3e	2025-12-10 18:14:44.250693	2	\N
26	7	Dave	goodie	t	58cdf02872ba795d25c8656986e9f655	2025-12-10 19:12:23.492895	2	\N
27	7	Chris	baddie	t	cb29d151576d385c2ac5384e9722dfe2	2025-12-10 19:12:25.786521	6	\N
28	7	Ben	goodie	t	975b11fd8804cc868e86497d28b7d937	2025-12-10 19:12:27.718822	11	\N
\.


--
-- Data for Name: games; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.games (id, code, status, current_round, created_at, current_subround, phase, last_eliminated_player_id, last_eliminated_seq) FROM stdin;
3	94C63E	in_progress	2	2025-12-07 22:55:41.435069	2	feedback	\N	0
1	EE2443	in_progress	2	2025-11-27 15:22:23.168203	2	rally	\N	0
8	220E98	in_progress	3	2025-12-10 19:50:14.064785	1	interview1	33	1
4	9EF690	in_progress	4	2025-12-08 10:36:15.153214	1	rally	17	2
5	771977	in_progress	1	2025-12-10 16:14:25.451562	1	interview1	\N	0
2	573C37	in_progress	2	2025-12-07 17:33:48.140375	1	interview1	\N	0
6	FD3D2E	in_progress	1	2025-12-10 18:13:21.116794	2	interview2	\N	0
7	97DDA2	in_progress	1	2025-12-10 19:11:46.668407	2	interview2	\N	0
\.


--
-- Data for Name: interview_answers; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.interview_answers (id, interview_id, question_id, reported_value) FROM stdin;
\.


--
-- Data for Name: interview_assignments; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.interview_assignments (id, round_id, subround, interviewer_player_id, interviewee_player_id) FROM stdin;
1	1	1	1	4
2	1	1	4	1
3	1	1	2	3
4	1	1	3	2
5	1	2	1	2
6	1	2	4	3
7	1	2	2	1
8	1	2	3	4
9	2	1	2	3
10	2	1	3	2
11	2	1	4	1
12	2	1	1	4
13	2	2	2	4
14	2	2	3	1
15	2	2	4	2
16	2	2	1	3
17	3	1	8	7
18	3	1	7	8
19	3	1	6	5
20	3	1	5	9
21	3	1	9	6
22	3	2	8	6
23	3	2	7	9
24	3	2	6	8
25	3	2	5	7
26	3	2	9	5
27	4	1	9	5
28	4	1	5	9
29	4	1	7	6
30	4	1	6	8
31	4	1	8	7
32	4	2	9	7
33	4	2	5	8
34	4	2	7	9
35	4	2	6	5
36	4	2	8	6
37	5	1	12	10
38	5	1	10	12
39	5	1	11	13
40	5	1	13	11
41	5	2	12	11
42	5	2	10	13
43	5	2	11	12
44	5	2	13	10
45	6	1	10	11
46	6	1	11	10
47	6	1	12	13
48	6	1	13	12
49	6	2	10	12
50	6	2	11	13
51	6	2	12	10
52	6	2	13	11
53	7	1	17	15
54	7	1	15	17
55	7	1	14	16
56	7	1	16	14
57	7	2	17	14
58	7	2	15	16
59	7	2	14	17
60	7	2	16	15
61	8	1	17	15
62	8	1	15	17
63	8	1	16	14
64	8	1	14	16
65	8	2	17	16
66	8	2	15	14
67	8	2	16	17
68	8	2	14	15
69	9	1	15	17
70	9	1	17	15
71	9	1	14	16
72	9	1	16	14
73	9	2	15	14
74	9	2	17	16
75	9	2	14	15
76	9	2	16	17
77	10	1	17	14
78	10	1	14	17
79	10	1	16	15
80	10	1	15	16
81	10	2	17	16
82	10	2	14	15
83	10	2	16	17
84	10	2	15	14
85	11	1	20	21
86	11	1	21	20
87	11	1	18	19
88	11	1	19	18
89	11	2	20	18
90	11	2	21	19
91	11	2	18	20
92	11	2	19	21
93	12	1	25	22
94	12	1	22	25
95	12	1	23	24
96	12	1	24	23
97	12	2	25	23
98	12	2	22	24
99	12	2	23	25
100	12	2	24	22
101	13	1	28	26
102	13	1	26	28
103	13	1	27	29
104	13	1	29	27
105	13	2	28	27
106	13	2	26	29
107	13	2	27	28
108	13	2	29	26
109	14	1	31	30
110	14	1	30	31
111	14	1	32	33
112	14	1	33	32
113	14	2	31	32
114	14	2	30	33
115	14	2	32	31
116	14	2	33	30
117	15	1	31	32
118	15	1	32	31
119	15	1	33	30
120	15	1	30	33
121	15	2	31	33
122	15	2	32	30
123	15	2	33	31
124	15	2	30	32
125	16	1	31	32
126	16	1	32	31
127	16	1	33	30
128	16	1	30	33
129	16	2	31	33
130	16	2	32	30
131	16	2	33	31
132	16	2	30	32
\.


--
-- Data for Name: interviews; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.interviews (id, round_id, interviewer_player_id, interviewee_player_id, created_at) FROM stdin;
1	1	1	4	2025-11-27 15:26:30.257858
2	1	4	1	2025-11-27 15:26:50.761988
3	1	3	2	2025-11-27 15:27:32.789919
4	1	2	3	2025-11-27 15:27:52.933359
5	1	1	2	2025-11-27 15:28:54.354034
6	1	2	1	2025-11-27 15:29:23.926925
7	1	3	4	2025-11-27 15:30:28.577161
8	1	4	3	2025-11-27 15:31:00.219349
9	2	1	4	2025-11-27 21:54:52.631059
10	5	10	12	2025-12-07 23:12:20.661713
12	5	13	11	2025-12-07 23:12:26.200596
11	5	12	10	2025-12-07 23:12:33.03445
13	5	11	13	2025-12-07 23:12:37.502489
22	6	10	11	2025-12-07 23:23:51.140519
23	6	12	13	2025-12-07 23:24:18.151317
24	6	11	10	2025-12-07 23:24:39.96496
25	6	13	12	2025-12-07 23:25:03.058022
18	6	10	12	2025-12-07 23:25:33.739564
21	6	13	11	2025-12-07 23:25:56.308726
19	6	12	10	2025-12-07 23:26:18.463568
20	6	11	13	2025-12-07 23:26:39.198334
30	7	14	16	2025-12-08 10:39:58.828037
31	7	16	14	2025-12-08 10:40:14.123972
32	7	17	15	2025-12-08 10:40:35.541061
33	7	15	17	2025-12-08 10:40:45.426186
34	7	17	14	2025-12-08 10:41:08.703656
35	7	14	17	2025-12-08 10:41:18.080125
36	7	15	16	2025-12-08 10:41:28.01334
37	7	16	15	2025-12-08 10:41:37.82648
38	8	17	15	2025-12-08 11:27:30.934478
39	8	16	14	2025-12-08 11:27:55.53816
40	8	15	17	2025-12-08 11:28:24.018165
41	8	14	16	2025-12-08 11:28:50.599549
42	8	14	15	2025-12-08 11:29:26.007215
43	8	17	16	2025-12-08 11:29:44.265311
45	8	16	17	2025-12-08 11:30:20.180359
44	8	15	14	2025-12-08 11:30:25.115382
47	9	14	16	2025-12-08 12:17:17.235844
50	9	17	15	2025-12-08 12:17:29.615878
51	9	15	17	2025-12-08 12:17:39.04877
52	9	16	14	2025-12-08 12:17:56.566094
56	9	14	15	2025-12-08 12:19:14.114156
55	9	17	16	2025-12-08 12:19:34.366531
54	9	15	14	2025-12-08 12:19:56.037379
57	9	16	17	2025-12-08 12:20:17.956071
\.


--
-- Data for Name: player_profiles; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.player_profiles (id, game_player_id, question_id, answer_value) FROM stdin;
1	22	1	21
2	22	2	Dallas
3	22	3	I meet friends in cafes
4	22	4	Twice a month
5	22	5	Croissant and orange juice
6	22	6	10:00 AM
7	22	7	Vegetable curry
8	22	8	I run
9	22	9	White
10	22	10	I am a photographer
11	22	11	Between five and six hours
12	22	12	Yes a rabbit
13	23	1	42
14	23	2	Miami
15	23	3	I work on my car
16	23	4	Every six weeks
17	23	5	Fried eggs and toast
18	23	6	10:05 AM
19	23	7	Steak and chips
20	23	8	By car
21	23	9	Dark blue
22	23	10	I am a taxi driver
23	23	11	8 hours exactly
24	23	12	Yes a snake
25	24	1	43
26	24	2	San Francisco
27	24	3	I go fishing
28	24	4	Never
29	24	5	Eggs and mushrooms
30	24	6	8:30 AM
31	24	7	Roast beef
32	24	8	I ice-skate
33	24	9	Brown
34	24	10	I am a builder
35	24	11	About six and a half hours
36	24	12	No pets
37	25	1	36
38	25	2	Manchester
39	25	3	I play football in the park
40	25	4	Every two years
41	25	5	Bacon and eggs
42	25	6	9:00 AM
43	25	7	Fish and chips
44	25	8	I row my boat
45	25	9	Pink
46	25	10	I am an electrician
47	25	11	7 hours and 30 minutes
48	25	12	Yes a hamster
49	26	1	36
50	26	2	Manchester
51	26	3	I play football in the park
52	26	4	Every two years
53	26	5	Bacon and eggs
54	26	6	9:00 AM
55	26	7	Fish and chips
56	26	8	I row my boat
57	26	9	Pink
58	26	10	I am an electrician
59	26	11	7 hours and 30 minutes
60	26	12	Yes a hamster
61	27	1	27
62	27	2	Leeds
63	27	3	I do yoga and read books
64	27	4	Four times a year
65	27	5	Yogurt with fruit
66	27	6	8:35 AM
67	27	7	Sushi
68	27	8	By bicycle
69	27	9	Light purple
70	27	10	I am a journalist
71	27	11	Between nine and ten hours
72	27	12	Yes a  guinea pig
73	28	1	32
74	28	2	Nottingham
75	28	3	I go to the gym
76	28	4	Three times a week
77	28	5	Porridge with fruit
78	28	6	9:55 AM
79	28	7	Cheeseburger
80	28	8	By train
81	28	9	Black
82	28	10	I am a fitness trainer
83	28	11	About seven hours
84	28	12	Yes a pig
85	29	1	24
86	29	2	Chicago
87	29	3	I do photography in the park
88	29	4	Twice a month
89	29	5	Nothing
90	29	6	10:25 AM
91	29	7	Stir fry
92	29	8	By bicycle
93	29	9	Purple
94	29	10	I am a youtuber
95	29	11	About ten and a half hours
96	29	12	Yes a tortoise
97	30	1	26
98	30	2	Washington
99	30	3	I do graffiti around the city
100	30	4	Once a year
101	30	5	Pancakes and fruit
102	30	6	9:45 AM
103	30	7	Noodles
104	30	8	By underground train
105	30	9	Light orange
106	30	10	I am a receptionist
107	30	11	Between four and five hours
108	30	12	Yes a horse
109	31	1	40
110	31	2	Newcastle
111	31	3	I play tennis at the club
112	31	4	Three times a week
113	31	5	A banana
114	31	6	8:50 AM
115	31	7	Grilled salmon
116	31	8	I rollerskate
117	31	9	Orange
118	31	10	I am a manager
119	31	11	About four hours
120	31	12	Yes a dog
121	32	1	21
122	32	2	Dallas
123	32	3	I meet friends in cafes
124	32	4	Twice a month
125	32	5	Croissant and orange juice
126	32	6	10:00 AM
127	32	7	Vegetable curry
128	32	8	I run
129	32	9	White
130	32	10	I am a photographer
131	32	11	Between five and six hours
132	32	12	Yes a rabbit
133	33	1	20
134	33	2	Montreal
135	33	3	I visit my family
136	33	4	Once a month
137	33	5	Smoothie and toast
138	33	6	9:25 AM
139	33	7	Pad thai
140	33	8	By horse
141	33	9	Turquoise
142	33	10	I am a vet
143	33	11	About eight hours
144	33	12	Yes a cat and a dog
\.


--
-- Data for Name: pod_members; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.pod_members (id, pod_id, game_player_id) FROM stdin;
1	1	1
2	1	4
3	1	2
4	1	3
5	2	2
6	2	3
7	2	4
8	2	1
9	3	8
10	3	7
11	3	6
12	3	5
13	3	9
14	4	9
15	4	5
16	4	7
17	4	6
18	4	8
19	5	12
20	5	10
21	5	11
22	5	13
23	6	10
24	6	11
25	6	12
26	6	13
27	7	17
28	7	15
29	7	14
30	7	16
31	8	17
32	8	15
33	8	16
34	8	14
35	9	15
36	9	17
37	9	14
38	9	16
39	10	17
40	10	14
41	10	16
42	10	15
43	11	20
44	11	21
45	11	18
46	11	19
47	12	25
48	12	22
49	12	23
50	12	24
51	13	28
52	13	26
53	13	27
54	13	29
55	14	31
56	14	30
57	14	32
58	14	33
59	15	31
60	15	32
61	15	33
62	15	30
63	16	31
64	16	32
65	16	33
66	16	30
\.


--
-- Data for Name: pods; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.pods (id, game_id, round_id, label) FROM stdin;
1	1	1	Pod A
2	1	2	Pod A
3	2	3	Pod A
4	2	4	Pod A
5	3	5	Pod A
6	3	6	Pod A
7	4	7	Pod A
8	4	8	Pod A
9	4	9	Pod A
10	4	10	Pod A
11	5	11	Pod A
12	6	12	Pod A
13	7	13	Pod A
14	8	14	Pod A
15	8	15	Pod A
16	8	16	Pod A
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.questions (id, text) FROM stdin;
1	How old are you?
2	Where are you from?
3	What do you do at the weekend?
4	How often do you go to the hairdresser?
5	What do you have for breakfast?
6	What time do you get up on Sundays?
7	What is your favourite food?
8	How do you travel to work each day?
9	What is your favourite colour?
10	What do you do?
11	How long do you sleep each night?
12	Have you got any pets?
\.


--
-- Data for Name: round_questions; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.round_questions (id, round_id, question_id, display_order) FROM stdin;
1	13	1	1
2	13	4	2
3	13	8	3
4	13	3	4
5	14	2	1
6	14	12	2
7	14	6	3
8	14	1	4
9	15	12	1
10	15	10	2
11	15	11	3
12	15	9	4
13	16	5	1
14	16	6	2
15	16	9	3
16	16	12	4
\.


--
-- Data for Name: rounds; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.rounds (id, game_id, round_number, status, created_at) FROM stdin;
1	1	1	interviews	2025-11-27 15:24:49.059646
2	1	2	interviews	2025-11-27 21:50:45.992468
3	2	1	interviews	2025-12-07 17:37:20.107651
4	2	2	interviews	2025-12-07 19:32:39.386133
5	3	1	interviews	2025-12-07 22:57:47.25238
6	3	2	interviews	2025-12-07 23:12:01.499098
7	4	1	interviews	2025-12-08 10:39:11.284505
8	4	2	interviews	2025-12-08 11:24:01.169803
9	4	3	interviews	2025-12-08 12:16:30.08423
10	4	4	interviews	2025-12-08 13:28:14.947637
11	5	1	interviews	2025-12-10 16:16:06.423467
12	6	1	interviews	2025-12-10 18:15:04.211979
13	7	1	interviews	2025-12-10 19:12:39.332798
14	8	1	interviews	2025-12-10 19:52:30.520741
15	8	2	interviews	2025-12-10 19:54:52.150777
16	8	3	interviews	2025-12-10 19:59:13.956398
\.


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: williamkingdom
--

COPY public.votes (id, round_id, voter_player_id, target_player_id, created_at) FROM stdin;
1	1	3	1	2025-11-27 15:34:08.627533
2	1	4	1	2025-11-27 15:34:19.976029
3	1	1	3	2025-11-27 15:35:08.861858
4	1	2	1	2025-11-27 15:35:22.959583
5	2	4	2	2025-11-27 21:57:26.638241
6	2	3	2	2025-11-27 21:57:40.101618
7	2	2	3	2025-11-27 21:57:52.146627
8	7	14	15	2025-12-08 11:22:18.823819
10	7	15	14	2025-12-08 11:22:54.880523
9	7	17	14	2025-12-08 11:23:00.873572
11	7	16	14	2025-12-08 11:23:08.474076
19	8	15	16	2025-12-08 12:15:46.323513
21	8	17	16	2025-12-08 12:15:59.017432
22	8	16	15	2025-12-08 12:16:06.468753
23	9	17	15	2025-12-08 12:28:26.816778
24	9	15	17	2025-12-08 12:28:31.911612
25	15	30	33	2025-12-10 19:57:39.659235
26	15	32	33	2025-12-10 19:57:51.190904
27	15	33	31	2025-12-10 19:58:04.460136
28	15	31	33	2025-12-10 19:58:20.157512
\.


--
-- Name: baddie_mutations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.baddie_mutations_id_seq', 10, true);


--
-- Name: character_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.character_profiles_id_seq', 312, true);


--
-- Name: characters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.characters_id_seq', 26, true);


--
-- Name: game_players_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.game_players_id_seq', 33, true);


--
-- Name: games_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.games_id_seq', 8, true);


--
-- Name: interview_answers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.interview_answers_id_seq', 1, false);


--
-- Name: interview_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.interview_assignments_id_seq', 132, true);


--
-- Name: interviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.interviews_id_seq', 65, true);


--
-- Name: player_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.player_profiles_id_seq', 144, true);


--
-- Name: pod_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.pod_members_id_seq', 66, true);


--
-- Name: pods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.pods_id_seq', 16, true);


--
-- Name: questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.questions_id_seq', 12, true);


--
-- Name: round_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.round_questions_id_seq', 16, true);


--
-- Name: rounds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.rounds_id_seq', 16, true);


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: williamkingdom
--

SELECT pg_catalog.setval('public.votes_id_seq', 28, true);


--
-- Name: baddie_mutations baddie_mutations_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.baddie_mutations
    ADD CONSTRAINT baddie_mutations_pkey PRIMARY KEY (id);


--
-- Name: baddie_mutations baddie_mutations_round_id_game_player_id_question_id_key; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.baddie_mutations
    ADD CONSTRAINT baddie_mutations_round_id_game_player_id_question_id_key UNIQUE (round_id, game_player_id, question_id);


--
-- Name: character_profiles character_profiles_character_id_question_id_key; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.character_profiles
    ADD CONSTRAINT character_profiles_character_id_question_id_key UNIQUE (character_id, question_id);


--
-- Name: character_profiles character_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.character_profiles
    ADD CONSTRAINT character_profiles_pkey PRIMARY KEY (id);


--
-- Name: characters characters_code_key; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_code_key UNIQUE (code);


--
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- Name: game_players game_players_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.game_players
    ADD CONSTRAINT game_players_pkey PRIMARY KEY (id);


--
-- Name: games games_code_key; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_code_key UNIQUE (code);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: interview_answers interview_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interview_answers
    ADD CONSTRAINT interview_answers_pkey PRIMARY KEY (id);


--
-- Name: interview_assignments interview_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interview_assignments
    ADD CONSTRAINT interview_assignments_pkey PRIMARY KEY (id);


--
-- Name: interviews interviews_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_pkey PRIMARY KEY (id);


--
-- Name: interviews interviews_round_id_interviewer_player_id_interviewee_playe_key; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_round_id_interviewer_player_id_interviewee_playe_key UNIQUE (round_id, interviewer_player_id, interviewee_player_id);


--
-- Name: player_profiles player_profiles_game_player_id_question_id_key; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.player_profiles
    ADD CONSTRAINT player_profiles_game_player_id_question_id_key UNIQUE (game_player_id, question_id);


--
-- Name: player_profiles player_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.player_profiles
    ADD CONSTRAINT player_profiles_pkey PRIMARY KEY (id);


--
-- Name: pod_members pod_members_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.pod_members
    ADD CONSTRAINT pod_members_pkey PRIMARY KEY (id);


--
-- Name: pods pods_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.pods
    ADD CONSTRAINT pods_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: round_questions round_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.round_questions
    ADD CONSTRAINT round_questions_pkey PRIMARY KEY (id);


--
-- Name: round_questions round_questions_round_id_question_id_key; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.round_questions
    ADD CONSTRAINT round_questions_round_id_question_id_key UNIQUE (round_id, question_id);


--
-- Name: rounds rounds_game_id_round_number_key; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.rounds
    ADD CONSTRAINT rounds_game_id_round_number_key UNIQUE (game_id, round_number);


--
-- Name: rounds rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.rounds
    ADD CONSTRAINT rounds_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: votes votes_round_id_voter_player_id_key; Type: CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_round_id_voter_player_id_key UNIQUE (round_id, voter_player_id);


--
-- Name: baddie_mutations baddie_mutations_game_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.baddie_mutations
    ADD CONSTRAINT baddie_mutations_game_player_id_fkey FOREIGN KEY (game_player_id) REFERENCES public.game_players(id);


--
-- Name: baddie_mutations baddie_mutations_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.baddie_mutations
    ADD CONSTRAINT baddie_mutations_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: baddie_mutations baddie_mutations_round_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.baddie_mutations
    ADD CONSTRAINT baddie_mutations_round_id_fkey FOREIGN KEY (round_id) REFERENCES public.rounds(id) ON DELETE CASCADE;


--
-- Name: character_profiles character_profiles_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.character_profiles
    ADD CONSTRAINT character_profiles_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- Name: character_profiles character_profiles_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.character_profiles
    ADD CONSTRAINT character_profiles_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: game_players game_players_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.game_players
    ADD CONSTRAINT game_players_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: game_players game_players_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.game_players
    ADD CONSTRAINT game_players_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id) ON DELETE CASCADE;


--
-- Name: interview_answers interview_answers_interview_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interview_answers
    ADD CONSTRAINT interview_answers_interview_id_fkey FOREIGN KEY (interview_id) REFERENCES public.interviews(id) ON DELETE CASCADE;


--
-- Name: interview_answers interview_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interview_answers
    ADD CONSTRAINT interview_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: interview_assignments interview_assignments_interviewee_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interview_assignments
    ADD CONSTRAINT interview_assignments_interviewee_player_id_fkey FOREIGN KEY (interviewee_player_id) REFERENCES public.game_players(id) ON DELETE CASCADE;


--
-- Name: interview_assignments interview_assignments_interviewer_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interview_assignments
    ADD CONSTRAINT interview_assignments_interviewer_player_id_fkey FOREIGN KEY (interviewer_player_id) REFERENCES public.game_players(id) ON DELETE CASCADE;


--
-- Name: interview_assignments interview_assignments_round_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interview_assignments
    ADD CONSTRAINT interview_assignments_round_id_fkey FOREIGN KEY (round_id) REFERENCES public.rounds(id) ON DELETE CASCADE;


--
-- Name: interviews interviews_interviewee_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_interviewee_player_id_fkey FOREIGN KEY (interviewee_player_id) REFERENCES public.game_players(id);


--
-- Name: interviews interviews_interviewer_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_interviewer_player_id_fkey FOREIGN KEY (interviewer_player_id) REFERENCES public.game_players(id);


--
-- Name: interviews interviews_round_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_round_id_fkey FOREIGN KEY (round_id) REFERENCES public.rounds(id) ON DELETE CASCADE;


--
-- Name: player_profiles player_profiles_game_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.player_profiles
    ADD CONSTRAINT player_profiles_game_player_id_fkey FOREIGN KEY (game_player_id) REFERENCES public.game_players(id) ON DELETE CASCADE;


--
-- Name: player_profiles player_profiles_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.player_profiles
    ADD CONSTRAINT player_profiles_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: pod_members pod_members_game_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.pod_members
    ADD CONSTRAINT pod_members_game_player_id_fkey FOREIGN KEY (game_player_id) REFERENCES public.game_players(id) ON DELETE CASCADE;


--
-- Name: pod_members pod_members_pod_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.pod_members
    ADD CONSTRAINT pod_members_pod_id_fkey FOREIGN KEY (pod_id) REFERENCES public.pods(id) ON DELETE CASCADE;


--
-- Name: pods pods_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.pods
    ADD CONSTRAINT pods_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id) ON DELETE CASCADE;


--
-- Name: pods pods_round_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.pods
    ADD CONSTRAINT pods_round_id_fkey FOREIGN KEY (round_id) REFERENCES public.rounds(id) ON DELETE CASCADE;


--
-- Name: round_questions round_questions_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.round_questions
    ADD CONSTRAINT round_questions_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: round_questions round_questions_round_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.round_questions
    ADD CONSTRAINT round_questions_round_id_fkey FOREIGN KEY (round_id) REFERENCES public.rounds(id) ON DELETE CASCADE;


--
-- Name: rounds rounds_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.rounds
    ADD CONSTRAINT rounds_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id) ON DELETE CASCADE;


--
-- Name: votes votes_round_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_round_id_fkey FOREIGN KEY (round_id) REFERENCES public.rounds(id) ON DELETE CASCADE;


--
-- Name: votes votes_target_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_target_player_id_fkey FOREIGN KEY (target_player_id) REFERENCES public.game_players(id);


--
-- Name: votes votes_voter_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: williamkingdom
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_voter_player_id_fkey FOREIGN KEY (voter_player_id) REFERENCES public.game_players(id);


--
-- PostgreSQL database dump complete
--

\unrestrict aFodlpkjv7V4hQiZDEcFPz9gQ8j53GcZTwcObsBrqCyQs0csY90rwMsipmKRmBc

