/**
 *  Modification History
 *  Date            Name                Description
 *  30.06.14        Lukasz Bieniawski   logic rebuilded, new methods added
 *  29.12.15        Piotr Przesmycki    fixed dates to make multiple year scenario determined
 *  2018-05-18      Jaroslaw Laniecki   Update API version to 40 + fix test data preparation seeAllData = false
 */
 
@isTest
private class GNE_SFA2_TimeOffTerritory_Test {
    private static Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
    /* NOTE: Primary-Care profiles do not exist */    
    private static String PROFILE_MEDAFFAIRS_TEST = 'GNE-MedAffairs-MSL';
    private static String PROFILE_SFA_TEST = 'GNE-Field';
    private static String PROFILE_MCCO_TEST = 'GNE-Field';
    
    private static String REASON_PICKLIST_VALUE = 'Holiday';
    
    static testMethod void testCreateSFATotUnexpectedError(){
        TotInputs inputs = new TotInputs(PROFILE_SFA_TEST, Date.newInstance(System.today().year(), 1, 1), Date.newInstance(System.today().year(), 1, 3), REASON_PICKLIST_VALUE);
        inputs.symulateUnexpectedError = true;
        User testUser = GNE_FRM_TestUtilities.createUser('ActemraCS', ids2ProfilesMap.get(PROFILE_SFA_TEST), true);
        System.runAs(testUser){         
            createTotUnsuccessPath(inputs);
        }
    }
    
    static testMethod void testCreateMedAffairsTot(){
        TotInputs inputs = new TotInputs(PROFILE_MEDAFFAIRS_TEST, Date.newInstance(System.today().year(), 1, 1), Date.newInstance(System.today().year(), 1, 3), REASON_PICKLIST_VALUE);
        User testUser = getUser(inputs.profileNameContext);
        System.runAs(testUser){         
            createTotSuccessPath(inputs);            
        }
    } 
    
    static testMethod void testCreateMedAffairsTotAllFailures(){
        TotInputs inputs = new TotInputs(PROFILE_MEDAFFAIRS_TEST, null, null, null);
        inputs.enableReferralAssignment = null;
        User testUser = getUser(inputs.profileNameContext);
        System.runAs(testUser){
            createTotUnsuccessPath(inputs);
        }
    }
    
    static testMethod void testCreateMedAffairsTotDateDaysFailure(){
        TotInputs inputs = new TotInputs(PROFILE_MEDAFFAIRS_TEST, Date.newInstance(System.today().year(), 1, 3), Date.newInstance(System.today().year(), 1, 1), REASON_PICKLIST_VALUE);
        User testUser = getUser(inputs.profileNameContext);
        System.runAs(testUser){                     
            createTotUnsuccessPath(inputs);
        }
    }
    
    static testMethod void testCreateMedAffairsTotDateYearFailure(){
        TotInputs inputs = new TotInputs(PROFILE_MEDAFFAIRS_TEST, Date.newInstance(System.today().year(), 1, 1), Date.newInstance(System.today().year() + 1, 1, 3), REASON_PICKLIST_VALUE);
        User testUser = getUser(inputs.profileNameContext);
        System.runAs(testUser){                     
            createTotUnsuccessPath(inputs);
        }
    }
    
    static testMethod void testCreateMedAffairsTotWithAssignmentFailure(){     
        TotInputs inputs = new TotInputs(PROFILE_MEDAFFAIRS_TEST, Date.newInstance(System.today().year(), 1, 1), Date.newInstance(System.today().year(), 1, 3), REASON_PICKLIST_VALUE);
        inputs.enableReferralAssignment = true;
        User testUser = getUser(inputs.profileNameContext);
        System.runAs(testUser){
            createTotUnsuccessPath(inputs);
        }
    }
    
    static testMethod void testCreateMedAffairsTotWithAssignmentUserFailure(){     
        TotInputs inputs = new TotInputs(PROFILE_MEDAFFAIRS_TEST, Date.newInstance(System.today().year(), 1, 1), Date.newInstance(System.today().year(), 1, 3), REASON_PICKLIST_VALUE);
        inputs.enableReferralAssignment = true;     
        User testUser = getUser(inputs.profileNameContext);        
        System.runAs(testUser){
            inputs.assignedReferralSearchId = UserInfo.getUserId();
            createTotUnsuccessPath(inputs);
        }
    }
    
    static testMethod void testCreateMedAffairsTotWithAssignmentSuccess(){     
        TotInputs inputs = new TotInputs(PROFILE_MEDAFFAIRS_TEST, Date.newInstance(System.today().year(), 1, 1), Date.newInstance(System.today().year(), 1, 3), REASON_PICKLIST_VALUE);
        inputs.enableReferralAssignment = true;
        inputs.assignUser = true;
        User testUser = getUser(inputs.profileNameContext);
        User userToAssign = getUser(inputs.profileNameContext, 1);            
        insert userToAssign;
        System.runAs(testUser){
            createTotSuccessPath(inputs);
        }
    }
    
    static testMethod void testCancelMethodMedAffairs(){
        TotInputs inputs = new TotInputs(PROFILE_MEDAFFAIRS_TEST, Date.newInstance(System.today().year(), 1, 1), Date.newInstance(System.today().year(), 1, 3), REASON_PICKLIST_VALUE);
        User testUser = getUser(inputs.profileNameContext);
        System.runAs(testUser){
            cancelMethodPath(inputs);
        }
    }
    
    static void createTotSuccessPath(TotInputs inputs){
        Integer daysBetween = initializeWorkingDays(inputs.startDate, inputs.dueDate);        
        GNE_SFA2_TimeOffTerritory_Create_Ext cont = initializeController(inputs);
        PageReference pr = cont.createTOT();
        System.assert(true, pr != null && pr.getUrl().startsWith(new ApexPages.StandardController(cont.tot).view().getUrl()));        
        System.assert(true, cont.tot.Id != null);
        Integer totdCount = [Select Count() From Time_off_Territory_Day_gne__c Where Time_Off_Territory_gne__c = :cont.tot.id];
        System.assertEquals(daysBetween, totdCount);        
        System.assertEquals(inputs.reason, cont.tot.Description_gne__c);
        if (inputs.assignUser == true || String.isNotBlank(inputs.assignedReferralSearchId) || inputs.enableReferralAssignment == true){
            String assignedUserQuery = 'Select Id From User Where Id = \'' + inputs.assignedReferralSearchId + '\' And ' + cont.assignedUserLookupFilter;           
            List<User> result = Database.query(assignedUserQuery);
            System.assertEquals(1, result.size());
            System.assertEquals(inputs.assignedReferralSearchId, cont.tot.Assigned_Referral_Activity_gne__c);
        }
    }
    
    static void createTotUnsuccessPath(TotInputs inputs){
        Integer daysBetween = initializeWorkingDays(inputs.startDate, inputs.dueDate);
        GNE_SFA2_TimeOffTerritory_Create_Ext cont = initializeController(inputs);
        PageReference pr = cont.createTOT();
        System.assertEquals(null, pr);
        System.assert(true, inputs.symulateUnexpectedError == true ? cont.tot == null : cont.tot.Id == null);
        System.assert(true, ApexPages.hasMessages());
    }
    
    static Integer initializeWorkingDays(Date startDate, Date dueDate){
        if (startDate == null || dueDate == null){
            return -1;
        }
        Integer daysBetween = startDate.daysBetween(dueDate);
        List<Actual_Working_Days_gne__c> awdList = new List<Actual_Working_Days_gne__c>();
        Date sDate = startDate;
        for (Integer i = 0; i < daysBetween; i++){          
            awdList.add(
                new Actual_Working_Days_gne__c(
                    Date_gne__c = sDate
                )
            );
            sDate.addDays(1);
        }
        insert awdList;
        return daysBetween;
    }
    
    static GNE_SFA2_TimeOffTerritory_Create_Ext initializeController(TotInputs inputs){
        GNE_SFA2_TimeOffTerritory_Create_Ext cont = new GNE_SFA2_TimeOffTerritory_Create_Ext(
            new ApexPages.StandardController(new Time_Off_Territory_gne__c())
        );
        cont.from_totd.Date_gne__c = inputs.startDate;
        cont.to_totd.Date_gne__c = inputs.dueDate;
        if (inputs.enableReferralAssignment != null){
            cont.enableReferralAssignment = inputs.enableReferralAssignment == true ? 'Yes' : 'No';
        } else {
            cont.enableReferralAssignment = null;
        }       
        if (inputs.profileNameContext == PROFILE_MEDAFFAIRS_TEST){
            cont.from_totd.Reason_MedAffair_gne__c = inputs.reason;
        } else if (inputs.profileNameContext == PROFILE_MCCO_TEST){
            cont.from_totd.Reason_MCCO_gne__c = inputs.reason;
        } else {
            cont.from_totd.Reason_SFA_gne__c = inputs.reason;
        }
        cont.assignedReferralSearchId = inputs.assignedReferralSearchId; 
        if (inputs.assignUser == true){
            User userToAssign = [SELECT Id FROm User WHERE UserName LIKE 'u_1GNE-MedAffairs-MSL%'];
            
            inputs.assignedReferralSearchId = userToAssign.Id;
            cont.assignedReferralSearchId = inputs.assignedReferralSearchId; 
        }
        if (inputs.symulateUnexpectedError == true){
            cont.tot = null;            
        }        
        return cont;        
    }
    
    static void cancelMethodPath(TotInputs inputs){      
        GNE_SFA2_TimeOffTerritory_Create_Ext cont = initializeController(inputs);
        
        String retUrlDefault = Page.GNE_SFA2_MyAccounts.getUrl();
        String redirected = cont.cancel().getUrl();        
        System.assert(true, redirected.startsWith(retUrlDefault));
                
        String retUrl = Page.GNE_SFA2_MyContacts.getUrl();
        ApexPages.currentPage().getParameters().put('retURL', retUrl);
        redirected = cont.cancel().getUrl();
        System.assert(true, redirected.startsWith(retUrl));
    }
    
    static User getUser(String profileName){
        return getUser(profileName, 0);
    }
    
    static User getUser(String profileName, Integer createdUserIndex){
        Profile p = [Select Id From Profile Where Name = :profileName];     
        User user = new User(
            Alias = 'testUser',
            Email = 'testUser@gene.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'u_' + createdUserIndex + profileName + '@gene.com'
        );         
        System.debug(user);
        return user;
    }
    
    private class TotInputs{
        public String profileNameContext { get; private set; }
        public Date startDate { get; private set; }
        public Date dueDate { get; private set; }
        public String reason { get; private set; }  
        public Boolean enableReferralAssignment { get; set; }
        public String assignedReferralSearchId { get; set; }
        public Boolean assignUser { get; set; }
        public Boolean symulateUnexpectedError { get; set; }
        
        public TotInputs(String profileNameContext, Date startDate, Date dueDate, String reason){
            this.profileNameContext = profileNameContext;
            this.startDate = startDate;
            this.dueDate = dueDate;
            this.reason = reason;
            this.enableReferralAssignment = false;
            this.assignUser = false;
            this.symulateUnexpectedError = false;
        }
    }
}