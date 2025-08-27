#! /usr/bin/env python
#
import os
import sqlite3

db_file          = 'example_lmt.db'
table_name       = 'alma' 
selected_columns = 'proposal_id, obsnum, processing_level, is_combined, ref_id'



try:
    database_file = os.environ['WORK_LMT'] + '/' + db_file
    print("# columns:  ",selected_columns)
    print("# database: ",database_file)
    with sqlite3.connect(database_file) as conn:
        cursor = conn.cursor()

        # Construct the SQL query
        sql_query = f"SELECT {selected_columns} FROM {table_name}"

        # Execute the query
        cursor.execute(sql_query)

        # Fetch all rows
        rows = cursor.fetchall()

        # Print the selected columns from all rows
        for row in rows:
            print(*row)

except sqlite3.Error as e:
    print(f"An error occurred: {e}")



