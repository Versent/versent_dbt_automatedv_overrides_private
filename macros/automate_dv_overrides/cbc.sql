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
            {{ sat }}_data as (  
                select 
                    {{ satellites[sat]['pk'] }},
                    {{ satellites[sat]['ldts'] }},
                    -- payload
                    {% set sat_payload = satellites[sat]['payload'] %}
                    {% if sat_payload %}  
                        {{ versent_dbt_automatedv_overrides_private.mac_payload(sat_payload)}}
                    {% endif %}
                from 
                    {{ ref(sat)}}
            )
            {%- set lookups = satellites[sat].get('lookups', {}) %} 
            {%- for lookup in lookups %}
            ,{{ lookup}} as (  
                select
                    {{ lookups[lookup]['bk'] ~ ' as bk_' ~ lookup}},
                    {% set lookup_payload = lookups[lookup]['payload'] %}
                    {{ versent_dbt_automatedv_overrides_private.mac_payload(lookup_payload)}}
                from
                    {{ ref(lookup)}}
            )
            {%- endfor %}
            ,final as (  
                select 
                    *
                from 
                    {{ sat }}_data  
                        {%- set lookups = satellites[sat].get('lookups', {}) %}
                        {%- for lookup in lookups %}
                        left join
                        {{ lookup}} 
                            on
                                {{sat}}_data.{{ lookups[lookup]['sat_bk'] if 'sat_bk' in lookups[lookup] else lookups[lookup]['bk'] }} = {{ 'bk_' ~ lookup }}
                        {%- endfor %}
            )

            select
                *
            from 
                final
    )
    {%- if not loop.last %},{% endif %}  
    {%- endfor %}
    ,get_sats as ( 
        select 
            hub.{{hash_key}},
            hub.{{hub_bkey}},
            pit.as_of_date
            {%- for sat in satellites %}    
                {% set sat_payload = satellites[sat]['payload'] %}
                {% if sat_payload %}
                ,{{ versent_dbt_automatedv_overrides_private.mac_payload(sat_payload)}}
                {% endif %}
                {%- set lookups = satellites[sat].get('lookups', {}) %}
                {%- for lookup in lookups %}
                    {% set lookup_payload = lookups[lookup]['payload'] %}
                    ,{{ versent_dbt_automatedv_overrides_private.mac_payload(lookup_payload)}}
                {%- endfor %}
            {%- endfor %}  
            ,current_timestamp() as load_datetime
            ,hub.record_source    
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
                                pit.{{hash_key}} = {{sat}}.{{satellites[sat]['pk']}} and  
                                pit.{{satellites[sat]['pit_ldts']}} = {{sat}}.{{satellites[sat]['ldts']}}
                    {%- endfor %}
    )
    {%- if derivations %} 
    ,derivations as (
        select
            {{ versent_dbt_automatedv_overrides_private.mac_payload(derivations)}},                 
            * 
        from
            get_sats
    )
    {%- endif %}
    ,final as (
        select
            *
        from
            {% if derivations %}derivations{% else %}get_sats{% endif %}
    )
select
    *
from
    final 
{%- endmacro %}