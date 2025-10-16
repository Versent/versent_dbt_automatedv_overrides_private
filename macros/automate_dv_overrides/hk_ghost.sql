{% macro hk_ghost(column_name) -%}
coalesce (
    {{column_name}},
    {{ hk_ghost_default()}}
    ) as {{ column_name }}
{%- endmacro %}

{% macro hk_ghost_default()%}
CAST((MD5_BINARY(NULLIF(UPPER(TRIM(CAST('{{ var('bk_ghost') }}' AS VARCHAR))), ''))) AS BINARY(16))
{%- endmacro %}