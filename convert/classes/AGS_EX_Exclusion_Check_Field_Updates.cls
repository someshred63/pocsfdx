public without sharing class AGS_EX_Exclusion_Check_Field_Updates {

    final static String STATUS_EXCLUDED = 'Excluded';
    final static String RESULT_EMAIL_TEMPLATE = 'AGS_EX_Exclusion_Check_Request_Result';
    final static String EXCLUDED_EMAIL_TEMPLATE = 'AGS_EX_Exclusion_Account_Excluded';

    public static void onAfterUpdate(List<AGS_EX_Exclusion_Check_gne__c> triggerNew) {
        
        System.debug('MICK_LOKO triggerNew:' + triggerNew);
        List<AGS_EX_Exclusion_Check_gne__c> checksNew = [SELECT Id, Name,AGS_EX_Exclusion_Request_gne__r.AGS_EX_Request_Status_gne__c, AGS_EX_Account_Address_gne__c, AGS_EX_Account_MDMID_gne__c, 
                                                            AGS_EX_Account_Name_gne__c, AGS_EX_Account_NPIID_gne__c, AGS_EX_Check_Attachment_gne__c, 
                                                            AGS_EX_Check_Date_gne__c, AGS_EX_Comments_gne__c, AGS_EX_Exclusion_Request_gne__c, 
                                                            AGS_EX_Reviewer_Name_gne__c, AGS_EX_Status_gne__c, AGS_EX_Exclusion_Request_gne__r.AGS_EX_Account_Name_gne__c
                                                        FROM AGS_EX_Exclusion_Check_gne__c
                                                        WHERE Id IN :triggerNew and AGS_EX_Exclusion_Request_gne__r.AGS_EX_Request_Status_gne__c != 'In Progress'];

        generateEmails(checksNew);


    }

    public static void onAfterInsert(List<AGS_EX_Exclusion_Check_gne__c> triggerNew) {

        List<AGS_EX_Exclusion_Check_gne__c> checksNew = [SELECT Id, Name, AGS_EX_Account_Address_gne__c, AGS_EX_Account_MDMID_gne__c, 
                                                            AGS_EX_Account_Name_gne__c, AGS_EX_Account_NPIID_gne__c, AGS_EX_Check_Attachment_gne__c, 
                                                            AGS_EX_Check_Date_gne__c, AGS_EX_Comments_gne__c, AGS_EX_Exclusion_Request_gne__c, 
                                                            AGS_EX_Reviewer_Name_gne__c, AGS_EX_Status_gne__c, AGS_EX_Exclusion_Request_gne__r.AGS_EX_Account_Name_gne__c
                                                        FROM AGS_EX_Exclusion_Check_gne__c
                                                        WHERE Id IN :triggerNew and AGS_EX_Exclusion_Request_gne__r.AGS_EX_Request_Status_gne__c != 'In Progress'];

        generateEmails(checksNew);


    }
    
    private static void generateEmails(List<AGS_EX_Exclusion_Check_gne__c> checksNew) {

        // FOR STATUS CHANGES

        List<AGS_EX_Exclusion_Check_gne__c> listExclusionCheck = new List<AGS_EX_Exclusion_Check_gne__c>();
        List<Id> requestorIds = new List<Id>();
        List<Id> listRequestId = new List<Id>();
        List<Id> listExcludedAccountsIds = new List<Id>();
        List<Speaker_Bureau_Membership_gne__c> listMemberToLead;
        List<EDM_Attendee_gne__c> listEventsAttendees;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        //Request result information (EXC-NOT-02) 

        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Exclusion Check' LIMIT 1];
        Id orgWideEmailId = null;
        if (owa != null) {
            orgWideEmailId = owa.Id;
        }

        for (AGS_EX_Exclusion_Check_gne__c newExclusionCheck : checksNew) {

            listExclusionCheck.add(newExclusionCheck);
            listRequestId.add(newExclusionCheck.AGS_EX_Exclusion_Request_gne__c);

            if (newExclusionCheck.AGS_EX_Status_gne__c == STATUS_EXCLUDED) {
                listExcludedAccountsIds.add(newExclusionCheck.AGS_EX_Exclusion_Request_gne__r.AGS_EX_Account_Name_gne__c);
                System.debug('listExcludedAccountsIds: ' + listExcludedAccountsIds); 
            }
        }
        System.debug('listRequestId: ' + listRequestId);

        for (AGS_EX_Exclusion_Requestor_gne__c exclusionRequestor : [SELECT AGS_EX_Requestor_Name_gne__c FROM AGS_EX_Exclusion_Requestor_gne__c
                                                                WHERE AGS_EX_Exclusion_Request_gne__c in :listRequestId]) {
            requestorIds.add(exclusionRequestor.AGS_EX_Requestor_Name_gne__c);
        }
        System.debug('requestorIds: ' + requestorIds);

        List<EmailTemplate> listResultEmailTpl = [SELECT Id, Name FROM EmailTemplate WHERE Developername = :RESULT_EMAIL_TEMPLATE];
        if (listResultEmailTpl.size() == 1) {
            Id resultTemplateId = listResultEmailTpl[0].id;
            for (AGS_EX_Exclusion_Check_gne__c exclusionCheck : listExclusionCheck) {
                for (Id reqId : requestorIds) {
                    emails.add(AGS_EX_Exclusion_Utils.getTemplatedEmailWithOWA(reqId, exclusionCheck.Id, resultTemplateId, orgWideEmailId));
                    System.debug('Emails to send (exclusionCheck): ' + emails);
                }                   
            }
        }
        else {
            System.debug('Email template not found: ' + RESULT_EMAIL_TEMPLATE);
        }
        

        //Existing Account Excluded information (EXC-NOT-03)
        List<EmailTemplate> listExclEmailTpl = [SELECT Id, Name FROM EmailTemplate WHERE Developername = :EXCLUDED_EMAIL_TEMPLATE];
        if (listExclEmailTpl.size() == 1) {
            Set<String> userAccountSet = new Set<String>();
            Id excludedTemplateId = listExclEmailTpl[0].id;
            String currentYear = String.valueOf(System.Today().year());
            listMemberToLead = [SELECT Bureau_Member_gne__c, Speaker_Bureau_ID_gne__r.Speaker_Bureau_Year_gne__c,
                                    Speaker_Bureau_ID_gne__r.Speaker_Bureau_Lead_gne__c
                                FROM Speaker_Bureau_Membership_gne__c 
                                WHERE Bureau_Member_gne__c IN :listExcludedAccountsIds
                                AND Speaker_Bureau_ID_gne__r.Speaker_Bureau_Year_gne__c >= :currentYear
                                AND Speaker_Bureau_ID_gne__r.Speaker_Bureau_Lead_gne__c != null];

            for (Speaker_Bureau_Membership_gne__c member : listMemberToLead) {
                userAccountSet.add(member.Speaker_Bureau_ID_gne__r.Speaker_Bureau_Lead_gne__c + '_' + member.Bureau_Member_gne__c);
            }

            listEventsAttendees = [SELECT EDM_Account_gne__c, EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__c,
                                        EDM_Parent_IABP_gne__r.EDM_Secondary_AB_Lead_gne__c,
                                        EDM_Parent_IABP_gne__r.EDM_Third_AB_Lead_gne__c
                                    FROM EDM_Attendee_gne__c
                                    WHERE EDM_Account_gne__c IN :listExcludedAccountsIds
                                    AND EDM_Parent_IABP_gne__r.EDM_Status_gne__c IN 
                                                ('IABP Not Started', 'IABP In Progress', 'IABP Under Review', 'IABP Submitted for Approval',
                                                 'IABP Approved', 'Revising Approved IABP', 'Re-Reviewing Approved IABP')
                                    AND EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false
                                ];

            for (EDM_Attendee_gne__c att : listEventsAttendees) {
                if(att.EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__c != null)
                    userAccountSet.add(att.EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__c + '_' + att.EDM_Account_gne__c);
                if(att.EDM_Parent_IABP_gne__r.EDM_Secondary_AB_Lead_gne__c != null)
                    userAccountSet.add(att.EDM_Parent_IABP_gne__r.EDM_Secondary_AB_Lead_gne__c + '_' + att.EDM_Account_gne__c);
                if(att.EDM_Parent_IABP_gne__r.EDM_Third_AB_Lead_gne__c != null)
                    userAccountSet.add(att.EDM_Parent_IABP_gne__r.EDM_Third_AB_Lead_gne__c + '_' + att.EDM_Account_gne__c);
            }

            for (String userAccountId : userAccountSet) {
                List<String> userAccountList = userAccountId.split('_');
                emails.add(AGS_EX_Exclusion_Utils.getTemplatedEmailWithOWA(userAccountList[0], userAccountList[1], excludedTemplateId, orgWideEmailId));
                System.debug('Emails to send (accId): ' + emails);
            }            
        }
        else {
            System.debug('Email template not found: ' + EXCLUDED_EMAIL_TEMPLATE);
        }
        
        System.debug('Emails to send: ' + emails);
        // Add later on for Advisory Board Leads!
        if(emails.size() > 0){
            Messaging.sendEmail(emails);
        }
        // END FOR STATUS CHANGES
    }

}