public class Roster_JSON {

   public String responseStatus;
    public ResponseDetails responseDetails;
    public List<Data> data;

    public class ResponseDetails {
        public String pagesize;
        public String pageoffset;
        public String size;
        public String total;
        public Boolean nextPage;
        public String nextPagePath;
    }

    public class Data {
        public String EMPLOYEE_IDENTIFIER;
        public String LOGIN_ID;
        public String FIRST_NAME;
        public String LAST_NAME;
        public String EMAIL_ADDRESS;
        public List<String> FIELD_ECOSYSTEM_NAME;
        public List<String> FIELD_ECOSYSTEM_ID;
        public List<String> FIELD_TEAM;
        public List<String> FIELD_THEREPAUTIC_AREA;
        public String STATE;
        public List<String> EMPLOYEE_STATUS_CODE;
        public Datetime EMPLOYEE_LAST_UPDATE_DATE;
        public List<Employee_Assignment> Employee_Assignment;
    }

    public class Employee_Assignment {
        public String Field_Title_Code;
        public String Field_Title_Description;
        public String Field_Area_Code;
        public String Field_Area_Name;
        public String Field_Force;
        public String Assignment_Type;
        public String Assignment_start_date;
        public String Assignment_end_date;
        public String Status;
        public String Assignment_Modifiled_date;
        public String Region;
        public String Id;
    }

    
    public static Roster_JSON parse(String json) {
        return (Roster_JSON) System.JSON.deserialize(json, Roster_JSON.class);
    }
}