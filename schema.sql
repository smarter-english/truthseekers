--
-- PostgreSQL database dump
--

\restrict A15wRqcwewjk9mogbeCQQ0unzL9uVDtvRwSTb7xV1zrKxLLq4QLxwPP6jcfjR23

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
-- Name: game_players; Type: TABLE; Schema: public; Owner: williamkingdom
--

CREATE TABLE public.game_players (
    id integer NOT NULL,
    game_id integer NOT NULL,
    display_name character varying(50) NOT NULL,
    role character varying(20) DEFAULT 'unknown'::character varying NOT NULL,
    is_alive boolean DEFAULT true NOT NULL,
    join_token character varying(64) NOT NULL,
    joined_at timestamp without time zone DEFAULT now() NOT NULL
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

\unrestrict A15wRqcwewjk9mogbeCQQ0unzL9uVDtvRwSTb7xV1zrKxLLq4QLxwPP6jcfjR23

