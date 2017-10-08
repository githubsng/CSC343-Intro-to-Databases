import java.sql.*;
import java.util.Date;
import java.text.SimpleDateFormat;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not received a high mark.  
import java.util.ArrayList; 
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

public class Assignment2 {

   // A connection to the database
   Connection connection;

   Assignment2() {}

  /**
   * Connects and sets the search path.
   *
   * Establishes a connection to be used for this session, assigning it to
   * the instance variable 'connection'.  In addition, sets the search
   * path to bnb.
   *
   * @param  url       the url for the database
   * @param  username  the username to connect to the database
   * @param  password  the password to connect to the database
   * @return           true if connecting is successful, false otherwise
   */
   public boolean connectDB(String URL, String username, String password) {

      try {
          Class.forName("org.postgresql.Driver");
      } catch (ClassNotFoundException e) {
          System.out.println("Failed to find the JDBC driver");
      }

      try {
          connection = DriverManager.getConnection(URL, username, password);
          String set_path = "SET search_path TO bnb, public;";
          PreparedStatement prepared_statement = connection.prepareStatement(set_path);
          prepared_statement.execute();
          return true;
      } catch (SQLException e) {
          e.printStackTrace();
          return false;
      }
   }


  /**
   * Closes the database connection.
   *
   * @return true if the closing was successful, false otherwise
   */
   public boolean disconnectDB() {

      try {
          connection.close();
          return true;
      } catch (SQLException e) { 
          e.printStackTrace();
          return false;
      }
   }


   /**
    * Returns the 10 most similar homeowners based on traveller reviews. 
    *
    * Does so by using Cosine Similarity: the dot product between the columns
    * representing different homeowners. If there is a tie for the 10th 
    * homeowner (only the 10th), more than 10 records may be returned. 
    *
    * @param  homeownerID   id of the homeowner
    * @return               a list of the 10 most similar homeowners
    */
    // public HashMap homeownerRecommendation(int homeownerID) {
    public ArrayList homeownerRecommendation(int homeownerID) {
        
        
        ArrayList<Integer> recommendedList = new ArrayList<Integer>();
        ArrayList<Integer> recommendedListScores = new ArrayList<Integer>();

        try{
            
            // Check if the homeowner exists in the TravelerRating and Listing tables
            String firstcheck = "SELECT Listing.owner FROM TravelerRating, Listing"+
                                " WHERE TravelerRating.listingId = Listing.listingId"+
                                " AND Listing.owner = ?"+";";

            String drop = "DROP VIEW IF EXISTS rating2, rating, homeowners, average, travelers CASCADE;";

            String q1 = "CREATE VIEW travelers AS"+
                        " SELECT Traveler.TravelerId, Booking.listingId, Booking.startDate" +
                        " FROM Traveler LEFT OUTER JOIN Booking ON Traveler.travelerID=Booking.travelerId"+
                        " ORDER BY traveler.travelerID;";

            String q2 = "CREATE VIEW average AS"+
                        " SELECT Travelers.TravelerId, travelers.listingId, avg(coalesce(TravelerRating.rating,0)) AS avg"+
                        " FROM Travelers LEFT OUTER JOIN TravelerRating ON TravelerRating.listingID=Travelers.listingId AND Travelers.startDate = TravelerRating.startDate"+
                        " GROUP BY Travelers.travelerID, travelers.listingId"+
                        " ORDER BY travelers.travelerID;";
 
            String q3 = "CREATE VIEW homeowners AS"+
                        " SELECT homeowner.homeownerid,listing.listingid FROM homeowner LEFT OUTER JOIN"+
                        " Listing ON listing.owner = homeowner.homeownerid"+
                        " GROUP BY homeowner.homeownerid, listing.listingid;";

            String q4 = "CREATE VIEW rating AS"+
                        " SELECT homeowners.homeownerid,average.travelerid,coalesce(average.avg,0)::float as avg"+
                        " FROM homeowners LEFT OUTER JOIN average ON homeowners.listingid = average.listingid"+
                        " GROUP BY homeowners.homeownerid,average.travelerid,average.avg;";

            String q5 = "CREATE VIEW rating2 AS "+
                        "SELECT"+
                        " R1.homeownerid AS R1homeownerid,"+
                        " R1.travelerid AS R1travelerid,"+
                        " R1.avg AS R1avg,"+
                        " R2.homeownerid AS R2homeownerid,"+
                        " R2.travelerid AS R2travelerid,"+
                        " R2.avg AS R2avg,"+
                        " (R1.avg * R2.avg) AS multiplier"+
                        " FROM Rating R1, Rating R2"+
                        " WHERE R1.homeownerid <> R2.homeownerid"+
                        " AND R1.travelerid = R2.travelerid;";

            String q6 = " SELECT R1homeownerid, R2homeownerid, sum(multiplier) as scores"+
                        " FROM rating2"+
                        " WHERE R1homeownerid = ?"+
                        " GROUP BY R1homeownerid, R2homeownerid"+
                        " ORDER BY sum(multiplier) DESC, R2homeownerid ASC;";
            
            // Execute first check to see if homeowner even exists
            PreparedStatement ps = connection.prepareStatement(firstcheck);
                ps.setInt(1, homeownerID);
            
            ResultSet rs = ps.executeQuery();

            // If homeowner does not exist in listing or travelerRating tables
            // return null
            if (!rs.isBeforeFirst() ) {    
                // System.out.println("Owner does not exist or have any ratings.");
                return null;
            } 

            // Execute recommended homeowner queries
            Statement st = connection.createStatement();
                st.executeUpdate(drop);
                st.executeUpdate(q1);
                st.executeUpdate(q2);
                st.executeUpdate(q3);
                st.executeUpdate(q4);
                st.executeUpdate(q5);

            PreparedStatement ps2 = connection.prepareStatement(q6);
                ps2.setInt(1, homeownerID);
 
            ResultSet rs2 = ps2.executeQuery();
            
            // If homeowner inputted is the only rated homeowner in travelerratings
            if (!rs2.isBeforeFirst() ) {    
                // System.out.println("There are no other homeowners to compare.");
                return null;
            } 
            
            // limit recommended list to 10 and include ties, if any
            int count = 0;

            while(rs2.next()){
                
                //grab values from q6
                int recHomeowners = rs2.getInt("R2homeownerid");
                int recHomeownerScore = rs2.getInt("scores");
                
                // Do not add homeowners with scores of 0
                if (recHomeownerScore == 0) {
                    break;
                }
                
                // Keep adding to the recommendedList if count is under 10
                if (count < 10) {
                    recommendedList.add(recHomeowners);
                    recommendedListScores.add(recHomeownerScore);
                } else {
                    int lastHomeownerScore = recommendedListScores.get(recommendedListScores.size() - 1);
                    if (lastHomeownerScore == recHomeownerScore) {
                        recommendedList.add(recHomeowners);
                        recommendedListScores.add(recHomeownerScore);
                    } else {
                        break;
                    }
                }
                count++;
            }

            // System.out.println(recommendedList);
            // System.out.println(recommendedListScores);
            return recommendedList;
                                           
        } catch (SQLException s){                                 
            System.err.println("SQL Exception caught: " + s.getMessage());
            return null; 
        }
        
 }



   /**
    * Records the fact that a booking request has been accepted by a 
    * homeowner. 
    *
    * If a booking request was made and the corresponding booking has not been
    * recorded, records it by adding a row to the Booking table, and returns 
    * true. Otherwise, returns false. 
    *
    * @param  requestID  id of the booking request
    * @param  start      start date for the booking
    * @param  numNights  number of nights booked
    * @param  price      amount paid to the homeowner
    * @return            true if the operation was successful, false otherwise
    */
    public boolean booking(int requestId, Date start, int numNights, int price) {
        
        // Convert Date start from a Java.Util.Date objec to a Java.Sql.Date object for setDate()
        java.sql.Date sqlStartDate = new java.sql.Date(start.getTime());

        // Check if the inputted request even exists in the booking request table first
        String checkInBookRequest = "SELECT * FROM BookingRequest "+
                                    "WHERE BookingRequest.requestId = ?"+
                                    " AND BookingRequest.startdate = ?"+
                                    " AND BookingRequest.numNights = ?"+
                                    " AND BookingRequest.offerPrice = ?"+";";

        // Check if request is already in the booking table
        String checkInBooking = "SELECT * FROM Booking, BookingRequest "+
                                "WHERE Booking.listingID = BookingRequest.listingID"+
                                " AND BookingRequest.requestId = ?"+
                                " AND Booking.startdate = BookingRequest.startdate"+
                                " AND BookingRequest.startDate = ?"+
                                " AND Booking.numNights = BookingRequest.numNights"+
                                " AND BookingRequest.numNights = ?"+
                                " AND Booking.price = BookingRequest.offerPrice"+
                                " AND BookingRequest.offerPrice= ?"+";";

        // Insert into Booking table if request has not been recorded
        String insertInBooking = "INSERT INTO Booking VALUES (?, ?, ?, ?, ?, ?);";

        try {
            
            // Execute first check      
            PreparedStatement ps = connection.prepareStatement(checkInBookRequest);
                ps.setInt(1, requestId);
                ps.setDate(2, sqlStartDate);
                ps.setInt(3, numNights);
                ps.setInt(4, price); 
               
            
            ResultSet rs = ps.executeQuery();

            // First check, does request even exist in the bookingrequest table
            if (!rs.isBeforeFirst() ) {    
                System.out.println("This request does not exist in the booking request table.");
                return false;
            } 
            // If result set is not empty, go to second check
            while(rs.next()){
                                     
                // Get the listing ID from the first resultset
                int rsTravelerId = rs.getInt("travelerId");
                int rsListingId = rs.getInt("listingid");
                int rsnumGuests = rs.getInt("numGuests");

                // Second check, see if request is already in the booking table
                PreparedStatement ps2 = connection.prepareStatement(checkInBooking);
                    ps2.setInt(1, requestId);
                    ps2.setDate(2, sqlStartDate);
                    ps2.setInt(3, numNights);
                    ps2.setInt(4, price);  

                ResultSet rs2 = ps2.executeQuery();

                // If booking request is not already recorded, insert it 
                if (!rs2.isBeforeFirst() ) {    
                    
                    PreparedStatement ps3 = connection.prepareStatement(insertInBooking);
                        ps3.setInt(1, rsListingId);
                        ps3.setDate(2, sqlStartDate);
                        ps3.setInt(3, rsTravelerId);
                        ps3.setInt(4, numNights);  
                        ps3.setInt(5, rsnumGuests);
                        ps3.setInt(6, price);
                        ps3.executeUpdate();
                    return true;
                } 

                // booking request has already been recorded, return true
                while(rs2.next()){
                    System.out.println("Booking request is already recorded in Bookings!");
                    return true;
                }

            }
            return true;

        } catch (SQLException s){
            System.err.println("SQL Exception caught: " + s.getMessage());
        }
        System.out.println("Operation failed");
        return false;
   }



   public static void main(String[] args) {
    /* 
    You can put testing code in here. It will not affect our autotester.
        Note to self: to run this program: 
        'javac Assignment2.java' 
        'java -cp /local/packages/jdbc-postgresql/postgresql-9.4.1212.jar: Assignment2'
    */
        try {
            Assignment2 a2 = new Assignment2();
            String url = "jdbc:postgresql://localhost:5432/csc343h-ngsunny";
            a2.connectDB(url,"ngsunny","");

            // a2.homeownerRecommendation(4000);
            // SimpleDateFormat ft = new SimpleDateFormat ("yyyy-MM-dd");
            // a2.booking(6000, ft.parse("2016-10-05"), 2, 120);

            a2.disconnectDB();
        } catch(Exception e) {   
            e.printStackTrace();
        }      
    }

}
