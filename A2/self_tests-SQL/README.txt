Please always use the last version of the self tester.
 
Instructions:
1. Copy and unzip the file to your home directory on dbsrv1.
2. Put your .sql solution files into the folder, they must be named q1.sql to q8.sql.
3. Run ./run_sql_tester.sh to have your queries evaluated. 
 
Some advice:
- Do not assume the real solutions look like the ones in the solution folder, those are just hardcoded.
- Be nice with the server resources, i.e. do not run it more than say 5 times a day and be sure to be ready in advance of the deadline, when server usage increases dramatically. 
- Be careful about the type of returned attributes by your queries. Auto tester gives you feedback on that. 
For instance, if you use extract function to get the year of a date, sql returns the year with type double and the tester might not accept that. 
