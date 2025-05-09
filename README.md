# Database
# **_Important indication to read:_**
### To write the code in sql from the desing in draw.io there are some precautions to keep in mind:
- User in Sql can't be used as a table name, so I changed the table name with **_app_user_**;
- Order in Sql can't be used as a table name, so I changed the table name with **_order_table_**;
- Sql transform all the word in lower case, unless you put " ", but you have to do it in all the file, so all the table from draw.io will change tha name for example from ProductVariant to product_variant;
- I changed the product_variant table so now if a product doesn't have a variant at DEFAULT has the value 'default', so we don't need no more to have both product_id and variant_id as foreign key in the other table to compensate if the product doesn't have a variant beacuse now all the product have a default variant;
