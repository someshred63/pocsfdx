public class BankcheckWrapper {
    
    public Long ItemReferenceId {get;set;} 
    public String CreatedDate {get;set;} 
    public String ErrorMessage {get;set;} 
    public Integer VerificationResponse {get;set;} 
    public Integer AccountResponseCode {get;set;} 
    public String BankName {get;set;} 
    public String AccountAddedDate {get;set;} 
    public String AccountLastUpdatedDate {get;set;} 
    public Date AccountClosedDate {get;set;} 
    public String BankAccountType {get;set;} 
    public Boolean VoidedCheckImage {get;set;} 
    public String FundsConfirmationResult {get;set;} 
    public Integer CustomerResponseCode {get;set;} 
    public String MatchedPersonData {get;set;} 
    public String ConsumerAlertMessages {get;set;} 
    public String MatchedBusinessData {get;set;} 
    public String OfacListPotentialMatches {get;set;} 
    public String GIdentifyKbaResult {get;set;} 
    public String EmailAddressInformationResult {get;set;} 
    public String IpAddressInformationResult {get;set;} 
    public String DomainRegistry {get;set;} 
    public String MobileVerifyResult {get;set;} 
    public String MobileIdentifyResult {get;set;} 
    public String MobileLocationResult {get;set;} 
    public String PhoneIntelligenceResult {get;set;}
    
    public static BankcheckWrapper parse(String json) {
        return (BankcheckWrapper) System.JSON.deserialize(json, BankcheckWrapper.class);
    } 
}