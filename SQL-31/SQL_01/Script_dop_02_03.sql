SELECT table_name, constraint_name 
FROM information_schema.table_constraints
WHERE constraint_schema = 'public' AND constraint_type = 'PRIMARY KEY'

SELECT constr.table_name, constr.constraint_name, cols.data_type
FROM information_schema.table_constraints constr, information_schema.columns cols, information_schema.key_column_usage kcu 
WHERE constr.constraint_schema = 'public' AND constr.constraint_type = 'PRIMARY KEY'
AND constr.constraint_name = kcu.constraint_name 
AND kcu.column_name = cols.column_name 
