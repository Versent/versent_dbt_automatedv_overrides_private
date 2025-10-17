{% macro hk_ghost(column_name) -%}
coalesce (
    {{column_name}},
    {{ hk_ghost_default()}}
    ) as {{ column_name }}
{%- endmacro %}

{% macro hk_ghost_default()%}
    {{ automate_dv.hash("'ghost'", 'hk_ghost')}}
{%- endmacro %}