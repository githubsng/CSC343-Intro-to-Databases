#!/usr/bin/env bash

USER=$(whoami)
DB=csc343h-${USER}
SOLUTIONDIR=solution
SCHEMAFILE=schema.ddl
DATASETDIR=datasets
QUERYDIR=queries
echo "SQL Tester: Creating solutions (this may take some time)"
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
echo "SQL Tester: Testing student files"
python3 sql_tester.py ${DB} ${USER}
echo "SQL Tester: Testing done, see result.txt file for details"
echo "SQL Tester: Cleaning up"
for datafile in ${SOLUTIONDIR}/${DATASETDIR}/*; do
	dataname=$(basename -s .sql ${datafile})
	&> /dev/null psql -U ${USER} -d ${DB} <<-EOF
		DROP SCHEMA IF EXISTS ${dataname} CASCADE;
	EOF
done
