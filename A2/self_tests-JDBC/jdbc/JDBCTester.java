import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;

public class JDBCTester {

	private String oracleDatabase;
	private String testDatabase;
	private String userName;
	private String userPassword;
	private String schemaName;

	private Assignment2Solution oracle;
	private Assignment2 test;

	private static void printResult(String name, String input, String expected, String actual, int marks, String status) {

		System.out.println(status + ": (java) " + name + " - " + actual);
	}

	private static void printResultFile(String testName, String message, String oracleResults, String testResults) {

		System.err.println("(java) " + testName + " - " + message);
		System.err.println(" Expected: " + oracleResults);
		System.err.println(" Actual: " + testResults + "\n");
	}

	public JDBCTester(String oracleDatabase, String testDatabase, String userName, String userPassword, String schemaName) {

		this.oracleDatabase = oracleDatabase;
		this.testDatabase = testDatabase;
		this.userName = userName;
		this.userPassword = userPassword;
		this.schemaName = schemaName;
	}

	private boolean initDB(String dataName) {

		try {
			this.oracle = new Assignment2Solution();
			this.test = new Assignment2();
			final String JDBC_PREAMBLE = "jdbc:postgresql://localhost:5432/";
			boolean testConnected = this.test.connectDB(JDBC_PREAMBLE + this.testDatabase, this.userName, this.userPassword);
			if (!testConnected || this.test.connection == null || !this.test.connection.isValid(0)) {
				JDBCTester.printResult("connectDB + " + dataName, "", "", "connectDB() failed", 0, "fail");
				return false;
			}
			JDBCTester.printResult("connectDB + " + dataName, "", "", "All good", 1, "pass");	
			return true;
		}
		catch (Exception e) {
			JDBCTester.printResult("connectDB + " + dataName, "", "", e.getMessage(), 0, "fail");
			return false;
		}
	}

	private void closeDB(String dataName) {

		try {
			boolean testDisconnected = this.test.disconnectDB();
			if (!testDisconnected || (this.test.connection != null && !this.test.connection.isClosed())) {
				JDBCTester.printResult("disconnectDB + " + dataName, "", "", "disconnectDB() failed", 0, "fail");
				return;
			}
			JDBCTester.printResult("disconnectDB + " + dataName, "", "", "All good", 1, "pass");
		}
		catch (Exception e) {
			JDBCTester.printResult("disconnectDB + " + dataName, "", "", e.getMessage(), 0, "fail");
		}
	}

	private void testHomeownerRecommendation(String testDataName) throws Exception {

		ArrayList testResult = this.test.homeownerRecommendation(4000);
		ArrayList oracleResult = this.oracle.homeownerRecommendation(4000);
		String message;
		int mark;
		String status;
		if (oracleResult.equals(testResult)) {
			message = "All good";
			mark = 1;
			status = "pass";
		}
		else {
			message = "homeownerRecommendation() output differs";
			mark = 0;
			status = "fail";
		}
		JDBCTester.printResult(testDataName, "", "", message, mark, status);
		JDBCTester.printResultFile(testDataName, message, Arrays.toString(oracleResult.toArray()), Arrays.toString(testResult.toArray()));
	}

	private void testBooking(String testDataName) throws Exception {

        SimpleDateFormat ft = new SimpleDateFormat("yyyy-MM-dd");
		boolean testBooked = this.test.booking(6000, ft.parse("2016-10-05"), 2, 120);
		boolean oracleBooked = this.oracle.booking(6000, ft.parse("2016-10-05"), 2, 120);
		String message;
		int mark;
		String status;
		if (oracleBooked == testBooked) {
			message = "All good";
			mark = 1;
			status = "pass";
		}
		else {
			message = "booking() output differs";
			mark = 0;
			status = "fail";
		}
		JDBCTester.printResult(testDataName, "", "", message, mark, status);
		JDBCTester.printResultFile(testDataName, message, String.valueOf(oracleBooked), String.valueOf(testBooked));
	}

	public void run(String dataFile, String testName) {

		String dataName = dataFile.split("\\.")[0];
		String testDataName = testName + " + " + dataName;
		if (!this.initDB(dataName)) {
			return;
		}
		try {
			switch (testName) {
				case "homeownerRecommendation":
					this.testHomeownerRecommendation(testDataName);
					break;
				case "booking":
					this.testBooking(testDataName);
					break;
			}
		}
		catch (Exception e) {
			JDBCTester.printResult(testDataName, "", "", e.getMessage(), 0, "error");
		}
		finally {
			this.closeDB(dataName);
		}
	}

	public static void main(String args[]) {

		final String DATABASE = args[0];
		final String USER = args[1];
		final String PASSWORD = args[2];
		final String SCHEMA_NAME = args[3];
		final String DATA_FILE = args[4];
		final String TEST_NAME = args[5];

		JDBCTester tester = new JDBCTester(DATABASE, DATABASE, USER, PASSWORD, SCHEMA_NAME);
		tester.run(DATA_FILE, TEST_NAME);
	}

}
