{% macro sat(
    src_pk,
    business_key,
    src_hashdiff,
    src_payload,
    src_eff,
    src_ldts,
    src_source,
    source_model
    ) -%}
 
{% set lower_src_payload = src_payload | map('lower') | list %}
{% if 'record_action' in lower_src_payload %}
    {% set record_action_fld_name = src_payload[lower_src_payload.index('record_action')] %}
{%- endif -%}
 
with
    automate_dv_sat as (
        {{ automate_dv.sat(
            src_pk=src_pk,
                src_hashdiff=src_hashdiff,
                src_payload=src_payload,
                src_eff=src_eff,
                src_ldts=src_ldts,
                src_source=src_source,
                source_model=source_model
                            ) }}
    ),
    {%- if business_key|length > 0 %} 
    bk as (
        select
            distinct
            {{ src_pk }},
            {{ business_key }}
        from
            {{ ref(source_model)}}
    ),
    {%- endif %}
    final as (
        select
            {%- if business_key|length > 0 %} 
            coalesce(bk.{{business_key}}, '{{ var('bk_ghost') }}') as {{business_key}},
            {%- endif %}
            automate_dv_sat.*
            {%- if record_action_fld_name %} 
                except({{ record_action_fld_name }}),
                coalesce({{ record_action_fld_name }}, 'INSERT') as {{ record_action_fld_name }}
            {%- endif %}
        from
            automate_dv_sat
        {%- if business_key|length > 0 %} 
        left join
            bk
                on automate_dv_sat.{{src_pk}} = bk.{{src_pk}}
        {%- endif %}   
    )
select
    *
from
    final

{%- endmacro %}