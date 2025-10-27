{%- macro mac_payload(
    pPayload
) -%}
    {%- for col in pPayload %}
        {{ col }}{%- if not loop.last %},{% endif -%}
    {%- endfor %}
{%- endmacro %}