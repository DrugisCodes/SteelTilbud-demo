--
-- PostgreSQL database dump
--

\restrict 1MUrxVsJxCQxXGpXLqNHzUBQnXkwdMuzeRmw2Q3pGdHmNbyhwSMeqWu7TDh4vDb

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-10-30 17:32:18

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

--
-- TOC entry 237 (class 1255 OID 17049)
-- Name: logg_pris_endring(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.logg_pris_endring() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- bare lagre hvis verdiene faktisk endres
    IF (
        NEW.pris IS DISTINCT FROM OLD.pris OR
        NEW.mengde IS DISTINCT FROM OLD.mengde OR
        NEW.enhet IS DISTINCT FROM OLD.enhet OR
        NEW.pris_per_enhet IS DISTINCT FROM OLD.pris_per_enhet OR
        NEW.rabatt IS DISTINCT FROM OLD.rabatt
    ) THEN
        INSERT INTO pris_historikk (
            produkt_id,
            butikk_id,
            pris,
            mengde,
            enhet,
            pris_per_enhet,
            pris_per_enhet_enhet,
            kilde_fil,
            gyldig_fra,
            gyldig_til
        ) VALUES (
            OLD.produkt_id,
            OLD.butikk_id,
            OLD.pris,
            OLD.mengde,
            OLD.enhet,
            OLD.pris_per_enhet,
            OLD.pris_per_enhet_enhet,
            OLD.kilde_fil,
            OLD.dato,
            CURRENT_DATE
        );
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.logg_pris_endring() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 234 (class 1259 OID 16693)
-- Name: bruker; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bruker (
    id integer NOT NULL,
    brukernavn character varying(100) NOT NULL,
    passord_hash text NOT NULL,
    opprettet timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.bruker OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16692)
-- Name: bruker_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bruker_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bruker_id_seq OWNER TO postgres;

--
-- TOC entry 5022 (class 0 OID 0)
-- Dependencies: 233
-- Name: bruker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bruker_id_seq OWNED BY public.bruker.id;


--
-- TOC entry 224 (class 1259 OID 16490)
-- Name: butikk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.butikk (
    id integer NOT NULL,
    navn text NOT NULL
);


ALTER TABLE public.butikk OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16489)
-- Name: butikk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.butikk_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.butikk_id_seq OWNER TO postgres;

--
-- TOC entry 5023 (class 0 OID 0)
-- Dependencies: 223
-- Name: butikk_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.butikk_id_seq OWNED BY public.butikk.id;


--
-- TOC entry 236 (class 1259 OID 16705)
-- Name: favoritt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favoritt (
    id integer NOT NULL,
    bruker_id integer,
    produkt_id integer,
    opprettet timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.favoritt OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16704)
-- Name: favoritt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.favoritt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.favoritt_id_seq OWNER TO postgres;

--
-- TOC entry 5024 (class 0 OID 0)
-- Dependencies: 235
-- Name: favoritt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.favoritt_id_seq OWNED BY public.favoritt.id;


--
-- TOC entry 226 (class 1259 OID 16501)
-- Name: kategori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kategori (
    id integer NOT NULL,
    navn text NOT NULL
);


ALTER TABLE public.kategori OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16500)
-- Name: kategori_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kategori_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kategori_id_seq OWNER TO postgres;

--
-- TOC entry 5025 (class 0 OID 0)
-- Dependencies: 225
-- Name: kategori_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kategori_id_seq OWNED BY public.kategori.id;


--
-- TOC entry 230 (class 1259 OID 16550)
-- Name: pris_historikk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pris_historikk (
    id integer NOT NULL,
    produkt_id integer,
    butikk_id integer,
    pris numeric(10,2),
    mengde numeric(10,2),
    enhet character varying(10),
    pris_per_enhet numeric(10,2),
    pris_per_enhet_enhet character varying(10),
    kilde_fil text,
    gyldig_fra date DEFAULT CURRENT_DATE,
    gyldig_til date,
    opprettet timestamp with time zone DEFAULT now(),
    registrert_tid timestamp with time zone DEFAULT now(),
    uke_nr integer,
    rabatt text
);


ALTER TABLE public.pris_historikk OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16549)
-- Name: pris_historikk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pris_historikk_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pris_historikk_id_seq OWNER TO postgres;

--
-- TOC entry 5026 (class 0 OID 0)
-- Dependencies: 229
-- Name: pris_historikk_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pris_historikk_id_seq OWNED BY public.pris_historikk.id;


--
-- TOC entry 228 (class 1259 OID 16512)
-- Name: produkt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produkt (
    id integer NOT NULL,
    navn text NOT NULL,
    kategori_id integer
);


ALTER TABLE public.produkt OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16511)
-- Name: produkt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produkt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produkt_id_seq OWNER TO postgres;

--
-- TOC entry 5027 (class 0 OID 0)
-- Dependencies: 227
-- Name: produkt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produkt_id_seq OWNED BY public.produkt.id;


--
-- TOC entry 218 (class 1259 OID 16434)
-- Name: produkter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produkter (
    id integer NOT NULL,
    pris numeric(10,2),
    mengde numeric(10,2),
    enhet character varying(10),
    dato date DEFAULT CURRENT_DATE,
    pris_per_enhet numeric(10,2),
    pris_per_enhet_enhet character varying(10),
    kilde_fil text,
    butikk_id integer,
    produkt_id integer,
    rabatt text
);


ALTER TABLE public.produkter OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16457)
-- Name: produkter_historikk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produkter_historikk (
    id integer NOT NULL,
    butikk text NOT NULL,
    kategori text,
    produkt text NOT NULL,
    pris numeric(10,2),
    mengde numeric(10,2),
    enhet character varying(10),
    pris_per_enhet numeric(10,2),
    pris_per_enhet_enhet character varying(10),
    kilde_fil text,
    gyldig_fra date DEFAULT CURRENT_DATE,
    opprettet timestamp with time zone DEFAULT now(),
    gyldig_til date,
    butikk_id integer,
    produkt_id integer
);


ALTER TABLE public.produkter_historikk OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16456)
-- Name: produkter_historikk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produkter_historikk_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produkter_historikk_id_seq OWNER TO postgres;

--
-- TOC entry 5028 (class 0 OID 0)
-- Dependencies: 221
-- Name: produkter_historikk_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produkter_historikk_id_seq OWNED BY public.produkter_historikk.id;


--
-- TOC entry 217 (class 1259 OID 16433)
-- Name: produkter_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produkter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produkter_id_seq OWNER TO postgres;

--
-- TOC entry 5029 (class 0 OID 0)
-- Dependencies: 217
-- Name: produkter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produkter_id_seq OWNED BY public.produkter.id;


--
-- TOC entry 220 (class 1259 OID 16447)
-- Name: produkter_rejects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produkter_rejects (
    id integer NOT NULL,
    reason text,
    kilde_fil text,
    payload jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.produkter_rejects OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16446)
-- Name: produkter_rejects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produkter_rejects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produkter_rejects_id_seq OWNER TO postgres;

--
-- TOC entry 5030 (class 0 OID 0)
-- Dependencies: 219
-- Name: produkter_rejects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produkter_rejects_id_seq OWNED BY public.produkter_rejects.id;


--
-- TOC entry 231 (class 1259 OID 16622)
-- Name: v_produktoversikt; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_produktoversikt AS
 SELECT pr.id,
    b.navn AS butikk,
    p.navn AS produkt,
    pr.pris,
    pr.mengde,
    pr.enhet,
    pr.pris_per_enhet,
    pr.pris_per_enhet_enhet,
    pr.kilde_fil,
    pr.dato
   FROM ((public.produkter pr
     JOIN public.butikk b ON ((pr.butikk_id = b.id)))
     JOIN public.produkt p ON ((pr.produkt_id = p.id)));


ALTER VIEW public.v_produktoversikt OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16679)
-- Name: v_produktoversikt_full; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_produktoversikt_full AS
 SELECT pr.id,
    b.navn AS butikk,
    k.navn AS kategori,
    p.navn AS produkt,
    pr.pris,
    pr.mengde,
    pr.enhet,
    pr.pris_per_enhet,
    pr.pris_per_enhet_enhet,
    pr.kilde_fil,
    pr.dato
   FROM (((public.produkter pr
     JOIN public.butikk b ON ((pr.butikk_id = b.id)))
     JOIN public.produkt p ON ((pr.produkt_id = p.id)))
     LEFT JOIN public.kategori k ON ((p.kategori_id = k.id)));


ALTER VIEW public.v_produktoversikt_full OWNER TO postgres;

--
-- TOC entry 4805 (class 2604 OID 16696)
-- Name: bruker id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bruker ALTER COLUMN id SET DEFAULT nextval('public.bruker_id_seq'::regclass);


--
-- TOC entry 4798 (class 2604 OID 16493)
-- Name: butikk id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.butikk ALTER COLUMN id SET DEFAULT nextval('public.butikk_id_seq'::regclass);


--
-- TOC entry 4807 (class 2604 OID 16708)
-- Name: favoritt id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favoritt ALTER COLUMN id SET DEFAULT nextval('public.favoritt_id_seq'::regclass);


--
-- TOC entry 4799 (class 2604 OID 16504)
-- Name: kategori id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori ALTER COLUMN id SET DEFAULT nextval('public.kategori_id_seq'::regclass);


--
-- TOC entry 4801 (class 2604 OID 16553)
-- Name: pris_historikk id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pris_historikk ALTER COLUMN id SET DEFAULT nextval('public.pris_historikk_id_seq'::regclass);


--
-- TOC entry 4800 (class 2604 OID 16515)
-- Name: produkt id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkt ALTER COLUMN id SET DEFAULT nextval('public.produkt_id_seq'::regclass);


--
-- TOC entry 4791 (class 2604 OID 16437)
-- Name: produkter id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter ALTER COLUMN id SET DEFAULT nextval('public.produkter_id_seq'::regclass);


--
-- TOC entry 4795 (class 2604 OID 16460)
-- Name: produkter_historikk id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter_historikk ALTER COLUMN id SET DEFAULT nextval('public.produkter_historikk_id_seq'::regclass);


--
-- TOC entry 4793 (class 2604 OID 16450)
-- Name: produkter_rejects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter_rejects ALTER COLUMN id SET DEFAULT nextval('public.produkter_rejects_id_seq'::regclass);


--
-- TOC entry 5014 (class 0 OID 16693)
-- Dependencies: 234
-- Data for Name: bruker; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bruker (id, brukernavn, passord_hash, opprettet) FROM stdin;
\.


--
-- TOC entry 5006 (class 0 OID 16490)
-- Dependencies: 224
-- Data for Name: butikk; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.butikk (id, navn) FROM stdin;
1	Bunnpris
11	Coop_Extra
70	Coop_Prix
166	REMA_1000
246	SPAR
83	KIWI
154	MENY
\.


--
-- TOC entry 5016 (class 0 OID 16705)
-- Dependencies: 236
-- Data for Name: favoritt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.favoritt (id, bruker_id, produkt_id, opprettet) FROM stdin;
\.


--
-- TOC entry 5008 (class 0 OID 16501)
-- Dependencies: 226
-- Data for Name: kategori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kategori (id, navn) FROM stdin;
265	Baking
266	Frukt
267	Godteri
268	Frysevarer
269	Bakervarer
270	Pålegg
271	Søtsaker
272	Frossenmat
273	Grønnsaker
274	Krydder
275	Frukt og grønt
276	Hjem
277	Klær
278	Helse
279	Matvarer
280	Personlig pleie
281	Sjømat
282	Frokostblanding
283	Hermetikk
284	Krydder/Saus
285	Sauser
286	Bakverk
287	Blomster
288	Iskrem
289	Dressing
290	Taco
291	Tilbehør
292	Pasta
293	Sjokolade
294	Diverse
295	Frukt og Grønt
296	Planter
297	Matolje
26	Meieri
77	Frokost
54	Tørrvarer
83	Kjøtt
15	Brød
11	Snacks
36	Husholdning
1	Drikke
12	Frukt/Grønt
13	Fisk
5	Ferdigmat
3	Annet
157	Hygiene
\.


--
-- TOC entry 5012 (class 0 OID 16550)
-- Dependencies: 230
-- Data for Name: pris_historikk; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pris_historikk (id, produkt_id, butikk_id, pris, mengde, enhet, pris_per_enhet, pris_per_enhet_enhet, kilde_fil, gyldig_fra, gyldig_til, opprettet, registrert_tid, uke_nr, rabatt) FROM stdin;
1	1	1	20.00	0.80	l	25.00	kr/l	bunnpris_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.594103+02	2025-10-21 00:24:01.594103+02	\N	\N
2	4	1	10.00	0.50	l	20.00	kr/l	bunnpris_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.610798+02	2025-10-21 00:24:01.610798+02	\N	\N
3	16	11	19.00	\N	\N	\N	\N	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.636702+02	2025-10-21 00:24:01.636702+02	\N	\N
4	14	11	25.00	\N	\N	\N	\N	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.641068+02	2025-10-21 00:24:01.641068+02	\N	\N
5	39	11	129.00	12.00	pk	\N	\N	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.679449+02	2025-10-21 00:24:01.679449+02	\N	\N
6	41	11	149.00	\N	\N	\N	\N	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.68299+02	2025-10-21 00:24:01.68299+02	\N	\N
7	11	11	36.67	150.00	g	244.47	kr/kg	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.707604+02	2025-10-21 00:24:01.707604+02	\N	3 for 110
8	19	11	15.00	1.00	stk	\N	\N	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.713765+02	2025-10-21 00:24:01.713765+02	\N	\N
9	23	11	10.00	1.00	stk	\N	\N	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.720904+02	2025-10-21 00:24:01.720904+02	\N	\N
10	24	11	49.90	1200.00	g	41.58	kr/kg	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.723182+02	2025-10-21 00:24:01.723182+02	\N	\N
11	25	11	89.90	\N	\N	\N	\N	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.725342+02	2025-10-21 00:24:01.725342+02	\N	\N
12	26	11	33.60	\N	\N	\N	\N	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.727509+02	2025-10-21 00:24:01.727509+02	\N	\N
13	27	11	30.00	6.00	stk	\N	\N	coop_extra_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.72957+02	2025-10-21 00:24:01.72957+02	\N	\N
14	85	83	29.90	\N	\N	\N	\N	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.775735+02	2025-10-21 00:24:01.775735+02	\N	\N
15	83	83	144.90	1400.00	g	103.50	kr/kg	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.790392+02	2025-10-21 00:24:01.790392+02	\N	\N
19	105	83	69.90	\N	\N	\N	\N	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.814333+02	2025-10-21 00:24:01.814333+02	\N	\N
21	84	83	39.90	2000.00	g	19.95	kr/kg	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.862665+02	2025-10-21 00:24:01.862665+02	\N	\N
22	92	83	99.00	10.00	stk	\N	\N	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.866284+02	2025-10-21 00:24:01.866284+02	\N	\N
23	93	83	24.90	1.00	stk	\N	\N	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.868078+02	2025-10-21 00:24:01.868078+02	\N	\N
24	94	83	69.90	1.00	stk	\N	\N	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.869841+02	2025-10-21 00:24:01.869841+02	\N	\N
25	138	83	29.90	400.00	g	74.75	kr/kg	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.872947+02	2025-10-21 00:24:01.872947+02	\N	\N
26	98	83	49.60	400.00	g	124.00	kr/kg	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.875008+02	2025-10-21 00:24:01.875008+02	\N	\N
28	108	83	219.00	\N	\N	\N	\N	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.884212+02	2025-10-21 00:24:01.884212+02	\N	\N
29	119	83	49.90	1.00	l	49.90	kr/l	kiwi_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.887927+02	2025-10-21 00:24:01.887927+02	\N	\N
30	162	154	79.90	1.00	stk	\N	\N	meny_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.93187+02	2025-10-21 00:24:01.93187+02	\N	\N
31	161	154	64.90	1.00	stk	\N	\N	meny_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.934013+02	2025-10-21 00:24:01.934013+02	\N	\N
32	166	166	69.90	450.00	g	155.33	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.94721+02	2025-10-21 00:24:01.94721+02	\N	\N
33	199	166	49.90	400.00	g	124.75	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:01.997933+02	2025-10-21 00:24:01.997933+02	\N	\N
34	168	166	32.90	1.00	stk	\N	\N	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.038664+02	2025-10-21 00:24:02.038664+02	\N	\N
35	169	166	39.90	1000.00	g	39.90	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.040976+02	2025-10-21 00:24:02.040976+02	\N	\N
36	170	166	34.90	360.00	g	96.94	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.04326+02	2025-10-21 00:24:02.04326+02	\N	\N
37	176	166	11.00	28.00	g	392.86	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.047991+02	2025-10-21 00:24:02.047991+02	\N	\N
38	174	166	49.90	300.00	g	166.33	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.050174+02	2025-10-21 00:24:02.050174+02	\N	\N
39	182	166	10.00	325.00	g	30.77	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.056564+02	2025-10-21 00:24:02.056564+02	\N	\N
40	119	166	69.90	0.75	l	93.20	kr/l	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.061709+02	2025-10-21 00:24:02.061709+02	\N	\N
41	189	166	39.90	150.00	g	266.00	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.066834+02	2025-10-21 00:24:02.066834+02	\N	\N
42	190	166	69.90	300.00	g	233.00	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.069241+02	2025-10-21 00:24:02.069241+02	\N	\N
43	192	166	49.90	160.00	g	311.88	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.072843+02	2025-10-21 00:24:02.072843+02	\N	\N
44	194	166	29.90	385.00	g	77.66	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.077247+02	2025-10-21 00:24:02.077247+02	\N	\N
46	202	166	34.90	900.00	g	38.78	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.084486+02	2025-10-21 00:24:02.084486+02	\N	\N
47	204	166	69.90	800.00	g	87.38	kr/kg	rema_1000_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.086488+02	2025-10-21 00:24:02.086488+02	\N	\N
48	246	246	50.00	0.33	l	151.52	kr/l	spar_20251020.json	2025-10-26	2025-11-01	2025-10-21 00:24:02.128468+02	2025-10-21 00:24:02.128468+02	\N	2 for 100
49	273	1	25.00	\N	kg	\N	\N	Bunnpris_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.160923+01	2025-10-29 23:09:46.160923+01	\N	\N
50	284	1	45.00	\N	g	\N	\N	Bunnpris_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.248131+01	2025-10-29 23:09:46.248131+01	\N	\N
51	286	1	30.00	\N	g	\N	\N	Bunnpris_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.249051+01	2025-10-29 23:09:46.249051+01	\N	\N
52	15	11	40.00	550.00	g	72.73	kr/kg	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.303929+01	2025-10-29 23:09:46.303929+01	\N	\N
53	16	11	19.00	\N	\N	\N	\N	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.30499+01	2025-10-29 23:09:46.30499+01	\N	\N
54	13	11	45.00	450.00	g	100.00	kr/kg	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.305894+01	2025-10-29 23:09:46.305894+01	\N	\N
55	14	11	25.00	\N	\N	\N	\N	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.306813+01	2025-10-29 23:09:46.306813+01	\N	\N
56	19	11	15.00	1.00	stk	\N	\N	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.311602+01	2025-10-29 23:09:46.311602+01	\N	\N
57	58	11	15.00	2000.00	g	7.50	kr/kg	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.314002+01	2025-10-29 23:09:46.314002+01	\N	\N
58	30	11	99.90	900.00	g	111.00	kr/kg	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.324774+01	2025-10-29 23:09:46.324774+01	\N	\N
59	29	11	69.90	18.00	stk	\N	\N	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.325612+01	2025-10-29 23:09:46.325612+01	\N	\N
60	28	11	16.90	6.00	stk	\N	\N	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.333713+01	2025-10-29 23:09:46.333713+01	\N	\N
61	45	11	59.00	1.00	pk	\N	\N	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.344836+01	2025-10-29 23:09:46.344836+01	\N	\N
62	46	11	19.00	1.00	pk	\N	\N	coop_extra_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.345666+01	2025-10-29 23:09:46.345666+01	\N	\N
63	341	11	24.90	\N	stk	\N	\N	Coop_Extra_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.376047+01	2025-10-29 23:09:46.376047+01	\N	\N
64	342	11	18.90	\N	kg	\N	\N	Coop_Extra_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.376873+01	2025-10-29 23:09:46.376873+01	\N	\N
65	343	11	5.90	\N	g	\N	\N	Coop_Extra_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.377689+01	2025-10-29 23:09:46.377689+01	\N	\N
66	344	11	20.90	\N	stk	\N	\N	Coop_Extra_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.378749+01	2025-10-29 23:09:46.378749+01	\N	\N
67	345	11	60.90	\N	g	\N	\N	Coop_Extra_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.379919+01	2025-10-29 23:09:46.379919+01	\N	\N
68	447	83	24.90	\N	g	\N	\N	KIWI_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.49566+01	2025-10-29 23:09:46.49566+01	\N	\N
69	87	83	19.90	\N	\N	\N	\N	kiwi_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.506505+01	2025-10-29 23:09:46.506505+01	\N	\N
70	92	83	99.00	10.00	stk	\N	\N	kiwi_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.511131+01	2025-10-29 23:09:46.511131+01	\N	\N
71	93	83	24.90	1.00	stk	\N	\N	kiwi_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.512213+01	2025-10-29 23:09:46.512213+01	\N	\N
72	94	83	69.90	1.00	stk	\N	\N	kiwi_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.514084+01	2025-10-29 23:09:46.514084+01	\N	\N
73	466	83	34.90	\N	stk	\N	\N	KIWI_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.525244+01	2025-10-29 23:09:46.525244+01	\N	\N
74	481	83	17.90	\N	l	\N	\N	KIWI_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.545074+01	2025-10-29 23:09:46.545074+01	\N	\N
75	456	83	39.90	\N	kg	\N	\N	KIWI_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.547092+01	2025-10-29 23:09:46.547092+01	\N	\N
76	93	83	69.90	\N	stk	\N	\N	kiwi_20251020.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.547919+01	2025-10-29 23:09:46.547919+01	\N	\N
77	466	83	49.90	\N	stk	\N	\N	KIWI_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.551545+01	2025-10-29 23:09:46.551545+01	\N	\N
78	470	83	44.00	\N	g	\N	\N	KIWI_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.553183+01	2025-10-29 23:09:46.553183+01	\N	\N
79	471	83	44.00	\N	g	\N	\N	KIWI_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.554217+01	2025-10-29 23:09:46.554217+01	\N	\N
80	92	154	99.00	10.00	pk	\N	\N	meny_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.573232+01	2025-10-29 23:09:46.573232+01	\N	\N
81	156	154	149.00	\N	\N	\N	\N	meny_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.575492+01	2025-10-29 23:09:46.575492+01	\N	\N
82	169	166	39.90	1000.00	g	39.90	kr/kg	rema_1000_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.587632+01	2025-10-29 23:09:46.587632+01	\N	\N
83	179	166	24.90	500.00	g	49.80	kr/kg	rema_1000_20251020.json	2025-10-21	2025-10-29	2025-10-29 23:09:46.601758+01	2025-10-29 23:09:46.601758+01	\N	\N
84	499	166	20.50	\N	g	\N	\N	REMA_1000_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.603546+01	2025-10-29 23:09:46.603546+01	\N	\N
85	142	166	79.90	\N	g	\N	\N	REMA_1000_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.610326+01	2025-10-29 23:09:46.610326+01	\N	\N
86	515	166	49.90	\N	g	\N	\N	REMA_1000_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.623169+01	2025-10-29 23:09:46.623169+01	\N	\N
87	540	166	49.90	\N	g	\N	\N	REMA_1000_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.661204+01	2025-10-29 23:09:46.661204+01	\N	\N
88	509	166	49.90	\N	g	\N	\N	REMA_1000_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.662091+01	2025-10-29 23:09:46.662091+01	\N	\N
89	516	166	27.90	\N	g	\N	\N	REMA_1000_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.667192+01	2025-10-29 23:09:46.667192+01	\N	\N
90	517	166	47.90	\N	g	\N	\N	REMA_1000_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.668062+01	2025-10-29 23:09:46.668062+01	\N	\N
91	518	166	27.90	\N	g	\N	\N	REMA_1000_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.668904+01	2025-10-29 23:09:46.668904+01	\N	\N
92	323	166	34.90	\N	kg	\N	\N	REMA_1000_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.674604+01	2025-10-29 23:09:46.674604+01	\N	\N
93	560	246	59.90	\N	g	\N	\N	SPAR_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.705697+01	2025-10-29 23:09:46.705697+01	\N	\N
94	551	246	\N	\N	g	\N	\N	SPAR_20251029.json	2025-10-29	2025-10-29	2025-10-29 23:09:46.734372+01	2025-10-29 23:09:46.734372+01	\N	\N
\.


--
-- TOC entry 5010 (class 0 OID 16512)
-- Dependencies: 228
-- Data for Name: produkt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produkt (id, navn, kategori_id) FROM stdin;
2	Pepsi Max / Solo Super	1
3	Proteinprodukter fra YT, Propud, Arla, Sunniva og Skyr	3
5	Dr. Oetker My Pizza Slice	5
6	MY Pizza Slice Ham-Cheese og Mozzarella-Pesto	5
7	Imsdal Naturell og Fersken	1
1	Et stort utvalg Fun Light	1
9	Et utvalg proteinprodukter fra YT, Propud, Arla, Sunniva og Skyr	3
4	CULT energidrikk	1
12	Pærer	12
13	Coop Mormors fiskekaker	13
15	Mors hjemmebakte flatbrød	15
17	Gilde skinnfri wienerpølser	1
16	Norske poteter	12
130	KVIKK LUNSJ	11
21	Coop rotfruktsmix	12
22	Wokmiks	12
28	Coop Barer 6 pk	11
29	Kinder Maxi 18 pk	11
30	Swizzels Big Party Mix	11
31	Sunniva Juice	1
32	Lipton Forest Fruit Tea	1
33	Twinings Tea	1
34	Honning Centralen Honning fra Akasie	3
35	Tine Yoghurt	26
36	OMO Flytende Color/Ultra Hvitt	36
37	Energizer Max Batterier	3
38	Energizer Batterier	3
39	Energizer Max Plus	3
41	Myk Jerseylaken	3
43	Raggsokk	3
44	Ullsokk	3
45	Halloween Utskjæringssett	3
46	Halloween Godteribøtte	3
47	Softer Days Socks	3
48	Slazenger Socks	3
49	Linea Tape med holder	3
50	Linea Gavepapir	36
51	Rana Gnocchi	5
52	Rana Ravioli	5
53	Mutti Tomat	12
54	Coop Pastasaus Basilicata	54
55	Schweppes	1
56	Maarud Potetskruer Salt	12
11	Alle storplater fra Freia og Nidar	11
58	Løk strømpe	12
19	Änglamark krydderurter	12
60	Coop Rotfrukts	12
61	Salat wokmiks	12
62	Chili rød	12
23	Ingefær	12
24	Hoff Opphøgde Poteter	12
25	Lofoten Fiskeburger	13
26	Coop Burgerost Cheddar	26
27	Coop Prime Time Burgerbrød	15
68	Coop Barer	11
69	Kinder Maxi	11
70	Sjokolade	11
71	Santos	11
72	Husholdningspapir	36
73	Juice	1
74	Ferdig pizza	5
75	Polpa	54
76	Fettucine	54
77	Korni	77
78	Apelin	3
79	Fanta	1
80	Sprite	1
81	Paprika	12
82	Honningsyltetøy	12
14	Norske epler	12
87	Kålrot	12
85	Brokkolini	12
89	Mandelpoteter	12
90	Middelhavsmix, Crispi Mix, Romano Mix	54
91	Isberg Mix, Meksikansk Mix	12
131	MYK&RUND, JULIUS	15
96	Kyllinglårfilet	83
132	MELANGE FLYTENDE	36
99	Lårfilet av kylling	83
100	Biter av kyllingfilet	83
168	Blomkål	12
149	Kjøttsuppe	83
103	Hel kylling	83
104	Gresskar	12
106	Svinekotletter	83
105	Svineknoke	83
109	Svinekam	83
110	Storfekjøtt høyrygg i bit	83
111	Laksefilet m/skinn	13
112	Ørretfilet m/skinn	13
113	SWEET&SOUR KYLLINGGRYTE	83
114	FISKEBURGER 80% FISK	13
115	FISKESUPPE	13
116	THAISUPPE	5
117	KJØTTKRAFTSUPPE	83
118	KJØTTKRAFT LAPSKAUS	83
120	Lapskaus	5
121	Pizzabunn Prime	5
122	Eldorado Mozzarella	26
123	Synnøve Revet Økonomipakke	26
124	PIZZASAUS	54
125	RØMMEDRESSING	5
126	PEPPERONI	5
127	KJØTTBOLLER	83
128	PINNEKJØTT/PINNESTEIK	83
129	LUTEFISK	13
84	Poteter	12
157	Barnemat og barnemateglass	157
93	Calluna	3
94	Calluna Trio	3
138	Prior Kyllingfilet	83
98	Strimler av kyllingfilet	83
83	Kyllingfilet	83
142	Kylling lårfilet	83
143	Kyllingfilet 360 g, 2-pk, Lovise	83
144	Kyllingfilet 200 g, stekt/skivet, soltørket tomat	83
145	Hel kylling ca. 1.5 kg, Prior	83
108	Nakkekoteletter av svin	83
147	Sweet & Sour Kyllinggryte	83
150	Mozzarella	26
151	Revet	26
152	Pepperoni	3
153	Kjøttboller	83
92	Roser	3
155	Tulipanmix	3
156	Roser, Chrysanthemum og Hyperikum	3
158	Pizzaer	5
159	Define hårpleie	157
160	Pierre Robert tekstil	157
162	Tørkeruller	36
165	Finish power all-in-1	36
167	Kjeldsberg kaffe	1
166	Strimlet kyllingfilet	83
172	Kylling Tikka Masala	83
173	Tortillas 4pk	54
169	Middagsris	54
170	Tikka Masala	5
174	Original revet ost	26
161	Toalettpapir	36
175	Enchiladas med kylling	83
177	Hakkede tomater kylling	83
178	Hakkede tomater	12
179	Tagliatelle	54
180	Feta	26
181	Grønnkål	12
183	Nypotet	12
184	Bearnaisesaus	54
185	Wok Mix	12
186	Tom Kha Suppe	5
188	Indisk Kyllingsuppe	83
191	Torsk Skrei Terning	13
193	Kyllingburger	83
195	Hel Sprø Fiskeburger	13
196	Sprø Torsk	13
197	Laks Loin U/Skinn	13
198	Kjøttkaker	83
310	Berlinerboller	269
201	Svinekjøttdeig 20%	83
203	Kjøttboller XXL	83
205	Stuffed Crust Pizza	5
206	TAGA Biff Trio	83
207	TAGA Kylling Trio	83
208	Trio Kylling	83
209	Pampas Entrecôte	83
210	Kylling Lårfilet	83
211	TINE Gräddost	26
212	Skyr Mini	26
213	Skinke XXL	83
214	Havrebrød m/spelt	15
215	Kyllingpølse	1
216	Stranda skinke renskåret	83
217	Skrella Mozzarella	26
218	Kongsgaard	26
219	Gårdsost bit	26
223	Tortillas 6pk	15
176	Taco Spice Mix	54
226	Hakkede tomater hvitløk	12
227	Kylling med feta & grønnkål	83
228	Kyllingsnadder	83
182	American BBQ	54
230	Wok mix	5
231	Tomatsuppe	12
119	Thaisuppe	5
233	Indisk suppe	5
189	Reker Pillede	13
190	Strimlet Kyllingfilet	83
236	Torsk Sei Terning	13
192	Torsk Laks Terning	13
238	Helpro Fiskeburger	13
194	Bestemors Fiskekaker	13
240	Laks loin u/skinn	13
199	Karbonader	83
242	Svin kjøttdeig 20%	83
202	Kjøttpølse	1
204	Ytrefilet av svin	83
245	Bacon uten svor	83
247	Klippfisk	13
248	Freia sjokolade	11
249	Småsjokolade	11
250	Snacks	11
251	Extra Sweetmint	11
252	Skolebrød	15
253	Gifflar	11
256	Torky	36
257	Comfort	36
246	Coca-Cola/Fanta/Sprite	1
259	Delikat gulrot	12
260	Rød spisspaprika	12
261	Aspargesbønner/snittebønner	12
262	My Pizza Slice	5
263	Spekesild	13
264	Lasagne	5
265	Melk 1L	26
266	Norvegia Original	26
267	Kvikk Lunsj	11
268	Sprite/Fanta/Urge	1
269	Løvsteik	83
270	Utvalgte Mel Sorter Regal	265
271	Sukkerfri Saft	1
272	Go' Morgen Yoghurt Vanilje og Skogsbær	26
273	Epler	12
274	All Frukt	266
275	Helgekuppet	267
276	Frukt-onsdag	266
277	Fjordland Risgrøt og Rømmegrøt	54
278	Grilstad Kylling Nuggets	83
279	Wienerpølser	83
280	Gilde Skåret Skinke	83
281	Gilde Storfeburger	83
282	Pasta Carbonara, Bolognese, Tikka Masala, Thai Chicken og Kylling	83
283	Woksaus Teriyaki, Oyster & Spring Onion og Hoi Sin	54
284	Revet Økonomipakke	26
285	Utvalgte Peppes produkter	268
286	Bacon Original	83
287	Laks Varmrøkt	13
288	Grytekjøtt Storfe	83
289	Storfe Strimler	83
290	Coca-Cola Uten Sukker	1
291	Utvalgte Lofoten fiskeprodukter	13
292	Melange Margarin	26
293	Lier Surdeigsstykke	269
294	Kokt Skinke Ekte	83
295	Hamburgerrygg	83
296	Mills Italiensk Salat	270
297	Gulost Original Skivet	26
298	Yoplait Kvarg Rips/Vanilje & Sitron	26
299	Yoplait Safari Ape	26
300	Nesquik Frokostblanding	26
301	Sicilia Sitron- og Limesaft	1
302	Tine Sjokomelk	26
303	Nescafé Cappuccino	1
304	Norvegia Ost	26
305	Mellomgrovt Brød	15
306	Ryvita Rug Knekkebrød	15
307	Utvalgte glutenfrie Schär produkter	269
308	Gourmetrundstykke, grove frokostbrød, havrestykke, ostebrød og hindstykke grovt	26
309	Donuts	269
311	Marsipankake rund	269
312	Plukk & Miks Boller	269
313	Sørlandschips Potetgull Rifla	12
314	Osteinger Cheddar & Chili og Ostesprø XL Cheddar	26
315	Cheez Doodles	11
316	Sørlandschips Havsalt, Spansk Paprika og Creme Fraiche	11
317	New Energy og Troika	271
318	Lion	271
319	Twix, Mars og Snickers	271
320	Sprite u/sukker, Urge, Fanta Orange Zero, Fanta Lemon og Coca-Cola Sleek m/u sukker	1
321	Sprite, Fanta, Coca-Cola	1
322	Utvalgte Melkesorter Regal	26
323	Sukker	265
324	Frukt	266
325	Smågodt	11
326	Rømmegrøt	26
327	Kylling Nuggets	83
328	Grytekjøtt storfe	83
329	Grandiosa Pizza	272
330	Friele Kaffe	1
331	Toro Supper/Sauser/Gryter	54
332	Gulrøtter	273
333	Gilde kjøttkaker	83
334	Coop tyttebærsyltetøy 60%	26
335	Gilde kjøttpølse	83
336	Coop bacon uten svor	83
337	Rørvik fiskeboller	13
338	Coop snackpaprika	275
339	Coop hvitløk	275
340	Coop HverdagsTomat	273
341	Mango Spisemoden	266
342	Søtpoteter	12
343	Sjampinjong	273
344	Granateple	12
345	Coop Blåbær	266
346	Coop Chews	11
347	Maarud Goldfish	11
348	Lofotburger 86% Torsk/Sei	13
349	Prior Crispy Sticks	54
350	Coop Sprø Pommes Frites/Potetstaver	12
351	Tine Yoghurt Naturell	26
352	Softlan	36
353	Matoppbevaring	276
354	Glassflasker og krukker	276
355	Pierre Robert Sokker	277
356	Northpeak Ullundertøy Voksen	277
357	Northpeak Undertøy til Voksen	277
358	Coop Pizza	272
359	Coop Chips	11
360	Coop Vitamin	278
361	Coop Fryseposer	36
362	Coop Party Mix	11
363	Coop Drops	11
364	Lerøy Fiskekarbonader	13
365	Hatting Rundstykker	269
366	YT Protein	1
367	Yum Yum Nudler	279
368	YT Protein Yoghurt	26
369	Gilde Famileskinke	83
370	Earth Control	11
371	Sørlandschips	11
372	OLW Cheez Doodles	11
373	Freda Småster	11
374	Freda Smil Chewies	11
375	Tyrkisk Peber	11
376	Labello	280
377	Jordan Oppvaskbørste	36
378	Colgate Tannkrem Max Fresh	280
379	Coop Sprudle	1
380	Coop Hverdagstomat	273
381	Gilde Grillpølser	83
382	Regal Hvetemel	265
383	Freia Sjokoladeplater	11
384	Maarud Godt&Blått	11
385	Norske Gulrøtter	273
386	Hatting Pølsebrød	83
387	Mills Potetmos	12
388	Masa Sashimi	281
389	Sunniva Eplejuice	1
390	Coop Fruktmüsli	282
391	Colgate 2x75g Tannkrem	157
392	Coop Vann Uten Kullsyre	1
393	Kvikk Lunsj Sjokolade	11
394	Zinklarian Bakepapir	36
395	Coop Godteri	11
396	Mills Pålegg	270
397	Coop Pizzabunn Original	269
398	Coop Cornflakes og Poteter	12
399	Skivet Laks	13
400	Dave & Jon's Dadler	11
401	Zalo Oppvask- og Kjøkkenspray	36
402	Milo Oppvask	36
403	Coop Hvetetortilla	269
404	Gilde Skinnfri Kjøttpølse	83
405	Tine Revet Original	26
406	Olivero Soft Flora	26
407	Coop Fersk Laks	13
408	Softlan Skyllemiddel	36
409	Findus Fiskegrateng	13
410	Softlan Tøymykner	36
411	Lerøy Familiefisk Fiskegrateng	13
412	Polarbrød Havre	15
413	Freia Melkehjerter	26
414	Stabburet Leverpostei	26
415	Snapple Juice	1
416	Fjordland Risgrøt	54
417	Biola	26
418	Coop Passerte Tomater	283
419	Pringles	11
420	Nugatti Nøttepålegg	270
421	Idun Ketchup	284
422	Dolmio	285
423	Ricola	1
424	Coop Bacon uten Svor	83
425	Store Fine Rundstykker	269
426	Skolebrød/Boller	15
427	Donuts med Nonstop	269
428	Wienerbrød	15
429	Battery/Capri-Sun	1
430	Polly Peanøtter	11
431	Pågen Gifflar	286
432	Freia Posemix	11
433	Snickers/Twix	11
434	Fun Light	1
435	Apetina Original	26
436	Wokmiks Red Curry/Teriyaki	5
437	Coop Gulerøtter	273
438	Coop Røde Druer	266
439	Coop Ruccolasalat	1
440	Appelsiner	266
441	Coop Fersk Kake	286
442	Coop Wokmiks Red Curry	5
443	Coop Wokmiks Teriyaki	5
444	Libero bleier	157
445	Big One Pizza	272
446	Nidar Smågodt	267
447	Gulrot	273
448	Løk	273
449	Norsk Rød Spisskål	273
450	Norske Småpoteter	12
451	Rødbeter	273
452	Betemiks	273
453	Rotmiks	273
454	Norsk Gul Løk	273
455	Kinakål	273
456	Purre	273
457	Mix Salat & Rødbeter	273
458	Mix Salat&Reddik, Mix Salat&Rødbete	273
459	Feldsalat Mix, Babyspinat, Babyleaf Mix, Ruccula	273
460	Toro Snarkokt Risgrøt	54
461	Original Risgrøt	54
462	Pariseragurker	54
463	Hakkede Tomater og Pizzasaus	54
464	Grov Sennep	274
465	Sterk Sennep	274
466	Evergood Kaffekapsler	1
467	Hvetemel	265
468	Pizza Rustica	272
469	Hjemmelagde Fiskekaker	13
470	Fiskekaker Hjerteformet	13
471	Pizzabunn Surdeig	269
472	Mors Grovbrød	15
473	Sæterbrød	15
474	Gårdsbrød	15
475	Sørlandsis	288
476	Fløteis Beger	288
477	Pepperkaker	269
478	Bacon i bit	83
479	Skinnfri kjøttpølse	83
480	Majones	270
481	Julebrus	1
482	Purreløk	273
483	Idun Grov Sennep	274
484	Idun Sterk Sennep	274
485	Glemt & Frisk salat mix	54
486	Bananer	12
487	Blåbær	266
488	Guacamole	289
489	Kuttet frisk storfe biffer	54
490	Taco-produkter	290
491	Tulipanmiks	287
492	Laksefilet Naturell	13
493	Grandiosa Full Pakke	83
494	Godehav Laksefilet	13
495	Babyspinat	273
496	Wokgrønnsaker Sweet Chili	273
497	Potetstappe	12
498	Brokkoli	273
499	Grønn Pesto	291
500	Sitron	266
501	Matfløte	26
502	Rosenkål	273
503	Sandefjordsaus	54
504	All Yoghurt fra Tine	26
505	Santa Maria Naan Bread	269
506	Kylling kjøttboller	83
507	Asia fiskeburger	13
508	Bestemors fiskekaker	13
509	Grateng Familiens	83
510	Laks Lenke U/Skinn	13
511	Big Beef Burger	83
512	Kjøtt- og Grønnsaksdeig	83
513	Grovt Hverdagsbrød	15
514	Utvalgte Knekkebrød	15
515	Grilstad	83
516	Grovbrød	15
517	Jubelsalami	83
518	Din Stund	11
519	Ternet Bacon	83
520	Kokt Skinke XXL	83
521	RÅ Kaldpresset Juice	1
522	Marsipan-/sjokoladekake	11
523	Tricolor paprika	273
524	Tynnribbe	83
525	Urøkt Pinnekjøtt	83
526	Julebrus Utsukker	1
527	Marsipanbrød	15
528	Julekuler	271
529	Skumnisser	271
530	Grans Julebrus u/sukker	1
531	Julebrunost	26
532	Julebrunost skivet	26
533	Plukk og miks	83
534	KiMs chips	11
535	Kims Chips	11
536	Mjølkeruta Storplate	293
537	Seigmenn	267
538	Laksefilet naturell	13
539	Woksaus Sweet Chili	54
540	Fiskekaker	13
541	Laks Lenke U/skinn	13
542	Grilstad Jubelsalami	83
543	Dine Yoghurt	26
544	Terning Bacon	83
545	Siktet Hvetemel	265
546	Dove Såpe	157
547	Røkt Laks XXL	13
548	Marsipan-sjokoladekake	11
549	Evergood	1
550	Taco	294
551	Melange	26
552	Rein skank	83
553	Diverse produkter	294
554	Kjære bønder, takk for maten!	294
555	Norske epler 6-pk	12
556	Druer	266
557	Sunn Snækk	295
558	Godt til middag	294
559	Fiskeburger 4-pk.	13
560	Grytekjøtt	83
561	Revet Synnøve	26
562	Bertagni pasta	54
563	Kornbrød	15
564	Fransk Landbrød	15
565	Julebakst	269
566	Alpro	1
567	Julekake	286
568	Yoghurt	26
569	Twinings/Lipton	1
570	Godteri	267
571	Potetgull	12
572	Battery	1
573	Möller's/Sana-sol/Vitaminbjørner	278
574	Isklar	1
575	Dyresnacks	294
576	TINE smaksrike oster	26
577	Finsbråten pålegg	83
578	Dr. Greve	280
579	Nøtter fra Den Lille Nøttefabrikken	11
580	Tulipaner	287
581	Novemberkaktus	296
582	Tomater	273
583	Dybvik Bacalao	83
584	Fripa IPA	1
585	Valdresost	26
586	Sursild	83
587	Frosta Chips	26
\.


--
-- TOC entry 5000 (class 0 OID 16434)
-- Dependencies: 218
-- Data for Name: produkter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produkter (id, pris, mengde, enhet, dato, pris_per_enhet, pris_per_enhet_enhet, kilde_fil, butikk_id, produkt_id, rabatt) FROM stdin;
1	20.00	0.80	l	2025-10-21	25.00	kr/l	bunnpris_20251020.json	1	1	\N
2	100.00	15.00	l	2025-10-21	6.67	kr/l	bunnpris_20251020.json	1	2	\N
3	66.67	\N	\N	2025-10-21	\N	\N	bunnpris_20251020.json	1	3	3 for 200
4	10.00	0.50	l	2025-10-21	20.00	kr/l	bunnpris_20251020.json	1	4	\N
5	25.00	2.00	stk	2025-10-21	\N	\N	bunnpris_20251020.json	1	5	2 for 50
6	25.00	145.00	g	2025-10-21	172.41	kr/kg	bunnpris_20251020.json	1	6	2 for 50
7	15.00	0.65	l	2025-10-21	23.08	kr/l	bunnpris_20251020.json	1	7	2 for 30
8	66.67	\N	\N	2025-10-21	\N	\N	bunnpris_20251020.json	1	9	3 for 200
9	36.67	150.00	g	2025-10-21	244.47	kr/kg	coop_extra_20251020.json	11	11	3 for 110
10	29.90	\N	\N	2025-10-21	\N	\N	coop_extra_20251020.json	11	12	\N
15	25.00	600.00	g	2025-10-21	41.67	kr/kg	coop_extra_20251020.json	11	17	\N
17	29.00	600.00	g	2025-10-21	48.33	kr/kg	coop_extra_20251020.json	11	21	\N
18	30.00	1.00	stk	2025-10-21	\N	\N	coop_extra_20251020.json	11	22	\N
19	10.00	1.00	stk	2025-10-21	\N	\N	coop_extra_20251020.json	11	23	\N
20	49.90	1200.00	g	2025-10-21	41.58	kr/kg	coop_extra_20251020.json	11	24	\N
21	89.90	\N	\N	2025-10-21	\N	\N	coop_extra_20251020.json	11	25	\N
22	33.60	\N	\N	2025-10-21	\N	\N	coop_extra_20251020.json	11	26	\N
23	30.00	6.00	stk	2025-10-21	\N	\N	coop_extra_20251020.json	11	27	\N
27	34.90	1.50	l	2025-10-21	23.27	kr/l	coop_extra_20251020.json	11	31	\N
28	36.90	20.00	pose	2025-10-21	\N	\N	coop_extra_20251020.json	11	32	\N
29	59.90	20.00	pose	2025-10-21	\N	\N	coop_extra_20251020.json	11	33	\N
30	69.90	350.00	g	2025-10-21	199.71	kr/kg	coop_extra_20251020.json	11	34	\N
31	29.30	850.00	g	2025-10-21	34.47	kr/kg	coop_extra_20251020.json	11	35	\N
32	39.90	0.75	l	2025-10-21	53.20	kr/l	coop_extra_20251020.json	11	36	\N
33	31.90	2.00	pk	2025-10-21	\N	\N	coop_extra_20251020.json	11	37	\N
34	49.90	4.00	pk	2025-10-21	\N	\N	coop_extra_20251020.json	11	38	\N
35	129.00	12.00	pk	2025-10-21	\N	\N	coop_extra_20251020.json	11	39	\N
36	149.00	\N	\N	2025-10-21	\N	\N	coop_extra_20251020.json	11	41	\N
37	99.00	2.00	pk	2025-10-21	\N	\N	coop_extra_20251020.json	11	43	\N
38	89.90	2.00	pk	2025-10-21	\N	\N	coop_extra_20251020.json	11	44	\N
41	49.50	2.00	pk	2025-10-21	\N	\N	coop_extra_20251020.json	11	47	2 for 99
42	64.50	3.00	pk	2025-10-21	\N	\N	coop_extra_20251020.json	11	48	2 for 129
43	19.50	2.00	stk	2025-10-21	\N	\N	coop_extra_20251020.json	11	49	2 for 39
44	29.50	2.00	stk	2025-10-21	\N	\N	coop_extra_20251020.json	11	50	2 for 59
45	49.20	500.00	g	2025-10-21	98.40	kr/kg	coop_extra_20251020.json	11	51	\N
46	50.90	250.00	g	2025-10-21	203.60	kr/kg	coop_extra_20251020.json	11	52	\N
47	21.90	400.00	g	2025-10-21	54.75	kr/kg	coop_extra_20251020.json	11	53	\N
48	23.20	390.00	g	2025-10-21	59.49	kr/kg	coop_extra_20251020.json	11	54	\N
49	40.30	1.50	l	2025-10-21	26.87	kr/l	coop_extra_20251020.json	11	55	\N
50	23.50	165.00	g	2025-10-21	142.42	kr/kg	coop_extra_20251020.json	11	56	\N
52	29.00	150.00	g	2025-10-21	193.33	kr/kg	coop_extra_20251020.json	11	60	\N
53	30.00	1.00	stk	2025-10-21	\N	\N	coop_extra_20251020.json	11	61	\N
54	10.00	1.00	stk	2025-10-21	\N	\N	coop_extra_20251020.json	11	62	\N
55	16.90	6.00	pk	2025-10-21	\N	\N	coop_extra_20251020.json	11	68	\N
56	69.90	18.00	pk	2025-10-21	\N	\N	coop_extra_20251020.json	11	69	\N
57	36.67	200.00	g	2025-10-21	183.35	kr/kg	coop_prix_20251020.json	70	70	3 for 110
58	25.00	200.00	g	2025-10-21	125.00	kr/kg	coop_prix_20251020.json	70	71	2 for 50
59	29.90	\N	\N	2025-10-21	\N	\N	coop_prix_20251020.json	70	72	\N
60	9.00	1.00	l	2025-10-21	9.00	kr/l	coop_prix_20251020.json	70	73	2 for 18
61	29.90	1.00	stk	2025-10-21	\N	\N	coop_prix_20251020.json	70	74	\N
62	25.00	400.00	g	2025-10-21	62.50	kr/kg	coop_prix_20251020.json	70	75	2 for 50
63	25.00	500.00	g	2025-10-21	50.00	kr/kg	coop_prix_20251020.json	70	76	2 for 50
64	34.90	500.00	g	2025-10-21	69.80	kr/kg	coop_prix_20251020.json	70	77	\N
65	44.90	500.00	g	2025-10-21	89.80	kr/kg	coop_prix_20251020.json	70	78	\N
66	24.90	1.50	l	2025-10-21	16.60	kr/l	coop_prix_20251020.json	70	79	\N
67	24.90	1.50	l	2025-10-21	16.60	kr/l	coop_prix_20251020.json	70	80	\N
68	19.90	1.00	stk	2025-10-21	\N	\N	coop_prix_20251020.json	70	81	\N
69	39.00	1.00	stk	2025-10-21	\N	\N	coop_prix_20251020.json	70	82	\N
70	144.90	1400.00	g	2025-10-21	103.50	kr/kg	kiwi_20251020.json	83	83	\N
71	39.90	2000.00	g	2025-10-21	19.95	kr/kg	kiwi_20251020.json	83	84	\N
72	29.90	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	85	\N
73	24.90	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	14	\N
75	39.90	1500.00	g	2025-10-21	26.60	kr/kg	kiwi_20251020.json	83	89	\N
76	19.90	175.00	g	2025-10-21	113.71	kr/kg	kiwi_20251020.json	83	90	\N
77	24.90	270.00	g	2025-10-21	92.22	kr/kg	kiwi_20251020.json	83	91	\N
14	19.00	\N	kg	2025-10-29	\N	\N	coop_extra_20251020.json	11	16	
11	45.00	\N	g	2025-10-29	100.00	kr/kg	coop_extra_20251020.json	11	13	
12	25.00	\N	kg	2025-10-29	\N	\N	coop_extra_20251020.json	11	14	
16	15.00	\N	g	2025-10-29	\N	\N	coop_extra_20251020.json	11	19	
51	15.00	\N	g	2025-10-29	7.50	kr/kg	coop_extra_20251020.json	11	58	
26	99.90	\N	g	2025-10-29	111.00	kr/kg	coop_extra_20251020.json	11	30	
25	69.90	\N	g	2025-10-29	\N	\N	coop_extra_20251020.json	11	29	
24	16.90	\N		2025-10-29	\N	\N	coop_extra_20251020.json	11	28	
39	59.00	\N	l	2025-10-29	\N	\N	coop_extra_20251020.json	11	45	
40	19.00	\N	stk	2025-10-29	\N	\N	coop_extra_20251020.json	11	46	
74	9.90	\N	kg	2025-10-29	\N	\N	kiwi_20251020.json	83	87	
78	99.00	\N	stk	2025-10-29	\N	\N	kiwi_20251020.json	83	92	
79	24.90	\N	stk	2025-10-29	\N	\N	kiwi_20251020.json	83	93	
81	109.40	900.00	g	2025-10-21	121.56	kr/kg	kiwi_20251020.json	83	96	\N
82	49.60	400.00	g	2025-10-21	124.00	kr/kg	kiwi_20251020.json	83	98	\N
83	84.90	600.00	g	2025-10-21	141.50	kr/kg	kiwi_20251020.json	83	99	\N
84	89.90	600.00	g	2025-10-21	149.83	kr/kg	kiwi_20251020.json	83	100	\N
85	79.90	1500.00	g	2025-10-21	53.27	kr/kg	kiwi_20251020.json	83	103	\N
86	14.90	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	104	\N
87	69.90	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	105	\N
88	114.90	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	106	\N
89	219.00	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	108	\N
90	99.00	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	109	\N
91	219.00	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	110	\N
92	74.80	100.00	g	2025-10-21	748.00	kr/kg	kiwi_20251020.json	83	111	\N
93	116.00	100.00	g	2025-10-21	1160.00	kr/kg	kiwi_20251020.json	83	112	\N
94	69.90	460.00	g	2025-10-21	151.96	kr/kg	kiwi_20251020.json	83	113	\N
95	59.90	480.00	g	2025-10-21	124.79	kr/kg	kiwi_20251020.json	83	114	\N
96	39.00	1.00	l	2025-10-21	39.00	kr/l	kiwi_20251020.json	83	115	\N
97	39.00	1.00	l	2025-10-21	39.00	kr/l	kiwi_20251020.json	83	116	\N
98	39.00	1.00	l	2025-10-21	39.00	kr/l	kiwi_20251020.json	83	117	\N
99	39.00	1.00	l	2025-10-21	39.00	kr/l	kiwi_20251020.json	83	118	\N
100	49.90	1.00	l	2025-10-21	49.90	kr/l	kiwi_20251020.json	83	119	\N
101	59.90	1000.00	g	2025-10-21	59.90	kr/kg	kiwi_20251020.json	83	120	\N
102	69.90	1.00	stk	2025-10-21	\N	\N	kiwi_20251020.json	83	121	\N
103	25.40	200.00	g	2025-10-21	127.00	kr/kg	kiwi_20251020.json	83	122	\N
104	43.40	370.00	g	2025-10-21	117.30	kr/kg	kiwi_20251020.json	83	123	\N
105	18.90	180.00	g	2025-10-21	105.00	kr/kg	kiwi_20251020.json	83	124	\N
106	23.40	125.00	g	2025-10-21	187.20	kr/kg	kiwi_20251020.json	83	125	\N
107	27.90	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	126	\N
108	34.90	\N	\N	2025-10-21	\N	\N	kiwi_20251020.json	83	127	\N
109	38900.00	1800.00	g	2025-10-21	21611.11	kr/kg	kiwi_20251020.json	83	128	\N
110	16900.00	1200.00	g	2025-10-21	14083.33	kr/kg	kiwi_20251020.json	83	129	\N
111	34.90	1.00	stk	2025-10-21	\N	\N	kiwi_20251020.json	83	130	\N
112	29.90	12.00	stk	2025-10-21	\N	\N	kiwi_20251020.json	83	131	\N
113	34.90	0.50	l	2025-10-21	69.80	kr/l	kiwi_20251020.json	83	132	\N
114	29.90	400.00	g	2025-10-21	74.75	kr/kg	kiwi_20251020.json	83	138	\N
115	43.90	300.00	g	2025-10-21	146.33	kr/kg	kiwi_20251020.json	83	142	\N
116	79.90	360.00	g	2025-10-21	221.94	kr/kg	kiwi_20251020.json	83	143	\N
117	43.90	200.00	g	2025-10-21	219.50	kr/kg	kiwi_20251020.json	83	144	\N
118	79.90	1500.00	g	2025-10-21	53.27	kr/kg	kiwi_20251020.json	83	145	\N
119	69.90	460.00	g	2025-10-21	151.96	kr/kg	kiwi_20251020.json	83	147	\N
120	59.00	1.00	l	2025-10-21	59.00	kr/l	kiwi_20251020.json	83	149	\N
121	25.40	210.00	g	2025-10-21	120.95	kr/kg	kiwi_20251020.json	83	150	\N
122	43.40	370.00	g	2025-10-21	117.30	kr/kg	kiwi_20251020.json	83	151	\N
123	27.90	70.00	g	2025-10-21	398.57	kr/kg	kiwi_20251020.json	83	152	\N
124	34.90	120.00	g	2025-10-21	290.83	kr/kg	kiwi_20251020.json	83	153	\N
126	149.00	20.00	pk	2025-10-21	\N	\N	meny_20251020.json	154	155	\N
128	66.67	1.00	stk	2025-10-21	\N	\N	meny_20251020.json	154	157	3 for 200
129	66.67	1.00	stk	2025-10-21	\N	\N	meny_20251020.json	154	158	3 for 200
130	66.67	1.00	stk	2025-10-21	\N	\N	meny_20251020.json	154	159	3 for 200
131	66.67	1.00	stk	2025-10-21	\N	\N	meny_20251020.json	154	160	3 for 200
132	64.90	1.00	stk	2025-10-21	\N	\N	meny_20251020.json	154	161	\N
133	79.90	1.00	stk	2025-10-21	\N	\N	meny_20251020.json	154	162	\N
134	109.00	1.00	pk	2025-10-21	\N	\N	meny_20251020.json	154	165	\N
135	69.90	450.00	g	2025-10-21	155.33	kr/kg	rema_1000_20251020.json	166	166	\N
136	34.90	250.00	g	2025-10-21	139.60	kr/kg	rema_1000_20251020.json	166	167	\N
137	32.90	1.00	stk	2025-10-21	\N	\N	rema_1000_20251020.json	166	168	\N
139	34.90	360.00	g	2025-10-21	96.94	kr/kg	rema_1000_20251020.json	166	170	\N
140	177.60	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	172	\N
141	19.90	320.00	g	2025-10-21	62.19	kr/kg	rema_1000_20251020.json	166	173	\N
142	49.90	300.00	g	2025-10-21	166.33	kr/kg	rema_1000_20251020.json	166	174	\N
143	165.60	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	175	\N
144	11.00	28.00	g	2025-10-21	392.86	kr/kg	rema_1000_20251020.json	166	176	\N
145	14.90	390.00	g	2025-10-21	38.21	kr/kg	rema_1000_20251020.json	166	177	\N
146	14.90	390.00	g	2025-10-21	38.21	kr/kg	rema_1000_20251020.json	166	178	\N
148	32.10	150.00	g	2025-10-21	214.00	kr/kg	rema_1000_20251020.json	166	180	\N
149	39.90	180.00	g	2025-10-21	221.67	kr/kg	rema_1000_20251020.json	166	181	\N
150	10.00	325.00	g	2025-10-21	30.77	kr/kg	rema_1000_20251020.json	166	182	\N
151	19.90	1000.00	g	2025-10-21	19.90	kr/kg	rema_1000_20251020.json	166	183	\N
152	35.00	300.00	g	2025-10-21	116.67	kr/kg	rema_1000_20251020.json	166	184	\N
153	42.90	700.00	g	2025-10-21	61.29	kr/kg	rema_1000_20251020.json	166	185	\N
154	69.90	0.75	l	2025-10-21	93.20	kr/l	rema_1000_20251020.json	166	186	\N
155	69.90	0.75	l	2025-10-21	93.20	kr/l	rema_1000_20251020.json	166	119	\N
156	69.90	0.75	l	2025-10-21	93.20	kr/l	rema_1000_20251020.json	166	188	\N
157	39.90	150.00	g	2025-10-21	266.00	kr/kg	rema_1000_20251020.json	166	189	\N
158	69.90	300.00	g	2025-10-21	233.00	kr/kg	rema_1000_20251020.json	166	190	\N
159	49.90	160.00	g	2025-10-21	311.88	kr/kg	rema_1000_20251020.json	166	191	\N
160	49.90	160.00	g	2025-10-21	311.88	kr/kg	rema_1000_20251020.json	166	192	\N
161	99.90	800.00	g	2025-10-21	124.88	kr/kg	rema_1000_20251020.json	166	193	\N
125	99.00	\N		2025-10-29	\N	\N	meny_20251020.json	154	92	
127	149.00	\N	g	2025-10-29	\N	\N	meny_20251020.json	154	156	
147	25.90	\N	g	2025-10-29	49.80	kr/kg	rema_1000_20251020.json	166	179	
162	29.90	385.00	g	2025-10-21	77.66	kr/kg	rema_1000_20251020.json	166	194	\N
163	59.90	360.00	g	2025-10-21	166.39	kr/kg	rema_1000_20251020.json	166	195	\N
164	79.90	250.00	g	2025-10-21	319.60	kr/kg	rema_1000_20251020.json	166	196	\N
165	79.00	500.00	g	2025-10-21	158.00	kr/kg	rema_1000_20251020.json	166	197	\N
166	49.90	800.00	g	2025-10-21	62.37	kr/kg	rema_1000_20251020.json	166	198	\N
167	49.90	400.00	g	2025-10-21	124.75	kr/kg	rema_1000_20251020.json	166	199	\N
168	29.90	400.00	g	2025-10-21	74.75	kr/kg	rema_1000_20251020.json	166	201	\N
169	34.90	900.00	g	2025-10-21	38.78	kr/kg	rema_1000_20251020.json	166	202	\N
170	49.90	900.00	g	2025-10-21	55.44	kr/kg	rema_1000_20251020.json	166	203	\N
171	69.90	800.00	g	2025-10-21	87.38	kr/kg	rema_1000_20251020.json	166	204	\N
172	44.90	1.00	stk	2025-10-21	\N	\N	rema_1000_20251020.json	166	205	\N
173	49.90	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	206	\N
174	49.90	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	207	\N
175	99.00	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	208	\N
176	269.00	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	209	\N
177	105.00	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	210	\N
178	119.90	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	211	\N
179	10.90	90.00	g	2025-10-21	121.11	kr/kg	rema_1000_20251020.json	166	212	\N
180	39.90	200.00	g	2025-10-21	199.50	kr/kg	rema_1000_20251020.json	166	213	\N
181	34.90	750.00	g	2025-10-21	46.53	kr/kg	rema_1000_20251020.json	166	214	\N
182	25.00	230.00	g	2025-10-21	108.70	kr/kg	rema_1000_20251020.json	166	215	2 for 50
183	81.90	150.00	g	2025-10-21	546.00	kr/kg	rema_1000_20251020.json	166	216	\N
184	29.90	125.00	g	2025-10-21	239.20	kr/kg	rema_1000_20251020.json	166	217	\N
185	67.90	450.00	g	2025-10-21	150.89	kr/kg	rema_1000_20251020.json	166	218	\N
186	99.90	500.00	g	2025-10-21	199.80	kr/kg	rema_1000_20251020.json	166	219	\N
187	19.90	336.00	g	2025-10-21	59.23	kr/kg	rema_1000_20251020.json	166	223	\N
188	14.90	390.00	g	2025-10-21	38.21	kr/kg	rema_1000_20251020.json	166	226	\N
189	181.70	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	227	\N
190	182.70	\N	\N	2025-10-21	\N	\N	rema_1000_20251020.json	166	228	\N
191	42.90	500.00	g	2025-10-21	85.80	kr/kg	rema_1000_20251020.json	166	230	\N
192	69.90	3.00	l	2025-10-21	23.30	kr/l	rema_1000_20251020.json	166	231	\N
193	69.90	3.00	l	2025-10-21	23.30	kr/l	rema_1000_20251020.json	166	233	\N
194	49.90	300.00	g	2025-10-21	166.33	kr/kg	rema_1000_20251020.json	166	236	\N
195	59.90	360.00	g	2025-10-21	166.39	kr/kg	rema_1000_20251020.json	166	238	\N
196	179.00	500.00	g	2025-10-21	358.00	kr/kg	rema_1000_20251020.json	166	240	\N
197	29.90	400.00	g	2025-10-21	74.75	kr/kg	rema_1000_20251020.json	166	242	\N
198	74.90	500.00	g	2025-10-21	149.80	kr/kg	rema_1000_20251020.json	166	245	\N
199	50.00	0.33	l	2025-10-21	151.52	kr/l	spar_20251020.json	246	246	2 for 100
200	200.00	\N	\N	2025-10-21	\N	\N	spar_20251020.json	246	247	\N
201	41.90	100.00	g	2025-10-21	419.00	kr/kg	spar_20251020.json	246	248	\N
202	17.90	57.00	g	2025-10-21	314.04	kr/kg	spar_20251020.json	246	249	\N
203	20.00	160.00	g	2025-10-21	125.00	kr/kg	spar_20251020.json	246	250	\N
204	30.00	1.00	stk	2025-10-21	\N	\N	spar_20251020.json	246	251	\N
205	22.90	140.00	g	2025-10-21	163.57	kr/kg	spar_20251020.json	246	252	\N
206	30.00	300.00	g	2025-10-21	100.00	kr/kg	spar_20251020.json	246	253	\N
207	30.00	1.00	stk	2025-10-21	\N	\N	spar_20251020.json	246	161	\N
208	30.00	1.00	stk	2025-10-21	\N	\N	spar_20251020.json	246	162	\N
209	30.00	\N	\N	2025-10-21	\N	\N	spar_20251020.json	246	256	\N
210	30.00	0.75	l	2025-10-21	40.00	kr/l	spar_20251020.json	246	257	\N
211	25.00	400.00	g	2025-10-21	62.50	kr/kg	spar_20251020.json	246	259	\N
212	30.00	300.00	g	2025-10-21	100.00	kr/kg	spar_20251020.json	246	260	\N
213	20.00	200.00	g	2025-10-21	100.00	kr/kg	spar_20251020.json	246	261	\N
214	20.00	1.00	stk	2025-10-21	\N	\N	spar_20251020.json	246	262	\N
215	30.00	250.00	g	2025-10-21	120.00	kr/kg	spar_20251020.json	246	263	\N
216	30.00	1.00	stk	2025-10-21	\N	\N	spar_20251020.json	246	264	\N
218	99.00	\N	kg	2025-10-29	\N	\N	Bunnpris_20251029.json	1	266	
219	59.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	267	
220	\N	\N	l	2025-10-29	\N	\N	Bunnpris_20251029.json	1	268	
221	99.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	269	
222	\N	\N	kg	2025-10-29	\N	\N	Bunnpris_20251029.json	1	270	
223	59.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	271	
224	55.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	272	
226	\N	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	274	
227	9.90	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	275	
225	\N	\N	kg	2025-10-29	\N	\N	Bunnpris_20251029.json	1	273	
229	\N	\N	l	2025-10-29	\N	\N	Bunnpris_20251029.json	1	276	
230	39.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	277	
231	79.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	278	
232	59.00	\N	kg	2025-10-29	\N	\N	Bunnpris_20251029.json	1	279	
233	39.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	280	
234	49.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	281	
235	\N	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	282	
236	\N	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	283	
237	45.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	24	
239	\N	\N	l	2025-10-29	\N	\N	Bunnpris_20251029.json	1	285	
241	65.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	287	
242	60.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	288	
243	70.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	289	
244	89.00	\N	l	2025-10-29	\N	\N	Bunnpris_20251029.json	1	290	
245	\N	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	291	
238	\N	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	284	
240	\N	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	286	
217	22.90	\N	l	2025-10-29	\N	\N	testdata.json	83	265	20%
246	59.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	292	
247	29.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	293	
248	59.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	294	
249	59.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	295	
250	35.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	296	
251	69.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	297	
252	25.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	298	
253	39.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	299	
254	40.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	300	
255	15.00	\N	l	2025-10-29	\N	\N	Bunnpris_20251029.json	1	301	
256	25.00	\N	l	2025-10-29	\N	\N	Bunnpris_20251029.json	1	302	
257	79.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	303	
258	99.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	304	
259	30.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	305	
260	35.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	306	
261	\N	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	307	
262	25.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	308	
263	25.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	309	
264	25.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	310	
265	179.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	311	
266	25.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	312	
267	49.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	313	
268	29.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	314	
269	69.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	315	
270	59.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	316	
271	69.00	\N	kg	2025-10-29	\N	\N	Bunnpris_20251029.json	1	317	
272	69.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	318	
273	18.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	69	
274	99.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	319	
275	20.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	320	
276	20.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	321	
277	50.00	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	322	
278	59.00	\N	kg	2025-10-29	\N	\N	Bunnpris_20251029.json	1	323	
279	\N	\N		2025-10-29	\N	\N	Bunnpris_20251029.json	1	324	
280	9.90	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	325	
281	39.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	326	
282	79.00	\N	g	2025-10-29	\N	\N	Bunnpris_20251029.json	1	327	
285	65.00	\N	stk	2025-10-29	\N	\N	Bunnpris_20251029.json	1	328	
286	\N	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	329	
287	\N	\N	l	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	330	
288	\N	\N	l	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	331	
289	19.90	\N	kg	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	332	
290	80.00	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	333	
291	40.00	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	334	
13	40.00	\N	g	2025-10-29	72.73	kr/kg	coop_extra_20251020.json	11	15	
296	35.00	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	335	
297	20.00	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	336	
299	40.00	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	337	
301	19.00	\N		2025-10-29	\N	\N	Coop_Extra_20251029.json	11	338	
302	10.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	339	
303	39.90	\N	kg	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	340	
311	19.90	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	346	
312	32.50	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	347	
313	89.90	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	348	
314	57.00	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	349	
315	75.00	\N		2025-10-29	\N	\N	Coop_Extra_20251029.json	11	350	
316	29.50	\N	l	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	290	
318	29.30	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	351	
319	29.90	\N	l	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	352	
320	\N	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	353	
321	\N	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	354	
322	\N	\N		2025-10-29	\N	\N	Coop_Extra_20251029.json	11	355	
323	299.00	\N		2025-10-29	\N	\N	Coop_Extra_20251029.json	11	356	
324	\N	\N		2025-10-29	\N	\N	Coop_Extra_20251029.json	11	357	
325	14.90	\N	kg	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	104	
328	\N	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	358	
329	\N	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	359	
330	45.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	360	
331	25.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	361	
332	55.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	362	
333	40.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	363	
334	55.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	364	
335	55.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	365	
336	55.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	366	
337	60.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	367	
338	45.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	368	
339	40.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	369	
340	55.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	370	
341	55.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	371	
342	25.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	372	
343	75.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	373	
305	18.00	\N	kg	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	342	
306	5.00	\N	kg	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	343	
307	20.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	344	
308	60.00	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	345	
344	50.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	374	
345	35.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	375	
346	45.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	376	
347	30.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	377	
348	75.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	378	
349	25.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	379	
350	39.00	\N	g	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	380	
304	24.00	\N	stk	2025-10-29	\N	\N	Coop_Extra_20251029.json	11	341	
356	50.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	381	
357	80.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	382	
358	40.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	383	
359	50.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	384	
360	19.90	\N	kg	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	385	
361	\N	\N	l	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	329	
362	10.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	386	
363	10.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	35	
364	10.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	387	
365	10.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	388	
366	10.00	\N	l	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	389	
367	10.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	390	
368	10.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	391	
369	10.00	\N	l	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	392	
370	10.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	393	
371	10.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	394	
372	30.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	395	
373	30.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	396	
374	20.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	397	
375	30.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	398	
376	20.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	399	
377	40.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	400	
378	30.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	377	
379	40.00	\N	l	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	401	
380	60.00	\N	l	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	402	
381	50.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	403	
382	40.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	404	
383	50.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	405	
384	40.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	406	
385	100.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	407	
386	35.00	\N	l	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	408	
387	60.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	409	
388	30.00	\N	l	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	410	
389	60.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	411	
390	30.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	412	
391	60.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	413	
392	20.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	414	
393	80.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	415	
394	50.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	416	
395	60.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	417	
396	20.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	418	
397	50.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	419	
398	60.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	420	
399	50.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	421	
400	60.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	422	
401	60.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	423	
402	50.00	\N		2025-10-29	\N	\N	Coop_Prix_20251029.json	70	424	
403	20.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	425	
404	30.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	426	
405	20.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	427	
406	30.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	428	
407	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	429	
408	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	371	
409	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	430	
410	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	431	
411	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	432	
412	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	433	
413	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	434	
414	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	435	
415	19.90	\N	kg	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	332	
416	35.00	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	436	
417	\N	\N	kg	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	437	
418	\N	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	438	
419	\N	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	439	
420	\N	\N	kg	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	440	
421	84.90	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	92	
422	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	441	
423	35.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	442	
424	35.00	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	443	
425	\N	\N	l	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	444	
426	\N	\N	stk	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	445	
427	\N	\N	g	2025-10-29	\N	\N	Coop_Prix_20251029.json	70	446	
429	12.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	448	
430	19.90	\N	stk	2025-10-29	\N	\N	KIWI_20251029.json	83	449	
428	14.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	447	
432	19.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	450	
433	24.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	451	
434	24.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	452	
435	27.90	\N	kg	2025-10-29	\N	\N	KIWI_20251029.json	83	453	
436	12.90	\N		2025-10-29	\N	\N	KIWI_20251029.json	83	454	
437	19.90	\N	stk	2025-10-29	\N	\N	KIWI_20251029.json	83	455	
440	16.90	\N	stk	2025-10-29	\N	\N	KIWI_20251029.json	83	457	
441	17.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	458	
442	16.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	459	
80	69.90	\N	stk	2025-10-29	\N	\N	kiwi_20251020.json	83	94	
446	19.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	460	
447	24.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	461	
448	24.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	462	
449	16.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	463	
450	18.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	464	
451	24.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	465	
511	64.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	509	
454	19.90	\N	kg	2025-10-29	\N	\N	KIWI_20251029.json	83	467	
455	59.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	468	
456	59.90	\N	stk	2025-10-29	\N	\N	KIWI_20251029.json	83	469	
459	19.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	472	
460	19.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	473	
461	19.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	474	
462	54.90	\N	l	2025-10-29	\N	\N	KIWI_20251029.json	83	475	
463	69.90	\N	l	2025-10-29	\N	\N	KIWI_20251029.json	83	476	
464	24.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	477	
465	199.00	\N	kg	2025-10-29	\N	\N	KIWI_20251029.json	83	478	
466	67.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	479	
467	39.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	480	
468	38.90	\N	l	2025-10-29	\N	\N	KIWI_20251029.json	83	481	
470	39.90	\N	stk	2025-10-29	\N	\N	KIWI_20251029.json	83	482	
438	19.90	\N	kg	2025-10-29	\N	\N	KIWI_20251029.json	83	456	
473	24.50	\N		2025-10-29	\N	\N	KIWI_20251029.json	83	483	
474	31.90	\N		2025-10-29	\N	\N	KIWI_20251029.json	83	484	
452	44.00	\N	stk	2025-10-29	\N	\N	KIWI_20251029.json	83	466	
457	59.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	470	
458	59.90	\N	g	2025-10-29	\N	\N	KIWI_20251029.json	83	471	
478	12.90	\N		2025-10-29	\N	\N	KIWI_20251029.json	83	332	
479	20.00	\N	g	2025-10-29	\N	\N	MENY_20251029.json	154	485	
480	19.00	\N	kg	2025-10-29	\N	\N	MENY_20251029.json	154	486	
481	20.00	\N	g	2025-10-29	\N	\N	MENY_20251029.json	154	487	
482	40.00	\N	g	2025-10-29	\N	\N	MENY_20251029.json	154	488	
483	40.00	\N	kg	2025-10-29	\N	\N	MENY_20251029.json	154	489	
484	\N	\N	g	2025-10-29	\N	\N	MENY_20251029.json	154	490	
486	149.00	\N		2025-10-29	\N	\N	MENY_20251029.json	154	491	
488	79.00	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	492	
489	39.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	493	
138	39.90	\N	kg	2025-10-29	39.90	kr/kg	rema_1000_20251020.json	166	169	
491	24.90	\N	kg	2025-10-29	\N	\N	REMA_1000_20251029.json	166	447	
492	79.90	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	494	
493	24.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	495	
494	23.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	496	
495	44.90	\N		2025-10-29	\N	\N	REMA_1000_20251029.json	166	497	
496	39.90	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	498	
498	11.98	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	500	
500	23.90	\N	l	2025-10-29	\N	\N	REMA_1000_20251029.json	166	501	
497	20.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	499	
502	49.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	502	
503	24.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	503	
504	\N	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	504	
505	\N	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	505	
506	99.00	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	142	
508	99.00	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	506	
509	29.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	507	
510	29.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	508	
512	79.00	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	510	
513	54.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	511	
514	39.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	512	
515	19.90	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	513	
516	24.90	\N		2025-10-29	\N	\N	REMA_1000_20251029.json	166	514	
517	29.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	515	
522	39.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	519	
523	39.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	520	
524	49.90	\N	l	2025-10-29	\N	\N	REMA_1000_20251029.json	166	521	
525	19.90	\N	kg	2025-10-29	\N	\N	REMA_1000_20251029.json	166	467	
527	169.00	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	522	
528	169.90	\N	l	2025-10-29	\N	\N	REMA_1000_20251029.json	166	161	
529	19.90	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	523	
530	19.90	\N	kg	2025-10-29	\N	\N	REMA_1000_20251029.json	166	12	
531	129.90	\N	kg	2025-10-29	\N	\N	REMA_1000_20251029.json	166	524	
532	289.90	\N	kg	2025-10-29	\N	\N	REMA_1000_20251029.json	166	525	
519	39.90	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	516	
520	39.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	517	
521	39.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	518	
526	13.45	\N	kg	2025-10-29	\N	\N	REMA_1000_20251029.json	166	323	
533	24.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	477	
534	59.90	\N	l	2025-10-29	\N	\N	REMA_1000_20251029.json	166	526	
535	24.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	527	
536	24.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	528	
537	14.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	529	
538	12.60	\N	l	2025-10-29	\N	\N	REMA_1000_20251029.json	166	530	
539	12.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	531	
540	26.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	532	
541	\N	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	533	
542	24.90	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	534	
543	27.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	535	
544	39.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	536	
545	14.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	537	
546	79.00	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	538	
547	23.90	\N	l	2025-10-29	\N	\N	REMA_1000_20251029.json	166	539	
548	79.00	\N	kg	2025-10-29	\N	\N	REMA_1000_20251029.json	166	540	
551	54.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	541	
552	49.90	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	542	
553	29.90	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	543	
557	39.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	544	
558	19.90	\N	kg	2025-10-29	\N	\N	REMA_1000_20251029.json	166	545	
559	34.90	\N	stk	2025-10-29	\N	\N	REMA_1000_20251029.json	166	546	
560	39.90	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	547	
562	79.00	\N	g	2025-10-29	\N	\N	REMA_1000_20251029.json	166	548	
564	11.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	325	
567	\N	\N	stk	2025-10-29	\N	\N	SPAR_20251029.json	246	552	
568	\N	\N	stk	2025-10-29	\N	\N	SPAR_20251029.json	246	553	
569	39.90	\N	stk	2025-10-29	\N	\N	SPAR_20251029.json	246	554	
570	36.90	\N	kg	2025-10-29	\N	\N	SPAR_20251029.json	246	555	
571	29.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	16	
572	34.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	556	
573	59.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	487	
574	59.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	557	
575	\N	\N	l	2025-10-29	\N	\N	SPAR_20251029.json	246	558	
576	69.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	559	
577	79.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	83	
578	79.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	560	
580	44.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	561	
581	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	562	
582	29.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	563	
583	29.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	564	
584	30.00	\N		2025-10-29	\N	\N	SPAR_20251029.json	246	565	
585	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	566	
586	39.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	567	
587	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	568	
588	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	569	
589	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	570	
590	34.90	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	571	
591	14.90	\N	l	2025-10-29	\N	\N	SPAR_20251029.json	246	572	
592	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	573	
593	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	574	
594	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	575	
595	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	576	
596	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	577	
597	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	578	
598	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	579	
599	79.90	\N		2025-10-29	\N	\N	SPAR_20251029.json	246	580	
600	69.90	\N	stk	2025-10-29	\N	\N	SPAR_20251029.json	246	581	
566	\N	\N		2025-10-29	\N	\N	SPAR_20251029.json	246	551	
563	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	549	
603	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	582	
565	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	550	
605	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	583	
606	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	584	
607	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	585	
608	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	586	
609	\N	\N	g	2025-10-29	\N	\N	SPAR_20251029.json	246	587	
\.


--
-- TOC entry 5004 (class 0 OID 16457)
-- Dependencies: 222
-- Data for Name: produkter_historikk; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produkter_historikk (id, butikk, kategori, produkt, pris, mengde, enhet, pris_per_enhet, pris_per_enhet_enhet, kilde_fil, gyldig_fra, opprettet, gyldig_til, butikk_id, produkt_id) FROM stdin;
\.


--
-- TOC entry 5002 (class 0 OID 16447)
-- Dependencies: 220
-- Data for Name: produkter_rejects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produkter_rejects (id, reason, kilde_fil, payload, created_at) FROM stdin;
1	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "4 x 100g", "produkt": "Baconburger", "kategori": "Kjøtt"}	2025-10-21 00:24:01.503312+02
2	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "380g", "produkt": "Kyllingfilet naturell", "kategori": "Kjøtt"}	2025-10-21 00:24:01.51047+02
3	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "500g", "produkt": "Pasta linguine", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.537229+02
4	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "1kg", "produkt": "Gulrot i pose", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.537831+02
5	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "250g", "produkt": "Fiskepinner", "kategori": "Fisk"}	2025-10-21 00:24:01.538458+02
6	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "60g", "produkt": "Freia Melkesjokolade, Firkløver og Melkesjokolade Kvikk Lunsj", "kategori": "Meieri"}	2025-10-21 00:24:01.539003+02
7	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "370g", "produkt": "Risgrøt", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.539546+02
8	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "", "produkt": "All frukt", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.540269+02
9	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "800g", "produkt": "Havrebrød", "kategori": "Brød"}	2025-10-21 00:24:01.540751+02
10	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Go' Morgen Yoghurt og Rislunsj", "kategori": "Meieri"}	2025-10-21 00:24:01.541236+02
11	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "90g", "produkt": "Poppa Nøisør", "kategori": "Snacks"}	2025-10-21 00:24:01.541669+02
12	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "80g", "produkt": "Mills Ovnsbakt Leverpostei", "kategori": "Meieri"}	2025-10-21 00:24:01.542132+02
13	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "37g", "produkt": "Wasa Sandwich", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.542642+02
14	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "130g", "produkt": "Friggs Maiskaker", "kategori": "Snacks"}	2025-10-21 00:24:01.543177+02
15	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "90g", "produkt": "Muffin Double Chocolate", "kategori": "Drikke"}	2025-10-21 00:24:01.543666+02
16	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "400g", "produkt": "Soft Flora Original", "kategori": "Husholdning"}	2025-10-21 00:24:01.544117+02
17	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "165g", "produkt": "Mills Majones Ekte og Lett", "kategori": "Husholdning"}	2025-10-21 00:24:01.544559+02
18	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "1l", "produkt": "Tine Skummetmelk", "kategori": "Meieri"}	2025-10-21 00:24:01.544994+02
19	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "125g", "produkt": "Tine Kremgo' Pepper", "kategori": "Meieri"}	2025-10-21 00:24:01.545452+02
20	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Ritz Kex", "kategori": "Snacks"}	2025-10-21 00:24:01.545899+02
21	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Skyr Luftig Bringebær", "kategori": "Meieri"}	2025-10-21 00:24:01.546331+02
22	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "50g", "produkt": "Bixit Mini Dobbel Vanilje", "kategori": "Snacks"}	2025-10-21 00:24:01.546889+02
23	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "250ml", "produkt": "Froosh Smoothie Mango & Appelsin", "kategori": "Drikke"}	2025-10-21 00:24:01.547795+02
24	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "500g", "produkt": "Osteloaf", "kategori": "Meieri"}	2025-10-21 00:24:01.548105+02
25	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "375g", "produkt": "Frokostblanding", "kategori": "Meieri"}	2025-10-21 00:24:01.548411+02
26	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "185g", "produkt": "Prior Kyllingpostei", "kategori": "Meieri"}	2025-10-21 00:24:01.54871+02
27	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Ritz Kjeks Original", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.549022+02
28	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "600g", "produkt": "Axa 4-korn", "kategori": "Frokost"}	2025-10-21 00:24:01.549322+02
29	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Gilde Leverpostei", "kategori": "Meieri"}	2025-10-21 00:24:01.549621+02
30	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1stk", "produkt": "Brød", "kategori": "Brød"}	2025-10-21 00:24:01.55369+02
31	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1stk", "produkt": "Polarbrød", "kategori": "Brød"}	2025-10-21 00:24:01.553981+02
32	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1stk", "produkt": "Potetgull", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.554265+02
33	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1stk", "produkt": "Mills majones", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.554554+02
34	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "1stk", "produkt": "Mais", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.555305+02
35	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Apetina hvitløks- & grønne oliven og soltørket tomat", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.55561+02
36	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Tyrkisk olivenolje, pepper, safran i olje og tomat", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.556545+02
37	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "220ml", "produkt": "Starbucks skinny latte, cappuccino caramel macchiato", "kategori": "Drikke"}	2025-10-21 00:24:01.556875+02
38	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "165g", "produkt": "Mills remulade", "kategori": "Husholdning"}	2025-10-21 00:24:01.557209+02
39	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "250g", "produkt": "Mascarpone ost og chia & havsalt", "kategori": "Meieri"}	2025-10-21 00:24:01.557537+02
40	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "160g", "produkt": "Gresk yoghurt vanilje & granola og duo pekan & honning", "kategori": "Meieri"}	2025-10-21 00:24:01.557859+02
41	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "4x125g", "produkt": "Yoplait double 0% mango, vanilje og fersken/pasjonsfrukt", "kategori": "Meieri"}	2025-10-21 00:24:01.558178+02
42	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "1l", "produkt": "Alle synnøve biola", "kategori": "Brød"}	2025-10-21 00:24:01.55918+02
43	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Balleringa og safari original", "kategori": "Snacks"}	2025-10-21 00:24:01.55954+02
44	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Utvalgte prior-pålegg", "kategori": "Frokost"}	2025-10-21 00:24:01.559871+02
45	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Utvalgte wasa knekkebrød", "kategori": "Brød"}	2025-10-21 00:24:01.560287+02
46	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Grilstad gullsalami dansk", "kategori": "Kjøtt"}	2025-10-21 00:24:01.560652+02
47	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Tulip skivet salami dansk", "kategori": "Kjøtt"}	2025-10-21 00:24:01.561071+02
48	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Philadelphia original, light og laktosefri", "kategori": "Meieri"}	2025-10-21 00:24:01.561517+02
49	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "125g", "produkt": "Mozzarella oster", "kategori": "Meieri"}	2025-10-21 00:24:01.561973+02
50	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "175g", "produkt": "Kavli magerost skinke, jalapeno og chili & pepper & hvitløk", "kategori": "Meieri"}	2025-10-21 00:24:01.562332+02
51	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "500g", "produkt": "Gilde hamburgerkjøtt og sommerkoteletter", "kategori": "Kjøtt"}	2025-10-21 00:24:01.562685+02
52	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Cookies", "kategori": "Snacks"}	2025-10-21 00:24:01.563028+02
53	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "260g", "produkt": "Gifflar kanel", "kategori": "Snacks"}	2025-10-21 00:24:01.563381+02
54	invalid_price	bunnpris_20251020.json	{"pris": "-50%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Jæren skinke og norvegia skivet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.563724+02
55	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "1l", "produkt": "Havredrikk 1,5% fett, rapsolje og vaniljesmak", "kategori": "Drikke"}	2025-10-21 00:24:01.564065+02
56	invalid_price	bunnpris_20251020.json	{"pris": "-35%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Eldorado spekeskinke", "kategori": "Kjøtt"}	2025-10-21 00:24:01.564403+02
57	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Castello hvit, chili og guldbjørn", "kategori": "Meieri"}	2025-10-21 00:24:01.564744+02
58	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "750g", "produkt": "Havrebrød", "kategori": "Brød"}	2025-10-21 00:24:01.565153+02
59	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "360g", "produkt": "Kyllingfilet naturell", "kategori": "Kjøtt"}	2025-10-21 00:24:01.565565+02
60	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "0.4l", "produkt": "Fuze Tea Peach Hibiscus", "kategori": "Drikke"}	2025-10-21 00:24:01.57032+02
61	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "94g", "produkt": "Hoff Potetmos Gressløk/Melk", "kategori": "Meieri"}	2025-10-21 00:24:01.570673+02
62	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "65g", "produkt": "Mr. Lee Nudler Kylling", "kategori": "Kjøtt"}	2025-10-21 00:24:01.571025+02
63	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "Flere varianter", "produkt": "Utvalgte Toro Posesupper (Rett i koppen)", "kategori": "Ferdigmat"}	2025-10-21 00:24:01.571394+02
64	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "6pk", "produkt": "Kylling-, Fisk- og Grønnsaksbuljong", "kategori": "Kjøtt"}	2025-10-21 00:24:01.571689+02
65	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "58g", "produkt": "Pasta Snack Pot Bolognese, Carbonara og Bacon", "kategori": "Kjøtt"}	2025-10-21 00:24:01.572009+02
66	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Prior Kyllingbacon", "kategori": "Kjøtt"}	2025-10-21 00:24:01.572333+02
67	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "Flere varianter", "produkt": "Utvalgte Toro Posesauser", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.572651+02
68	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "4pk", "produkt": "Bearnaisesaus", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.572971+02
69	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "5pk", "produkt": "Nongshim Nudler", "kategori": "Ferdigmat"}	2025-10-21 00:24:01.573283+02
70	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "350g", "produkt": "Rømmegrøt og Pjoltergrøt", "kategori": "Meieri"}	2025-10-21 00:24:01.573598+02
71	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "250ml", "produkt": "Xerabassu Mild og Sterk", "kategori": "Hygiene"}	2025-10-21 00:24:01.57392+02
72	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "185g", "produkt": "Nachips Chunky", "kategori": "Snacks"}	2025-10-21 00:24:01.57423+02
73	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "320g", "produkt": "Tortillas Original", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.574545+02
74	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Mozzarella Ostemix Norvegia og Gløgg Cheddar Rev", "kategori": "Meieri"}	2025-10-21 00:24:01.575381+02
75	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "500g", "produkt": "Kjøttboller/Fiskeboller", "kategori": "Kjøtt"}	2025-10-21 00:24:01.575752+02
76	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "1l", "produkt": "Eldorado Raps- og Solsikkeolje", "kategori": "Husholdning"}	2025-10-21 00:24:01.576059+02
77	invalid_price	bunnpris_20251020.json	{"pris": "-35%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Maksikon Extra Crispy", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.576447+02
78	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Bacon Terninger", "kategori": "Kjøtt"}	2025-10-21 00:24:01.576871+02
79	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "500g", "produkt": "Kyllingfilet Store Stykker", "kategori": "Kjøtt"}	2025-10-21 00:24:01.577224+02
80	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "500g", "produkt": "Gilde Pølsekniv", "kategori": "Drikke"}	2025-10-21 00:24:01.577511+02
81	invalid_price	bunnpris_20251020.json	{"pris": "-50%", "butikk": "Bunnpris", "mengde": "500g", "produkt": "Kebab i Klassisk", "kategori": "Kjøtt"}	2025-10-21 00:24:01.57789+02
82	invalid_price	bunnpris_20251020.json	{"pris": "-50%", "butikk": "Bunnpris", "mengde": "2pk", "produkt": "Baconburger", "kategori": "Kjøtt"}	2025-10-21 00:24:01.578205+02
83	invalid_price	bunnpris_20251020.json	{"pris": "-50%", "butikk": "Bunnpris", "mengde": "2pk", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.578519+02
84	invalid_price	bunnpris_20251020.json	{"pris": "-90%", "butikk": "Bunnpris", "mengde": "500g", "produkt": "Pulled Pork og Pork Taco", "kategori": "Kjøtt"}	2025-10-21 00:24:01.578827+02
85	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "250g", "produkt": "Melange Margarin", "kategori": "Meieri"}	2025-10-21 00:24:01.579137+02
86	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "390g", "produkt": "Eldorado Hakkede Tomater", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.579464+02
87	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Fish & Crisp", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.579774+02
88	invalid_price	bunnpris_20251020.json	{"pris": "-35%", "butikk": "Bunnpris", "mengde": "2.5kg", "produkt": "Poteter hvite og røde", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.580087+02
89	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "1 pakke", "produkt": "Libresse intimservietter", "kategori": "Hygiene"}	2025-10-21 00:24:01.580405+02
90	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1 pakke", "produkt": "Bomullspads", "kategori": "Hygiene"}	2025-10-21 00:24:01.580715+02
91	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Utvalgte Lano såpe, produkter og lipsyl", "kategori": "Hygiene"}	2025-10-21 00:24:01.581023+02
92	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Dove roll-on", "kategori": "Hygiene"}	2025-10-21 00:24:01.581333+02
93	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Nivea roll-on men", "kategori": "Hygiene"}	2025-10-21 00:24:01.581647+02
94	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1 pakke", "produkt": "Salvequick plaster", "kategori": "Hygiene"}	2025-10-21 00:24:01.581958+02
95	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "1 pakke", "produkt": "Truseinnlegg 50 slim og normal", "kategori": "Hygiene"}	2025-10-21 00:24:01.582268+02
96	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Asan trippel dusj mild", "kategori": "Hygiene"}	2025-10-21 00:24:01.582595+02
97	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "WC blått", "kategori": "Husholdning"}	2025-10-21 00:24:01.582932+02
98	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Comfort tøymykner", "kategori": "Husholdning"}	2025-10-21 00:24:01.583286+02
99	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Antibac håndkrem og Nivea roll-on", "kategori": "Hygiene"}	2025-10-21 00:24:01.583613+02
100	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Asan intimvask tranebær", "kategori": "Husholdning"}	2025-10-21 00:24:01.583912+02
101	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Nivea cream body/face", "kategori": "Hygiene"}	2025-10-21 00:24:01.584218+02
102	invalid_price	bunnpris_20251020.json	{"pris": "-50%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Axe bodyspray", "kategori": "Hygiene"}	2025-10-21 00:24:01.584519+02
103	invalid_price	bunnpris_20251020.json	{"pris": "-60%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Flux fluorskyll", "kategori": "Hygiene"}	2025-10-21 00:24:01.58514+02
104	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "1 pose", "produkt": "Sørlandschips", "kategori": "Snacks"}	2025-10-21 00:24:01.585552+02
105	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Snøfrisk", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.586646+02
106	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "1 pakke", "produkt": "Fiskefilet", "kategori": "Fisk"}	2025-10-21 00:24:01.587027+02
107	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "1 flaske", "produkt": "Sura fresh 1,5l", "kategori": "Drikke"}	2025-10-21 00:24:01.587399+02
108	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "20 poser", "produkt": "Lipton Te", "kategori": "Annet"}	2025-10-21 00:24:01.587775+02
109	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "1 stk", "produkt": "Alle Plunlight", "kategori": "Husholdning"}	2025-10-21 00:24:01.58852+02
110	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "0.5l", "produkt": "Mer Pære, Appelsin og Jordbær & Eple", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.588844+02
111	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "0.5l", "produkt": "Boble Vann", "kategori": "Drikke"}	2025-10-21 00:24:01.589158+02
112	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "138g pr pk", "produkt": "Eldorado Mellombar", "kategori": "Snacks"}	2025-10-21 00:24:01.59198+02
113	insert_error:42703	bunnpris_20251020.json	{"pris": "20 + pant", "butikk": "Bunnpris", "mengde": "0.8-1l", "produkt": "Et stort utvalg Fun Light", "kategori": "Drikke"}	2025-10-21 00:24:01.598368+02
114	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "60-70g", "produkt": "Freia Melkesjokolade, Fruktnøtt og Melkesjokolade Kvikk Lunsj", "kategori": "Meieri"}	2025-10-21 00:24:01.598721+02
115	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "900g", "produkt": "Risgrøt", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.599722+02
116	invalid_price	bunnpris_20251020.json	{"pris": "30%", "butikk": "Bunnpris", "mengde": "", "produkt": "Ukens nystekte brød", "kategori": "Brød"}	2025-10-21 00:24:01.600039+02
117	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "35g", "produkt": "Poppa Müsli Bar", "kategori": "Snacks"}	2025-10-21 00:24:01.600376+02
118	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Mills Ovnsbakt Salat", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.600668+02
119	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Wasabrød", "kategori": "Brød"}	2025-10-21 00:24:01.600976+02
120	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Muffin Double Chocolate", "kategori": "Drikke"}	2025-10-21 00:24:01.601292+02
121	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "400g", "produkt": "Soft Flora Original og Lett", "kategori": "Husholdning"}	2025-10-21 00:24:01.601633+02
122	invalid_price	bunnpris_20251020.json	{"pris": "-10%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Tine Sukkerfri", "kategori": "Snacks"}	2025-10-21 00:24:01.601933+02
123	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "125g", "produkt": "Tine Kremgo Pepper", "kategori": "Meieri"}	2025-10-21 00:24:01.602241+02
124	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Bi-Fi Nøtter", "kategori": "Snacks"}	2025-10-21 00:24:01.602552+02
125	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Osteloop", "kategori": "Meieri"}	2025-10-21 00:24:01.602861+02
126	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Skyr Luftig", "kategori": "Meieri"}	2025-10-21 00:24:01.603165+02
127	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "250g", "produkt": "Findus Fiskepinner", "kategori": "Fisk"}	2025-10-21 00:24:01.603503+02
128	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Bixit Mini Dobbel Vanilje", "kategori": "Meieri"}	2025-10-21 00:24:01.60381+02
129	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "250ml", "produkt": "Froosh Smoothie", "kategori": "Snacks"}	2025-10-21 00:24:01.604116+02
130	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "110g", "produkt": "Makrell i Tomat", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.604422+02
131	invalid_price	bunnpris_20251020.json	{"pris": "-15%", "butikk": "Bunnpris", "mengde": "400g", "produkt": "Utvannet Klippfisk", "kategori": "Drikke"}	2025-10-21 00:24:01.604729+02
132	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Bruschetta", "kategori": "Snacks"}	2025-10-21 00:24:01.605037+02
133	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "TUC Kiks Salt og Paprika", "kategori": "Snacks"}	2025-10-21 00:24:01.605346+02
134	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Tulip Egro Leverpostei", "kategori": "Meieri"}	2025-10-21 00:24:01.605653+02
135	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "330g", "produkt": "Prior kyllingpølse", "kategori": "Drikke"}	2025-10-21 00:24:01.605959+02
136	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Gilde leverpostei", "kategori": "Meieri"}	2025-10-21 00:24:01.606268+02
137	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Ovnsbakt original", "kategori": "Kjøtt"}	2025-10-21 00:24:01.606577+02
138	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Fårepølse salami og skivet", "kategori": "Drikke"}	2025-10-21 00:24:01.606876+02
139	insert_error:42703	bunnpris_20251020.json	{"pris": "10 + pant", "butikk": "Bunnpris", "mengde": "0.5l", "produkt": "CULT energidrikk", "kategori": "Drikke"}	2025-10-21 00:24:01.611969+02
140	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Apetina hvitost & grønne oliven og soltørket tomat", "kategori": "Meieri"}	2025-10-21 00:24:01.612295+02
141	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "3x80g", "produkt": "Tunfisk olivenolje/pepper, stangekylling i olje og tomat", "kategori": "Kjøtt"}	2025-10-21 00:24:01.6126+02
142	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "220ml", "produkt": "Starbucks Skinny Latte, Cappuccino og Caramel Macchiato", "kategori": "Drikke"}	2025-10-21 00:24:01.61289+02
143	invalid_price	bunnpris_20251020.json	{"pris": "-20%", "butikk": "Bunnpris", "mengde": "165g", "produkt": "Mills majones", "kategori": "Husholdning"}	2025-10-21 00:24:01.61318+02
144	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Mascarpone ost og chia & havsalt", "kategori": "Meieri"}	2025-10-21 00:24:01.613516+02
145	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Gresk yoghurt vanilje & granola og duo pekan & honning", "kategori": "Meieri"}	2025-10-21 00:24:01.613857+02
146	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "4x125g", "produkt": "Yoplait double 0% mango, vanilje og fersken/pasjon", "kategori": "Drikke"}	2025-10-21 00:24:01.614214+02
147	invalid_price	bunnpris_20251020.json	{"pris": "-25%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Tyrkisk Peber & Chili", "kategori": "Snacks"}	2025-10-21 00:24:01.614566+02
148	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Alle synnøt kjeks", "kategori": "Snacks"}	2025-10-21 00:24:01.614925+02
149	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "190g", "produkt": "Ballerina og Safari original", "kategori": "Snacks"}	2025-10-21 00:24:01.615273+02
150	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Grilstad Gullsalami", "kategori": "Kjøtt"}	2025-10-21 00:24:01.615604+02
151	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Tulip skivet salami dansk", "kategori": "Kjøtt"}	2025-10-21 00:24:01.615931+02
152	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Philadelphia original, light og light m/urter", "kategori": "Meieri"}	2025-10-21 00:24:01.616273+02
153	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "120g", "produkt": "Mozzarella ostestringer", "kategori": "Meieri"}	2025-10-21 00:24:01.616608+02
154	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Kyllingpålegg skinke, jalapeno og chili & pepper m/hvitløk", "kategori": "Kjøtt"}	2025-10-21 00:24:01.616937+02
155	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Gilde hamburgerrygg og sommerpølse skåret", "kategori": "Drikke"}	2025-10-21 00:24:01.617266+02
156	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Siflar kanel", "kategori": "Snacks"}	2025-10-21 00:24:01.617649+02
157	invalid_price	bunnpris_20251020.json	{"pris": "-50%", "butikk": "Bunnpris", "mengde": "300g", "produkt": "Jærs serie og norvegia skiver", "kategori": "Kjøtt"}	2025-10-21 00:24:01.618009+02
158	invalid_price	bunnpris_20251020.json	{"pris": "-35%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Havregrøt 15% fett, rabarbra og vaniljesmak", "kategori": "Frokost"}	2025-10-21 00:24:01.618363+02
159	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "100g", "produkt": "Gilde spekeskinke", "kategori": "Kjøtt"}	2025-10-21 00:24:01.618717+02
160	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "150g", "produkt": "Castello hvit, chili og gulbrie", "kategori": "Meieri"}	2025-10-21 00:24:01.619096+02
161	invalid_price	bunnpris_20251020.json	{"pris": "-30%", "butikk": "Bunnpris", "mengde": "200g", "produkt": "Havregrøt", "kategori": "Frokost"}	2025-10-21 00:24:01.619423+02
162	invalid_price	bunnpris_20251020.json	{"pris": "-40%", "butikk": "Bunnpris", "mengde": "600g", "produkt": "Kyllingfilet naturell", "kategori": "Kjøtt"}	2025-10-21 00:24:01.619758+02
163	invalid_price	coop_extra_20251020.json	{"pris": "-40%", "butikk": "Coop_Extra", "mengde": "400g", "produkt": "Rørvik fiskeboller", "kategori": "Fisk"}	2025-10-21 00:24:01.620717+02
164	invalid_price	coop_extra_20251020.json	{"pris": "-30%", "butikk": "Coop_Extra", "mengde": "", "produkt": "Alle TORO supper/sauser/gryter", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.621109+02
165	invalid_price	coop_extra_20251020.json	{"pris": "-80%", "butikk": "Coop_Extra", "mengde": "800g", "produkt": "Gilde kjøttkaker", "kategori": "Kjøtt"}	2025-10-21 00:24:01.624733+02
166	invalid_price	coop_extra_20251020.json	{"pris": "-40%", "butikk": "Coop_Extra", "mengde": "370g", "produkt": "Coop tyttebærsyltetøy 60%", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.625027+02
167	invalid_price	coop_extra_20251020.json	{"pris": "-40%", "butikk": "Coop_Extra", "mengde": "520g", "produkt": "Mors hjemmebakte flatbrød", "kategori": "Brød"}	2025-10-21 00:24:01.625314+02
168	invalid_price	coop_extra_20251020.json	{"pris": "-19%", "butikk": "Coop_Extra", "mengde": "1kg", "produkt": "Norske poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.625601+02
169	invalid_price	coop_extra_20251020.json	{"pris": "-35%", "butikk": "Coop_Extra", "mengde": "450g", "produkt": "Gilde kjøttpølse", "kategori": "Drikke"}	2025-10-21 00:24:01.633837+02
170	invalid_price	coop_extra_20251020.json	{"pris": "-20%", "butikk": "Coop_Extra", "mengde": "90g", "produkt": "Coop bacon uten svor", "kategori": "Kjøtt"}	2025-10-21 00:24:01.634144+02
171	invalid_price	coop_extra_20251020.json	{"pris": "-40%", "butikk": "Coop_Extra", "mengde": "Pr pk", "produkt": "Rørvik fiskeboller", "kategori": "Fisk"}	2025-10-21 00:24:01.634448+02
172	invalid_price	coop_extra_20251020.json	{"pris": "-15%", "butikk": "Coop_Extra", "mengde": "11 varianter", "produkt": "Anglamark krydderurter", "kategori": "Annet"}	2025-10-21 00:24:01.63477+02
173	invalid_price	coop_extra_20251020.json	{"pris": "-19%", "butikk": "Coop_Extra", "mengde": "Pr kg", "produkt": "Norske poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.635108+02
174	insert_error:42703	coop_extra_20251020.json	{"pris": "19.00", "butikk": "Coop_Extra", "mengde": "per kg", "produkt": "Norske poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.637406+02
175	insert_error:42703	coop_extra_20251020.json	{"pris": "25.00", "butikk": "Coop_Extra", "mengde": "per kg", "produkt": "Norske epler", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.641951+02
176	invalid_price	coop_extra_20251020.json	{"pris": "1% til rosa sløyfe", "butikk": "Coop_Extra", "mengde": "", "produkt": "Frukt & grønt", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.648768+02
177	invalid_price	coop_extra_20251020.json	{"pris": "-25%", "butikk": "Coop_Extra", "mengde": "", "produkt": "Dr. Greve", "kategori": "Hygiene"}	2025-10-21 00:24:01.671583+02
178	invalid_price	coop_extra_20251020.json	{"pris": "-25%", "butikk": "Coop_Extra", "mengde": "", "produkt": "Define hårpleie", "kategori": "Hygiene"}	2025-10-21 00:24:01.671928+02
179	invalid_price	coop_extra_20251020.json	{"pris": "-25%", "butikk": "Coop_Extra", "mengde": "", "produkt": "OMO tøyvask", "kategori": "Husholdning"}	2025-10-21 00:24:01.672268+02
180	invalid_price	coop_extra_20251020.json	{"pris": "-25%", "butikk": "Coop_Extra", "mengde": "", "produkt": "Jif rengjøring", "kategori": "Husholdning"}	2025-10-21 00:24:01.67261+02
181	invalid_price	coop_extra_20251020.json	{"pris": "-40%", "butikk": "Coop_Extra", "mengde": "", "produkt": "Matoppbevaring", "kategori": "Husholdning"}	2025-10-21 00:24:01.672977+02
182	invalid_price	coop_extra_20251020.json	{"pris": "-40%", "butikk": "Coop_Extra", "mengde": "", "produkt": "Glassflasker og krukker", "kategori": "Husholdning"}	2025-10-21 00:24:01.673313+02
183	insert_error:42703	coop_extra_20251020.json	{"pris": "129.00", "butikk": "Coop_Extra", "mengde": "AA / E91 12 pk", "produkt": "Energizer Max Plus", "kategori": "Annet"}	2025-10-21 00:24:01.68017+02
184	insert_error:42703	coop_extra_20251020.json	{"pris": "229.00", "butikk": "Coop_Extra", "mengde": "180 x 200 cm", "produkt": "Myk Jerseylaken", "kategori": "Annet"}	2025-10-21 00:24:01.683613+02
185	insert_error:42703	coop_extra_20251020.json	{"pris": "3 for 110", "butikk": "Coop_Extra", "mengde": "150-200g", "produkt": "Alle storplater fra Freia og Nidar", "kategori": "Snacks"}	2025-10-21 00:24:01.708264+02
186	invalid_price	coop_extra_20251020.json	{"pris": "-40%", "butikk": "Coop_Extra", "mengde": "320g", "produkt": "Mors hjemmebakte flatbrød", "kategori": "Brød"}	2025-10-21 00:24:01.708586+02
187	invalid_price	coop_extra_20251020.json	{"pris": "-45%", "butikk": "Coop_Extra", "mengde": "450g", "produkt": "Coop Mormors fiskekaker", "kategori": "Fisk"}	2025-10-21 00:24:01.708902+02
188	invalid_price	coop_extra_20251020.json	{"pris": "-25%", "butikk": "Coop_Extra", "mengde": "kg", "produkt": "Norske epler", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.709212+02
189	invalid_price	coop_extra_20251020.json	{"pris": "-40%", "butikk": "Coop_Extra", "mengde": "500g", "produkt": "Mors hjemmebakte flatbrød", "kategori": "Brød"}	2025-10-21 00:24:01.709612+02
190	invalid_price	coop_extra_20251020.json	{"pris": "-19%", "butikk": "Coop_Extra", "mengde": "kg", "produkt": "Norske poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.709975+02
191	invalid_price	coop_extra_20251020.json	{"pris": "-35%", "butikk": "Coop_Extra", "mengde": "pk", "produkt": "Gilde kjøttpølse", "kategori": "Drikke"}	2025-10-21 00:24:01.710289+02
192	invalid_price	coop_extra_20251020.json	{"pris": "-20%", "butikk": "Coop_Extra", "mengde": "150g", "produkt": "Coop bacon uten svor", "kategori": "Kjøtt"}	2025-10-21 00:24:01.710598+02
193	invalid_price	coop_extra_20251020.json	{"pris": "-15%", "butikk": "Coop_Extra", "mengde": "11g", "produkt": "Änglamark krydderurter", "kategori": "Ferdigmat"}	2025-10-21 00:24:01.710912+02
194	insert_error:42703	coop_extra_20251020.json	{"pris": "15.00", "butikk": "Coop_Extra", "mengde": "Pr stk", "produkt": "Änglamark krydderurter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.714322+02
195	insert_error:42703	coop_extra_20251020.json	{"pris": "10.00", "butikk": "Coop_Extra", "mengde": "Pr stk", "produkt": "Ingefær", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.721548+02
196	insert_error:42703	coop_extra_20251020.json	{"pris": "49.90", "butikk": "Coop_Extra", "mengde": "1.2kg", "produkt": "Hoff Opphøgde Poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.723802+02
197	insert_error:42703	coop_extra_20251020.json	{"pris": "89.90", "butikk": "Coop_Extra", "mengde": "600g", "produkt": "Lofoten Fiskeburger", "kategori": "Fisk"}	2025-10-21 00:24:01.725967+02
198	insert_error:42703	coop_extra_20251020.json	{"pris": "33.60", "butikk": "Coop_Extra", "mengde": "150g", "produkt": "Coop Burgerost Cheddar", "kategori": "Meieri"}	2025-10-21 00:24:01.7281+02
199	insert_error:42703	coop_extra_20251020.json	{"pris": "30.00", "butikk": "Coop_Extra", "mengde": "6stk", "produkt": "Coop Prime Time Burgerbrød", "kategori": "Brød"}	2025-10-21 00:24:01.730132+02
200	invalid_price	coop_prix_20251020.json	{"pris": "-30%", "butikk": "Coop_Prix", "mengde": "6 stk", "produkt": "Fried Chicken", "kategori": "Annet"}	2025-10-21 00:24:01.73678+02
201	invalid_price	coop_prix_20251020.json	{"pris": "-25%", "butikk": "Coop_Prix", "mengde": "100g", "produkt": "Stranda spekemat", "kategori": "Kjøtt"}	2025-10-21 00:24:01.737133+02
202	invalid_price	coop_prix_20251020.json	{"pris": "-25%", "butikk": "Coop_Prix", "mengde": "200g", "produkt": "Stranda spekemat", "kategori": "Kjøtt"}	2025-10-21 00:24:01.73742+02
203	invalid_price	coop_prix_20251020.json	{"pris": "14%", "butikk": "Coop_Prix", "mengde": "400g", "produkt": "Kjøttdeig", "kategori": "Kjøtt"}	2025-10-21 00:24:01.743703+02
204	invalid_price	coop_prix_20251020.json	{"pris": "25%", "butikk": "Coop_Prix", "mengde": "1l", "produkt": "OMØ", "kategori": "Hygiene"}	2025-10-21 00:24:01.753561+02
205	invalid_price	coop_prix_20251020.json	{"pris": "25%", "butikk": "Coop_Prix", "mengde": "1l", "produkt": "Lano", "kategori": "Hygiene"}	2025-10-21 00:24:01.754155+02
206	invalid_price	coop_prix_20251020.json	{"pris": "25%", "butikk": "Coop_Prix", "mengde": "500ml", "produkt": "Lano", "kategori": "Hygiene"}	2025-10-21 00:24:01.754614+02
207	invalid_price	coop_prix_20251020.json	{"pris": "25%", "butikk": "Coop_Prix", "mengde": "250ml", "produkt": "Lano", "kategori": "Hygiene"}	2025-10-21 00:24:01.755165+02
208	invalid_price	coop_prix_20251020.json	{"pris": "25%", "butikk": "Coop_Prix", "mengde": "100ml", "produkt": "Lano", "kategori": "Hygiene"}	2025-10-21 00:24:01.755489+02
209	invalid_price	coop_prix_20251020.json	{"pris": "-50%", "butikk": "Coop_Prix", "mengde": "1 pakke", "produkt": "Bleier", "kategori": "Hygiene"}	2025-10-21 00:24:01.759601+02
210	invalid_price	coop_prix_20251020.json	{"pris": "pakkepris", "butikk": "Coop_Prix", "mengde": "1l + 1 stk", "produkt": "Pakkepris på 1l melk & 1 grovbrød", "kategori": "Meieri"}	2025-10-21 00:24:01.76042+02
211	invalid_price	coop_prix_20251020.json	{"pris": "-50%", "butikk": "Coop_Prix", "mengde": "1 stk", "produkt": "Grovt brød fra Coop", "kategori": "Brød"}	2025-10-21 00:24:01.760717+02
212	invalid_price	coop_prix_20251020.json	{"pris": "-50%", "butikk": "Coop_Prix", "mengde": "1 l", "produkt": "1 liter melk fra Tine", "kategori": "Meieri"}	2025-10-21 00:24:01.761001+02
213	invalid_price	kiwi_20251020.json	{"pris": "-20%", "butikk": "KIWI", "mengde": "", "produkt": "Stort utvalg kylling", "kategori": "Kjøtt"}	2025-10-21 00:24:01.766701+02
214	invalid_price	kiwi_20251020.json	{"pris": "15%", "butikk": "KIWI", "mengde": "", "produkt": "Bonus på fersk frukt og grønt", "kategori": "Annet"}	2025-10-21 00:24:01.770228+02
215	insert_error:42703	kiwi_20251020.json	{"pris": "29.90", "butikk": "KIWI", "mengde": "200g", "produkt": "Brokkolini", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.776375+02
216	insert_error:42703	kiwi_20251020.json	{"pris": "144.70", "butikk": "KIWI", "mengde": "1,4 kg", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.791045+02
217	insert_error:23505	kiwi_20251020.json	{"pris": "29.90", "butikk": "KIWI", "mengde": "200g", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.797321+02
218	insert_error:23505	kiwi_20251020.json	{"pris": "63.90", "butikk": "KIWI", "mengde": "360 g, 2 pk", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.803987+02
219	insert_error:23505	kiwi_20251020.json	{"pris": "43.90", "butikk": "KIWI", "mengde": "200 g", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.805962+02
220	insert_error:42703	kiwi_20251020.json	{"pris": "99.00", "butikk": "KIWI", "mengde": "Pr. kg", "produkt": "Svineknoke", "kategori": "Kjøtt"}	2025-10-21 00:24:01.815472+02
221	invalid_price	kiwi_20251020.json	{"pris": "-26%", "butikk": "KIWI", "mengde": "210g", "produkt": "MOZZARELLA", "kategori": "Meieri"}	2025-10-21 00:24:01.844912+02
222	invalid_price	kiwi_20251020.json	{"pris": "-43%", "butikk": "KIWI", "mengde": "370g", "produkt": "REVET", "kategori": "Meieri"}	2025-10-21 00:24:01.845195+02
223	insert_error:23505	kiwi_20251020.json	{"pris": "144", "butikk": "KIWI", "mengde": "1.4kg", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.860945+02
224	invalid_price	kiwi_20251020.json	{"pris": "-20%", "butikk": "KIWI", "mengde": "1.4kg", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.861272+02
225	insert_error:42703	kiwi_20251020.json	{"pris": "39.90", "butikk": "KIWI", "mengde": "2kg", "produkt": "Poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.863242+02
226	invalid_price	kiwi_20251020.json	{"pris": "15% bonus", "butikk": "KIWI", "mengde": "2kg", "produkt": "Poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.863515+02
227	invalid_price	kiwi_20251020.json	{"pris": "15% bonus", "butikk": "KIWI", "mengde": "200g", "produkt": "Brokkolini", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.863815+02
228	invalid_price	kiwi_20251020.json	{"pris": "15% trumf-bonus", "butikk": "KIWI", "mengde": "", "produkt": "Norske epler", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.864058+02
229	invalid_price	kiwi_20251020.json	{"pris": "15% trumf-bonus", "butikk": "KIWI", "mengde": "", "produkt": "Kålrot", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.864305+02
230	invalid_price	kiwi_20251020.json	{"pris": "15% trumf-bonus", "butikk": "KIWI", "mengde": "", "produkt": "Brokkolini", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.864548+02
231	invalid_price	kiwi_20251020.json	{"pris": "15% trumf-bonus med kiwi pluss", "butikk": "KIWI", "mengde": "2 kg", "produkt": "Poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.864794+02
232	invalid_price	kiwi_20251020.json	{"pris": "15% trumf-bonus med kiwi pluss", "butikk": "KIWI", "mengde": "1.5 kg", "produkt": "Mandelpoteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.865037+02
233	insert_error:42703	kiwi_20251020.json	{"pris": "99.00", "butikk": "KIWI", "mengde": "10 stk", "produkt": "Roser", "kategori": "Annet"}	2025-10-21 00:24:01.866805+02
234	insert_error:42703	kiwi_20251020.json	{"pris": "24.90", "butikk": "KIWI", "mengde": "11 cm", "produkt": "Calluna", "kategori": "Annet"}	2025-10-21 00:24:01.868593+02
235	insert_error:42703	kiwi_20251020.json	{"pris": "69.90", "butikk": "KIWI", "mengde": "14 cm", "produkt": "Calluna Trio", "kategori": "Annet"}	2025-10-21 00:24:01.870355+02
236	insert_error:42703	kiwi_20251020.json	{"pris": "49.60", "butikk": "KIWI", "mengde": "400 g", "produkt": "Prior Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.873492+02
237	invalid_price	kiwi_20251020.json	{"pris": "-43%", "butikk": "KIWI", "mengde": "200g", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.873742+02
238	insert_error:42703	kiwi_20251020.json	{"pris": "84.90", "butikk": "KIWI", "mengde": "400g", "produkt": "Strimler av kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.875516+02
239	insert_error:23505	kiwi_20251020.json	{"pris": "63.90", "butikk": "KIWI", "mengde": "300g", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.877063+02
240	insert_error:42703	kiwi_20251020.json	{"pris": "114.90", "butikk": "KIWI", "mengde": "Pr. kg", "produkt": "Nakkekoteletter av svin", "kategori": "Kjøtt"}	2025-10-21 00:24:01.884757+02
241	insert_error:42703	kiwi_20251020.json	{"pris": "49.00", "butikk": "KIWI", "mengde": "1 liter", "produkt": "Thaisuppe", "kategori": "Ferdigmat"}	2025-10-21 00:24:01.888615+02
242	invalid_price	kiwi_20251020.json	{"pris": "-43%", "butikk": "KIWI", "mengde": "1 liter", "produkt": "Thaisuppe", "kategori": "Ferdigmat"}	2025-10-21 00:24:01.890693+02
243	invalid_price	kiwi_20251020.json	{"pris": "-43%", "butikk": "KIWI", "mengde": "1 kg", "produkt": "Lapskaus", "kategori": "Ferdigmat"}	2025-10-21 00:24:01.890978+02
244	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "stk", "produkt": "Toro produkter", "kategori": "Annet"}	2025-10-21 00:24:01.898115+02
245	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "stk", "produkt": "Mello Mello", "kategori": "Snacks"}	2025-10-21 00:24:01.898432+02
246	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "stk", "produkt": "Tannkrem", "kategori": "Hygiene"}	2025-10-21 00:24:01.89875+02
247	invalid_price	meny_20251020.json	{"pris": "-20%", "butikk": "MENY", "mengde": "stk", "produkt": "Vaskemiddel", "kategori": "Husholdning"}	2025-10-21 00:24:01.899063+02
248	invalid_price	meny_20251020.json	{"pris": "-20%", "butikk": "MENY", "mengde": "stk", "produkt": "Fiskekaker", "kategori": "Fisk"}	2025-10-21 00:24:01.899367+02
249	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "stk", "produkt": "Yoghurt", "kategori": "Meieri"}	2025-10-21 00:24:01.899664+02
250	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "2kg", "produkt": "Norske poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.899971+02
251	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "stk", "produkt": "Smoothie/shot", "kategori": "Drikke"}	2025-10-21 00:24:01.900266+02
252	invalid_price	meny_20251020.json	{"pris": "-20%", "butikk": "MENY", "mengde": "150-200g", "produkt": "TINE skivet ost", "kategori": "Meieri"}	2025-10-21 00:24:01.900564+02
253	invalid_price	meny_20251020.json	{"pris": "-30%", "butikk": "MENY", "mengde": "stk", "produkt": "Kjøttpålegg", "kategori": "Kjøtt"}	2025-10-21 00:24:01.900858+02
254	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "33-40g", "produkt": "Wasa sandwich", "kategori": "Meieri"}	2025-10-21 00:24:01.901173+02
255	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "190g", "produkt": "Go Morgen yoghurt", "kategori": "Meieri"}	2025-10-21 00:24:01.901475+02
256	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "150g", "produkt": "Rislunsj", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.90177+02
257	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "4x125g", "produkt": "Junior yoghurt 0%", "kategori": "Meieri"}	2025-10-21 00:24:01.902067+02
258	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "370g", "produkt": "Havregrøt", "kategori": "Frokost"}	2025-10-21 00:24:01.902365+02
259	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "160g", "produkt": "Tube majones", "kategori": "Annet"}	2025-10-21 00:24:01.902663+02
260	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "90g", "produkt": "Potetmos", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.902962+02
261	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "2stk", "produkt": "Muffins", "kategori": "Snacks"}	2025-10-21 00:24:01.903334+02
262	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "2stk", "produkt": "Donuts", "kategori": "Snacks"}	2025-10-21 00:24:01.903736+02
263	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "6stk", "produkt": "Bordtennisballer", "kategori": "Snacks"}	2025-10-21 00:24:01.904223+02
264	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "100stk", "produkt": "Kaffefilter", "kategori": "Snacks"}	2025-10-21 00:24:01.904595+02
265	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "125g", "produkt": "Sjokoladepudding", "kategori": "Snacks"}	2025-10-21 00:24:01.905681+02
266	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "6stk", "produkt": "Kokosboller", "kategori": "Snacks"}	2025-10-21 00:24:01.906033+02
267	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "1kg", "produkt": "Klementiner", "kategori": "Snacks"}	2025-10-21 00:24:01.906377+02
268	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "200g", "produkt": "Peanøtter", "kategori": "Snacks"}	2025-10-21 00:24:01.906718+02
269	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "185g", "produkt": "Tunfisk", "kategori": "Fisk"}	2025-10-21 00:24:01.907051+02
270	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "400g", "produkt": "Pariserbaguette", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.907386+02
271	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "185g", "produkt": "Grov leverpostei", "kategori": "Meieri"}	2025-10-21 00:24:01.907767+02
272	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "110g", "produkt": "Makrell i tomat", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.908194+02
273	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "500g", "produkt": "Spaghetti", "kategori": "Snacks"}	2025-10-21 00:24:01.908554+02
274	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "230g", "produkt": "Taco saus", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.908898+02
275	invalid_price	meny_20251020.json	{"pris": "-30%", "butikk": "MENY", "mengde": "2x90g", "produkt": "Bontà Divina", "kategori": "Annet"}	2025-10-21 00:24:01.909384+02
276	invalid_price	meny_20251020.json	{"pris": "-50%", "butikk": "MENY", "mengde": "300ml", "produkt": "Dashi by Choi", "kategori": "Annet"}	2025-10-21 00:24:01.909797+02
277	invalid_price	meny_20251020.json	{"pris": "-30%", "butikk": "MENY", "mengde": "180g", "produkt": "Milk chocolate cookies", "kategori": "Drikke"}	2025-10-21 00:24:01.910223+02
278	invalid_price	meny_20251020.json	{"pris": "-30%", "butikk": "MENY", "mengde": "10x16g", "produkt": "Nescafé", "kategori": "Snacks"}	2025-10-21 00:24:01.910683+02
279	invalid_price	meny_20251020.json	{"pris": "-30%", "butikk": "MENY", "mengde": "2x100m", "produkt": "Torky", "kategori": "Husholdning"}	2025-10-21 00:24:01.911064+02
280	invalid_price	meny_20251020.json	{"pris": "-30%", "butikk": "MENY", "mengde": "50ml", "produkt": "Rexona roll-on", "kategori": "Husholdning"}	2025-10-21 00:24:01.911393+02
281	invalid_price	meny_20251020.json	{"pris": "-30%", "butikk": "MENY", "mengde": "350g", "produkt": "Akkarhonning", "kategori": "Husholdning"}	2025-10-21 00:24:01.911698+02
282	invalid_price	meny_20251020.json	{"pris": "-30%", "butikk": "MENY", "mengde": "100g", "produkt": "Mørk sjokolade", "kategori": "Snacks"}	2025-10-21 00:24:01.912004+02
283	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "400g", "produkt": "Kjøttdeig", "kategori": "Kjøtt"}	2025-10-21 00:24:01.912282+02
284	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "2x90g", "produkt": "Plantebasert burger", "kategori": "Kjøtt"}	2025-10-21 00:24:01.912554+02
285	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "250g", "produkt": "Fersk pasta", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.912856+02
286	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "250g", "produkt": "Risotto", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.913125+02
287	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "300g", "produkt": "Fiskekaker", "kategori": "Fisk"}	2025-10-21 00:24:01.913394+02
288	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "350g", "produkt": "Kjøttboller/pastasaus", "kategori": "Kjøtt"}	2025-10-21 00:24:01.913638+02
289	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "10stk", "produkt": "Mini donuts", "kategori": "Snacks"}	2025-10-21 00:24:01.913908+02
290	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "250ml", "produkt": "Drengeens chilisaus", "kategori": "Tørrvarer"}	2025-10-21 00:24:01.914175+02
291	invalid_price	meny_20251020.json	{"pris": "-10%", "butikk": "MENY", "mengde": "stk", "produkt": "Kiwifrukt", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.914464+02
292	invalid_price	meny_20251020.json	{"pris": "-25%", "butikk": "MENY", "mengde": "kg", "produkt": "Norske epler", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.914737+02
293	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "stk", "produkt": "Grovbrød", "kategori": "Brød"}	2025-10-21 00:24:01.915009+02
294	invalid_price	meny_20251020.json	{"pris": "-15%", "butikk": "MENY", "mengde": "4x125g", "produkt": "Yoghurt", "kategori": "Meieri"}	2025-10-21 00:24:01.915285+02
295	invalid_price	meny_20251020.json	{"pris": "-20%", "butikk": "MENY", "mengde": "1kg", "produkt": "Bananer", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.915559+02
296	invalid_price	meny_20251020.json	{"pris": "-20%", "butikk": "MENY", "mengde": "125g", "produkt": "Blåbær", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.915825+02
297	invalid_price	meny_20251020.json	{"pris": "-40%", "butikk": "MENY", "mengde": "500g", "produkt": "Kuttet frukt store beger", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:01.916111+02
298	invalid_price	meny_20251020.json	{"pris": "20%", "butikk": "MENY", "mengde": "Stort utvalg, Toro", "produkt": "Trumf-bonus", "kategori": "Annet"}	2025-10-21 00:24:01.91641+02
299	invalid_price	meny_20251020.json	{"pris": "30%", "butikk": "MENY", "mengde": "203-557g, Stort utvalg, Toro", "produkt": "Trumf-bonus", "kategori": "Annet"}	2025-10-21 00:24:01.916715+02
300	insert_error:42703	meny_20251020.json	{"pris": "3 for 200", "butikk": "MENY", "mengde": "6stk", "produkt": "Tørkeruller", "kategori": "Husholdning"}	2025-10-21 00:24:01.932513+02
301	insert_error:42703	meny_20251020.json	{"pris": "3 for 200", "butikk": "MENY", "mengde": "8stk", "produkt": "Toalettpapir", "kategori": "Husholdning"}	2025-10-21 00:24:01.93462+02
302	invalid_price	meny_20251020.json	{"pris": "-99%", "butikk": "MENY", "mengde": "1.17kg", "produkt": "Omo color vaskepulver", "kategori": "Husholdning"}	2025-10-21 00:24:01.934997+02
303	insert_error:42703	rema_1000_20251020.json	{"pris": "69.90", "butikk": "REMA_1000", "mengde": "400 g", "produkt": "Strimlet kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.947798+02
304	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "1-2 kg", "produkt": "Kyllinglår", "kategori": "Kjøtt"}	2025-10-21 00:24:01.98444+02
305	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "1-2 kg", "produkt": "Kyllingvingeklubber", "kategori": "Kjøtt"}	2025-10-21 00:24:01.984772+02
306	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "1-2 kg", "produkt": "Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:01.985095+02
307	insert_error:42703	rema_1000_20251020.json	{"pris": "69.90", "butikk": "REMA_1000", "mengde": "800g", "produkt": "Karbonader", "kategori": "Kjøtt"}	2025-10-21 00:24:01.998617+02
308	invalid_price	rema_1000_20251020.json	{"pris": "-67%", "butikk": "REMA_1000", "mengde": "400g", "produkt": "Urtemarinert ytrefilet av svin", "kategori": "Kjøtt"}	2025-10-21 00:24:02.005693+02
309	invalid_price	rema_1000_20251020.json	{"pris": "-74%", "butikk": "REMA_1000", "mengde": "400g", "produkt": "Bacon uten svor", "kategori": "Kjøtt"}	2025-10-21 00:24:02.00605+02
310	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "BAMA pr. kg", "produkt": "Klementiner", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.034124+02
311	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "BAMA pr. stk", "produkt": "Tomat miniplomme", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.034529+02
312	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "BAMA pr. stk", "produkt": "Brokkolini", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.034883+02
313	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "BAMA pr. stk", "produkt": "Sjalottløk", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.035229+02
314	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "BAMA pr. kg", "produkt": "Kålrot", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.035574+02
315	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "BAMA pr. stk", "produkt": "Ruccula", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.035919+02
316	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "BAMA pr. stk", "produkt": "Babyleaf mix", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.036273+02
317	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "BAMA pr. stk", "produkt": "Isberg mix", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.036618+02
318	invalid_price	rema_1000_20251020.json	{"pris": "25% bonus", "butikk": "REMA_1000", "mengde": "8 stk", "produkt": "Ukens utvalgte frukt og grønt", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.036966+02
319	insert_error:42703	rema_1000_20251020.json	{"pris": "32.90", "butikk": "REMA_1000", "mengde": "stk", "produkt": "Blomkål", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.03935+02
320	insert_error:42703	rema_1000_20251020.json	{"pris": "39.90", "butikk": "REMA_1000", "mengde": "1kg", "produkt": "Middagsris", "kategori": "Tørrvarer"}	2025-10-21 00:24:02.041637+02
321	insert_error:42703	rema_1000_20251020.json	{"pris": "34.90", "butikk": "REMA_1000", "mengde": "450g", "produkt": "Tikka Masala", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.043922+02
322	insert_error:42703	rema_1000_20251020.json	{"pris": "11.00", "butikk": "REMA_1000", "mengde": "28g", "produkt": "Taco Spice Mix", "kategori": "Tørrvarer"}	2025-10-21 00:24:02.048641+02
323	insert_error:42703	rema_1000_20251020.json	{"pris": "49.90", "butikk": "REMA_1000", "mengde": "300g", "produkt": "Original revet ost", "kategori": "Meieri"}	2025-10-21 00:24:02.050751+02
324	insert_error:42703	rema_1000_20251020.json	{"pris": "10.00", "butikk": "REMA_1000", "mengde": "330g", "produkt": "American BBQ", "kategori": "Tørrvarer"}	2025-10-21 00:24:02.057149+02
325	insert_error:42703	rema_1000_20251020.json	{"pris": "69.90", "butikk": "REMA_1000", "mengde": "3x1L", "produkt": "Thaisuppe", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.062272+02
326	invalid_price	rema_1000_20251020.json	{"pris": "-67%", "butikk": "REMA_1000", "mengde": "750g", "produkt": "Tom Kha Suppe", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.064673+02
327	invalid_price	rema_1000_20251020.json	{"pris": "-67%", "butikk": "REMA_1000", "mengde": "750g", "produkt": "Thai Suppe", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.065011+02
328	invalid_price	rema_1000_20251020.json	{"pris": "-67%", "butikk": "REMA_1000", "mengde": "750g", "produkt": "Indisk Kyllingsuppe", "kategori": "Kjøtt"}	2025-10-21 00:24:02.065314+02
329	insert_error:42703	rema_1000_20251020.json	{"pris": "39.90", "butikk": "REMA_1000", "mengde": "200g", "produkt": "Reker Pillede", "kategori": "Fisk"}	2025-10-21 00:24:02.067443+02
330	insert_error:42703	rema_1000_20251020.json	{"pris": "69.90", "butikk": "REMA_1000", "mengde": "350g", "produkt": "Strimlet Kyllingfilet", "kategori": "Kjøtt"}	2025-10-21 00:24:02.069846+02
331	insert_error:42703	rema_1000_20251020.json	{"pris": "49.90", "butikk": "REMA_1000", "mengde": "300g", "produkt": "Torsk Laks Terning", "kategori": "Fisk"}	2025-10-21 00:24:02.07343+02
332	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "1,2-2,4 kg", "produkt": "Kylling lår", "kategori": "Kjøtt"}	2025-10-21 00:24:02.073724+02
333	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "1,2-2,4 kg", "produkt": "Kylling filet", "kategori": "Kjøtt"}	2025-10-21 00:24:02.07401+02
334	invalid_price	rema_1000_20251020.json	{"pris": "-25%", "butikk": "REMA_1000", "mengde": "1,2-2,4 kg", "produkt": "Kylling vingeklubber", "kategori": "Kjøtt"}	2025-10-21 00:24:02.074303+02
335	insert_error:42703	rema_1000_20251020.json	{"pris": "87.70", "butikk": "REMA_1000", "mengde": "3 x 385g", "produkt": "Bestemors Fiskekaker", "kategori": "Fisk"}	2025-10-21 00:24:02.077806+02
336	invalid_price	rema_1000_20251020.json	{"pris": "-77%", "butikk": "REMA_1000", "mengde": "250g", "produkt": "Sprø torsk", "kategori": "Fisk"}	2025-10-21 00:24:02.0781+02
337	insert_error:23505	rema_1000_20251020.json	{"pris": "49.90", "butikk": "REMA_1000", "mengde": "600g", "produkt": "Karbonader", "kategori": "Kjøtt"}	2025-10-21 00:24:02.081413+02
338	insert_error:42703	rema_1000_20251020.json	{"pris": "34.90", "butikk": "REMA_1000", "mengde": "600g", "produkt": "Kjøttpølse", "kategori": "Drikke"}	2025-10-21 00:24:02.085046+02
339	insert_error:42703	rema_1000_20251020.json	{"pris": "69.90", "butikk": "REMA_1000", "mengde": "500g", "produkt": "Ytrefilet av svin", "kategori": "Kjøtt"}	2025-10-21 00:24:02.087042+02
340	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "425g", "produkt": "Kjøttpølse", "kategori": "Drikke"}	2025-10-21 00:24:02.089758+02
341	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "375g", "produkt": "Grandiosa porsjonsstørrelse", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.090101+02
342	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "1kg", "produkt": "Norske poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.092422+02
343	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "pr. kg", "produkt": "Bananer Bendit", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.092711+02
344	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "90-270g", "produkt": "Grønn & Frisk salater", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.093003+02
345	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "400g", "produkt": "Delikat gulrot", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.093292+02
346	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "4-pk", "produkt": "Gul løk", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.093578+02
347	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "300g", "produkt": "Rød spisspaprika", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.093869+02
348	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "200g", "produkt": "Aspargesbønner/snittebønner", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.094152+02
349	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "stk", "produkt": "My Pizza Slice", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.094421+02
350	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "250g", "produkt": "Spekesild", "kategori": "Fisk"}	2025-10-21 00:24:02.094704+02
351	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "140g", "produkt": "My Pizza Slice Dr. Oetker, ham & cheese/mozarella & pesto", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.094969+02
352	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "400g", "produkt": "Lasagne Folkets", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.095229+02
353	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "200g", "produkt": "Fish & Crisp Findus", "kategori": "Tørrvarer"}	2025-10-21 00:24:02.095499+02
354	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "400g", "produkt": "Fried Rice Eldorado", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.095759+02
355	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "230g", "produkt": "Pinsa Eldorado", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.096025+02
356	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "360g", "produkt": "Pizzabunn Eldorado", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.096286+02
357	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "500ml", "produkt": "Tomatsuppe Eldorado", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.096575+02
358	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "405g", "produkt": "Pannekaker 6-pk.", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.098188+02
359	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "250g", "produkt": "Melange", "kategori": "Husholdning"}	2025-10-21 00:24:02.098449+02
360	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "300g", "produkt": "Løkringer", "kategori": "Snacks"}	2025-10-21 00:24:02.098707+02
361	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "350g", "produkt": "Hvitløksbaguetter 2-pk.", "kategori": "Brød"}	2025-10-21 00:24:02.098971+02
362	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "300-500g", "produkt": "Grønnsaker", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.099229+02
363	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "500g", "produkt": "Bukettgrønnsaker", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.099515+02
364	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "650g", "produkt": "Makaroni", "kategori": "Tørrvarer"}	2025-10-21 00:24:02.099768+02
365	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "500g", "produkt": "Couscous", "kategori": "Tørrvarer"}	2025-10-21 00:24:02.100566+02
366	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "594g", "produkt": "Maiskorn 3-pk.", "kategori": "Frokost"}	2025-10-21 00:24:02.100862+02
367	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "1l", "produkt": "Solsikkeolje/rapsolje", "kategori": "Husholdning"}	2025-10-21 00:24:02.101125+02
368	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "500g", "produkt": "Pasta Linguine Eldorado", "kategori": "Tørrvarer"}	2025-10-21 00:24:02.101411+02
369	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "80g", "produkt": "Vårrull biff/kylling/vegetar", "kategori": "Kjøtt"}	2025-10-21 00:24:02.101671+02
370	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "750g", "produkt": "Julius Favorittbrød", "kategori": "Brød"}	2025-10-21 00:24:02.101942+02
371	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "200-240g", "produkt": "Leksands knekkebrød", "kategori": "Brød"}	2025-10-21 00:24:02.102206+02
372	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "230-235g", "produkt": "Soft Flora", "kategori": "Husholdning"}	2025-10-21 00:24:02.102465+02
373	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "450g", "produkt": "Lier surdeigsstykker 5-pk.", "kategori": "Brød"}	2025-10-21 00:24:02.10273+02
374	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "1kg", "produkt": "Solsikke-/kornbrød", "kategori": "Brød"}	2025-10-21 00:24:02.102987+02
375	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "600-700g", "produkt": "Müsli", "kategori": "Frokost"}	2025-10-21 00:24:02.103244+02
376	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "175g", "produkt": "Smøreost", "kategori": "Meieri"}	2025-10-21 00:24:02.103505+02
377	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "180-190g", "produkt": "Postei", "kategori": "Meieri"}	2025-10-21 00:24:02.103811+02
378	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "380g", "produkt": "Klem jordbærsyltetøy", "kategori": "Annet"}	2025-10-21 00:24:02.104179+02
379	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "150g", "produkt": "Fløtemys", "kategori": "Meieri"}	2025-10-21 00:24:02.104562+02
380	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "200g", "produkt": "Dansk salami", "kategori": "Kjøtt"}	2025-10-21 00:24:02.104905+02
381	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "150g", "produkt": "Kokt skinke", "kategori": "Kjøtt"}	2025-10-21 00:24:02.105207+02
382	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "90g", "produkt": "Skyr Mini", "kategori": "Meieri"}	2025-10-21 00:24:02.105487+02
383	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "160g", "produkt": "Skyr", "kategori": "Meieri"}	2025-10-21 00:24:02.10576+02
384	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "190g", "produkt": "Proteinyoghurt", "kategori": "Meieri"}	2025-10-21 00:24:02.106038+02
385	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "200g", "produkt": "Protein-pudding", "kategori": "Meieri"}	2025-10-21 00:24:02.10629+02
386	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "330ml", "produkt": "Restitusjonsdrikk", "kategori": "Drikke"}	2025-10-21 00:24:02.106539+02
387	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "150g", "produkt": "Rislunsj", "kategori": "Tørrvarer"}	2025-10-21 00:24:02.106782+02
388	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "80-100g", "produkt": "Ostestenger", "kategori": "Meieri"}	2025-10-21 00:24:02.107464+02
389	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "0.25l", "produkt": "Red Bull", "kategori": "Drikke"}	2025-10-21 00:24:02.107714+02
390	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "0.33l", "produkt": "Munkholm Fatøl", "kategori": "Drikke"}	2025-10-21 00:24:02.107959+02
391	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "473 ml + pant", "produkt": "Red Bull regular/sukkerfri", "kategori": "Drikke"}	2025-10-21 00:24:02.108235+02
392	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "0,65 l + pant", "produkt": "Imsdal", "kategori": "Drikke"}	2025-10-21 00:24:02.108485+02
393	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "0,5 l", "produkt": "Sjokolademelk", "kategori": "Meieri"}	2025-10-21 00:24:02.108739+02
394	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "1,5 l", "produkt": "Eplejuice Eldorado", "kategori": "Drikke"}	2025-10-21 00:24:02.108987+02
395	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "1 stk", "produkt": "Freia Firkløver, Melkesjokolade, Kvikk Lunsj", "kategori": "Meieri"}	2025-10-21 00:24:02.109274+02
396	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "1 stk", "produkt": "Nidar Hobby, Bounty, Dumle, Lion", "kategori": "Snacks"}	2025-10-21 00:24:02.109531+02
397	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "115 g", "produkt": "Sjokoladepudding Danette", "kategori": "Snacks"}	2025-10-21 00:24:02.116231+02
398	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "25 g", "produkt": "Fisherman's Friend", "kategori": "Annet"}	2025-10-21 00:24:02.116478+02
399	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "50 g", "produkt": "Turklenning Berthas, kanel", "kategori": "Annet"}	2025-10-21 00:24:02.116752+02
400	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "60 g", "produkt": "Berlinerboller Bakehuset, vanilje/bringebær", "kategori": "Annet"}	2025-10-21 00:24:02.116994+02
401	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "95 g", "produkt": "Aunt Mabel's", "kategori": "Annet"}	2025-10-21 00:24:02.117233+02
402	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "75 ml", "produkt": "Zendium fresh & white/kids", "kategori": "Hygiene"}	2025-10-21 00:24:02.125355+02
403	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "250 ml", "produkt": "Listerine Total Care", "kategori": "Hygiene"}	2025-10-21 00:24:02.125596+02
404	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "250–300 ml", "produkt": "Lano refill håndsåpe/dusjsåpe", "kategori": "Hygiene"}	2025-10-21 00:24:02.12611+02
405	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "", "produkt": "Oppvaskbørste", "kategori": "Husholdning"}	2025-10-21 00:24:02.126746+02
406	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "", "produkt": "Kubbelys", "kategori": "Husholdning"}	2025-10-21 00:24:02.126986+02
407	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "425g", "produkt": "Kjøttpølse Leiv Vidar, skinnfri", "kategori": "Drikke"}	2025-10-21 00:24:02.12723+02
408	insert_error:42703	spar_20251020.json	{"pris": "2 for 100", "butikk": "SPAR", "mengde": "0,33l + pant", "produkt": "Coca-Cola/Fanta/Sprite", "kategori": "Drikke"}	2025-10-21 00:24:02.129001+02
409	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "pr. kg", "produkt": "Norske poteter", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.129784+02
410	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "pr. kg", "produkt": "Bananer", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.130045+02
411	invalid_price	spar_20251020.json	{"pris": "-18%", "butikk": "SPAR", "mengde": "pr. kg", "produkt": "Bananer Bendit", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.130282+02
412	invalid_price	spar_20251020.json	{"pris": "-10%", "butikk": "SPAR", "mengde": "1kg", "produkt": "Delikat gulrot", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.130524+02
413	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "140 g", "produkt": "My Pizza Slice Dr. Oetker, ham & cheese/mozzarella & pesto", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.139073+02
414	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "200 g", "produkt": "Fish & Crisp Findus", "kategori": "Tørrvarer"}	2025-10-21 00:24:02.139348+02
415	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "400 g", "produkt": "Fried Rice Eldorado", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.139618+02
416	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "230 g", "produkt": "Pinsa Eldorado", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.139894+02
417	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "360 g", "produkt": "Pizzabunn Eldorado, steinovnsbakt", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.140161+02
418	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "570 ml", "produkt": "Tomatsuppe Eldorado, mild", "kategori": "Frukt/Grønt"}	2025-10-21 00:24:02.140428+02
419	invalid_price	spar_20251020.json	{"pris": "-20%", "butikk": "SPAR", "mengde": "1 kg", "produkt": "Klippfisk", "kategori": "Fisk"}	2025-10-21 00:24:02.140694+02
420	invalid_price	spar_20251020.json	{"pris": "-30%", "butikk": "SPAR", "mengde": "405 g", "produkt": "Pannekaker 6-pk.", "kategori": "Ferdigmat"}	2025-10-21 00:24:02.140962+02
\.


--
-- TOC entry 5031 (class 0 OID 0)
-- Dependencies: 233
-- Name: bruker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bruker_id_seq', 1, false);


--
-- TOC entry 5032 (class 0 OID 0)
-- Dependencies: 223
-- Name: butikk_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.butikk_id_seq', 264, true);


--
-- TOC entry 5033 (class 0 OID 0)
-- Dependencies: 235
-- Name: favoritt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.favoritt_id_seq', 1, false);


--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 225
-- Name: kategori_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kategori_id_seq', 297, true);


--
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 229
-- Name: pris_historikk_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pris_historikk_id_seq', 94, true);


--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 227
-- Name: produkt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produkt_id_seq', 587, true);


--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 221
-- Name: produkter_historikk_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produkter_historikk_id_seq', 1, false);


--
-- TOC entry 5038 (class 0 OID 0)
-- Dependencies: 217
-- Name: produkter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produkter_id_seq', 610, true);


--
-- TOC entry 5039 (class 0 OID 0)
-- Dependencies: 219
-- Name: produkter_rejects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produkter_rejects_id_seq', 420, true);


--
-- TOC entry 4837 (class 2606 OID 16703)
-- Name: bruker bruker_brukernavn_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bruker
    ADD CONSTRAINT bruker_brukernavn_key UNIQUE (brukernavn);


--
-- TOC entry 4839 (class 2606 OID 16701)
-- Name: bruker bruker_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bruker
    ADD CONSTRAINT bruker_pkey PRIMARY KEY (id);


--
-- TOC entry 4818 (class 2606 OID 16499)
-- Name: butikk butikk_navn_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.butikk
    ADD CONSTRAINT butikk_navn_key UNIQUE (navn);


--
-- TOC entry 4820 (class 2606 OID 16497)
-- Name: butikk butikk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.butikk
    ADD CONSTRAINT butikk_pkey PRIMARY KEY (id);


--
-- TOC entry 4841 (class 2606 OID 16711)
-- Name: favoritt favoritt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favoritt
    ADD CONSTRAINT favoritt_pkey PRIMARY KEY (id);


--
-- TOC entry 4823 (class 2606 OID 16510)
-- Name: kategori kategori_navn_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_navn_key UNIQUE (navn);


--
-- TOC entry 4825 (class 2606 OID 16508)
-- Name: kategori kategori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_pkey PRIMARY KEY (id);


--
-- TOC entry 4833 (class 2606 OID 16559)
-- Name: pris_historikk pris_historikk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pris_historikk
    ADD CONSTRAINT pris_historikk_pkey PRIMARY KEY (id);


--
-- TOC entry 4828 (class 2606 OID 16521)
-- Name: produkt produkt_navn_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkt
    ADD CONSTRAINT produkt_navn_key UNIQUE (navn);


--
-- TOC entry 4830 (class 2606 OID 16519)
-- Name: produkt produkt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkt
    ADD CONSTRAINT produkt_pkey PRIMARY KEY (id);


--
-- TOC entry 4816 (class 2606 OID 16466)
-- Name: produkter_historikk produkter_historikk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter_historikk
    ADD CONSTRAINT produkter_historikk_pkey PRIMARY KEY (id);


--
-- TOC entry 4810 (class 2606 OID 16442)
-- Name: produkter produkter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter
    ADD CONSTRAINT produkter_pkey PRIMARY KEY (id);


--
-- TOC entry 4814 (class 2606 OID 16455)
-- Name: produkter_rejects produkter_rejects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter_rejects
    ADD CONSTRAINT produkter_rejects_pkey PRIMARY KEY (id);


--
-- TOC entry 4835 (class 2606 OID 16730)
-- Name: pris_historikk uniq_pris_tid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pris_historikk
    ADD CONSTRAINT uniq_pris_tid UNIQUE (produkt_id, butikk_id, gyldig_fra, pris);


--
-- TOC entry 4812 (class 2606 OID 17052)
-- Name: produkter uniq_produkt_butikk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter
    ADD CONSTRAINT uniq_produkt_butikk UNIQUE (produkt_id, butikk_id);


--
-- TOC entry 4821 (class 1259 OID 16548)
-- Name: idx_butikk_navn; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_butikk_navn ON public.butikk USING btree (navn);


--
-- TOC entry 4831 (class 1259 OID 16570)
-- Name: idx_pris_hist_dato; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pris_hist_dato ON public.pris_historikk USING btree (gyldig_fra, gyldig_til);


--
-- TOC entry 4826 (class 1259 OID 16547)
-- Name: idx_produkt_navn; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_produkt_navn ON public.produkt USING btree (navn);


--
-- TOC entry 4851 (class 2620 OID 17050)
-- Name: produkter produkter_logg_til_historikk; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER produkter_logg_til_historikk BEFORE UPDATE ON public.produkter FOR EACH ROW EXECUTE FUNCTION public.logg_pris_endring();


--
-- TOC entry 4849 (class 2606 OID 16712)
-- Name: favoritt favoritt_bruker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favoritt
    ADD CONSTRAINT favoritt_bruker_id_fkey FOREIGN KEY (bruker_id) REFERENCES public.bruker(id) ON DELETE CASCADE;


--
-- TOC entry 4850 (class 2606 OID 16717)
-- Name: favoritt favoritt_produkt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favoritt
    ADD CONSTRAINT favoritt_produkt_id_fkey FOREIGN KEY (produkt_id) REFERENCES public.produkt(id) ON DELETE CASCADE;


--
-- TOC entry 4847 (class 2606 OID 16565)
-- Name: pris_historikk pris_historikk_butikk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pris_historikk
    ADD CONSTRAINT pris_historikk_butikk_id_fkey FOREIGN KEY (butikk_id) REFERENCES public.butikk(id);


--
-- TOC entry 4848 (class 2606 OID 16560)
-- Name: pris_historikk pris_historikk_produkt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pris_historikk
    ADD CONSTRAINT pris_historikk_produkt_id_fkey FOREIGN KEY (produkt_id) REFERENCES public.produkt(id);


--
-- TOC entry 4846 (class 2606 OID 16522)
-- Name: produkt produkt_kategori_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkt
    ADD CONSTRAINT produkt_kategori_id_fkey FOREIGN KEY (kategori_id) REFERENCES public.kategori(id);


--
-- TOC entry 4842 (class 2606 OID 16527)
-- Name: produkter produkter_butikk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter
    ADD CONSTRAINT produkter_butikk_id_fkey FOREIGN KEY (butikk_id) REFERENCES public.butikk(id);


--
-- TOC entry 4844 (class 2606 OID 16537)
-- Name: produkter_historikk produkter_historikk_butikk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter_historikk
    ADD CONSTRAINT produkter_historikk_butikk_id_fkey FOREIGN KEY (butikk_id) REFERENCES public.butikk(id);


--
-- TOC entry 4845 (class 2606 OID 16542)
-- Name: produkter_historikk produkter_historikk_produkt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter_historikk
    ADD CONSTRAINT produkter_historikk_produkt_id_fkey FOREIGN KEY (produkt_id) REFERENCES public.produkt(id);


--
-- TOC entry 4843 (class 2606 OID 16532)
-- Name: produkter produkter_produkt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkter
    ADD CONSTRAINT produkter_produkt_id_fkey FOREIGN KEY (produkt_id) REFERENCES public.produkt(id);


-- Completed on 2025-10-30 17:32:18

--
-- PostgreSQL database dump complete
--

\unrestrict 1MUrxVsJxCQxXGpXLqNHzUBQnXkwdMuzeRmw2Q3pGdHmNbyhwSMeqWu7TDh4vDb

