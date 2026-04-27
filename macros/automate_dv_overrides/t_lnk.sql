{%- macro t_link(src_pk, src_fk, src_payload, src_extra_columns, src_eff, src_ldts, src_source, source_model) -%}

with t_lnk as (
{{ automate_dv.nh_link(
    src_pk=src_pk,
    src_fk=src_fk,
    src_payload=src_payload,
    src_extra_columns=src_extra_columns,
    src_eff=src_eff,
    src_ldts=src_ldts,
    src_source=src_source,
    source_model=source_model
    ) }}
)
select 
    t_lnk.* except(
            {%- for col in src_fk %}
            {{col}}{% if not loop.last %},{% endif %}
            {%- endfor %}
    ) ,
    {%- for col in src_fk %}
    if(
        string({{col}})='CD9E459EA708A948D5C2F5A6CA8838CF', 
        cast('{{ var('bk_ghost') }}' as binary),
        {{col}}
     ) as {{col}}{% if not loop.last %},{% endif %}
    {%- endfor %}    

from
    t_lnk
                    
 
{%- endmacro -%}