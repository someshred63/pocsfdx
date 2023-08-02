@RestResource(urlMapping='/FCR/getUserDetails/*')
global class FCR_Get_PeepUserDetails {

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId) {
        return iPhone_Commons_gne.buildResponse(
            new GetUserPeepsStructureResponseBuilder(),
            new RequestArgs(lastSyncDate,  unixId )
            
        );
    }
    
    class GetUserPeepsStructureResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args) {
            RequestArgs reqArgs = (RequestArgs)args;
            UserPeepsStructure ups;
            UserPeepsStructure[] employees = new UserPeepsStructure[]{};
            for(FCR_Peep_gne__c peep:[
                SELECT UserUnixId__c, Department_Code_gne__c, Department_Name_gne__c, Email_gne__c, Employment_Type_gne__c, First_Name_gne__c, Full_Name_gne__c, Job_Title_gne__c, 
                	Last_Name_gne__c, Location_gne__c, Location_Id_gne__c, Manager_gne__c, LastMOdifiedDate, CreatedDate, Mobile_Phone_Number_gne__c, Phone_Number_gne__c
                FROM FCR_Peep_gne__c 
                WHERE UserUnixId__c =:reqArgs.unixId OR Manager_gne__c = :reqArgs.unixId
            ]) {                
                if(peep.UserUnixId__c == reqArgs.unixId) {
                    ups = new UserPeepsStructure(peep);
                } else {
                    employees.add(new UserPeepsStructure(peep));
                }
            }
            ups.employees = new List<UserPeepsStructure>();
            ups.employees.addAll(employees);
            ups.manager = getManager(ups);

            
            return new DeltaRecordsResponse(ups);
        }
        
        private UserPeepsStructure getManager(UserPeepsStructure currentUps) {
            UserPeepsStructure manager;
            if(currentUps.managerUnixId != null) {
                for(FCR_Peep_gne__c peep: [
                    SELECT UserUnixId__c, Department_Code_gne__c, Department_Name_gne__c, Email_gne__c, Employment_Type_gne__c, First_Name_gne__c, Full_Name_gne__c, Job_Title_gne__c, 
                    	Last_Name_gne__c, Location_gne__c, Location_Id_gne__c, Manager_gne__c, LastMOdifiedDate, CreatedDate, Mobile_Phone_Number_gne__c, Phone_Number_gne__c 
                    FROM FCR_Peep_gne__c 
                    WHERE UserUnixId__c = :currentUps.managerUnixId
                ]) {
                    manager = new UserPeepsStructure(peep);
                }
            }
            
            return manager;
        }      
	}
    
    public class UserPeepsStructure {
		public String departmentCode;
		public String departmentName;
		public String email;
		public String employmentType;
		public String firstName;
		public String fullName;
		public String googleId;
		public String jobTitle;
		public String labNumber;
		public String lastName;
		public String location;
		public String locationCD;
		public String mailStop;
		public String managerUnixId;
		public String mobilePhoneNumber;
		public String odgName;
		public String odgNumber;
		public String phoneNumber;
		public String photoEtag;
		public String roomNumber;
		public String salutation;
		public String street;
		public String userId;  
        public String lastModified;
        private List<UserPeepsStructure> employees; 
        public UserPeepsStructure manager;
        
        public UserPeepsStructure() {
            
        }
        
        public UserPeepsStructure(FCR_Peep_gne__c peep) {
            this.userId = peep.UserUnixId__c;
            this.departmentCode = peep.Department_Code_gne__c;
            this.departmentName = peep.Department_Name_gne__c;
            this.email = peep.Email_gne__c;
            this.employmentType = peep.Employment_Type_gne__c;
            this.firstName = peep.First_Name_gne__c;
            this.fullName = peep.Full_Name_gne__c;
            this.jobTitle = peep.Job_Title_gne__c;
            this.lastName = peep.Last_Name_gne__c;
            this.location = peep.Location_gne__c;
            this.locationCD = peep.Location_Id_gne__c;
            this.managerUnixId = peep.Manager_gne__c;
            this.phoneNumber = peep.Phone_Number_gne__c;
            this.mobilePhoneNumber = peep.Mobile_Phone_Number_gne__c;
            this.lastModified = String.valueOf(peep.LastModifiedDate);
        }
    }
    
    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
        public RequestArgs(String lastSyncDate, String unixId) {
            super(lastSyncDate, unixId, null, null, null);
        }               
    }    
    
    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public UserPeepsStructure peepsUser;
        public DeltaRecordsResponse(UserPeepsStructure peepsUser) {
            this.peepsUser = peepsUser;           
        }
    }
}