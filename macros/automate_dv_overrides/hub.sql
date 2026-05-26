{%- macro hub(src_pk, src_nk, src_extra_columns, src_ldts, src_source, source_model) -%}
{% set var_bk_ghost = var('bk_ghost') %}
{{- automate_dv.default__hub(src_pk=src_pk,
                             src_nk=src_nk,
                             src_extra_columns=src_extra_columns,
                             src_ldts=src_ldts,
                             src_source=src_source,
                             source_model=source_model) -}}


{# Overrides automate_dv.hub macro to add 'ghost' record #}
UNION 
SELECT  {{ automate_dv.hash(src_nk, src_pk) }},
        {{ src_nk}},
        current_timestamp() as load_datetime,
        'macros_hub' as record_source
    from
        (
            select 
            '{{ var_bk_ghost }}' as {{src_nk}})
 
{%- endmacro -%}