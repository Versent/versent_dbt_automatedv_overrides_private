{% macro pit_as_of_date(
    satellites
    ) -%}
with
{%- for sat in satellites %}
    {{sat}} as (
        select 
            {{ satellites[sat]['pk'] }},
            {{ satellites[sat]['as_of_date'] }} as as_of_date
        from 
            {{ ref(sat)}}
    ),
{%- endfor %}

    union_sat_as_of_dates as (
    {%- for sat in satellites %}        
        select 
            * 
        from
            {{sat}}
        {% if not loop.last %}union{% endif %}
    {%- endfor %}
    ),
    final as (
        select distinct *
        from union_sat_as_of_dates
    )

    select 
        *
    from 
        final
{%- endmacro %}