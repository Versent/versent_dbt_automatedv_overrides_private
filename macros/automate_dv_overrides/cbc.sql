{% macro cbc(
    hash_key,
    hub_bkey,
    hub,
    pit,
    satellites,
    payload,
    derivations
    ) -%}
with 
    hub as (
        select 
            {{hash_key}},
            {{hub_bkey}},
            record_source
        from {{ ref(hub) }}
    ),
    pit as (
        select 
            *
        from
                    {{ ref(pit)}}
    ),
    -- satellites
    {%- for sat in satellites %}
    {{sat}} as (
        with
            {{ sat }} as (
                select 
                    {{ satellites[sat]['pk'] }},
                    {{ satellites[sat]['ldts'] }},
                    -- payload
                    {% set sat_payload = satellites[sat]['payload'] %}
                        {{ versent_dbt_automatedv_overrides_private.mac_payload(sat_payload)}}
                from 
                    {{ ref(sat)}}
            ), 
            {%- set lookups = satellites[sat]['lookups'] %}
            {%- for lookup in lookups %}
            {{ lookup}} as (
                select
                    {{ lookups[lookup]['bk'] ~ ' as bk_' ~ lookup}},
                    {% set sat_payload = lookups[lookup]['payload'] %}
                    {{ versent_dbt_automatedv_overrides_private.mac_payload(sat_payload)}}
                from
                    {{ ref(lookup)}}
            ),
                --{{ lookup_table}}
            {%- endfor %}
            final as (
                select 
                    *
                from 
                    {{ sat }}
                        {%- set lookups = satellites[sat]['lookups'] %}
                        {%- for lookup in lookups %}
                        left join
                        {{ lookup}} 
                            on
                                {{sat}}.{{ lookups[lookup]['sat_bk'] if 'sat_bk' in lookups[lookup] else lookups[lookup]['bk'] }} = {{ 'bk_' ~ lookup }}
                        {%- endfor %}
            )

            select
                *
            from 
                final
    ),
    {%- endfor %}
    get_sats as (
        select 
            hub.{{hash_key}},
            hub.{{hub_bkey}},
            pit.as_of_date,
            {%- for sat in satellites %}    
            -- {{sat}}
                {% set sat_payload = satellites[sat]['payload'] %}
                {{ versent_dbt_automatedv_overrides_private.mac_payload_cols(sat_payload)}}
                {%- set lookups = satellites[sat]['lookups'] %}
                {%- for lookup in lookups %}
                    {% set lookup_payload = lookups[lookup]['payload'] %}
                    {{ versent_dbt_automatedv_overrides_private.mac_payload_cols(lookup_payload)}}
                {%- endfor %}
            {%- endfor %}  
            current_timestamp() as load_datetime,
            hub.record_source    
        from
            hub
            join 
                pit 
                    on
                        hub.{{hash_key}} = pit.{{hash_key}}
                -- satellites
                    {%- for sat in satellites %}
                    left join
                        {{sat}}
                            on
                                pit.{{hash_key}} = {{sat}}.{{hash_key}} and
                                pit.{{satellites[sat]['pit_ldts']}} = {{sat}}.{{satellites[sat]['ldts']}}
                    {%- endfor %}
    ),
    derivations as (
        select
            {% set derivation_payload = derivations %}
            {{ versent_dbt_automatedv_overrides_private.mac_payload(derivation_payload)}}{%if derivation_payload is defined and derivation_payload is not none%},{%endif%}                 
            * 
        from
            get_sats

    ),
    final as (
        select
            *
        from
            derivations
    )
select
    *
from
    final 
{%- endmacro %}
