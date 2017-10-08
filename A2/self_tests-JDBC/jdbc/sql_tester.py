import os
import sys
import pprint
import psycopg2


class SQLTester:

    SCHEMA_FILE = 'schema.ddl'
    DATASET_DIR = 'datasets'
    QUERY_DIR = 'queries'

    def __init__(self, oracle_database, test_database, user_name, user_password, data_files, schema_name,
                 path_to_solution, output_filename='result.txt'):
        self.oracle_database = oracle_database
        self.test_database = test_database
        self.user_name = user_name
        self.user_password = user_password
        self.data_files = data_files
        self.schema_name = schema_name
        self.path_to_solution = path_to_solution
        self.output_filename = output_filename
        self.oracle_connection = None
        self.oracle_cursor = None
        self.test_connection = None
        self.test_cursor = None

    def init_db(self):
        self.oracle_connection = psycopg2.connect(database=self.oracle_database, user=self.user_name,
                                                  password=self.user_password)
        self.oracle_cursor = self.oracle_connection.cursor()
        self.test_connection = psycopg2.connect(database=self.test_database, user=self.user_name,
                                                password=self.user_password)
        self.test_cursor = self.test_connection.cursor()

    def close_db(self):
        if self.test_cursor:
            self.test_cursor.close()
        if self.test_connection:
            self.test_connection.close()
        if self.oracle_cursor:
            self.oracle_cursor.close()
        if self.oracle_connection:
            self.oracle_connection.close()

    def get_oracle_results(self, data_name, test_name):
        self.oracle_cursor.execute('SELECT * FROM %(schema)s.%(table)s',
                                   {'schema': psycopg2.extensions.AsIs(data_name),
                                    'table': psycopg2.extensions.AsIs('oracle_{}'.format(test_name))})
        self.oracle_connection.commit()
        oracle_results = self.oracle_cursor.fetchall()

        return oracle_results

    def set_test_schema(self, data_file):
        self.test_cursor.execute('DROP SCHEMA IF EXISTS %(schema)s CASCADE',
                                 {'schema': psycopg2.extensions.AsIs(self.schema_name)})
        self.test_cursor.execute('CREATE SCHEMA %(schema)s', {'schema': psycopg2.extensions.AsIs(self.schema_name)})
        self.test_cursor.execute('SET search_path TO %(schema)s',
                                 {'schema': psycopg2.extensions.AsIs(self.schema_name)})
        with open(os.path.join(self.path_to_solution, self.SCHEMA_FILE)) as schema_open:
            schema = schema_open.read()
            self.test_cursor.execute(schema)
        with open(os.path.join(self.path_to_solution, self.DATASET_DIR, data_file)) as data_open:
            data = data_open.read()
            self.test_cursor.execute(data)
        self.test_connection.commit()

    def get_test_results(self, sql_file):
        with open(sql_file) as sql_open:
            sql = sql_open.read()
            self.test_cursor.execute(sql)
            self.test_connection.commit()
            test_results = self.test_cursor.fetchall()

            return test_results

    def check_results(self, oracle_results, test_results):
        # check 1: column number, names/order and types
        oracle_columns = self.oracle_cursor.description
        test_columns = self.test_cursor.description
        oracle_num_columns = len(oracle_columns)
        test_num_columns = len(test_columns)
        if oracle_num_columns != test_num_columns:
            return 'Expected {} columns instead of {}'.format(oracle_num_columns, test_num_columns), 0, 'fail'
        for i, oracle_column in enumerate(oracle_columns):
            if test_columns[i].name != oracle_column.name:
                return "Expected column {} to have name '{}' instead of '{}'".format(i, oracle_column.name,
                                                                                     test_columns[i].name), 0, 'fail'
            if test_columns[i].type_code != oracle_column.type_code:  # strict type checking + compatible type checking
                if not oracle_results or not test_results or type(test_results[0][i]) is not type(oracle_results[0][i]):
                    return "The type of values in column '{}' does not match the expected type".format(
                           test_columns[i].name), 0, 'fail'
        # check 2: rows number and content/order
        oracle_num_results = len(oracle_results)
        test_num_results = len(test_results)
        if oracle_num_results != test_num_results:
            return 'Expected {} rows instead of {}'.format(oracle_num_results, test_num_results), 0, 'fail'
        for i, oracle_row in enumerate(oracle_results):
            if oracle_row != test_results[i]:
                return 'Expected row {} to be {} instead of {}'.format(i, oracle_row, test_results[i]), 0, 'fail'

        # all good
        return '', 1, 'pass'

    def print_result_file(self, output_open, test_name, message, oracle_results, test_results):
        output_open.write('{} - {}\n'.format(test_name, message))
        output_open.write(' Expected Columns:\n  {}\n'.format(pprint.pformat([column.name for column in
                                                                              self.oracle_cursor.description])))
        output_open.write(' Actual Columns:\n  {}\n'.format(pprint.pformat([column.name for column in
                                                                            self.test_cursor.description])))
        output_open.write(' Expected Rows:\n')
        for oracle_result in oracle_results:
            output_open.write('  {}\n'.format(pprint.pformat(oracle_result)))
        output_open.write(' Actual Rows:\n')
        for test_result in test_results:
            output_open.write('  {}\n'.format(pprint.pformat(test_result)))
        output_open.write('\n')

    def run(self):

        try:
            self.init_db()
            with open(self.output_filename, 'w') as output_open:
                for sql_file in self.data_files.keys():
                    test_name = sql_file.partition('.')[0]
                    for data_file in self.data_files[sql_file]:
                        data_name = data_file.partition('.')[0]
                        test_data_name = '{} + {}'.format(test_name, data_name)
                        if not os.path.isfile(sql_file):
                            self.print_result(name=test_data_name, input='', expected='',
                                              actual='File {} not found'.format(sql_file), marks=0, status='fail')
                            continue
                        try:
                            # drop + recreate test schema + dataset + fetch test results
                            self.set_test_schema(data_file=data_file)
                            test_results = self.get_test_results(sql_file=sql_file)
                            # fetch results from oracle
                            oracle_results = self.get_oracle_results(data_name=data_name, test_name=test_name)
                            # compare test results with oracle
                            result = self.check_results(oracle_results=oracle_results, test_results=test_results)
                            self.print_result(name=test_data_name, input='', expected='',
                                              actual=(result[0] if result[0] else 'All good'), marks=result[1],
                                              status=result[2])
                            self.print_result_file(output_open=output_open, test_name=test_data_name,
                                                   message=(result[0] if result[0] else 'All good'),
                                                   oracle_results=oracle_results, test_results=test_results)
                        except Exception as e:
                            self.oracle_connection.commit()
                            self.test_connection.commit()
                            self.print_result(name=test_data_name, input='', expected='', actual=str(e), marks=0,
                                              status='error')
        except Exception as e:
            self.print_result(name='All SQL tests', input='', expected='', actual=str(e), marks=0, status='error')
        finally:
            self.close_db()

    @staticmethod
    def print_result(name, input, expected, actual, marks, status):
        print('{}: {} - {}\n'.format(status, name, actual))


if __name__ == '__main__':

    PATH_TO_SOLUTION = 'solution'
    DATA_FILES = {'q1.sql': ['data1.sql'], 'q2.sql': ['data2.sql'], 'q3.sql': ['data3.sql'], 'q4.sql': ['data4.sql'],
                  'q5.sql': ['data5.sql'], 'q6.sql': ['data6.sql'], 'q7.sql': ['data7.sql'], 'q8.sql': ['data8.sql']}
    SCHEMA_NAME = 'bnb'
    DATABASE = sys.argv[1]
    USER = sys.argv[2]
    PASSWORD = None
    tester = SQLTester(oracle_database=DATABASE, test_database=DATABASE, user_name=USER, user_password=PASSWORD,
                       data_files=DATA_FILES, schema_name=SCHEMA_NAME, path_to_solution=PATH_TO_SOLUTION)
    tester.run()
