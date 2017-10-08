#!/usr/bin/env python3

import sys
import os
import subprocess
from sql_tester import SQLTester


class JDBCTester(SQLTester):

    def __init__(self, oracle_database, test_database, user_name, user_password, data_files, schema_name,
                 path_to_solution, java_files, java_classpath, need_oracle, output_filename='result_jdbc.txt'):
        super(JDBCTester, self).__init__(oracle_database, test_database, user_name, user_password, data_files,
                                         schema_name, path_to_solution, output_filename)
        self.java_files = java_files
        self.java_classpath = java_classpath
        self.need_oracle = need_oracle

    def init_java(self):
        shell_command = ['javac', '-cp', self.java_classpath, '{}.java'.format(self.__class__.__name__)]
        subprocess.run(shell_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True,
                               check=True)

    def run_java(self, data_file, test_name, output_open):
        shell_command = ['java', '-cp', self.java_classpath, self.__class__.__name__, self.test_database,
                         self.user_name, self.user_password, self.schema_name, data_file, test_name]
        java = subprocess.run(shell_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True,
                              check=True)
        print(java.stdout)
        output_open.write(java.stderr)

    def run(self):

        try:
            for java_file in self.java_files:
                if not os.path.isfile(java_file):
                    self.print_result(name='All JDBC tests', input='', expected='',
                                      actual='File {} not found'.format(java_file), marks=0, status='fail')
                    return
            self.init_java()
            self.init_db()
            with open(self.output_filename, 'w') as output_open:
                for test_name in self.data_files.keys():
                    for data_file in self.data_files[test_name]:
                        data_name = data_file.partition('.')[0]
                        test_data_name = '{} + {}'.format(test_name, data_name)
                        try:
                            # drop + recreate test schema + dataset + fetch test results
                            self.set_test_schema(data_file=data_file)
                            self.run_java(data_file=data_file, test_name=test_name, output_open=output_open)
                            if not self.need_oracle[test_name]:
                                continue
                            sql_file = os.path.join(self.path_to_solution, self.QUERY_DIR,
                                                    '{}_select.sql'.format(test_name))
                            test_results = self.get_test_results(sql_file=sql_file)
                            # fetch results from oracle
                            oracle_results = self.get_oracle_results(data_name=data_name, test_name=test_name)
                            # compare test results with oracle
                            result = self.check_results(oracle_results=oracle_results, test_results=test_results)
                            self.print_result(name=test_data_name, input='', expected='',
                                              actual=result[0] if result[0] else 'All good', marks=result[1],
                                              status=result[2])
                            self.print_result_file(output_open=output_open, test_name=test_data_name,
                                                   message=(result[0] if result[0] else 'All good'),
                                                   oracle_results=oracle_results, test_results=test_results)
                        except subprocess.CalledProcessError as e:
                            self.oracle_connection.commit()
                            self.test_connection.commit()
                            msg = 'Java error\nstdout: {stdout}\nstderr: {stderr}'.format(stdout=e.stdout,
                                                                                          stderr=e.stderr)
                            self.print_result(name=test_data_name, input='', expected='', actual=msg, marks=0,
                                              status='error')
                        except Exception as e:
                            self.oracle_connection.commit()
                            self.test_connection.commit()
                            self.print_result(name=test_data_name, input='', expected='', actual=str(e), marks=0,
                                              status='error')
        except subprocess.CalledProcessError as e:
            msg = 'Java compilation error\nstdout: {stdout}\nstderr: {stderr}'.format(stdout=e.stdout, stderr=e.stderr)
            self.print_result(name='All JDBC tests', input='', expected='', actual=msg, marks=0, status='error')
        except Exception as e:
            self.print_result(name='All JDBC tests', input='', expected='', actual=str(e), marks=0, status='error')
        finally:
            self.close_db()

if __name__ == '__main__':

    PATH_TO_SOLUTION = 'solution'
    DATA_FILES = {'homeownerRecommendation': ['datahr.sql'], 'booking': ['datab.sql']}
    SCHEMA_NAME = 'bnb'
    DATABASE = sys.argv[1]
    USER = sys.argv[2]
    PASSWORD = ''

    JAVA_FILES = ['Assignment2.java']
    JAVA_CLASSPATH = '.:./{}:/local/packages/jdbc-postgresql/postgresql-9.4.1212.jar'.format(PATH_TO_SOLUTION)
    NEED_ORACLE = {'homeownerRecommendation': False, 'booking': True}
    tester = JDBCTester(oracle_database=DATABASE, test_database=DATABASE, user_name=USER, user_password=PASSWORD,
                        data_files=DATA_FILES, schema_name=SCHEMA_NAME, path_to_solution=PATH_TO_SOLUTION,
                        java_files=JAVA_FILES, java_classpath=JAVA_CLASSPATH, need_oracle=NEED_ORACLE)
    tester.run()
