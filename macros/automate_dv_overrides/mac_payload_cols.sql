{%- macro mac_payload_cols(
    pPayload
) -%}
    {%- for col in pPayload %}
        {{ col}},
    {%- endfor %}
{%- endmacro %}