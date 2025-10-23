{%- macro mac_payload(
    pPayload
) -%}
    {%- for col in pPayload %}
        {%- set derivation = pPayload[col] %}
        {{ derivation ~ " as " ~ col if derivation is not none else col}}{%- if not loop.last %},{% endif -%}
    {%- endfor %}
{%- endmacro %}