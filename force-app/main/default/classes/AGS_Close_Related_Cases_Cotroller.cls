public with sharing class AGS_Close_Related_Cases_Cotroller { 
    public String sRetUrl = '';
    public String sErrMessage { get; set; }
    public String sActionPicklist { get; set; }
    public AGS_Case_Action_gne__c objAGSCaseaction = new AGS_Case_Action_gne__c();
    public AGS_Case_gne__c objAGScase = new AGS_Case_gne__c();
    public List<Cases> casesListObj = new List<Cases>(); 
    public List<RecordType> RecTypeNEW = new List<RecordType>([select Name, Id from RecordType where Name like 'AGS%']);
    public Map<String, RecordType> AGS_RecTypes_map;
    
    public AGS_Close_Related_Cases_Cotroller(ApexPages.StandardController controller) {
        sActionPicklist='None';

        system.debug( 'sRetUrl' + ApexPages.currentPage().getParameters().get('id') );
        if( ApexPages.currentPage().getParameters().get('id') != null ) {
            sRetUrl = ApexPages.currentPage().getParameters().get('id');
            system.debug('sRetUrl :' + sRetUrl);
        }
    }

    public AGS_Case_Action_gne__c getObjAGSCaseaction() {
        try {
            objAGSCase = [select Id, Name from AGS_Case_gne__c where Id = :sRetUrl];
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        if(objAGSCase != null && objAGSCase.Id != null) {
            objAGSCaseaction.AGS_Case_gne__c = objAGSCase.Id;
        }
        return objAGSCaseaction;
    }

    public PageReference autoRun() {
        System.debug('Made It to AutoRun');
        try {
            objAGSCase = [
                SELECT  Id, Name, Reason_Type_gne__c, Case_Status_gne__c
                FROM    AGS_Case_gne__c
                WHERE   Id = :sRetUrl
            ];
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        if(objAGSCase != null && objAGSCase.Id != null) {
            objAGSCaseaction.AGS_Case_gne__c = objAGSCase.Id;
            system.debug('objAGSCase.Id :' + objAGSCase.Id);
        }  
        List<AGSSpendCCOCase_gne__c> relatedCases = new List<AGSSpendCCOCase_gne__c>();
        List<AGSSpendCCOCase_gne__c> caseDetails = new List<AGSSpendCCOCase_gne__c>([
            SELECT  Event_Id_gne__c 
            FROM    AGSSpendCCOCase_gne__c 
            WHERE   AGS_Case_gne__c = :objAGSCase.Id 
            AND     Event_Id_gne__c != null
        ]);
        if(caseDetails != null && caseDetails.size() > 0) {
            relatedCases = new List<AGSSpendCCOCase_gne__c>([
                SELECT  AGS_Case_gne__r.Id, AGS_Case_gne__r.AGS_CCO_Reason_Name_gne__c, AGS_Case_gne__r.Case_Status_gne__c 
                FROM    AGSSpendCCOCase_gne__c
                WHERE   Event_Id_gne__c =:caseDetails[0].Event_ID_gne__c
            ]);
        } else {
            ApexPages.addMessage( new Apexpages.Message(ApexPages.Severity.ERROR, 'There are no events associated to this case') );
            relatedCases = new List<AGSSpendCCOCase_gne__c>([
                SELECT  AGS_Case_gne__r.Id, AGS_Case_gne__r.AGS_CCO_Reason_Name_gne__c, AGS_Case_gne__r.Case_Status_gne__c 
                FROM    AGSSpendCCOCase_gne__c 
                WHERE   AGS_Case_gne__c = :objAGSCase.Id
            ]);
        }
        
        All_User_Hierarchy_gne__c dummy = [
            SELECT  Id, User_External_Id_gne__c 
            FROM    All_User_Hierarchy_gne__c  
            WHERE   User_External_Id_gne__c = :Utilities.noSpendUser
        ];
        List<AGSSpendCCOCase_gne__c> juncObj = new List<AGSSpendCCOCase_gne__c>([
            SELECT  AGS_Case_gne__r.Name, 
                    AGS_Spend_Expense_Transaction_gne__r.Spend_User_gne__c,
                    AGS_Case_gne__r.Resolver_gne__c,
                    User_External_ID__c,
                    AGS_Case_gne__r.Reason_Type_gne__c,
                    AGS_Case_gne__r.Reason_gne__c,
                    AGS_Case_gne__r.Inactive_resolver__r.Active_gne__c, 
                    AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c, 
                    AGS_Case_gne__r.Inactive_resolver__r.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c,
                    User_from_AllUserHeirarchy__r.All_User_Hierarchy_Level1_gne__c,
                    User_from_AllUserHeirarchy__r.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c
            FROM    AGSSpendCCOCase_gne__c 
            WHERE   AGS_Case_gne__c = :objAGSCaseaction.AGS_Case_gne__c
        ]);
        Set<String> userExternalIdSet = new Set<String>();
        for (AGSSpendCCOCase_gne__c ju : juncObj) {
            userExternalIdSet.add(ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c);
        }
        List<User> usersFromExternalIds = [
            SELECT  Id, isActive, External_ID_gne__c
            FROM    User 
            WHERE   External_ID_gne__c IN :userExternalIdSet
        ];
        Map<String, User> externalIdToUserMap = new Map<String, User>();
        for(User u : usersFromExternalIds) {
            externalIdToUserMap.put(u.External_ID_gne__c, u);
        }
        Set<string> resolverSet = new Set<String>();
        for (AGSSpendCCOCase_gne__c ju : juncObj) {
            if(ju.AGS_Case_gne__r.Resolver_gne__c != null && ju.AGS_Case_gne__r.Inactive_resolver__c != null) {
                if(ju.AGS_Case_gne__r.Inactive_resolver__r.Active_gne__c) {
                    User usr = externalIdToUserMap.get(ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c);
                    if(usr != null && usr.isActive) {
                        resolverSet.add(ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c); 
                    } else {
                        resolverSet.add(dummy.User_External_Id_gne__c);
                    }
                } else {
                    resolverSet.add(dummy.User_External_Id_gne__c); 
                }
                System.debug('Resolver External ID :' + resolverSet);
            }
        }
        for(AGSSpendCCOCase_gne__c relatedCase : relatedCases) {
            casesListObj.add(
                new Cases(
                    relatedCase.AGS_Case_gne__r.Id,
                    resolverSet.clone(),
                    relatedCase.AGS_Case_gne__r.AGS_CCO_Reason_Name_gne__c,
                    relatedCase.AGS_Case_gne__r.Case_Status_gne__c
                )
            );
        }
        return null;
    }

    public PageReference SaveAction() { 
        try {
            objAGSCase = [
                SELECT     Id, Name, Reason_Type_gne__c, AGS_CCO_Reason_Name_gne__c 
                FROM     AGS_Case_gne__c 
                WHERE     Id = :sRetUrl
            ];
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }   
        AGS_RecTypes_map = new Map<String, RecordType>();
        for(RecordType r :RecTypeNEW) { 
            AGS_RecTypes_map.put(r.name, r);
        }                
        if(sActionPicklist == null || sActionPicklist == 'None') {
            sErrMessage = 'Please enter value for Case Action';
            return null;
        } 
        if(casesListObj != null && casesListObj.size() > 0) {
            List< AGS_Case_Action_gne__c> lstCaseActionInsert = new List< AGS_Case_Action_gne__c>();
            List<User> usr_list = new List<User>([
                SELECT  Email, Name, Id, IsActive, External_ID_gne__c
                FROM    User 
                WHERE   External_ID_gne__c IN :casesListObj[0].resolverSet 
                AND     UserType = 'Standard' 
                ORDER BY Email
            ]);
            for(Cases caseObj: casesListObj) {
                System.debug('----------------------caseObj' + caseObj);
                if(objAGSCase.Reason_Type_gne__c == 'Instance Rule' && caseObj.caseStatus.toLowerCase().Contains('open') && caseObj.caseReason == objAGSCase.AGS_CCO_Reason_Name_gne__c) {
                    for (Integer i=0; i <usr_list.size(); i++) {
                        AGS_Case_Action_gne__c aca ; 
                        if(sActionPicklist == 'Close Case - No Issue') { 
                            aca = createCaseAction(usr_list[i], AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'), caseObj.caseId);
                        } else if(sActionPicklist == 'Close Case - Issue Resolved') {   
                            aca = createCaseAction(usr_list[i], AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'), caseObj.caseId);
                        } else if(sActionPicklist == 'Close Case - HCO To Resolve') {   
                            aca = createCaseAction(usr_list[i], AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'), caseObj.caseId);
                        } else if(sActionPicklist == 'Close Case - No Notification') {   
                            aca = createCaseAction(usr_list[i], AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'), caseObj.caseId);
                        }
                        if (aca != null) {
                            lstCaseActionInsert.add(aca);
                        }
                    }
                }
            }
            System.debug('----------------------lstCaseActionInsert' + lstCaseActionInsert);
            try { 
                SavePoint savePoint = Database.setSavePoint();
                Set<Id> caseActionsWithSuccess = new Set<Id>();  
                //AGS_Case_Action_gne__c act = new AGS_Case_Action_gne__c();
                //act.ownerId = '005Q0000000P0eV';
                //act.AGS_Case_gne__c = objAGSCase.Id;
                //act.Action_gne__c= 'bla bla bla';
                //lstCaseActionInsert.add(act);   
                if(lstCaseActionInsert != null && lstCaseActionInsert.size() > 0) {
                    List<Database.Saveresult> results = Database.insert(lstCaseActionInsert, false);
                    for(Database.Saveresult res : results) { 
                        if( res.isSuccess() ) {
                            caseActionsWithSuccess.add( res.getId() );
                        }
                    }
                    System.debug('----------------------caseActionWithSuccess' + caseActionsWithSuccess);
                    system.debug('Inserted Case Action Successfully'  + lstCaseActionInsert);
                }
                List<AGS_Case_Action_gne__c> listCaseActionsWithSuccess = new List<AGS_Case_Action_gne__c>([
                    SELECT  OwnerId, AGS_Case_gne__c, AGS_Case_gne__r.Name 
                    FROM    AGS_Case_Action_gne__c 
                    WHERE   Id in :caseActionsWithSuccess
                ]);
                List<AGS_Case_Action_gne__c> listCaseActionsWithFailures = new List<AGS_Case_Action_gne__c>();
                for(AGS_Case_Action_gne__c aca : lstCaseActionInsert) {
                    Boolean isFailed = true;
                    for(AGS_Case_Action_gne__c actionSuccess : listCaseActionsWithSuccess ) {
                        if(aca.OwnerId == actionSuccess.OwnerId && aca.AGS_Case_gne__c == actionSuccess.AGS_Case_gne__c) {
                            isFailed = false;
                        }
                    }
                    if(isFailed) {
                        listCaseActionsWithFailures.add(aca);
                    }
                }
                System.Debug('listCaseActionsWithFailures-----------------------' + listCaseActionsWithFailures);
                
                if(listCaseActionsWithFailures != null && listCaseActionsWithFailures.size() > 0) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<User> usrs = new List<User>([select email,Name from User where id=:UserInfo.getUserId()]);
                    system.debug('------------------------usrs'+usrs);
                    system.debug('------------------------usrs[0].email'+usrs[0].email);
                    mail.setToAddresses(new String[]{usrs[0].email});
                    mail.setSubject('Failed cases');
                    mail.setReplyTo('kaczmarl@gene.com');
                    String mailText = '******PLEASE DO NOT REPLY TO THIS EMAIL****** \n\n';
                    mailText += 'Dear '+ usrs[0].Name+',\n\n'; 
                    mailText += 'The folowing cases have not been closed while Close Related Cases action:\n\n'; 
                    for(AGS_Case_Action_gne__c actionFailure: listCaseActionsWithFailures ) {
                        mailText += actionFailure.AGS_Case_gne__r.Name + '\n';
                    }
                    mailText += '\nBest regards,\n';
                    mailText += 'System Administrator';
                    System.Debug('-------------mailText' + mailText);
                    mail.setPlainTextBody(mailText);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    Database.rollback(savePoint);
                }
            } catch(Exception ex) {
                //ApexPages.addMessages(ex);
            }
        } else {
            ApexPages.addMessage( 
                new Apexpages.Message(ApexPages.Severity.ERROR, 'There are no events associated to this case')
            );
            return null;
        }   
        PageReference opp = new PageReference('/' + objAGSCaseaction.AGS_Case_gne__c);
        return opp;
    }

    public AGS_Case_Action_gne__c createCaseAction(User usrRecord, RecordType recType, Id caseId) {
        AGS_Case_Action_gne__c aca = new AGS_Case_Action_gne__c();
        aca.ownerId = usrRecord.id;
        aca.AGS_Case_gne__c = caseId;
        aca.Action_gne__c = sActionPicklist;
        aca.Action_Status_internal_gne__c = 'Open';
        aca.recordtypeid = recType.Id;
        system.debug('Rec Type for Aggregate reco spending Reached  :' + recType.Id );
        system.debug('aca.recordtypeid  :' + aca.recordtypeid );
        return aca;
    }   

    public class Cases {
        public Id caseId { get; set; }
        Set<string> resolverSet = new Set<string>();
        String caseReason { get; set; }
        String caseStatus { get; set; }
        public Cases(Id idParam, Set<string> resolverSetParam, String caseReasonParam, String caseStatusParam) {
            caseId = idParam;
            resolverSet = resolverSetParam;
            caseReason = caseReasonParam;
            caseStatus = caseStatusParam;
        }
    }
}