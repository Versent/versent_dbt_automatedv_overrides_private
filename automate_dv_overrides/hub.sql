{%- macro hub(src_pk, src_nk, src_extra_columns, src_ldts, src_source, source_model) -%}

{{- automate_dv.default__hub(src_pk=src_pk,
                             src_nk=src_nk,
                             src_extra_columns=src_extra_columns,
                             src_ldts=src_ldts,
                             src_source=src_source,
                             source_model=source_model) -}}


{# Overrides automate_dv.hub macro to add 'ghost' record #}
UNION 
SELECT  cast('{{ var('bk_ghost') }}' as binary) AS {{src_pk}},
        '{{ var('bk_ghost') }}' as {{src_nk}},
        current_timestamp() as load_datetime,
        'macros_hub' as record_source
                    
 
{%- endmacro -%}