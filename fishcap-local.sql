--
-- PostgreSQL database dump
--

\restrict mJobcybZeTVR3PilomPaxeyl3CVZmnFe1QdfjvgQmyGV6RUL0WaR4urw4O7KtOj

-- Dumped from database version 16.14 (Debian 16.14-1.pgdg13+1)
-- Dumped by pg_dump version 16.14 (Debian 16.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.batches (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    pond_id uuid,
    species_id uuid NOT NULL,
    stocking_date timestamp without time zone NOT NULL,
    initial_count integer NOT NULL,
    current_count integer,
    initial_weight integer,
    mortality_rate numeric(5,2)
);


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devices (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    pond_id uuid,
    device_code character varying(50) NOT NULL,
    status character varying(20) DEFAULT 'AVAILABLE'::character varying NOT NULL,
    device_name character varying(100),
    assigned_at timestamp with time zone,
    released_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: feed_calculations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feed_calculations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    batch_id uuid NOT NULL,
    target_date timestamp without time zone NOT NULL,
    total_feed_grams numeric(12,2) NOT NULL,
    details jsonb,
    language character varying(5) DEFAULT 'km'::character varying NOT NULL
);


--
-- Name: feed_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feed_schedules (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    pond_id uuid NOT NULL,
    feed_time time without time zone NOT NULL,
    feed_amount numeric(10,2) NOT NULL,
    is_active boolean DEFAULT true,
    title character varying(100),
    last_synced_at timestamp with time zone,
    last_sync_status character varying(50),
    sync_attempts integer DEFAULT 0 NOT NULL
);


--
-- Name: feeding_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feeding_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    pond_id uuid NOT NULL,
    schedule_id uuid,
    feed_amount numeric(10,2),
    status character varying(20),
    fed_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: fish_species; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fish_species (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name_en character varying(100) NOT NULL,
    name_km character varying(100) NOT NULL,
    aliases jsonb,
    growth_stages jsonb,
    default_initial_weight integer,
    environment jsonb
);


--
-- Name: fishcap_typeorm_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fishcap_typeorm_migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: fishcap_typeorm_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fishcap_typeorm_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fishcap_typeorm_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fishcap_typeorm_migrations_id_seq OWNED BY public.fishcap_typeorm_migrations.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    name character varying NOT NULL,
    executed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    title character varying(200) NOT NULL,
    message text,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: otps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.otps (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(200) NOT NULL,
    code character varying(20) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    used boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: ponds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ponds (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    pond_name character varying(100) NOT NULL,
    location character varying(255),
    fish_type character varying(100),
    fish_count integer,
    start_date character varying(20),
    end_date character varying(20),
    feeding_times jsonb,
    amount numeric(10,2),
    hardware_id character varying(100),
    status character varying(20) DEFAULT 'active'::character varying,
    status_color character varying(20),
    has_alert boolean DEFAULT false,
    temperature character varying(20),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: sensor_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sensor_data (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    device_id character varying(100) NOT NULL,
    temperature numeric(5,2),
    ph numeric(4,2),
    dissolved_oxygen numeric(5,2),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    weight_grams numeric(10,2),
    feeding boolean,
    feed_grams_dispensed numeric(10,2),
    remaining_stock_grams numeric(10,2),
    low_stock boolean,
    tds numeric(8,2),
    pond_id uuid
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255),
    phone character varying(20),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    profile_image character varying(500),
    "resetTokenHash" character varying,
    "resetTokenExpiresAt" timestamp with time zone,
    profile_image_public_id character varying(255)
);


--
-- Name: fishcap_typeorm_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fishcap_typeorm_migrations ALTER COLUMN id SET DEFAULT nextval('public.fishcap_typeorm_migrations_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Data for Name: batches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.batches (id, pond_id, species_id, stocking_date, initial_count, current_count, initial_weight, mortality_rate) FROM stdin;
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.devices (id, pond_id, device_code, status, device_name, assigned_at, released_at, created_at, updated_at) FROM stdin;
60b7ff51-0a4d-456f-9f2a-773e3e5010b7	1f4d1d55-6837-463e-ab5a-0461aeed917f	DEMO-DEVICE-001	ONLINE	\N	\N	\N	2026-09-16 15:44:31.65378+00	2026-09-16 15:44:31.664062+00
ec400621-1800-4292-bb25-f72b4b4d95bf	4408c859-fa79-42d6-bcaa-53443d155d95	fishcap_001	ONLINE	\N	\N	\N	2026-09-16 15:44:31.65378+00	2026-09-16 15:44:31.664062+00
187c9e48-d11c-44ce-a8ab-a1aa17366c2f	13d3c394-ca4a-4198-9490-07bd0176bdbd	fishcap_002	ONLINE	\N	\N	\N	2026-09-16 15:44:31.65378+00	2026-09-16 15:44:31.664062+00
b55e0ab7-7436-4fbb-9232-d05ec3a88160	3c77d537-971b-421d-9ec5-284102f380ed	fishcap_004	ASSIGNED	\N	2026-09-17 02:39:18.638+00	\N	2026-09-17 02:39:18.463013+00	2026-09-17 02:39:18.643657+00
990aa809-f6a6-48a6-9b90-9ca3903be452	7c6ddb01-5cd5-4f80-abc9-fbab2f706521	fishcap_005	ASSIGNED	\N	2026-09-17 03:07:43.348+00	\N	2026-09-17 03:07:43.214697+00	2026-09-17 03:07:43.351675+00
837b4d81-81bd-4e24-8d9e-20aa00950922	00347294-5086-4268-800f-5e6230e4867b	FEEDER-1534-AX	ASSIGNED	\N	2026-09-18 04:07:46.048+00	\N	2026-09-18 04:07:01.560865+00	2026-09-18 04:07:46.047445+00
fdcda190-69e0-4106-8c88-558dcbc4691c	\N	fishcap_008	AVAILABLE	\N	2026-09-19 10:51:09.477+00	2026-10-28 05:45:31.527+00	2026-09-19 10:51:09.350613+00	2026-10-28 05:45:31.482895+00
\.


--
-- Data for Name: feed_calculations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.feed_calculations (id, batch_id, target_date, total_feed_grams, details, language) FROM stdin;
\.


--
-- Data for Name: feed_schedules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.feed_schedules (id, pond_id, feed_time, feed_amount, is_active, title, last_synced_at, last_sync_status, sync_attempts) FROM stdin;
747ab4d9-02b4-44a6-83c3-60936dd68854	1f4d1d55-6837-463e-ab5a-0461aeed917f	08:00:00	100.00	t	\N	\N	\N	0
84389501-bb1a-4be2-ac00-e41500b9b120	00347294-5086-4268-800f-5e6230e4867b	09:09:00	8.00	t	\N	\N	\N	0
c4d4c15d-1a05-4fa9-8daf-cd682b308431	ec52ffd8-0d14-4277-a73e-a4803a8b7c6d	08:00:00	125.00	t	\N	\N	\N	0
dd9583c1-c0f6-42ef-8991-1a0e3513ac50	ec52ffd8-0d14-4277-a73e-a4803a8b7c6d	13:00:00	125.00	t	\N	\N	\N	0
623c0b7d-3e05-4920-9d73-e4fe5bfee414	ec52ffd8-0d14-4277-a73e-a4803a8b7c6d	18:00:00	125.00	t	\N	\N	\N	0
7c3e8221-0822-4423-ad3d-f19082d7f9e6	a1852c20-c0ff-4175-92fe-2bdde538d976	08:00:00	75.00	t	\N	\N	\N	0
61fb9562-e7e7-43f6-8e6c-41470625417a	a1852c20-c0ff-4175-92fe-2bdde538d976	13:00:00	75.00	t	\N	\N	\N	0
e0ca327a-5920-4c89-a724-f84d0fe4580c	a1852c20-c0ff-4175-92fe-2bdde538d976	18:00:00	75.00	t	\N	\N	\N	0
72bb5b4d-4ecd-49fb-9db0-646b01b4bde4	efa43877-1fd7-4ee5-b4e9-da97faea07f3	08:42:00	4.00	t	\N	\N	\N	0
e44f1b3a-f9be-4e13-ac92-a397a4ceb568	4408c859-fa79-42d6-bcaa-53443d155d95	14:42:00	0.50	t	\N	2026-09-09 07:42:02.233+00	failed	1
0a7986c2-9ccb-400f-9409-7149b06c3e5b	4408c859-fa79-42d6-bcaa-53443d155d95	15:00:00	0.50	t	\N	2026-09-09 08:00:12.407+00	failed	1
02c9525b-427d-42d4-b2dc-5e7f365190bf	cf6219ad-8194-47c9-b5e5-65be1c02867a	15:52:00	0.50	t	\N	\N	\N	0
57429bb7-ef88-4d50-97e7-d3102829d462	b4837108-e174-48cd-9aba-b2444bd88dc5	08:00:00	7.50	t	\N	\N	\N	0
bd0d183f-aad7-4b92-b8a2-1d4707c14d43	b4837108-e174-48cd-9aba-b2444bd88dc5	13:00:00	7.50	t	\N	\N	\N	0
6b12507b-506a-40f6-a5eb-dc4d68897590	b4837108-e174-48cd-9aba-b2444bd88dc5	18:00:00	7.50	t	\N	\N	\N	0
63a257e9-2499-432a-b39e-125e616f383a	edf20d9e-95f4-4df1-89da-3178dd43bbee	09:55:00	1.00	t	\N	2026-09-16 02:55:04.801+00	failed	1
9b8eb6ff-167d-4d04-9683-20f85e6e80d7	e744c555-23ec-40e7-9ad0-0f6f52e4f63a	08:53:00	3.00	t	\N	\N	\N	0
ccf34eaf-7abd-4129-b901-5464d8a4f4fe	3c77d537-971b-421d-9ec5-284102f380ed	08:00:00	337.50	t	\N	\N	\N	0
1b00412b-e396-4fd1-a8a9-53b27ca609f7	3c77d537-971b-421d-9ec5-284102f380ed	18:00:00	337.50	t	\N	\N	\N	0
6dd3f048-e993-4ced-a92e-9b47e0501cea	268213b7-1ffe-44a1-a862-9c9fca9ba3ec	09:31:00	5.00	t	\N	\N	\N	0
e80be376-e50c-4ce5-8bc7-02f7c60c6e07	268213b7-1ffe-44a1-a862-9c9fca9ba3ec	10:22:00	8.00	t	\N	\N	\N	0
5c2abc85-f05b-464e-929b-e680524f821f	13d3c394-ca4a-4198-9490-07bd0176bdbd	14:32:00	1.50	t	\N	\N	\N	0
f144a53e-0a5e-4199-ac2a-d46322696553	13d3c394-ca4a-4198-9490-07bd0176bdbd	00:35:00	0.50	t	\N	\N	\N	0
b278eae0-0531-4a45-944e-d185ee80273b	82ad13b0-44f7-4deb-be40-11a578cb0a56	09:57:00	4.00	t	\N	\N	\N	0
ba189325-69d8-4b59-8c5c-4be8486d378a	82ad13b0-44f7-4deb-be40-11a578cb0a56	13:37:00	1.00	t	\N	\N	\N	0
afc62919-9dfc-4f8d-9c8a-e57ee76ee2bb	82ad13b0-44f7-4deb-be40-11a578cb0a56	14:01:00	1.00	t	\N	\N	\N	0
1d852b88-8a5d-4ae8-bc16-e0cd7d335eff	7c6ddb01-5cd5-4f80-abc9-fbab2f706521	08:00:00	345.00	t	\N	\N	\N	0
462a249e-bcbc-40af-8448-49ee2828f8c9	7c6ddb01-5cd5-4f80-abc9-fbab2f706521	13:00:00	345.00	t	\N	\N	\N	0
a5c1078e-bb28-44ad-b50c-faa5195163f6	7c6ddb01-5cd5-4f80-abc9-fbab2f706521	18:00:00	345.00	t	\N	\N	\N	0
\.


--
-- Data for Name: feeding_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.feeding_logs (id, pond_id, schedule_id, feed_amount, status, fed_at) FROM stdin;
\.


--
-- Data for Name: fish_species; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fish_species (id, name_en, name_km, aliases, growth_stages, default_initial_weight, environment) FROM stdin;
\.


--
-- Data for Name: fishcap_typeorm_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fishcap_typeorm_migrations (id, "timestamp", name) FROM stdin;
1	1747400002000	AddProfileImagePublicIdToUser1747400002000
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.migrations (id, name, executed_at) FROM stdin;
1	AddDeviceLifecycleAndPondSensor1747400000000	2026-09-16 15:44:31.792165+00
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, title, message, is_read, created_at) FROM stdin;
e9fe30f3-f812-4245-bcdc-c89514f46bd5	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.004 kg. Refill the hopper soon.	t	2026-09-07 09:05:21.735974
2fb1dd31-60e2-4196-9fef-7e2748b2b114	377f04c6-82dd-4af1-8184-51c48d7a5451	Water temperature alert	fishcap_001 water temperature is too high (38.5 °C). Safe range: 20-35 °C.	t	2026-09-07 09:05:21.81081
190c966e-5b22-41da-a8ff-5e773f55854f	377f04c6-82dd-4af1-8184-51c48d7a5451	Water temperature alert	fishcap_001 water temperature is too low (2.4 °C). Safe range: 20-35 °C.	t	2026-09-07 09:39:38.568985
c5f005b3-eb79-4457-9297-fcc9b588c01f	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.013 kg. Refill the hopper soon.	t	2026-09-08 02:50:39.640948
4ee2acac-59ac-416f-acfd-6f7c6c38287c	377f04c6-82dd-4af1-8184-51c48d7a5451	Water pH alert	fishcap_001 water pH is too low (4.50). Safe range: 6-9.	t	2026-09-08 04:29:43.072609
222934f3-df9c-41ac-8bba-6c23ab61c140	377f04c6-82dd-4af1-8184-51c48d7a5451	Dissolved oxygen alert	fishcap_001 dissolved oxygen is low (2.0 mg/L). Safe minimum: 3 mg/L — check aeration.	t	2026-09-08 04:29:43.087644
0e6c270f-2f6f-4386-8107-0e56f23afab3	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.002 kg. Refill the hopper soon.	t	2026-09-08 07:38:52.289909
82832b6b-4f3b-4421-bfc8-3056bf462040	377f04c6-82dd-4af1-8184-51c48d7a5451	Water pH alert	fishcap_002 water pH is too high (9.82). Safe range: 6-9.	t	2026-09-16 07:55:41.379811
06f50537-34aa-46c3-b4df-612656c46ab7	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.001 kg. Refill the hopper soon.	t	2026-09-16 10:04:57.950743
e5ed46ad-5174-4033-acff-10f517e3ebd9	377f04c6-82dd-4af1-8184-51c48d7a5451	Water TDS alert	fishcap_002 water TDS is too high (729.2 ppm). Safe range: 100-500 ppm.	f	2026-09-17 03:12:41.349807
2887e085-d860-4fbe-8532-0bb6a8c9b353	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.001 kg. Refill the hopper soon.	f	2026-09-17 02:40:25.89263
51c26c18-926f-4ae6-99c0-f58ad1feb9a3	377f04c6-82dd-4af1-8184-51c48d7a5451	Water TDS alert	fishcap_002 water TDS is too high (728.9 ppm). Safe range: 100-500 ppm.	f	2026-09-17 03:09:38.414504
77d99734-03a1-4d92-81aa-c222d1c0b1d9	377f04c6-82dd-4af1-8184-51c48d7a5451	Water temperature alert	fishcap_001 water temperature is too low (19.3 °C). Safe range: 20-35 °C.	t	2026-09-08 10:04:59.036871
0119a5c9-2d05-4770-b14e-321aeaf276b4	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-09 03:22:38.692581
c4b2a00a-2d22-4456-9d08-99791bc554d4	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 05:09:46.737558
ff8b63b2-3048-41b7-abf5-33c8acb1d5d5	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:17:03.957062
38412b2d-ef1b-4f65-9f74-e49a694a0750	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:18:08.052152
96a27f09-606e-46c1-a64a-2e2e9e9b7c7a	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:19:12.371549
25b91f5c-1154-4512-bb66-044e146c35fc	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:20:16.168011
1d6a0072-fb8d-4a6c-9ffd-5bcb632c788d	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:21:19.569739
8fe25a4f-7278-48ae-ae8c-11ad7c445850	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:22:24.477287
cb28f2a6-1464-46dc-a13d-47ed272ce631	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:23:27.768356
66fb2702-186a-4b80-891b-581cae601a8e	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:24:31.854348
33a4c13b-52d1-4c26-a3de-95a431aaf750	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:25:36.607002
d7c13282-422d-4a8e-8afc-255c98389d7d	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:26:40.688508
fafb236e-dce0-4bc3-a81f-27fe1589f1dd	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:27:44.172113
44a43ae8-5c52-4675-b316-7e1517f0e032	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:28:48.06388
2f72b301-ca61-4dd6-a245-d6f198aaf4eb	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:29:52.17519
212e7dc7-13c3-4e43-8bff-f9bf99ca146e	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:30:56.688953
15cbc350-c593-47a6-b5a6-5cf0bc03b9f0	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:32:00.776926
2a773870-cdef-4292-83c5-ff8df2b0e45c	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:33:04.680474
bad59a2e-968f-43fd-89ec-44eea31224a5	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:34:08.986901
59fe6ed3-2c38-4420-9bc7-f4e8bfd6a3ba	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:35:13.513464
443ec7d3-79f2-4931-ac4e-65a847410376	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:36:17.392667
605f5ad9-b1e9-48ba-a565-937c2bc69ad8	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:37:21.910794
32eadb38-bf6d-46e1-862b-3d290a26c5a0	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:38:25.804508
dd571061-9d32-471d-8a25-f81810232f0e	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:39:29.651857
0f9fbcaf-9773-4b49-8ab5-6014a716c2fd	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:40:33.390065
d9b8304e-c7b2-45f1-8fc4-559af31f1222	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:41:38.10022
d406a1b8-9ba6-40b7-a5f1-08e3e146fd22	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:42:41.365282
66decbd4-957d-4865-aad5-6d549e0ec857	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:43:45.920345
6d52dc47-8841-4202-9b70-745b5e3694fb	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:44:50.419373
27c238d4-a806-4008-af27-c7e77554c3eb	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:45:53.509961
b0479a36-d08a-49fa-a5aa-66968176172d	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:46:58.419895
aed34db5-c02a-48c8-bebc-22205c228cdb	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:48:01.604271
959d6b02-68dc-4f7b-83cb-8ca36a680877	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:49:06.61152
f5c71713-ed8b-4d27-a9a9-4f1f5f6be989	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:50:09.901966
e1e57c42-b2f0-4a11-bf73-29e81f528998	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:51:14.031579
8d280e0c-78e3-490b-9f2f-82180cd7b99d	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:52:18.93693
046b17ec-7c49-46bc-95d9-3168501380ff	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:53:23.037873
38d5d25a-394e-4aa6-9449-7e58c9d7a860	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:54:26.554604
48dd04da-01b3-4b6c-8878-63e7c0252ee7	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:55:30.71713
c23cc524-02e8-44ca-8e9b-1048a6f2f64c	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:56:35.737819
0e21e1d5-051d-442e-942e-29251c18f313	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:57:39.840918
d5cf5994-9695-479c-a99c-a536cca70c36	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:58:43.961786
23c73702-2153-429d-b0d2-4e7545550de3	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 06:59:47.460499
c622aadd-6818-4bfe-afd0-4582055b8f96	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:00:51.145832
26fb1b33-3f9a-4e23-b0a4-78b1f9111197	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:01:55.930577
611f0a40-a716-49b3-8ec7-7d523c1ab2ff	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:02:59.926188
5a2b4bd3-a6fd-436b-9e10-0b5c331eae98	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:04:03.448169
16ea8c0e-02f5-4ebd-b302-8e0db4c1e4e3	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:05:08.566237
47809821-963b-4d4d-bd39-73a5eeb7817d	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:06:12.272005
75a4d9cd-09c5-4d17-8157-5759b840fa8b	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:07:16.579309
5da00853-ec57-427a-9006-82680e62edd2	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:08:20.884889
0d74de52-8f9e-4da1-9890-eb0fd3b4fda3	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:09:24.188947
31ae6d8b-d66a-481e-a7df-d3564d7670c7	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:10:29.292183
959572cf-4503-4c87-9573-4aaa8ce2b736	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:11:32.668257
21c10e72-5be4-4c59-9193-7e7243cc0c60	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:12:37.688197
10c501c3-8d8b-48bd-a7dd-e59798a51f56	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:13:42.008536
847ddf38-f846-43ab-80be-0aa5c4e4da95	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:14:45.30246
513a9b38-6d8d-4e11-bc7f-95ea878cb442	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:15:50.014997
26d10561-2462-469e-9e41-b7e4903f2b01	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:16:53.965486
980d5ae1-9d5c-4a04-bcfb-5c4012e1264b	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:17:57.60458
dec7893c-841e-4827-9b8f-c0018ee57c6e	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:19:01.495805
e5bec219-6fd5-4c24-87b5-638767fd206f	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:20:06.40679
a33afdee-8165-425d-a3a6-88153a766e69	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:21:09.121615
61a24662-a8b6-4731-84f7-e9b896d191cc	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:22:13.128845
f6e8f983-705a-40f4-a151-765175b41803	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:23:18.114965
1db431ab-b537-4697-91c7-1c40fb6a4146	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:24:21.193082
f4b82dc4-6de4-42db-a266-ae297a93aed0	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:25:26.116402
143001dd-126e-4873-8b01-76a8cac123b0	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:26:30.419813
46b3d085-1e07-4a16-8d4b-a9b31c4c4acf	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:27:33.905468
338a0928-d016-4d09-be21-1274d2691975	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:28:38.41225
1cca2182-0c23-4a21-bd9a-93ce0e55645d	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:29:42.192001
85bdf435-0093-4190-aeba-66e624832a55	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:30:46.639377
34c554a5-02b1-4a25-a245-b94c82b1866a	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:31:50.93567
7c6aa6c8-490b-4d46-b7f9-16e52224330b	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:32:55.453873
a431576e-0481-49e4-b694-f8abafb98f7f	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:33:59.757
eaa38dbf-8614-4d1f-8e85-5d251f88379f	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:35:03.067656
422f1aef-cdfc-4eda-9d32-7702fd904efa	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:36:07.744067
1ee6aabf-d200-4756-ae1c-83da606b2e20	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:37:11.043163
f62b8e8b-a2c3-41cb-9689-22451c7b2405	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:38:15.116463
b63f938c-2bd3-4e5f-bd5f-fa91a889e411	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:39:20.068588
74182c5e-270a-4d2e-b79c-73cd39b58cac	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:40:24.370965
c1456dbe-f434-4ece-bdb8-cb1c4d1f840e	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:41:30.112897
27aef333-1e99-4f04-9d7f-9248e5b33e69	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:42:33.382955
789a50a4-574e-43a0-bf48-2dfe917033a4	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:43:38.511415
6124b038-867e-455f-a77d-3c3adb8f4ac6	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:44:42.840866
4dd301fa-f3b0-4aea-9c65-e655f9f4d067	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:45:46.526988
7ea1bdb0-4ed2-4d79-96d8-10d499c251bb	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:46:51.245712
04def680-bf89-43a5-b660-a9d403406e5d	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:47:55.349062
ded4bf0b-87ce-4f22-aa99-227982eb96b2	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:48:59.070057
7a153da3-8c19-43e2-9fac-d518e7a8dd14	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:50:02.934181
f4a3a841-dae4-405f-bd29-6311e6f3119f	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:51:07.640601
4c9b8c7e-a67d-4fe2-9f85-d22cfe3c9c7a	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:52:10.624117
56b237bf-4306-40d5-bbd9-ca56bf281434	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:53:14.736764
cb4411a8-37a5-4e97-908e-d5dd3dac0835	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:54:19.204824
aa413f2e-c985-4556-8673-3b003139c323	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:55:23.032544
3936bbce-2af0-4c68-a3fe-5f2170dd3862	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:56:27.752945
0aacc30b-fbf3-462a-8c21-effb3dd6c319	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:57:31.436071
dbbd0393-92d4-47b6-ab6e-4bfe3fb0be20	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:58:36.350919
f0eecd82-2bfc-4c48-b7f5-c8ff772a5c32	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 07:59:40.048912
f43fdeee-9359-4ed9-b0eb-4c87f2e76266	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:00:43.762539
e550cff8-e847-4115-9d5e-84c0f918eb96	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:01:47.546301
b7c8d877-ed6a-4aef-a145-d1bf92e4a99b	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:02:51.969557
61dffc2b-60e4-44b7-92d4-b1ac879117b2	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:03:55.619631
91a557d5-5c54-4aeb-b83c-fa59af15a486	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:05:00.453661
87b94a92-bac7-4049-b6eb-b73917e0bcdf	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:06:04.458615
847e3856-9bb6-465d-9c75-a87768dde8b0	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:07:07.756025
155dbca7-7852-4db9-9ae5-1efe0949c4b2	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:08:11.720789
96990909-48c5-4050-961a-a42dfb368681	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:09:15.70162
949d729e-7822-479d-b063-21941c1b288b	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:10:19.692227
c815dcef-5dff-45e0-af5d-335290f2a2b9	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:11:24.582323
c873024d-95a4-4da7-a833-fab5edf74d3c	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:12:28.278715
42dd803a-be01-41df-a0d6-727e55afac0d	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:13:32.765738
e349dcfe-3e02-4703-9fae-6c3721fed5ea	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:14:37.084124
19828dd0-82f5-47e0-9aed-de578fc80ca5	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:15:40.690362
f47fd332-7ce1-483d-b3b9-a7a3af79edae	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:16:45.130177
18a3bba9-7a5c-43a2-9791-f4226ff605e5	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:17:48.646105
a519d8d7-65c4-474d-84d7-02d78abf7c08	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:18:53.276991
5b18eec0-2137-4b36-b233-4fc0daa0107f	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:19:56.987134
91c38341-4f2d-4ac0-8c5b-be52e3fad777	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:21:00.774396
4142d457-ec50-43fa-beee-67741bf79cb8	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:22:05.808554
6dea989f-d05f-4dd7-b060-76a53df37ad0	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:23:08.722914
acd7061f-7d0e-409b-973c-dfcee9421041	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:24:12.790207
d6e9ebef-1908-4d0d-9b7e-034b831bbd8e	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:25:17.496074
f19d8c14-092c-4f53-8cf1-89f6a23c5986	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:26:21.205459
001f6178-42fa-4448-a0c1-264baa8a530a	377f04c6-82dd-4af1-8184-51c48d7a5451	Feed dispensed	fishcap_001 finished feeding and dispensed 0.000 kg.	t	2026-09-09 08:27:25.702349
e7be3444-f09b-443b-b907-7422375851da	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-09 09:23:17.092716
aeed8261-354e-4611-8b7a-de5d947e1359	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.003 kg. Refill the hopper soon.	t	2026-09-10 14:25:17.682154
8726d408-bb25-4794-880f-e1068a922c13	377f04c6-82dd-4af1-8184-51c48d7a5451	Water pH alert	fishcap_001 water pH is too high (11.41). Safe range: 6-9.	t	2026-09-10 14:25:17.696009
df246af6-ad72-4f6e-9205-2c9ee5efa659	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.004 kg. Refill the hopper soon.	t	2026-09-13 08:23:11.387903
557f70c2-98f5-4ad4-89ee-2764bc20e4e1	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-13 15:22:06.707632
05154794-60d8-43f8-9ab0-1a943f427125	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-13 15:26:12.484668
99e7cfbb-f384-45c1-8429-f063d6468a72	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-13 15:28:15.80579
7ddd5149-1c17-4bcb-8e6c-b0427cf5cb69	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_001 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-14 03:06:39.090631
95180969-8e09-474e-84cc-494b406083a4	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.002 kg. Refill the hopper soon.	t	2026-09-14 09:23:38.355582
4b8867fb-e3f9-4c1c-86da-c6b1f2c4e9c8	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.006 kg. Refill the hopper soon.	t	2026-09-15 06:28:30.195979
0c2fbfaa-1068-4302-9a49-f28e7414e6a2	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-15 07:13:35.231474
06abba45-a0fb-415d-b417-f3c5aa8202e5	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-15 07:25:13.929579
dee5d564-049a-42c0-9d1a-1d58d5d9b1d6	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-15 07:29:43.337606
c0fa4f49-7b34-48ab-b106-37ca4e8f36ea	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.005 kg. Refill the hopper soon.	t	2026-09-15 09:49:11.91162
2238a32a-e211-4ca3-aaae-49f66718da68	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.007 kg. Refill the hopper soon.	t	2026-09-15 15:49:39.405489
5d6d79fa-092c-4875-8b5b-a195ae43302f	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.000 kg. Refill the hopper soon.	t	2026-09-16 02:48:46.52199
51ca32ba-992c-4108-a750-1e532134d442	377f04c6-82dd-4af1-8184-51c48d7a5451	Low feed stock	fishcap_002 remaining feed is 0.000 kg. Refill the hopper soon.	f	2026-09-17 02:21:44.340049
90548720-5bdc-4021-97bd-88153275a781	377f04c6-82dd-4af1-8184-51c48d7a5451	Water TDS alert	fishcap_002 water TDS is too high (663.7 ppm). Safe range: 100-500 ppm.	f	2026-09-17 02:21:44.354815
2a674cfd-8775-4bfc-b690-054496f2ded8	377f04c6-82dd-4af1-8184-51c48d7a5451	Water pH alert	fishcap_002 water pH is too high (10.26). Safe range: 6-9.	f	2026-09-17 02:22:49.055737
\.


--
-- Data for Name: otps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.otps (id, email, code, expires_at, used, created_at) FROM stdin;
c76090ab-32e9-4d60-b598-fbf130865bd7	engdalline43@gmail.com	408727	2026-09-08 02:46:48.241	t	2026-09-08 02:41:48.253695
b782acda-86f6-493e-a0a4-17fa2a032616	test@test.com	490945	2026-09-18 02:18:11.003	f	2026-09-18 02:13:11.016863
9790ddbd-013e-4fca-874b-eb5f1d6ca8bb	test@example.com	397318	2026-09-18 04:08:02.956	f	2026-09-18 04:03:02.968759
878e6082-e9de-4a3d-8431-df313fa5c806	nita@gmail.com	642091	2026-09-18 04:49:50.094	f	2026-09-18 04:44:50.094742
f7b8f4a5-a3f8-439f-9f21-615db43aad74	daline@gmail.com	754654	2026-09-19 11:01:16.333	f	2026-09-19 10:56:16.346216
\.


--
-- Data for Name: ponds; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ponds (id, user_id, pond_name, location, fish_type, fish_count, start_date, end_date, feeding_times, amount, hardware_id, status, status_color, has_alert, temperature, created_at, updated_at) FROM stdin;
1f4d1d55-6837-463e-ab5a-0461aeed917f	677e34c7-f579-4452-a892-7b46eb21177d	Demo Pond	\N	Tilapia	50	\N	\N	\N	\N	\N	active	\N	f	\N	2026-08-25 08:39:28.161467	2026-08-25 08:39:28.161467
ddbc148f-41c8-4143-9044-766c7ca5808b	377f04c6-82dd-4af1-8184-51c48d7a5451	fds	fds	dda	6000	2026-08-26	2026-08-26	\N	8.00	gfdsfg-98-gf	done	\N	f	\N	2026-08-26 06:53:03.40089	2026-08-26 08:31:09.127537
63c5b6d7-a408-4240-99fc-8dd2fef8d84c	677e34c7-f579-4452-a892-7b46eb21177d	CurlTest	\N	Tilapia	5	\N	\N	\N	\N	\N	active	\N	f	\N	2026-08-27 01:59:39.40372	2026-08-27 01:59:39.40372
a83b692e-78e4-43e7-bb9e-1647be326466	677e34c7-f579-4452-a892-7b46eb21177d	CurlTest	\N	Tilapia	5	\N	\N	\N	\N	\N	active	\N	f	\N	2026-08-27 02:00:08.656742	2026-08-27 02:00:08.656742
e744c555-23ec-40e7-9ad0-0f6f52e4f63a	377f04c6-82dd-4af1-8184-51c48d7a5451	testpron	testpron	tilapia	2000	2026-09-04	2026-12-31	["08:53"]	3.00	fishcap-002	done	\N	f	\N	2026-09-04 01:54:19.50894	2026-09-12 14:41:03.201782
4408c859-fa79-42d6-bcaa-53443d155d95	377f04c6-82dd-4af1-8184-51c48d7a5451	new prons	new prons	tilapia	2000	2026-08-27	2026-10-31	["15:00", "14:42"]	1.00	fishcap_001	done	\N	f	\N	2026-08-27 02:28:19.477131	2026-09-12 15:06:12.539102
13d3c394-ca4a-4198-9490-07bd0176bdbd	377f04c6-82dd-4af1-8184-51c48d7a5451	lepron	lepron	ត្រីប្រា	6000	2026-09-14	2026-11-30	["14:32", "00:35"]	2.00	fishcap_002	active	\N	f	\N	2026-09-14 06:42:18.4269	2026-09-17 05:01:30.959196
82ad13b0-44f7-4deb-be40-11a578cb0a56	377f04c6-82dd-4af1-8184-51c48d7a5451	nitapron	nitapron	ត្រីរស	2500	2026-09-14	2026-11-30	["09:57", "13:37", "14:01"]	6.00	fishcap_001	active	\N	f	\N	2026-09-14 02:58:03.629716	2026-09-17 07:01:42.818339
cf6219ad-8194-47c9-b5e5-65be1c02867a	377f04c6-82dd-4af1-8184-51c48d7a5451	hie	hie	tiliap	1000	2026-08-25	2026-10-30	["15:52"]	0.50	fishcap_001	done	\N	f	\N	2026-08-25 09:09:22.67206	2026-09-13 09:55:42.378202
8cfc0282-bd75-4f2b-8421-4e444ee54fb0	377f04c6-82dd-4af1-8184-51c48d7a5451	fdtw	fdtw	fdeer	20000	2026-08-26	2026-08-26	\N	6.00	fjdkjj-09-dj	done	\N	f	\N	2026-08-26 04:49:57.529869	2026-08-28 01:44:39.437734
efa43877-1fd7-4ee5-b4e9-da97faea07f3	377f04c6-82dd-4af1-8184-51c48d7a5451	the south of pron	the south of pron	tilapia	1000	2026-08-26	2026-08-26	["08:42"]	4.00	dfeiie-97	done	\N	f	\N	2026-08-26 04:59:33.652793	2026-08-31 06:59:48.907345
7c6ddb01-5cd5-4f80-abc9-fbab2f706521	377f04c6-82dd-4af1-8184-51c48d7a5451	ខាងជើង	ខាងជើង	ត្រីរស	46000	2026-09-17	2026-11-30	["08:00", "13:00", "18:00"]	1035.00	fishcap_005	active	\N	f	\N	2026-09-17 03:07:43.319001	2026-09-17 08:17:31.07762
00347294-5086-4268-800f-5e6230e4867b	c61a2b49-5c5e-435e-be45-5fc39c090335	ខាងត្បូង	ខាងត្បូង	ត្រី	10000	2026-09-01	2026-11-30	["09:09"]	8.00	FEEDER-1534-AX	active	\N	f	\N	2026-09-01 02:09:32.016488	2026-09-18 04:07:45.932591
268213b7-1ffe-44a1-a862-9c9fca9ba3ec	377f04c6-82dd-4af1-8184-51c48d7a5451	testing	testing	tilupia	2000	2026-09-04	2026-11-28	["09:31", "10:22"]	13.00	fishcap-003	done	\N	f	\N	2026-09-04 02:31:48.337448	2026-09-04 03:22:55.621059
ec52ffd8-0d14-4277-a73e-a4803a8b7c6d	377f04c6-82dd-4af1-8184-51c48d7a5451	ខាងជើង	ខាងជើង	ត្រីប្រា	50000	2026-09-19	2026-11-30	["08:00", "13:00", "18:00"]	375.00	fishcap_008	done	\N	f	\N	2026-09-19 10:51:09.438538	2026-10-28 05:45:31.482895
a1852c20-c0ff-4175-92fe-2bdde538d976	377f04c6-82dd-4af1-8184-51c48d7a5451	hiny	hiny	tilipai	30000	2026-10-01	2027-01-30	["08:00", "13:00", "18:00"]	225.00	\N	active	\N	f	\N	2026-11-01 08:42:29.726949	2026-11-01 08:42:29.726949
edf20d9e-95f4-4df1-89da-3178dd43bbee	377f04c6-82dd-4af1-8184-51c48d7a5451	ERpron	ERpron	tilapia	5000	2026-09-13	2027-01-31	["09:55"]	1.00	fishcap_002	done	\N	f	\N	2026-09-13 09:57:37.66753	2026-09-14 06:31:20.600418
b4837108-e174-48cd-9aba-b2444bd88dc5	377f04c6-82dd-4af1-8184-51c48d7a5451	nore	nore	tilapia	3000	2026-09-15	2026-11-30	["08:00", "13:00", "18:00"]	22.50	fishcap_003	active	\N	f	\N	2026-09-15 06:17:07.302999	2026-09-15 06:17:07.302999
3c77d537-971b-421d-9ec5-284102f380ed	377f04c6-82dd-4af1-8184-51c48d7a5451	ស្រះខាងត្បូង	ស្រះខាងត្បូង	ត្រីប្រា	45000	2026-09-17	2026-11-30	["08:00", "18:00"]	675.00	fishcap_004	active	\N	f	\N	2026-09-17 02:39:18.599685	2026-09-17 02:39:54.661743
\.


--
-- Data for Name: sensor_data; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sensor_data (id, device_id, temperature, ph, dissolved_oxygen, created_at, weight_grams, feeding, feed_grams_dispensed, remaining_stock_grams, low_stock, tds, pond_id) FROM stdin;
c88c8669-6d30-419a-913e-cc65f2efba9d	fishcap_002	23.81	8.62	\N	2026-09-17 02:21:44.285807	0.00	f	0.00	0.00	t	663.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
5b19c0c8-3708-467a-ae30-9294e69ad549	fishcap_002	25.50	9.03	\N	2026-09-17 02:29:59.386792	0.00	f	0.00	0.00	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
a46eaf44-bd0e-4536-9ed6-2fe3f5d74619	fishcap_002	25.19	8.76	\N	2026-09-17 02:51:17.335869	99.24	f	0.00	99.24	t	223.54	13d3c394-ca4a-4198-9490-07bd0176bdbd
36b3e81f-a941-44e5-9b8c-dd9a7d34b617	fishcap_002	24.69	8.67	\N	2026-09-17 03:12:41.2785	0.00	f	0.00	0.00	t	729.17	13d3c394-ca4a-4198-9490-07bd0176bdbd
1db53426-312f-44de-8c76-16e1bb9a126d	fishcap_002	24.88	8.61	\N	2026-09-17 03:37:13.78401	0.00	f	0.00	0.00	t	739.43	13d3c394-ca4a-4198-9490-07bd0176bdbd
8cdc1d4d-df36-401d-b566-5727f52e4463	fishcap_002	24.50	8.55	\N	2026-09-17 04:03:30.352527	0.00	f	0.00	0.00	t	217.26	13d3c394-ca4a-4198-9490-07bd0176bdbd
cc2b0030-91f3-4956-a042-e58bbc37eaaf	fishcap_002	24.69	8.55	\N	2026-09-17 04:25:00.908844	92.83	f	0.00	92.83	t	218.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
1a8a4c20-0f72-4699-aa0f-d3f0c61e143c	fishcap_002	24.50	8.52	\N	2026-09-17 04:53:10.971697	0.00	f	0.00	0.00	t	218.59	13d3c394-ca4a-4198-9490-07bd0176bdbd
d688b933-f06c-40cd-88f3-0c64579ad2c5	fishcap_002	24.13	10.26	\N	2026-09-17 02:22:49.028749	0.00	f	0.00	0.00	t	672.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
c419598d-ec13-43eb-9074-3d0e76b00577	fishcap_002	25.44	8.99	\N	2026-09-17 02:30:59.299906	0.00	f	0.00	0.00	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
6d7ddb7e-3c3a-44b0-a195-e0237e167499	fishcap_002	25.19	8.77	\N	2026-09-17 02:52:17.212341	98.89	f	0.00	98.89	t	220.63	13d3c394-ca4a-4198-9490-07bd0176bdbd
c5ed0554-746d-4064-9c10-4074099e2dfa	fishcap_002	24.69	8.65	\N	2026-09-17 03:13:43.70743	0.00	f	0.00	0.00	t	731.57	13d3c394-ca4a-4198-9490-07bd0176bdbd
90903350-9a5d-4df3-ab9f-2da656cbbb10	fishcap_002	24.88	8.63	\N	2026-09-17 03:38:13.954702	0.00	f	0.00	0.00	t	168.76	13d3c394-ca4a-4198-9490-07bd0176bdbd
c870b1e0-096f-4d8b-a900-6345a857cde3	fishcap_002	24.56	8.54	\N	2026-09-17 04:04:30.358725	0.00	f	0.00	0.00	t	217.22	13d3c394-ca4a-4198-9490-07bd0176bdbd
b51216fd-d581-401a-931f-8a841502bcd8	fishcap_002	24.69	8.54	\N	2026-09-17 04:26:00.931345	93.00	f	0.00	93.00	t	218.95	13d3c394-ca4a-4198-9490-07bd0176bdbd
d0cd5f6f-05a0-4642-965e-799db248e499	fishcap_002	24.50	8.51	\N	2026-09-17 04:54:11.099703	0.00	f	0.00	0.00	t	218.63	13d3c394-ca4a-4198-9490-07bd0176bdbd
e02888fe-5bea-4c98-81a9-5e12956a8c51	fishcap_002	24.25	9.42	\N	2026-09-17 02:23:49.072498	0.00	f	0.00	0.00	t	675.10	13d3c394-ca4a-4198-9490-07bd0176bdbd
420eab1d-e4c1-4c23-9f99-a8c2759ebc78	fishcap_002	25.44	8.95	\N	2026-09-17 02:32:05.237137	0.00	f	0.00	0.00	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
cc566d27-a3eb-45ef-9185-1910278f80b9	fishcap_002	25.19	8.75	\N	2026-09-17 02:53:17.8598	99.17	f	0.00	99.17	t	218.94	13d3c394-ca4a-4198-9490-07bd0176bdbd
dddc653c-5f35-442f-940d-db36063986a8	fishcap_002	24.75	8.64	\N	2026-09-17 03:15:37.959131	0.00	f	0.00	0.00	t	733.23	13d3c394-ca4a-4198-9490-07bd0176bdbd
2dc6a955-a5dd-4f6c-8fc6-afcdb272fa38	fishcap_002	24.75	8.68	\N	2026-09-17 03:15:46.199262	0.00	f	0.00	0.00	t	729.87	13d3c394-ca4a-4198-9490-07bd0176bdbd
771c02a7-630b-4e46-a4e0-09866149c15f	fishcap_002	24.44	8.59	\N	2026-09-17 03:39:18.178758	0.00	f	0.00	0.00	t	225.42	13d3c394-ca4a-4198-9490-07bd0176bdbd
cb0881b3-a206-4c5b-9413-59cfd8cd2dbf	fishcap_002	24.63	8.56	\N	2026-09-17 04:05:35.578382	0.00	f	0.00	0.00	t	218.50	13d3c394-ca4a-4198-9490-07bd0176bdbd
2c8afe08-e938-47fa-95e3-9d69dd3ab755	fishcap_002	24.63	8.54	\N	2026-09-17 04:27:00.919431	94.64	f	0.00	94.64	t	219.61	13d3c394-ca4a-4198-9490-07bd0176bdbd
211d6b14-a39e-488a-ad94-d650de790c67	fishcap_002	24.50	8.49	\N	2026-09-17 04:55:11.067371	0.00	f	0.00	0.00	t	219.49	13d3c394-ca4a-4198-9490-07bd0176bdbd
024fe921-f13a-4e9e-b396-de8d2e0ea8b7	fishcap_002	24.31	9.29	\N	2026-09-17 02:24:49.432631	0.00	f	0.00	0.00	t	678.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
f91e6ad9-af19-4cd8-a091-70e03bbbe105	fishcap_002	25.44	8.94	\N	2026-09-17 02:33:05.243857	102.20	f	0.00	102.20	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
2aba9c13-8eb9-43f9-8f6f-64d362c429cc	fishcap_002	25.19	8.73	\N	2026-09-17 02:54:17.230033	98.96	f	0.00	98.96	t	217.94	13d3c394-ca4a-4198-9490-07bd0176bdbd
8cff8346-c42f-42cd-8305-72b968245b37	fishcap_002	24.69	8.65	\N	2026-09-17 03:18:52.912545	0.00	f	0.00	0.00	t	734.02	13d3c394-ca4a-4198-9490-07bd0176bdbd
9da5fd2b-7ce0-4ded-9215-f2760def2612	fishcap_002	24.56	8.57	\N	2026-09-17 03:45:11.252455	0.00	f	0.00	0.00	t	218.21	13d3c394-ca4a-4198-9490-07bd0176bdbd
ab4531a1-9414-4f43-836c-d9d801fdf223	fishcap_002	24.69	8.54	\N	2026-09-17 04:06:35.922738	0.00	f	0.00	0.00	t	217.94	13d3c394-ca4a-4198-9490-07bd0176bdbd
771955d8-8930-43a7-aa09-ac5aca31920e	fishcap_002	24.63	8.54	\N	2026-09-17 04:28:05.854336	94.13	f	0.00	94.13	t	218.24	13d3c394-ca4a-4198-9490-07bd0176bdbd
ad9714a1-57f3-4bff-a491-befa1e13b12b	fishcap_002	24.50	8.51	\N	2026-09-17 04:56:11.072165	0.00	f	0.00	0.00	t	219.15	13d3c394-ca4a-4198-9490-07bd0176bdbd
6480e0dd-ddd2-4cb3-9610-6116547aab06	fishcap_002	24.44	9.22	\N	2026-09-17 02:25:54.748841	0.00	f	0.00	0.00	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
302eb949-a81a-44c8-a653-3adb5f88ef1f	fishcap_002	25.31	8.92	\N	2026-09-17 02:34:07.382935	101.61	f	0.00	101.61	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
915385a0-f3ee-48cd-92e2-c5deaa461e5a	fishcap_002	25.25	8.72	\N	2026-09-17 02:55:17.837165	98.57	f	0.00	98.57	t	215.90	13d3c394-ca4a-4198-9490-07bd0176bdbd
cb356a64-659f-4201-8142-d3605a5e23de	fishcap_002	24.75	8.64	\N	2026-09-17 03:19:52.645341	0.00	f	0.00	0.00	t	732.46	13d3c394-ca4a-4198-9490-07bd0176bdbd
3c05891b-fb8f-4a3b-a2b0-a52450a16e50	fishcap_002	24.56	8.59	\N	2026-09-17 03:46:12.420924	0.00	f	0.00	0.00	t	218.19	13d3c394-ca4a-4198-9490-07bd0176bdbd
315066a2-98a9-4c97-a700-85ae828e0487	fishcap_002	24.75	8.55	\N	2026-09-17 04:07:35.578078	0.00	f	0.00	0.00	t	218.39	13d3c394-ca4a-4198-9490-07bd0176bdbd
e0449cf5-837e-4c88-aca6-e89ad6de36e9	fishcap_002	24.63	8.54	\N	2026-09-17 04:29:05.845962	94.22	f	0.00	94.22	t	219.73	13d3c394-ca4a-4198-9490-07bd0176bdbd
23d0d182-6cb2-4bd8-b12c-5bc7afed0634	fishcap_002	24.50	8.50	\N	2026-09-17 04:57:11.069168	0.00	f	0.00	0.00	t	219.61	13d3c394-ca4a-4198-9490-07bd0176bdbd
d9713af3-6955-4f0f-b826-a5f37adc5c8e	fishcap_002	25.81	9.15	\N	2026-09-17 02:26:55.366818	0.00	f	0.00	0.00	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
b699246d-8705-4c88-ac0f-c49e2b259c57	fishcap_002	25.25	8.89	\N	2026-09-17 02:35:05.551497	100.52	f	0.00	100.52	t	276.18	13d3c394-ca4a-4198-9490-07bd0176bdbd
3e835653-7723-406e-9b9b-6e375e4ba440	fishcap_002	25.19	8.72	\N	2026-09-17 02:56:17.025553	98.61	f	0.00	98.61	t	215.19	13d3c394-ca4a-4198-9490-07bd0176bdbd
5858e6a1-36ea-4d38-bc3c-2e1791111e87	fishcap_002	24.75	8.63	\N	2026-09-17 03:20:53.137313	0.00	f	0.00	0.00	t	733.44	13d3c394-ca4a-4198-9490-07bd0176bdbd
d4511f43-d35d-4b20-886d-0682b65a5fc7	fishcap_002	24.56	8.60	\N	2026-09-17 03:47:12.431491	0.00	f	0.00	0.00	t	217.17	13d3c394-ca4a-4198-9490-07bd0176bdbd
15fbb7ca-7d43-4516-aa1a-2a5376253912	fishcap_002	24.75	8.56	\N	2026-09-17 04:08:35.595248	0.00	f	0.00	0.00	t	219.07	13d3c394-ca4a-4198-9490-07bd0176bdbd
60ad0b70-1d49-42f1-a65d-040818be45d6	fishcap_002	24.63	8.54	\N	2026-09-17 04:30:06.889433	94.55	f	0.00	94.55	t	219.54	13d3c394-ca4a-4198-9490-07bd0176bdbd
6845cdca-a514-4ff0-9656-0c3e1bb785cf	fishcap_002	24.50	8.49	\N	2026-09-17 04:58:17.264889	0.00	f	0.00	0.00	t	219.39	13d3c394-ca4a-4198-9490-07bd0176bdbd
0ffb0455-a94a-472b-a409-d48dded9e133	fishcap_002	25.19	8.89	\N	2026-09-17 02:36:05.885568	100.67	f	0.00	100.67	t	276.33	13d3c394-ca4a-4198-9490-07bd0176bdbd
229093b8-fc6d-44f0-b1e6-a631118bf900	fishcap_002	25.25	8.69	\N	2026-09-17 02:57:17.045239	98.58	f	0.00	98.58	t	215.18	13d3c394-ca4a-4198-9490-07bd0176bdbd
9bb86002-0366-4f57-81a4-d3aca6e08104	fishcap_002	24.75	8.64	\N	2026-09-17 03:21:53.222467	0.00	f	0.00	0.00	t	731.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
083b7f24-7849-4d3b-b6fa-8dfad5969e6c	fishcap_002	24.56	8.59	\N	2026-09-17 03:48:11.468846	0.00	f	0.00	0.00	t	216.82	13d3c394-ca4a-4198-9490-07bd0176bdbd
c00e5e4e-8a34-4717-9edb-ad8a5f12a5da	fishcap_002	24.75	8.57	\N	2026-09-17 04:09:41.061499	0.00	f	0.00	0.00	t	219.35	13d3c394-ca4a-4198-9490-07bd0176bdbd
b5d9609e-73f9-4809-9979-d9087a018950	fishcap_002	24.63	8.52	\N	2026-09-17 04:31:05.876406	93.56	f	0.00	93.56	t	218.80	13d3c394-ca4a-4198-9490-07bd0176bdbd
e106ca0a-12e1-4362-9cc6-aa7317f2b7ad	fishcap_002	24.56	8.49	\N	2026-09-17 04:59:16.318759	0.00	f	0.00	0.00	t	219.96	13d3c394-ca4a-4198-9490-07bd0176bdbd
8e358b81-c20f-4246-af0f-425900e677ff	fishcap_002	25.19	8.87	\N	2026-09-17 02:37:06.485766	100.50	f	0.00	100.50	t	278.66	13d3c394-ca4a-4198-9490-07bd0176bdbd
8d18b0c8-4405-4f2e-9488-332bd3c5933b	fishcap_002	25.25	8.71	\N	2026-09-17 02:58:22.157137	98.49	f	0.00	98.49	t	216.40	13d3c394-ca4a-4198-9490-07bd0176bdbd
0966568b-6f40-439b-9875-b3007844b56b	fishcap_002	24.81	8.62	\N	2026-09-17 03:22:53.441728	0.00	f	0.00	0.00	t	733.35	13d3c394-ca4a-4198-9490-07bd0176bdbd
46f8864a-a5b4-441a-a433-6475e0a66e0b	fishcap_002	24.50	8.57	\N	2026-09-17 03:49:11.472218	0.00	f	0.00	0.00	t	220.57	13d3c394-ca4a-4198-9490-07bd0176bdbd
cef2afd2-3e46-4b91-a822-6d55feaf17be	fishcap_002	24.75	8.57	\N	2026-09-17 04:10:41.273771	34.31	f	0.00	34.31	t	218.44	13d3c394-ca4a-4198-9490-07bd0176bdbd
5b899aad-88f7-49ab-8d88-87d4350db195	fishcap_002	24.56	8.51	\N	2026-09-17 04:32:11.18223	93.88	f	0.00	93.88	t	218.16	13d3c394-ca4a-4198-9490-07bd0176bdbd
6a388be2-2984-4f6d-af41-54a0120b390b	fishcap_002	24.56	8.51	\N	2026-09-17 05:00:16.310448	0.00	f	0.00	0.00	t	219.27	13d3c394-ca4a-4198-9490-07bd0176bdbd
e89f0d01-2e85-44a0-b517-b286c5195d2f	fishcap_002	25.25	8.84	\N	2026-09-17 02:38:06.491913	100.55	f	0.00	100.55	t	271.92	13d3c394-ca4a-4198-9490-07bd0176bdbd
4a577d26-d259-4284-8682-6aa900081370	fishcap_002	25.25	8.72	\N	2026-09-17 02:59:22.945599	98.62	f	0.00	98.62	t	216.77	13d3c394-ca4a-4198-9490-07bd0176bdbd
27d2dd17-f396-4edb-9a96-5b089e5ad27f	fishcap_002	24.81	8.63	\N	2026-09-17 03:23:53.032078	0.00	f	0.00	0.00	t	733.44	13d3c394-ca4a-4198-9490-07bd0176bdbd
50f9dbc3-404f-440f-b1ce-872a9f764c49	fishcap_002	24.56	8.57	\N	2026-09-17 03:50:11.482191	0.00	f	0.00	0.00	t	217.36	13d3c394-ca4a-4198-9490-07bd0176bdbd
cbfcca26-1c24-41ca-a80b-4deb247a83a6	fishcap_002	24.75	8.55	\N	2026-09-17 04:11:40.569069	94.63	f	0.00	94.63	t	218.20	13d3c394-ca4a-4198-9490-07bd0176bdbd
db526b9a-0fdb-4258-b08f-803cac269a40	fishcap_002	24.63	8.52	\N	2026-09-17 04:33:11.15522	94.30	f	0.00	94.30	t	219.25	13d3c394-ca4a-4198-9490-07bd0176bdbd
3bb18965-53cd-4954-8da3-54a218ffa3bb	fishcap_002	24.56	8.52	\N	2026-09-17 05:01:16.311156	0.00	f	0.00	0.00	t	220.43	13d3c394-ca4a-4198-9490-07bd0176bdbd
8857f041-d404-411f-9cd0-a28bea007000	fishcap_002	25.31	8.85	\N	2026-09-17 02:39:06.502222	101.17	f	0.00	101.17	t	263.05	13d3c394-ca4a-4198-9490-07bd0176bdbd
ac1a953a-a959-49ad-ad76-8a0065ae7a45	fishcap_002	25.25	8.67	\N	2026-09-17 03:00:22.570484	98.96	f	0.00	98.96	t	215.46	13d3c394-ca4a-4198-9490-07bd0176bdbd
2eec1784-63c2-4617-a9fd-1c9e423fed8c	fishcap_002	24.81	8.63	\N	2026-09-17 03:24:58.165688	0.00	f	0.00	0.00	t	735.03	13d3c394-ca4a-4198-9490-07bd0176bdbd
463e1457-b917-4241-9dcd-59e5c507105c	fishcap_002	24.56	8.57	\N	2026-09-17 03:51:17.375878	0.00	f	0.00	0.00	t	216.98	13d3c394-ca4a-4198-9490-07bd0176bdbd
25b34959-1e97-466b-9f89-7b0b8fc62456	fishcap_002	24.75	8.54	\N	2026-09-17 04:12:46.006111	94.67	f	0.00	94.67	t	218.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
9b56abb5-a011-49da-a0ba-e25051ea148a	fishcap_002	24.56	8.55	\N	2026-09-17 04:34:11.163843	95.00	f	0.00	95.00	t	218.63	13d3c394-ca4a-4198-9490-07bd0176bdbd
9cbdf107-0cb0-451e-8c7c-54c83b76801b	fishcap_002	24.56	8.52	\N	2026-09-17 05:02:21.555251	0.00	f	0.00	0.00	t	220.24	13d3c394-ca4a-4198-9490-07bd0176bdbd
7f278065-dbf9-4672-ac61-6310f096af86	fishcap_002	25.31	8.83	\N	2026-09-17 02:40:06.494962	101.33	f	0.00	101.33	t	261.78	13d3c394-ca4a-4198-9490-07bd0176bdbd
b27410ff-d68a-4e55-844d-0f073341c910	fishcap_002	25.25	8.71	\N	2026-09-17 03:01:23.189845	98.62	f	0.00	98.62	t	215.94	13d3c394-ca4a-4198-9490-07bd0176bdbd
574c9cf9-a2fc-428c-8370-d8bb35108245	fishcap_002	24.94	8.64	\N	2026-09-17 03:25:57.827876	0.00	f	0.00	0.00	t	737.16	13d3c394-ca4a-4198-9490-07bd0176bdbd
67fa8806-1038-49ec-9c9e-07dc149e8214	fishcap_002	24.50	8.57	\N	2026-09-17 03:52:16.773209	0.00	f	0.00	0.00	t	217.54	13d3c394-ca4a-4198-9490-07bd0176bdbd
f78e5e57-afbe-4b68-ad13-069d2beea917	fishcap_002	24.75	8.55	\N	2026-09-17 04:13:46.616009	94.57	f	0.00	94.57	t	218.23	13d3c394-ca4a-4198-9490-07bd0176bdbd
6ff4fbfe-56dd-4701-9a21-830e319b02ec	fishcap_002	24.63	8.51	\N	2026-09-17 04:35:18.338057	94.86	f	0.00	94.86	t	218.99	13d3c394-ca4a-4198-9490-07bd0176bdbd
887d9de2-8f97-4515-b105-b0e198412b16	fishcap_002	24.56	8.51	\N	2026-09-17 05:03:21.564943	0.00	f	0.00	0.00	t	219.53	13d3c394-ca4a-4198-9490-07bd0176bdbd
476cd619-3277-4dfa-859b-c2e2b4d7556f	fishcap_002	25.31	8.83	\N	2026-09-17 02:41:06.315642	100.42	f	0.00	100.42	t	259.62	13d3c394-ca4a-4198-9490-07bd0176bdbd
988f4a78-a2cd-43cd-be4d-228d6fc25384	fishcap_002	25.31	8.71	\N	2026-09-17 03:02:22.197566	97.70	f	0.00	97.70	t	218.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
62b52b4b-e522-450a-aca3-89c4dfd21949	fishcap_002	24.88	8.61	\N	2026-09-17 03:26:57.82826	0.00	f	0.00	0.00	t	737.12	13d3c394-ca4a-4198-9490-07bd0176bdbd
309d4ee0-d13f-42e6-bb02-f2c13a26b6f6	fishcap_002	24.56	8.53	\N	2026-09-17 03:53:19.368332	0.00	f	0.00	0.00	t	217.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
e0f63583-cbaa-4271-9aaa-73fa0b7296f0	fishcap_002	24.69	8.55	\N	2026-09-17 04:14:45.689063	94.89	f	0.00	94.89	t	218.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
520214cd-1d07-4fdf-ad8f-1569732bbc62	fishcap_002	24.63	8.52	\N	2026-09-17 04:36:18.844272	94.65	f	0.00	94.65	t	218.87	13d3c394-ca4a-4198-9490-07bd0176bdbd
47668ba6-8bb2-44c0-a650-831a19eb972a	fishcap_002	25.31	8.80	\N	2026-09-17 02:42:06.506047	99.25	f	0.00	99.25	t	256.15	13d3c394-ca4a-4198-9490-07bd0176bdbd
6c055dbe-e19a-4c70-a918-9b2fcffea5e1	fishcap_002	25.31	8.69	\N	2026-09-17 03:03:22.197816	98.56	f	0.00	98.56	t	219.63	13d3c394-ca4a-4198-9490-07bd0176bdbd
c05ff3d4-db03-458e-bfb9-e39dc55fcbc5	fishcap_002	24.88	8.63	\N	2026-09-17 03:28:02.765128	0.00	f	0.00	0.00	t	736.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
ea52a0de-4ac0-43e7-9622-6abc13fe66cd	fishcap_002	24.50	8.58	\N	2026-09-17 03:54:18.630828	0.00	f	0.00	0.00	t	218.37	13d3c394-ca4a-4198-9490-07bd0176bdbd
f132f423-f4e9-457e-873f-c4157fa5936d	fishcap_002	24.69	8.52	\N	2026-09-17 04:15:50.62413	94.55	f	0.00	94.55	t	218.64	13d3c394-ca4a-4198-9490-07bd0176bdbd
9e80ad9e-7230-4a18-bb6d-ce00980bd4c7	fishcap_002	24.56	8.52	\N	2026-09-17 04:37:19.162303	94.51	f	0.00	94.51	t	218.82	13d3c394-ca4a-4198-9490-07bd0176bdbd
adf15862-76a8-4166-94b7-87deced92a1d	fishcap_002	25.31	8.79	\N	2026-09-17 02:43:06.513989	100.95	f	0.00	100.95	t	255.64	13d3c394-ca4a-4198-9490-07bd0176bdbd
b95ed6bc-7df6-4a52-92b9-4dab58458166	fishcap_002	25.31	8.71	\N	2026-09-17 03:04:22.198572	98.48	f	0.00	98.48	t	219.17	13d3c394-ca4a-4198-9490-07bd0176bdbd
9907a951-3e3e-4e43-8b25-0c4dc86016b6	fishcap_002	24.81	8.60	\N	2026-09-17 03:29:03.092653	0.00	f	0.00	0.00	t	734.09	13d3c394-ca4a-4198-9490-07bd0176bdbd
d0b51bbc-a3c7-42ef-a2f7-909422f014b2	fishcap_002	24.50	8.59	\N	2026-09-17 03:55:18.849805	0.00	f	0.00	0.00	t	217.03	13d3c394-ca4a-4198-9490-07bd0176bdbd
ad4d197f-9abd-445a-9916-6b59dc3662f0	fishcap_002	24.69	8.53	\N	2026-09-17 04:16:50.644701	94.34	f	0.00	94.34	t	218.55	13d3c394-ca4a-4198-9490-07bd0176bdbd
27051bca-0c92-4f6c-9f3c-e5345c76fc44	fishcap_002	24.56	8.53	\N	2026-09-17 04:38:19.154012	94.13	f	0.00	94.13	t	221.83	13d3c394-ca4a-4198-9490-07bd0176bdbd
0c58f8d3-900e-488a-95ea-abe92265799e	fishcap_002	25.25	8.79	\N	2026-09-17 02:44:05.926229	100.91	f	0.00	100.91	t	257.82	13d3c394-ca4a-4198-9490-07bd0176bdbd
67c3d27a-3e40-4478-926b-321d87de21b3	fishcap_002	25.25	8.67	\N	2026-09-17 03:05:30.184745	98.83	f	0.00	98.83	t	217.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
9c39d7e6-a11c-4545-a3d0-9e0a7fc71ad4	fishcap_002	24.88	8.59	\N	2026-09-17 03:30:02.770354	0.00	f	0.00	0.00	t	737.40	13d3c394-ca4a-4198-9490-07bd0176bdbd
42dae396-0a10-4880-a9b7-a527b112b578	fishcap_002	24.50	8.54	\N	2026-09-17 03:56:24.021337	0.00	f	0.00	0.00	t	217.05	13d3c394-ca4a-4198-9490-07bd0176bdbd
c28b8f0c-4821-4b23-91d8-a4ff50fb2d8b	fishcap_002	24.69	8.54	\N	2026-09-17 04:17:50.653687	94.34	f	0.00	94.34	t	218.46	13d3c394-ca4a-4198-9490-07bd0176bdbd
c4bf15da-2df5-4f08-bfbf-8de059eb8a48	fishcap_002	24.56	8.54	\N	2026-09-17 04:39:23.949335	94.48	f	0.00	94.48	t	218.73	13d3c394-ca4a-4198-9490-07bd0176bdbd
98d5ca6f-c74c-4af7-87f2-d4a056e7f0db	fishcap_002	25.25	8.78	\N	2026-09-17 02:45:05.588823	100.37	f	0.00	100.37	t	249.54	13d3c394-ca4a-4198-9490-07bd0176bdbd
52d16585-ab6e-49b6-b478-6e89c939bbc1	fishcap_002	25.25	8.68	\N	2026-09-17 03:06:31.821821	98.73	f	0.00	98.73	t	216.20	13d3c394-ca4a-4198-9490-07bd0176bdbd
49e5b84c-d65a-4299-80db-bf95923d0a23	fishcap_002	24.88	8.61	\N	2026-09-17 03:31:08.647791	0.00	f	0.00	0.00	t	736.94	13d3c394-ca4a-4198-9490-07bd0176bdbd
fcdd4bc7-458c-4008-bf04-9609fce1b24e	fishcap_002	24.50	8.57	\N	2026-09-17 03:57:23.726241	0.00	f	0.00	0.00	t	216.93	13d3c394-ca4a-4198-9490-07bd0176bdbd
e04f8d84-0c7b-4f2d-8ccf-567595901ae0	fishcap_002	24.69	8.52	\N	2026-09-17 04:18:51.181377	93.73	f	0.00	93.73	t	218.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
d263ce16-1110-4236-9482-731d7b6cc30f	fishcap_002	24.56	8.53	\N	2026-09-17 04:40:24.019046	94.31	f	0.00	94.31	t	218.87	13d3c394-ca4a-4198-9490-07bd0176bdbd
9bb6fa44-43a3-4ec4-bcf8-987de19f02ae	fishcap_002	25.19	8.75	\N	2026-09-17 02:46:05.568765	100.18	f	0.00	100.18	t	239.90	13d3c394-ca4a-4198-9490-07bd0176bdbd
c4afd347-bd57-4a7b-96a2-de53ea3e9f75	fishcap_002	25.31	8.71	\N	2026-09-17 03:07:33.659728	99.91	f	0.00	99.91	t	216.05	13d3c394-ca4a-4198-9490-07bd0176bdbd
28065220-b184-4738-a81d-59163f239e37	fishcap_002	24.94	8.60	\N	2026-09-17 03:32:08.444727	0.00	f	0.00	0.00	t	738.45	13d3c394-ca4a-4198-9490-07bd0176bdbd
ac4aa966-9ebb-469a-9cdb-45a4b4c5fd4b	fishcap_002	24.50	8.54	\N	2026-09-17 03:58:24.455005	5.66	f	0.00	5.66	t	217.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
ccfc011a-4be2-4946-ad56-8fd4c146b09d	test_probe	\N	10.47	\N	2026-09-15 10:04:18.191758	\N	\N	\N	\N	t	1.00	\N
4476d71b-5ea7-4ae7-b0f3-c9822f4a8458	fishcap_002	24.69	8.54	\N	2026-09-17 04:19:50.663173	93.77	f	0.00	93.77	t	219.09	13d3c394-ca4a-4198-9490-07bd0176bdbd
84507eae-f353-4a27-945f-7f6e534bd436	test_probe	\N	10.47	\N	2026-09-15 10:05:20.431542	\N	\N	\N	\N	t	1.00	\N
ff9e69dd-6ed8-403f-ac62-7d50d0cc5de0	fishcap_002	24.56	8.55	\N	2026-09-17 04:41:24.51326	94.56	f	0.00	94.56	t	219.01	13d3c394-ca4a-4198-9490-07bd0176bdbd
af3070d4-5771-4999-b579-15ba02c0b756	test_probe	\N	10.47	\N	2026-09-15 10:06:18.342839	\N	\N	\N	\N	t	1.00	\N
6555f1d0-f3ea-4766-b011-daf4ba83a990	fishcap_002	25.19	8.75	\N	2026-09-17 02:47:10.24173	99.89	f	0.00	99.89	t	235.20	13d3c394-ca4a-4198-9490-07bd0176bdbd
a83a0923-d88a-4a57-a944-07ceb553fde1	fishcap_002	25.31	8.69	\N	2026-09-17 03:08:35.441044	100.24	f	0.00	100.24	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
7ff07aba-6761-43b4-8608-3c227d09dbeb	fishcap_002	24.88	8.63	\N	2026-09-17 03:33:08.163954	0.00	f	0.00	0.00	t	734.95	13d3c394-ca4a-4198-9490-07bd0176bdbd
fa35cf81-5e16-4f74-94f7-51c8bd1cba97	fishcap_002	24.38	8.58	\N	2026-09-17 03:59:25.019881	0.00	f	0.00	0.00	t	216.61	13d3c394-ca4a-4198-9490-07bd0176bdbd
3a0b622a-a597-4b39-808f-cce84ca3963e	fishcap_002	24.75	8.53	\N	2026-09-17 04:20:55.767639	94.79	f	0.00	94.79	t	218.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
ee876233-8d91-4b7c-9c7f-43709e5f8fa2	fishcap_002	24.56	8.53	\N	2026-09-17 04:42:30.777582	94.52	f	0.00	94.52	t	219.30	13d3c394-ca4a-4198-9490-07bd0176bdbd
da210c7d-ad71-4130-a8e7-2b0aaa53b5de	fishcap_002	25.19	8.77	\N	2026-09-17 02:48:11.460214	99.52	f	0.00	99.52	t	229.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
6d64f8aa-3e76-412b-baf3-a9455a528256	fishcap_002	24.81	8.69	\N	2026-09-17 03:09:38.390122	100.35	f	0.00	100.35	t	728.93	13d3c394-ca4a-4198-9490-07bd0176bdbd
faf07dc5-1c0e-4b8d-8dc1-5fd4041eeb48	fishcap_002	24.88	8.63	\N	2026-09-17 03:34:14.184606	0.00	f	0.00	0.00	t	738.08	13d3c394-ca4a-4198-9490-07bd0176bdbd
ca1eebf5-d8f1-4d35-818e-7997dffb4c54	fishcap_002	24.50	8.54	\N	2026-09-17 04:00:25.07616	0.00	f	0.00	0.00	t	216.62	13d3c394-ca4a-4198-9490-07bd0176bdbd
e37e62fe-5a74-43a9-b1ad-6c8aa1f9bce3	fishcap_002	24.69	8.57	\N	2026-09-17 04:21:55.763592	94.51	f	0.00	94.51	t	218.64	13d3c394-ca4a-4198-9490-07bd0176bdbd
f9698332-9841-4887-b040-fa8cbbd4f17a	fishcap_002	24.56	8.53	\N	2026-09-17 04:43:31.380038	94.58	f	0.00	94.58	t	219.18	13d3c394-ca4a-4198-9490-07bd0176bdbd
5b0a436e-aa8a-4a61-834c-bd0812659cb7	fishcap_002	25.19	8.74	\N	2026-09-17 02:49:11.690905	99.55	f	0.00	99.55	t	229.27	13d3c394-ca4a-4198-9490-07bd0176bdbd
259c31d4-3ed2-4864-a754-af37b8e20a97	fishcap_002	24.56	8.66	\N	2026-09-17 03:10:38.134413	100.49	f	0.00	100.49	t	725.46	13d3c394-ca4a-4198-9490-07bd0176bdbd
1ad4a82c-97e4-4336-a304-c41c41543eb7	fishcap_002	24.88	8.61	\N	2026-09-17 03:35:13.179101	0.00	f	0.00	0.00	t	738.29	13d3c394-ca4a-4198-9490-07bd0176bdbd
601d7707-93ca-4025-8d17-eac120b52e4c	fishcap_002	24.44	8.56	\N	2026-09-17 04:01:25.451471	0.00	f	0.00	0.00	t	216.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
e5a868e7-0d98-45b4-aa46-239567b974ff	fishcap_002	24.69	8.55	\N	2026-09-17 04:22:55.801013	93.39	f	0.00	93.39	t	218.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
b8312d92-04a8-435b-9686-4ef44b119fba	fishcap_002	24.50	8.52	\N	2026-09-17 04:44:34.019641	94.41	f	0.00	94.41	t	218.90	13d3c394-ca4a-4198-9490-07bd0176bdbd
0932269a-5efd-4151-b0b6-3f81d5df6418	fishcap_001	28.44	\N	\N	2026-08-27 03:48:32.447295	303.60	f	0.00	303.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
307eae84-df5a-459e-ab97-1dc82b61a496	fishcap_001	28.60	\N	\N	2026-08-27 05:04:53.491604	1500.50	f	0.00	1500.50	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5f5b6d8e-434c-4db8-aadc-daa28afc30fc	fishcap_001	28.60	\N	\N	2026-08-27 05:53:25.29772	80.00	t	2.00	80.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
51870c61-7085-4996-953e-d72da0a53f15	fishcap_001	27.06	\N	\N	2026-09-02 09:14:00.627079	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
95972711-bd4a-46c0-8626-e93b1219b81c	fishcap_001	27.00	\N	\N	2026-09-02 09:15:00.408446	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b7af4960-378c-4033-917a-3bafc83502f7	fishcap_001	27.00	\N	\N	2026-09-02 09:16:02.026573	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ccdee97e-f8d1-40c0-b8bd-bf167b6f4bfa	fishcap_001	27.00	\N	\N	2026-09-02 09:17:01.100947	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e45e48bd-57ba-4ce7-844c-20aa7bf79930	fishcap_001	27.00	\N	\N	2026-09-02 09:18:02.039847	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ab07a91f-aa4f-4b71-9f4e-d61d62b76285	fishcap_001	25.56	\N	\N	2026-09-02 09:19:01.446495	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6af1840c-6716-469b-abd4-07281f1e7163	fishcap_001	24.94	\N	\N	2026-09-02 09:20:01.280524	5.80	f	0.00	5.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
21180790-8034-4e93-8aa6-15e670172e1e	fishcap_001	24.75	\N	\N	2026-09-02 09:21:02.104413	2.00	f	0.00	2.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bccace71-db30-4850-a362-01de05df13e3	fishcap_001	24.75	\N	\N	2026-09-02 09:22:08.596814	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
60624b03-dec2-4e43-8da0-e09c4ac4ade2	fishcap_001	25.00	\N	\N	2026-09-02 09:23:07.833313	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f758de76-ef2b-40a6-af22-e3d503643933	fishcap_001	25.13	\N	\N	2026-09-02 09:24:07.85149	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d47886d7-3f5f-43df-84d5-699343689119	fishcap_001	25.31	\N	\N	2026-09-02 09:25:08.311	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ebb43ac0-8b68-42d4-800e-b14127039523	fishcap_001	25.44	\N	\N	2026-09-02 09:26:08.398692	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6a6191e2-84b9-496a-acc8-3aed52a00adc	fishcap_001	25.63	\N	\N	2026-09-02 09:27:08.465928	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
562da5fa-1589-4041-b461-8e6f639a8657	fishcap_001	25.75	\N	\N	2026-09-02 09:28:08.463686	6.00	f	0.00	6.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a7789f74-6335-420f-854b-d6f647cd86d0	fishcap_001	25.94	\N	\N	2026-09-02 09:29:09.29771	75.00	f	0.00	75.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b21cbbd2-bc08-49a0-a0c8-b5ef7697a6d0	fishcap_001	26.06	\N	\N	2026-09-02 09:30:09.519592	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
76911168-084c-4d75-a92f-71de8f1acb7a	fishcap_001	26.38	\N	\N	2026-09-02 09:31:09.044061	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
992698f2-7291-4122-9ec2-047ae55252af	fishcap_001	26.50	\N	\N	2026-09-02 09:32:09.918569	0.80	f	0.00	0.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c760e36e-3245-4b0d-9bf9-0d99f0447157	fishcap_001	26.69	\N	\N	2026-09-02 09:33:09.205545	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
401d9c6e-8e41-4259-ab1a-cd51f1db1d9b	fishcap_001	26.81	\N	\N	2026-09-02 09:34:09.556762	1.00	f	0.00	1.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1ceec0dc-63e9-442c-a549-645d3b866881	fishcap_001	26.94	\N	\N	2026-09-02 09:35:09.345292	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9ee92e5d-8749-439f-b68b-0c9360dcdb98	fishcap_001	26.94	\N	\N	2026-09-02 09:36:09.582673	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4e4f9d93-f1f3-46a9-a056-6c1fa1b47e55	fishcap_001	27.00	\N	\N	2026-09-02 09:37:10.574568	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
51e0a304-47cb-40b5-bcb0-9e7ad82d0196	fishcap_001	27.06	\N	\N	2026-09-02 09:38:09.767703	1.00	f	0.00	1.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fda502fc-3bde-4284-84f5-833cae9e4549	fishcap_001	27.13	\N	\N	2026-09-02 09:40:10.834828	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
aabc4336-d69a-4705-beed-28671013ba34	fishcap_001	27.13	\N	\N	2026-09-02 09:41:09.963357	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
40d33d5d-2ca0-4593-b828-23bd6add671f	fishcap_001	27.25	\N	\N	2026-09-02 09:42:10.127451	2.60	f	0.00	2.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
df016e08-98d7-4815-a6d1-7dccda5ec753	fishcap_001	27.56	\N	\N	2026-09-02 09:43:10.628052	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c0d20f0c-bf58-4959-830b-92a91fe8aa3d	fishcap_001	27.63	\N	\N	2026-09-02 09:44:10.46325	1.80	f	0.00	1.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
80d7cd00-aa69-4de8-a819-0cf564526121	fishcap_001	27.69	\N	\N	2026-09-02 09:45:10.643613	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
cdaaec34-5b96-47ae-ae83-588ba7ca05f8	fishcap_001	27.75	\N	\N	2026-09-02 09:46:10.242718	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
60f9a60b-fe21-4d9e-9a7e-7cdb13e91190	fishcap_001	27.81	\N	\N	2026-09-02 09:47:10.259182	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3540c160-f7d3-4ae5-a2e7-55a52f45dd74	fishcap_001	27.81	\N	\N	2026-09-02 09:48:11.277508	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d687cae7-8ea4-489a-9c03-789dc7a0ac75	fishcap_001	27.88	\N	\N	2026-09-02 09:49:11.2786	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2fd17698-af7c-4afd-81b7-2e5840d17d45	fishcap_001	27.88	\N	\N	2026-09-02 09:50:11.08028	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
deaae4af-807c-4e12-8837-0c0434170cd9	fishcap_001	27.88	\N	\N	2026-09-02 09:51:10.611804	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9f61e33c-4d6a-4287-bd0b-c0b65ca6e351	fishcap_001	27.88	\N	\N	2026-09-02 09:52:10.484099	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8c1453f8-4376-4f59-9a3f-6a1ca40e30da	fishcap_001	27.88	\N	\N	2026-09-02 09:53:10.492549	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
948cc8cd-6228-4495-91b7-d2e6827cc265	fishcap_001	27.88	\N	\N	2026-09-02 09:54:10.698624	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a3265c46-4386-4ddd-8035-c7ac9be10859	fishcap_001	27.81	\N	\N	2026-09-02 09:55:10.61969	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bbfae836-c4a8-46f7-8c44-c870ac67a23e	fishcap_001	27.88	\N	\N	2026-09-02 09:56:11.527355	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
efea1eb6-f93f-4a12-a3cb-591d5465dcbf	fishcap_001	27.88	\N	\N	2026-09-02 09:57:11.533363	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d6e13e94-d795-4a2b-be24-e0714bc0622e	fishcap_001	27.81	\N	\N	2026-09-02 09:58:11.542278	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
651d0cb8-b22a-4a06-ac63-23d1c9916bd7	fishcap_001	27.69	\N	\N	2026-09-03 01:54:26.120907	2.40	f	0.00	2.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
19ed5207-49ce-4070-8c11-b47b9471b37c	fishcap_001	27.63	\N	\N	2026-09-03 01:55:26.222028	6.20	f	0.00	6.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5cab5397-0b06-47a1-8050-b99959e817f7	fishcap_001	27.63	\N	\N	2026-09-03 01:56:27.041564	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d719e38e-9772-4f35-bc27-b3e8251e0949	fishcap_001	27.56	\N	\N	2026-09-03 01:57:26.844462	7.60	f	0.00	7.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
08edf973-0fe8-4a66-ab6e-f55818e17e4f	fishcap_001	27.63	\N	\N	2026-09-03 01:58:27.854637	1.80	f	0.00	1.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8fb1cf6a-b6c6-447a-9609-7f9e6cecf841	fishcap_001	27.63	\N	\N	2026-09-03 01:59:27.843501	1.60	f	0.00	1.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6498f3cf-c5b0-4a2c-bb98-bcf491aa2714	fishcap_001	27.63	\N	\N	2026-09-03 02:00:27.849967	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c123a060-7a07-4a35-9bb6-818baa893a21	fishcap_001	27.56	\N	\N	2026-09-03 02:01:27.853478	4.00	f	0.00	4.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c653753e-3cdb-40cc-809d-fd21231ba27c	fishcap_001	27.56	\N	\N	2026-09-03 02:02:27.862413	0.40	f	0.00	0.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ebc0d233-f687-4fbb-8cf7-083a9f212e71	fishcap_001	27.56	\N	\N	2026-09-03 02:03:28.584675	14.20	f	0.00	14.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e6950398-aba7-4f00-a4f3-05686099f04e	fishcap_001	27.56	\N	\N	2026-09-03 02:04:28.559059	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ca889e63-65c5-4b23-aa3e-d5fc880789ac	fishcap_001	27.56	\N	\N	2026-09-03 02:05:27.819876	2.80	f	0.00	2.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
13380946-afaf-45f9-acac-997702eafcfd	fishcap_001	27.56	\N	\N	2026-09-03 02:06:29.521951	10.20	f	0.00	10.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ab537d99-4b6f-49fd-9001-961118f2a537	fishcap_001	27.56	\N	\N	2026-09-03 02:07:28.599814	2.00	f	0.00	2.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3ea571ec-095a-4398-a262-3ef8764f2a80	fishcap_001	27.56	\N	\N	2026-09-03 02:08:28.589689	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
67897013-c5b8-4ff9-a0b8-516b8ae586c2	fishcap_001	27.50	\N	\N	2026-09-03 02:09:29.375696	5.20	f	0.00	5.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
37e58cfc-683b-416d-9f82-5bc1aeec349b	fishcap_001	27.50	\N	\N	2026-09-03 02:10:29.535984	3.40	f	0.00	3.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
def09c27-6a7e-45a4-b8c0-c801e1bf7f0a	fishcap_001	27.50	\N	\N	2026-09-03 02:11:29.951038	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2a4126e7-8ab1-4076-aefd-e64c66308e96	fishcap_001	27.50	\N	\N	2026-09-03 02:12:29.955734	3.60	f	0.00	3.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ef47ea35-986e-4329-9d77-3927fe5d0667	fishcap_001	27.50	\N	\N	2026-09-03 02:13:29.148322	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7b433258-580e-4e8f-b226-165c95bad2c6	fishcap_001	27.50	\N	\N	2026-09-03 02:14:30.169177	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
63594897-59b3-43de-98df-dae6f0ccf53f	fishcap_001	27.50	\N	\N	2026-09-03 02:15:30.171643	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a59a6864-e5db-42df-b04b-63229d391c69	fishcap_001	27.50	\N	\N	2026-09-03 02:16:30.175241	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b4caf72b-8bcb-48e1-be42-c92e8b3d2e4e	fishcap_001	27.44	\N	\N	2026-09-03 02:17:30.388805	6.80	f	0.00	6.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2cc01334-a39c-4d5e-b3cf-f3c43cbe5f19	fishcap_001	27.50	\N	\N	2026-09-03 02:18:30.389223	9.20	f	0.00	9.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
034545a0-1cf9-43bd-93a2-0863b0670c7d	fishcap_001	27.50	\N	\N	2026-09-03 02:19:30.396574	1.20	f	0.00	1.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c3ddcc3f-1d02-421e-805f-4b6494233f77	fishcap_001	27.50	\N	\N	2026-09-03 02:20:30.203853	3.00	f	0.00	3.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f1264a5b-20b9-4e75-84d8-e33e5de9ceda	fishcap_001	27.44	\N	\N	2026-09-03 02:21:31.22428	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f61de87c-d4f9-4d07-8c9d-cdecad0b855b	fishcap_001	27.44	\N	\N	2026-09-03 02:22:31.237612	6.40	f	0.00	6.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a99cf52b-e263-4763-8879-d0aba566056b	fishcap_001	27.44	\N	\N	2026-09-03 02:23:31.238705	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
885edb64-ec04-4fd1-95fc-1159807a2b52	fishcap_001	27.44	\N	\N	2026-09-03 02:24:31.247601	2.00	f	0.00	2.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
70c5e4d4-c4d5-41d0-8e51-efa827f07ce7	fishcap_001	27.44	\N	\N	2026-09-03 02:25:31.438235	5.40	f	0.00	5.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2a159d55-1bbc-447c-8b96-be2c7afa8d37	fishcap_001	27.44	\N	\N	2026-09-03 02:26:31.360231	2.20	f	0.00	2.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8d21f92f-e017-4e7b-9c87-994c010c5a44	fishcap_001	27.38	\N	\N	2026-09-03 02:27:31.456194	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
646eddc6-1761-432f-a806-02c06c4bf47c	fishcap_001	27.38	\N	\N	2026-09-03 02:28:32.277083	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e712bba1-e063-489f-9ca7-23f7de3516de	fishcap_001	27.38	\N	\N	2026-09-03 02:29:32.279592	5.40	f	0.00	5.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b4a66d69-75c4-484a-9665-e20b9c583963	fishcap_001	27.38	\N	\N	2026-09-03 02:30:32.086651	9.00	f	0.00	9.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
32ac2152-23d8-488e-bb79-67b433c80c9a	fishcap_001	27.44	\N	\N	2026-09-03 02:31:31.694952	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2d2adc02-67d9-473d-97ec-09e4feaa5147	fishcap_001	27.44	\N	\N	2026-09-03 02:32:31.755608	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e1151699-6892-4d26-95a0-44647b924056	fishcap_001	27.38	\N	\N	2026-09-03 02:33:32.310428	5.80	f	0.00	5.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
689706f3-2b28-4bdc-af57-56856d0f0918	fishcap_001	27.44	\N	\N	2026-09-03 02:34:32.921179	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
070e4fe4-d871-4400-b883-ffa5328b09dc	fishcap_001	27.38	\N	\N	2026-09-03 02:35:32.937077	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
45f5d89c-d027-40fc-b014-39a2d9c47f1b	fishcap_001	27.44	\N	\N	2026-09-03 02:36:32.587423	8.60	f	0.00	8.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bcdd9773-bc5b-4898-9e92-f30a8db32368	fishcap_001	27.44	\N	\N	2026-09-03 02:37:32.787568	6.40	f	0.00	6.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a2bf7d4e-c378-4986-b716-4688f1fe56b9	fishcap_001	27.44	\N	\N	2026-09-03 02:38:32.965497	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
66e1b4e6-992f-4cf5-bfb6-2041d03ae98e	fishcap_001	27.44	\N	\N	2026-09-03 02:39:33.212996	3.60	f	0.00	3.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
06c0bc08-7ab7-4119-ae15-6fd5ded6c369	fishcap_001	27.44	\N	\N	2026-09-03 02:40:33.28437	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2934ecdd-b987-4c00-80db-003ccfd6625a	fishcap_001	27.44	\N	\N	2026-09-03 02:41:33.288989	1.40	f	0.00	1.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3d359b1e-dba6-4b0d-b566-cff230cf26fc	fishcap_001	27.44	\N	\N	2026-09-03 02:42:33.473636	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9fc1ac05-fc56-43af-9c5f-69ed82fcb9bb	fishcap_001	27.44	\N	\N	2026-09-03 02:43:34.206683	1.40	f	0.00	1.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
30551b26-5d80-4c68-af29-807c9dfa6f9f	fishcap_001	27.44	\N	\N	2026-09-03 02:44:33.600587	3.80	f	0.00	3.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0d795a45-e02e-4658-8344-d85e9b68316d	fishcap_001	27.38	\N	\N	2026-09-03 02:45:33.814914	0.40	f	0.00	0.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4a8b0f74-8727-4ca0-965e-385c099dbd4d	fishcap_001	27.44	\N	\N	2026-09-03 02:46:33.851935	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b71e0c38-2bd0-4eee-b3ca-7de51cae3241	fishcap_001	27.44	\N	\N	2026-09-03 02:47:34.438662	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0fa93c21-c22b-471d-b739-984959561097	fishcap_001	27.44	\N	\N	2026-09-03 02:51:35.340976	5.20	f	0.00	5.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1c1e9cab-fe44-4a57-98e7-0e621c5edf54	fishcap_001	27.44	\N	\N	2026-09-03 02:52:35.393511	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d014e2b4-a3c4-4ca6-826b-60e59adea161	fishcap_001	27.50	\N	\N	2026-09-03 02:53:35.869157	5.20	f	0.00	5.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e3451cd4-3adc-4818-9517-cb29979c906a	fishcap_001	27.50	\N	\N	2026-09-03 02:54:36.974099	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
64260cfd-b4b0-4be8-b2c2-7224f1331a7e	fishcap_001	27.44	\N	\N	2026-09-03 02:55:36.965589	1.40	f	0.00	1.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
288ca47c-a73f-4b43-9e82-df3b6592b852	fishcap_001	27.44	\N	\N	2026-09-03 02:56:36.163644	16.00	f	0.00	16.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
05db5ab3-af5c-4ff3-a39c-497eb7d3130b	fishcap_001	27.50	\N	\N	2026-09-03 02:57:36.170764	1.80	f	0.00	1.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
71560008-6fe9-419d-ab69-346413c6ff3e	fishcap_001	27.50	\N	\N	2026-09-03 02:58:36.612505	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dde31c8a-3ed1-40d0-92b7-1917b6cdca8a	fishcap_001	27.50	\N	\N	2026-09-03 02:59:37.20605	7.60	f	0.00	7.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
472295da-d97b-4e61-9f81-40b85992a06f	fishcap_001	27.50	\N	\N	2026-09-03 03:00:37.419039	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
27a5b95c-e3f1-4872-a65f-388d1b308c6e	fishcap_001	27.50	\N	\N	2026-09-03 03:01:36.865692	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3a03cbe2-15a1-4f10-9891-eea92b546831	fishcap_001	27.50	\N	\N	2026-09-03 03:02:37.604814	7.00	f	0.00	7.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9385c577-e876-459e-808e-0cb3ff0431b0	fishcap_001	27.50	\N	\N	2026-09-03 03:03:37.863315	1.60	f	0.00	1.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6a7581fa-448a-4f53-8cf4-60936ba65da8	fishcap_001	30.50	\N	\N	2026-09-04 01:42:03.517453	1472.20	f	0.00	1472.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3cee2e50-becf-464a-8f9f-0b18da44eb2a	fishcap_001	30.50	\N	\N	2026-09-04 01:46:09.870224	595.60	f	0.00	595.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4c9944bb-ad67-48b7-a4d1-71d37f46d8e6	fishcap_001	30.50	\N	\N	2026-09-04 01:46:59.503892	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dafec347-2b64-4d1a-9f75-39616432c670	fishcap_001	30.50	\N	\N	2026-09-04 01:48:08.578046	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1668921b-68dc-47d0-9ae4-960698a5f6a0	fishcap_001	30.50	\N	\N	2026-09-04 01:48:42.611939	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
17ad6852-4fd9-47ad-a923-4d522e4deef2	fishcap_001	30.00	\N	\N	2026-09-04 01:50:04.43386	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
05fcd17f-0fbe-4f4b-8d10-04387f33c728	fishcap_001	30.00	\N	\N	2026-09-04 01:51:10.518917	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1a58f664-6842-45ce-92e4-3bdc0ea68347	fishcap_001	30.00	\N	\N	2026-09-04 01:52:05.709658	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e3b7e293-9330-4283-af89-d49240c7e26b	fishcap_001	30.50	\N	\N	2026-09-04 01:53:05.977934	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
46b34239-c65b-4c38-b713-b8a97c1872f0	fishcap_001	30.50	\N	\N	2026-09-04 01:54:07.031886	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
704f4e52-2874-4d8c-a86f-71a3a04ce401	fishcap_001	30.50	\N	\N	2026-09-04 01:55:07.967296	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
86043a05-19cb-456c-88df-c43212da1824	fishcap_001	31.00	\N	\N	2026-09-04 01:56:08.170565	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
34e4b7fc-5752-40f1-9ba9-57845545021c	fishcap_001	31.00	\N	\N	2026-09-04 01:57:09.395588	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
44849303-2a18-441d-a23e-7c4619559dad	fishcap_001	29.50	\N	\N	2026-09-04 01:58:10.106007	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6416c454-c716-4443-b402-6953156b606f	fishcap_001	29.50	\N	\N	2026-09-04 01:59:10.594408	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
abe88063-075d-4763-a0e8-02c5813c3e6f	fishcap_001	29.50	\N	\N	2026-09-04 02:00:10.674708	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
48f8b4cc-fc71-48dc-af69-de4ec6f15ab8	fishcap_001	29.50	\N	\N	2026-09-04 02:01:10.453144	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
13bf22af-f094-425d-adb5-af414845411f	fishcap_001	29.50	\N	\N	2026-09-04 02:02:11.377241	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ba234381-2bec-4f4b-8807-e2d1526f8103	fishcap_001	29.50	\N	\N	2026-09-04 02:03:11.368235	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1e83132e-2302-4546-8fdf-2f48482b6569	fishcap_001	29.50	\N	\N	2026-09-04 02:04:12.810114	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
de6ba566-488f-4542-b477-1015e95e7b82	fishcap_001	29.00	\N	\N	2026-09-04 02:05:12.417937	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9b095c52-cfaa-45ff-8df4-77a777d67f14	fishcap_001	29.50	\N	\N	2026-09-04 02:06:12.972925	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8b8688ec-fccc-4e9f-acee-a9e8f1149636	fishcap_001	29.50	\N	\N	2026-09-04 02:07:15.747132	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f7c51b32-10a0-4553-840a-1935539fc842	fishcap_001	29.00	\N	\N	2026-09-04 02:08:11.758971	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4b3ee4fa-7cf1-44d3-9008-535412aba0ba	fishcap_001	29.00	\N	\N	2026-09-04 02:09:12.234556	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9436cb2f-6c7e-43c8-8e0a-48a15bdd62ad	fishcap_001	29.00	\N	\N	2026-09-04 02:10:11.918137	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
57436d76-ec9c-468a-afe9-23f861480341	fishcap_001	29.00	\N	\N	2026-09-04 02:11:11.895074	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3c58d123-1ef7-4ea9-8bf5-60eebfdb62a7	fishcap_001	29.00	\N	\N	2026-09-04 02:12:12.249249	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2b0f88a6-b58f-4787-ac69-31a561893b0d	fishcap_001	29.00	\N	\N	2026-09-04 02:13:12.467182	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bf7015be-67eb-483c-be4b-08f07cb87564	fishcap_001	29.00	\N	\N	2026-09-04 02:14:12.163804	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5de10487-fcae-452f-8f82-121d501a577e	fishcap_001	29.00	\N	\N	2026-09-04 02:15:12.682057	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0b847103-cc56-4010-bea5-b07af20803f4	fishcap_001	29.00	\N	\N	2026-09-04 02:16:17.222118	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
36762551-8302-4cfe-b6bf-5f9ad5bb1e89	fishcap_001	-127.00	\N	\N	2026-09-04 02:52:19.880476	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a26b2f62-c72d-4ef4-a3d9-7c52209d08b1	fishcap_001	30.50	\N	\N	2026-09-04 02:53:20.879898	1468.60	f	0.00	1468.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
955207cc-b073-4087-8982-0c5e6ba45070	fishcap_001	30.50	\N	\N	2026-09-04 02:54:20.285692	1465.60	f	0.00	1465.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
790b5ac8-5a56-43f7-813e-674de65e1c54	fishcap_001	30.50	\N	\N	2026-09-04 02:55:20.365746	1465.80	f	0.00	1465.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dbdf9373-15d5-423c-870f-e3beed086710	fishcap_001	30.50	\N	\N	2026-09-04 02:56:21.731997	1469.20	f	0.00	1469.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3b61aa88-b139-4935-8b72-484ab82c64d0	fishcap_001	30.00	\N	\N	2026-09-04 02:57:21.129682	1464.60	f	0.00	1464.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7323e7df-e299-4611-8c28-fa78cc2c28ec	fishcap_001	30.00	\N	\N	2026-09-04 02:58:21.755611	1460.80	f	0.00	1460.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
04884f4c-4985-4740-8a25-535e0389620a	fishcap_001	30.00	\N	\N	2026-09-04 02:59:22.171548	1463.80	f	0.00	1463.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5cb3fc27-5c50-4231-a2e5-d95a12e8f358	fishcap_001	30.00	\N	\N	2026-09-04 03:00:22.783351	1177.00	f	0.00	1177.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6a12869b-9739-460c-9244-f5a9119287e2	fishcap_001	30.00	\N	\N	2026-09-04 03:01:22.790014	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
30d45620-d466-4dc1-b5c9-1ba1e8ea874d	fishcap_001	30.00	\N	\N	2026-09-04 03:02:21.904605	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
aee4e5b7-256d-4e0e-af32-14002c63fcd3	fishcap_001	30.00	\N	\N	2026-09-04 03:03:21.923521	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1eca7b90-8a7f-4f91-916e-327939f822ee	fishcap_001	30.00	\N	\N	2026-09-04 03:04:22.093993	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
23bb31b4-b985-4973-816f-34aa5d26a652	fishcap_001	30.00	\N	\N	2026-09-04 03:05:22.00936	1476.40	f	0.00	1476.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
382c2b7e-c211-4b2f-b4db-589e1a3b197f	fishcap_001	30.00	\N	\N	2026-09-04 03:06:22.824085	1476.40	f	0.00	1476.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6a7a04c0-4c11-4828-986e-cda3043b00ea	fishcap_001	30.00	\N	\N	2026-09-04 03:07:23.036401	1471.00	f	0.00	1471.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d97c658c-9848-4633-95d4-13e82a76479f	fishcap_001	30.00	\N	\N	2026-09-04 03:08:23.038351	1458.40	f	0.00	1458.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
02ab4110-cb7e-4832-8d55-f880e8a3cf3e	fishcap_001	30.00	\N	\N	2026-09-04 03:09:22.446697	1469.60	f	0.00	1469.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
82c6c992-2635-4ada-afc7-f00c47980e88	fishcap_001	30.00	\N	\N	2026-09-04 03:10:22.248391	1473.80	f	0.00	1473.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
abc4c85e-c7e6-4525-95df-b20e3127c75e	fishcap_001	30.00	\N	\N	2026-09-04 03:11:22.259772	1466.00	f	0.00	1466.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b91ba4b3-9b3c-4fff-9c8b-8e0c10736715	fishcap_001	30.00	\N	\N	2026-09-04 03:12:22.261156	1468.00	f	0.00	1468.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
59563e2b-77fe-483e-8295-8098983fd341	fishcap_001	30.00	\N	\N	2026-09-04 03:13:22.249174	1474.20	f	0.00	1474.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
aeb5e1f8-3348-416f-9522-8a8a90972515	fishcap_001	30.00	\N	\N	2026-09-04 03:14:22.498442	1456.80	f	0.00	1456.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
97f06291-94e8-43b2-b150-53e1c5316e22	fishcap_001	30.00	\N	\N	2026-09-04 03:15:22.572231	1468.00	f	0.00	1468.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d519c709-dbc1-4a5f-84f4-7b36a0e106d6	fishcap_001	30.00	\N	\N	2026-09-04 03:16:22.621922	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
708f7afa-e3f1-46eb-8490-d66212ab9fbf	fishcap_001	30.00	\N	\N	2026-09-04 03:17:00.205648	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0bcfdeeb-e345-49fd-a8fc-a4451ba3e915	fishcap_001	30.00	\N	\N	2026-09-04 03:17:23.317164	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3e7c581f-be5d-4f87-9aad-59dab9443f39	fishcap_001	30.00	\N	\N	2026-09-04 03:18:22.725706	1467.40	f	0.00	1467.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
39afcc35-a3e8-4629-9324-139468571956	fishcap_001	30.00	\N	\N	2026-09-04 03:19:01.576392	1466.60	t	2.00	1466.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
77396aac-ca91-4db9-873f-940b21af521b	fishcap_001	30.00	\N	\N	2026-09-04 03:19:23.330652	1469.80	f	0.00	1469.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e9c8012f-18d0-4025-abc7-42c5b82d14b3	fishcap_001	30.00	\N	\N	2026-09-04 03:20:23.750171	1466.80	f	0.00	1466.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f1e8142c-d805-456a-9de9-0540668079c1	fishcap_001	30.00	\N	\N	2026-09-04 03:21:23.775762	1469.00	f	0.00	1469.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c04fef30-4566-408b-9ff6-f0fe367ba06c	fishcap_001	30.00	\N	\N	2026-09-04 03:22:28.644127	1462.40	f	0.00	1462.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3881c8e2-5ffa-422e-85a4-d0e29d9bf270	fishcap_001	30.00	\N	\N	2026-09-04 03:23:30.459218	1474.60	f	0.00	1474.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
46626565-a258-4ccd-9072-dbf1643f08ac	fishcap_001	30.00	\N	\N	2026-09-04 03:24:30.642209	1467.20	f	0.00	1467.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b8dd5a02-be53-4405-a330-399d25822f48	fishcap_001	30.00	\N	\N	2026-09-04 03:25:30.724152	1461.20	f	0.00	1461.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
003fcdcc-3118-467a-9a60-c3514ed5b523	fishcap_001	30.00	\N	\N	2026-09-04 03:26:30.770438	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
643dcab1-2f2c-4eff-895b-faf908f9e35c	fishcap_001	30.00	\N	\N	2026-09-04 03:27:30.799667	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
aa2ec9d5-ba6b-49e7-adb6-a5d253db4af6	fishcap_001	30.00	\N	\N	2026-09-04 03:28:30.791548	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
60875ae6-775b-423c-a08e-24820231f213	fishcap_001	30.00	\N	\N	2026-09-04 03:29:31.788214	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3af6e5ef-3054-4c48-90d0-01a82f15737d	fishcap_001	30.00	\N	\N	2026-09-04 03:30:31.793213	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
daf8159f-f29e-4b3c-a26a-6b5c1550cc52	fishcap_001	30.00	\N	\N	2026-09-04 03:31:31.694982	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b866b0b9-da9a-4832-9c34-b1d49cede2ee	fishcap_001	30.00	\N	\N	2026-09-04 03:32:31.027133	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
287eca2b-87a9-49e9-8a3c-fd7ecd0e57c1	fishcap_001	30.00	\N	\N	2026-09-04 03:33:31.962719	1475.00	f	0.00	1475.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
38cdb26a-3b41-441c-ac2b-26eccadd3ef4	fishcap_001	30.00	\N	\N	2026-09-04 03:34:31.227628	1465.00	f	0.00	1465.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
442a90a2-a126-43df-a236-ef12cf51ac67	fishcap_001	30.00	\N	\N	2026-09-04 03:35:32.244015	1467.40	f	0.00	1467.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
55018586-5f5f-45f9-a200-430c7bfa9bc7	fishcap_001	30.00	\N	\N	2026-09-04 03:36:32.051209	1464.80	f	0.00	1464.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dc08e365-bbf3-4e1f-ad0b-cdf719bcd6f3	fishcap_001	29.38	\N	\N	2026-09-04 08:22:57.698344	6.20	f	0.00	6.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e8d33b46-b357-49a5-9ed5-ec54d96bbc82	fishcap_001	29.44	\N	\N	2026-09-04 08:23:57.341114	2.80	f	0.00	2.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
209af29b-501d-4e77-8602-254e1b689886	fishcap_001	27.88	\N	\N	2026-09-04 08:24:57.317431	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c57ae215-1845-42dc-84a4-ec3c8cc548e0	fishcap_001	17.25	\N	\N	2026-09-04 08:25:58.491202	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
257e52cd-50f0-4377-a1dd-f606a0ccd746	fishcap_001	15.88	\N	\N	2026-09-04 08:26:57.747521	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ec2e6dc5-4ff0-4d7e-8fec-6fcc6c84c8a1	fishcap_001	16.38	\N	\N	2026-09-04 08:27:57.705568	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
62a0f3e0-8526-46bf-854d-ca8caaaad128	fishcap_001	16.81	\N	\N	2026-09-04 08:28:58.632179	2.60	f	0.00	2.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
547ea18e-04a7-42fe-89cb-28e951899430	fishcap_001	17.31	\N	\N	2026-09-04 08:29:58.822763	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1040e2f0-488b-4c2a-a824-9c45a8e45535	fishcap_001	17.75	\N	\N	2026-09-04 08:30:59.454127	5.00	f	0.00	5.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6c99467e-1d73-4c52-a5fa-2e4f54eeb962	fishcap_001	18.25	\N	\N	2026-09-04 08:31:59.246207	1.80	f	0.00	1.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6ca8bc9b-7084-4aca-ac08-b967a6f0a075	fishcap_001	18.69	\N	\N	2026-09-04 08:32:59.170439	9.20	f	0.00	9.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b4c18013-0ba9-4d47-ad4e-d24cd2ce08f8	fishcap_001	19.06	\N	\N	2026-09-04 08:33:59.009464	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
eafebde1-3195-4228-b8f2-f03d2e760316	fishcap_001	19.44	\N	\N	2026-09-04 08:34:59.663496	7.60	f	0.00	7.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4a6e44d0-a61e-474a-9f41-110a7ef31745	fishcap_001	19.75	\N	\N	2026-09-04 08:35:59.483508	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7cfb76e7-02e7-4759-a7fd-b4fdc7d38faf	fishcap_001	20.06	\N	\N	2026-09-04 08:36:58.87388	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
efb1e7db-889c-4d5e-9b58-1570e093618d	fishcap_001	20.38	\N	\N	2026-09-04 08:37:58.888271	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9f766273-0a03-4e24-8852-a56fdd36317d	fishcap_001	20.69	\N	\N	2026-09-04 08:39:01.754237	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
93c2da1b-a0e0-4f62-b8bb-4849cc8a7af3	fishcap_001	20.94	\N	\N	2026-09-04 08:40:01.376257	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
83936306-3259-4539-99e7-73d378121d77	fishcap_001	21.19	\N	\N	2026-09-04 08:41:02.179643	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
41836e81-9375-4f1d-be47-e374ca7e673f	fishcap_001	21.44	\N	\N	2026-09-04 08:42:02.389975	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b8594b1b-3c1a-4d70-8efe-80a6ae0a0bda	fishcap_001	21.69	\N	\N	2026-09-04 08:43:02.194396	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5a424618-72d4-48c8-b3a1-503ec950264a	fishcap_001	21.88	\N	\N	2026-09-04 08:44:02.003401	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bbbd0565-2a86-46a4-a0f1-89595eb20e73	fishcap_001	22.13	\N	\N	2026-09-04 08:45:02.849655	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
31cc133d-bdbd-4dfd-b07b-c9738171a438	fishcap_001	22.31	\N	\N	2026-09-04 08:46:02.442631	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b8ad3186-9741-4453-a159-9fec37a70738	fishcap_001	22.50	\N	\N	2026-09-04 08:47:02.661223	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3f24401d-249b-4e27-ae2a-2b2b8e4390f8	fishcap_001	22.69	\N	\N	2026-09-04 08:48:03.66267	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
aad28f5c-0a2e-41a7-8ed0-e7c783705879	fishcap_001	22.88	\N	\N	2026-09-04 08:49:02.684701	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7a87f42c-5a20-4e3b-99fa-718592e1be65	fishcap_001	23.06	\N	\N	2026-09-04 08:50:03.078794	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dbf7c7d2-1faf-4b79-aacb-327e752c6f48	fishcap_001	23.19	\N	\N	2026-09-04 08:51:02.917622	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
63655bb8-1066-4eb6-ac14-55e5f0936d03	fishcap_001	23.38	\N	\N	2026-09-04 08:52:04.116626	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6e08402c-b970-4187-a1ed-d9ac085d5526	fishcap_001	23.56	\N	\N	2026-09-04 08:53:03.129581	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4e3fd933-1dfe-4ef5-a50b-9589816a806f	fishcap_001	24.06	\N	\N	2026-09-04 08:54:03.136082	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2bb12553-392f-4020-9461-9828fd8c7176	fishcap_001	34.81	\N	\N	2026-09-04 09:25:07.020695	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
15cd70c0-ee8a-46b4-bf0b-f5c1dcb47412	fishcap_001	51.69	\N	\N	2026-09-04 09:26:06.484955	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1e91940c-40d9-4cfd-9f12-d94405861c3e	fishcap_001	49.63	\N	\N	2026-09-04 09:27:10.57104	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f60b12ef-2a8a-4a7d-9420-6d47f084f529	fishcap_001	48.19	\N	\N	2026-09-04 09:28:11.377264	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a441782a-1d4c-4f7c-98f4-375c5a96d37e	fishcap_001	46.94	\N	\N	2026-09-04 09:29:11.406698	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e10322d2-439b-40d1-841f-e8d34fae04d7	fishcap_001	45.50	\N	\N	2026-09-04 09:30:11.392152	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4f36109e-b4c0-44ce-9624-c3f655a5ca31	fishcap_001	44.25	\N	\N	2026-09-04 09:31:11.464795	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9da1e905-b2a3-4a37-8479-7b04534e0a6d	fishcap_001	43.06	\N	\N	2026-09-04 09:32:11.569667	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bf1590e6-ba9c-41f0-a0b2-73469dd20ea2	fishcap_001	42.19	\N	\N	2026-09-04 09:33:12.595638	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
22f174ec-2d81-4273-8eda-1fd8e9e66e2e	fishcap_001	41.19	\N	\N	2026-09-04 09:34:13.218695	0.40	f	0.00	0.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
13187606-e85b-423a-8196-31900ac8a3dd	fishcap_001	40.25	\N	\N	2026-09-04 09:35:12.897544	8.80	f	0.00	8.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2fe19fbf-0f03-4c40-b152-de6365331202	fishcap_001	39.44	\N	\N	2026-09-04 09:36:12.425265	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
633639b9-c81b-4ae2-a8ed-4667ff7c0422	fishcap_001	38.75	\N	\N	2026-09-04 09:37:13.44485	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1f11ad3d-a6ff-43d7-bb23-7e536c1afbf4	fishcap_001	38.13	\N	\N	2026-09-04 09:38:13.172996	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
581040af-6fd8-465f-ba03-6faff0e75bb5	fishcap_001	37.50	\N	\N	2026-09-04 09:39:13.203856	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f20f0147-fb08-4221-8126-fa320fc10805	fishcap_001	36.88	\N	\N	2026-09-04 09:40:13.20867	0.20	f	0.00	0.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f048aa6f-89e4-434e-bfb9-458f4c2776ec	fishcap_001	36.31	\N	\N	2026-09-04 09:41:13.233606	2.60	f	0.00	2.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a215358a-364e-4662-887d-8c6a7152a21b	fishcap_001	35.75	\N	\N	2026-09-04 09:42:13.27184	11.80	f	0.00	11.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
08ef0118-12c8-42ed-bb78-78256029f827	fishcap_001	35.31	\N	\N	2026-09-04 09:43:13.28025	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c113a749-cd70-469e-b9c5-b18feb9daff2	fishcap_001	34.88	\N	\N	2026-09-04 09:44:13.958843	0.40	f	0.00	0.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
49bca07d-4642-4648-97e8-74c8478ff838	fishcap_001	34.44	\N	\N	2026-09-04 09:45:14.783165	6.00	f	0.00	6.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
87fe10d4-0cef-49fc-9c03-e0a9e2757a62	fishcap_001	34.00	\N	\N	2026-09-04 09:46:15.782725	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b441a0c0-da14-40bf-ac4b-272fad7416be	fishcap_001	33.63	\N	\N	2026-09-04 09:47:14.971166	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9dff63d5-489f-4746-b514-d2dda0c9c71a	fishcap_001	33.25	\N	\N	2026-09-04 09:48:14.999581	3.00	f	0.00	3.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
438220c3-f4c7-4011-ba0b-274df1511899	fishcap_001	32.94	\N	\N	2026-09-04 09:49:15.018181	5.60	f	0.00	5.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7f9d2ef3-72cb-4eec-8456-0c58fd734e40	fishcap_001	32.63	\N	\N	2026-09-04 09:50:15.209535	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7c722d9a-4a68-43f4-8397-614811c9a0af	fishcap_001	32.38	\N	\N	2026-09-04 09:51:15.241574	8.60	f	0.00	8.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
88b5e103-0fd8-4dbf-aaef-e43b45bdc2c9	fishcap_001	32.06	\N	\N	2026-09-04 09:52:15.402103	2.00	f	0.00	2.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1d4e037f-d307-4d13-8acf-b3087c0ad2a3	fishcap_001	31.81	\N	\N	2026-09-04 09:53:15.401967	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ea8db905-87f3-4367-afb8-e4ac965edae8	fishcap_001	31.56	\N	\N	2026-09-04 09:54:15.870035	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6d26dace-fc0f-4c39-8110-2963aba5f9d8	fishcap_001	31.31	\N	\N	2026-09-04 09:55:15.865827	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bde79f23-0328-43d1-83fd-cd2eec5182fd	fishcap_001	31.06	\N	\N	2026-09-04 09:56:15.907224	1.00	f	0.00	1.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ecc5bfcd-983c-475e-ba89-2fcbd41ca30f	fishcap_001	30.88	\N	\N	2026-09-04 09:57:16.350298	4.20	f	0.00	4.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a82fadbd-6c66-4b86-a7ee-ef3e9a2230ed	fishcap_001	30.31	\N	\N	2026-09-07 06:08:12.718385	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2baf7ff1-a3fd-4c1b-9979-ed4aefd2f0d1	fishcap_001	30.25	\N	\N	2026-09-07 06:09:12.81199	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fcde0593-ca9b-4dc3-b88f-83fc3dae186b	fishcap_001	30.13	\N	\N	2026-09-07 06:10:12.81428	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b88e5753-a264-4e9d-84c3-913c4db45e91	fishcap_001	30.13	\N	\N	2026-09-07 06:11:12.884717	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
11b23e7e-f364-4aa8-83cd-bbc32215ba4e	fishcap_001	30.06	\N	\N	2026-09-07 06:12:12.894496	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
acd02aba-19a0-4d29-ab6f-3ad3ea0675ad	fishcap_001	30.06	\N	\N	2026-09-07 06:13:12.917283	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1e2df85a-1ccd-4ab0-b688-bdc263ee6377	fishcap_001	30.00	\N	\N	2026-09-07 06:14:13.621838	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b714514d-b1fa-4546-94e5-f4fa14fe6520	fishcap_001	29.94	\N	\N	2026-09-07 06:15:13.83547	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
017cd573-05c4-4f3c-8e62-6213dd0407e0	fishcap_001	29.94	\N	\N	2026-09-07 06:16:13.041243	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9eae49db-ba84-4768-841d-cc611a81b1fa	fishcap_001	29.94	\N	\N	2026-09-07 06:17:13.060188	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4cdf1558-fc89-4f6e-8915-d3ed2c2cf7bd	fishcap_001	-127.00	\N	\N	2026-09-07 06:57:48.741673	1484.80	f	0.00	1484.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9bf4ef4f-f15d-4a3c-b4d5-e9ce217f432f	fishcap_001	-127.00	\N	\N	2026-09-07 06:58:48.524061	1483.20	f	0.00	1483.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
31322503-8c31-46aa-a960-dc89c49ba89b	fishcap_001	-127.00	\N	\N	2026-09-07 06:59:47.920565	1479.20	f	0.00	1479.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7434f5c5-7dc7-474e-b42d-973de9e63176	fishcap_001	-127.00	\N	\N	2026-09-07 07:00:48.7466	1480.60	f	0.00	1480.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ba07337a-1ee3-4b02-b1cd-708691cf68ae	fishcap_001	-127.00	\N	\N	2026-09-07 07:01:49.378465	1473.20	f	0.00	1473.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2ce2647c-efae-44e9-9efe-a075be5e7e08	fishcap_001	-127.00	\N	\N	2026-09-07 07:02:50.626193	1479.00	f	0.00	1479.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
109c5e4c-9b04-42fa-89be-6ebffb69b7e1	fishcap_001	-127.00	\N	\N	2026-09-07 07:03:49.067138	1478.60	f	0.00	1478.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c4f8baf9-1bc5-434e-b0f4-99d159d46385	fishcap_001	-127.00	\N	\N	2026-09-07 07:04:48.569274	1483.40	f	0.00	1483.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
88569461-e7c9-427e-ab63-3468e320fdd7	fishcap_001	-127.00	\N	\N	2026-09-07 07:05:49.075056	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a6cb4563-a548-426e-bcc6-adaf284466cb	fishcap_001	-127.00	\N	\N	2026-09-07 07:07:04.691896	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0e56749a-1d00-455a-8e25-ace4cb3e84aa	fishcap_001	-127.00	\N	\N	2026-09-07 07:07:57.112089	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f281db50-4d73-437b-b9f2-75428a639a24	fishcap_001	-127.00	\N	\N	2026-09-07 07:08:49.000975	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
395afa67-e37b-4453-8aac-fcfa5ede5cb3	fishcap_001	-127.00	\N	\N	2026-09-07 07:11:49.605722	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0524c9de-2b8c-4938-a48a-b9245783e015	fishcap_001	-127.00	\N	\N	2026-09-07 07:12:50.136132	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0a90854f-879b-4c70-a1ec-566c5c0fed6a	fishcap_001	-127.00	\N	\N	2026-09-07 07:13:51.740993	1479.40	f	0.00	1479.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3b1db205-7d42-4827-ba0c-d670fe816613	fishcap_001	-127.00	\N	\N	2026-09-07 07:14:51.010223	1475.60	f	0.00	1475.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
57d7fbd8-ee44-4434-b5c7-6f4b5e93dee9	fishcap_001	-127.00	\N	\N	2026-09-07 07:15:50.693332	1492.60	f	0.00	1492.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d84d7b7a-065e-45ea-a12a-5e237b0cc3f4	fishcap_001	-127.00	\N	\N	2026-09-07 07:16:50.420573	1480.60	f	0.00	1480.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
42eb1d7e-f34b-46e0-a0e3-5175778d574c	fishcap_001	-127.00	\N	\N	2026-09-07 07:17:51.318691	1484.40	f	0.00	1484.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
10ad085c-8ab3-4968-9b12-bea57e33a5a2	fishcap_001	-127.00	\N	\N	2026-09-07 07:18:50.994222	1473.00	f	0.00	1473.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2bdc8f07-5124-40f3-9fe0-b74213961929	fishcap_001	-127.00	\N	\N	2026-09-07 07:19:51.328149	1487.20	f	0.00	1487.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
49e2234e-1add-4e7e-8b3d-0e5767a626e4	fishcap_001	-127.00	\N	\N	2026-09-07 07:20:51.088143	1474.80	f	0.00	1474.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
00c9f1bb-4004-4d8d-88e3-ce28d4e481a8	fishcap_001	-127.00	\N	\N	2026-09-07 07:21:51.14347	1485.00	f	0.00	1485.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9b80ca92-345f-48e9-a5f2-30775cd5a8bd	fishcap_001	-127.00	\N	\N	2026-09-07 07:22:55.21506	1483.20	f	0.00	1483.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3789c9c3-d0d6-4d38-a67b-b3efcab82ea1	fishcap_001	-127.00	\N	\N	2026-09-07 07:23:51.228978	1475.40	f	0.00	1475.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a897dee8-fa10-41c1-8f10-f27244854301	fishcap_001	-127.00	\N	\N	2026-09-07 07:24:52.005479	1484.80	f	0.00	1484.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a147fa31-7c4f-4573-a346-fb8835ffe139	fishcap_001	-127.00	\N	\N	2026-09-07 07:25:52.955019	1485.60	f	0.00	1485.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b24f3cb5-488c-423c-b7db-6c5be7334122	fishcap_001	-127.00	\N	\N	2026-09-07 07:26:52.566701	1475.20	f	0.00	1475.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0c10ee20-2083-4165-b117-048fc951ae55	fishcap_001	-127.00	\N	\N	2026-09-07 07:27:53.025416	1479.60	f	0.00	1479.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
71474a76-8c58-4a12-9e0f-cf111a8c5812	fishcap_001	-127.00	\N	\N	2026-09-07 07:28:53.402412	1476.60	f	0.00	1476.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4f61e984-d812-495f-8088-f33992098269	fishcap_001	-127.00	\N	\N	2026-09-07 07:29:53.452898	1484.20	f	0.00	1484.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9f516164-dd09-4e6d-8181-b4cf99f00246	fishcap_001	-127.00	\N	\N	2026-09-07 07:30:53.863935	1481.40	f	0.00	1481.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
521b3069-cdad-4d8e-b926-48e45b4cdd50	fishcap_001	-127.00	\N	\N	2026-09-07 07:31:53.874843	1474.60	f	0.00	1474.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7fab3acb-0c69-4cda-b15d-961f2ed9b428	fishcap_001	-127.00	\N	\N	2026-09-07 07:32:54.470409	1472.40	f	0.00	1472.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0d828ed6-4113-46cf-97e4-867776b89ec1	fishcap_001	-127.00	\N	\N	2026-09-07 07:33:53.693069	1469.80	f	0.00	1469.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7311f753-0809-4c7e-a161-bfec7e6997d7	fishcap_001	-127.00	\N	\N	2026-09-07 07:34:54.483466	1486.80	f	0.00	1486.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
46fee03c-a58d-46a5-825d-e3ca8f6ac004	fishcap_001	-127.00	\N	\N	2026-09-07 07:35:54.675195	1478.60	f	0.00	1478.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
24ca452d-e2bf-4588-be91-a98ab292fe92	fishcap_001	-127.00	\N	\N	2026-09-07 07:36:54.699514	1489.00	f	0.00	1489.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1158d74c-d829-47a6-aa24-6edad2aafc80	fishcap_001	-127.00	\N	\N	2026-09-07 07:37:54.802112	1480.00	f	0.00	1480.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4346a2bb-b98b-4577-9464-cdb7a5006b74	fishcap_001	-127.00	\N	\N	2026-09-07 07:38:54.918101	1475.60	f	0.00	1475.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
61de8c69-eff3-45d3-a12d-468fbbd085c1	fishcap_001	-127.00	\N	\N	2026-09-07 07:39:53.943174	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c53d88f0-f7b2-40ca-82ab-c70af4f9f990	fishcap_001	-127.00	\N	\N	2026-09-07 07:40:54.742345	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
71578353-8210-4790-8104-320c479ed285	fishcap_001	-127.00	\N	\N	2026-09-07 07:41:54.144128	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bea1caa8-e9b0-4a02-b285-a5623052e438	fishcap_001	-127.00	\N	\N	2026-09-07 07:42:55.034262	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b1046a92-46dd-4277-b0bf-a01e7c200173	fishcap_001	-127.00	\N	\N	2026-09-07 07:43:54.996969	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
714ce248-84c8-455e-a4e2-c5539890c064	fishcap_001	-127.00	\N	\N	2026-09-07 07:44:54.483115	1485.80	f	0.00	1485.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2a32684a-d506-4683-b5a7-e33977fc79f6	fishcap_001	-127.00	\N	\N	2026-09-07 07:45:54.542174	1475.00	f	0.00	1475.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
54184d35-a661-45b0-a94f-2716deef64d4	fishcap_001	-127.00	\N	\N	2026-09-07 07:46:54.58843	1482.00	f	0.00	1482.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
69a860eb-e271-4803-989a-84ac51225cab	fishcap_001	-127.00	\N	\N	2026-09-07 07:47:55.375704	1481.20	f	0.00	1481.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
88201496-aaba-4369-9500-6ebca07bb1d6	fishcap_001	-127.00	\N	\N	2026-09-07 07:48:55.415645	1492.60	f	0.00	1492.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d177592b-565e-4cb5-ac55-fe96e03fb7ce	fishcap_001	-127.00	\N	\N	2026-09-07 07:49:55.472115	1479.60	f	0.00	1479.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b41f89e8-8cae-421c-82b6-a8deec700c04	fishcap_001	-127.00	\N	\N	2026-09-07 07:50:56.05007	1487.60	f	0.00	1487.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6b7b13bc-b1b0-409e-b920-5e19befd14b3	fishcap_001	-127.00	\N	\N	2026-09-07 07:51:55.554998	1478.20	f	0.00	1478.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ed2abe52-b60c-46d4-ada7-71072e337df0	fishcap_001	-127.00	\N	\N	2026-09-07 07:52:56.359908	1484.60	f	0.00	1484.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2a0d5a95-733c-4e62-ad66-41b218b9c85e	fishcap_001	-127.00	\N	\N	2026-09-07 07:53:56.447414	1480.00	f	0.00	1480.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ba22eaef-34f7-4697-992f-83829ddb7d8f	fishcap_001	-127.00	\N	\N	2026-09-07 07:54:57.292276	1465.40	f	0.00	1465.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1655211c-4eca-44d7-adc8-7bf61a66c830	fishcap_001	-127.00	\N	\N	2026-09-07 07:55:57.293047	1485.20	f	0.00	1485.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e2013053-d20c-41eb-b9da-304586b8649b	fishcap_001	-127.00	\N	\N	2026-09-07 07:56:57.100235	1490.00	f	0.00	1490.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
94ee7323-82e5-45ec-8906-a1d82fd3bea9	fishcap_001	-127.00	\N	\N	2026-09-07 07:57:56.561349	1491.60	f	0.00	1491.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
79c4ab0e-306c-4da7-bf14-384f5fc8b4c2	fishcap_001	-127.00	\N	\N	2026-09-07 07:58:57.284819	1478.80	f	0.00	1478.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3ce81c9c-60e6-42a0-bca4-09869369384a	fishcap_001	-127.00	\N	\N	2026-09-07 07:59:58.375364	1478.00	f	0.00	1478.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6c00088c-e279-41c8-b103-d62651072960	fishcap_001	-127.00	\N	\N	2026-09-07 08:00:58.955496	1484.20	f	0.00	1484.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f79909bd-af77-46be-bca4-23a9bfd44c54	fishcap_001	-127.00	\N	\N	2026-09-07 08:01:59.029607	1483.20	f	0.00	1483.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8b904332-5a45-448f-834e-9640657141e5	fishcap_001	-127.00	\N	\N	2026-09-07 08:02:58.101822	1488.40	f	0.00	1488.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
802d24d7-9cd2-4268-87dc-0da294c2223c	fishcap_001	-127.00	\N	\N	2026-09-07 08:03:58.960769	1484.20	f	0.00	1484.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
06cc549d-6d53-4e72-9b3b-b5564d740194	fishcap_001	-127.00	\N	\N	2026-09-07 08:04:58.77848	1483.40	f	0.00	1483.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a01c788e-0181-4e73-ba93-63b17e0d47fe	fishcap_001	-127.00	\N	\N	2026-09-07 08:08:01.065443	1488.40	f	0.00	1488.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c0497a79-55f4-4282-8a95-f68f46cd4987	fishcap_001	-127.00	\N	\N	2026-09-07 08:08:58.826152	1481.00	f	0.00	1481.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
61a4cbf8-89d2-4ee1-abe6-7a72d949ec40	fishcap_001	-127.00	\N	\N	2026-09-07 08:09:59.867894	1482.40	f	0.00	1482.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a964a5b4-8639-40a7-8cdd-7e509d663223	fishcap_001	-127.00	\N	\N	2026-09-07 08:10:59.053341	1482.60	f	0.00	1482.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ded31c56-5c91-4fbb-a7e6-b677e353cd30	fishcap_001	-127.00	\N	\N	2026-09-07 08:11:59.870681	1489.00	f	0.00	1489.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bb96b4dc-2911-455f-81b1-6048ea3abcdb	fishcap_001	-127.00	\N	\N	2026-09-07 08:12:59.07585	1476.00	f	0.00	1476.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
81a0ce03-f0ec-4887-91e3-25bb308ecfca	fishcap_001	-127.00	\N	\N	2026-09-07 08:14:00.095024	1474.80	f	0.00	1474.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f37b11cc-c812-49fc-b485-a6839d3095d8	fishcap_001	-127.00	\N	\N	2026-09-07 08:14:59.166909	1476.60	f	0.00	1476.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
11c57746-35aa-4c2b-ab6e-2cbd9a7494fa	fishcap_001	-127.00	\N	\N	2026-09-07 08:15:59.196578	1474.60	f	0.00	1474.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e412c9ff-96f2-4341-8792-5a258f75218b	fishcap_001	-127.00	\N	\N	2026-09-07 08:16:59.914995	1478.60	f	0.00	1478.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7c425beb-463e-46c5-8f5b-d9285032f1fb	fishcap_001	-127.00	\N	\N	2026-09-07 08:17:59.223213	1478.00	f	0.00	1478.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6f693ac8-243d-4d07-ac2d-4827b3a81cb1	fishcap_001	-127.00	\N	\N	2026-09-07 08:19:00.735869	1486.80	f	0.00	1486.80	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bdad6ca0-0e3b-4e1a-bec5-27843f4012dc	fishcap_001	-127.00	\N	\N	2026-09-07 08:19:59.93335	1491.20	f	0.00	1491.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2879ec3d-0d62-497b-9953-99051c505174	fishcap_001	-127.00	\N	\N	2026-09-07 08:21:00.552084	1471.00	f	0.00	1471.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0e70a701-857c-42ad-a1b1-521dcef25ea7	fishcap_001	-127.00	\N	\N	2026-09-07 08:22:01.479726	1481.40	f	0.00	1481.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
93bd9ccc-aa14-4534-81c9-93e9c5aa760c	fishcap_001	-127.00	\N	\N	2026-09-07 08:23:01.657903	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
28cee021-1c75-460a-806e-290272517ab4	fishcap_001	-127.00	\N	\N	2026-09-07 08:24:00.784559	1485.00	f	0.00	1485.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ff03d2d2-c76a-419f-8b5e-048f24599189	fishcap_001	-127.00	\N	\N	2026-09-07 08:25:01.481849	1486.60	f	0.00	1486.60	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8fb1fd20-fcdf-478e-b971-fb681d6a1834	fishcap_001	-127.00	\N	\N	2026-09-07 08:26:01.731655	1473.40	f	0.00	1473.40	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
cfdae16d-d391-45a3-bcb5-ea0ff0be29d4	fishcap_001	-127.00	\N	\N	2026-09-07 08:27:02.151347	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0c993ccc-b236-4c45-83e1-741910c2ecdc	fishcap_001	-127.00	\N	\N	2026-09-07 08:28:02.140597	1480.20	f	0.00	1480.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e69af7d7-d403-43de-ab12-6d1171e84154	fishcap_001	-127.00	\N	\N	2026-09-07 08:29:03.058672	1513.20	f	0.00	1513.20	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
cbfb18ff-a1e4-4fa2-998e-9a82208aa83f	fishcap_001	-127.00	\N	\N	2026-09-07 08:30:03.681721	1523.00	f	0.00	1523.00	f	\N	4408c859-fa79-42d6-bcaa-53443d155d95
48c632e0-3d64-43ae-878e-0da9e343c5f0	fishcap_001	27.75	\N	\N	2026-09-07 08:38:31.995581	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1c2efc39-b47f-436f-88b9-91df548e3f5c	fishcap_001	27.75	\N	\N	2026-09-07 08:39:31.591427	1.00	f	0.00	1.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
19509619-0ff7-4b20-837d-afdb5f3bf033	fishcap_001	27.81	\N	\N	2026-09-07 08:40:31.598125	8.40	f	0.00	8.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
79680f5e-55db-4d7c-a65c-90cbc23644a8	fishcap_001	27.81	\N	\N	2026-09-07 08:41:31.624138	8.60	f	0.00	8.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fcdc63b7-0604-44b5-b1cb-d36009079e53	fishcap_001	27.81	\N	\N	2026-09-07 08:42:31.468575	16.60	f	0.00	16.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7aee89a2-fc21-410d-9ab0-e69079bac468	fishcap_001	27.81	\N	\N	2026-09-07 08:43:31.958976	2.40	f	0.00	2.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c7d64840-b1a7-4b96-8e13-1d1a1b0af969	fishcap_001	27.81	\N	\N	2026-09-07 08:44:31.624808	18.00	f	0.00	18.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bd86ee21-13ad-4d91-bdaa-6fca4804b27c	fishcap_001	27.81	\N	\N	2026-09-07 08:45:30.768356	6.60	f	0.00	6.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
494fd08e-6606-41fc-b871-f8d40f27eec0	fishcap_001	27.81	\N	\N	2026-09-07 08:46:31.443576	4.40	f	0.00	4.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8000731e-74f4-48cf-8233-bc48c3c8ccf0	fishcap_001	27.81	\N	\N	2026-09-07 08:47:30.862759	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
51e92299-ec89-4acf-a4b4-c703be7a2de4	fishcap_001	27.81	\N	\N	2026-09-07 08:48:31.475201	1.60	f	0.00	1.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2e6dd3cd-2401-40a9-9683-e47231969d32	fishcap_001	27.81	\N	\N	2026-09-07 08:49:31.261616	0.40	f	0.00	0.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d2d760c9-b20c-4490-8a34-0ef089940bad	fishcap_001	27.81	\N	\N	2026-09-07 08:50:31.819663	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
26ad387c-02d8-40d9-9db8-0e8007d623cf	fishcap_001	27.81	\N	\N	2026-09-07 08:51:31.881074	8.60	f	0.00	8.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
367d35d1-e257-47b3-b0e7-d14a8181c7c4	fishcap_001	27.81	\N	\N	2026-09-07 08:52:31.277232	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
26042d1f-5122-419c-9293-23e22e02a48a	fishcap_001	27.81	\N	\N	2026-09-07 08:53:31.997388	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6725302a-41a0-4cfa-80ac-79fec596062b	fishcap_001	27.88	\N	\N	2026-09-07 08:54:32.264936	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
00f87534-07c2-464d-a634-e1841979b225	fishcap_001	27.81	\N	\N	2026-09-07 08:55:32.324431	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
92364705-d727-4368-a0f8-c97a676f353e	fishcap_001	27.81	\N	\N	2026-09-07 08:56:32.500944	4.00	f	0.00	4.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d335cebb-c2df-4efe-a685-589b6ec9701c	fishcap_001	27.81	\N	\N	2026-09-07 08:57:32.549061	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bbb5ee20-dd54-4781-bbd9-4dd851140415	fishcap_001	27.81	\N	\N	2026-09-07 08:58:33.16783	3.40	f	0.00	3.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d888ec60-6673-4969-881c-c2107a18b50d	fishcap_001	27.81	\N	\N	2026-09-07 08:59:32.966698	1.60	f	0.00	1.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1088a2cb-3c52-43be-9847-5e1560a38612	fishcap_001	27.81	\N	\N	2026-09-07 09:00:33.670699	10.60	f	0.00	10.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
14e304f5-811b-44cf-aeee-fb42ce2bd50f	fishcap_001	27.81	\N	\N	2026-09-07 09:01:34.105872	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e438a186-03d6-403a-9a68-59cf93429ba7	fishcap_001	27.81	\N	\N	2026-09-07 09:02:33.784575	5.80	f	0.00	5.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9388b9a2-a2bf-4cfb-90ef-d927df03314d	fishcap_001	27.81	\N	\N	2026-09-07 09:03:33.868232	2.60	f	0.00	2.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9bf7541f-2e77-47f2-90b6-c909abf7873c	fishcap_001	27.81	\N	\N	2026-09-07 09:04:33.886069	8.80	f	0.00	8.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f02a6142-0141-44d5-b275-8a4355b4639b	fishcap_001	27.80	\N	\N	2026-09-07 09:05:21.679474	4.40	f	0.00	4.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b5f832c7-a14d-42cd-b88d-419dad2ae41c	fishcap_001	38.50	\N	\N	2026-09-07 09:05:21.775494	\N	\N	\N	\N	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a2086e0b-13db-4cd4-aa51-0c489814b787	fishcap_001	27.75	\N	\N	2026-09-07 09:05:34.284436	1.00	f	0.00	1.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
51e39288-1bee-4f4e-874b-87abd7a1c0b7	fishcap_001	27.75	\N	\N	2026-09-07 09:06:34.047354	3.60	f	0.00	3.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7d5176cd-b7fa-4167-a195-b419d27ab1b0	fishcap_001	27.81	\N	\N	2026-09-07 09:07:34.879342	4.00	f	0.00	4.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
25b176c9-7225-4fb2-a8da-040ab07a9578	fishcap_001	27.75	\N	\N	2026-09-07 09:08:34.735432	8.20	f	0.00	8.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a971e864-0542-43a5-916c-6806e086f1c5	fishcap_001	27.75	\N	\N	2026-09-07 09:09:35.289666	2.00	f	0.00	2.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b1cfdce2-1f71-49dd-ba68-e9a3d113f234	fishcap_001	27.69	\N	\N	2026-09-07 09:10:34.768127	3.00	f	0.00	3.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5589d6e1-b511-47bd-b564-9ac353fda8a9	fishcap_001	27.75	\N	\N	2026-09-07 09:11:34.895201	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b43cde83-315a-4d24-85e3-d6f5bab2dff5	fishcap_001	27.69	\N	\N	2026-09-07 09:12:35.77981	10.00	f	0.00	10.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ce0f1392-35ba-4160-980a-8588a911b5a8	fishcap_001	27.69	\N	\N	2026-09-07 09:13:35.925423	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
604d726c-aa66-4957-bd60-4ea68c41fe79	fishcap_001	27.63	\N	\N	2026-09-07 09:14:35.930116	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0fda3d60-3dc5-4307-b615-35ae19618ef9	fishcap_001	27.63	\N	\N	2026-09-07 09:15:35.531543	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
542d4245-61d6-4012-835a-1a25f7034812	fishcap_001	27.56	\N	\N	2026-09-07 09:16:36.354344	11.60	f	0.00	11.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
36924426-4313-4141-947a-a7c3cc4c9797	fishcap_001	27.56	\N	\N	2026-09-07 09:17:36.359895	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0ffe414c-faee-4bf7-8ab0-abb12f2e2ae7	fishcap_001	27.50	\N	\N	2026-09-07 09:18:36.060239	6.80	f	0.00	6.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fafc1943-71c3-457f-b97d-bee5dc9041be	fishcap_001	27.44	\N	\N	2026-09-07 09:19:36.025023	4.20	f	0.00	4.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
20c8e471-c8cd-4159-93c3-eeafabbd7597	fishcap_001	27.44	\N	\N	2026-09-07 09:21:36.204532	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
800cabf3-c12c-4127-a2f1-9a848709a9d7	fishcap_001	27.44	\N	\N	2026-09-07 09:22:36.610937	4.80	f	0.00	4.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5ea0eabb-164e-430f-84e8-17583f77f935	fishcap_001	27.44	\N	\N	2026-09-07 09:23:37.188471	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f2f12cdb-416b-4f6b-a071-498fb6a02b8b	fishcap_001	27.38	\N	\N	2026-09-07 09:24:37.38604	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2d7fd849-2fe8-4339-9fab-78978d32f888	fishcap_001	27.38	\N	\N	2026-09-07 09:25:36.572789	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
71dbf491-d52f-4683-8430-2d17bff86c15	fishcap_001	27.38	\N	\N	2026-09-07 09:26:36.601644	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e6dff3d8-82dc-42b9-8737-0379fcec8c4f	fishcap_001	27.38	\N	\N	2026-09-07 09:27:36.657184	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
73f41aa9-364e-4720-abed-7b8b0b4e3448	fishcap_001	27.38	\N	\N	2026-09-07 09:28:37.601313	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d306b6ec-5580-476d-ba78-db30544f03c7	fishcap_001	27.31	\N	\N	2026-09-07 09:29:37.646273	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
394a9cf3-b169-4998-a366-13fae88d5728	fishcap_001	27.31	\N	\N	2026-09-07 09:30:37.658047	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1a462474-1e5d-49f6-9191-6d504a291fe2	fishcap_001	27.31	\N	\N	2026-09-07 09:31:37.860534	0.60	f	0.00	0.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6594b7e7-5acd-4be7-80c8-98301147742e	fishcap_001	27.31	\N	\N	2026-09-07 09:32:37.44623	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a4f1437f-cf85-428f-9c4f-e32a45c4143e	fishcap_001	27.31	\N	\N	2026-09-07 09:33:37.535368	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2734968d-1c4b-4819-b53a-52f9dfe6b232	fishcap_001	27.25	\N	\N	2026-09-07 09:34:37.724922	0.80	f	0.00	0.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d5579d7f-a40a-485d-bde9-b7a408cdbb4a	fishcap_001	27.31	\N	\N	2026-09-07 09:35:37.731788	0.20	f	0.00	0.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e8d73fce-93a5-4404-ad67-6e6c6cc79b24	fishcap_001	27.63	\N	\N	2026-09-07 09:36:37.542075	5.80	f	0.00	5.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
eb59ffc4-2dc6-4b6a-8870-d598b6cab3b0	fishcap_001	28.00	\N	\N	2026-09-07 09:37:38.540585	2.40	f	0.00	2.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e4ea98c9-071c-493a-8937-7ec5713cb422	fishcap_001	28.19	\N	\N	2026-09-07 09:38:37.942311	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7c14eae0-277d-4739-abb7-6e8451877204	fishcap_001	2.44	\N	\N	2026-09-07 09:39:38.534763	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d63fe5e7-50bd-4663-aa82-85786391e9a6	fishcap_001	2.50	\N	\N	2026-09-07 09:40:37.959131	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f5a54c68-6551-4499-a226-2d6ac8e4735b	fishcap_001	2.75	\N	\N	2026-09-07 09:41:38.616067	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
df1ce639-bca1-48d4-86c0-38daca57c6cf	fishcap_001	2.94	\N	\N	2026-09-07 09:42:38.604421	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
478f0f8b-163d-41a9-ada7-c87802af3c5a	fishcap_001	3.25	\N	\N	2026-09-07 09:43:38.755668	2.80	f	0.00	2.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
177b0191-3680-4df3-adbb-a6aa3e5a9990	fishcap_001	26.94	\N	\N	2026-09-08 02:50:39.610999	13.00	f	0.00	13.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b2f690ca-3b57-4e2a-800c-c33118645044	fishcap_001	26.94	\N	\N	2026-09-08 02:51:40.322137	14.00	f	0.00	14.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
94e36e19-b08a-46a1-a15c-4ee01073836a	fishcap_001	26.94	\N	\N	2026-09-08 02:52:41.058974	5.00	f	0.00	5.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3cf03621-bf74-4bab-b417-58bf47403324	fishcap_001	26.94	\N	\N	2026-09-08 02:53:40.932484	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2c592557-61ee-4139-a0ba-54b533497902	fishcap_001	26.88	\N	\N	2026-09-08 02:54:40.616569	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
40ae74d6-fcf6-4386-8f4b-2bc0a4f2d580	fishcap_001	26.88	\N	\N	2026-09-08 02:55:40.933378	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ec316749-7191-4c0b-aba7-00fdc04334c7	fishcap_001	26.94	\N	\N	2026-09-08 02:56:40.937204	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
db28da87-3395-4ff5-a760-3d966f539b02	fishcap_001	26.94	\N	\N	2026-09-08 02:57:40.552131	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9ecfbf36-c14e-4bac-b600-3f212ebca088	fishcap_001	26.94	\N	\N	2026-09-08 02:58:40.659288	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
aecdf56c-ed29-4151-a00c-00c0abb4ef98	fishcap_001	26.94	\N	\N	2026-09-08 02:59:40.855798	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a32ea48b-5500-49ae-a181-f76f0be13b22	fishcap_001	26.94	\N	\N	2026-09-08 03:00:40.680743	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d1b42d28-313a-461f-91c5-66f88fead8b3	fishcap_001	26.94	\N	\N	2026-09-08 03:01:40.691483	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0cd5b868-b26e-4520-b85b-e11b6dad7d9e	fishcap_001	26.94	\N	\N	2026-09-08 03:02:40.779003	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4a9998af-51a8-4258-836c-f280db65bf1e	fishcap_001	26.94	\N	\N	2026-09-08 03:03:40.79093	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d8693158-06e1-4120-be1b-df95b8bbf47c	fishcap_001	26.94	\N	\N	2026-09-08 03:04:40.793997	17.40	f	0.00	17.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
279e3586-e611-422a-9669-ee2597c43ad6	fishcap_001	27.31	\N	\N	2026-09-08 03:27:42.58101	12.20	f	0.00	12.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
463031d7-5405-449f-805a-a61d41bd6754	fishcap_001	27.25	\N	\N	2026-09-08 03:28:41.454112	19.60	f	0.00	19.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
94c4b921-8078-4698-8649-19f1216b7c1b	fishcap_001	27.31	\N	\N	2026-09-08 03:29:41.605506	4.80	f	0.00	4.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
20fd940d-ebe6-468b-81fb-de8c069c9dae	fishcap_001	27.31	\N	\N	2026-09-08 03:30:41.606902	19.00	f	0.00	19.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
158ab1c5-1325-48a3-b706-5157a8fbd11e	fishcap_001	27.31	\N	\N	2026-09-08 03:31:41.623042	10.40	f	0.00	10.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7d40ea49-e207-49c9-ba17-7303d9ebe484	fishcap_001	27.31	\N	\N	2026-09-08 03:32:42.038929	5.00	f	0.00	5.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7470a69d-c506-476e-a0be-ed274d639f31	fishcap_001	27.31	\N	\N	2026-09-08 03:33:42.088116	8.20	f	0.00	8.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c2ed23bd-b55c-479b-8664-0ab317ee6a0f	fishcap_001	27.31	\N	\N	2026-09-08 03:34:42.063593	7.00	f	0.00	7.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
61d9ef0b-c8a5-4ec1-a8fc-e81459402e18	fishcap_001	28.00	4.50	2.00	2026-09-08 04:29:43.021748	\N	\N	\N	\N	\N	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fbd4cd31-9e23-4c21-b4ed-ed90c6b975d8	fishcap_001	28.00	4.60	2.10	2026-09-08 04:29:53.926496	\N	\N	\N	\N	\N	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c2a3e172-13b1-4fe7-bdf8-9b24de5eda90	fishcap_001	27.00	\N	\N	2026-09-08 07:38:52.249935	2.20	f	0.00	2.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3bfeda66-1c5d-434a-9a6e-ee8d55e3c4c2	fishcap_001	27.00	\N	\N	2026-09-08 07:39:52.294113	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ff94ee85-a538-4da1-9c2e-f0f3754f09c3	fishcap_001	26.94	\N	\N	2026-09-08 07:40:52.3502	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
59516a69-4446-4eb0-a8dc-f8b939806543	fishcap_001	26.88	\N	\N	2026-09-08 07:41:52.361597	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c9b375e5-72b6-42b5-ba57-7b996ff94d0e	fishcap_001	26.94	\N	\N	2026-09-08 07:42:00.375703	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
95f4d931-e693-49f5-9820-62157943c609	fishcap_001	26.88	\N	\N	2026-09-08 07:42:53.175902	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
59e2d6f7-b0d2-4e6f-8dbd-f87dc394011b	fishcap_001	26.94	\N	\N	2026-09-08 07:43:53.412029	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2317e791-b0d1-4ea4-8be9-7c1d9df2db3b	fishcap_001	26.94	\N	\N	2026-09-08 07:44:52.700941	9.00	f	0.00	9.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
60961c10-05e6-4a11-960d-20aa0fe2e83b	fishcap_001	26.94	\N	\N	2026-09-08 07:45:53.071236	4.60	f	0.00	4.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5409ee67-7339-4dc9-b672-3a344e2fcef9	fishcap_001	26.94	\N	\N	2026-09-08 07:46:53.236145	4.40	f	0.00	4.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
34841498-e475-463a-aa51-8d12876b3c40	fishcap_001	26.94	\N	\N	2026-09-08 07:47:53.43794	5.80	f	0.00	5.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fa80ce3a-549d-42e2-b3c8-d0564e74e8f1	fishcap_001	26.88	\N	\N	2026-09-08 07:48:53.05636	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8b3cb441-dad6-4485-b14e-d77797edeec8	fishcap_001	26.88	\N	\N	2026-09-08 07:49:53.666231	1.60	f	0.00	1.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0b7361e7-a861-4990-be17-5d73ebfab9cf	fishcap_001	26.88	\N	\N	2026-09-08 07:50:54.081946	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e812001e-8fd8-4a4f-908e-ba4545c44ed1	fishcap_001	26.81	\N	\N	2026-09-08 07:51:54.699019	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ba1586d6-528b-40ed-8430-28bdb3f1ea5c	fishcap_001	26.81	\N	\N	2026-09-08 07:52:53.686497	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4a6628cd-3260-44b7-be8f-2f19a6ca5eaa	fishcap_001	26.81	\N	\N	2026-09-08 07:53:54.12569	1.80	f	0.00	1.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7afd3612-bab0-44f2-ad95-959bcd3178ae	fishcap_001	26.81	\N	\N	2026-09-08 07:54:53.753862	10.00	f	0.00	10.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
62d86c72-7e58-4d8f-bee2-bfa59ba425f5	fishcap_001	26.81	\N	\N	2026-09-08 07:55:53.705172	2.40	f	0.00	2.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f747f65f-d804-46aa-a9ce-dbc3a61dfef7	fishcap_001	26.69	\N	\N	2026-09-08 08:04:36.249893	0.40	f	0.00	0.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1d178dc7-3424-44ba-a98c-af2d33641b60	fishcap_001	26.69	\N	\N	2026-09-08 08:05:36.363723	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
eabca08b-7a5c-4021-8611-dd3ab5954538	fishcap_001	26.69	\N	\N	2026-09-08 08:06:36.237632	2.60	f	0.00	2.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
375ba557-ec03-4da3-92a7-80dee0f00677	fishcap_001	26.63	\N	\N	2026-09-08 08:07:36.188544	5.40	f	0.00	5.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9c97cd02-604a-4b86-bc81-686ce943c2c5	fishcap_001	26.63	\N	\N	2026-09-08 08:08:36.31463	0.60	f	0.00	0.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
73886553-b492-4681-9fd4-2d03598fb967	fishcap_001	26.56	\N	\N	2026-09-08 08:09:36.845988	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5a456def-338c-4784-972b-b39e63a64fdd	fishcap_001	26.56	\N	\N	2026-09-08 08:10:37.401752	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0e0b30aa-074e-4555-b1df-946f96dbb431	fishcap_001	26.56	\N	\N	2026-09-08 08:11:36.42075	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5a307314-c9f5-49f8-8cdc-cae157939cc8	fishcap_001	26.56	\N	\N	2026-09-08 08:12:37.655851	1.60	f	0.00	1.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e4882db0-abdd-4b16-972b-9af911e6537a	fishcap_001	26.56	\N	\N	2026-09-08 08:13:37.605838	2.60	f	0.00	2.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f6209c41-180e-4ece-b166-e2be635af3e5	fishcap_001	26.56	\N	\N	2026-09-08 08:14:37.060779	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3ff2480b-ae86-4f4b-bd61-a612a734fa71	fishcap_001	26.56	\N	\N	2026-09-08 08:15:37.850929	3.80	f	0.00	3.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
43e6e6a3-b12f-41c5-b7c3-c0e4784d9251	fishcap_001	26.50	\N	\N	2026-09-08 08:16:37.652219	0.20	f	0.00	0.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
899b4abb-92a9-4a22-86f3-688fb26f8339	fishcap_001	26.56	\N	\N	2026-09-08 08:17:37.618857	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
60254646-bb0c-41af-8381-1b5f6fb40874	fishcap_001	26.50	\N	\N	2026-09-08 08:18:37.757345	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4963dd2c-1948-4e6c-bfd6-5709a6d2ff18	fishcap_001	26.50	\N	\N	2026-09-08 08:19:38.664269	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2ada2475-9fbb-4c8d-8dee-94d24f3f96a0	fishcap_001	26.50	\N	\N	2026-09-08 08:20:38.722428	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4ac4db3e-32cd-448c-a70a-b28d017794d9	fishcap_001	26.50	\N	\N	2026-09-08 08:21:38.312325	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
843d6669-cb35-4c9e-85c1-e42e46c7c3a5	fishcap_001	26.44	\N	\N	2026-09-08 08:22:38.325448	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d5cb950d-23f2-4a3c-927c-643a644940f9	fishcap_001	26.44	\N	\N	2026-09-08 08:23:38.953064	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d3e9af22-fa6e-4b1c-8077-768785bd0ddd	fishcap_001	26.44	\N	\N	2026-09-08 08:24:38.952983	7.40	f	0.00	7.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3b20b711-b9ef-4bf7-8bae-c787db3c5f2c	fishcap_001	26.44	\N	\N	2026-09-08 08:25:38.770078	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2948c194-a57c-4cbd-814d-d2bec6b24694	fishcap_001	26.44	\N	\N	2026-09-08 08:26:39.11236	1.20	f	0.00	1.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0973242d-01d3-4eb0-8735-cea6922c4210	fishcap_001	26.44	\N	\N	2026-09-08 08:27:39.114121	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
631d034d-4cf4-48b8-b3d6-a9f5c2e641cf	fishcap_001	26.44	\N	\N	2026-09-08 08:28:39.807362	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
26faf1dc-a3a8-49af-938f-67b8f14e2c59	fishcap_001	26.44	\N	\N	2026-09-08 08:29:40.011857	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6a227224-7089-4a81-8073-0b87c3c6a616	fishcap_001	26.44	\N	\N	2026-09-08 08:30:40.84691	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
54576afd-8868-4e41-9639-2559103eb034	fishcap_001	26.50	\N	\N	2026-09-08 08:31:39.769952	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b2ce5e45-b34e-4b16-a33f-1c3bde28cb62	fishcap_001	26.44	\N	\N	2026-09-08 08:32:40.647172	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dbf59d87-9dd1-44d9-a1b3-31db27f71ea4	fishcap_001	26.50	\N	\N	2026-09-08 08:33:41.488141	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b755be27-9d51-4022-b0be-added0dd30cf	fishcap_001	26.50	\N	\N	2026-09-08 08:34:41.101543	5.20	f	0.00	5.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4ed98bb1-a251-40ae-8ba9-bb064def56ea	fishcap_001	26.50	\N	\N	2026-09-08 08:35:40.676547	7.80	f	0.00	7.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8606b731-3e94-4302-8421-2fddde60dbcb	fishcap_001	26.38	\N	\N	2026-09-08 08:36:40.680237	4.80	f	0.00	4.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2c86be74-6cd7-4a43-930f-c4768f89e46e	fishcap_001	26.38	\N	\N	2026-09-08 08:37:41.911314	5.40	f	0.00	5.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c1885c30-9805-4cd1-b06c-ae1dbe93f056	fishcap_001	26.38	\N	\N	2026-09-08 08:38:41.777046	3.00	f	0.00	3.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d5ad72a4-79fe-4348-aa00-1d1644edf979	fishcap_001	26.44	\N	\N	2026-09-08 08:39:42.333839	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ba7e1f14-1486-4305-8ae8-0c303765a82b	fishcap_001	26.44	\N	\N	2026-09-08 08:40:42.133591	1.20	f	0.00	1.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e28a0f21-89a8-46cc-9777-36dcc90305f0	fishcap_001	26.44	\N	\N	2026-09-08 08:41:42.754893	2.80	f	0.00	2.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b4afc6e5-4e5a-4dbd-b7c6-69ef445f896e	fishcap_001	26.44	\N	\N	2026-09-08 08:42:42.762788	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
388559a1-fe8d-4096-bd75-3eefab60b55e	fishcap_001	26.38	\N	\N	2026-09-08 08:43:43.175494	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
841abe11-3c56-49c2-8fdb-35b821b04da4	fishcap_001	26.38	\N	\N	2026-09-08 08:44:43.183612	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
01e79e2e-6aa6-4c59-87d4-9bc1f93f773b	fishcap_001	26.38	\N	\N	2026-09-08 08:45:43.186081	5.00	f	0.00	5.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c4be9427-b333-4ed0-b7a6-34c40e5f2479	fishcap_001	26.38	\N	\N	2026-09-08 08:46:43.656498	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d5d3970a-d27b-4dcc-a762-5504da93b3c5	fishcap_001	26.38	\N	\N	2026-09-08 08:47:44.418836	6.40	f	0.00	6.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e5ca9b0e-f5a0-4532-90d3-a5c4995b1b08	fishcap_001	26.31	\N	\N	2026-09-08 08:48:44.22905	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
88ce9c7c-4628-4956-a3f7-00e410c4d693	fishcap_001	26.38	\N	\N	2026-09-08 08:49:44.034227	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
100f0287-f1d0-49ef-bba2-52135cc9c9d4	fishcap_001	26.31	\N	\N	2026-09-08 08:50:44.657604	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a7d56226-c869-46c6-8cf1-1def0e6ab8ae	fishcap_001	26.31	\N	\N	2026-09-08 08:51:45.614454	2.80	f	0.00	2.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
27a7216f-15fa-4b4c-a408-2050c393e0f0	fishcap_001	26.31	\N	\N	2026-09-08 08:52:45.206555	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5c8dc573-f236-4573-9b72-790953a0ab24	fishcap_001	26.31	\N	\N	2026-09-08 08:53:45.838073	4.40	f	0.00	4.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
44beadd9-8255-4980-83b7-06c6037c8a3a	fishcap_001	26.31	\N	\N	2026-09-08 08:54:45.658321	6.60	f	0.00	6.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1d26e63c-6a63-495a-8c45-c59e49aff610	fishcap_001	26.25	\N	\N	2026-09-08 08:55:45.845186	4.20	f	0.00	4.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5c541a5b-9402-4b31-a41a-681d9c57a4a2	fishcap_001	26.31	\N	\N	2026-09-08 08:56:46.257738	11.80	f	0.00	11.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
efab0807-80b9-4bdb-82fa-82792b97d46d	fishcap_001	26.31	\N	\N	2026-09-08 08:57:46.878703	8.60	f	0.00	8.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3bbbe03c-0eb3-4d20-b56b-d01fd4e023e8	fishcap_001	26.31	\N	\N	2026-09-08 08:58:46.79808	6.80	f	0.00	6.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
81258135-e2cb-4473-a9eb-c9b33fc6e419	fishcap_001	26.31	\N	\N	2026-09-08 08:59:46.897407	1.80	f	0.00	1.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0c73dc3c-0ae4-4796-baa8-5a05c2f3fdc5	fishcap_001	26.31	\N	\N	2026-09-08 09:00:46.703547	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
decca479-a172-4dfc-a0b0-1dd88adf5711	fishcap_001	26.31	\N	\N	2026-09-08 09:01:47.654626	4.20	f	0.00	4.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
69371ea5-8599-4d4e-97c5-d12221abc735	fishcap_001	26.31	\N	\N	2026-09-08 09:02:46.382862	8.20	f	0.00	8.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
22b5f0e0-c538-40e7-b32c-f2c4737ace65	fishcap_001	26.25	\N	\N	2026-09-08 09:03:46.717869	2.00	f	0.00	2.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4615b3be-6557-48cf-96a2-6397b300bb5f	fishcap_001	26.25	\N	\N	2026-09-08 09:04:46.529771	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
640b195a-302f-4d87-aec9-bfd41022b1af	fishcap_001	26.25	\N	\N	2026-09-08 09:05:47.65537	6.20	f	0.00	6.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5478134c-4c23-4d7d-a1c5-76e804e8d02f	fishcap_001	26.25	\N	\N	2026-09-08 09:06:47.966115	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
67e076fc-ac17-43e7-8373-bfe30b043896	fishcap_001	26.19	\N	\N	2026-09-08 09:07:47.7654	4.00	f	0.00	4.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6cb7083d-e5a4-4e44-bacc-94a01e899f4e	fishcap_001	26.19	\N	\N	2026-09-08 09:08:47.976821	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c7aa73f2-2ad7-4284-b769-ba3cb13866ed	fishcap_001	26.19	\N	\N	2026-09-08 09:09:47.169303	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2c32225c-2de1-4954-935b-839a521d39d2	fishcap_001	26.19	\N	\N	2026-09-08 09:10:48.396001	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ce6d72ac-7f57-4ed3-a6a1-2ead10ea6e4a	fishcap_001	26.13	\N	\N	2026-09-08 09:11:48.610561	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
68fb457d-21a3-46f3-8f75-20dfbd6aad83	fishcap_001	26.13	\N	\N	2026-09-08 09:12:48.210894	6.40	f	0.00	6.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8483660c-3d15-4ad5-847f-58849e3bbb51	fishcap_001	26.13	\N	\N	2026-09-08 09:13:47.656965	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
47b42ece-ccd9-4b41-92c4-6da344a8a3d0	fishcap_001	26.13	\N	\N	2026-09-08 09:14:47.705871	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d79b3ccf-39ca-42b0-976f-8be43a685439	fishcap_001	26.00	\N	\N	2026-09-08 09:15:48.634543	6.80	f	0.00	6.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
423b35e3-0e91-41ca-ad5f-b4d8b31cf1c5	fishcap_001	26.00	\N	\N	2026-09-08 09:16:48.639746	4.00	f	0.00	4.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1e62dd83-6691-49ad-be70-ed781bdcd4fc	fishcap_001	25.94	\N	\N	2026-09-08 09:17:49.26235	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ae345e99-d121-490f-942a-afd558d152f3	fishcap_001	25.94	\N	\N	2026-09-08 09:18:49.268756	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
44101d8d-7dfa-485b-97b5-5eee8f5011b2	fishcap_001	25.94	\N	\N	2026-09-08 09:19:48.87364	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b18c4040-ab1b-48d5-a396-01b5e135950b	fishcap_001	25.88	\N	\N	2026-09-08 09:20:49.483028	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ffef2d01-4c16-4aa0-bc27-f80cae38e617	fishcap_001	25.88	\N	\N	2026-09-08 09:21:49.902853	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b4a5ad34-ad97-4080-b018-5283a053955f	fishcap_001	25.88	\N	\N	2026-09-08 09:22:49.70822	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
afb7a013-b8ab-4067-a70d-2e23fbe7c647	fishcap_001	25.81	\N	\N	2026-09-08 09:23:49.646479	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6040d74d-dff9-4c6c-b75b-2910629b37cb	fishcap_001	25.81	\N	\N	2026-09-08 09:24:49.649358	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
54a28b24-3c6c-47da-86d1-03e9b993d893	fishcap_001	25.81	\N	\N	2026-09-08 09:25:49.932471	0.40	f	0.00	0.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c84ebc5e-732f-4aaa-8e99-5b34cef4a9bc	fishcap_001	25.75	\N	\N	2026-09-08 09:26:49.967961	2.60	f	0.00	2.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bd38994e-b26b-4460-9fb6-d0b8a57bee31	fishcap_001	25.75	\N	\N	2026-09-08 09:27:50.978241	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a724e509-9149-466c-942b-c92fa08227f7	fishcap_001	25.69	\N	\N	2026-09-08 09:28:51.172326	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
16b17dc2-653f-4ab9-85ae-8af428dbb808	fishcap_001	25.69	\N	\N	2026-09-08 09:29:51.625126	7.00	f	0.00	7.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
be48b92f-29a3-4272-b341-a0883bd056b1	fishcap_001	25.69	\N	\N	2026-09-08 09:30:51.654481	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9577b26b-675b-4ed6-a9fe-97b24d55dbd5	fishcap_001	25.69	\N	\N	2026-09-08 09:31:51.623237	3.60	f	0.00	3.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d4630b9c-3831-4e3e-9dec-1f95d136fc5b	fishcap_001	25.69	\N	\N	2026-09-08 09:32:51.709633	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5ee9f572-c179-4ce3-ab96-414235b49b16	fishcap_001	25.69	\N	\N	2026-09-08 09:33:52.638707	0.60	f	0.00	0.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bd708129-23f7-4e05-bbc2-4b55cd56c636	fishcap_001	25.69	\N	\N	2026-09-08 09:34:52.845193	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d2bcf899-71d6-4dd9-9930-d8a8b520f3f6	fishcap_001	25.69	\N	\N	2026-09-08 09:35:53.619285	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a4585cb3-5287-41c3-8a52-0df8260cd108	fishcap_001	25.63	\N	\N	2026-09-08 09:36:53.651897	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
22cd82e7-962b-4435-ac42-bc98fecbca05	fishcap_001	25.63	\N	\N	2026-09-08 09:37:54.311826	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
45b968ba-9566-48f3-8d5d-3020c243a54e	fishcap_001	25.63	\N	\N	2026-09-08 09:38:53.719539	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
978c605c-1c5b-4ae5-97df-cf17c1b025a4	fishcap_001	25.63	\N	\N	2026-09-08 09:39:53.500377	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1a020d81-8826-4ea1-a25f-78980f128b47	fishcap_001	25.63	\N	\N	2026-09-08 09:40:53.517295	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
836573da-9a39-44e9-b03d-9674777c8d3a	fishcap_001	25.63	\N	\N	2026-09-08 09:41:53.533947	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0f247863-3521-492c-a65d-919469fb68bd	fishcap_001	25.56	\N	\N	2026-09-08 09:42:53.531342	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
37a4f8c7-de36-477b-be0a-b7b71214b695	fishcap_001	25.50	\N	\N	2026-09-08 09:43:53.540411	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5c640465-77fd-4d72-826f-d7bc7347d72a	fishcap_001	25.50	\N	\N	2026-09-08 09:44:53.552934	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3ae758b6-e0ea-4ab4-b2cb-9dd5917b50e1	fishcap_001	25.44	\N	\N	2026-09-08 09:45:53.621345	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e3c8230f-e274-4aaa-8fc3-0bbb170e9340	fishcap_001	25.44	\N	\N	2026-09-08 09:46:53.967727	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4471e14e-45c6-4e82-aeea-2740ca318f82	fishcap_001	25.38	\N	\N	2026-09-08 09:47:53.626353	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
77aec243-01cf-4dfc-add6-fa569fdddf6b	fishcap_001	25.38	\N	\N	2026-09-08 09:48:53.667216	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
98642b1e-982c-489f-a3c3-6c0a47a8d2d3	fishcap_001	25.31	\N	\N	2026-09-08 09:49:53.626513	1.40	f	0.00	1.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f637f472-79ef-491f-882d-8064ad1723eb	fishcap_001	25.31	\N	\N	2026-09-08 09:50:53.662797	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bd5b740c-2e76-4d3a-b2bc-67aea65174d1	fishcap_001	25.25	\N	\N	2026-09-08 09:51:54.000807	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d7875748-1148-4fe9-bd41-63b5c42d0cc4	fishcap_001	25.19	\N	\N	2026-09-08 09:52:54.001424	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
12ad76b7-a953-4975-8fbe-4a12d7e5a0d7	fishcap_001	25.19	\N	\N	2026-09-08 09:53:54.578111	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2def2041-9fe6-4baa-bc4f-0082053cd09a	fishcap_001	25.13	\N	\N	2026-09-08 09:54:54.020226	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
43ea9c93-0f5f-416d-91f9-36a955824b42	fishcap_001	25.06	\N	\N	2026-09-08 09:55:55.045095	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
933ba7c4-6a76-4390-a851-ff6e0d5bcc21	fishcap_001	25.00	\N	\N	2026-09-08 09:56:55.057548	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
295416b1-4b9d-48d2-a2c7-fe4a00cb439c	fishcap_001	24.81	\N	\N	2026-09-08 09:57:55.058508	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ad4994f7-a55e-45a2-aff5-cf8149e72187	fishcap_001	24.63	\N	\N	2026-09-08 09:58:55.636351	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6707c26d-26ec-43b2-82af-36aa7bbf5a1e	fishcap_001	24.75	\N	\N	2026-09-08 09:59:56.304119	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
af8571ea-442f-4e9c-baff-e1e085b94552	fishcap_001	24.75	\N	\N	2026-09-08 10:00:57.130146	1.20	f	0.00	1.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f83b9aa7-3e9b-48bd-b04a-7e366a2af1af	fishcap_001	24.75	\N	\N	2026-09-08 10:01:57.655142	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
920225b4-8d99-405e-a1b3-cac164aaa01a	fishcap_001	24.50	\N	\N	2026-09-08 10:02:57.960352	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0e295304-065f-463a-a414-2be24becdea0	fishcap_001	24.94	\N	\N	2026-09-08 10:03:57.967797	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0b5a1799-6ca1-4bfb-b12b-33943aef99cd	fishcap_001	19.31	\N	\N	2026-09-08 10:04:59.001807	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3ef82261-b537-4b31-b365-03fdf9d004f1	fishcap_001	33.31	\N	\N	2026-09-08 10:05:57.758985	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0f9af9bd-a22e-4c50-af44-4da5722338dd	fishcap_001	34.19	\N	\N	2026-09-08 10:06:58.602353	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9b2d5618-134c-414a-9b97-404a2598a784	fishcap_001	33.69	\N	\N	2026-09-08 10:07:57.791807	2.40	f	0.00	2.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
322518a8-9b75-42d0-8afd-de87759bd521	fishcap_001	33.06	\N	\N	2026-09-08 10:08:57.995574	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f2950dfb-c378-4ca9-af8e-672693a547ea	fishcap_001	27.06	\N	\N	2026-09-08 10:09:58.612121	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
00ef5c61-dc62-480f-a391-657de616640b	fishcap_001	28.06	\N	\N	2026-09-09 03:22:38.622275	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bbbac498-e5d3-4662-a241-394e782a821d	fishcap_001	28.06	\N	\N	2026-09-09 03:23:38.627077	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a3f403c1-8023-47e1-91b6-c43cd7ebabfa	fishcap_001	28.00	\N	\N	2026-09-09 03:24:38.611647	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8ae92170-0ec8-4340-a2b0-16ad5ceff861	fishcap_001	28.00	\N	\N	2026-09-09 03:25:38.633624	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5d22e899-362f-4b28-b743-84c55d12cae1	fishcap_001	28.00	\N	\N	2026-09-09 03:26:38.833882	2.60	f	0.00	2.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d97ebeed-010c-4faf-ac2f-f93c2103f759	fishcap_001	28.00	\N	\N	2026-09-09 03:27:40.691084	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
622f0b6a-755e-497c-b4fb-70608bdbf830	fishcap_001	28.00	\N	\N	2026-09-09 03:28:40.927176	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
11b6e3db-ccb9-4e4b-b264-edf6fbae2cb0	fishcap_001	27.94	\N	\N	2026-09-09 03:29:41.858773	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4c8a1bfa-7d39-4898-b027-3386c1615628	fishcap_001	27.94	\N	\N	2026-09-09 03:30:41.55268	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7273a114-82a1-4de9-89bd-b88785c411b1	fishcap_001	27.94	\N	\N	2026-09-09 03:31:42.750013	0.40	f	0.00	0.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e84eddd5-a079-4876-9cc3-225b4e9e069d	fishcap_001	27.94	\N	\N	2026-09-09 03:32:42.191877	8.40	f	0.00	8.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ddc302e2-9280-46d6-a16b-e606e379f61e	fishcap_001	27.94	\N	\N	2026-09-09 03:33:42.965925	4.60	f	0.00	4.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bc827e74-c9d9-4ae8-b0eb-685b466f7d40	fishcap_001	28.00	\N	\N	2026-09-09 03:34:42.973269	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
86e11f0c-4468-4159-9620-8468db04e065	fishcap_001	28.00	\N	\N	2026-09-09 03:35:44.539469	0.80	f	0.00	0.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
eb86d4bf-3a77-4496-992f-edd6a0bdeee9	fishcap_001	28.00	\N	\N	2026-09-09 03:36:44.487671	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1413780a-ebd4-4650-a642-b9e17718768a	fishcap_001	28.00	\N	\N	2026-09-09 03:37:44.768839	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d686571b-e797-4b6e-996a-ccda13b7f1ec	fishcap_001	28.00	\N	\N	2026-09-09 03:38:45.044662	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bda48626-c65d-4ae2-b011-42ccf67bd1f1	fishcap_001	28.00	\N	\N	2026-09-09 03:39:46.092283	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8acec1f6-eadc-4604-9c7e-a5642fa75b5e	fishcap_001	28.00	\N	\N	2026-09-09 03:40:47.736501	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f5e977f4-f200-4c0e-b623-163f348b86e3	fishcap_001	28.00	\N	\N	2026-09-09 03:41:48.149602	7.20	f	0.00	7.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
030e0329-3879-4e6d-be05-1684f9d462d1	fishcap_001	27.94	\N	\N	2026-09-09 03:42:48.974475	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7478bef2-8a74-48e1-86cd-e93cd633f6e2	fishcap_001	27.88	\N	\N	2026-09-09 03:43:50.207452	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c8bb8fc7-8fc0-45e5-a636-81ff6da3515a	fishcap_001	27.88	\N	\N	2026-09-09 03:44:50.232588	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6154e8ba-ddcd-4673-9d76-eab21bd1b74f	fishcap_001	27.88	\N	\N	2026-09-09 03:45:51.244461	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7cc8ec1a-1997-4634-ac72-33a9a31adca5	fishcap_001	27.88	\N	\N	2026-09-09 03:46:51.45251	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
09723a3c-3f88-44f2-a987-023570c16ac1	fishcap_001	27.94	\N	\N	2026-09-09 03:47:52.080601	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
37e4eaa7-a460-47d0-a3b9-47667a6ae3e6	fishcap_001	27.94	\N	\N	2026-09-09 03:48:52.616421	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
24104ce9-6809-4c8a-a18c-84bac86658ca	fishcap_001	28.00	\N	\N	2026-09-09 03:49:53.956695	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5e136392-ea00-42f6-81c5-29f37b6e77de	fishcap_001	28.00	\N	\N	2026-09-09 03:50:54.847777	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
38b12ed4-7062-41ae-ad44-f51e10b44e70	fishcap_001	28.00	\N	\N	2026-09-09 03:51:55.391513	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
66f40539-cd82-412a-9424-e7f2fc107057	fishcap_001	28.00	\N	\N	2026-09-09 03:52:54.750569	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
63358f3d-19ca-4610-aba8-8defec2b760d	fishcap_001	28.06	\N	\N	2026-09-09 03:53:56.64628	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8810a4de-d4fb-433e-8161-b6b8e6f15efd	fishcap_001	28.06	\N	\N	2026-09-09 03:54:56.643088	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7193c6a6-1c4f-4e40-8e7e-8006e2bfc9fb	fishcap_001	28.06	\N	\N	2026-09-09 03:55:57.905923	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
db8a2133-a3fb-459c-95bb-f40d050717e4	fishcap_001	28.00	\N	\N	2026-09-09 03:56:58.071305	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a57911dd-5f1a-4e12-b7a5-05f00c56cf35	fishcap_001	28.06	\N	\N	2026-09-09 03:57:58.486432	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
395c76c1-5d61-4e5c-873e-10546bf1a791	fishcap_001	28.00	\N	\N	2026-09-09 03:58:57.699712	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2e30faa0-f0ed-4969-b7e2-639f59a9cace	fishcap_001	27.94	\N	\N	2026-09-09 03:59:59.536257	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f2cab1f0-035c-4bf8-a271-8a52e5d676e2	fishcap_001	27.94	\N	\N	2026-09-09 04:00:59.745557	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
feed029e-4fc2-4feb-aaee-272e5d3eea66	fishcap_001	27.94	\N	\N	2026-09-09 04:01:59.742796	0.40	f	0.00	0.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ff7363e7-97e1-4af9-b366-68df5b2f1789	fishcap_001	27.94	\N	\N	2026-09-09 04:03:00.796688	4.20	f	0.00	4.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8bbbefdb-7fdc-4245-812f-4223475a5733	fishcap_001	27.88	\N	\N	2026-09-09 04:04:01.803052	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
273da4ad-bb2f-4c53-9b3e-dac4665faf2b	fishcap_001	27.88	\N	\N	2026-09-09 04:05:02.014194	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
952ded4e-4746-4cb5-ab4c-5decda4b05d9	fishcap_001	27.88	\N	\N	2026-09-09 04:06:03.259728	2.40	f	0.00	2.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8ef3dc14-d708-461b-b6fc-8383e2932e77	fishcap_001	27.88	\N	\N	2026-09-09 04:07:03.87273	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f23a44f4-5279-4ad6-a43d-6a9a2e5a212d	fishcap_001	27.88	\N	\N	2026-09-09 04:08:03.13074	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
55addaed-68e4-412a-aedc-174fb6bc4748	fishcap_001	27.88	\N	\N	2026-09-09 04:09:04.094063	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
66c332d0-1e02-483e-b543-d0b5e4ce3ae0	fishcap_001	27.88	\N	\N	2026-09-09 04:10:04.725036	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e5162c88-b259-476d-a82f-d55fb9d56217	fishcap_001	27.81	\N	\N	2026-09-09 04:11:06.992919	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7803d34e-3160-4aae-a0cb-0ad720b70a21	fishcap_001	27.81	\N	\N	2026-09-09 04:12:06.583724	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4efd8002-3af4-4203-8e52-9569d98ba566	fishcap_001	27.81	\N	\N	2026-09-09 04:13:07.817603	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a5ea03b4-8142-4814-85cd-80253b1ece1a	fishcap_001	27.81	\N	\N	2026-09-09 04:14:07.558077	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a5f003c4-b0a1-4c50-a1be-86fadb29177f	fishcap_001	27.81	\N	\N	2026-09-09 04:15:08.05204	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3aaa152e-c505-4e44-a516-750b0b3b9239	fishcap_001	27.81	\N	\N	2026-09-09 04:16:09.505556	0.20	f	0.00	0.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
df4e09c4-9720-4497-b86c-df78e45a055f	fishcap_001	27.81	\N	\N	2026-09-09 04:17:10.165995	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2f6cd7d2-8864-4743-95c7-5c688ed69647	fishcap_001	27.81	\N	\N	2026-09-09 04:18:11.626258	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f3da9d34-266b-4699-b292-b057204efb62	fishcap_001	27.81	\N	\N	2026-09-09 04:19:11.869938	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
012049c1-7140-41eb-b620-da9c6dc8aae5	fishcap_001	27.75	\N	\N	2026-09-09 04:20:12.91631	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3d4da0eb-072a-4f09-8fe8-bde5f01a065c	fishcap_001	27.81	\N	\N	2026-09-09 04:21:12.69195	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d72ea81d-59e3-460c-a857-64718ca46c4c	fishcap_001	27.81	\N	\N	2026-09-09 04:22:14.081568	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4efb503c-b8f3-4f04-a0b1-b9c782d6698e	fishcap_001	27.81	\N	\N	2026-09-09 04:23:15.46149	3.40	f	0.00	3.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
da2f2927-9882-46ee-9137-a5d4dc74a18b	fishcap_001	27.81	\N	\N	2026-09-09 04:24:15.509756	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
062e18e1-1449-42ca-a893-3e8031b80b02	fishcap_001	27.81	\N	\N	2026-09-09 04:25:16.943137	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
970b950a-9d85-49a7-b9ab-7186dd88d205	fishcap_001	27.81	\N	\N	2026-09-09 04:26:17.872332	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9f70efe0-29d5-4bc0-8077-6b1f6b8be4eb	fishcap_001	27.75	\N	\N	2026-09-09 04:27:18.619254	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8bc23e8c-ecdf-43b8-9802-33110b83560e	fishcap_001	27.75	\N	\N	2026-09-09 04:28:19.008922	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
572245c6-b51a-47a4-ae99-a84dc33e2eb1	fishcap_001	27.75	\N	\N	2026-09-09 04:29:19.797185	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a8e00180-c99b-4303-827a-fa055f3d1336	fishcap_001	27.75	\N	\N	2026-09-09 04:30:46.020138	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
581f8513-cfb9-4ff4-8dbf-2a245cc52e27	fishcap_001	27.75	\N	\N	2026-09-09 04:31:46.642031	0.60	f	0.00	0.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1e10cffe-aa30-4e1a-8882-4c18b6a78e9f	fishcap_001	27.75	\N	\N	2026-09-09 04:32:46.616064	5.40	f	0.00	5.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ef780e8a-8439-4e96-bf5d-a70c37891f31	fishcap_001	27.75	\N	\N	2026-09-09 04:33:47.064602	3.40	f	0.00	3.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3348f029-9f86-4134-9af5-0da6578a73bf	fishcap_001	27.75	\N	\N	2026-09-09 04:34:46.057894	3.80	f	0.00	3.80	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c6ed2136-acf2-4bf8-a2ee-103d177f97b7	fishcap_001	27.75	\N	\N	2026-09-09 04:35:46.872464	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
110aa550-0a0c-4cdd-803a-a91a7c9173dd	fishcap_001	27.75	\N	\N	2026-09-09 04:36:46.098221	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
68cf315c-09d9-4004-9499-555411d8bbe3	fishcap_001	27.81	\N	\N	2026-09-09 04:37:47.091425	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3d2c7f71-b483-449e-9de5-8ed8382173b5	fishcap_001	27.75	\N	\N	2026-09-09 04:38:46.225879	12.00	f	0.00	12.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
29f172a0-0aff-4a42-806a-cca9c5518fbb	fishcap_001	27.75	\N	\N	2026-09-09 04:39:46.710867	0.20	f	0.00	0.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b24164aa-cbab-4fe8-a91a-2e0ef7628ae6	fishcap_001	27.75	\N	\N	2026-09-09 04:40:47.30832	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
80adb5a1-9bb7-48ed-b92b-52cef6c1f693	fishcap_001	27.81	\N	\N	2026-09-09 04:41:47.942958	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a56e3a90-9292-4a7d-aae3-1e976b541b3f	fishcap_001	27.75	\N	\N	2026-09-09 04:42:47.342677	6.20	f	0.00	6.20	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6a73e211-24c9-4688-8a33-6aebd0b95b14	fishcap_001	27.81	\N	\N	2026-09-09 04:43:47.246608	0.60	f	0.00	0.60	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dc17e2f9-8344-4595-b955-f74ceec11daa	fishcap_001	27.75	\N	\N	2026-09-09 04:44:48.634561	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
cc79c7e1-3dcc-4bce-93c8-480f85211de3	fishcap_001	27.75	\N	\N	2026-09-09 04:45:47.763163	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1a0b9d85-1157-47c8-ad93-e89167c9d585	fishcap_001	27.75	\N	\N	2026-09-09 04:46:47.454682	5.40	f	0.00	5.40	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
210ae63d-d8bd-4874-b6ca-5d10d97181b2	fishcap_001	28.44	\N	\N	2026-09-09 04:47:48.190657	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
793fcbf2-a8ec-49b1-a9a8-39c1f273c8f4	fishcap_001	29.06	\N	\N	2026-09-09 04:48:47.818079	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f5a35d55-0a0f-427a-a56a-33a7ed63f20d	fishcap_001	29.38	\N	\N	2026-09-09 04:49:47.81399	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
06235df1-6569-4c37-9bf5-21de18e171b7	fishcap_001	29.63	\N	\N	2026-09-09 04:50:48.393673	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
309dcf50-1a46-47d2-ba47-7fd56459d9f3	fishcap_001	29.75	\N	\N	2026-09-09 04:51:48.407246	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2b5f55f7-1e33-4525-9c38-1db5c8c5c168	fishcap_001	29.75	\N	\N	2026-09-09 04:52:47.480762	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ac875f16-f7ac-487a-8d9a-f1fdbf7f536f	fishcap_001	29.81	\N	\N	2026-09-09 04:53:47.483638	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
74c259c1-a468-48aa-b2fa-e371129064ed	fishcap_001	29.88	\N	\N	2026-09-09 04:54:47.833142	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
19993b61-4f54-4a59-8292-e332336f0fc3	fishcap_001	29.88	\N	\N	2026-09-09 04:55:48.43116	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8c37ac1f-5334-462c-bfa3-16af4b0faf4c	fishcap_001	29.75	\N	\N	2026-09-09 04:57:40.647369	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e61044a0-139f-44cf-95b8-8bb40aad94bd	fishcap_001	29.69	\N	\N	2026-09-09 04:58:41.501296	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3de47314-28a2-41be-a982-8adddb29d981	fishcap_001	29.63	\N	\N	2026-09-09 04:59:41.914316	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3ade8c4b-cc88-43d4-97c0-4af9e7c03343	fishcap_001	29.56	\N	\N	2026-09-09 05:00:42.535949	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fa1b87eb-3348-4eb6-aaaa-05971b1a6c9c	fishcap_001	29.56	\N	\N	2026-09-09 05:01:42.950653	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
be2edc68-70b3-4ad0-9e61-e38cbe1947b3	fishcap_001	29.44	\N	\N	2026-09-09 05:02:43.982346	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ba0723a4-7da2-4301-acfd-27e8ace98c04	fishcap_001	29.38	\N	\N	2026-09-09 05:03:44.401146	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9aa8b221-8952-450c-ac5e-7f92363bb3d0	fishcap_001	29.31	\N	\N	2026-09-09 05:04:45.022729	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
320193ce-2cfd-4c23-a612-123a5b4573bd	fishcap_001	29.38	\N	\N	2026-09-09 05:05:45.073131	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9a660fa0-92d4-4b53-8893-837d09cb4576	fishcap_001	29.38	\N	\N	2026-09-09 05:06:46.338109	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c15a39ec-d6a8-4dc8-b172-1817caf5cc1d	fishcap_001	29.44	\N	\N	2026-09-09 05:07:46.592059	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c2e9400d-cae5-4b09-8c41-4199bc609a5d	fishcap_001	29.38	\N	\N	2026-09-09 05:08:47.226734	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a1e36ee7-028d-4c4e-8b12-4034fff8d6b0	fishcap_001	29.31	\N	\N	2026-09-09 05:09:46.710158	-1000.00	t	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9c094f1b-c856-4e5b-8ea1-e092374f3c8b	fishcap_001	29.31	\N	\N	2026-09-09 05:10:47.318481	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
49f4e2b9-fcab-44a4-a2a2-5cbaf8d86b93	fishcap_001	29.31	\N	\N	2026-09-09 05:11:46.653435	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5d27b7d0-525f-4a97-a09a-cdd86b1e5ff4	fishcap_001	29.31	\N	\N	2026-09-09 05:12:47.943782	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b4026790-ebfa-4d09-bec6-d50a80ca3c3c	fishcap_001	29.38	\N	\N	2026-09-09 05:13:48.621562	-1000.00	f	0.00	-1000.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fb8a1444-54f5-43ad-8358-675552cec7ab	fishcap_001	29.44	\N	\N	2026-09-09 05:14:51.225014	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d19bd902-f366-4b54-8556-34be628f11ea	fishcap_001	29.13	\N	\N	2026-09-09 05:16:00.281885	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2b99d592-b8a8-4b09-8d71-9985f7957339	fishcap_001	28.44	\N	\N	2026-09-09 05:20:46.664035	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c2d88123-6fb3-48dd-afb9-a01515c442cf	fishcap_001	28.31	\N	\N	2026-09-09 05:21:51.690805	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
51bfc29c-4d1a-4e2d-bcc0-830def21f7e6	fishcap_001	28.25	\N	\N	2026-09-09 05:22:55.791663	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
cdd5c111-fa38-4d97-b2a7-dd330e145fb6	fishcap_001	28.25	\N	\N	2026-09-09 05:23:58.903901	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b78884ef-2532-44cd-a18d-f38102fb9b47	fishcap_001	28.19	\N	\N	2026-09-09 05:25:04.000928	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dc5f9681-d355-4e6b-bfd3-75b29da2181a	fishcap_001	28.19	\N	\N	2026-09-09 05:26:04.013666	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0700bfb1-f1a1-4c18-84a7-ad11ff6b1c47	fishcap_001	29.13	\N	\N	2026-09-09 05:31:49.707299	0.04	f	0.00	0.04	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1324d7c6-91ea-4622-b741-f28e2b8cb8c4	fishcap_001	29.25	\N	\N	2026-09-09 05:32:59.142955	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fb90f6a4-dca1-4a5e-9a24-63f096de2485	fishcap_001	29.31	\N	\N	2026-09-09 05:33:58.97337	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4f53e272-1b45-4381-95a2-3246feb90239	fishcap_001	29.31	\N	\N	2026-09-09 05:35:02.645291	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c6a37ea8-6b30-47fb-a1de-1a0a50724c7d	fishcap_001	29.44	\N	\N	2026-09-09 05:36:07.142934	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f140b944-09f0-4032-8959-9db3aea383a9	fishcap_001	29.44	\N	\N	2026-09-09 05:37:10.671781	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7214939e-ce84-498c-9cbf-af38082c044d	fishcap_001	29.38	\N	\N	2026-09-09 05:38:14.618678	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7f166e19-24f2-4437-b777-a46d4589bd08	fishcap_001	29.31	\N	\N	2026-09-09 05:39:18.747459	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2c0572d5-a734-4b81-9a58-7c9fb107a9f7	fishcap_001	29.31	\N	\N	2026-09-09 05:40:23.551836	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0f7cb53d-4716-4967-a642-42a2c5fd9dbe	fishcap_001	29.31	\N	\N	2026-09-09 05:41:27.869552	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
15eaf476-edd0-435d-a4c2-668179ddbeaa	fishcap_001	29.31	\N	\N	2026-09-09 05:42:31.955829	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
02b7ff71-b0cb-4f16-9336-760181c0d8a0	fishcap_001	29.25	\N	\N	2026-09-09 05:43:36.591988	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
55ffe9de-64be-4e9d-8dae-d3dcbf394883	fishcap_001	29.19	\N	\N	2026-09-09 05:44:40.088399	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
72d48f5c-b938-402a-aab6-3509decc8a39	fishcap_001	29.13	\N	\N	2026-09-09 05:45:44.897283	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8004a57d-4bea-41cb-9a2c-9bb061d3ea58	fishcap_001	29.06	\N	\N	2026-09-09 05:46:48.694637	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6001a7b3-07cb-43a0-b2a7-854acc0d04e5	fishcap_001	29.06	\N	\N	2026-09-09 05:47:52.289801	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c6e8f650-0c02-4706-9959-6b4988674e82	fishcap_001	29.06	\N	\N	2026-09-09 05:48:56.999097	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
34458dbf-99de-4697-8b8d-6874b8e2fdea	fishcap_001	29.06	\N	\N	2026-09-09 05:50:01.913346	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
da35cde5-b5db-44e4-957a-361ff560312d	fishcap_001	29.00	\N	\N	2026-09-09 05:51:05.394598	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6a451e11-d88b-422a-be9b-020933f0b02e	fishcap_001	29.00	\N	\N	2026-09-09 05:52:09.699712	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a0e5dc87-1587-4108-8901-48999357e3df	fishcap_001	29.00	\N	\N	2026-09-09 05:53:13.058588	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a587de20-7ecd-4087-9544-fc0befa346af	fishcap_001	28.94	\N	\N	2026-09-09 05:55:15.268905	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7d2b9262-c5f3-4856-9d4b-43fcbaba11bb	fishcap_001	28.94	\N	\N	2026-09-09 05:56:20.185674	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fb44b610-9e45-4931-94b5-ae58539d70c5	fishcap_001	28.88	\N	\N	2026-09-09 05:57:24.628875	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
373fc111-a64c-4c5e-b741-8146e6a13c93	fishcap_001	28.94	\N	\N	2026-09-09 05:58:28.027395	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d634e071-7c2b-4acf-984a-cd4c812d9eb7	fishcap_001	28.88	\N	\N	2026-09-09 06:00:45.401423	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9e33e404-eaa0-4fdd-8950-8f6d440c1d41	fishcap_001	28.81	\N	\N	2026-09-09 06:01:49.726555	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7eefadd1-3147-4632-8e96-b366f17046f0	fishcap_001	28.81	\N	\N	2026-09-09 06:02:54.018423	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d6f1dd00-3f1b-4a79-9f37-8f42fea04856	fishcap_001	28.81	\N	\N	2026-09-09 06:03:57.344619	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1b522281-1dec-44a9-a1e1-954ec0443ff0	fishcap_001	28.81	\N	\N	2026-09-09 06:05:02.212092	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9edb0b6a-1ef6-459b-8434-c3be88453f27	fishcap_001	28.81	\N	\N	2026-09-09 06:06:02.834619	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8611f598-80c6-47ac-8dbe-89dda6c480d8	fishcap_001	28.81	\N	\N	2026-09-09 06:07:06.40031	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f138385b-9bc6-48cc-83fb-4032f81690bd	fishcap_001	28.75	\N	\N	2026-09-09 06:08:11.258013	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e9c9724f-e445-4a3c-ac0c-4219dd30feb7	fishcap_001	28.81	\N	\N	2026-09-09 06:09:15.002059	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c3e48351-2918-4361-98f1-b320e13a44af	fishcap_001	28.81	\N	\N	2026-09-09 06:10:19.461861	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f41972f7-58fb-4464-bc7e-b9f1cacc43e6	fishcap_001	28.75	\N	\N	2026-09-09 06:11:23.359917	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6eabb8cc-21fb-4674-b920-8b65fb7b902d	fishcap_001	28.75	\N	\N	2026-09-09 06:12:28.077509	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
64e25019-e5b3-4e4e-b03c-693a63af26cd	fishcap_001	28.69	\N	\N	2026-09-09 06:13:31.962254	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
388e8c0e-0fbf-4c39-ac9d-f168c0e42f3c	fishcap_001	28.75	\N	\N	2026-09-09 06:14:35.254399	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bbd350e2-f3ec-4067-baf1-4f0ad2be5a0e	fishcap_001	28.75	\N	\N	2026-09-09 06:15:40.164615	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c703a5cc-330a-4983-a414-d686cb7988b9	fishcap_001	28.69	\N	\N	2026-09-09 06:17:03.93714	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
10261830-c1c8-43b5-8296-c16c9896052e	fishcap_001	28.69	\N	\N	2026-09-09 06:18:08.031462	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
87f3954a-06e5-4f7c-a9f6-3e8f40a77e42	fishcap_001	28.69	\N	\N	2026-09-09 06:19:12.351778	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c1763dcb-f782-4bfa-8cd9-c380943649da	fishcap_001	28.63	\N	\N	2026-09-09 06:20:16.151991	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9c6e7878-1faf-4c25-be28-42af70f72649	fishcap_001	28.63	\N	\N	2026-09-09 06:21:19.550715	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ce45b2dd-8821-4b47-a199-24ea345bd412	fishcap_001	28.69	\N	\N	2026-09-09 06:22:24.452844	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
caa8d640-1e4e-4b39-a48b-e2a2b3886cae	fishcap_001	28.63	\N	\N	2026-09-09 06:23:27.743846	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1dc6866e-64bb-44fb-b7ef-5c33b8b8a70c	fishcap_001	28.63	\N	\N	2026-09-09 06:24:31.833662	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
275b80c1-0c9e-423f-8be7-b77dddb1a631	fishcap_001	28.63	\N	\N	2026-09-09 06:25:36.587626	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b7553334-b54a-4890-89cf-c7c2b6d28d24	fishcap_001	28.63	\N	\N	2026-09-09 06:26:40.667661	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8399ae1e-ed7c-4b16-afbf-10acfea6ea2b	fishcap_001	28.63	\N	\N	2026-09-09 06:27:44.1483	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
16f76d29-1f92-4ee5-9f78-1cc4eb6a2014	fishcap_001	28.56	\N	\N	2026-09-09 06:28:48.04746	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c0326e3f-0928-4c93-a961-1af93b15c692	fishcap_001	28.63	\N	\N	2026-09-09 06:29:52.155127	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9e028cb0-b1e4-4616-95c0-1f8831080af8	fishcap_001	28.56	\N	\N	2026-09-09 06:30:56.662589	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4eb402d3-e42b-4c07-ab93-0cca29108fd6	fishcap_001	28.56	\N	\N	2026-09-09 06:32:00.758549	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a9b39dd6-abc0-4d21-a3b1-2b370c39af5c	fishcap_001	28.56	\N	\N	2026-09-09 06:33:04.65806	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6fb6ab63-f6f5-4f1f-85fd-17823e486922	fishcap_001	28.50	\N	\N	2026-09-09 06:34:08.960709	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7ed805cc-eb02-4811-9cdc-58b4507ccc24	fishcap_001	28.50	\N	\N	2026-09-09 06:35:13.480932	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5e653bf9-26bb-4374-908b-6515ba3de4fb	fishcap_001	28.50	\N	\N	2026-09-09 06:36:17.374171	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
31514d41-bbca-41c2-a3e3-2d374d6ed89e	fishcap_001	28.50	\N	\N	2026-09-09 06:37:21.887956	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e18cce88-6242-4a51-9c96-4145df54a22b	fishcap_001	28.44	\N	\N	2026-09-09 06:38:25.78683	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
27b29e48-0b31-4eb7-b468-be603106109d	fishcap_001	28.44	\N	\N	2026-09-09 06:39:29.62934	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a5285c87-3133-47b1-8773-22786bcc79d3	fishcap_001	28.44	\N	\N	2026-09-09 06:40:33.371023	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6aa216b5-f9d0-48e3-94a4-f873280aec26	fishcap_001	28.38	\N	\N	2026-09-09 06:41:38.082284	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5fc119e5-9a51-4cfb-b005-c58ccc2841db	fishcap_001	28.38	\N	\N	2026-09-09 06:42:41.34037	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ce0fa512-6df3-4b8a-9825-d12e2984351c	fishcap_001	28.38	\N	\N	2026-09-09 06:43:45.893133	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
825f1f44-65d8-4d01-974a-8b92f98a5541	fishcap_001	28.38	\N	\N	2026-09-09 06:44:50.399593	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8038c8a0-3ca1-4bdd-b79e-f5b418c3345b	fishcap_001	28.38	\N	\N	2026-09-09 06:45:53.494865	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8efd7da7-eb0c-4082-bde2-3f43c5b4b332	fishcap_001	28.38	\N	\N	2026-09-09 06:46:58.403019	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b89dc970-92da-4624-9be1-7a50d2e5e184	fishcap_001	28.31	\N	\N	2026-09-09 06:48:01.587792	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d53c012a-0f00-4829-a3bc-5fe1e2e926bc	fishcap_001	28.31	\N	\N	2026-09-09 06:49:06.592776	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
91f79686-deee-4745-814a-209ffe2547a7	fishcap_001	28.31	\N	\N	2026-09-09 06:50:09.885052	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
db383a38-527d-497d-b472-fb96055dac86	fishcap_001	28.31	\N	\N	2026-09-09 06:51:14.007413	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f6ca9c68-ce94-4ea8-9f4a-1147c90fcc42	fishcap_001	28.38	\N	\N	2026-09-09 06:52:18.916179	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4e81979e-b2ea-4649-a2c4-0af98caf386f	fishcap_001	28.38	\N	\N	2026-09-09 06:53:23.012994	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
76fcc955-be92-405a-8389-776ca44ce93c	fishcap_001	28.31	\N	\N	2026-09-09 06:54:26.538244	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2791f8c2-b426-463d-9b54-deab8cf65c12	fishcap_001	28.31	\N	\N	2026-09-09 06:55:30.697632	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dee867a3-de8a-4062-8391-b219c8c12b46	fishcap_001	28.38	\N	\N	2026-09-09 06:56:35.721523	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c4a56188-5e41-468e-a095-3fea26458fdc	fishcap_001	28.38	\N	\N	2026-09-09 06:57:39.825908	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5caf0007-dc2a-42fa-9c8a-4e9a2e248f14	fishcap_001	28.38	\N	\N	2026-09-09 06:58:43.939349	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ad78bcf0-2f78-4c39-9899-7ad145ff6d96	fishcap_001	28.38	\N	\N	2026-09-09 06:59:47.438479	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0ab6eb39-210b-445b-8ac2-c056b264c92e	fishcap_001	28.31	\N	\N	2026-09-09 07:00:51.124372	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
16f08d0b-ae93-4a02-bade-93469850e126	fishcap_001	28.31	\N	\N	2026-09-09 07:01:55.911822	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b7f0f74a-dd76-4894-a3f2-6c6bb0583774	fishcap_001	28.31	\N	\N	2026-09-09 07:02:59.899364	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
00d3c8ca-7285-4173-9ede-26ad016fb9f4	fishcap_001	28.38	\N	\N	2026-09-09 07:04:03.431764	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fc7a440a-cadc-48a9-8a3b-6e923d925626	fishcap_001	28.31	\N	\N	2026-09-09 07:05:08.545128	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
cb8260a4-16d3-4d33-a540-bbf6b42e334f	fishcap_001	28.31	\N	\N	2026-09-09 07:06:12.252581	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
00028aa6-1d90-48fa-86e9-27d1079fe4c7	fishcap_001	28.31	\N	\N	2026-09-09 07:07:16.555625	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1ad6ecc6-2f60-42dc-8748-cecfdc1c817c	fishcap_001	28.31	\N	\N	2026-09-09 07:08:20.86107	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c6c7ae4f-5166-4364-b30d-75e05a3d00c9	fishcap_001	28.31	\N	\N	2026-09-09 07:09:24.1659	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0e412078-8c2b-4d9a-81f6-e1d31b333434	fishcap_001	28.31	\N	\N	2026-09-09 07:10:29.274446	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8b5f1319-07f4-40d6-82fe-cee0178ff60c	fishcap_001	28.31	\N	\N	2026-09-09 07:11:32.648878	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c9e9d13c-3bf1-4bd5-8b19-be508dd18f39	fishcap_001	28.25	\N	\N	2026-09-09 07:12:37.671687	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
40850f1b-6de2-42a2-a26a-e1da2d23d703	fishcap_001	28.25	\N	\N	2026-09-09 07:13:41.990315	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9cc4c5bf-dbf7-4d99-bb64-923399ad5157	fishcap_001	28.25	\N	\N	2026-09-09 07:14:45.282092	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fa01fb6a-4fd7-43e7-9cde-d28ddf142bca	fishcap_001	28.25	\N	\N	2026-09-09 07:15:49.992199	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
51783930-dce7-474d-8308-6bb469dece7e	fishcap_001	28.25	\N	\N	2026-09-09 07:16:53.948693	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c2d54a57-f8a4-4c6a-a999-e70b2587b906	fishcap_001	28.25	\N	\N	2026-09-09 07:17:57.585211	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bd4d7319-2d1a-4997-a940-0b59737bdf70	fishcap_001	28.31	\N	\N	2026-09-09 07:19:01.474536	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f599a8f3-fbae-4f12-b0eb-1479a320c05e	fishcap_001	28.31	\N	\N	2026-09-09 07:20:06.391107	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
55c483c4-f662-476c-bfd7-6237249961e4	fishcap_001	28.25	\N	\N	2026-09-09 07:21:09.104274	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7f26a424-1e27-4474-874b-edc8fb36fa1e	fishcap_001	28.31	\N	\N	2026-09-09 07:22:13.10333	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c401f020-0718-41cd-ac5b-62cc32c12fd9	fishcap_001	28.25	\N	\N	2026-09-09 07:23:18.096991	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9b869d05-6317-4872-8e6d-931d3b690ea7	fishcap_001	28.31	\N	\N	2026-09-09 07:24:21.174922	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7847e7ab-dfbf-471a-824b-6861a40328e2	fishcap_001	28.25	\N	\N	2026-09-09 07:25:26.096613	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
62e0a755-cb6d-4e43-b2d9-79aa5d6d9f74	fishcap_001	28.31	\N	\N	2026-09-09 07:26:30.404018	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
571dabfe-e08e-4884-8608-583bf7179455	fishcap_001	28.31	\N	\N	2026-09-09 07:27:33.889786	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
15abea08-efa1-4fd6-83db-57532aeee370	fishcap_001	28.31	\N	\N	2026-09-09 07:28:38.39888	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c5bbeed1-9ade-416b-9134-098ccba17bd6	fishcap_001	28.31	\N	\N	2026-09-09 07:29:42.174529	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
311ad94e-e7f2-4746-b09c-efc1292fafe5	fishcap_001	28.31	\N	\N	2026-09-09 07:30:46.6161	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e7f1430b-e4ae-4dae-a194-a474a5c29b6a	fishcap_001	28.25	\N	\N	2026-09-09 07:31:50.91669	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ec9d8330-f3e0-41fe-bcfe-cc02832735b7	fishcap_001	28.25	\N	\N	2026-09-09 07:32:55.427966	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ee82ff78-954c-4876-96c6-49988cb43920	fishcap_001	28.25	\N	\N	2026-09-09 07:33:59.736556	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d9f488f5-0fb3-4473-8d5c-a4227d41f295	fishcap_001	28.25	\N	\N	2026-09-09 07:35:03.051374	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
09125d04-2ebe-4a9a-b943-632e5d167bcb	fishcap_001	28.25	\N	\N	2026-09-09 07:36:07.723809	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b643c110-f6d1-4959-b39c-aea026ce7303	fishcap_001	28.25	\N	\N	2026-09-09 07:37:11.024801	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
979a4b66-aa11-4fc3-bfe1-9b9562125701	fishcap_001	28.19	\N	\N	2026-09-09 07:38:15.092987	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bb78b198-e04c-44c6-a257-631d226641f8	fishcap_001	28.19	\N	\N	2026-09-09 07:39:20.048139	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8898cc8b-a08a-4b0b-a3c3-c323c601375c	fishcap_001	28.19	\N	\N	2026-09-09 07:40:24.353248	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
cb73d6dc-af8d-4637-a63a-acf2e14855a2	fishcap_001	28.19	\N	\N	2026-09-09 07:41:30.091033	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e4ba2247-2392-475d-8c14-bdaa8ec441d5	fishcap_001	28.19	\N	\N	2026-09-09 07:42:33.370221	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6b208451-5c26-44c1-8be9-ea31504c8698	fishcap_001	28.13	\N	\N	2026-09-09 07:43:38.493048	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
6775eeca-badc-4835-b8a0-2e31fd8c8f02	fishcap_001	28.13	\N	\N	2026-09-09 07:44:42.81339	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7686524a-be05-41bf-99bb-6ba049f27158	fishcap_001	28.06	\N	\N	2026-09-09 07:45:46.508019	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
abb83a93-b214-4d48-9c88-f2fef944e1b9	fishcap_001	28.06	\N	\N	2026-09-09 07:46:51.219734	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f9415ba5-98d1-42ae-9278-9b5d6356898e	fishcap_001	28.06	\N	\N	2026-09-09 07:47:55.324624	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dcf6c179-faac-4b08-b18a-9f2de581580e	fishcap_001	28.13	\N	\N	2026-09-09 07:48:59.051866	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
671b133a-0afc-45fe-8a3f-bfe510ffd7c8	fishcap_001	28.13	\N	\N	2026-09-09 07:50:02.912868	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f72f88fa-19c4-4c5a-b669-a46d01d24dcd	fishcap_001	28.13	\N	\N	2026-09-09 07:51:07.619522	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
af618363-18a2-42d6-b80b-94730137bd31	fishcap_001	28.19	\N	\N	2026-09-09 07:52:10.611469	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f6c0c6d3-b83e-46e2-a68a-0667e63f107d	fishcap_001	28.19	\N	\N	2026-09-09 07:53:14.713797	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5710f387-1889-47df-b2ce-7c0266d6cd9d	fishcap_001	28.19	\N	\N	2026-09-09 07:54:19.185552	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
ca8294d3-e497-4678-8c63-61852249eb30	fishcap_001	28.19	\N	\N	2026-09-09 07:55:23.015054	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f4716d01-fe97-496a-8d97-475fa59f9cb8	fishcap_001	28.19	\N	\N	2026-09-09 07:56:27.735284	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4b39b633-fbfb-467a-9e77-2236e0afef8e	fishcap_001	28.19	\N	\N	2026-09-09 07:57:31.414711	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
17ea2e20-d87e-4aab-b264-d026f50c3437	fishcap_001	28.25	\N	\N	2026-09-09 07:58:36.332835	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
120e7538-1e9a-4342-864c-b2b5f3261e15	fishcap_001	28.25	\N	\N	2026-09-09 07:59:40.027298	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
edb57a64-cbe8-438a-b542-39825b6c6f87	fishcap_001	28.25	\N	\N	2026-09-09 08:00:43.74425	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8882f05c-e640-47c1-a4db-ac754ae4eee7	fishcap_001	28.25	\N	\N	2026-09-09 08:01:47.52554	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d5e400c7-7818-407b-a9c9-672a503a47d8	fishcap_001	28.25	\N	\N	2026-09-09 08:02:51.94999	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
70528481-cedd-4997-b00b-c46815c74091	fishcap_001	28.25	\N	\N	2026-09-09 08:03:55.597514	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
cc91e50a-9bea-414e-85a0-3fe3320888c9	fishcap_001	28.25	\N	\N	2026-09-09 08:05:00.435329	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3fb0652d-6dc4-418b-ae1b-0e711cd09574	fishcap_001	28.25	\N	\N	2026-09-09 08:06:04.438795	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
12346d91-f91c-45bc-812d-9a5f24f2399a	fishcap_001	28.25	\N	\N	2026-09-09 08:07:07.731087	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c44f7e75-a5f5-4012-9ede-9cddc904b7c7	fishcap_001	28.31	\N	\N	2026-09-09 08:08:11.701214	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bd706308-7054-44f7-b123-c30cd2576660	fishcap_001	28.25	\N	\N	2026-09-09 08:09:15.683525	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d65a70d4-14e5-43b2-81f0-bee4a553da20	fishcap_001	28.31	\N	\N	2026-09-09 08:10:19.672648	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
13f06f44-9922-4257-981e-711b3668d166	fishcap_001	28.31	\N	\N	2026-09-09 08:11:24.559204	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
63d3c951-fc9b-4906-bc1f-a5a887ec3738	fishcap_001	28.25	\N	\N	2026-09-09 08:12:28.259332	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b1b02084-67df-4bb2-aad6-41060123f17b	fishcap_001	28.25	\N	\N	2026-09-09 08:13:32.75085	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7e5e7719-93b9-46a2-9413-5e697b91ba6b	fishcap_001	28.25	\N	\N	2026-09-09 08:14:37.0552	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
54b38f78-a675-47f1-b907-0e76c46a05e2	fishcap_001	28.25	\N	\N	2026-09-09 08:15:40.668199	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
93e83d56-cad7-4131-b058-6b3931072bf4	fishcap_001	28.25	\N	\N	2026-09-09 08:16:45.093137	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0ba1827e-f349-4619-9906-138f65aeca61	fishcap_001	28.31	\N	\N	2026-09-09 08:17:48.625405	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
243252b9-3218-40cd-9ebf-cbd609e3a02f	fishcap_001	28.25	\N	\N	2026-09-09 08:18:53.258751	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
327ec8a0-68ea-4b7d-97a9-388efebdd9fd	fishcap_001	28.25	\N	\N	2026-09-09 08:19:56.971407	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
86b8b94c-7360-4403-bc6c-13687460aa6e	fishcap_001	28.25	\N	\N	2026-09-09 08:21:00.754158	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
765f0fc1-5db5-4488-a3e1-6e46e6a80277	fishcap_001	28.31	\N	\N	2026-09-09 08:22:05.788297	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
577fb210-4aa3-4591-a0ee-4d8d87271d47	fishcap_001	28.31	\N	\N	2026-09-09 08:23:08.704466	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5480f496-a7e6-4454-947f-4bf9ff5f0e3b	fishcap_001	28.31	\N	\N	2026-09-09 08:24:12.77146	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b153c43f-0622-48e8-9f71-513eb663222b	fishcap_001	28.31	\N	\N	2026-09-09 08:25:17.475553	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
72489655-e611-48a9-90cb-dfd7c426c013	fishcap_001	28.38	\N	\N	2026-09-09 08:26:21.180081	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5fe207ba-b658-4e0f-aa15-ea3d32e7f3d3	fishcap_001	28.38	\N	\N	2026-09-09 08:27:25.681237	0.00	t	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
8591afec-6619-46e6-a21c-1c009ea83ef9	fishcap_001	28.50	\N	\N	2026-09-09 08:29:08.883137	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
78744e3d-a394-474d-beb9-b399102c2211	fishcap_001	\N	\N	\N	2026-09-09 08:30:08.908915	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d44353d4-5b8e-418a-a244-6bf822dc8f88	fishcap_001	28.50	\N	\N	2026-09-09 08:31:15.879215	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
17f28eb9-67e8-4834-b5c6-9c17f723c180	fishcap_001	28.56	\N	\N	2026-09-09 08:32:18.132554	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
48a06714-9eac-430a-bba0-9fc6edda3602	fishcap_001	28.56	\N	\N	2026-09-09 08:33:19.586683	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
74808cac-4e02-497f-9390-e20e8724e935	fishcap_001	28.63	\N	\N	2026-09-09 08:34:22.533551	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c85332aa-a50c-4250-949c-03827703b65e	fishcap_001	28.56	\N	\N	2026-09-09 08:35:22.649222	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
4ee0ada1-2c5e-4832-adea-5dcdbeaa4647	fishcap_001	28.63	\N	\N	2026-09-09 08:36:24.518131	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0da75882-3688-488a-bc4c-30ea94759a79	fishcap_001	28.63	\N	\N	2026-09-09 08:37:26.38337	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
90bb92b6-a4b1-4750-87ce-559d52472cf0	fishcap_001	28.63	\N	\N	2026-09-09 08:38:28.394915	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bd5d9f18-c9da-4ee4-84b6-ad040cc2008f	fishcap_001	28.63	\N	\N	2026-09-09 08:39:31.486637	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b5540c3e-1723-4279-9a45-0bdc076757a5	fishcap_001	28.63	\N	\N	2026-09-09 08:40:32.322685	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
fbe0c1f2-bc6c-4168-b31e-ffde0bb53744	fishcap_001	\N	\N	\N	2026-09-09 08:41:36.028934	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
62166bce-76ac-4494-8407-52c0f0694c63	fishcap_001	28.63	\N	\N	2026-09-09 08:42:35.64845	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
db6f4028-a181-436f-b319-7de0c547d230	fishcap_001	28.63	\N	\N	2026-09-09 08:43:37.882225	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
baeed3bb-4e3b-445f-8273-602f33560212	fishcap_001	28.63	\N	\N	2026-09-09 08:44:42.180504	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d96b2bb1-1208-4952-a817-5bb0bdd35e0b	fishcap_001	\N	\N	\N	2026-09-09 08:45:45.267206	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d1066ff0-88e1-48bf-9967-b2ea0528b1b3	fishcap_001	28.63	\N	\N	2026-09-09 08:46:47.929816	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
577bc834-bf50-4cfa-b1bf-93ed0bc03773	fishcap_001	28.56	\N	\N	2026-09-09 08:47:49.96117	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
38e34df7-cb43-49e3-9b74-28e54dbf9128	fishcap_001	28.56	\N	\N	2026-09-09 08:48:51.64049	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bea39dfe-8817-424d-9c57-0d4c896e8fdf	fishcap_001	28.56	\N	\N	2026-09-09 08:49:53.899552	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1abc62ee-1d5f-4a22-9de9-dc220644072f	fishcap_001	28.56	\N	\N	2026-09-09 08:50:56.158103	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b1dfccc5-43b2-4f23-8350-6fa1537fcaf6	fishcap_001	28.56	\N	\N	2026-09-09 08:51:59.022047	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a68ca077-cc11-4625-88c5-784904cd042b	fishcap_001	28.50	\N	\N	2026-09-09 08:53:00.667414	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0c1d22d4-e137-490d-8b4b-4357639d7567	fishcap_001	28.50	\N	\N	2026-09-09 08:54:03.746616	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9348d153-aef7-4905-8ef5-455445cffe5a	fishcap_001	28.50	\N	\N	2026-09-09 08:55:06.211035	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a2a7f349-fb22-4dac-9ebe-89685304cac3	fishcap_001	28.50	\N	\N	2026-09-09 08:56:08.469661	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5fceb2b0-987a-4bf2-b3ef-4e76f7e2bfd3	fishcap_001	28.50	\N	\N	2026-09-09 08:57:09.917863	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2d48bb3d-f02e-4613-b2e0-64d9d9fd5185	fishcap_001	30.13	\N	\N	2026-09-09 09:17:10.615513	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f25c7527-3ec3-4ca3-9d13-611a6187d624	fishcap_001	29.63	\N	\N	2026-09-09 09:18:12.72238	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
01df9ddb-b751-4e63-a7f4-91d015450e1c	fishcap_001	29.06	\N	\N	2026-09-09 09:19:14.588157	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
691a15f1-76a0-4351-8045-660d8d79b5e5	fishcap_001	28.75	\N	\N	2026-09-09 09:20:16.511418	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
156696df-c749-4e3e-aae4-82d55a09916d	fishcap_001	28.56	\N	\N	2026-09-09 09:21:17.449947	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
85463d2b-4c54-487d-be15-ca11b3524f2b	fishcap_001	\N	\N	\N	2026-09-09 09:22:17.661695	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d5ba81a4-7819-41a6-adba-0e44aa322c0c	fishcap_001	\N	\N	\N	2026-09-09 09:23:17.064177	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
74981859-73dc-4ea7-b169-1e139cc5d7e9	fishcap_001	\N	\N	\N	2026-09-09 09:24:25.875181	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9e2848ec-d567-4f40-b52e-7738ff48c62f	fishcap_001	\N	\N	\N	2026-09-09 09:25:28.083413	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dcd67cdc-6013-4834-9995-66e023b51637	fishcap_001	\N	\N	\N	2026-09-09 09:34:59.343301	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
a9229b1c-3bf1-473b-8859-0f24c31ec0c4	fishcap_001	\N	\N	\N	2026-09-09 09:36:01.789917	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
bd3ca2f2-0074-42d6-94c1-7785e78a0042	fishcap_001	\N	\N	\N	2026-09-09 09:37:04.659021	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
e1c9ccd4-5a23-49a5-ab62-c8345554dc5d	fishcap_001	\N	\N	\N	2026-09-09 09:38:08.152452	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
db8665bb-8130-4845-82d4-e2950f5feb39	fishcap_001	\N	\N	\N	2026-09-09 09:39:11.839938	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c90a1149-7a5e-475e-a7e6-ad06e6b65c88	fishcap_001	\N	\N	\N	2026-09-09 09:40:14.183485	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
28feca2b-467d-4682-becb-b2278be7493f	fishcap_001	\N	\N	\N	2026-09-09 09:41:16.973343	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
d816cc58-4929-4bf2-b81b-505ee1b33d16	fishcap_001	\N	\N	\N	2026-09-09 09:42:20.274942	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
5f3f441c-7646-4c4f-9b6b-3f4d06a247ab	fishcap_001	\N	\N	\N	2026-09-09 09:43:23.760239	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b2c873f1-f3f8-40b0-b9cd-0e79af3babb0	fishcap_001	\N	\N	\N	2026-09-09 09:44:27.048468	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
2dfb721a-95b3-496e-afaa-c1d41f830e29	fishcap_001	\N	\N	\N	2026-09-09 09:45:30.732602	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c5689062-95b4-4876-8111-3b9ea90fde5e	fishcap_001	\N	\N	\N	2026-09-09 09:46:33.001587	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
81fa06e8-415a-48db-9c6d-dd68113c0fd0	fishcap_001	\N	\N	\N	2026-09-09 09:47:35.727731	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
3282c5e1-949f-4085-b6cb-83e1eb344d99	fishcap_001	\N	\N	\N	2026-09-09 09:48:37.979037	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
c555b548-47a7-416d-9c7b-ced6022f8cf2	fishcap_001	\N	\N	\N	2026-09-09 09:49:46.587856	0.01	f	0.00	0.01	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
9ee679dc-7b38-403d-a972-17c3ea23cafc	fishcap_001	\N	\N	\N	2026-09-09 09:50:48.585649	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
0e7f0f68-5e7d-4421-8ba9-0269b00f0730	fishcap_001	\N	\N	\N	2026-09-09 09:51:49.074397	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
311005f7-78ea-4568-afc6-6fa235c0817b	fishcap_001	\N	\N	\N	2026-09-09 09:52:49.823702	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
f312af04-df8f-413b-8d2e-f8810be3677a	fishcap_001	\N	\N	\N	2026-09-09 09:53:50.614719	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7ca52f83-6f92-4ec9-a7e7-9f9466f125c0	fishcap_001	\N	\N	\N	2026-09-09 09:54:50.65033	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
704a17dd-06ef-43cc-b020-f35add5a8b6b	fishcap_001	\N	\N	\N	2026-09-09 09:55:56.194614	0.00	f	0.00	0.00	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
dc073bdf-6440-435d-a90e-07732fc5764e	fishcap_001	\N	\N	\N	2026-09-09 09:56:57.451583	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
1182f204-0974-4f08-9da5-abd9a5535168	fishcap_001	\N	\N	\N	2026-09-09 09:57:57.026438	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
7e55f558-fc4e-4950-a342-de3e39f70a81	fishcap_001	\N	\N	\N	2026-09-09 09:58:57.039291	0.03	f	0.00	0.03	t	\N	4408c859-fa79-42d6-bcaa-53443d155d95
b6256ebc-4e8e-44d5-83b8-6aa515d6cb99	fishcap_001	28.44	11.41	\N	2026-09-10 14:25:17.60201	3.29	f	0.00	3.29	t	33.42	4408c859-fa79-42d6-bcaa-53443d155d95
cdeb9493-edbc-4365-b1ca-4a9a4cc31584	fishcap_001	28.44	11.41	\N	2026-09-10 14:30:02.024566	3.29	f	0.00	3.29	t	33.42	4408c859-fa79-42d6-bcaa-53443d155d95
9121e272-fc1c-4948-a9ad-4d6a80b5de97	fishcap_001	28.38	11.50	\N	2026-09-10 14:32:06.460946	1.69	f	0.00	1.69	t	33.76	4408c859-fa79-42d6-bcaa-53443d155d95
0940c8fe-9e4f-40b7-aadb-35a18636e6cd	fishcap_001	28.38	11.46	\N	2026-09-10 14:33:07.569045	2.33	f	0.00	2.33	t	33.41	4408c859-fa79-42d6-bcaa-53443d155d95
6fd2059d-6f88-4339-81d1-8f6a48a24819	fishcap_001	28.38	11.45	\N	2026-09-10 14:34:09.81422	2.63	f	0.00	2.63	t	34.17	4408c859-fa79-42d6-bcaa-53443d155d95
9dbe8ebd-c817-42a8-9d61-e619d88ec431	fishcap_001	28.38	11.43	\N	2026-09-10 14:35:10.758994	2.96	f	0.00	2.96	t	33.63	4408c859-fa79-42d6-bcaa-53443d155d95
c93f1b0c-7da7-4740-89db-a3a498ad6928	fishcap_001	28.31	11.44	\N	2026-09-10 14:36:12.411906	3.06	f	0.00	3.06	t	32.30	4408c859-fa79-42d6-bcaa-53443d155d95
6082c092-aff9-4fe9-8dc3-4f49d6517ffd	fishcap_001	28.31	11.42	\N	2026-09-10 14:37:14.767099	3.02	f	0.00	3.02	t	35.04	4408c859-fa79-42d6-bcaa-53443d155d95
30a87134-1290-43a6-9a6e-1ed72d4801c3	fishcap_001	30.38	11.43	\N	2026-09-13 08:23:11.300059	3.72	f	0.00	3.72	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
f4e1db87-0a30-4593-a633-d2cebc8762ef	fishcap_001	30.25	11.42	\N	2026-09-13 08:24:14.131394	2.82	f	0.00	2.82	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
cf2cb05c-4ead-4aeb-a3d0-da2317abbc0a	fishcap_001	30.19	11.48	\N	2026-09-13 08:28:06.115504	0.56	f	0.00	0.56	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
a08c2ea0-8e63-48a1-bf72-c90919e5a7c5	fishcap_001	30.25	11.46	\N	2026-09-13 08:29:07.771663	0.88	f	0.00	0.88	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
d6549821-8c23-4646-8a58-510974eb260e	fishcap_001	29.56	11.45	\N	2026-09-13 08:30:09.40967	1.11	f	0.00	1.11	t	36.75	4408c859-fa79-42d6-bcaa-53443d155d95
15ebc133-001c-4139-982d-ab407cc3ee25	fishcap_001	29.00	11.45	\N	2026-09-13 08:31:11.884625	1.27	f	0.00	1.27	t	35.25	4408c859-fa79-42d6-bcaa-53443d155d95
4c1c1a8d-fe23-40e7-8d8e-bfcc0a9e2aec	fishcap_001	28.75	11.45	\N	2026-09-13 08:32:12.936319	1.30	f	0.00	1.30	t	35.40	4408c859-fa79-42d6-bcaa-53443d155d95
3378fb4c-e03e-4f22-9d3d-e67c40423daa	fishcap_001	28.63	11.46	\N	2026-09-13 08:33:14.18013	1.31	f	0.00	1.31	t	36.07	4408c859-fa79-42d6-bcaa-53443d155d95
9935d815-cdb0-40db-b9a8-cca936bbdcee	fishcap_001	28.50	11.43	\N	2026-09-13 08:34:17.051709	1.37	f	0.00	1.37	t	35.30	4408c859-fa79-42d6-bcaa-53443d155d95
f633f9ae-c81e-4910-bb57-ba09e2579c96	fishcap_001	28.44	14.14	\N	2026-09-13 08:35:18.081312	1.27	f	0.00	1.27	t	32.85	4408c859-fa79-42d6-bcaa-53443d155d95
4cb4d0ad-d4e8-4e09-8d82-726d7b050d6b	fishcap_001	28.50	13.89	\N	2026-09-13 08:36:19.658186	1.13	f	0.00	1.13	t	158.36	4408c859-fa79-42d6-bcaa-53443d155d95
d1ea489c-987a-4efe-acfc-a2a0e8d3c67e	fishcap_001	28.56	11.35	\N	2026-09-13 08:37:21.608506	1.30	f	0.00	1.30	t	209.92	4408c859-fa79-42d6-bcaa-53443d155d95
cb4be24a-aaf5-4ddc-83a2-7d1db657ada9	fishcap_001	28.50	11.34	\N	2026-09-13 08:38:22.811165	1.33	f	0.00	1.33	t	249.28	4408c859-fa79-42d6-bcaa-53443d155d95
d5dea9b3-1ff8-426c-b237-e2b647c9aa15	fishcap_001	28.50	11.35	\N	2026-09-13 08:39:24.461386	1.23	f	0.00	1.23	t	264.77	4408c859-fa79-42d6-bcaa-53443d155d95
035eef3a-65f4-4013-9556-224cb6d5266e	fishcap_001	28.56	11.35	\N	2026-09-13 08:40:26.332621	1.65	f	0.00	1.65	t	269.39	4408c859-fa79-42d6-bcaa-53443d155d95
a319e05c-f3ed-4f4d-a6a6-baa2efadd0b7	fishcap_001	28.56	19.11	\N	2026-09-13 08:41:27.711612	0.00	f	0.00	0.00	t	296.42	4408c859-fa79-42d6-bcaa-53443d155d95
c996d5ec-daaf-4ad5-b0b8-03561ad36fdc	fishcap_001	28.56	11.36	\N	2026-09-13 08:42:29.627676	0.00	f	0.00	0.00	t	269.26	4408c859-fa79-42d6-bcaa-53443d155d95
62546a4f-b964-46e8-bca2-2c7029c8ee22	fishcap_001	28.56	11.36	\N	2026-09-13 08:43:30.847864	0.63	f	0.00	0.63	t	267.31	4408c859-fa79-42d6-bcaa-53443d155d95
f77f30fa-43d4-49e9-b2fc-13e3f5f5be2b	fishcap_001	28.56	11.36	\N	2026-09-13 08:45:02.588171	0.51	f	0.00	0.51	t	271.87	4408c859-fa79-42d6-bcaa-53443d155d95
ecd58afe-536f-4424-a2f2-85a3689f2898	fishcap_001	28.56	11.37	\N	2026-09-13 08:46:04.434938	0.15	f	0.00	0.15	t	271.03	4408c859-fa79-42d6-bcaa-53443d155d95
d577e5c8-ffd6-4ca3-b73a-aa07458def3c	fishcap_001	28.50	11.38	\N	2026-09-13 08:47:05.808709	0.12	f	0.00	0.12	t	281.02	4408c859-fa79-42d6-bcaa-53443d155d95
c72ae7a4-80b9-48e7-bf9e-b76f6bdac464	fishcap_001	28.75	11.42	\N	2026-09-13 08:54:29.376618	1.40	f	0.00	1.40	t	277.25	4408c859-fa79-42d6-bcaa-53443d155d95
e882ad63-e875-40c3-9e64-1b7fcfac1091	fishcap_001	28.81	11.38	\N	2026-09-13 08:55:31.11313	1.02	f	0.00	1.02	t	0.69	4408c859-fa79-42d6-bcaa-53443d155d95
ec169d90-90b4-4c10-b645-2f0852e5a393	fishcap_001	28.88	11.40	\N	2026-09-13 08:56:33.370426	1.24	f	0.00	1.24	t	277.14	4408c859-fa79-42d6-bcaa-53443d155d95
773cb4af-59f4-4d4d-985f-30081d7ff00c	fishcap_001	29.00	11.39	\N	2026-09-13 08:57:34.400821	1.59	f	0.00	1.59	t	281.79	4408c859-fa79-42d6-bcaa-53443d155d95
ea1251c7-6cec-447c-8f38-37bfc8f0971b	fishcap_001	29.19	11.38	\N	2026-09-13 08:58:35.683159	1.63	f	0.00	1.63	t	276.90	4408c859-fa79-42d6-bcaa-53443d155d95
f3a1a544-fde3-463b-8cd3-bd218c0e8818	fishcap_001	29.31	11.38	\N	2026-09-13 08:59:37.286504	1.70	f	0.00	1.70	t	271.57	4408c859-fa79-42d6-bcaa-53443d155d95
11bfb851-f029-4845-a930-d3a093af4e91	fishcap_001	30.00	11.41	\N	2026-09-13 09:56:03.224465	2.83	f	0.00	2.83	t	168.50	4408c859-fa79-42d6-bcaa-53443d155d95
b799cf10-b41e-4a53-a4e8-2618443246cb	fishcap_001	30.06	11.40	\N	2026-09-13 09:57:04.490913	3.12	f	0.00	3.12	t	164.76	4408c859-fa79-42d6-bcaa-53443d155d95
7239f6af-0643-4ba5-bb5a-5afcd793bbf5	fishcap_001	30.00	11.41	\N	2026-09-13 09:58:06.103386	3.31	f	0.00	3.31	t	167.73	4408c859-fa79-42d6-bcaa-53443d155d95
7ea64223-ff3d-4307-bd7e-43413e7933bd	fishcap_001	30.00	11.41	\N	2026-09-13 09:59:07.744204	3.49	f	0.00	3.49	t	168.36	4408c859-fa79-42d6-bcaa-53443d155d95
79d05180-ec44-45a9-a0d3-398325b4300a	fishcap_001	30.00	11.40	\N	2026-09-13 10:00:10.209068	3.43	f	0.00	3.43	t	178.70	4408c859-fa79-42d6-bcaa-53443d155d95
4326577d-73fa-434e-afdc-250cd6b296ea	fishcap_001	30.00	11.38	\N	2026-09-13 10:01:10.824073	3.99	f	0.00	3.99	t	211.48	4408c859-fa79-42d6-bcaa-53443d155d95
61b7d940-3110-4f41-9b66-40c0c2b70794	fishcap_001	30.00	11.42	\N	2026-09-13 10:02:12.586205	3.93	f	0.00	3.93	t	176.09	4408c859-fa79-42d6-bcaa-53443d155d95
83b81e76-d0cd-4033-b2cd-c3d44071f716	fishcap_001	30.00	11.40	\N	2026-09-13 10:03:14.626624	3.98	f	0.00	3.98	t	177.48	4408c859-fa79-42d6-bcaa-53443d155d95
ef95e1b8-2904-4efa-80d8-cbd0b832ffa3	fishcap_001	29.94	11.41	\N	2026-09-13 10:04:17.204839	4.03	f	0.00	4.03	t	176.93	4408c859-fa79-42d6-bcaa-53443d155d95
1772c35f-2be9-4d42-8d71-267fd92be4c2	fishcap_001	29.63	11.45	\N	2026-09-13 11:00:33.142624	1663.45	f	0.00	1663.45	f	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
650bcda2-6210-486f-8a2e-baa4f250c198	fishcap_001	29.69	11.44	\N	2026-09-13 11:01:34.766018	2169.31	f	0.00	2169.31	f	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
73faa920-2cd2-4b7c-960e-449afd19fd85	fishcap_001	29.75	11.43	\N	2026-09-13 11:02:36.09127	2517.49	f	0.00	2517.49	f	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
64e99fbc-9a4f-4865-aeb1-255256dd4f0f	fishcap_001	29.75	11.41	\N	2026-09-13 11:03:38.080376	3025.03	f	0.00	3025.03	f	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
e9de9bc3-7099-4cae-9f7c-1bbefb9f7bbc	fishcap_001	29.69	11.42	\N	2026-09-13 11:04:40.100773	3198.35	f	0.00	3198.35	f	199.51	4408c859-fa79-42d6-bcaa-53443d155d95
25717cd8-ff30-463c-87e7-26a0250e3279	fishcap_001	29.69	11.40	\N	2026-09-13 11:05:40.849576	3365.44	f	0.00	3365.44	f	201.05	4408c859-fa79-42d6-bcaa-53443d155d95
f865b57f-4656-4df7-8dc8-3ce758abdc86	fishcap_001	29.69	11.41	\N	2026-09-13 11:06:43.394495	3500.53	f	0.00	3500.53	f	198.94	4408c859-fa79-42d6-bcaa-53443d155d95
c8814516-363d-4c32-8e7e-86493472cb18	fishcap_001	28.56	11.47	\N	2026-09-13 15:15:56.119478	3713.20	f	0.00	3713.20	f	212.87	4408c859-fa79-42d6-bcaa-53443d155d95
e0a00f9e-4d78-4739-b425-601e6005e944	fishcap_001	28.56	11.45	\N	2026-09-13 15:16:58.074004	4251.04	f	0.00	4251.04	f	214.37	4408c859-fa79-42d6-bcaa-53443d155d95
3e4b850b-9da6-42eb-9efc-800ab16238ce	fishcap_001	28.56	11.46	\N	2026-09-13 15:18:00.086204	16305.81	f	0.00	16305.81	f	213.35	4408c859-fa79-42d6-bcaa-53443d155d95
e917a90d-8df3-488f-a147-304b2c7601ce	fishcap_001	28.63	11.45	\N	2026-09-13 15:19:01.729331	6339.87	f	0.00	6339.87	f	213.72	4408c859-fa79-42d6-bcaa-53443d155d95
1b283d6b-ee52-4827-861e-4afa63d8ccae	fishcap_001	28.63	11.45	\N	2026-09-13 15:20:02.62547	12262.09	f	0.00	12262.09	f	213.83	4408c859-fa79-42d6-bcaa-53443d155d95
3fcf604b-fce2-4f74-a1a0-807b4ea13b96	fishcap_001	28.56	11.45	\N	2026-09-13 15:21:05.082103	2210.21	f	0.00	2210.21	f	213.95	4408c859-fa79-42d6-bcaa-53443d155d95
93f93238-58a8-42d2-aa92-e9aeae99358e	fishcap_001	28.56	11.47	\N	2026-09-13 15:22:06.679335	0.00	f	0.00	0.00	t	216.38	4408c859-fa79-42d6-bcaa-53443d155d95
565bf6f4-9794-4ebb-b1ef-8a27eef6d12a	fishcap_001	28.63	11.45	\N	2026-09-13 15:23:07.587452	0.00	f	0.00	0.00	t	213.01	4408c859-fa79-42d6-bcaa-53443d155d95
43ede645-954d-4d04-a47b-9eb473b26959	fishcap_001	28.63	11.45	\N	2026-09-13 15:24:09.971539	0.00	f	0.00	0.00	t	210.81	4408c859-fa79-42d6-bcaa-53443d155d95
16f6293d-a188-4f49-8be5-71b732a8a745	fishcap_001	28.63	11.44	\N	2026-09-13 15:25:10.878274	4880.78	f	0.00	4880.78	f	210.10	4408c859-fa79-42d6-bcaa-53443d155d95
1259254c-0fb2-4380-b544-5a54676e2f77	fishcap_001	28.56	11.42	\N	2026-09-13 15:26:12.455224	0.00	f	0.00	0.00	t	209.32	4408c859-fa79-42d6-bcaa-53443d155d95
29b024d6-f9e4-48ae-81f9-42e36faca50f	fishcap_001	28.56	11.45	\N	2026-09-13 15:27:14.273082	4566.67	f	0.00	4566.67	f	210.31	4408c859-fa79-42d6-bcaa-53443d155d95
0837e8df-9d52-40ab-b476-30f5737c238f	fishcap_001	28.56	11.45	\N	2026-09-13 15:28:15.776689	0.00	f	0.00	0.00	t	210.04	4408c859-fa79-42d6-bcaa-53443d155d95
4cec5d9e-a6b9-4c1b-8d90-bca0f5a1e14a	fishcap_001	28.56	11.45	\N	2026-09-13 15:29:17.382074	18008.04	f	0.00	18008.04	f	209.97	4408c859-fa79-42d6-bcaa-53443d155d95
65d9e039-e667-40d6-ab23-5f16b8896c7a	fishcap_001	28.56	11.44	\N	2026-09-13 15:30:18.956753	5101.99	f	0.00	5101.99	f	210.82	4408c859-fa79-42d6-bcaa-53443d155d95
00225571-c87f-4069-a41b-3e9ac8891999	fishcap_001	28.44	11.51	\N	2026-09-13 15:51:06.87382	4157.54	f	0.00	4157.54	f	216.45	4408c859-fa79-42d6-bcaa-53443d155d95
d3df47a3-6ce3-4e34-bd57-dadf134c084e	fishcap_001	25.00	11.42	\N	2026-09-14 02:39:52.230209	2084.77	f	0.00	2084.77	f	29.83	4408c859-fa79-42d6-bcaa-53443d155d95
f628c898-d0a6-4d83-afca-6c40f5b05d29	fishcap_001	25.00	11.44	\N	2026-09-14 02:40:56.937746	8374.16	f	0.00	8374.16	f	49.14	4408c859-fa79-42d6-bcaa-53443d155d95
b69798d4-2aa0-4329-b0ed-eefb8f815e69	fishcap_001	24.94	11.42	\N	2026-09-14 02:42:01.865344	10649.23	f	0.00	10649.23	f	41.41	4408c859-fa79-42d6-bcaa-53443d155d95
b903dac3-26e2-4716-b206-d844c7cea481	fishcap_002	24.44	9.61	\N	2026-09-14 06:49:52.362231	0.00	f	0.00	0.00	t	627.04	13d3c394-ca4a-4198-9490-07bd0176bdbd
4d3d09c9-811d-4da9-83e8-db8afe3ed18e	fishcap_001	24.94	11.44	\N	2026-09-14 02:43:03.478616	7068.40	f	0.00	7068.40	f	35.01	4408c859-fa79-42d6-bcaa-53443d155d95
d08a15cd-b13f-4f4f-9054-3a0bd37f1124	fishcap_001	24.88	11.51	\N	2026-09-14 02:44:05.32518	7370.48	f	0.00	7370.48	f	32.19	4408c859-fa79-42d6-bcaa-53443d155d95
d20a6aee-b575-41c3-83b2-8037a56f554b	fishcap_001	24.69	14.27	\N	2026-09-14 02:46:32.748995	5912.03	f	0.00	5912.03	f	129.59	4408c859-fa79-42d6-bcaa-53443d155d95
1eae4901-d580-4349-960a-e5ff9f06ef3f	fishcap_001	24.50	14.47	\N	2026-09-14 02:50:09.587854	2051.39	f	0.00	2051.39	f	200.04	4408c859-fa79-42d6-bcaa-53443d155d95
7c60fc42-0538-489c-8c34-5c1a600c06a6	fishcap_001	24.50	14.60	\N	2026-09-14 02:51:15.369932	2579.53	f	0.00	2579.53	f	218.39	4408c859-fa79-42d6-bcaa-53443d155d95
3f9b6e25-7a6a-4de6-a39d-e54efaaf43f3	fishcap_001	24.38	14.59	\N	2026-09-14 02:52:16.435133	2996.71	f	0.00	2996.71	f	254.64	4408c859-fa79-42d6-bcaa-53443d155d95
703ff90a-6664-415b-bb69-5462e322a663	fishcap_001	24.50	14.58	\N	2026-09-14 02:53:17.149528	3512.37	f	0.00	3512.37	f	331.26	4408c859-fa79-42d6-bcaa-53443d155d95
60992101-6724-4dd6-90d7-f3b4f6854654	fishcap_001	24.56	14.58	\N	2026-09-14 02:54:18.744541	3714.20	f	0.00	3714.20	f	341.08	4408c859-fa79-42d6-bcaa-53443d155d95
96e25e47-7297-4189-9097-dc97c1b4d837	fishcap_001	24.56	14.59	\N	2026-09-14 02:55:20.775804	3730.44	f	0.00	3730.44	f	348.60	4408c859-fa79-42d6-bcaa-53443d155d95
1228c5ac-d6c6-4717-9214-8c9a21044098	fishcap_001	24.63	14.63	\N	2026-09-14 02:56:22.812907	4172.21	f	0.00	4172.21	f	357.88	4408c859-fa79-42d6-bcaa-53443d155d95
750aa7da-f5ab-4813-af42-aee8e79f947f	fishcap_001	24.63	14.65	\N	2026-09-14 02:57:23.865933	4100.92	f	0.00	4100.92	f	350.19	4408c859-fa79-42d6-bcaa-53443d155d95
ba4d6a5d-8857-4836-84f1-49cbc4b7ebcf	fishcap_001	24.63	14.66	\N	2026-09-14 02:58:25.256873	4514.47	f	0.00	4514.47	f	355.24	4408c859-fa79-42d6-bcaa-53443d155d95
03ee5aca-a881-48c1-adc7-a62680f56705	fishcap_001	24.63	14.68	\N	2026-09-14 02:59:27.761317	4687.05	f	0.00	4687.05	f	369.16	4408c859-fa79-42d6-bcaa-53443d155d95
656dd785-dc54-4fe1-8670-bfa10104c7ef	fishcap_001	24.63	14.67	\N	2026-09-14 03:00:28.816217	4278.23	f	0.00	4278.23	f	372.02	4408c859-fa79-42d6-bcaa-53443d155d95
e09c3620-42c3-425c-bf50-677549fbad40	fishcap_001	24.75	14.68	\N	2026-09-14 03:01:30.621461	5079.57	f	0.00	5079.57	f	380.40	4408c859-fa79-42d6-bcaa-53443d155d95
1158f673-dae6-4609-a3f5-d2f644adb52f	fishcap_001	24.94	14.67	\N	2026-09-14 03:02:31.969767	4891.95	f	0.00	4891.95	f	383.02	4408c859-fa79-42d6-bcaa-53443d155d95
17d080c0-65e5-4a3a-8d2a-53b343f03c3f	fishcap_001	25.00	14.70	\N	2026-09-14 03:03:33.65658	4932.16	f	0.00	4932.16	f	381.77	4408c859-fa79-42d6-bcaa-53443d155d95
06dc0233-f12b-484f-9c1c-d05dedc334ff	fishcap_001	25.06	14.72	\N	2026-09-14 03:04:36.173623	5453.13	f	0.00	5453.13	f	388.69	4408c859-fa79-42d6-bcaa-53443d155d95
e22e0501-cce4-46dc-b4c3-dbec81f375f5	fishcap_001	25.06	14.70	\N	2026-09-14 03:05:36.88161	5205.62	f	0.00	5205.62	f	390.05	4408c859-fa79-42d6-bcaa-53443d155d95
7ea7966c-1d8b-4c2e-8982-b35acbb985da	fishcap_001	25.06	14.72	\N	2026-09-14 03:06:39.072297	0.00	f	0.00	0.00	t	396.74	4408c859-fa79-42d6-bcaa-53443d155d95
1c8ca446-50e5-4576-8baf-6de1a181a81b	fishcap_001	25.13	14.75	\N	2026-09-14 03:07:40.511661	0.00	f	0.00	0.00	t	412.68	4408c859-fa79-42d6-bcaa-53443d155d95
d9444304-c989-48a1-b89d-5192e12a8f28	fishcap_001	25.13	14.74	\N	2026-09-14 03:08:41.728513	0.00	f	0.00	0.00	t	407.48	4408c859-fa79-42d6-bcaa-53443d155d95
869e17a5-a039-48c1-9178-7030afb7cb54	fishcap_001	25.13	14.76	\N	2026-09-14 03:09:43.395021	0.00	f	0.00	0.00	t	411.48	4408c859-fa79-42d6-bcaa-53443d155d95
f3a14501-e512-4b1f-a7c5-effb3ce386b3	fishcap_001	25.25	14.68	\N	2026-09-14 03:10:44.979671	0.00	f	0.00	0.00	t	401.68	4408c859-fa79-42d6-bcaa-53443d155d95
11e6400d-922d-4d8a-9298-4f8de05a9082	fishcap_001	25.25	14.75	\N	2026-09-14 03:11:47.374752	0.00	f	0.00	0.00	t	394.80	4408c859-fa79-42d6-bcaa-53443d155d95
e4093a9e-f64b-4339-86b6-3db4e8f4c8b7	fishcap_001	25.31	14.67	\N	2026-09-14 03:12:48.477075	0.00	f	0.00	0.00	t	401.31	4408c859-fa79-42d6-bcaa-53443d155d95
15b667d7-41aa-4565-8293-0d11dd378753	fishcap_001	25.31	14.69	\N	2026-09-14 03:13:49.949624	0.00	f	0.00	0.00	t	397.11	4408c859-fa79-42d6-bcaa-53443d155d95
5b3484c9-e7e3-43a3-8938-755752c99474	fishcap_001	24.69	10.19	\N	2026-09-14 04:19:05.72706	0.00	f	0.00	0.00	t	384.54	4408c859-fa79-42d6-bcaa-53443d155d95
323b2dcf-8c14-4555-9eec-d704a2da6f57	fishcap_001	24.63	10.26	\N	2026-09-14 04:20:05.670604	0.00	f	0.00	0.00	t	387.13	4408c859-fa79-42d6-bcaa-53443d155d95
a437a554-839f-4e39-ae8a-2d23a1b802b3	fishcap_001	24.69	10.35	\N	2026-09-14 04:21:06.011779	0.00	f	0.00	0.00	t	401.71	4408c859-fa79-42d6-bcaa-53443d155d95
006695fa-0033-4d20-a2b5-a6800708ffe7	fishcap_001	24.63	10.34	\N	2026-09-14 04:22:05.683551	0.00	f	0.00	0.00	t	414.30	4408c859-fa79-42d6-bcaa-53443d155d95
bb5a0407-aecb-4a0a-83c9-0d1bafe2e1a3	fishcap_001	24.69	10.41	\N	2026-09-14 04:23:06.63546	0.00	f	0.00	0.00	t	423.57	4408c859-fa79-42d6-bcaa-53443d155d95
0ed8f3df-2810-4d7c-81cc-0ef8b0b40d57	fishcap_001	24.75	10.12	\N	2026-09-14 04:24:06.82937	0.00	f	0.00	0.00	t	572.20	4408c859-fa79-42d6-bcaa-53443d155d95
1ba0fd18-9492-4734-b0ab-103d4121b1ba	fishcap_001	24.75	10.02	\N	2026-09-14 04:25:10.332085	0.00	f	0.00	0.00	t	577.82	4408c859-fa79-42d6-bcaa-53443d155d95
dbd42558-26ae-45b5-b014-2d96d8510543	fishcap_001	24.81	9.85	\N	2026-09-14 04:26:11.155348	0.00	f	0.00	0.00	t	705.64	4408c859-fa79-42d6-bcaa-53443d155d95
406645ec-e275-4426-880a-7c3e82e1f360	fishcap_001	23.88	9.79	\N	2026-09-14 04:27:10.221267	0.00	f	0.00	0.00	t	704.70	4408c859-fa79-42d6-bcaa-53443d155d95
55788140-82b3-46ee-8568-89c9dfacb4f5	fishcap_001	24.06	9.75	\N	2026-09-14 04:28:11.162451	0.00	f	0.00	0.00	t	719.74	4408c859-fa79-42d6-bcaa-53443d155d95
198d7af5-f42f-4f15-84d8-6c37d3d97210	fishcap_001	24.19	9.67	\N	2026-09-14 04:29:11.259368	0.00	f	0.00	0.00	t	735.01	4408c859-fa79-42d6-bcaa-53443d155d95
6c130209-d708-45f6-9c99-057a8f758ac9	fishcap_001	24.31	9.69	\N	2026-09-14 04:30:12.206598	0.00	f	0.00	0.00	t	739.06	4408c859-fa79-42d6-bcaa-53443d155d95
91c5822a-3a39-4989-8724-653e11f3aea7	fishcap_001	24.25	9.62	\N	2026-09-14 04:31:12.213934	0.00	f	0.00	0.00	t	731.58	4408c859-fa79-42d6-bcaa-53443d155d95
ddb67475-00a2-402f-b99c-cc3b65e5ec7b	fishcap_001	24.13	9.63	\N	2026-09-14 04:32:12.014359	0.00	f	0.00	0.00	t	723.71	4408c859-fa79-42d6-bcaa-53443d155d95
cb31b623-f6d3-4f8c-bfee-50008b2acba8	fishcap_001	22.94	9.62	\N	2026-09-14 06:12:13.10231	1.93	f	0.00	1.93	t	587.75	4408c859-fa79-42d6-bcaa-53443d155d95
b51a5aff-18b7-472e-9fd2-687e47ada284	fishcap_001	22.94	9.59	\N	2026-09-14 06:13:14.419218	1.90	f	0.00	1.90	t	585.75	4408c859-fa79-42d6-bcaa-53443d155d95
7dd55eeb-47ea-4384-8950-aa8c85c74331	fishcap_001	22.94	9.59	\N	2026-09-14 06:14:16.065069	1.98	f	0.00	1.98	t	583.92	4408c859-fa79-42d6-bcaa-53443d155d95
a0265b35-e9d2-4852-b111-9d2bc601a0d5	fishcap_001	22.94	9.60	\N	2026-09-14 06:15:18.63339	2.19	f	0.00	2.19	t	585.14	4408c859-fa79-42d6-bcaa-53443d155d95
36362829-a66d-43b8-b3c7-c563653bfa8b	fishcap_001	22.94	9.59	\N	2026-09-14 06:31:09.238899	4.11	f	0.00	4.11	t	594.93	4408c859-fa79-42d6-bcaa-53443d155d95
f6b1ca99-26a8-47b0-8dc9-c519a2f11375	fishcap_001	22.88	9.57	\N	2026-09-14 06:32:10.990953	0.00	f	0.00	0.00	t	595.04	4408c859-fa79-42d6-bcaa-53443d155d95
a00a90f8-90e9-4578-970b-dd5c9bf321f1	fishcap_001	25.56	9.53	\N	2026-09-14 06:33:12.634975	0.00	f	0.00	0.00	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
8b160940-163d-47ea-a5af-8cb606d40d9e	fishcap_001	26.00	9.57	\N	2026-09-14 06:34:14.227712	0.00	f	0.00	0.00	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
377c87f4-daf5-47af-ba17-a9a8452275a0	fishcap_001	26.06	9.57	\N	2026-09-14 06:35:15.929974	0.00	f	0.00	0.00	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
273b5da8-c8b9-4b6f-bd0d-e5fb35879810	fishcap_001	25.94	9.59	\N	2026-09-14 06:36:17.528241	0.00	f	0.00	0.00	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
bc2cc37a-4af6-4054-883a-4f8b1fdb0f28	fishcap_001	25.88	9.56	\N	2026-09-14 06:37:19.855468	0.00	f	0.00	0.00	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
e887ca59-bb6e-4669-800d-bc9f43f904eb	fishcap_001	25.75	9.57	\N	2026-09-14 06:38:20.926634	0.00	f	0.00	0.00	t	0.00	4408c859-fa79-42d6-bcaa-53443d155d95
030bad0c-7b77-4d1a-a6e5-8c4fc622e7d0	fishcap_001	25.06	9.57	\N	2026-09-14 06:40:20.635297	1.04	f	0.00	1.04	t	630.68	4408c859-fa79-42d6-bcaa-53443d155d95
3b6949a8-6aa1-4fb3-90da-2f213c1f8959	fishcap_002	24.75	9.59	\N	2026-09-14 06:42:10.454891	0.93	f	0.00	0.93	t	625.60	13d3c394-ca4a-4198-9490-07bd0176bdbd
d8ceeca7-d0c9-4cf2-9c02-a9f7dfae2772	fishcap_002	24.69	9.59	\N	2026-09-14 06:43:12.358986	1.40	f	0.00	1.40	t	622.53	13d3c394-ca4a-4198-9490-07bd0176bdbd
676e7d71-f0a7-4c7b-9c99-aa5219072c07	fishcap_002	24.63	9.60	\N	2026-09-14 06:44:13.275843	226.61	f	0.00	226.61	t	632.50	13d3c394-ca4a-4198-9490-07bd0176bdbd
0a59eac4-365e-4476-b44e-93b388bec3ba	fishcap_002	24.56	9.57	\N	2026-09-14 06:45:15.776055	226.29	f	0.00	226.29	t	631.96	13d3c394-ca4a-4198-9490-07bd0176bdbd
fb4ae004-ce04-42e4-9e2e-cb883b561968	fishcap_002	24.69	9.62	\N	2026-09-14 06:47:25.215629	0.21	f	0.00	0.21	t	630.47	13d3c394-ca4a-4198-9490-07bd0176bdbd
82817a48-85c7-4302-9b47-d10ccbcfcc94	fishcap_002	24.69	9.64	\N	2026-09-14 06:48:27.101444	0.42	f	0.00	0.42	t	629.03	13d3c394-ca4a-4198-9490-07bd0176bdbd
ae21631d-159b-4fe2-af34-35867fe1d3f2	fishcap_002	24.50	9.62	\N	2026-09-14 06:50:54.141288	0.00	f	0.00	0.00	t	627.56	13d3c394-ca4a-4198-9490-07bd0176bdbd
772eb006-1df2-4696-8f60-4dd5be03738b	fishcap_002	24.63	9.64	\N	2026-09-14 06:58:07.071484	0.00	f	0.00	0.00	t	630.55	13d3c394-ca4a-4198-9490-07bd0176bdbd
63a58260-b732-481b-95ca-70d6eb530c31	fishcap_002	24.69	9.60	\N	2026-09-14 06:59:08.331451	0.00	f	0.00	0.00	t	633.12	13d3c394-ca4a-4198-9490-07bd0176bdbd
d7959251-5566-4e26-88cd-8c288313dd76	fishcap_002	24.69	9.61	\N	2026-09-14 07:00:11.224205	0.00	f	0.00	0.00	t	632.37	13d3c394-ca4a-4198-9490-07bd0176bdbd
c922eb1a-d8b4-441b-8612-826591009803	fishcap_002	24.69	9.59	\N	2026-09-14 07:01:13.24616	0.00	f	0.00	0.00	t	633.63	13d3c394-ca4a-4198-9490-07bd0176bdbd
d57afd72-9571-4937-a755-957d7fa05cd9	fishcap_002	24.69	9.63	\N	2026-09-14 07:02:53.20098	1.34	f	0.00	1.34	t	636.37	13d3c394-ca4a-4198-9490-07bd0176bdbd
c53b07f9-ae3a-4e40-9dc9-f6e95489ecee	fishcap_002	24.69	9.66	\N	2026-09-14 07:03:55.460503	1.34	f	0.00	1.34	t	634.61	13d3c394-ca4a-4198-9490-07bd0176bdbd
e5576b5d-d171-4a1f-a780-0b0e049ca1e6	fishcap_002	24.75	9.59	\N	2026-09-14 07:04:56.8955	0.03	f	0.00	0.03	t	637.42	13d3c394-ca4a-4198-9490-07bd0176bdbd
4e59fcbb-c361-4545-bacc-4400e575edcd	fishcap_002	24.75	9.61	\N	2026-09-14 07:07:00.67968	3.20	f	0.00	3.20	t	635.23	13d3c394-ca4a-4198-9490-07bd0176bdbd
8742757c-94bf-49ca-8729-1b066f5a91bc	fishcap_002	24.75	9.60	\N	2026-09-14 07:08:01.740581	3.41	f	0.00	3.41	t	635.10	13d3c394-ca4a-4198-9490-07bd0176bdbd
39832bc6-6148-48f8-97b8-f7fa3b9ba2bf	fishcap_002	24.69	9.59	\N	2026-09-14 07:09:03.374712	3.72	f	0.00	3.72	t	632.71	13d3c394-ca4a-4198-9490-07bd0176bdbd
3b853ce8-f1b7-499f-8b35-c71cfa418c67	fishcap_002	24.69	9.62	\N	2026-09-14 07:10:05.320842	3.10	f	0.00	3.10	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
2cd56f69-ae53-4a82-a4dc-fac3b0fdc452	fishcap_002	24.75	9.67	\N	2026-09-14 07:11:07.593017	2.62	f	0.00	2.62	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
a08d11a1-7903-4828-9f4b-68967193f1a7	fishcap_002	24.75	9.62	\N	2026-09-14 07:12:08.364565	2.99	f	0.00	2.99	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
487cbada-b6c7-4347-9e8b-bd06e9ea0311	fishcap_002	24.75	9.62	\N	2026-09-14 07:13:10.472109	2.18	f	0.00	2.18	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
bc70cc92-e6e1-473d-bf3a-341dac1e6547	fishcap_002	24.81	9.60	\N	2026-09-14 07:14:11.730704	2.31	f	0.00	2.31	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
201e5df0-dbaa-4e1d-bee3-aa674ff6f127	fishcap_002	24.75	9.61	\N	2026-09-14 07:15:13.364015	53.67	f	0.00	53.67	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
1e0f0605-4e23-44b9-bc81-97b52d0eab02	fishcap_002	24.81	9.60	\N	2026-09-14 07:16:15.795162	51.68	f	0.00	51.68	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
8816b866-ac50-4864-847f-f3c610600fb2	fishcap_002	24.81	9.60	\N	2026-09-14 07:17:17.269043	51.61	f	0.00	51.61	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
7111ed87-cd44-4b18-a906-cd8bf62210a7	fishcap_002	24.88	9.62	\N	2026-09-14 07:18:18.678898	50.65	f	0.00	50.65	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
9468761c-6913-4044-b508-f9614f54c7cb	fishcap_002	24.88	9.60	\N	2026-09-14 07:19:20.43698	48.45	f	0.00	48.45	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
c129b1b3-2da8-4357-85b7-5abee4966898	fishcap_002	24.88	9.60	\N	2026-09-14 07:20:22.603356	49.21	f	0.00	49.21	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
1f134a1e-7712-4f74-bca0-49fcf291ea21	fishcap_002	24.81	9.60	\N	2026-09-14 07:21:23.856085	48.71	f	0.00	48.71	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
9e907954-b5ba-4fe0-b700-95adb74e8c45	fishcap_002	24.88	9.56	\N	2026-09-14 07:22:25.528933	49.01	f	0.00	49.01	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
1f04c3a7-07d8-4567-af53-b8e9af4ad586	fishcap_002	24.88	9.58	\N	2026-09-14 07:23:27.12601	47.98	f	0.00	47.98	t	88.97	13d3c394-ca4a-4198-9490-07bd0176bdbd
ff0c9f61-51a6-48bb-af8b-4c4a807fd206	fishcap_002	24.88	9.58	\N	2026-09-14 07:24:30.203502	48.00	f	0.00	48.00	t	662.35	13d3c394-ca4a-4198-9490-07bd0176bdbd
29508bb0-16f4-459f-a897-870972256f0d	fishcap_002	24.81	9.60	\N	2026-09-14 07:25:32.345521	47.27	f	0.00	47.27	t	657.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
b9e94f7b-8136-41d3-aa91-3b510d5fa7a9	fishcap_002	24.88	9.57	\N	2026-09-14 07:26:34.001935	46.47	f	0.00	46.47	t	656.11	13d3c394-ca4a-4198-9490-07bd0176bdbd
92c90a58-a135-44a5-a1c5-45a13714dcfb	fishcap_002	24.88	9.58	\N	2026-09-14 07:27:35.7459	46.88	f	0.00	46.88	t	651.78	13d3c394-ca4a-4198-9490-07bd0176bdbd
9cf91c0f-1dae-407e-bbf4-4886fcccbec1	fishcap_002	24.94	9.60	\N	2026-09-14 07:28:37.416282	45.85	f	0.00	45.85	t	651.54	13d3c394-ca4a-4198-9490-07bd0176bdbd
5256ac37-e2bf-4ea5-a602-d15dfca3f3ad	fishcap_002	24.88	9.60	\N	2026-09-14 07:29:39.648892	45.75	f	0.00	45.75	t	644.49	13d3c394-ca4a-4198-9490-07bd0176bdbd
79c06e4f-2dc6-40b9-8cba-097f144046cc	fishcap_002	24.94	9.63	\N	2026-09-14 07:30:41.709733	45.38	f	0.00	45.38	t	646.29	13d3c394-ca4a-4198-9490-07bd0176bdbd
b98d0a15-68fa-4203-ac01-413ab1e6eda6	fishcap_002	24.94	9.56	\N	2026-09-14 07:31:43.16436	0.00	f	0.00	0.00	t	645.68	13d3c394-ca4a-4198-9490-07bd0176bdbd
baef7e31-18c1-44bd-9ba8-e26c9ae51d68	fishcap_002	24.88	9.60	\N	2026-09-14 07:32:45.033229	0.00	f	0.00	0.00	t	643.61	13d3c394-ca4a-4198-9490-07bd0176bdbd
e8f3dfac-be9c-4e25-a941-1011631592d2	fishcap_002	24.88	9.59	\N	2026-09-14 07:33:47.068705	0.00	f	0.00	0.00	t	639.25	13d3c394-ca4a-4198-9490-07bd0176bdbd
c92d4efa-ffa4-4657-8dd4-a66849a2f509	fishcap_002	24.94	9.59	\N	2026-09-14 07:34:47.827334	0.00	f	0.00	0.00	t	643.70	13d3c394-ca4a-4198-9490-07bd0176bdbd
9ed46938-1b0c-4384-916e-82af7889cbea	fishcap_002	24.94	9.64	\N	2026-09-14 07:35:49.758375	0.00	f	0.00	0.00	t	639.85	13d3c394-ca4a-4198-9490-07bd0176bdbd
c7de7583-9656-4978-96cc-0927cf9f20c9	fishcap_002	24.94	9.55	\N	2026-09-14 07:36:51.205172	0.00	f	0.00	0.00	t	638.82	13d3c394-ca4a-4198-9490-07bd0176bdbd
54110137-7600-4eb5-be62-bd3fa898fad0	fishcap_002	25.00	9.60	\N	2026-09-14 07:37:53.43377	0.00	f	0.00	0.00	t	639.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
ec0ef00a-d1ac-4dca-b640-1e2645396e92	fishcap_002	25.00	9.64	\N	2026-09-14 07:38:54.580091	0.00	f	0.00	0.00	t	639.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
c5850ee4-61c0-4ca3-a29f-c6a1be4dc5fb	fishcap_002	25.00	9.60	\N	2026-09-14 07:39:56.297943	0.00	f	0.00	0.00	t	640.13	13d3c394-ca4a-4198-9490-07bd0176bdbd
78b472f9-0ae7-4c9c-bf25-3bdcd5dc7cc2	fishcap_002	25.00	9.62	\N	2026-09-14 07:40:57.940105	0.00	f	0.00	0.00	t	636.25	13d3c394-ca4a-4198-9490-07bd0176bdbd
9eb34762-2cf6-4c59-a5b3-02029bcabdec	fishcap_002	25.06	9.63	\N	2026-09-14 07:41:59.576716	0.00	f	0.00	0.00	t	634.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
3ad1395c-f10e-4f0b-9a9f-8d8a564c8326	fishcap_002	25.06	9.62	\N	2026-09-14 07:43:01.283777	0.00	f	0.00	0.00	t	637.70	13d3c394-ca4a-4198-9490-07bd0176bdbd
6406321f-0956-4819-8aef-10db14578331	fishcap_002	25.13	9.64	\N	2026-09-14 07:44:03.294593	0.00	f	0.00	0.00	t	643.08	13d3c394-ca4a-4198-9490-07bd0176bdbd
c948c96c-eab5-4ad9-a6f1-9c2b53e2ca95	fishcap_002	25.13	9.62	\N	2026-09-14 07:45:04.55598	0.00	f	0.00	0.00	t	636.32	13d3c394-ca4a-4198-9490-07bd0176bdbd
d80e4f71-31b9-4a09-8436-c5e2007b67d0	fishcap_002	25.13	9.64	\N	2026-09-14 07:46:07.009828	0.00	f	0.00	0.00	t	633.27	13d3c394-ca4a-4198-9490-07bd0176bdbd
c10de62d-dec4-4e03-8656-9888f4d2015d	fishcap_002	25.06	9.58	\N	2026-09-14 07:47:08.23515	0.00	f	0.00	0.00	t	634.68	13d3c394-ca4a-4198-9490-07bd0176bdbd
b338dfb9-9ffe-44e9-808b-9ae123118d10	fishcap_002	25.13	9.59	\N	2026-09-14 07:48:09.54232	0.00	f	0.00	0.00	t	636.91	13d3c394-ca4a-4198-9490-07bd0176bdbd
31531a4c-a0c8-4dfd-bb8e-721f10a3110a	fishcap_002	25.13	9.62	\N	2026-09-14 07:49:11.18603	0.00	f	0.00	0.00	t	639.85	13d3c394-ca4a-4198-9490-07bd0176bdbd
86ceb8ef-4bab-4386-b248-c3c0895704a6	fishcap_002	25.13	11.30	\N	2026-09-14 07:50:13.886034	0.00	f	0.00	0.00	t	644.81	13d3c394-ca4a-4198-9490-07bd0176bdbd
149b9380-d800-4bdd-9d75-d767779d72c6	fishcap_002	25.13	10.73	\N	2026-09-14 07:51:14.579371	0.00	f	0.00	0.00	t	644.19	13d3c394-ca4a-4198-9490-07bd0176bdbd
7ecbc77d-47db-43b6-bf3d-cbbf31d1f277	fishcap_002	25.13	10.41	\N	2026-09-14 07:52:16.222021	9.80	f	0.00	9.80	t	655.27	13d3c394-ca4a-4198-9490-07bd0176bdbd
9cfb102c-d821-40a1-8cb1-87fc76d20a8c	fishcap_002	25.13	9.43	\N	2026-09-14 07:53:17.873842	14.31	f	0.00	14.31	t	653.94	13d3c394-ca4a-4198-9490-07bd0176bdbd
df250a16-d17c-40fc-b27f-aaba21e252fd	fishcap_002	25.13	9.49	\N	2026-09-14 07:54:20.340614	13.91	f	0.00	13.91	t	655.09	13d3c394-ca4a-4198-9490-07bd0176bdbd
61f57f2e-6980-45fb-a9b3-c0a3baf806a3	fishcap_002	25.13	9.52	\N	2026-09-14 07:55:21.905479	13.97	f	0.00	13.97	t	640.88	13d3c394-ca4a-4198-9490-07bd0176bdbd
5494c80f-5bc4-4e60-afad-a8631bbd2cbd	fishcap_002	25.13	9.51	\N	2026-09-14 07:56:23.001083	13.85	f	0.00	13.85	t	664.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
a8ae38b5-4d90-452f-8539-4066c2194fd3	fishcap_002	25.13	9.52	\N	2026-09-14 07:57:24.623244	13.95	f	0.00	13.95	t	653.86	13d3c394-ca4a-4198-9490-07bd0176bdbd
d6ebbb64-0493-457b-b474-4d530971c9a0	fishcap_002	25.13	9.61	\N	2026-09-14 08:32:55.620976	1.62	f	0.00	1.62	t	644.38	13d3c394-ca4a-4198-9490-07bd0176bdbd
1163f0b0-12f6-4ed9-b167-afb753ed4a8e	fishcap_002	25.13	9.57	\N	2026-09-14 08:33:56.352204	1.94	f	0.00	1.94	t	644.17	13d3c394-ca4a-4198-9490-07bd0176bdbd
00cebcf9-d224-480c-a3da-4cfed60d06b8	fishcap_002	25.06	9.61	\N	2026-09-14 08:34:59.71756	2.36	f	0.00	2.36	t	642.04	13d3c394-ca4a-4198-9490-07bd0176bdbd
9b80202d-091e-45d6-ba71-4050bbb8b453	fishcap_002	25.13	9.57	\N	2026-09-14 08:36:00.502611	1.52	f	0.00	1.52	t	647.78	13d3c394-ca4a-4198-9490-07bd0176bdbd
6aba8768-7544-4444-9fa9-1e1dbdd13f83	fishcap_002	25.06	9.62	\N	2026-09-14 08:37:02.189976	1.80	f	0.00	1.80	t	644.23	13d3c394-ca4a-4198-9490-07bd0176bdbd
d656af3a-229d-4ba0-94c2-efe409f6d989	fishcap_002	25.13	9.59	\N	2026-09-14 08:38:03.90604	1.77	f	0.00	1.77	t	645.27	13d3c394-ca4a-4198-9490-07bd0176bdbd
639aa608-f2a2-4b10-b5dc-c8ccc70d3647	fishcap_002	25.13	9.59	\N	2026-09-14 08:39:05.46581	2.04	f	0.00	2.04	t	643.05	13d3c394-ca4a-4198-9490-07bd0176bdbd
763d536a-cbc0-41c0-b049-3a16eb645cd6	fishcap_002	25.13	9.61	\N	2026-09-14 08:40:08.334189	1.87	f	0.00	1.87	t	644.15	13d3c394-ca4a-4198-9490-07bd0176bdbd
1e2d4328-a302-43ad-a577-9f1b87e09ba0	fishcap_002	25.06	9.56	\N	2026-09-14 08:41:09.983077	1.52	f	0.00	1.52	t	643.21	13d3c394-ca4a-4198-9490-07bd0176bdbd
ffc92dd2-f3fb-432d-9432-d02ba0b2ce66	fishcap_002	25.06	9.59	\N	2026-09-14 08:42:10.694381	1.72	f	0.00	1.72	t	643.77	13d3c394-ca4a-4198-9490-07bd0176bdbd
bdc23ab2-1385-470d-b000-423c1d6a91bb	fishcap_002	25.06	9.62	\N	2026-09-14 08:43:12.348159	1.18	f	0.00	1.18	t	644.37	13d3c394-ca4a-4198-9490-07bd0176bdbd
c3c8b5e0-5ebc-4d2e-8816-e13ad5addade	fishcap_002	25.13	9.57	\N	2026-09-14 08:46:52.19044	1.48	f	0.00	1.48	t	646.85	13d3c394-ca4a-4198-9490-07bd0176bdbd
44d84a58-3f15-45f2-a20b-2a5540d61661	fishcap_002	25.13	9.60	\N	2026-09-14 08:47:54.49499	1.64	f	0.00	1.64	t	643.58	13d3c394-ca4a-4198-9490-07bd0176bdbd
a3ed124c-63b0-4c38-a217-d82fcd2b320f	fishcap_002	24.94	9.65	\N	2026-09-14 09:23:38.33196	1.63	f	0.00	1.63	t	643.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
3abe62f2-7363-4693-8666-db7ba607dd6d	fishcap_002	24.94	9.58	\N	2026-09-14 09:24:41.003267	2.19	f	0.00	2.19	t	645.13	13d3c394-ca4a-4198-9490-07bd0176bdbd
9eda9625-1a14-450f-ba59-4ed7c1307fd6	fishcap_002	24.94	9.65	\N	2026-09-14 09:25:43.451161	2.38	f	0.00	2.38	t	647.11	13d3c394-ca4a-4198-9490-07bd0176bdbd
57bae55d-3336-4e87-b73f-d0853a8e6b3e	fishcap_002	24.94	9.66	\N	2026-09-14 09:26:45.940311	2.11	f	0.00	2.11	t	644.69	13d3c394-ca4a-4198-9490-07bd0176bdbd
2875996d-0934-4891-aff7-3aeb33ff5851	fishcap_002	24.94	9.63	\N	2026-09-14 09:27:47.475602	0.00	f	0.00	0.00	t	647.11	13d3c394-ca4a-4198-9490-07bd0176bdbd
b101d22a-a5cc-47f1-8d85-fde97634ef86	fishcap_002	24.88	9.58	\N	2026-09-14 09:28:50.374518	0.00	f	0.00	0.00	t	646.27	13d3c394-ca4a-4198-9490-07bd0176bdbd
220349d2-2ad0-4c30-9444-0285f414f747	fishcap_002	24.88	9.63	\N	2026-09-14 09:29:50.940384	0.00	f	0.00	0.00	t	649.86	13d3c394-ca4a-4198-9490-07bd0176bdbd
82e33c63-6157-43d9-b3a3-f70ca786ef99	fishcap_002	24.88	9.68	\N	2026-09-14 09:30:52.59647	0.00	f	0.00	0.00	t	646.07	13d3c394-ca4a-4198-9490-07bd0176bdbd
f5f24b3e-ed1c-49e3-9594-314eea2a4975	fishcap_002	24.88	9.59	\N	2026-09-14 09:31:54.383315	0.00	f	0.00	0.00	t	642.70	13d3c394-ca4a-4198-9490-07bd0176bdbd
54fc1845-cdbe-4414-926c-d9861f18271c	fishcap_002	24.81	9.55	\N	2026-09-14 09:32:56.009496	0.00	f	0.00	0.00	t	642.96	13d3c394-ca4a-4198-9490-07bd0176bdbd
2950dc85-b993-43d5-82e7-862fce8cf030	fishcap_002	24.75	9.66	\N	2026-09-14 09:33:57.685926	0.00	f	0.00	0.00	t	642.42	13d3c394-ca4a-4198-9490-07bd0176bdbd
b271b624-1502-46c3-a99e-36902a734b3a	fishcap_002	24.69	9.56	\N	2026-09-14 09:35:00.430052	0.00	f	0.00	0.00	t	644.47	13d3c394-ca4a-4198-9490-07bd0176bdbd
b1e99d8c-d1f4-41b8-9a81-c3dc2ee7471b	fishcap_002	24.69	9.58	\N	2026-09-14 09:36:01.426469	0.00	f	0.00	0.00	t	641.68	13d3c394-ca4a-4198-9490-07bd0176bdbd
abac7312-a646-4506-9a1a-090058bf0647	fishcap_002	24.69	9.63	\N	2026-09-14 09:37:03.033628	0.00	f	0.00	0.00	t	641.57	13d3c394-ca4a-4198-9490-07bd0176bdbd
e5a5e1c1-ff06-4ae9-a398-0ba17cd57de8	fishcap_002	24.63	9.60	\N	2026-09-14 09:38:05.074065	0.00	f	0.00	0.00	t	641.92	13d3c394-ca4a-4198-9490-07bd0176bdbd
1885bb39-6e90-4826-ad35-46236eb33da6	fishcap_002	24.69	9.64	\N	2026-09-14 09:39:06.431674	0.00	f	0.00	0.00	t	643.61	13d3c394-ca4a-4198-9490-07bd0176bdbd
7135a6c4-f8bd-416b-9a51-9a61dc325129	fishcap_002	24.63	9.54	\N	2026-09-14 09:40:09.351218	0.00	f	0.00	0.00	t	640.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
923b69d6-ead0-4040-903f-6dbebf7f4a4a	fishcap_002	24.69	9.57	\N	2026-09-14 09:41:10.879374	0.00	f	0.00	0.00	t	645.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
1211c3b3-ddae-4135-a567-86ea9024a8fa	fishcap_002	24.69	9.52	\N	2026-09-14 09:42:12.660595	0.00	f	0.00	0.00	t	642.32	13d3c394-ca4a-4198-9490-07bd0176bdbd
4a095993-144a-4b5b-aa12-99b5b517e4fb	fishcap_002	24.63	9.58	\N	2026-09-14 09:43:14.289147	0.00	f	0.00	0.00	t	643.35	13d3c394-ca4a-4198-9490-07bd0176bdbd
5638dd2c-ba6b-4692-a881-4dd26c0f9e6d	fishcap_002	24.63	9.62	\N	2026-09-14 09:44:16.348239	0.00	f	0.00	0.00	t	645.06	13d3c394-ca4a-4198-9490-07bd0176bdbd
d20d01f3-1c22-4169-bb16-d2c665e2eca4	fishcap_002	25.00	10.50	\N	2026-09-14 09:44:19.751542	\N	\N	\N	50.00	t	700.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
6c5d3a3f-4772-4877-b2d8-37b3e1fcf75b	fishcap_002	24.63	9.57	\N	2026-09-14 09:45:17.802886	0.00	f	0.00	0.00	t	638.15	13d3c394-ca4a-4198-9490-07bd0176bdbd
3d67813d-a341-4a9c-bc54-7825d692ecc6	fishcap_002	24.56	9.68	\N	2026-09-14 09:46:20.335138	0.00	f	0.00	0.00	t	637.53	13d3c394-ca4a-4198-9490-07bd0176bdbd
393e97c2-a5d9-4103-bcb1-2ed344c6d7be	fishcap_002	24.63	9.61	\N	2026-09-14 09:47:23.129813	0.00	f	0.00	0.00	t	639.36	13d3c394-ca4a-4198-9490-07bd0176bdbd
e5d58548-5454-4e10-b983-792c40fb8805	fishcap_002	24.63	9.59	\N	2026-09-14 09:48:25.591667	0.00	f	0.00	0.00	t	640.13	13d3c394-ca4a-4198-9490-07bd0176bdbd
5d5d788c-b88c-4bc0-b290-d4035570c4d1	fishcap_002	24.56	9.57	\N	2026-09-14 09:49:27.443528	0.00	f	0.00	0.00	t	639.92	13d3c394-ca4a-4198-9490-07bd0176bdbd
442dcee0-82bf-45ed-974c-23765dd78e7a	fishcap_002	23.88	9.75	\N	2026-09-15 06:28:30.151559	6.45	f	0.00	6.45	t	0.22	13d3c394-ca4a-4198-9490-07bd0176bdbd
0e5ae8ed-4274-4732-8395-966e21a4620b	fishcap_002	24.38	9.76	\N	2026-09-15 06:29:32.206596	8.71	f	0.00	8.71	t	0.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
5330838a-a75b-4db9-b084-e0dc9ac2002a	fishcap_002	24.63	9.76	\N	2026-09-15 06:30:34.672366	11.05	f	0.00	11.05	t	0.12	13d3c394-ca4a-4198-9490-07bd0176bdbd
e45e6f86-34b2-4ce1-895a-bf82b489f506	fishcap_002	24.75	9.75	\N	2026-09-15 06:31:36.5231	13.23	f	0.00	13.23	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
e9ed76a1-28ef-41d6-ba98-b5af124c12b2	fishcap_002	24.75	9.77	\N	2026-09-15 06:32:37.56723	15.14	f	0.00	15.14	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
e0fa3aee-5176-4b13-8791-a961dc761cfe	fishcap_002	24.75	9.76	\N	2026-09-15 06:33:38.989278	16.97	f	0.00	16.97	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
fa1bd95e-ff71-4702-a19e-5072ebb78854	fishcap_002	24.81	9.76	\N	2026-09-15 06:34:41.039455	18.49	f	0.00	18.49	t	0.03	13d3c394-ca4a-4198-9490-07bd0176bdbd
fd3fb94b-f958-4fab-8037-18ad7610cb25	fishcap_002	24.88	9.76	\N	2026-09-15 06:35:42.825858	19.94	f	0.00	19.94	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
4994ba3e-d626-4f6c-b85c-6fe2ebe02d4c	fishcap_002	24.88	9.76	\N	2026-09-15 06:36:47.422829	21.07	f	0.00	21.07	t	0.17	13d3c394-ca4a-4198-9490-07bd0176bdbd
159a6b86-e94e-43fe-940a-aacd88e2caab	fishcap_002	24.94	9.75	\N	2026-09-15 06:38:05.241998	0.99	f	0.00	0.99	t	76.45	13d3c394-ca4a-4198-9490-07bd0176bdbd
b96e9411-f821-44da-a8cb-841ec24e7d09	fishcap_002	24.94	9.76	\N	2026-09-15 06:39:13.744999	1.93	f	0.00	1.93	t	28.92	13d3c394-ca4a-4198-9490-07bd0176bdbd
cd4149a5-5881-4c71-84ae-f49fe8ba1cc6	fishcap_002	24.94	9.77	\N	2026-09-15 06:40:21.397377	3.48	f	0.00	3.48	t	63.98	13d3c394-ca4a-4198-9490-07bd0176bdbd
dafac6e4-3abe-4c72-a65b-a6a0c0ed193f	fishcap_002	25.56	9.75	\N	2026-09-15 07:02:58.759923	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
912bf4b4-f879-4f5f-8528-065f9d6fcc7d	fishcap_002	25.63	9.77	\N	2026-09-15 07:04:03.998506	0.00	f	0.00	0.00	t	0.91	13d3c394-ca4a-4198-9490-07bd0176bdbd
466ff531-de75-4d23-9876-d8ae6b3ba3c3	fishcap_002	25.56	9.76	\N	2026-09-15 07:05:06.220429	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
ba79dce7-d55a-448d-9755-94df9a16ab60	fishcap_002	25.56	9.77	\N	2026-09-15 07:06:10.532723	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
ab8e765b-ab49-4b44-a120-ad15433bd0cb	fishcap_002	25.56	9.76	\N	2026-09-15 07:07:15.098414	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
0774d0c5-b288-4784-89eb-c2fa4a69926a	fishcap_002	25.56	9.76	\N	2026-09-15 07:08:15.465342	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
409ff8a9-2fca-4b6d-a0d9-ffec3fc081e8	fishcap_002	25.56	9.76	\N	2026-09-15 07:09:22.63079	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
48ac06c8-469f-4870-849a-74a46c4b6c51	fishcap_002	25.56	9.75	\N	2026-09-15 07:10:29.718061	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
010721f9-c69e-4d2a-b575-1271a291f437	fishcap_002	25.56	9.76	\N	2026-09-15 07:11:34.809122	2481.09	f	0.00	2481.09	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
be46a472-6167-40fe-82fb-74187a9f43c0	fishcap_002	25.56	9.77	\N	2026-09-15 07:12:35.16604	2420.90	f	0.00	2420.90	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
4c91a998-677d-40c7-85c0-d368cf6465f6	fishcap_002	25.56	9.76	\N	2026-09-15 07:13:35.209353	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
e50fd6ca-b15f-4b28-8bc2-c7af786995e4	fishcap_002	25.56	9.76	\N	2026-09-15 07:14:44.358752	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
828c1df5-89b5-4040-b6c1-426b3ccdfb3d	fishcap_002	25.56	9.76	\N	2026-09-15 07:15:48.871219	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
d4953e0a-4e74-4b5e-b0b5-7ff769945c8d	fishcap_002	25.56	9.76	\N	2026-09-15 07:16:54.710315	2497.44	f	0.00	2497.44	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
b10f7336-3366-415e-959e-0ba33cce9485	fishcap_002	25.63	9.76	\N	2026-09-15 07:17:58.592133	2497.74	f	0.00	2497.74	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
3f2adec6-093a-4a6a-85a1-a8201d2073a1	fishcap_002	25.56	9.77	\N	2026-09-15 07:18:58.617609	2497.83	f	0.00	2497.83	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
abbf57dd-a507-4333-97ae-6b97133f7baf	fishcap_002	25.63	9.78	\N	2026-09-15 07:19:58.615673	2498.11	f	0.00	2498.11	f	1.03	13d3c394-ca4a-4198-9490-07bd0176bdbd
7b9f4c6b-87ed-479f-a59b-329ee0802b4d	fishcap_002	25.63	9.76	\N	2026-09-15 07:21:02.1939	2483.45	f	0.00	2483.45	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
2f1719f5-0b5c-4f70-a8a9-71bf1f479ab3	fishcap_002	25.63	9.76	\N	2026-09-15 07:22:06.600419	2498.60	f	0.00	2498.60	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
2541bad7-f6fd-493b-a28a-7c25aa7e8ffa	fishcap_002	25.63	9.75	\N	2026-09-15 07:23:12.046412	2498.93	f	0.00	2498.93	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
91588c2b-12b9-4a81-920c-9c703fe71ca7	fishcap_002	25.63	9.75	\N	2026-09-15 07:24:12.262503	2498.94	f	0.00	2498.94	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
0751893b-bc49-4e3a-870d-33735b1bfe82	fishcap_002	25.69	9.76	\N	2026-09-15 07:25:13.903179	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
daaff78e-c5a0-4f80-bb98-18c75c0331d2	fishcap_002	25.69	9.76	\N	2026-09-15 07:26:16.983797	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
5325a84e-ce0f-4b25-975d-669d42afb902	fishcap_002	25.75	9.76	\N	2026-09-15 07:27:20.260968	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
4aed4cde-5196-4454-a9fa-75886d6888a0	fishcap_002	25.81	9.76	\N	2026-09-15 07:28:31.32175	2152.56	f	0.00	2152.56	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
f34db3e5-3919-46cc-9b0d-7c1d518951cd	fishcap_002	25.81	9.76	\N	2026-09-15 07:29:43.317486	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
176fa80a-580c-43d3-be81-9a16768d8df8	fishcap_002	25.81	9.76	\N	2026-09-15 07:30:44.301955	2500.21	f	0.00	2500.21	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
8b9c0ed1-3738-4d54-a4cc-578fc98fa3b8	fishcap_002	25.81	9.76	\N	2026-09-15 07:31:43.849619	2500.23	f	0.00	2500.23	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
6a3626f4-1d5e-46b1-839e-bee4ed73bf18	fishcap_002	25.75	9.77	\N	2026-09-15 07:32:49.387451	2500.59	f	0.00	2500.59	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
0e7b9db1-ba34-43e5-9e59-6c6225be5da8	fishcap_002	25.81	9.77	\N	2026-09-15 07:33:49.834347	2500.73	f	0.00	2500.73	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
33ed9465-f212-4af7-b161-64d342423452	fishcap_002	25.81	9.78	\N	2026-09-15 07:34:52.071805	2500.98	f	0.00	2500.98	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
a8442005-a267-4ba4-a69b-8444a4cc4db4	fishcap_002	25.75	9.78	\N	2026-09-15 07:35:50.170849	2501.20	f	0.00	2501.20	f	0.16	13d3c394-ca4a-4198-9490-07bd0176bdbd
91a2d23d-5cad-4c0f-aae6-652e253af05a	fishcap_002	25.75	9.76	\N	2026-09-15 07:36:49.620479	2501.40	f	0.00	2501.40	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
0d7816b7-7523-44f5-bbed-47e8ca5fdad1	fishcap_002	25.69	9.76	\N	2026-09-15 07:37:50.232553	2501.64	f	0.00	2501.64	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
f3b29c60-4c54-4f51-acab-d2971da019c9	fishcap_002	25.69	9.76	\N	2026-09-15 07:38:55.446304	2501.64	f	0.00	2501.64	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
1c505e7c-c014-43a9-8796-8712562d7bb0	fishcap_002	25.69	9.76	\N	2026-09-15 07:39:54.749019	2501.87	f	0.00	2501.87	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
4ff2118d-a126-4a6b-8709-b7f3df892c78	fishcap_002	25.69	9.78	\N	2026-09-15 07:40:54.347021	2502.10	f	0.00	2502.10	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
1f2990f0-5d47-4268-895b-9cb9c4844b6f	fishcap_002	25.69	9.77	\N	2026-09-15 07:41:59.268484	2502.30	f	0.00	2502.30	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
423321f4-1e5b-40e3-8e50-45123b7d5ec7	fishcap_002	25.69	9.76	\N	2026-09-15 07:43:00.290447	2502.44	f	0.00	2502.44	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
9757037c-706c-4f2a-b8ed-59b3561e3fdc	fishcap_002	25.69	9.77	\N	2026-09-15 07:43:59.274233	2502.61	f	0.00	2502.61	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
ea8a4cf8-61ef-4fe3-b637-fc9aef3eaf5e	fishcap_002	25.69	9.76	\N	2026-09-15 07:44:59.489281	2502.64	f	0.00	2502.64	f	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
b6fb1481-26e7-4167-b25f-786e9bef83df	fishcap_002	26.19	9.75	\N	2026-09-15 09:49:11.880281	5.13	f	0.00	5.13	t	851.71	13d3c394-ca4a-4198-9490-07bd0176bdbd
824268a8-fbf3-45af-a959-1748aaf591f4	fishcap_002	26.06	9.75	\N	2026-09-15 09:50:14.528182	7.87	f	0.00	7.87	t	840.84	13d3c394-ca4a-4198-9490-07bd0176bdbd
5b121b1d-14d4-4d1b-b588-e318e6531608	fishcap_002	26.06	10.09	\N	2026-09-15 09:51:14.318574	7.22	f	0.00	7.22	t	1031.97	13d3c394-ca4a-4198-9490-07bd0176bdbd
8b217d9c-d030-42a7-a5d0-59e732f43763	fishcap_002	26.13	10.16	\N	2026-09-15 09:52:14.527853	5.29	f	0.00	5.29	t	1022.75	13d3c394-ca4a-4198-9490-07bd0176bdbd
c4e88315-f56f-4bd3-b4f9-711e8dfe6e3a	fishcap_002	26.13	10.29	\N	2026-09-15 09:53:13.823474	4.54	f	0.00	4.54	t	1028.82	13d3c394-ca4a-4198-9490-07bd0176bdbd
22592eb0-9841-4a41-8071-fd3b33e87eb1	fishcap_002	26.13	10.36	\N	2026-09-15 09:54:13.804649	5.59	f	0.00	5.59	t	1041.36	13d3c394-ca4a-4198-9490-07bd0176bdbd
4cea5251-fb7e-4dad-82f1-cbfa05afb8d2	fishcap_002	26.06	11.52	\N	2026-09-15 09:55:18.87592	5.33	f	0.00	5.33	t	246.09	13d3c394-ca4a-4198-9490-07bd0176bdbd
17903803-95af-469a-915e-4400fd7143ee	fishcap_002	23.13	10.85	\N	2026-09-15 09:56:19.103843	5.32	f	0.00	5.32	t	34.12	13d3c394-ca4a-4198-9490-07bd0176bdbd
9bdc9ecd-a390-41c2-bc46-c275cd27a697	fishcap_002	23.06	10.70	\N	2026-09-15 09:57:18.883674	5.04	f	0.00	5.04	t	33.04	13d3c394-ca4a-4198-9490-07bd0176bdbd
7a72a33d-8ec6-40b2-83fa-8e5d431383a9	fishcap_002	23.06	10.66	\N	2026-09-15 09:58:23.987143	4.01	f	0.00	4.01	t	34.03	13d3c394-ca4a-4198-9490-07bd0176bdbd
b81d8946-8578-4db0-bda9-4aaaf6987afd	fishcap_002	23.13	10.47	\N	2026-09-15 09:59:23.987829	3.68	f	0.00	3.68	t	1.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
18e03882-741b-4ab3-812b-4dc305f5d965	fishcap_002	23.13	10.51	\N	2026-09-15 10:00:24.607904	3.38	f	0.00	3.38	t	36.26	13d3c394-ca4a-4198-9490-07bd0176bdbd
6414d788-7111-4075-b3ed-eb215d2285ba	fishcap_002	23.13	10.33	\N	2026-09-15 10:01:27.305298	4.12	f	0.00	4.12	t	33.61	13d3c394-ca4a-4198-9490-07bd0176bdbd
3d874972-d19a-4307-a70a-cbe31b96e920	fishcap_002	23.25	10.58	\N	2026-09-15 10:02:27.923223	1.61	f	0.00	1.61	t	26.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
0c0b654d-e6b9-4117-8d41-c71ee97799fb	fishcap_002	23.31	10.56	\N	2026-09-15 10:03:26.957959	1.00	f	0.00	1.00	t	16.42	13d3c394-ca4a-4198-9490-07bd0176bdbd
c023487f-862e-44e3-8e8a-0a7753edc2d2	fishcap_002	23.31	10.55	\N	2026-09-15 10:04:32.035977	0.00	f	0.00	0.00	t	17.21	13d3c394-ca4a-4198-9490-07bd0176bdbd
9feb2788-1878-49e4-bc6b-a31c78f47705	fishcap_002	23.38	10.52	\N	2026-09-15 10:05:32.65382	0.00	f	0.00	0.00	t	24.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
1bdd13ab-c1f7-4c65-985a-1a4a421a799b	fishcap_002	23.38	10.50	\N	2026-09-15 10:06:31.873485	0.00	f	0.00	0.00	t	27.65	13d3c394-ca4a-4198-9490-07bd0176bdbd
4948fd89-a2dd-4e71-a3aa-f0570084badc	fishcap_002	23.38	10.51	\N	2026-09-15 10:07:37.993491	0.00	f	0.00	0.00	t	25.53	13d3c394-ca4a-4198-9490-07bd0176bdbd
f39f5570-aa40-4a16-b47f-315410b72879	fishcap_002	23.38	10.49	\N	2026-09-15 10:08:37.0274	0.00	f	0.00	0.00	t	31.45	13d3c394-ca4a-4198-9490-07bd0176bdbd
43a512ef-a3e9-4487-9ce1-eda7e6417146	fishcap_002	23.38	9.65	\N	2026-09-15 10:09:37.016374	0.00	f	0.00	0.00	t	33.91	13d3c394-ca4a-4198-9490-07bd0176bdbd
3a720737-a6f1-4956-b7d3-1a7e8bc657c1	fishcap_002	29.75	9.93	\N	2026-09-15 14:53:19.542226	4.00	f	0.00	4.00	t	0.39	13d3c394-ca4a-4198-9490-07bd0176bdbd
6d319a11-dd61-48fd-9185-daa33d257e10	fishcap_002	29.69	9.93	\N	2026-09-15 14:54:24.490982	3.84	f	0.00	3.84	t	0.37	13d3c394-ca4a-4198-9490-07bd0176bdbd
e5aa8d93-df0b-42f4-8ee1-835c3c11d560	fishcap_002	29.69	9.92	\N	2026-09-15 14:55:24.472035	3.89	f	0.00	3.89	t	0.38	13d3c394-ca4a-4198-9490-07bd0176bdbd
8e437587-8168-4766-9351-d1c6fb8f4bd2	fishcap_002	29.69	9.93	\N	2026-09-15 14:56:24.476836	4.64	f	0.00	4.64	t	0.38	13d3c394-ca4a-4198-9490-07bd0176bdbd
9aa51ec0-695f-42e1-879b-ead90e1fd88a	fishcap_002	29.63	9.92	\N	2026-09-15 14:57:29.522622	4.26	f	0.00	4.26	t	0.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
1cd72213-f4c4-4a6c-9db8-5b1d5bc79aeb	fishcap_002	29.63	9.92	\N	2026-09-15 14:58:29.509639	3.73	f	0.00	3.73	t	0.31	13d3c394-ca4a-4198-9490-07bd0176bdbd
35460d34-7bf0-432f-ad26-c879f663bb8a	fishcap_002	29.63	9.92	\N	2026-09-15 14:59:29.526412	3.24	f	0.00	3.24	t	0.40	13d3c394-ca4a-4198-9490-07bd0176bdbd
cd4f292f-1327-4880-89a0-8df16514a823	fishcap_002	29.50	9.95	\N	2026-09-15 15:00:34.733979	6.09	f	0.00	6.09	t	0.36	13d3c394-ca4a-4198-9490-07bd0176bdbd
387b8a2d-14e6-4b96-a027-c1b9b038107b	fishcap_002	28.94	9.96	\N	2026-09-15 15:01:34.370536	4.84	f	0.00	4.84	t	91.33	13d3c394-ca4a-4198-9490-07bd0176bdbd
3c59eff1-3e7c-49ae-ac75-67d079097dcf	fishcap_002	28.88	9.95	\N	2026-09-15 15:02:34.411865	6.88	f	0.00	6.88	t	69.18	13d3c394-ca4a-4198-9490-07bd0176bdbd
d307fa13-e63b-4b94-98d4-14990574fc14	fishcap_002	28.88	9.76	\N	2026-09-15 15:03:39.170659	3.97	f	0.00	3.97	t	68.32	13d3c394-ca4a-4198-9490-07bd0176bdbd
d81b1b2a-21e5-4fb6-81cc-7dca6d0a7b21	fishcap_002	28.75	9.70	\N	2026-09-15 15:04:39.179694	0.00	f	0.00	0.00	t	67.72	13d3c394-ca4a-4198-9490-07bd0176bdbd
270ce708-d27a-42ae-8ae1-a9356b7e98ae	fishcap_002	28.75	9.67	\N	2026-09-15 15:05:39.194087	0.00	f	0.00	0.00	t	67.50	13d3c394-ca4a-4198-9490-07bd0176bdbd
da2307f5-efdc-4e2e-b4bc-06e14388046d	fishcap_002	28.75	9.65	\N	2026-09-15 15:06:44.598862	0.00	f	0.00	0.00	t	68.10	13d3c394-ca4a-4198-9490-07bd0176bdbd
a7bb32f6-3c10-4433-b55d-ef22765bf1ad	fishcap_002	28.75	9.65	\N	2026-09-15 15:07:44.846578	0.00	f	0.00	0.00	t	69.98	13d3c394-ca4a-4198-9490-07bd0176bdbd
12a10245-9bfa-424b-b1b1-fa9b4de0ccf2	fishcap_002	28.69	9.64	\N	2026-09-15 15:08:44.574863	2.45	f	0.00	2.45	t	67.18	13d3c394-ca4a-4198-9490-07bd0176bdbd
2748d372-8bb8-47e6-a780-36782a520979	fishcap_002	28.69	9.63	\N	2026-09-15 15:09:50.194595	3.06	f	0.00	3.06	t	67.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
5ab4183e-a7aa-4e3c-a292-9560cd95386d	fishcap_002	28.69	9.64	\N	2026-09-15 15:10:50.182637	2.56	f	0.00	2.56	t	67.53	13d3c394-ca4a-4198-9490-07bd0176bdbd
76bff8e9-1134-4aca-b5af-5df6cedab704	fishcap_002	28.69	9.63	\N	2026-09-15 15:11:49.88608	0.92	f	0.00	0.92	t	69.76	13d3c394-ca4a-4198-9490-07bd0176bdbd
e9506139-a614-4633-ac71-95d354e61d38	fishcap_002	28.69	9.63	\N	2026-09-15 15:12:55.115696	1.79	f	0.00	1.79	t	68.84	13d3c394-ca4a-4198-9490-07bd0176bdbd
dd9601fe-021a-4fa1-9667-66bb256f9432	fishcap_002	28.69	9.62	\N	2026-09-15 15:13:55.314651	0.95	f	0.00	0.95	t	69.44	13d3c394-ca4a-4198-9490-07bd0176bdbd
609f13d6-bdc9-4a76-8677-a209a6c7962b	fishcap_002	28.75	9.63	\N	2026-09-15 15:14:55.696898	2.45	f	0.00	2.45	t	68.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
e1401032-50e6-40b8-8fbb-22711df30f61	fishcap_002	28.75	9.64	\N	2026-09-15 15:15:55.081029	2.17	f	0.00	2.17	t	68.19	13d3c394-ca4a-4198-9490-07bd0176bdbd
6b453c29-2bf1-49cf-8333-72805463987a	fishcap_002	29.00	9.62	\N	2026-09-15 15:17:00.259452	4.65	f	0.00	4.65	t	0.43	13d3c394-ca4a-4198-9490-07bd0176bdbd
4843374a-cc39-4a16-bdf4-c01c8b925a5b	fishcap_002	29.19	9.62	\N	2026-09-15 15:18:01.383023	7.47	f	0.00	7.47	t	74.09	13d3c394-ca4a-4198-9490-07bd0176bdbd
56b9fcce-b05e-46a0-b915-736e1b6cd7b3	fishcap_002	29.31	9.62	\N	2026-09-15 15:19:01.68937	5.58	f	0.00	5.58	t	71.33	13d3c394-ca4a-4198-9490-07bd0176bdbd
a8fd896d-c02d-4aba-a709-f940bec4b8c5	fishcap_002	29.31	10.91	\N	2026-09-15 15:20:01.378025	4.47	f	0.00	4.47	t	73.56	13d3c394-ca4a-4198-9490-07bd0176bdbd
47f09d2e-156f-45dd-941a-f4a6745d2bbc	fishcap_002	29.06	10.20	\N	2026-09-15 15:21:01.69852	5.44	f	0.00	5.44	t	69.77	13d3c394-ca4a-4198-9490-07bd0176bdbd
030d0900-4fa6-49c0-afa1-605f534a1ec6	fishcap_002	28.81	9.40	\N	2026-09-15 15:22:06.425978	11.78	f	0.00	11.78	t	64.39	13d3c394-ca4a-4198-9490-07bd0176bdbd
776468df-bad2-4bb9-9662-de954aa03f47	fishcap_002	28.81	9.45	\N	2026-09-15 15:23:06.463718	5.94	f	0.00	5.94	t	65.43	13d3c394-ca4a-4198-9490-07bd0176bdbd
a0f4a3d2-c0a7-4f0d-bba6-677772b9e805	fishcap_002	28.81	9.48	\N	2026-09-15 15:24:06.384923	5.76	f	0.00	5.76	t	65.65	13d3c394-ca4a-4198-9490-07bd0176bdbd
fadcb1fb-fe52-497f-83e2-2f8ca6bec8c4	fishcap_002	28.81	9.49	\N	2026-09-15 15:25:11.362508	6.74	f	0.00	6.74	t	65.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
e626386d-a26f-4567-9d65-996c010f0c8f	fishcap_002	28.81	9.52	\N	2026-09-15 15:26:12.437474	6.87	f	0.00	6.87	t	65.41	13d3c394-ca4a-4198-9490-07bd0176bdbd
06fa4991-f333-403d-9f11-6988082943f3	fishcap_002	28.81	9.54	\N	2026-09-15 15:27:12.439025	7.94	f	0.00	7.94	t	66.33	13d3c394-ca4a-4198-9490-07bd0176bdbd
e91cffa7-c99e-444e-bdb2-9957331052f2	fishcap_002	28.81	9.54	\N	2026-09-15 15:28:12.448353	7.89	f	0.00	7.89	t	64.63	13d3c394-ca4a-4198-9490-07bd0176bdbd
32cdd869-a669-4b37-9a84-46f588e7aa1e	fishcap_002	28.88	9.56	\N	2026-09-15 15:29:17.937217	7.16	f	0.00	7.16	t	64.90	13d3c394-ca4a-4198-9490-07bd0176bdbd
63a40e12-7aa0-4da1-8619-d2b791d24620	fishcap_002	28.81	9.56	\N	2026-09-15 15:30:18.248356	7.29	f	0.00	7.29	t	60.49	13d3c394-ca4a-4198-9490-07bd0176bdbd
b4c8c673-4c32-4e5a-b767-1b1384740033	fishcap_002	28.88	9.56	\N	2026-09-15 15:31:18.362552	7.28	f	0.00	7.28	t	65.35	13d3c394-ca4a-4198-9490-07bd0176bdbd
f6b42a73-d240-4908-8bce-73c9315c45a8	fishcap_002	28.81	9.58	\N	2026-09-15 15:32:18.981824	5.47	f	0.00	5.47	t	64.77	13d3c394-ca4a-4198-9490-07bd0176bdbd
04fcb099-9400-4b69-abd4-6ff75c34fa0c	fishcap_002	28.88	9.57	\N	2026-09-15 15:33:18.312737	8.82	f	0.00	8.82	t	64.69	13d3c394-ca4a-4198-9490-07bd0176bdbd
18f0ec09-3771-4625-ba3f-dcf3bdc7a31f	fishcap_002	28.88	9.58	\N	2026-09-15 15:34:23.279123	7.03	f	0.00	7.03	t	63.58	13d3c394-ca4a-4198-9490-07bd0176bdbd
04768f46-2195-4efc-add4-83cfc1ffb3ac	fishcap_002	28.88	9.57	\N	2026-09-15 15:35:23.330472	8.43	f	0.00	8.43	t	64.80	13d3c394-ca4a-4198-9490-07bd0176bdbd
30d4edb6-8630-4d55-96ec-ee1ce9354977	fishcap_002	28.88	9.57	\N	2026-09-15 15:36:23.321104	5.45	f	0.00	5.45	t	65.15	13d3c394-ca4a-4198-9490-07bd0176bdbd
426a382c-600f-44ce-a791-77c972297821	fishcap_002	28.88	9.57	\N	2026-09-15 15:37:29.04451	6.32	f	0.00	6.32	t	64.98	13d3c394-ca4a-4198-9490-07bd0176bdbd
d5b85026-06a1-4f70-a296-4fae3665773f	fishcap_002	28.88	9.58	\N	2026-09-15 15:38:28.144596	5.99	f	0.00	5.99	t	63.99	13d3c394-ca4a-4198-9490-07bd0176bdbd
92b5e68b-009f-4cae-aa46-07282a7a19b0	fishcap_002	28.88	9.52	\N	2026-09-15 15:39:28.152861	6.94	f	0.00	6.94	t	57.46	13d3c394-ca4a-4198-9490-07bd0176bdbd
02f22fe1-5fb0-4e86-ae62-db116a900d17	fishcap_002	28.94	9.54	\N	2026-09-15 15:40:33.14269	6.97	f	0.00	6.97	t	51.98	13d3c394-ca4a-4198-9490-07bd0176bdbd
e90935ef-eb65-408f-a8df-1fd81428360f	fishcap_002	28.94	9.55	\N	2026-09-15 15:41:33.998482	6.94	f	0.00	6.94	t	52.12	13d3c394-ca4a-4198-9490-07bd0176bdbd
524b9101-fdf4-4f47-b7e9-1b37469d720f	fishcap_002	28.94	9.55	\N	2026-09-15 15:42:33.998736	6.94	f	0.00	6.94	t	51.84	13d3c394-ca4a-4198-9490-07bd0176bdbd
0842b0e4-0261-4fef-8cb0-915e249443da	fishcap_002	28.94	9.54	\N	2026-09-15 15:43:33.598373	6.97	f	0.00	6.97	t	44.29	13d3c394-ca4a-4198-9490-07bd0176bdbd
30b32ab9-8936-4d3b-a85d-c98aff4da7f0	fishcap_002	29.06	9.53	\N	2026-09-15 15:44:33.025521	6.97	f	0.00	6.97	t	43.39	13d3c394-ca4a-4198-9490-07bd0176bdbd
41458e88-7601-4222-a8ae-b3797e2ebd0d	fishcap_002	29.00	9.54	\N	2026-09-15 15:45:38.407212	7.10	f	0.00	7.10	t	41.95	13d3c394-ca4a-4198-9490-07bd0176bdbd
26a8b3bd-3dd6-4e77-acef-5f1dff77b04e	fishcap_002	29.00	9.54	\N	2026-09-15 15:46:39.350629	7.09	f	0.00	7.09	t	42.61	13d3c394-ca4a-4198-9490-07bd0176bdbd
347f9a4d-016c-4432-bace-9328140309dd	fishcap_002	29.06	9.54	\N	2026-09-15 15:47:38.413332	7.17	f	0.00	7.17	t	42.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
12152b75-d6b8-4170-805b-635396e305cc	fishcap_002	29.00	9.54	\N	2026-09-15 15:48:39.312979	7.19	f	0.00	7.19	t	41.62	13d3c394-ca4a-4198-9490-07bd0176bdbd
f43236a0-0c6f-49e4-aa9e-00699d10f854	fishcap_002	29.13	9.54	\N	2026-09-15 15:49:39.371877	7.10	f	0.00	7.10	t	36.51	13d3c394-ca4a-4198-9490-07bd0176bdbd
a7309648-4a61-4015-971e-665893633af9	fishcap_002	29.19	9.55	\N	2026-09-15 15:50:39.37341	7.14	f	0.00	7.14	t	37.27	13d3c394-ca4a-4198-9490-07bd0176bdbd
19d4c51d-f431-44a1-b131-9f3258fb06d5	fishcap_002	29.25	9.56	\N	2026-09-15 15:51:38.780273	7.12	f	0.00	7.12	t	37.09	13d3c394-ca4a-4198-9490-07bd0176bdbd
d077e029-f47d-4134-8dd7-bafdf8490154	fishcap_002	29.25	9.56	\N	2026-09-15 15:52:43.66789	7.12	f	0.00	7.12	t	36.80	13d3c394-ca4a-4198-9490-07bd0176bdbd
a5d84a95-287d-4be8-aa35-0329a1c0d00a	fishcap_002	29.31	9.56	\N	2026-09-15 15:53:43.684141	7.14	f	0.00	7.14	t	34.09	13d3c394-ca4a-4198-9490-07bd0176bdbd
acf47e0a-417b-4f63-a67c-b64c2aea18dd	fishcap_002	29.31	9.57	\N	2026-09-15 15:54:43.671492	5.67	f	0.00	5.67	t	36.56	13d3c394-ca4a-4198-9490-07bd0176bdbd
c19cd8ee-1a7e-45ae-870e-8c4b0fd848a6	fishcap_002	29.31	9.56	\N	2026-09-15 15:55:48.623522	6.41	f	0.00	6.41	t	0.02	13d3c394-ca4a-4198-9490-07bd0176bdbd
4ccf0173-a4e8-4199-ac4c-50a103f48eac	fishcap_002	29.31	9.57	\N	2026-09-15 15:56:48.622619	7.40	f	0.00	7.40	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
c960a023-fcd6-457e-9415-7881ef8d954b	fishcap_002	29.38	9.57	\N	2026-09-15 15:57:48.640327	7.37	f	0.00	7.37	t	1.29	13d3c394-ca4a-4198-9490-07bd0176bdbd
bad68e98-a21c-4a5b-bafb-bcbcb6985579	fishcap_002	29.38	9.57	\N	2026-09-15 15:58:53.558826	7.36	f	0.00	7.36	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
be315e07-784a-4e30-80a1-7e42e0f0891a	fishcap_002	29.44	9.58	\N	2026-09-15 15:59:53.582636	7.32	f	0.00	7.32	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
e8696463-6c6e-4d1d-a5d6-71b483828644	fishcap_002	29.44	9.58	\N	2026-09-15 16:00:53.619915	7.38	f	0.00	7.38	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
41f7e34a-26d7-4d7b-af51-6781daca56e2	fishcap_002	29.44	9.58	\N	2026-09-15 16:01:59.319203	7.33	f	0.00	7.33	t	0.13	13d3c394-ca4a-4198-9490-07bd0176bdbd
aba71ddf-7878-4d08-a015-d0296b1e6ce2	fishcap_002	29.44	9.58	\N	2026-09-15 16:02:58.40291	7.31	f	0.00	7.31	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
6c74aa10-f3e8-413b-a362-6e7d6b07f8ad	fishcap_002	29.44	9.59	\N	2026-09-15 16:03:58.72659	6.56	f	0.00	6.56	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
76ed11a4-daa1-4d28-8101-6859b3f4ae8a	fishcap_002	29.44	9.59	\N	2026-09-15 16:05:03.743228	9.88	f	0.00	9.88	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
876f1158-028e-423b-805c-6d6dbdbf7855	fishcap_002	29.44	9.59	\N	2026-09-15 16:07:59.7955	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
0a8f37d5-504b-4db7-b768-50ad8e2194cd	fishcap_002	29.44	9.58	\N	2026-09-15 16:08:59.966464	0.00	f	0.00	0.00	t	3.09	13d3c394-ca4a-4198-9490-07bd0176bdbd
3d7d0ce0-dc30-484e-a8f1-5284f6514fb3	fishcap_002	29.44	9.59	\N	2026-09-15 16:09:59.995467	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
1baa442d-0d74-4a18-ab91-6828d03a61e7	fishcap_002	29.44	9.59	\N	2026-09-15 16:10:59.991875	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
6422eadc-1c90-4154-9bf6-b29dfd75a716	fishcap_002	29.44	9.60	\N	2026-09-15 16:11:59.64079	0.00	f	0.00	0.00	t	0.00	13d3c394-ca4a-4198-9490-07bd0176bdbd
5e0eb6f8-53b8-44c3-a29f-0898b1646577	fishcap_002	24.50	9.91	\N	2026-09-16 02:48:46.477347	0.03	f	0.00	0.03	t	0.17	13d3c394-ca4a-4198-9490-07bd0176bdbd
157f15d5-a6da-4194-b99f-83481ec0f7e9	fishcap_002	24.19	9.93	\N	2026-09-16 02:49:58.861833	0.00	f	0.00	0.00	t	0.74	13d3c394-ca4a-4198-9490-07bd0176bdbd
8749b733-8a8f-4e88-88ba-c7146d21c021	fishcap_002	24.25	9.93	\N	2026-09-16 02:51:02.776454	0.00	f	0.00	0.00	t	1.49	13d3c394-ca4a-4198-9490-07bd0176bdbd
d6788900-4725-451d-9d35-ea000c5d9de3	fishcap_002	24.31	9.94	\N	2026-09-16 02:52:06.323836	0.00	f	0.00	0.00	t	0.06	13d3c394-ca4a-4198-9490-07bd0176bdbd
ac81b93a-55f2-47ef-8f77-a0281c674718	fishcap_002	24.38	9.95	\N	2026-09-16 02:53:05.675284	0.00	f	0.00	0.00	t	1.33	13d3c394-ca4a-4198-9490-07bd0176bdbd
693db77e-3bcf-498e-8aae-c31131ba00ce	fishcap_002	24.38	9.94	\N	2026-09-16 02:54:05.967645	0.00	f	0.00	0.00	t	0.75	13d3c394-ca4a-4198-9490-07bd0176bdbd
f6e56c20-8691-4b96-af10-91221a54b953	fishcap_002	24.38	9.95	\N	2026-09-16 02:55:05.941964	0.00	f	0.00	0.00	t	0.12	13d3c394-ca4a-4198-9490-07bd0176bdbd
dd63b875-aee0-4377-b434-aa29e3043a6d	fishcap_002	24.44	9.95	\N	2026-09-16 02:56:06.389768	0.00	f	0.00	0.00	t	0.23	13d3c394-ca4a-4198-9490-07bd0176bdbd
c28f9d38-3f75-47ce-b22d-551bc7e72df3	fishcap_002	24.38	9.95	\N	2026-09-16 02:57:05.812346	0.00	f	0.00	0.00	t	0.50	13d3c394-ca4a-4198-9490-07bd0176bdbd
c96dc7e1-7ac1-4191-861e-7d55dae18a06	fishcap_002	24.44	9.94	\N	2026-09-16 02:58:10.825829	0.00	f	0.00	0.00	t	0.70	13d3c394-ca4a-4198-9490-07bd0176bdbd
7095d95f-a897-4888-aa35-53fb5f0bb27d	fishcap_002	24.44	9.95	\N	2026-09-16 02:59:14.746481	0.00	f	0.00	0.00	t	623.40	13d3c394-ca4a-4198-9490-07bd0176bdbd
8e76ee4f-320a-4ebf-bbf6-c6408d7fd7c4	fishcap_002	24.88	9.93	\N	2026-09-16 03:10:35.330495	0.00	f	0.00	0.00	t	636.06	13d3c394-ca4a-4198-9490-07bd0176bdbd
5bcd13b0-ae42-4c61-9861-ba8f19e39b89	fishcap_002	24.88	9.95	\N	2026-09-16 03:11:34.632879	0.00	f	0.00	0.00	t	634.33	13d3c394-ca4a-4198-9490-07bd0176bdbd
206d6e64-b290-4a03-ac7e-14b811b8ac81	fishcap_002	24.81	9.94	\N	2026-09-16 03:12:35.351069	0.00	f	0.00	0.00	t	588.95	13d3c394-ca4a-4198-9490-07bd0176bdbd
94471525-02ef-4cb9-a868-cd83377f80dc	fishcap_002	25.06	9.96	\N	2026-09-16 03:13:34.952508	0.00	f	0.00	0.00	t	586.78	13d3c394-ca4a-4198-9490-07bd0176bdbd
b90ef7b2-3670-40c3-a6ad-8fea83d76b82	fishcap_002	25.19	9.97	\N	2026-09-16 03:14:35.163035	0.00	f	0.00	0.00	t	589.19	13d3c394-ca4a-4198-9490-07bd0176bdbd
05698150-8752-45dc-b48f-bd1c0015dc01	fishcap_002	25.31	9.95	\N	2026-09-16 03:15:39.946718	0.00	f	0.00	0.00	t	591.19	13d3c394-ca4a-4198-9490-07bd0176bdbd
6c1dc7ee-1ab2-49dc-a30a-828b727366fb	fishcap_002	25.38	9.97	\N	2026-09-16 03:16:39.957413	0.00	f	0.00	0.00	t	592.32	13d3c394-ca4a-4198-9490-07bd0176bdbd
58633edf-e1fe-4e2f-843c-527404e65726	fishcap_002	25.50	9.96	\N	2026-09-16 03:17:40.291678	0.00	f	0.00	0.00	t	593.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
4a7734b2-a51c-4106-8416-87c9a1adf8d5	fishcap_002	25.31	9.98	\N	2026-09-16 04:35:06.91382	0.00	f	0.00	0.00	t	508.22	13d3c394-ca4a-4198-9490-07bd0176bdbd
13ccb7f3-3160-424e-8940-9c88e0481688	fishcap_002	25.31	9.97	\N	2026-09-16 04:36:07.867614	0.00	f	0.00	0.00	t	559.37	13d3c394-ca4a-4198-9490-07bd0176bdbd
ffb6e85f-513f-45fb-84e2-3cfd54ac2b10	fishcap_002	25.31	9.97	\N	2026-09-16 04:37:07.665397	0.00	f	0.00	0.00	t	652.12	13d3c394-ca4a-4198-9490-07bd0176bdbd
02e0b85c-25e4-4290-9a51-6e3de858682e	fishcap_002	25.31	9.97	\N	2026-09-16 04:38:06.916639	0.00	f	0.00	0.00	t	629.68	13d3c394-ca4a-4198-9490-07bd0176bdbd
859f8ac3-b5fb-41e0-b2c4-6ba1590fb75a	fishcap_002	25.31	9.96	\N	2026-09-16 04:39:07.276211	156.95	f	0.00	156.95	t	539.91	13d3c394-ca4a-4198-9490-07bd0176bdbd
57ec2784-a67f-43b2-b752-81faf09af780	fishcap_002	25.31	9.97	\N	2026-09-16 04:40:12.449891	158.82	f	0.00	158.82	t	542.99	13d3c394-ca4a-4198-9490-07bd0176bdbd
e341f9c4-65ba-4f4e-b17a-da5c8e2a1ff3	fishcap_002	25.38	9.97	\N	2026-09-16 04:41:12.457963	158.62	f	0.00	158.62	t	545.10	13d3c394-ca4a-4198-9490-07bd0176bdbd
ba7ea0c8-2901-439e-9826-ca9950b9b401	fishcap_002	25.38	9.98	\N	2026-09-16 04:42:12.413894	105.08	f	0.00	105.08	t	540.21	13d3c394-ca4a-4198-9490-07bd0176bdbd
163f5878-a338-49a6-aff1-ca4b78b29b1a	fishcap_002	25.38	9.97	\N	2026-09-16 04:43:12.219042	132.29	f	0.00	132.29	t	541.71	13d3c394-ca4a-4198-9490-07bd0176bdbd
d2d9fb99-166e-49e8-bf72-42a674c90077	fishcap_002	25.38	9.96	\N	2026-09-16 04:44:17.346001	132.80	f	0.00	132.80	t	542.60	13d3c394-ca4a-4198-9490-07bd0176bdbd
c28f2db5-51ee-40b8-9089-b5bb754b3daf	fishcap_002	25.44	9.98	\N	2026-09-16 04:45:17.038274	131.05	f	0.00	131.05	t	530.06	13d3c394-ca4a-4198-9490-07bd0176bdbd
be744461-5ea3-4532-9cb8-e91bee61db5b	fishcap_002	25.44	9.98	\N	2026-09-16 04:46:17.367561	131.34	f	0.00	131.34	t	530.30	13d3c394-ca4a-4198-9490-07bd0176bdbd
e96d5ba9-e4b9-4d88-826c-21be5cc18b2f	fishcap_002	25.38	9.98	\N	2026-09-16 04:47:17.015129	131.85	f	0.00	131.85	t	531.86	13d3c394-ca4a-4198-9490-07bd0176bdbd
3c4da497-c99d-4c17-85a7-c1d31c033188	fishcap_002	25.38	9.98	\N	2026-09-16 04:48:22.081714	130.79	f	0.00	130.79	t	530.91	13d3c394-ca4a-4198-9490-07bd0176bdbd
ac5ce943-bf37-4646-ad3f-c02a192a6a94	fishcap_002	25.31	9.98	\N	2026-09-16 04:49:22.084809	131.59	f	0.00	131.59	t	530.81	13d3c394-ca4a-4198-9490-07bd0176bdbd
bc440fe0-5829-40f8-b821-f8d8dff34d69	fishcap_002	25.31	9.99	\N	2026-09-16 04:50:22.531778	130.73	f	0.00	130.73	t	524.90	13d3c394-ca4a-4198-9490-07bd0176bdbd
a14cf7d2-bc51-4122-bbb8-ce4a47fa4346	fishcap_002	25.25	8.47	\N	2026-09-16 04:52:00.204231	0.00	f	0.00	0.00	t	522.23	13d3c394-ca4a-4198-9490-07bd0176bdbd
06858c72-ec9e-4e86-a954-3becdf824dad	fishcap_002	25.13	8.47	\N	2026-09-16 04:53:00.6783	0.00	f	0.00	0.00	t	675.59	13d3c394-ca4a-4198-9490-07bd0176bdbd
2efd3e0d-c9c8-474f-a40b-e01c607c84a1	fishcap_002	24.19	8.49	\N	2026-09-16 04:54:00.51598	0.00	f	0.00	0.00	t	663.15	13d3c394-ca4a-4198-9490-07bd0176bdbd
412e09d1-e4c1-4e84-b363-4095bc289aed	fishcap_002	24.13	8.47	\N	2026-09-16 04:55:01.45353	0.00	f	0.00	0.00	t	661.69	13d3c394-ca4a-4198-9490-07bd0176bdbd
ec67d13b-d8b4-49c7-90b4-57e10a2a7c64	fishcap_002	24.06	8.47	\N	2026-09-16 04:56:02.061984	0.00	f	0.00	0.00	t	661.49	13d3c394-ca4a-4198-9490-07bd0176bdbd
a60625d8-75b9-4563-b879-50f238e332f1	fishcap_002	24.00	8.48	\N	2026-09-16 05:00:10.106093	0.00	f	0.00	0.00	t	662.18	13d3c394-ca4a-4198-9490-07bd0176bdbd
78e28229-67c5-47b4-8528-1ab13304cd0d	fishcap_002	24.00	8.48	\N	2026-09-16 05:01:10.109019	0.00	f	0.00	0.00	t	661.23	13d3c394-ca4a-4198-9490-07bd0176bdbd
c2b2ad6a-8ac6-4e91-80ce-e425626168c6	fishcap_002	24.06	8.50	\N	2026-09-16 05:02:10.107155	0.00	f	0.00	0.00	t	663.49	13d3c394-ca4a-4198-9490-07bd0176bdbd
ba763b07-3751-4f78-afc3-ed431c7c15b7	fishcap_002	24.00	8.50	\N	2026-09-16 05:03:15.847732	0.00	f	0.00	0.00	t	660.34	13d3c394-ca4a-4198-9490-07bd0176bdbd
7709a643-9e0f-4276-ab77-c744e15bba1f	fishcap_002	24.00	8.49	\N	2026-09-16 05:04:15.860578	44.03	f	0.00	44.03	t	661.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
8114a3fb-b5ed-4b6e-b2d5-154b5a11f374	fishcap_002	24.06	8.49	\N	2026-09-16 05:05:15.866812	44.62	f	0.00	44.62	t	664.11	13d3c394-ca4a-4198-9490-07bd0176bdbd
8e27f939-41db-42ce-9275-61f281eba4e9	fishcap_002	24.06	8.48	\N	2026-09-16 05:06:15.876061	44.79	f	0.00	44.79	t	663.41	13d3c394-ca4a-4198-9490-07bd0176bdbd
36a50af9-03e6-4b96-809f-0b1543d2da0c	fishcap_002	24.06	8.55	\N	2026-09-16 06:37:25.335582	0.00	f	0.00	0.00	t	683.99	13d3c394-ca4a-4198-9490-07bd0176bdbd
3852d843-2cee-45de-b00d-de7aa14e2180	fishcap_002	24.13	8.56	\N	2026-09-16 06:38:25.492493	0.00	f	0.00	0.00	t	689.26	13d3c394-ca4a-4198-9490-07bd0176bdbd
bdeb39f3-80f0-4334-83e7-9c2e56a74879	fishcap_002	24.19	8.56	\N	2026-09-16 06:39:26.64697	0.00	f	0.00	0.00	t	692.51	13d3c394-ca4a-4198-9490-07bd0176bdbd
ccc3a5a2-6a73-408f-80d9-a4e963a07e4a	fishcap_002	24.25	8.57	\N	2026-09-16 06:40:28.604408	0.00	f	0.00	0.00	t	692.72	13d3c394-ca4a-4198-9490-07bd0176bdbd
359f285b-bdd9-453f-88e9-a013434e30d6	fishcap_002	24.31	8.57	\N	2026-09-16 06:41:29.219882	0.00	f	0.00	0.00	t	695.49	13d3c394-ca4a-4198-9490-07bd0176bdbd
e65234f9-6ee1-493a-be83-cc8805a20aec	fishcap_002	24.38	8.57	\N	2026-09-16 06:42:29.430785	0.00	f	0.00	0.00	t	695.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
7e7007a7-e996-4b08-903c-6f8fe01bcd60	fishcap_002	24.38	8.56	\N	2026-09-16 06:43:29.476219	0.00	f	0.00	0.00	t	699.58	13d3c394-ca4a-4198-9490-07bd0176bdbd
29087d0b-cd42-44c7-82ab-05e36e2f14c4	fishcap_002	24.44	8.57	\N	2026-09-16 06:44:29.446605	0.00	f	0.00	0.00	t	699.97	13d3c394-ca4a-4198-9490-07bd0176bdbd
6f6e8253-da01-4079-85e8-d5195edd4513	fishcap_002	24.44	8.55	\N	2026-09-16 06:45:29.479396	0.00	f	0.00	0.00	t	701.44	13d3c394-ca4a-4198-9490-07bd0176bdbd
d212b055-355b-4c50-95ea-b1569499490e	fishcap_002	24.50	8.56	\N	2026-09-16 06:46:28.667616	0.00	f	0.00	0.00	t	703.09	13d3c394-ca4a-4198-9490-07bd0176bdbd
23700abb-b45b-4f0c-abdb-b46bb6914bdb	fishcap_002	24.44	8.56	\N	2026-09-16 06:47:29.061882	0.00	f	0.00	0.00	t	708.15	13d3c394-ca4a-4198-9490-07bd0176bdbd
411c17dd-be16-42ef-b1b4-19bf2a96c141	fishcap_002	24.44	8.56	\N	2026-09-16 06:48:29.476817	29.97	f	0.00	29.97	t	719.30	13d3c394-ca4a-4198-9490-07bd0176bdbd
88198a89-ea90-4529-8fad-339d2c0e97aa	fishcap_002	24.50	8.57	\N	2026-09-16 06:49:29.587359	34.89	f	0.00	34.89	t	734.51	13d3c394-ca4a-4198-9490-07bd0176bdbd
24d97af0-be51-4594-9134-7e81e7308618	fishcap_002	24.50	8.57	\N	2026-09-16 06:50:29.486707	24.64	f	0.00	24.64	t	738.50	13d3c394-ca4a-4198-9490-07bd0176bdbd
0c6155f9-8135-49d3-92f0-866e40084b12	fishcap_002	24.50	8.56	\N	2026-09-16 06:51:28.880898	25.16	f	0.00	25.16	t	782.33	13d3c394-ca4a-4198-9490-07bd0176bdbd
75545406-f076-4ee5-b589-f2ef543deee0	fishcap_002	24.56	8.56	\N	2026-09-16 06:52:29.509882	26.04	f	0.00	26.04	t	790.78	13d3c394-ca4a-4198-9490-07bd0176bdbd
f4bc2cc1-b940-4dc1-9e4b-c71ad288f5bd	fishcap_002	24.56	8.56	\N	2026-09-16 06:53:29.368981	26.33	f	0.00	26.33	t	744.28	13d3c394-ca4a-4198-9490-07bd0176bdbd
92349e59-1116-49bb-9eac-6a177fec2ee6	fishcap_002	24.56	8.55	\N	2026-09-16 06:54:29.320919	26.31	f	0.00	26.31	t	746.85	13d3c394-ca4a-4198-9490-07bd0176bdbd
6e61771d-eaa1-4440-93c0-6b0f1d2630af	fishcap_002	24.56	8.55	\N	2026-09-16 06:55:29.551644	26.95	f	0.00	26.95	t	757.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
4fe7dd85-22eb-41df-a5eb-ae579540130a	fishcap_002	24.56	8.55	\N	2026-09-16 06:56:29.340054	26.22	f	0.00	26.22	t	744.06	13d3c394-ca4a-4198-9490-07bd0176bdbd
9affbe35-49a2-4d05-b1f7-423dcf452ee6	fishcap_002	24.56	8.54	\N	2026-09-16 06:57:35.166197	26.18	f	0.00	26.18	t	743.81	13d3c394-ca4a-4198-9490-07bd0176bdbd
83c14444-ee9f-46fc-94f0-13320336afb4	fishcap_002	24.56	8.54	\N	2026-09-16 06:58:35.057683	26.61	f	0.00	26.61	t	747.63	13d3c394-ca4a-4198-9490-07bd0176bdbd
a1b99b53-a87b-4aa5-8712-a2d84db016fe	fishcap_002	24.56	8.55	\N	2026-09-16 06:59:35.04245	26.74	f	0.00	26.74	t	751.49	13d3c394-ca4a-4198-9490-07bd0176bdbd
b288d391-4d18-48b8-93f2-f51a5a3289d8	fishcap_002	24.63	8.54	\N	2026-09-16 07:00:34.46988	27.07	f	0.00	27.07	t	753.47	13d3c394-ca4a-4198-9490-07bd0176bdbd
b4325e77-95a9-4561-9157-26f9c346049e	fishcap_002	24.63	8.54	\N	2026-09-16 07:01:40.212079	28.06	f	0.00	28.06	t	763.61	13d3c394-ca4a-4198-9490-07bd0176bdbd
43f5915a-9ba4-4037-8518-e666f27b6617	fishcap_002	24.63	8.57	\N	2026-09-16 07:02:39.257982	28.05	f	0.00	28.05	t	724.35	13d3c394-ca4a-4198-9490-07bd0176bdbd
b05156a4-1d65-4c74-8ead-36dccb874eb5	fishcap_002	24.63	8.54	\N	2026-09-16 07:03:39.790214	28.90	f	0.00	28.90	t	726.40	13d3c394-ca4a-4198-9490-07bd0176bdbd
3e9f8092-ee14-4845-a8e6-a8995e07a2ab	fishcap_002	24.63	8.54	\N	2026-09-16 07:04:39.253454	28.95	f	0.00	28.95	t	726.86	13d3c394-ca4a-4198-9490-07bd0176bdbd
874a580d-5831-4d8b-aeb5-f806548648c8	fishcap_002	24.63	8.54	\N	2026-09-16 07:05:39.640427	28.98	f	0.00	28.98	t	728.01	13d3c394-ca4a-4198-9490-07bd0176bdbd
68b8c76f-dd6a-4ed9-8669-703c39522555	fishcap_002	24.63	8.56	\N	2026-09-16 07:06:44.670771	28.07	f	0.00	28.07	t	730.01	13d3c394-ca4a-4198-9490-07bd0176bdbd
7fd39f23-64fa-4272-8d29-82ac16f75eb4	fishcap_002	24.63	8.53	\N	2026-09-16 07:07:44.995521	28.04	f	0.00	28.04	t	728.68	13d3c394-ca4a-4198-9490-07bd0176bdbd
7ddd1536-205c-4c10-899f-6eaa6abff414	fishcap_002	24.63	8.53	\N	2026-09-16 07:08:44.978416	28.18	f	0.00	28.18	t	726.95	13d3c394-ca4a-4198-9490-07bd0176bdbd
0fedb8cd-e826-41d8-b78d-db4154e6e002	fishcap_002	24.63	8.55	\N	2026-09-16 07:09:49.974861	27.61	f	0.00	27.61	t	726.07	13d3c394-ca4a-4198-9490-07bd0176bdbd
5985a252-6bad-480f-a5bf-9922c5272688	fishcap_002	24.56	8.53	\N	2026-09-16 07:10:50.11343	28.02	f	0.00	28.02	t	725.70	13d3c394-ca4a-4198-9490-07bd0176bdbd
42c0f8e7-367f-4f0c-9df1-a0423576f0cb	fishcap_002	24.56	8.54	\N	2026-09-16 07:11:50.118616	27.93	f	0.00	27.93	t	732.14	13d3c394-ca4a-4198-9490-07bd0176bdbd
9d1f30af-1eb6-4557-95fd-fb237c62b724	fishcap_002	24.56	8.53	\N	2026-09-16 07:12:50.121566	27.87	f	0.00	27.87	t	729.58	13d3c394-ca4a-4198-9490-07bd0176bdbd
8d841154-fcba-4f5e-b1ca-324edfd96563	fishcap_002	24.56	8.53	\N	2026-09-16 07:13:55.854347	28.18	f	0.00	28.18	t	731.62	13d3c394-ca4a-4198-9490-07bd0176bdbd
0b663ea3-0e45-4885-8e4e-aed16f388cbf	fishcap_002	24.56	8.53	\N	2026-09-16 07:14:55.664512	28.41	f	0.00	28.41	t	729.67	13d3c394-ca4a-4198-9490-07bd0176bdbd
60d67de4-224c-4e64-a9ba-7ce05817534a	fishcap_002	24.56	8.52	\N	2026-09-16 07:15:55.87032	28.39	f	0.00	28.39	t	730.65	13d3c394-ca4a-4198-9490-07bd0176bdbd
360bd468-fe9a-423d-8bca-d2fe7faaaa83	fishcap_002	24.50	8.53	\N	2026-09-16 07:16:55.482116	28.37	f	0.00	28.37	t	729.63	13d3c394-ca4a-4198-9490-07bd0176bdbd
28e0a15a-9733-4448-9894-db9831758611	fishcap_002	24.50	8.53	\N	2026-09-16 07:17:55.678283	28.46	f	0.00	28.46	t	732.80	13d3c394-ca4a-4198-9490-07bd0176bdbd
298626b6-623e-403f-969c-2d596bb509cb	fishcap_002	24.50	8.51	\N	2026-09-16 07:18:55.08354	28.37	f	0.00	28.37	t	788.15	13d3c394-ca4a-4198-9490-07bd0176bdbd
4288f64f-7979-4654-a248-dda9fd9b8863	fishcap_002	24.50	8.52	\N	2026-09-16 07:20:00.038485	28.07	f	0.00	28.07	t	833.90	13d3c394-ca4a-4198-9490-07bd0176bdbd
ed45c711-125b-4ffa-b252-e05ad252dc03	fishcap_002	25.19	9.82	\N	2026-09-16 07:55:41.327199	0.00	f	0.00	0.00	t	864.75	13d3c394-ca4a-4198-9490-07bd0176bdbd
2dc5bccf-1a52-4a83-ac15-f44524edbc8a	fishcap_002	24.81	8.05	\N	2026-09-16 08:19:00.963405	0.00	f	0.00	0.00	t	724.87	13d3c394-ca4a-4198-9490-07bd0176bdbd
12899017-acfd-45c3-a07c-689747fa694d	fishcap_002	24.44	8.06	\N	2026-09-16 08:20:00.026505	0.00	f	0.00	0.00	t	717.80	13d3c394-ca4a-4198-9490-07bd0176bdbd
1eca8cec-5c26-4def-96b0-7eba46fc2838	fishcap_002	24.31	8.05	\N	2026-09-16 08:21:00.981229	0.00	f	0.00	0.00	t	721.71	13d3c394-ca4a-4198-9490-07bd0176bdbd
fcd9fbb7-9472-4416-91ce-f3990c2828bf	fishcap_002	24.31	8.07	\N	2026-09-16 08:22:01.622303	0.00	f	0.00	0.00	t	722.91	13d3c394-ca4a-4198-9490-07bd0176bdbd
32e2fceb-e297-41d8-9847-cca591f1e973	fishcap_002	24.56	7.88	\N	2026-09-16 10:04:57.90336	0.57	f	0.00	0.57	t	754.62	13d3c394-ca4a-4198-9490-07bd0176bdbd
75c4e20a-45ea-43c9-8f8f-30d4fe5f3a35	fishcap_002	24.50	7.87	\N	2026-09-16 10:05:58.84115	0.00	f	0.00	0.00	t	755.14	13d3c394-ca4a-4198-9490-07bd0176bdbd
b55a6161-83e6-4697-9f8f-19c120557fd3	fishcap_002	24.50	7.86	\N	2026-09-16 10:06:58.644942	21.82	f	0.00	21.82	t	827.02	13d3c394-ca4a-4198-9490-07bd0176bdbd
f4bd9db8-d4fc-4c99-993a-9c72ca0b2bb3	fishcap_002	24.50	7.84	\N	2026-09-16 10:12:02.504901	20.76	f	0.00	20.76	t	803.29	13d3c394-ca4a-4198-9490-07bd0176bdbd
60405417-697a-4140-9c7a-6d3363183344	fishcap_002	24.44	7.85	\N	2026-09-16 10:13:01.904804	20.18	f	0.00	20.18	t	807.90	13d3c394-ca4a-4198-9490-07bd0176bdbd
cda1fbee-6b46-4b9c-928f-a1c5586d51d7	fishcap_002	24.50	7.84	\N	2026-09-16 10:14:01.934573	21.00	f	0.00	21.00	t	799.62	13d3c394-ca4a-4198-9490-07bd0176bdbd
14e17fe2-e346-424a-8c33-4977d155f561	fishcap_002	24.44	7.86	\N	2026-09-16 10:15:01.928097	19.80	f	0.00	19.80	t	815.01	13d3c394-ca4a-4198-9490-07bd0176bdbd
26dfdf84-7efc-4cee-9b38-e9385ff945bc	fishcap_002	24.50	7.85	\N	2026-09-16 10:16:02.137021	20.03	f	0.00	20.03	t	257.21	13d3c394-ca4a-4198-9490-07bd0176bdbd
55c2fa9f-6358-4d66-b7d5-a5deec08918d	fishcap_002	24.13	7.86	\N	2026-09-16 10:17:07.193224	20.43	f	0.00	20.43	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
f86f8539-67ee-4654-800e-31bfa5d31f3f	fishcap_002	24.38	7.80	\N	2026-09-16 10:18:07.178115	19.31	f	0.00	19.31	t	769.03	13d3c394-ca4a-4198-9490-07bd0176bdbd
5a809234-50e4-441a-945c-8dec790c7141	fishcap_002	24.38	7.82	\N	2026-09-16 10:19:07.200076	19.84	f	0.00	19.84	t	754.17	13d3c394-ca4a-4198-9490-07bd0176bdbd
20168a3e-5a51-4664-a18a-48d4543a4288	fishcap_002	24.38	7.85	\N	2026-09-16 10:20:12.004032	19.28	f	0.00	19.28	t	754.30	13d3c394-ca4a-4198-9490-07bd0176bdbd
9280b36a-cb5b-49a9-8e27-d960bcfa499a	fishcap_002	29.88	7.92	\N	2026-09-16 14:13:22.663261	0.00	f	0.00	0.00	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
e4df68f7-a998-4f46-befa-4486b0817b21	fishcap_002	29.75	7.92	\N	2026-09-16 14:14:21.634406	0.00	f	0.00	0.00	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
ac1b2d2d-6df5-4075-8bb0-ce27b9d8828f	fishcap_002	29.69	7.97	\N	2026-09-16 14:15:22.418417	0.00	f	0.00	0.00	t	130.22	13d3c394-ca4a-4198-9490-07bd0176bdbd
2ff54cd5-e4cb-4261-8a22-c9268db4d7b0	fishcap_002	29.69	7.97	\N	2026-09-16 14:16:21.641896	0.00	f	0.00	0.00	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
a42197ef-291e-492a-8efe-404e37dbe428	fishcap_002	29.69	7.83	\N	2026-09-16 14:17:27.133769	0.00	f	0.00	0.00	t	\N	13d3c394-ca4a-4198-9490-07bd0176bdbd
381fafce-f329-412e-af03-435e530eb4e6	fishcap_002	29.81	7.85	\N	2026-09-16 14:18:26.740721	0.00	f	0.00	0.00	t	53.03	13d3c394-ca4a-4198-9490-07bd0176bdbd
3f0c67f0-7dca-4ace-8252-add57adba745	fishcap_002	29.63	7.85	\N	2026-09-16 14:19:27.138448	0.00	f	0.00	0.00	t	52.58	13d3c394-ca4a-4198-9490-07bd0176bdbd
d9616b58-adaf-4a7f-9ed7-11a4af19d2d2	fishcap_002	29.56	7.85	\N	2026-09-16 14:20:27.342333	0.00	f	0.00	0.00	t	51.59	13d3c394-ca4a-4198-9490-07bd0176bdbd
07b0d0e1-bc44-4a07-bbf6-b0f0b55c1785	fishcap_002	29.56	7.86	\N	2026-09-16 14:21:27.34985	0.00	f	0.00	0.00	t	52.19	13d3c394-ca4a-4198-9490-07bd0176bdbd
37185bd7-36b1-4c77-ae79-6569fa94e5ce	fishcap_002	29.56	7.85	\N	2026-09-16 14:22:26.433949	0.00	f	0.00	0.00	t	52.06	13d3c394-ca4a-4198-9490-07bd0176bdbd
b3debe16-7505-4e49-9fd6-7c19efca2743	fishcap_002	29.56	7.85	\N	2026-09-16 14:23:31.872174	0.00	f	0.00	0.00	t	52.37	13d3c394-ca4a-4198-9490-07bd0176bdbd
e632ba8f-0e53-45cd-9bc8-f1e66ec323cb	fishcap_002	29.56	7.85	\N	2026-09-16 14:24:32.484324	0.00	f	0.00	0.00	t	52.30	13d3c394-ca4a-4198-9490-07bd0176bdbd
eab8f6ae-31b5-4bee-9b6b-4f0a09b88dd4	fishcap_002	29.56	7.86	\N	2026-09-16 14:25:31.706546	0.00	f	0.00	0.00	t	52.23	13d3c394-ca4a-4198-9490-07bd0176bdbd
f36bd4cc-4511-447f-b9ae-9d3b7dcf76e0	fishcap_002	29.56	7.85	\N	2026-09-16 14:26:36.763205	0.00	f	0.00	0.00	t	51.79	13d3c394-ca4a-4198-9490-07bd0176bdbd
ca43ec60-da07-476d-9108-6577639df450	fishcap_002	29.50	7.85	\N	2026-09-16 14:27:36.765915	0.00	f	0.00	0.00	t	51.20	13d3c394-ca4a-4198-9490-07bd0176bdbd
b43c3637-9ced-431c-80c3-4ce38b56b28d	fishcap_002	29.56	7.86	\N	2026-09-16 14:28:37.223533	0.00	f	0.00	0.00	t	51.37	13d3c394-ca4a-4198-9490-07bd0176bdbd
546658cb-dace-4c7b-9bf8-49b6d3f21f1e	fishcap_002	29.56	7.86	\N	2026-09-16 14:29:41.913695	0.00	f	0.00	0.00	t	50.27	13d3c394-ca4a-4198-9490-07bd0176bdbd
948c4031-9fa7-4830-b7ec-8b87ae5e44c8	fishcap_002	29.56	7.86	\N	2026-09-16 14:30:42.637201	0.00	f	0.00	0.00	t	50.95	13d3c394-ca4a-4198-9490-07bd0176bdbd
68676104-6b6c-4150-8142-85edbb4ae684	fishcap_002	29.50	7.87	\N	2026-09-16 14:31:41.93262	0.00	f	0.00	0.00	t	50.89	13d3c394-ca4a-4198-9490-07bd0176bdbd
ba9308b3-6059-4018-9cce-ba9ad5a747b7	fishcap_002	29.56	7.87	\N	2026-09-16 14:32:41.934042	0.00	f	0.00	0.00	t	50.69	13d3c394-ca4a-4198-9490-07bd0176bdbd
f79adf63-f06c-44c2-aff9-ba97a0d6dca4	fishcap_002	29.50	7.87	\N	2026-09-16 14:33:42.803278	0.00	f	0.00	0.00	t	51.36	13d3c394-ca4a-4198-9490-07bd0176bdbd
9f59ee10-f01c-46fd-a63b-ffadaa833a0d	fishcap_002	29.56	7.87	\N	2026-09-16 14:34:42.806446	0.00	f	0.00	0.00	t	52.59	13d3c394-ca4a-4198-9490-07bd0176bdbd
d42c0e80-9f55-4f34-9385-f0fdf1ea4f38	fishcap_002	29.50	7.89	\N	2026-09-16 14:35:41.951168	0.00	f	0.00	0.00	t	72.92	13d3c394-ca4a-4198-9490-07bd0176bdbd
d1627250-6e44-4c17-8666-c0c875c10ffb	fishcap_002	25.19	8.74	\N	2026-09-17 02:50:11.47235	99.34	f	0.00	99.34	t	225.47	13d3c394-ca4a-4198-9490-07bd0176bdbd
85513cab-3fdd-4afa-af33-772fb247095c	fishcap_002	24.69	8.69	\N	2026-09-17 03:11:39.971275	0.00	f	0.00	0.00	t	727.10	13d3c394-ca4a-4198-9490-07bd0176bdbd
ec84ecc1-a0c4-4206-b23f-3ee14909ae13	fishcap_002	24.88	8.61	\N	2026-09-17 03:36:13.188987	0.00	f	0.00	0.00	t	736.48	13d3c394-ca4a-4198-9490-07bd0176bdbd
46347b59-3014-4d9c-b484-374531e7eb8d	fishcap_002	24.44	8.54	\N	2026-09-17 04:02:30.371811	0.00	f	0.00	0.00	t	216.90	13d3c394-ca4a-4198-9490-07bd0176bdbd
e317802c-90c6-4687-b505-e5790f846ebd	fishcap_002	24.69	8.51	\N	2026-09-17 04:24:00.896302	93.47	f	0.00	93.47	t	219.42	13d3c394-ca4a-4198-9490-07bd0176bdbd
d80a698b-5243-4fa5-9f55-48c577f68913	fishcap_002	24.44	8.50	\N	2026-09-17 04:52:10.961502	0.00	f	0.00	0.00	t	219.41	13d3c394-ca4a-4198-9490-07bd0176bdbd
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, full_name, email, password_hash, phone, created_at, profile_image, "resetTokenHash", "resetTokenExpiresAt", profile_image_public_id) FROM stdin;
677e34c7-f579-4452-a892-7b46eb21177d	Demo User	demo@fishcap.local	2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea	1234567890	2026-08-25 08:39:28.15833	\N	\N	\N	\N
04808a03-bb9a-40c5-9a83-3cf3a8a3c983	linlin	engdalline43@gmail.com	ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f	098765463	2026-09-08 02:43:03.228875	\N	\N	\N	\N
c61a2b49-5c5e-435e-be45-5fc39c090335	nitas	nita@gmail.com	15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225	02654789	2026-09-01 02:08:03.582254	\N	\N	\N	\N
377f04c6-82dd-4af1-8184-51c48d7a5451	dalin	daline@gmail.com	ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f	0978992196	2026-08-25 09:08:21.242487	\N	\N	\N	\N
\.


--
-- Name: fishcap_typeorm_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fishcap_typeorm_migrations_id_seq', 1, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 1, true);


--
-- Name: batches PK_55e7ff646e969b61d37eea5be7a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT "PK_55e7ff646e969b61d37eea5be7a" PRIMARY KEY (id);


--
-- Name: fishcap_typeorm_migrations PK_8e27806d57d5b599927828fd854; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fishcap_typeorm_migrations
    ADD CONSTRAINT "PK_8e27806d57d5b599927828fd854" PRIMARY KEY (id);


--
-- Name: fish_species PK_a2fb97783349cd5a209353d3220; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fish_species
    ADD CONSTRAINT "PK_a2fb97783349cd5a209353d3220" PRIMARY KEY (id);


--
-- Name: feed_calculations PK_fa793d9c66f2bf2c09ead6f0726; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_calculations
    ADD CONSTRAINT "PK_fa793d9c66f2bf2c09ead6f0726" PRIMARY KEY (id);


--
-- Name: devices devices_device_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_device_code_key UNIQUE (device_code);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: feed_schedules feed_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_schedules
    ADD CONSTRAINT feed_schedules_pkey PRIMARY KEY (id);


--
-- Name: feeding_logs feeding_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feeding_logs
    ADD CONSTRAINT feeding_logs_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: otps otps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otps
    ADD CONSTRAINT otps_pkey PRIMARY KEY (id);


--
-- Name: ponds ponds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ponds
    ADD CONSTRAINT ponds_pkey PRIMARY KEY (id);


--
-- Name: sensor_data sensor_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sensor_data
    ADD CONSTRAINT sensor_data_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: IDX_b38ebea2c8e7912661125bc2af; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_b38ebea2c8e7912661125bc2af" ON public.sensor_data USING btree (pond_id);


--
-- Name: feeding_logs FK_443cabfc5bf40a820667e3548e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feeding_logs
    ADD CONSTRAINT "FK_443cabfc5bf40a820667e3548e9" FOREIGN KEY (schedule_id) REFERENCES public.feed_schedules(id);


--
-- Name: feed_schedules FK_7b47c0084d85b4a560f7ae31d45; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_schedules
    ADD CONSTRAINT "FK_7b47c0084d85b4a560f7ae31d45" FOREIGN KEY (pond_id) REFERENCES public.ponds(id) ON DELETE CASCADE;


--
-- Name: feeding_logs FK_8540208080a464dcf235cca61df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feeding_logs
    ADD CONSTRAINT "FK_8540208080a464dcf235cca61df" FOREIGN KEY (pond_id) REFERENCES public.ponds(id) ON DELETE CASCADE;


--
-- Name: batches FK_9048a458a2e80fb3ab384b25290; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT "FK_9048a458a2e80fb3ab384b25290" FOREIGN KEY (species_id) REFERENCES public.fish_species(id);


--
-- Name: notifications FK_9a8a82462cab47c73d25f49261f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "FK_9a8a82462cab47c73d25f49261f" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: devices FK_ad1b589914114e31593f7ee5abf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT "FK_ad1b589914114e31593f7ee5abf" FOREIGN KEY (pond_id) REFERENCES public.ponds(id) ON DELETE SET NULL;


--
-- Name: ponds FK_c487e504da1137417bced90d6e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ponds
    ADD CONSTRAINT "FK_c487e504da1137417bced90d6e5" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: feed_calculations FK_ff43b8376d41c0b36aa163f04f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_calculations
    ADD CONSTRAINT "FK_ff43b8376d41c0b36aa163f04f5" FOREIGN KEY (batch_id) REFERENCES public.batches(id);


--
-- PostgreSQL database dump complete
--

\unrestrict mJobcybZeTVR3PilomPaxeyl3CVZmnFe1QdfjvgQmyGV6RUL0WaR4urw4O7KtOj

