create or replace function agg_first(
    IN p_state       anyelement,
    IN p_new_element anyelement
    )
    returns anyelement
    language sql
    as $$
select coalesce( p_state, p_new_element );
$$;

create aggregate first(anyelement) (
    sfunc = agg_first,
    stype = anyelement
);

create or replace function agg_last(
    IN p_state       anyelement,
    IN p_new_element anyelement
    )
    returns anyelement
    language sql
    as $$
select coalesce( p_new_element, p_state );
$$;

create aggregate last(anyelement) (
    sfunc = agg_last,
    stype = anyelement
);

create or replace function agg_first(
    IN p_state       anyarray,
    IN p_new_element anyelement,
    IN p_limit       int4
    )
    returns anyarray
    language sql
    as $$
select case
    when coalesce( array_length( p_state, 1 ), 0 ) < p_limit
         then p_state || p_new_element
    else p_state
    end;
$$;

create aggregate first(anyelement, int4) (
    sfunc = agg_first,
    stype = anyarray,
    initcond = '{}'
);

create or replace function agg_last(
    IN p_state       anyarray,
    IN p_new_element anyelement,
    IN p_limit       int4
    )
    returns anyarray
    language sql
    as $$
select ( case
    when array_length( p_state, 1 ) >= p_limit
        then p_state[(array_upper(p_state, 1) - p_limit + 2):]
    else
        p_state
    end ) || p_new_element;
$$;

CREATE AGGREGATE last(anyelement, int4) (
    sfunc = agg_last,
    stype = anyarray,
    initcond = '{}'
);

