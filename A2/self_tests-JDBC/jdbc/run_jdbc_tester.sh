#!/usr/bin/env bash

USER=$(whoami)
DB=csc343h-${USER}
SOLUTIONDIR=solution
SCHEMAFILE=schema.ddl
DATASETDIR=datasets
QUERYDIR=queries
echo "JDBC Tester: Creating solutions (this may take some time)"
for datafile in ${SOLUTIONDIR}/${DATASETDIR}/*; do
	dataname=$(basename -s .sql ${datafile})
	&> /dev/null psql -U ${USER} -d ${DB} <<-EOF
		DROP SCHEMA IF EXISTS ${dataname} CASCADE;
		CREATE SCHEMA ${dataname};
	EOF
	echo "SET search_path TO ${dataname};" | cat - ${SOLUTIONDIR}/${SCHEMAFILE} > .temp.sql
	psql -U ${USER} -d ${DB} -f .temp.sql &> /dev/null
	echo "SET search_path TO ${dataname};" | cat - ${datafile} > .temp.sql
	psql -U ${USER} -d ${DB} -f .temp.sql &> /dev/null
	for queryfile in ${SOLUTIONDIR}/${QUERYDIR}/*; do
    	echo "SET search_path TO ${dataname};" | cat - ${queryfile} > .temp.sql
		psql -U ${USER} -d ${DB} -f .temp.sql &> /dev/null
	done
done
rm .temp.sql
echo "JDBC Tester: Testing student files"
python3 jdbc_tester.py ${DB} ${USER}
echo "JDBC Tester: Testing done, see result_jdbc.txt file for details"
echo "JDBC Tester: Cleaning up"
for datafile in ${SOLUTIONDIR}/${DATASETDIR}/*; do
	dataname=$(basename -s .sql ${datafile})
	&> /dev/null psql -U ${USER} -d ${DB} <<-EOF
		DROP SCHEMA IF EXISTS ${dataname} CASCADE;
	EOF
done
