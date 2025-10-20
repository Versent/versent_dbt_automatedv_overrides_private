{% macro pit(
    hub,
    hash_key,
    business_key,
    as_of_dates_table,
    as_of_date,
    satellites,
    record_source,
    load_datetime
    ) -%}
with 
{%- if as_of_dates_table|length == 0 %} 
-- ##### generated_as_of_dates
{%- for sat in satellites %}
    {{sat}}_as_of_date as (
        select 
            {{ satellites[sat]['pk'] }},
            {{ satellites[sat]['ldts'] }} as as_of_date
        from 
            {{ ref(sat)}}
    ),
{%- endfor %}
    union_sat_as_of_dates as (
    {%- for sat in satellites %}        
        select 
            * 
        from
            {{sat}}_as_of_date
        {% if not loop.last %}union{% endif %}
    {%- endfor %}
    ),
    generated_as_of_dates as (
        select distinct *
        from union_sat_as_of_dates
    ),
-- ##### generated_as_of_dates
{%- endif %} 
    rows_as_of_dates as (
        select
            hub.{{hash_key}},
            {%- if business_key|length > 0 %} 
            hub.{{business_key}}, 
            {%- endif %}
            {%- if as_of_date|length > 0 %}
            as_of_dates.{{as_of_date}} as as_of_date
            {%- else %}
            as_of_dates.as_of_date
            {%- endif %}
        from
            {{ ref(hub)}} hub
        left join
            {%- if as_of_dates_table|length > 0 %}            
            {{ ref(as_of_dates_table)}} as_of_dates
            {%- else %}
            generated_as_of_dates as_of_dates
            {%- endif %}             
            on hub.{{hash_key}}  = as_of_dates.{{hash_key}}
          
    ),
    {%- for sat in satellites %}
    {{sat}}_effective_dates AS (
        select
            {{hash_key}},
            {{ satellites[sat]['ldts'] }},
            CASE 
                WHEN ROW_NUMBER() OVER (PARTITION BY {{hash_key}} ORDER BY {{ satellites[sat]['ldts'] }}) = 1 
                THEN TO_TIMESTAMP('1900-01-01 00:00:00')
                ELSE {{ satellites[sat]['ldts'] }}
            END AS effective_from,
            DATEADD(
            'millisecond', -1,
            LEAD({{ satellites[sat]['ldts'] }}, 1, TO_TIMESTAMP('2999-01-01 00:00:01')) OVER (
                PARTITION BY {{hash_key}}
                ORDER BY {{ satellites[sat]['ldts'] }}
            )
            ) AS effective_to
        FROM
            {{ ref(sat)}}
    ),
    {%- endfor %}          
    row_sats as (
        select
            rows_as_of_dates.{{hash_key}},
            {%- if business_key|length > 0 %} 
            rows_as_of_dates.{{business_key}}, 
            {%- endif %}
            rows_as_of_dates.as_of_date,
            -- ghost
            {{ hk_ghost_default()}},
            cast('1900-01-01 00:00:00' as timestamp) as early_date,            
            {%- for sat in satellites %}
            {{sat}}_src.{{ satellites[sat]['pk'] }} as {{sat}}_pk,
            {{sat}}_src.{{ satellites[sat]['ldts'] }} as {{sat}}_ldts{% if not loop.last %},{% endif %}
            {%- endfor %}  
        from
            rows_as_of_dates
        {%- for sat in satellites %}
            left join
                 {{sat}}_effective_dates as {{sat}}_src
                on rows_as_of_dates.{{hash_key}} = {{sat}}_src.{{ satellites[sat]['pk'] }}
                and rows_as_of_dates.as_of_date between {{sat}}_src.effective_from
                    and {{sat}}_src.effective_to                        
        {%- endfor %}       

    ),
    final as (
        select
            {{hash_key}},
            {%- if business_key|length > 0 %} 
            {{business_key}}, 
            {%- endif %}
            coalesce(as_of_date, early_date) as as_of_date,
            {%- if record_source|length > 0 %} 
            '{{record_source}}' as record_source, 
            {%- endif %}
            {%- if load_datetime|length > 0 %} 
            {{load_datetime}} as load_datetime, 
            {%- endif %}
            {%- for sat in satellites %}            
                coalesce({{sat}}_pk , hk_ghost) as {{sat}}_pk,
                coalesce({{sat}}_ldts, early_date) as {{sat}}_ldts{% if not loop.last %},{% endif %}
            {%- endfor %}    
        from
            row_sats 
    )    
select
    *
from
    final
{%- endmacro %}