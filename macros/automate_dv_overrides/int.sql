{%- macro int(models) -%}
{%- set model = models[0] %}
{%- set desc = model['description'] %}
{%- set src = desc.split('source:')[1] %}
{%- set table = src.split()[0] %}
{%- set constraints = model['constraints'] %}
SELECT  
    {%- set columns = model['columns'] %}
    {%- for column in columns %}
    {%- set column_description = column['description'] %}
    {%- set column_name = column['name'] %}
    {%- if 'source' in column_description %}
    {%- set col_source = column_description.split(':')[1]%}
    {%- else %}
    {%- set col_source = table + '.' + column_name %}
    {%- endif %}
    {{col_source}} as {{ column_name}}{{ ", " if not loop.last else "" }}

    {%- endfor %}
from 
    {{ ref(table) }}
    {%- for constraint in constraints| selectattr('type','equalto', 'foreign_key') %}
    left join 
        {%- set expression = constraint['expression'] %}  
        {%- set no_schema = expression.split('.')[1] %}
        {%- set table_name = no_schema.split('(')[0]|trim %}
        {{ ref(table_name)}}
        on 
            {{table}}.{{ constraint['columns'][0]}} = {{table_name}}.{{no_schema.split('(')[1].split(',')[0]}}
    {%- endfor %}
{%- endmacro -%}