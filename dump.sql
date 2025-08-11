--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

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
-- Name: decrement_all_furniture_stock(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decrement_all_furniture_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE all_furniture
	SET quantity = quantity - NEW.quantity
	WHERE id = NEW.furniture_item_id;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.decrement_all_furniture_stock() OWNER TO postgres;

--
-- Name: decrement_individual_furniture_stock(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decrement_individual_furniture_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	f_type TEXT;
	f_item_id INT;
BEGIN
	SELECT furniture_type, item_id INTO f_type, f_item_id
	FROM all_furniture
	WHERE id = NEW.furniture_item_id;

	CASE f_type
		WHEN 'bed' THEN
			UPDATE beds SET quantity = quantity - NEW.quantity WHERE id = f_item_id;
		WHEN 'night_stand' THEN
			UPDATE night_stands SET quantity = quantity - NEW.quantity WHERE id = f_item_id;
		WHEN 'dresser' THEN
			UPDATE dressers SET quantity = quantity - NEW.quantity WHERE id = f_item_id;
		WHEN 'couch' THEN
			UPDATE couches SET quantity = quantity - NEW.quantity WHERE id = f_item_id;
		WHEN 'tv' THEN
			UPDATE tvs SET quantity = quantity - NEW.quantity WHERE id = f_item_id;
		WHEN 'table' THEN
			UPDATE tables SET quantity = quantity - NEW.quantity WHERE id = f_item_id;
		ELSE
			RAISE EXCEPTION 'Unknown furniture type: %', f_type;
	END CASE;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.decrement_individual_furniture_stock() OWNER TO postgres;

--
-- Name: delete_bed_from_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_bed_from_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM all_furniture
    WHERE item_id = OLD.id AND furniture_type = OLD.furniture_type;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_bed_from_all_furniture() OWNER TO postgres;

--
-- Name: delete_couch_from_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_couch_from_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM all_furniture
    WHERE item_id = OLD.id AND furniture_type = OLD.furniture_type;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_couch_from_all_furniture() OWNER TO postgres;

--
-- Name: delete_dresser_from_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_dresser_from_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM all_furniture
    WHERE item_id = OLD.id AND furniture_type = OLD.furniture_type;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_dresser_from_all_furniture() OWNER TO postgres;

--
-- Name: delete_night_stand_from_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_night_stand_from_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM all_furniture
    WHERE item_id = OLD.id AND furniture_type = OLD.furniture_type;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_night_stand_from_all_furniture() OWNER TO postgres;

--
-- Name: delete_table_from_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_table_from_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM all_furniture
    WHERE item_id = OLD.id AND furniture_type = OLD.furniture_type;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_table_from_all_furniture() OWNER TO postgres;

--
-- Name: delete_tv_from_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_tv_from_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM all_furniture
    WHERE item_id = OLD.id AND furniture_type = OLD.furniture_type;
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_tv_from_all_furniture() OWNER TO postgres;

--
-- Name: finalize_checkout(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.finalize_checkout(p_cart_id integer, p_customer_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	new_checkout_id INT;
	total NUMERIC(10, 2);
BEGIN
	BEGIN
		INSERT INTO checkout (customer_id, cart_id)
		VALUES (p_customer_id, p_cart_id)
		RETURNING id INTO new_checkout_id;
	
		INSERT INTO checkout_items (checkout_id, furniture_item_id, quantity, unit_price)
		SELECT new_checkout_id, ci.furniture_item_id, ci.quantity, af.price
		FROM cart_items ci
		JOIN all_furniture af ON ci.furniture_item_id = af.id
		WHERE ci.cart_id = p_cart_id;
	
		SELECT SUM(quantity * unit_price)
		INTO total
		FROM checkout_items
		WHERE checkout_id = new_checkout_id;
	
		UPDATE checkout
		SET total_price = total
		WHERE id = new_checkout_id;
	
		RETURN new_checkout_id;

	EXCEPTION WHEN OTHERS THEN
		RAISE EXCEPTION 'Checkout failed: %', SQLERRM;
	END;
END;
$$;


ALTER FUNCTION public.finalize_checkout(p_cart_id integer, p_customer_id integer) OWNER TO postgres;

--
-- Name: insert_bed_into_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_bed_into_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO all_furniture (item_id, name, price, furniture_type, quantity)
    VALUES (NEW.id, NEW.name, NEW.price, NEW.furniture_type, NEW.quantity);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_bed_into_all_furniture() OWNER TO postgres;

--
-- Name: insert_couch_into_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_couch_into_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO all_furniture (item_id, name, price, furniture_type, quantity)
    VALUES (NEW.id, NEW.name, NEW.price, NEW.furniture_type, NEW.quantity);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_couch_into_all_furniture() OWNER TO postgres;

--
-- Name: insert_dresser_into_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_dresser_into_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO all_furniture (item_id, name, price, furniture_type, quantity)
    VALUES (NEW.id, NEW.name, NEW.price, NEW.furniture_type, NEW.quantity);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_dresser_into_all_furniture() OWNER TO postgres;

--
-- Name: insert_initial_bedroom_set_price(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_initial_bedroom_set_price() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO bedroom_set_price_maker (bedroom_set_id, total_price)
	VALUES (
		NEW.id,
		COALESCE((SELECT price FROM beds WHERE id = NEW.bed_id), 0) +
		COALESCE((SELECT price FROM night_stands WHERE id = NEW.night_stand_id), 0) +
		COALESCE((SELECT price FROM dressers WHERE id = NEW.dresser_id), 0)
	);
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_initial_bedroom_set_price() OWNER TO postgres;

--
-- Name: insert_initial_living_room_set_price(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_initial_living_room_set_price() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO living_room_set_price_maker (living_room_set_id, total_price)
    VALUES (
        NEW.id,
        COALESCE((SELECT price FROM couches WHERE id = NEW.couch_id), 0) +
        COALESCE((SELECT price FROM tvs WHERE id = NEW.tv_id), 0) +
        COALESCE((SELECT price FROM tables WHERE id = NEW.table_id), 0)
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_initial_living_room_set_price() OWNER TO postgres;

--
-- Name: insert_night_stand_into_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_night_stand_into_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO all_furniture (item_id, name, price, furniture_type, quantity)
    VALUES (NEW.id, NEW.name, NEW.price, NEW.furniture_type, NEW.quantity);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_night_stand_into_all_furniture() OWNER TO postgres;

--
-- Name: insert_table_into_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_table_into_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO all_furniture (item_id, name, price, furniture_type, quantity)
    VALUES (NEW.id, NEW.name, NEW.price, NEW.furniture_type, NEW.quantity);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_table_into_all_furniture() OWNER TO postgres;

--
-- Name: insert_tv_into_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_tv_into_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO all_furniture (item_id, name, price, furniture_type, quantity)
    VALUES (NEW.id, NEW.name, NEW.price, NEW.furniture_type, NEW.quantity);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_tv_into_all_furniture() OWNER TO postgres;

--
-- Name: prevent_adding_out_of_stock_items(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_adding_out_of_stock_items() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	available INT;
BEGIN
	SELECT quantity INTO available
	FROM all_furniture
	WHERE id = NEW.furniture_item_id;

	IF available IS NULL THEN
	RAISE EXCEPTION 'Item ID % not found in all_furniture', NEW.furniture_item_id;
	ELSIF NEW.quantity > available THEN
		RAISE EXCEPTION 'Only % of item ID % available, but % requested', available, NEW.furniture_item_id, NEW.quantity;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.prevent_adding_out_of_stock_items() OWNER TO postgres;

--
-- Name: update_bed_in_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_bed_in_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE all_furniture
    SET name = NEW.name,
        price = NEW.price,
        furniture_type = NEW.furniture_type,
        quantity = NEW.quantity
    WHERE item_id = NEW.id AND furniture_type = OLD.furniture_type;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_bed_in_all_furniture() OWNER TO postgres;

--
-- Name: update_bedroom_set_price(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_bedroom_set_price(set_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE bedroom_set_price_maker sp
	SET total_price = (
		SELECT
			COALESCE(b.price, 0) + COALESCE(n.price, 0) + COALESCE(d.price, 0)
			FROM bedroom_sets s
			JOIN beds b ON s.bed_id = b.id
			JOIN night_stands n ON s.night_stand_id = n.id
			JOIN dressers d ON s.dresser_id = d.id
			WHERE s.id = set_id
	)
	WHERE sp.bedroom_set_id = set_id;
END;
$$;


ALTER FUNCTION public.update_bedroom_set_price(set_id integer) OWNER TO postgres;

--
-- Name: update_cart_total_price(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_cart_total_price() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
	total NUMERIC(10, 2);
BEGIN
	SELECT SUM(ci.quantity * af.price)
	INTO total
	FROM cart_items ci
	JOIN all_furniture af ON ci.furniture_item_id = af.id
	WHERE ci.cart_id = COALESCE(NEW.cart_id, OLD.cart_id);

	RETURN NULL;
END;
$$;


ALTER FUNCTION public.update_cart_total_price() OWNER TO postgres;

--
-- Name: update_couch_in_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_couch_in_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE all_furniture
    SET name = NEW.name,
        price = NEW.price,
        furniture_type = NEW.furniture_type,
        quantity = NEW.quantity
    WHERE item_id = NEW.id AND furniture_type = OLD.furniture_type;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_couch_in_all_furniture() OWNER TO postgres;

--
-- Name: update_dresser_in_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_dresser_in_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE all_furniture
    SET name = NEW.name,
        price = NEW.price,
        furniture_type = NEW.furniture_type,
        quantity = NEW.quantity
    WHERE item_id = NEW.id AND furniture_type = OLD.furniture_type;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_dresser_in_all_furniture() OWNER TO postgres;

--
-- Name: update_living_room_set_price(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_living_room_set_price(set_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE living_room_set_price_maker sp
    SET total_price = (
        SELECT 
            COALESCE(c.price, 0) + COALESCE(tv.price, 0) + COALESCE(tbl.price, 0)
        FROM living_room_sets s
        JOIN couches c ON s.couch_id = c.id
        JOIN tvs tv ON s.tv_id = tv.id
        JOIN tables tbl ON s.table_id = tbl.id
        WHERE s.id = set_id
    )
    WHERE sp.bedroom_set_id = set_id;
END;
$$;


ALTER FUNCTION public.update_living_room_set_price(set_id integer) OWNER TO postgres;

--
-- Name: update_night_stand_in_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_night_stand_in_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE all_furniture
    SET name = NEW.name,
        price = NEW.price,
        furniture_type = NEW.furniture_type,
        quantity = NEW.quantity
    WHERE item_id = NEW.id AND furniture_type = OLD.furniture_type;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_night_stand_in_all_furniture() OWNER TO postgres;

--
-- Name: update_price_on_bed_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_price_on_bed_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE bedroom_set_price_maker
	SET total_price = total_price - OLD.price + NEW.price
	WHERE bedroom_set_id IN (
		SELECT id FROM bedroom_sets WHERE bed_id = NEW.id
	);
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_price_on_bed_change() OWNER TO postgres;

--
-- Name: update_price_on_couch_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_price_on_couch_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE living_room_set_price_maker
    SET total_price = total_price - OLD.price + NEW.price
    WHERE living_room_set_id IN (
        SELECT id FROM living_room_sets WHERE couch_id = NEW.id
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_price_on_couch_change() OWNER TO postgres;

--
-- Name: update_price_on_dresser_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_price_on_dresser_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE bedroom_set_price_maker
	SET total_price = total_price - OLD.price + NEW.price
	WHERE bedroom_set_id IN (
		SELECT id FROM bedroom_sets WHERE dresser_id = NEW.id
	);
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_price_on_dresser_change() OWNER TO postgres;

--
-- Name: update_price_on_night_stand_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_price_on_night_stand_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE bedroom_set_price_maker
	SET total_price = total_price - OLD.price + NEW.price
	WHERE bedroom_set_id IN (
		SELECT id FROM bedroom_sets WHERE night_stand_id = NEW.id
	);
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_price_on_night_stand_change() OWNER TO postgres;

--
-- Name: update_price_on_table_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_price_on_table_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE living_room_set_price_maker
    SET total_price = total_price - OLD.price + NEW.price
    WHERE living_room_set_id IN (
        SELECT id FROM living_room_sets WHERE table_id = NEW.id
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_price_on_table_change() OWNER TO postgres;

--
-- Name: update_price_on_tv_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_price_on_tv_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE living_room_set_price_maker
    SET total_price = total_price - OLD.price + NEW.price
    WHERE living_room_set_id IN (
        SELECT id FROM living_room_sets WHERE tv_id = NEW.id
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_price_on_tv_change() OWNER TO postgres;

--
-- Name: update_table_in_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_table_in_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE all_furniture
    SET name = NEW.name,
        price = NEW.price,
        furniture_type = NEW.furniture_type,
        quantity = NEW.quantity
    WHERE item_id = NEW.id AND furniture_type = OLD.furniture_type;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_table_in_all_furniture() OWNER TO postgres;

--
-- Name: update_tv_in_all_furniture(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_tv_in_all_furniture() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE all_furniture
    SET name = NEW.name,
        price = NEW.price,
        furniture_type = NEW.furniture_type,
        quantity = NEW.quantity
    WHERE item_id = NEW.id AND furniture_type = OLD.furniture_type;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_tv_in_all_furniture() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: all_furniture; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.all_furniture (
    id integer NOT NULL,
    item_id integer,
    name text,
    price numeric(10,2),
    furniture_type text,
    quantity integer
);


ALTER TABLE public.all_furniture OWNER TO postgres;

--
-- Name: all_furniture_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.all_furniture_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.all_furniture_id_seq OWNER TO postgres;

--
-- Name: all_furniture_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.all_furniture_id_seq OWNED BY public.all_furniture.id;


--
-- Name: bedroom_set_price_maker; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bedroom_set_price_maker (
    bedroom_set_id integer NOT NULL,
    total_price numeric(10,2) NOT NULL
);


ALTER TABLE public.bedroom_set_price_maker OWNER TO postgres;

--
-- Name: bedroom_sets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bedroom_sets (
    id integer NOT NULL,
    bed_id integer,
    night_stand_id integer,
    dresser_id integer,
    theme text
);


ALTER TABLE public.bedroom_sets OWNER TO postgres;

--
-- Name: beds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.beds (
    id integer NOT NULL,
    name text,
    price integer,
    furniture_type text,
    quantity integer,
    CONSTRAINT beds_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.beds OWNER TO postgres;

--
-- Name: beds_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.beds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.beds_id_seq OWNER TO postgres;

--
-- Name: beds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.beds_id_seq OWNED BY public.beds.id;


--
-- Name: cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    total_price numeric(10,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cart OWNER TO postgres;

--
-- Name: cart_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_id_seq OWNER TO postgres;

--
-- Name: cart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_id_seq OWNED BY public.cart.id;


--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_items (
    id integer NOT NULL,
    cart_id integer NOT NULL,
    furniture_item_id integer NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT cart_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.cart_items OWNER TO postgres;

--
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_items_id_seq OWNER TO postgres;

--
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- Name: checkout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checkout (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    cart_id integer,
    total_price numeric(10,2),
    checkout_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    payment_status text DEFAULT 'pending'::text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.checkout OWNER TO postgres;

--
-- Name: checkout_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.checkout_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.checkout_id_seq OWNER TO postgres;

--
-- Name: checkout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.checkout_id_seq OWNED BY public.checkout.id;


--
-- Name: checkout_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checkout_items (
    id integer NOT NULL,
    cart_id integer,
    furniture_item_id integer,
    quantity integer NOT NULL,
    unit_price numeric(10,2),
    checkout_id integer
);


ALTER TABLE public.checkout_items OWNER TO postgres;

--
-- Name: checkout_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.checkout_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.checkout_items_id_seq OWNER TO postgres;

--
-- Name: checkout_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.checkout_items_id_seq OWNED BY public.checkout_items.id;


--
-- Name: couches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.couches (
    id integer NOT NULL,
    name text,
    price integer,
    furniture_type text,
    quantity integer,
    CONSTRAINT couches_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.couches OWNER TO postgres;

--
-- Name: couches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.couches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.couches_id_seq OWNER TO postgres;

--
-- Name: couches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.couches_id_seq OWNED BY public.couches.id;


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO postgres;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id integer DEFAULT nextval('public.customers_id_seq'::regclass) NOT NULL,
    name text,
    number integer,
    password text,
    address text,
    email text,
    google_id text
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: dressers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dressers (
    id integer NOT NULL,
    name text,
    price integer,
    furniture_type text,
    quantity integer,
    CONSTRAINT dressers_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.dressers OWNER TO postgres;

--
-- Name: dressers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dressers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dressers_id_seq OWNER TO postgres;

--
-- Name: dressers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dressers_id_seq OWNED BY public.dressers.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    name text,
    title text,
    password text,
    salary integer
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: living_room_set_price_maker; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.living_room_set_price_maker (
    living_room_set_id integer NOT NULL,
    total_price integer
);


ALTER TABLE public.living_room_set_price_maker OWNER TO postgres;

--
-- Name: living_room_sets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.living_room_sets (
    id integer NOT NULL,
    couch_id integer,
    tv_id integer,
    table_id integer,
    theme text
);


ALTER TABLE public.living_room_sets OWNER TO postgres;

--
-- Name: night_stands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.night_stands (
    id integer NOT NULL,
    name text,
    price integer,
    furniture_type text,
    quantity integer,
    CONSTRAINT night_stands_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.night_stands OWNER TO postgres;

--
-- Name: night_stands_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.night_stands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.night_stands_id_seq OWNER TO postgres;

--
-- Name: night_stands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.night_stands_id_seq OWNED BY public.night_stands.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    customer_id integer,
    employee_id integer,
    order_id integer,
    room_set_type text,
    completed boolean
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tables (
    id integer NOT NULL,
    name text,
    price integer,
    furniture_type text,
    quantity integer,
    CONSTRAINT tables_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.tables OWNER TO postgres;

--
-- Name: tables_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tables_id_seq OWNER TO postgres;

--
-- Name: tables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tables_id_seq OWNED BY public.tables.id;


--
-- Name: tvs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tvs (
    id integer NOT NULL,
    name text,
    price integer,
    furniture_type text,
    quantity integer,
    CONSTRAINT tvs_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.tvs OWNER TO postgres;

--
-- Name: tvs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tvs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tvs_id_seq OWNER TO postgres;

--
-- Name: tvs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tvs_id_seq OWNED BY public.tvs.id;


--
-- Name: all_furniture id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.all_furniture ALTER COLUMN id SET DEFAULT nextval('public.all_furniture_id_seq'::regclass);


--
-- Name: beds id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beds ALTER COLUMN id SET DEFAULT nextval('public.beds_id_seq'::regclass);


--
-- Name: cart id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart ALTER COLUMN id SET DEFAULT nextval('public.cart_id_seq'::regclass);


--
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- Name: checkout id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout ALTER COLUMN id SET DEFAULT nextval('public.checkout_id_seq'::regclass);


--
-- Name: checkout_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout_items ALTER COLUMN id SET DEFAULT nextval('public.checkout_items_id_seq'::regclass);


--
-- Name: couches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.couches ALTER COLUMN id SET DEFAULT nextval('public.couches_id_seq'::regclass);


--
-- Name: dressers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dressers ALTER COLUMN id SET DEFAULT nextval('public.dressers_id_seq'::regclass);


--
-- Name: night_stands id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.night_stands ALTER COLUMN id SET DEFAULT nextval('public.night_stands_id_seq'::regclass);


--
-- Name: tables id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tables ALTER COLUMN id SET DEFAULT nextval('public.tables_id_seq'::regclass);


--
-- Name: tvs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tvs ALTER COLUMN id SET DEFAULT nextval('public.tvs_id_seq'::regclass);


--
-- Data for Name: all_furniture; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.all_furniture (id, item_id, name, price, furniture_type, quantity) FROM stdin;
9	2	treasure_chest	300.00	dresser	100
3	1	tool_box	250.00	dresser	100
1	1	racecar	1000.00	bed	100
8	2	lego_cubicle	200.00	night_stand	100
5	1	seashell	250.00	tv	100
11	2	flat_screen_tv	400.00	tv	100
6	1	sandstone	250.00	table	100
12	2	round_table	250.00	table	100
4	1	surfboard	1000.00	couch	100
10	2	pullout_couch	600.00	couch	100
14	3	Roos Ultimate Cool Boy Couch	333.00	couch	99
16	3	Koalas Party Bean Boy Pong Table	999.00	table	99
15	3	Kiwis Super Slick Boy Bed	111.00	bed	99
13	6	nothing	1.00	bed	99
7	2	water_bed	200.00	bed	99
2	1	gas_can	250.00	night_stand	99
\.


--
-- Data for Name: bedroom_set_price_maker; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bedroom_set_price_maker (bedroom_set_id, total_price) FROM stdin;
1	1500.00
\.


--
-- Data for Name: bedroom_sets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bedroom_sets (id, bed_id, night_stand_id, dresser_id, theme) FROM stdin;
1	1	1	1	cars
\.


--
-- Data for Name: beds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.beds (id, name, price, furniture_type, quantity) FROM stdin;
1	racecar	1000	bed	100
3	Kiwis Super Slick Boy Bed	111	bed	99
6	nothing	1	bed	99
2	water_bed	200	bed	99
\.


--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart (id, customer_id, total_price, created_at) FROM stdin;
8	13	\N	2025-08-11 02:49:39.301561
9	14	\N	2025-08-11 03:03:47.620824
\.


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_items (id, cart_id, furniture_item_id, quantity) FROM stdin;
\.


--
-- Data for Name: checkout; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checkout (id, customer_id, cart_id, total_price, checkout_date, payment_status, created_at) FROM stdin;
39	13	8	144300.00	2025-08-11 02:51:41.182908	pending	2025-08-11 02:51:41.182908
\.


--
-- Data for Name: checkout_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checkout_items (id, cart_id, furniture_item_id, quantity, unit_price, checkout_id) FROM stdin;
40	\N	16	1	99900.00	39
41	\N	15	1	11100.00	39
42	\N	14	1	33300.00	39
\.


--
-- Data for Name: couches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.couches (id, name, price, furniture_type, quantity) FROM stdin;
1	surfboard	1000	couch	100
2	pullout_couch	600	couch	100
3	Roos Ultimate Cool Boy Couch	333	couch	99
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, name, number, password, address, email, google_id) FROM stdin;
13	Kyle	\N	$2b$10$Stlf0yQTsctXC6iwJ/bysOQMBbD1QRCrn/OEinHNrHGVpmJh/opPi	\N	\N	\N
14	Kyle Bradley	\N	\N	\N	kylefromthewater@gmail.com	109541577166440886425
\.


--
-- Data for Name: dressers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dressers (id, name, price, furniture_type, quantity) FROM stdin;
2	treasure_chest	300	dresser	100
1	tool_box	250	dresser	100
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, name, title, password, salary) FROM stdin;
\.


--
-- Data for Name: living_room_set_price_maker; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.living_room_set_price_maker (living_room_set_id, total_price) FROM stdin;
1	1500
\.


--
-- Data for Name: living_room_sets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.living_room_sets (id, couch_id, tv_id, table_id, theme) FROM stdin;
1	1	1	1	beach
\.


--
-- Data for Name: night_stands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.night_stands (id, name, price, furniture_type, quantity) FROM stdin;
2	lego_cubicle	200	night_stand	100
1	gas_can	250	night_stand	99
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, customer_id, employee_id, order_id, room_set_type, completed) FROM stdin;
\.


--
-- Data for Name: tables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tables (id, name, price, furniture_type, quantity) FROM stdin;
1	sandstone	250	table	100
2	round_table	250	table	100
3	Koalas Party Bean Boy Pong Table	999	table	99
\.


--
-- Data for Name: tvs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tvs (id, name, price, furniture_type, quantity) FROM stdin;
1	seashell	250	tv	100
2	flat_screen_tv	400	tv	100
\.


--
-- Name: all_furniture_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.all_furniture_id_seq', 16, true);


--
-- Name: beds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.beds_id_seq', 2, true);


--
-- Name: cart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_id_seq', 9, true);


--
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 72, true);


--
-- Name: checkout_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checkout_id_seq', 39, true);


--
-- Name: checkout_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checkout_items_id_seq', 42, true);


--
-- Name: couches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.couches_id_seq', 1, false);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 14, true);


--
-- Name: dressers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dressers_id_seq', 1, false);


--
-- Name: night_stands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.night_stands_id_seq', 1, false);


--
-- Name: tables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tables_id_seq', 1, false);


--
-- Name: tvs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tvs_id_seq', 1, false);


--
-- Name: all_furniture all_furniture_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.all_furniture
    ADD CONSTRAINT all_furniture_pkey PRIMARY KEY (id);


--
-- Name: bedroom_set_price_maker bedroom_set_price_maker_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bedroom_set_price_maker
    ADD CONSTRAINT bedroom_set_price_maker_pkey PRIMARY KEY (bedroom_set_id);


--
-- Name: bedroom_sets bedroom_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bedroom_sets
    ADD CONSTRAINT bedroom_sets_pkey PRIMARY KEY (id);


--
-- Name: bedroom_sets bedroom_sets_theme_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bedroom_sets
    ADD CONSTRAINT bedroom_sets_theme_key UNIQUE (theme);


--
-- Name: beds beds_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beds
    ADD CONSTRAINT beds_name_key UNIQUE (name);


--
-- Name: beds beds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beds
    ADD CONSTRAINT beds_pkey PRIMARY KEY (id);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- Name: checkout_items checkout_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout_items
    ADD CONSTRAINT checkout_items_pkey PRIMARY KEY (id);


--
-- Name: checkout checkout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout
    ADD CONSTRAINT checkout_pkey PRIMARY KEY (id);


--
-- Name: couches couches_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.couches
    ADD CONSTRAINT couches_name_key UNIQUE (name);


--
-- Name: couches couches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.couches
    ADD CONSTRAINT couches_pkey PRIMARY KEY (id);


--
-- Name: customers customers_google_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_google_id_key UNIQUE (google_id);


--
-- Name: customers customers_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_number_key UNIQUE (number);


--
-- Name: customers customers_password_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_password_key UNIQUE (password);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: dressers dressers_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dressers
    ADD CONSTRAINT dressers_name_key UNIQUE (name);


--
-- Name: dressers dressers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dressers
    ADD CONSTRAINT dressers_pkey PRIMARY KEY (id);


--
-- Name: employees employees_password_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_password_key UNIQUE (password);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: employees employees_title_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_title_key UNIQUE (title);


--
-- Name: living_room_set_price_maker living_room_set_price_maker_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.living_room_set_price_maker
    ADD CONSTRAINT living_room_set_price_maker_pkey PRIMARY KEY (living_room_set_id);


--
-- Name: living_room_sets living_room_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.living_room_sets
    ADD CONSTRAINT living_room_sets_pkey PRIMARY KEY (id);


--
-- Name: living_room_sets living_room_sets_theme_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.living_room_sets
    ADD CONSTRAINT living_room_sets_theme_key UNIQUE (theme);


--
-- Name: night_stands night_stands_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.night_stands
    ADD CONSTRAINT night_stands_name_key UNIQUE (name);


--
-- Name: night_stands night_stands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.night_stands
    ADD CONSTRAINT night_stands_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: tables tables_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tables
    ADD CONSTRAINT tables_name_key UNIQUE (name);


--
-- Name: tables tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tables
    ADD CONSTRAINT tables_pkey PRIMARY KEY (id);


--
-- Name: tvs tvs_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tvs
    ADD CONSTRAINT tvs_name_key UNIQUE (name);


--
-- Name: tvs tvs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tvs
    ADD CONSTRAINT tvs_pkey PRIMARY KEY (id);


--
-- Name: beds bed_delete_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bed_delete_trigger AFTER DELETE ON public.beds FOR EACH ROW EXECUTE FUNCTION public.delete_bed_from_all_furniture();


--
-- Name: beds bed_insert_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bed_insert_trigger AFTER INSERT ON public.beds FOR EACH ROW EXECUTE FUNCTION public.insert_bed_into_all_furniture();


--
-- Name: beds bed_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bed_update_trigger AFTER UPDATE ON public.beds FOR EACH ROW EXECUTE FUNCTION public.update_bed_in_all_furniture();


--
-- Name: cart_items check_stock_before_cart_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_stock_before_cart_insert BEFORE INSERT ON public.cart_items FOR EACH ROW EXECUTE FUNCTION public.prevent_adding_out_of_stock_items();


--
-- Name: couches couch_delete_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER couch_delete_trigger AFTER DELETE ON public.couches FOR EACH ROW EXECUTE FUNCTION public.delete_couch_from_all_furniture();


--
-- Name: couches couch_insert_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER couch_insert_trigger AFTER INSERT ON public.couches FOR EACH ROW EXECUTE FUNCTION public.insert_couch_into_all_furniture();


--
-- Name: couches couch_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER couch_update_trigger AFTER UPDATE ON public.couches FOR EACH ROW EXECUTE FUNCTION public.update_couch_in_all_furniture();


--
-- Name: dressers dresser_delete_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dresser_delete_trigger AFTER DELETE ON public.dressers FOR EACH ROW EXECUTE FUNCTION public.delete_dresser_from_all_furniture();


--
-- Name: dressers dresser_insert_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dresser_insert_trigger AFTER INSERT ON public.dressers FOR EACH ROW EXECUTE FUNCTION public.insert_dresser_into_all_furniture();


--
-- Name: dressers dresser_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER dresser_update_trigger AFTER UPDATE ON public.dressers FOR EACH ROW EXECUTE FUNCTION public.update_dresser_in_all_furniture();


--
-- Name: night_stands night_stand_delete_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER night_stand_delete_trigger AFTER DELETE ON public.night_stands FOR EACH ROW EXECUTE FUNCTION public.delete_night_stand_from_all_furniture();


--
-- Name: night_stands night_stand_insert_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER night_stand_insert_trigger AFTER INSERT ON public.night_stands FOR EACH ROW EXECUTE FUNCTION public.insert_night_stand_into_all_furniture();


--
-- Name: night_stands night_stand_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER night_stand_update_trigger AFTER UPDATE ON public.night_stands FOR EACH ROW EXECUTE FUNCTION public.update_night_stand_in_all_furniture();


--
-- Name: tables table_delete_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER table_delete_trigger AFTER DELETE ON public.tables FOR EACH ROW EXECUTE FUNCTION public.delete_table_from_all_furniture();


--
-- Name: tables table_insert_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER table_insert_trigger AFTER INSERT ON public.tables FOR EACH ROW EXECUTE FUNCTION public.insert_table_into_all_furniture();


--
-- Name: tables table_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER table_update_trigger AFTER UPDATE ON public.tables FOR EACH ROW EXECUTE FUNCTION public.update_table_in_all_furniture();


--
-- Name: beds trg_bed_price_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_bed_price_update AFTER UPDATE OF price ON public.beds FOR EACH ROW EXECUTE FUNCTION public.update_price_on_bed_change();


--
-- Name: couches trg_couch_price_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_couch_price_update AFTER UPDATE OF price ON public.couches FOR EACH ROW EXECUTE FUNCTION public.update_price_on_couch_change();


--
-- Name: bedroom_sets trg_initial_set_price; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_initial_set_price AFTER INSERT ON public.bedroom_sets FOR EACH ROW EXECUTE FUNCTION public.insert_initial_bedroom_set_price();


--
-- Name: living_room_sets trg_insert_lr_set_price; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_insert_lr_set_price AFTER INSERT ON public.living_room_sets FOR EACH ROW EXECUTE FUNCTION public.insert_initial_living_room_set_price();


--
-- Name: dressers trg_night_stand_price_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_night_stand_price_update AFTER UPDATE OF price ON public.dressers FOR EACH ROW EXECUTE FUNCTION public.update_price_on_dresser_change();


--
-- Name: night_stands trg_night_stand_price_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_night_stand_price_update AFTER UPDATE OF price ON public.night_stands FOR EACH ROW EXECUTE FUNCTION public.update_price_on_night_stand_change();


--
-- Name: tables trg_tbl_price_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_tbl_price_update AFTER UPDATE OF price ON public.tables FOR EACH ROW EXECUTE FUNCTION public.update_price_on_table_change();


--
-- Name: tvs trg_tv_price_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_tv_price_update AFTER UPDATE OF price ON public.tvs FOR EACH ROW EXECUTE FUNCTION public.update_price_on_tv_change();


--
-- Name: tvs tv_delete_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tv_delete_trigger AFTER DELETE ON public.tvs FOR EACH ROW EXECUTE FUNCTION public.delete_tv_from_all_furniture();


--
-- Name: tvs tv_insert_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tv_insert_trigger AFTER INSERT ON public.tvs FOR EACH ROW EXECUTE FUNCTION public.insert_tv_into_all_furniture();


--
-- Name: tvs tv_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tv_update_trigger AFTER UPDATE ON public.tvs FOR EACH ROW EXECUTE FUNCTION public.update_tv_in_all_furniture();


--
-- Name: cart_items update_all_furniture_stock_after_cart_item_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_all_furniture_stock_after_cart_item_insert AFTER INSERT ON public.cart_items FOR EACH ROW EXECUTE FUNCTION public.decrement_all_furniture_stock();


--
-- Name: cart_items update_cart_total_price_after_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_cart_total_price_after_insert AFTER INSERT OR DELETE OR UPDATE ON public.cart_items FOR EACH ROW EXECUTE FUNCTION public.update_cart_total_price();


--
-- Name: cart_items update_individual_furniture_stock_after_cart_item_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_individual_furniture_stock_after_cart_item_insert AFTER INSERT ON public.cart_items FOR EACH ROW EXECUTE FUNCTION public.decrement_individual_furniture_stock();


--
-- Name: bedroom_set_price_maker bedroom_set_price_maker_bedroom_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bedroom_set_price_maker
    ADD CONSTRAINT bedroom_set_price_maker_bedroom_set_id_fkey FOREIGN KEY (bedroom_set_id) REFERENCES public.bedroom_sets(id);


--
-- Name: bedroom_sets bedroom_sets_bed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bedroom_sets
    ADD CONSTRAINT bedroom_sets_bed_id_fkey FOREIGN KEY (bed_id) REFERENCES public.beds(id);


--
-- Name: bedroom_sets bedroom_sets_dresser_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bedroom_sets
    ADD CONSTRAINT bedroom_sets_dresser_id_fkey FOREIGN KEY (dresser_id) REFERENCES public.dressers(id);


--
-- Name: bedroom_sets bedroom_sets_night_stand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bedroom_sets
    ADD CONSTRAINT bedroom_sets_night_stand_id_fkey FOREIGN KEY (night_stand_id) REFERENCES public.night_stands(id);


--
-- Name: cart cart_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_furniture_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_furniture_item_id_fkey FOREIGN KEY (furniture_item_id) REFERENCES public.all_furniture(id);


--
-- Name: checkout checkout_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout
    ADD CONSTRAINT checkout_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.cart(id);


--
-- Name: checkout checkout_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout
    ADD CONSTRAINT checkout_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: checkout_items checkout_items_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout_items
    ADD CONSTRAINT checkout_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.cart(id);


--
-- Name: checkout_items checkout_items_checkout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout_items
    ADD CONSTRAINT checkout_items_checkout_id_fkey FOREIGN KEY (checkout_id) REFERENCES public.checkout(id);


--
-- Name: checkout_items checkout_items_furniture_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout_items
    ADD CONSTRAINT checkout_items_furniture_item_id_fkey FOREIGN KEY (furniture_item_id) REFERENCES public.all_furniture(id);


--
-- Name: living_room_set_price_maker living_room_set_price_maker_living_room_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.living_room_set_price_maker
    ADD CONSTRAINT living_room_set_price_maker_living_room_set_id_fkey FOREIGN KEY (living_room_set_id) REFERENCES public.living_room_sets(id);


--
-- Name: living_room_sets living_room_sets_couch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.living_room_sets
    ADD CONSTRAINT living_room_sets_couch_id_fkey FOREIGN KEY (couch_id) REFERENCES public.couches(id);


--
-- Name: living_room_sets living_room_sets_table_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.living_room_sets
    ADD CONSTRAINT living_room_sets_table_id_fkey FOREIGN KEY (table_id) REFERENCES public.tables(id);


--
-- Name: living_room_sets living_room_sets_tv_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.living_room_sets
    ADD CONSTRAINT living_room_sets_tv_id_fkey FOREIGN KEY (tv_id) REFERENCES public.tvs(id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: orders orders_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- PostgreSQL database dump complete
--

