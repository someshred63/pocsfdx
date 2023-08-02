public with sharing class CFAR_TestUtils {
    
    public static final String GFRS_PROFILE = 'GNE-GFRS-User';
    public static final String AVERAGE_USER_PROFILE = 'GNE-CFAR-User-New';
    public static final String ADMIN_PROFILE = 'GNE-CFAR-Admin-New';
    public static final String IT_ADMIN_PROFILE = 'GNE-CFAR-IT-Admin-New';
    public static final String READ_ONLY_USER_PROFILE = 'GNE-CFAR-ReadOnlyUser-New';

    public static final Map<String, String> profileNameToAlias = new Map<String, String> {
            AVERAGE_USER_PROFILE => 'testAvg',
            ADMIN_PROFILE => 'testAdm',
            IT_ADMIN_PROFILE => 'testITAd',
            READ_ONLY_USER_PROFILE => 'testRO'
    };
    
    public static final String MSL_PS = 'CFAR_MSL2';
    
    public static Set<String> envsSet = new Set<String>{'.dev', '.aggs', '.sqa', '.uat', '.gstars', '.ma'};
    
    public static String getCurrentEnv() {
        String currentEnv = '';
        String username = UserInfo.getUserName().toLowerCase();
        for (String env : envsSet) {
            if (username.endsWith(env)) {
                currentEnv = env;
                break;
            }
        }
        return currentEnv;
    }

    public static User createTestAverageUser() {
        System.debug('inside createTestAvgUser before invoke');
        return createUser(AVERAGE_USER_PROFILE, 'testAvg', 'AverageUser');
    }
    
    public static User createTestAdminUser() {
        return createUser(ADMIN_PROFILE, 'testAdm', 'Admin');
    }
    
    public static User createTestITAdminUser() {
        return createUser(IT_ADMIN_PROFILE, 'testITAd', 'ITAdmin');
    }
    
    public static User createTestReadOnlyUser() {
        return createUser(READ_ONLY_USER_PROFILE, 'testRO', 'ReadOnlyUser');
    }


    
    public static User createTestMSLUser() {
        User usr = createGFRSUser();
        Id MSL2PermSetId = [select Id from PermissionSet where Name = :MSL_PS limit 1][0].Id;
        if (MSL2PermSetId != null && usr.Id != null) {
            PermissionSetAssignment psaToInsert = new PermissionSetAssignment(PermissionSetId = MSL2PermSetId, AssigneeId = usr.Id);
            insert psaToInsert;
        }
        else {
            return null;
        }
        return usr;
    }
    
    public static User createGFRSUser() {
        return createUser(GFRS_PROFILE, 'testGFRS', 'GFRSUser');
    }
    
    public static User createUser(String profileName, String unixId, String lastName) {
        System.debug('inside createTestAvgUser before role retrieval');
        String roleId = [select Id from UserRole where Name = 'Standard User' limit 1][0].Id;
        System.debug('inside createTestAvgUser before profile retrieval');
        String profileid = [select Id from Profile where Name = :profileName limit 1][0].Id;
        System.debug('inside createTestAvgUser before currenv');
        String currentEnv = getCurrentEnv();
        User usr = new User(
                        alias = unixId,                       
                        emailencodingkey = 'UTF-8', 
                        languagelocalekey = 'en_US', 
                        localesidkey = 'en_US', 
                        timezonesidkey = 'America/Los_Angeles', 
                        email = unixId + '@gene.com',
                        lastname = lastName, 
                        firstname = 'UnitTest',                                                                          
                        username = unixId + '@gene.com' + currentEnv,
                        federationidentifier = unixId + '@gene.com' + currentEnv,
                        userroleid = roleId,
                        profileid = profileId,
                        isActive = true
                    );
        insert usr;
        return usr;
    }

    public static List<User> createProfileUsers(List<String> profiles) {
        String roleId = [select Id from UserRole where Name = 'Standard User' limit 1][0].Id;
        List<User> usersList = new List<User>();
        String currentEnv = getCurrentEnv();

        for (Profile prof : [select Id, Name from Profile where Name in :profiles]) {
            System.debug('check pralinka');
            User usr = new User(
                    alias = profileNameToAlias.get(prof.Name),
                    emailencodingkey = 'UTF-8',
                    languagelocalekey = 'en_US',
                    localesidkey = 'en_US',
                    timezonesidkey = 'America/Los_Angeles',
                    email = profileNameToAlias.get(prof.Name) + '@gene.com',
                    lastname = profileNameToAlias.get(prof.Name),
                    firstname = 'UnitTest',
                    username = profileNameToAlias.get(prof.Name) + '@gene.com' + currentEnv,
                    federationidentifier = profileNameToAlias.get(prof.Name) + '@gene.com' + currentEnv,
                    userroleid = roleId,
                    profileid = prof.Id,
                    isActive = true
            );
            usersList.add(usr);
        }
        insert usersList;
        return usersList;
    }
    
    public static CFAR_Contact_gne__c createTestPrimaryContact() {
        CFAR_Contact_gne__c pc = new CFAR_Contact_gne__c(First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'PrimaryContact', Primary_Role_Function_gne__c = 'CSA = Clinical Study Associate', Active_Date_gne__c = System.today());
        insert pc;
        return pc;
    }
    
    public static CFAR_Contact_gne__c createTestInvestigator() {
        CFAR_Contact_gne__c inv = new CFAR_Contact_gne__c(First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'Investigator', Primary_Role_Function_gne__c = 'PI = Primary (or Principal) Investigator', Active_Date_gne__c = System.today());
        insert inv;
        return inv;
    }
    
    public static CFAR_Contact_gne__c createTestMSL() {
        CFAR_Contact_gne__c msl = new CFAR_Contact_gne__c(First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'MSL', Primary_Role_Function_gne__c = 'MSL = Medical Science Liaison', Active_Date_gne__c = System.today());
        insert msl;
        return msl;
    }
    
    public static CFAR_Contact_gne__c createTestAdminContact() {
    	CFAR_Contact_gne__c adm = new CFAR_Contact_gne__c(First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'Admin', Primary_Role_Function_gne__c = 'ADMIN = Administrator', Active_Date_gne__c = System.today());
        insert adm;
        return adm;
    }
    
    public static CFAR_Contact_gne__c createTestITAdminContact() {
    	CFAR_Contact_gne__c itadm = new CFAR_Contact_gne__c(First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'ITAdmin', Primary_Role_Function_gne__c = 'ITADMIN = IT Administrator', Active_Date_gne__c = System.today());
        insert itadm;
        return itadm;
    }
    
    public static CFAR_Contact_gne__c createTestReadOnlyContact() {
    	CFAR_Contact_gne__c ro = new CFAR_Contact_gne__c(First_Name_gne__c = 'UnitTest', Last_Name_gne__c = 'ReadOnly', Primary_Role_Function_gne__c = 'PMD = Product Medical Director', Active_Date_gne__c = System.today());
        insert ro;
        return ro;
    }
    
    public static CFAR_Contact_gne__c createTestContactForUser(User usr, String primaryRole) {
    	CFAR_Contact_gne__c cnt = new CFAR_Contact_gne__c(First_Name_gne__c = usr.FirstName, Last_Name_gne__c = usr.LastName, Primary_Role_Function_gne__c = primaryRole, Active_Date_gne__c = System.today(), User_ref_gne__c = usr.Id);
    	insert cnt;
    	return cnt;
    }

    public static CFAR_Parent_Organization_gne__c createTestParentOrganization(){
        CFAR_Parent_Organization_gne__c po = new CFAR_Parent_Organization_gne__c(Name = 'Test Organization',Active_gne__c = true);
        insert po;
        return po;
    }

    public static CFAR_Institution_gne__c createTestInstitution(){
        CFAR_Parent_Organization_gne__c po = createTestParentOrganization();
        CFAR_Institution_gne__c inst = new CFAR_Institution_gne__c(Name = 'Test Institution',Active_gne__c = true,Parent_Organization__c = po.Id);
        insert inst;
        return inst;
    }    

    public static CFAR_Trial_gne__c createTestTrial2() {
        CFAR_Picklist_Value_gne__c srt = CFAR_TestUtils.createPicklistValue(new List<String>{'test'}, 'SRT Team')[0];
        CFAR_Trial_gne__c trial = new CFAR_Trial_gne__c(
            Product_ref_gne__c = [select Id from CFAR_Product_gne__c where Name = 'Accutane' limit 1][0].Id,
            Trial_Type_ref_gne__c = [select Id from CFAR_Trial_Type_gne__c where Name = 'Collaborative Study' limit 1][0].Id,
            Genentech_Primary_Contact_ref_gne__c = createTestPrimaryContact().Id,
            Therapeutic_Area_ref_gne__c = [select Id from CFAR_Therapeutic_Area_gne__c where Name = 'BioOncology' limit 1][0].Id,
            Study_Phase_gne__c = 'Phase I',
            Subject_Type__c = 'Animal',
            SRT_Team_ref_gne__c = srt.id,
            Trial_Status_ref_gne__c = [select Id from CFAR_Trial_Status_gne__c where Name = 'Follow-up' limit 1][0].Id,
            CFAR_General_Indication_ref_gne__c = [select Id from CFAR_General_Indication_gne__c where Name = 'Aerodigestive Tract' limit 1][0].Id,
            CFAR_Specific_Indication_ref_gne__c = [select Id from CFAR_Specific_Indication_gne__c where Name = 'Aerodigestive Tract' limit 1][0].Id,
            Planned_Enrollment_gne__c = 1,
            IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-11111',
            Investigator_ref_gne__c = createTestInvestigator().Id,
            MSL_ref_gne__c = createTestMSL().Id,
            Received_Date_gne__c = System.today()
        );
        insert trial;
        return trial;
    }

	public static CFAR_Trial_gne__c createTestTrial() {
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, 5);
    	CFAR_Product_gne__c product = new CFAR_Product_gne__c();
    	product.Name =  'Accutane';
        product.Generic_Name_gne__c = 'generic';
        product.Abbreviation_gne__c = 'ACC';
    	insert product;
    	CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
    	trialType.Name = 'Collaborative Study';
    	insert trialType;
    	CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
    	area.Name = 'BioOncology';
    	insert area;
    	CFAR_Trial_Status_gne__c trialStatus = new CFAR_Trial_Status_gne__c();
    	trialStatus.Name = 'Follow-up';
    	insert trialStatus;
    	CFAR_General_Indication_gne__c indication = new CFAR_General_Indication_gne__c();
    	indication.name = 'Aerodigestive Tract';
    	insert indication;
    	CFAR_Specific_Indication_gne__c specIndication = new CFAR_Specific_Indication_gne__c();
    	specIndication.Name = 'Aerodigestive Tract';
    	insert specIndication;

        CFAR_Picklist_Value_gne__c srt = CFAR_TestUtils.createPicklistValue(new List<String>{'test'}, 'SRT Team')[0];
        CFAR_Trial_gne__c trial = new CFAR_Trial_gne__c(
            Product_ref_gne__c = product.Id,
            Trial_Type_ref_gne__c = trialType.Id,
            Genentech_Primary_Contact_ref_gne__c = createTestPrimaryContact().Id,
            Therapeutic_Area_ref_gne__c = area.Id,
            Study_Phase_gne__c = 'Phase I',
                Study_Phase_Multi_gne__c = 'I',
            Subject_Type__c = 'Animal',
            SRT_Team_ref_gne__c = srt.Id,
            Trial_Status_ref_gne__c =trialStatus.Id,
            CFAR_General_Indication_ref_gne__c = indication.Id,
            CFAR_Specific_Indication_ref_gne__c = specIndication.Id,
            Planned_Enrollment_gne__c = 1000,
            IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-'+randomNumber,
            Investigator_ref_gne__c = createTestInvestigator().Id,
            MSL_ref_gne__c = createTestMSL().Id,
            Received_Date_gne__c = System.today()
        );
        System.debug('abc: ' + trial.IIS_Portal_RO_Number_gne__c);
        insert trial;
        return trial;
    }

    public static CFAR_Trial_gne__c createTestTrial3(String portalRONumber) {
        CFAR_Product_gne__c product = new CFAR_Product_gne__c();
        product.Name =  'Accutane';
        product.Generic_Name_gne__c = 'generic';
        product.Abbreviation_gne__c = 'ACC';
        insert product;
        CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
        trialType.Name = 'Collaborative Study';
        insert trialType;
        CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c();
        area.Name = 'BioOncology';
        insert area;
        CFAR_Trial_Status_gne__c trialStatus = new CFAR_Trial_Status_gne__c();
        trialStatus.Name = 'Follow-up';
        insert trialStatus;
        CFAR_General_Indication_gne__c indication = new CFAR_General_Indication_gne__c();
        indication.name = 'Aerodigestive Tract';
        insert indication;
        CFAR_Specific_Indication_gne__c specIndication = new CFAR_Specific_Indication_gne__c();
        specIndication.Name = 'Aerodigestive Tract';
        insert specIndication;
        CFAR_Picklist_Value_gne__c srt = CFAR_TestUtils.createPicklistValue(new List<String>{'test'}, 'SRT Team')[0];
        CFAR_Trial_gne__c trial = new CFAR_Trial_gne__c(
                Product_ref_gne__c = product.Id,
                Trial_Type_ref_gne__c = trialType.Id,
                Genentech_Primary_Contact_ref_gne__c = createTestPrimaryContact().Id,
                Therapeutic_Area_ref_gne__c = area.Id,
                Study_Phase_gne__c = 'Phase I',
                Study_Phase_Multi_gne__c = 'I',
                Subject_Type__c = 'Animal',
                SRT_Team_ref_gne__c = srt.id,
                Trial_Status_ref_gne__c = trialStatus.Id,
                CFAR_General_Indication_ref_gne__c = indication.Id,
                CFAR_Specific_Indication_ref_gne__c = specIndication.Id,
                Planned_Enrollment_gne__c = 1,
                IIS_Portal_RO_Number_gne__c = portalRONumber,
                Investigator_ref_gne__c = createTestInvestigator().Id,
                MSL_ref_gne__c = createTestMSL().Id,
                Received_Date_gne__c = System.today()
        );
        insert trial;
        return trial;
    }

    public static CFAR_Trial_gne__c setTrialStatus(CFAR_Trial_gne__c trial, String newStatus) {
        if(trial == null)
            return null;

        Boolean correctStatus = false;
        if(String.isNotBlank(newStatus)) {
            List<CFAR_Trial_Status_gne__c> trialStatuses = CFAR_DAO.getTrialStatuses(new CFAR_SearchParameters()); 
            for(CFAR_Trial_Status_gne__c status : trialStatuses) {
                if(newStatus.toLowerCase().equals(status.Name.toLowerCase())) {
                    trial.Trial_Status_ref_gne__c = status.Id;
                    correctStatus = true;
                    break;
                }
            }
        }

        if(!correctStatus)
            trial.Trial_Status_ref_gne__c = null;

        update trial;
        trial = refreshTrial(trial);
        return trial;   
    }



    public static CFAR_Comment_gne__c createComment(CFAR_Trial_gne__c trial, CFAR_Contact_gne__c cont, Date actDate, String comment) {
        if(trial == null)
            return null;
        CFAR_Contact_gne__c testContact = (cont == null) ? createTestPrimaryContact() : cont;
        //User testUser = (usr == null) ? createTestAverageUser() : usr;
        Date testDate = (actDate == null) ? Date.today() : actDate;
        CFAR_Comment_gne__c testComment = new CFAR_Comment_gne__c();
        testComment.Activity_Date_gne__c= testDate ; 
        testComment.CFAR_Trial_ref_gne__c = trial.Id;
        testComment.Comments_gne__c = comment;
        testComment.Created_By_CFAR_Contact_ref_gne__c = testContact.Id;
        testComment.Created_By_SFDC_User_ref_gne__c = UserInfo.getUserId();

        insert testComment;
        return testComment;
    }

    public static CFAR_Comment_gne__c createComment(CFAR_Trial_gne__c trial, Date actDate, String comment) {
        return createComment(trial, null, actDate, comment);
    }

    public static CFAR_Comment_gne__c createComment(CFAR_Trial_gne__c trial, String comment) { 
        return createComment(trial, null, comment);
    }

    public static CFAR_Trial_gne__c refreshTrial(CFAR_Trial_gne__c trial) {
        return [SELECT Number_Of_Months_Of_Enrollment__c, Dollar_and_Drug_ref_gne__c, Dollar_to_Drug_gne__c, CFAR_Actual_Centers_gne__c, Enrolled_Sum_rollup_gne__c, CFAR_Actual_Enrollment_gne__c, frm_Amendment_Amount_gne__c, Autonumber_gne__c, Baselined__c, Brief_Title_gne__c, CTMS_gne__c, Comments_Number_gne__c, Contract_End_Date_gne__c, Cost_Center_gne__c, Cost_Element_gne__c, CreatedById, CreatedDate, Current_Amount_gne__c, IsDeleted, Disease_Status_gne__c, Enrollment_Completed_Num_gne__c, Enrollment_Discontinued_Num_gne__c, CFAR_Enrollment_End_Date_gne__c, Enrollment_Enrolled_Num_gne__c, Enrollment_Last_Date_Rollup_gne__c, CFAR_Enrollment_Start_Date_gne__c, FPI_Actual_Date_gne__c, FSR_Required_gne__c, Final_Study_Report_Received_gne__c, Final_Study_Report_Received_Date_gne__c, Frozen_Accruals_JSON_gne__c, Genentech_Primary_Contact_ref_gne__c, frm_Genentech_Primary_Contact_ref_gne__c, CFAR_General_Indication_ref_gne__c, frm_General_Indication_ref_gne__c, General_Indication_Other_gne__c, IND_gne__c, IND_Exempt_Letter_Date_gne__c, IND_Required_gne__c, IRB_Closure_Letter_Received_gne__c, IRB_Closure_Received_Date_gne__c, IRB_Renewal_Date_gne__c, IRB_Required_gne__c, Non_Interventional_gne__c, Investigator_ref_gne__c, frm_Investigator_ref_gne__c, Investigator_City_gne__c, Investigator_Institution_Company_gne__c, Investigator_State_Province_gne__c, Is_Budget_Straight_Line__c, frm_Is_Closed_gne__c, IsLocked, LPI_Actual_Date_gne__c, LPO_Actual_Date_gne__c, Lab_Support_gne__c, Last_Amendment_Amount_gne__c, LastModifiedById, LastModifiedDate, Latest_Comment_Date_gne__c, MSL_ref_gne__c, frm_MSL_ref_gne__c, MayEdit, Milestones_Without_Actual_Date_gne__c, Next_Payment_Due_gne__c, frm_Orginal_Amount_gne__c, Original_Contract_Execution_Date_gne__c, Other_Agents_gne__c, Other_GNE_Agents_ref_gne__c, Other_GNE_Agents_Multi_gne__c, Other_Trial_gne_Id__c, OwnerId, Planned_Centers_gne__c, Planned_Enrollment_gne__c, Genentech_Primary_Contact_frm_gne__c, Prior_Years_Paid_gne__c, Priority_gne__c, Product_ref_gne__c, frm_Product_ref_gne__c, CFAR_Rate_of_Accrual_gne__c, Last_Re_Baseline_Time_gne__c, Received_Date_gne__c, Id, Regimen_gne__c, Regulatory_Document_Complete_Date_gne__c, Sample_Type_gne__c, CFAR_Specific_Indication_ref_gne__c, frm_Specific_Indication_ref_gne__c, Specific_Indication_Other_gne__c, Study_Closure_Letter_Received_gne__c, Study_Closure_Received_Date_gne__c, Study_Phase_gne__c, Subject_Type__c, Subject_Type_Other_gne__c, SystemModstamp, Theme_ref_gne__c, Therapeutic_Area_ref_gne__c, Therapy_Type_gne__c, Total_Paid_gne__c, Name, Trial_Status_ref_gne__c, frm_Trial_Status_ref_gne__c, Title_gne__c, Trial_Type_ref_gne__c, Trial_Type_gne__c, frm_Trial_Type_ref_gne__c, Type_of_Sample_ref_gne__c, Type_of_Sample_Other_gne__c, Vendor_gne__c, frm_CFAR_WBS_ref_gne__c, CFAR_WBS_ref_gne__c, WBS_was_set_before_gne__c, Year_to_Date_Paid_gne__c, Trial_Status_ref_gne__r.Name FROM CFAR_Trial_gne__c where id = :trial.Id];
    }

    public static void setActualDateForMilestones(CFAR_Trial_gne__c trial, Date actDate) {
        if(trial == null)
            return;
        List<CFAR_Milestone_Activity_gne__c> milestones = new List<CFAR_Milestone_Activity_gne__c>();            
        for(CFAR_Milestone_Activity_gne__c milestone : [SELECT Actual_Date_gne__c, Baselined_Date_gne__c, CFAR_Trial_ref_gne__c, Comments_gne__c, Name, Planned_Date_gne__c, Id FROM CFAR_Milestone_Activity_gne__c WHERE CFAR_Trial_ref_gne__c =: trial.Id]) {
            milestone.Actual_Date_gne__c = actDate;
            milestones.add(milestone);
        }
        update milestones;
    }

    public static CFAR_Regulatory_Document_Tracking_gne__c createRegDoc(CFAR_Trial_gne__c trial, String regDoc, Date expDate, Date recDate, Boolean doInsert) {
        if(trial == null)
            return null;
        List<CFAR_Tracking_Activity_gne__c> tActivities = [SELECT Active_gne__c, CreatedById, CreatedDate, IsDeleted, IsLocked, LastModifiedById, LastModifiedDate, MayEdit, OwnerId, Id, Name, SystemModstamp FROM CFAR_Tracking_Activity_gne__c WHERE Name = :regDoc];
        CFAR_Tracking_Activity_gne__c tActivitie;
        if(!tActivities.isEmpty()) 
            tActivitie = tActivities.get(0);
        else return null;

        CFAR_Regulatory_Document_Tracking_gne__c rdt = new CFAR_Regulatory_Document_Tracking_gne__c();
        rdt.Regulatory_Tracking_Activity_gne__c = tActivitie.Id;
        rdt.CFAR_Trial_gne__c = trial.Id;
        rdt.Expiry_Date_gne__c = expDate;
        rdt.Date_Received_gne__c = recDate;
        if(doInsert!=null && doInsert)
            insert rdt;
        return rdt;
    }

    public static sObject createRecord(Map<sObject, Map<String, object>> sObjectConfig)
    {
        sObject newRecord = null;
        for(sObject myObject : sObjectConfig.keySet())
        {
          Schema.SObjectType targetType = myObject.getSObjectType();
          newRecord = targetType.newSObject();
          for(String field : sObjectConfig.get(myObject).keySet())
          {
            object fieldValue = sObjectConfig.get(myObject).get(field);
            newRecord.put(field, fieldValue);
          }
        }
        return newRecord;
    }

    public static CFAR_Theme_gne__c createTheme(String themeNr, String themeName) {
        return createTheme(themeNr, themeName, true);
    }

    public static CFAR_Theme_gne__c createTheme(String themeNr, String themeName, Boolean active) {
        try {
            CFAR_Theme_gne__c theme = new CFAR_Theme_gne__c(Name = themeNr, Theme_Name_gne__c = themeName, Active_gne__c = active);
            insert theme;
            return theme;
        } catch(Exception ex) {
            return null;
        }
    }

    public static CFAR_Product_gne__c createProduct(String prodName, String abrev, String genName) {
        try {
            CFAR_Theme_gne__c theme = createTheme('12345', 'testTheme');
            if(theme == null)
                return null;
            CFAR_Product_gne__c prod = new CFAR_Product_gne__c(Name = prodName, Abbreviation_gne__c = abrev, Generic_Name_gne__c = genName, Theme_ref_gne__c = theme.Id, Active_gne__c = true, Other_GNE_Agent_Active_gne__c = true);
            insert prod;
            return prod;
        } catch(Exception ex) {
            return null;
        }
    }

    public static CFAR_General_Indication_gne__c createGeneralIndication(String indName) {
        try {
            CFAR_General_Indication_gne__c ind = new CFAR_General_Indication_gne__c(Name = indName);
            insert ind;
            return ind;
        } catch(Exception ex) {
            return null;
        }
    }

    public static CFAR_Specific_Indication_gne__c createSpecificIndication(String indName) {
        try {
            CFAR_Specific_Indication_gne__c ind = new CFAR_Specific_Indication_gne__c(Name = indName);
            insert ind;
            return ind;
        } catch(Exception ex) {
            return null;
        }
    }
    
    public static CFAR_Dollar_and_Drug_gne__c createDollarAndDrug(String name){
        CFAR_Dollar_and_Drug_gne__c gneSupport = new  CFAR_Dollar_and_Drug_gne__c(Active_gne__c = true, name = name);
        insert gneSupport;
        return gneSupport;
    }

    public static List<CFAR_Roles_To_Users_Mapping_gne__c> createRolesToUsersMapping() {
    	List<CFAR_Roles_To_Users_Mapping_gne__c> mapping = new List<CFAR_Roles_To_Users_Mapping_gne__c>();
    	CFAR_Roles_To_Users_Mapping_gne__c m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Name='MD'; 
    	m.Drop_down_value_gne__c='MD = Medical Director';
    	m.Role_Function_gne__c='Medical Director';
    	mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Name='PI';
		m.Drop_down_value_gne__c='PI = Primary (or Principal) Investigator';
		m.Role_Function_gne__c='Investigator';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Name='SC';
		m.Drop_down_value_gne__c='SC = Study Coordinator';
		m.Role_Function_gne__c='Study Coordinator';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-User';
		m.Name='CSM';
		m.Drop_down_value_gne__c='CSM = Clinical Study Manager';
		m.Role_Function_gne__c='Primary Contact';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-User';
		m.Name='CSA';
		m.Drop_down_value_gne__c='CSA = Clinical Study Associate';
		m.Role_Function_gne__c='Primary Contact';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-User';
		m.Name='CA';
		m.Drop_down_value_gne__c='CA = Clinical Assistant';
		m.Role_Function_gne__c='Primary Contact';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Name='Ph';
		m.Drop_down_value_gne__c='Ph = Pharmacist';
		m.Role_Function_gne__c='Pharmacist';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Name='Sub-I';
		m.Drop_down_value_gne__c='Sub-I = Sub-investigator';
		m.Role_Function_gne__c='Sub-investigator';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Name='Other-External';
		m.Drop_down_value_gne__c='Other-External';
		m.Role_Function_gne__c='Other';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
		m.Name='Other-Internal';
		m.Drop_down_value_gne__c='Other-Internal';
		m.Role_Function_gne__c='Other';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-User';
		m.Name='CPL';
		m.Drop_down_value_gne__c='CPL = Clinical Program Leader';
		m.Role_Function_gne__c='Primary Contact';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
		m.Name='MSL';
		m.Drop_down_value_gne__c='MSL = Medical Science Liaison';
		m.Role_Function_gne__c='Medical Science Liason';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
		m.Name='PMD';
		m.Drop_down_value_gne__c='PMD = Product Medical Director';
		m.Role_Function_gne__c='Read Only';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
		m.Name='MSD';
		m.Drop_down_value_gne__c='MSD = Medical Science Director';
		m.Role_Function_gne__c='Medical Science Liason';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
		m.Name='SRT';
		m.Drop_down_value_gne__c='SRT = Study Review Team Chair';
		m.Role_Function_gne__c='Read Only';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
		m.Name='CM';
		m.Drop_down_value_gne__c='CM = Contracts Manager';
		m.Role_Function_gne__c='Read Only';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
		m.Name='PEM';
		m.Drop_down_value_gne__c='PEM = Planning and Execution Manager';
		m.Role_Function_gne__c='Read Only';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-IT-Admin';
		m.Name='ITADMIN';
		m.Drop_down_value_gne__c='ITADMIN = IT Administrator';
		m.Role_Function_gne__c='IT Administrator';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-Admin';
		m.Name='ADMIN';
		m.Drop_down_value_gne__c='ADMIN = Administrator';
		m.Role_Function_gne__c='Administrator';
		mapping.add(m);
		m = new CFAR_Roles_To_Users_Mapping_gne__c();
    	m.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
		m.Name='FM';
		m.Drop_down_value_gne__c='FM = Finance Manager';
		m.Role_Function_gne__c='Read Only';
		mapping.add(m);    	
		
		insert mapping;
		return mapping;
    	
    }
    
    public static List<CFAR_Degree_gne__c> createDegrees() {
    	List<CFAR_Degree_gne__c> degrees = new List<CFAR_Degree_gne__c>();
    	degrees.add(new CFAR_Degree_gne__c(Name = 'MPH'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'BS'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'DVM'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'FACP'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'PharmD'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'MBA'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'RN'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'BA'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'RPh'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'MD'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'PhD'));
    	degrees.add(new CFAR_Degree_gne__c(Name = 'MS')); 
    	
    	insert degrees;
    	return degrees;   	
    }
    
    public static List<CFAR_Address_Type_gne__c> createAddressTypes() {
    	List<CFAR_Address_Type_gne__c> addressTypes = new List<CFAR_Address_Type_gne__c>();
    	addressTypes.add(new CFAR_Address_Type_gne__c(Name = 'Fedex Delivery'));
    	addressTypes.add(new CFAR_Address_Type_gne__c(Name = 'Drug Shipment Location'));
    	addressTypes.add(new CFAR_Address_Type_gne__c(Name = 'Business'));
    	addressTypes.add(new CFAR_Address_Type_gne__c(Name = 'Residential'));
    	addressTypes.add(new CFAR_Address_Type_gne__c(Name = 'Site'));
    	
    	insert addressTypes;
    	return addressTypes;
    }
    
    public static List<CFAR_Countries_gne__c> createCountries() {
    	List<CFAR_Countries_gne__c> countries = new List<CFAR_Countries_gne__c>();
    	countries.add(new CFAR_Countries_gne__c(Name = 'Portugal', Country_Name_gne__c = 'Portugal'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Taiwan', Country_Name_gne__c = 'Taiwan'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Saudi Arabia', Country_Name_gne__c = 'Saudi Arabia'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Hong Kong', Country_Name_gne__c = 'Hong Kong'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Ecuador', Country_Name_gne__c = 'Ecuador'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Greece', Country_Name_gne__c = 'Greece'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Phillipines', Country_Name_gne__c = 'Phillipines'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Thailand', Country_Name_gne__c = 'Thailand'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Spain', Country_Name_gne__c = 'Spain'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Ukraine', Country_Name_gne__c = 'Ukraine'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Ireland', Country_Name_gne__c = 'Ireland'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Chile', Country_Name_gne__c = 'Chile'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Israel', Country_Name_gne__c = 'Israel'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Switzerland', Country_Name_gne__c = 'Switzerland'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Italy', Country_Name_gne__c = 'Italy'));
		countries.add(new CFAR_Countries_gne__c(Name = 'India', Country_Name_gne__c = 'India'));
		countries.add(new CFAR_Countries_gne__c(Name = 'France', Country_Name_gne__c = 'France'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Malaysia', Country_Name_gne__c = 'Malaysia'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Denmark', Country_Name_gne__c = 'Denmark'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Australia', Country_Name_gne__c = 'Australia'));
		countries.add(new CFAR_Countries_gne__c(Name = 'South Africa', Country_Name_gne__c = 'South Africa'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Netherlands', Country_Name_gne__c = 'Netherlands'));
		countries.add(new CFAR_Countries_gne__c(Name = 'China', Country_Name_gne__c = 'China'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Finland', Country_Name_gne__c = 'Finland'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Turkey', Country_Name_gne__c = 'Turkey'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Austria', Country_Name_gne__c = 'Austria'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Korea', Country_Name_gne__c = 'Korea'));
		countries.add(new CFAR_Countries_gne__c(Name = 'United Kingdom', Country_Name_gne__c = 'United Kingdom'));
		countries.add(new CFAR_Countries_gne__c(Name = 'USA', Country_Name_gne__c = 'USA'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Bahamas', Country_Name_gne__c = 'Bahamas'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Armenia', Country_Name_gne__c = 'Armenia'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Mexico', Country_Name_gne__c = 'Mexico'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Canada', Country_Name_gne__c = 'Canada'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Argentina', Country_Name_gne__c = 'Argentina'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Brazil', Country_Name_gne__c = 'Brazil'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Belgium', Country_Name_gne__c = 'Belgium'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Venezuela', Country_Name_gne__c = 'Venezuela'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Russia', Country_Name_gne__c = 'Russia'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Germany', Country_Name_gne__c = 'Germany'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Norway', Country_Name_gne__c = 'Norway'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Japan', Country_Name_gne__c = 'Japan'));
		countries.add(new CFAR_Countries_gne__c(Name = 'New Zealand', Country_Name_gne__c = 'New Zealand'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Sweden', Country_Name_gne__c = 'Sweden'));
		countries.add(new CFAR_Countries_gne__c(Name = 'South Korea', Country_Name_gne__c = 'South Korea'));
		countries.add(new CFAR_Countries_gne__c(Name = 'Puerto Rico', Country_Name_gne__c = 'Puerto Rico'));
		
		insert countries;
		return countries;
    }
    
    public static List<CFAR_States_gne__c> createStates() {
    	List<CFAR_States_gne__c> states = new List<CFAR_States_gne__c>();
    	states.add(new CFAR_States_gne__c(Name = 'Nebraska', State_Name_gne__c = 'Nebraska'));
		states.add(new CFAR_States_gne__c(Name = 'Alabama', State_Name_gne__c = 'Alabama'));
		states.add(new CFAR_States_gne__c(Name = 'Indiana', State_Name_gne__c = 'Indiana'));
		states.add(new CFAR_States_gne__c(Name = 'South Carolina', State_Name_gne__c = 'South Carolina'));
		states.add(new CFAR_States_gne__c(Name = 'Alaska', State_Name_gne__c = 'Alaska'));
		states.add(new CFAR_States_gne__c(Name = 'Arizona', State_Name_gne__c = 'Arizona'));
		states.add(new CFAR_States_gne__c(Name = 'Arkansas', State_Name_gne__c = 'Arkansas'));
		states.add(new CFAR_States_gne__c(Name = 'California', State_Name_gne__c = 'California'));
		states.add(new CFAR_States_gne__c(Name = 'Colorado', State_Name_gne__c = 'Colorado'));
		states.add(new CFAR_States_gne__c(Name = 'Connecticut', State_Name_gne__c = 'Connecticut'));
		states.add(new CFAR_States_gne__c(Name = 'Delaware', State_Name_gne__c = 'Delaware'));
		states.add(new CFAR_States_gne__c(Name = 'Florida', State_Name_gne__c = 'Florida'));
		states.add(new CFAR_States_gne__c(Name = 'Georgia', State_Name_gne__c = 'Georgia'));
		states.add(new CFAR_States_gne__c(Name = 'Hawaii', State_Name_gne__c = 'Hawaii'));
		states.add(new CFAR_States_gne__c(Name = 'Idaho', State_Name_gne__c = 'Idaho'));
		states.add(new CFAR_States_gne__c(Name = 'Illinois', State_Name_gne__c = 'Illinois'));
		states.add(new CFAR_States_gne__c(Name = 'Iowa', State_Name_gne__c = 'Iowa'));
		states.add(new CFAR_States_gne__c(Name = 'Kansas', State_Name_gne__c = 'Kansas'));
		states.add(new CFAR_States_gne__c(Name = 'Kentucky', State_Name_gne__c = 'Kentucky'));
		states.add(new CFAR_States_gne__c(Name = 'Louisiana', State_Name_gne__c = 'Louisiana'));
		states.add(new CFAR_States_gne__c(Name = 'Maine', State_Name_gne__c = 'Maine'));
		states.add(new CFAR_States_gne__c(Name = 'Maryland', State_Name_gne__c = 'Maryland'));
		states.add(new CFAR_States_gne__c(Name = 'Massachusetts', State_Name_gne__c = 'Massachusetts'));
		states.add(new CFAR_States_gne__c(Name = 'Michigan', State_Name_gne__c = 'Michigan'));
		states.add(new CFAR_States_gne__c(Name = 'Minnesota', State_Name_gne__c = 'Minnesota'));
		states.add(new CFAR_States_gne__c(Name = 'Mississippi', State_Name_gne__c = 'Mississippi'));
		states.add(new CFAR_States_gne__c(Name = 'Missouri', State_Name_gne__c = 'Missouri'));
		states.add(new CFAR_States_gne__c(Name = 'Montana', State_Name_gne__c = 'Montana'));
		states.add(new CFAR_States_gne__c(Name = 'Nevada', State_Name_gne__c = 'Nevada'));
		states.add(new CFAR_States_gne__c(Name = 'New Hampshire', State_Name_gne__c = 'New Hampshire'));
		states.add(new CFAR_States_gne__c(Name = 'New Jersey', State_Name_gne__c = 'New Jersey'));
		states.add(new CFAR_States_gne__c(Name = 'New Mexico', State_Name_gne__c = 'New Mexico'));
		states.add(new CFAR_States_gne__c(Name = 'New York', State_Name_gne__c = 'New York'));
		states.add(new CFAR_States_gne__c(Name = 'North Carolina', State_Name_gne__c = 'North Carolina'));
		states.add(new CFAR_States_gne__c(Name = 'North Dakota', State_Name_gne__c = 'North Dakota'));
		states.add(new CFAR_States_gne__c(Name = 'Ohio', State_Name_gne__c = 'Ohio'));
		states.add(new CFAR_States_gne__c(Name = 'Oklahoma', State_Name_gne__c = 'Oklahoma'));
		states.add(new CFAR_States_gne__c(Name = 'Oregon', State_Name_gne__c = 'Oregon'));
		states.add(new CFAR_States_gne__c(Name = 'Pennsylvania', State_Name_gne__c = 'Pennsylvania'));
		states.add(new CFAR_States_gne__c(Name = 'Rhode Island', State_Name_gne__c = 'Rhode Island'));
		states.add(new CFAR_States_gne__c(Name = 'South Dakota', State_Name_gne__c = 'South Dakota'));
		states.add(new CFAR_States_gne__c(Name = 'Tennessee', State_Name_gne__c = 'Tennessee'));
		states.add(new CFAR_States_gne__c(Name = 'Texas', State_Name_gne__c = 'Texas'));
		states.add(new CFAR_States_gne__c(Name = 'Utah', State_Name_gne__c = 'Utah'));
		states.add(new CFAR_States_gne__c(Name = 'Vermont', State_Name_gne__c = 'Vermont'));
		states.add(new CFAR_States_gne__c(Name = 'Virginia', State_Name_gne__c = 'Virginia'));
		states.add(new CFAR_States_gne__c(Name = 'Washington', State_Name_gne__c = 'Washington'));
		states.add(new CFAR_States_gne__c(Name = 'West Virginia', State_Name_gne__c = 'West Virginia'));
		states.add(new CFAR_States_gne__c(Name = 'Wisconsin', State_Name_gne__c = 'Wisconsin'));
		states.add(new CFAR_States_gne__c(Name = 'Wyoming', State_Name_gne__c = 'Wyoming'));
		states.add(new CFAR_States_gne__c(Name = 'DC', State_Name_gne__c = 'DC'));
    	
    	insert states;
    	return states;
    }
    
    public static CFAR_Contact_Address_gne__c createTestAddress() {
    	CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c(Name = 'Fedex Delivery');
        insert addressType;
    	CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
    	address.Address_Type_ref_gne__c = addressType.Id;
    	address.Country_gne__c = 'Argentina';
    	address.Province_gne__c = 'TestProvince';
		address.City_gne__c = 'TestCity';
		address.Address_gne__c = 'TestAddress';
		address.Postal_Code_gne__c = '12345';
        address.Institution_gne__c = createTestInstitution().Id;
		
		insert address;
		return address;
    }
    
    public static CFAR_Comment_gne__c createTestComment(Id trialId, Id contactId) {
    	CFAR_Comment_gne__c comment = new CFAR_Comment_gne__c(CFAR_Trial_ref_gne__c = trialId, Created_By_CFAR_Contact_ref_gne__c = contactId, Activity_Date_gne__c = Date.today(), Comments_gne__c = 'abc');
    	
    	insert comment;
    	return comment;
    }
    
    public static CFAR_WBS_gne__c createTestWBS() {
        CFAR_WBS_gne__c wbs = new CFAR_WBS_gne__c(Name = 'Activase ML28241', GSR_WBS_gne__c = 'GN09544PML28241', Old_WBS_Code_gne__c = '136.02514');
        
        insert wbs;
        return wbs;
    }
    
    public static List<CFAR_Budget_Contract_Type_gne__c> createContractTypes() {
        List<CFAR_Budget_Contract_Type_gne__c> contractTypes = new List<CFAR_Budget_Contract_Type_gne__c>();
        contractTypes.add(new CFAR_Budget_Contract_Type_gne__c(Name = 'Planned'));
        contractTypes.add(new CFAR_Budget_Contract_Type_gne__c(Name = 'Original Contract'));
        contractTypes.add(new CFAR_Budget_Contract_Type_gne__c(Name = 'Contract Amendment Increase'));
        contractTypes.add(new CFAR_Budget_Contract_Type_gne__c(Name = 'Contract Amendment Decrease'));
        contractTypes.add(new CFAR_Budget_Contract_Type_gne__c(Name = 'Contract Amendment No Change'));
        contractTypes.add(new CFAR_Budget_Contract_Type_gne__c(Name = 'Adjustment'));
        contractTypes.add(new CFAR_Budget_Contract_Type_gne__c(Name = 'Contract Cancelled'));
        
        insert contractTypes;
        return contractTypes;
    }
    
    public static List<CFAR_Payment_Schedule_Status_gne__c> createPaymentStatuses() {
        List<CFAR_Payment_Schedule_Status_gne__c> paymentStatuses = new List<CFAR_Payment_Schedule_Status_gne__c>();
        paymentStatuses.add(new CFAR_Payment_Schedule_Status_gne__c(Name = 'Cancelled', Active_gne__c = false));
        paymentStatuses.add(new CFAR_Payment_Schedule_Status_gne__c(Name = 'Invoice Paid'));
        paymentStatuses.add(new CFAR_Payment_Schedule_Status_gne__c(Name = 'Invoice Submitted'));
        paymentStatuses.add(new CFAR_Payment_Schedule_Status_gne__c(Name = 'Payment Due No Invoice Submitted'));
        paymentStatuses.add(new CFAR_Payment_Schedule_Status_gne__c(Name = 'Planned'));
        paymentStatuses.add(new CFAR_Payment_Schedule_Status_gne__c(Name = 'Refund'));
        paymentStatuses.add(new CFAR_Payment_Schedule_Status_gne__c(Name = 'Unpaid Contract Amount'));
        
        insert paymentStatuses;
        return paymentStatuses;
    }

    public static List<CFAR_Trial_Status_gne__c> createTrialStatuses() {
        List<CFAR_Trial_Status_gne__c> ts = new List<CFAR_Trial_Status_gne__c>();
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_PROPOSAL_APPROVED, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_PROTOCOL_APPROVED, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_FOLLOWUP, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_PUBLICATION, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_CLOSURE_PENDING, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_HOLD, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_REOPENED, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_COMPLETED_ENROLLMENT, Active_gne__c=true));
        ts.add(new CFAR_Trial_Status_gne__c(name=Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_ENROLLMENT, Active_gne__c=true));
        insert ts;
        return ts;
    }

    public static CFAR_Partnership_gne__c createPartnership(String name, Boolean active){
        CFAR_Partnership_gne__c partnership = new CFAR_Partnership_gne__c(Name = name, Active_gne__c = active);
        insert partnership;
        return partnership;
    }

    public static List<CFAR_Picklist_Value_gne__c> createPicklistValue(List<String> newPicklistValues, String rtName) {
        RecordType rt = [SELECT ID FROM RecordType WHERE Name = :rtName AND SobjectType = 'CFAR_Picklist_Value_gne__c' LIMIT 1];
        CFAR_Picklist_Value_gne__c[] newImpactValues = new List<CFAR_Picklist_Value_gne__c>();

        for (String impactValue : newPicklistValues) {
            newImpactValues.add(new CFAR_Picklist_Value_gne__c(Name = impactValue, Active_gne__c = true, RecordTypeId = rt.id));
        }

        insert newImpactValues;
        return newImpactValues;
    }

    public static CFAR_Type_of_Sample_gne__c createTypeOfSample(String typeName){
        CFAR_Type_of_Sample_gne__c typeOfSample = new CFAR_Type_of_Sample_gne__c(Name = typeName);
        insert typeOfSample;
        return typeOfSample;
    }

    public static CFAR_Trial_Type_of_Sample_gne__c createTrialTypeOfSample(Id trialId, Id typeOfSampleId, String typeName) {
        CFAR_Trial_Type_of_Sample_gne__c TrialTypeOfSample = new CFAR_Trial_Type_of_Sample_gne__c(
            CFAR_Trial_ref_gne__c = trialId,
            Type_of_Sample_ref_gne__c = typeOfSampleId,
            Name = typeName);

        insert TrialTypeOfSample;
        return TrialTypeOfSample;
    }
}