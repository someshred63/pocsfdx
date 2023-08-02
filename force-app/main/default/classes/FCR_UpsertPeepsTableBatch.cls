public class FCR_UpsertPeepsTableBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts{
    private Set<Id> updatedRecords;
    private static List<FCR_PeepTriggerHandlerLogic.PeepChanges> toSharingManage = new List<FCR_PeepTriggerHandlerLogic.PeepChanges>();
    private Datetime startProcessDT;
    private static Boolean isSandbox;
    
    static {
        isSandbox = isSandboxEnv();
    }
    
    public FCR_UpsertPeepsTableBatch() {
        this.updatedRecords = new Set<Id>();
        startProcessDT = System.now();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Map<Id, Profile> Id2Proflie = new Map<Id,profile>([
            SELECT Id, UserLicenseId
            FROM Profile
            WHERE UserLicenseId IN (SELECT Id FROM UserLicense WHERE name IN ('Salesforce','Salesforce Platform'))]);
        Set<Id> profileIds = Id2Proflie.keySet();
        return Database.getQueryLocator(
            'SELECT Id, External_Id_gne__c '+
			' FROM User '+
			' WHERE ProfileId IN (SELECT Id FROM Profile WHERE (NOT Name LIKE \'RCanada%\') )'+
            '     AND profileId IN : profileIds  '+
			'     AND isActive = true '+
            ' ORDER BY External_Id_gne__c '
        );
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<String, String> exterlanlId2Id = fetchExistingUser(scope);
        Map<String, FCR_Peep_gne__c> toUpsert = new Map<String, FCR_Peep_gne__c>();

        for(GNE_SFA2_Peeps_API_Engine.UserRecord ur:GNE_SFA2_Peeps_API_Engine.getPeepsDetails(exterlanlId2Id.keySet()).values()) {
            toUpsert.put(ur.userId, createPeepEntry(ur));
        }
        
        for(FCR_Peep_gne__c peep :[SELECT UserUnixId__c, Manager_gne__c FROM FCR_Peep_gne__c WHERE UserUnixId__c IN :toUpsert.keySet()]) {
            FCR_Peep_gne__c existingPeep = toUpsert.get(peep.UserUnixId__c) != null ? toUpsert.get(peep.UserUnixId__c) : null;
            if(existingPeep != null) {
                if(existingPeep.Manager_gne__c != null &&  peep.Manager_gne__c != existingPeep.Manager_gne__c ) {
                    toSharingManage.add(new FCR_PeepTriggerHandlerLogic.PeepChanges(peep, existingPeep) );
                }
            }
        }
        
        Database.upsert(toUpsert.values(), FCR_Peep_gne__c.UserUnixId__c, true);        
    }
    
    private FCR_Peep_gne__c createPeepEntry(GNE_SFA2_Peeps_API_Engine.UserRecord peep) {
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
    
    private Map<String, String> fetchExistingUser(List<sObject> scope) {
        Map<String, String> exterlanlId2Id = new Map<String, String>();
        for(User u : (List<User>)scope) {
            exterlanlId2Id.put(u.External_Id_gne__c, u.Id);
        }
        
        return exterlanlId2Id;
    }
    
    public void finish(Database.BatchableContext BC) {
        if(!toSharingManage.isEmpty() ) DataBase.executeBatch(new FCR_ManageSharingOnVisitsByPeepsBatch(startProcessDT, toSharingManage), 10);
        else DataBase.executeBatch(new FCR_DeletePeepsBatch(startProcessDT));
    }    
    
    public void execute(SchedulableContext sc) {
        FCR_UpsertPeepsTableBatch job = new FCR_UpsertPeepsTableBatch();
        Database.executeBatch(job, 100);
    }    
    
    private static Boolean isSandboxEnv() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}