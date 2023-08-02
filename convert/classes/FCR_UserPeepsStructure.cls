public class FCR_UserPeepsStructure {
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
    private List<FCR_UserPeepsStructure> employees; 
    public FCR_UserPeepsStructure manager;
    private static Boolean isSandbox;
    
    static {
        isSandbox = isSandboxEnv();
    }
    
    public FCR_UserPeepsStructure() {}
    
    public FCR_UserPeepsStructure(FCR_Peep_gne__c peep) {
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
        this.googleId = peep.Google_Id_gne__c;
    }
    
    public static FCR_Peep_gne__c createPeepEntry(FCR_UserPeepsStructure peep) {
        FCR_Peep_gne__c result = new FCR_Peep_gne__c();
        result.UserUnixId__c = peep.userId;
        result.Department_Code_gne__c = peep.departmentCode;
        result.Department_Name_gne__c = peep.departmentName;
        result.Email_gne__c = (isSandbox && peep.email != null) ? peep.email +'.sandbox' : peep.email;
        result.Employment_Type_gne__c = peep.employmentType;
        result.First_Name_gne__c = peep.firstName;
        result.Full_Name_gne__c = peep.fullName;
        result.Job_Title_gne__c = peep.jobTitle;
        result.Last_Name_gne__c = peep.lastName;
        result.Location_gne__c = peep.location;
        result.Location_Id_gne__c = peep.locationCD;
        result.Manager_gne__c = peep.managerUnixId;
        result.Phone_Number_gne__c = peep.phoneNumber;
        result.Mobile_Phone_Number_gne__c = peep.mobilePhoneNumber;
        result.Google_Id_gne__c = peep.googleId;
        
        return result;
    }
    
    private static Boolean isSandboxEnv() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}