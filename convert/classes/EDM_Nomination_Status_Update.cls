public class EDM_Nomination_Status_Update{
    
    public static void onAfterUpdateClassification(Map<Id,EDM_Classification_Request_gne__c> triggerOldMap,List<EDM_Classification_Request_gne__c> triggerNew) {
        
        List<ID> accountsWithBusiness = new List<ID>();
        List<ID> accountsWithClinical = new List<ID>();
        List<ID> accountsWithBusinessSBMToDelete = new List<ID>(); 
        List<ID> accountsWithClinicalSBMToDelete = new List<ID>();    
        
        for(EDM_Classification_Request_gne__c cr : triggerNew){
            if(cr.EDM_Status_gne__c=='Completed' && triggerOldMap.get(cr.Id).EDM_Status_gne__c == 'Pending'){
                if(cr.EDM_Type_of_Classification_gne__c == 'Clinical'){
                    if(cr.EDM_Action_Taken_gne__c == 'Decline to Classify'){
                        accountsWithClinicalSBMToDelete.add(cr.EDM_Account_gne__c);
                    } else {
                        accountsWithClinical.add(cr.EDM_Account_gne__c);
                    }
                } else {
                    if(cr.EDM_Action_Taken_gne__c == 'Decline to Classify'){
                        accountsWithBusinessSBMToDelete.add(cr.EDM_Account_gne__c);
                    } else {
                        accountsWithBusiness.add(cr.EDM_Account_gne__c);
                    }
                }
            }
        }

        if(!accountsWithBusiness.isEmpty()){
            updateSBMForClassification(accountsWithBusiness, 'Business');
        }
        if(!accountsWithClinical.isEmpty()){
            updateSBMForClassification(accountsWithClinical, 'Clinical');
        }
        if(!accountsWithClinicalSBMToDelete.isEmpty()){
            deleteSBM(accountsWithClinicalSBMToDelete,'Clinical');
        }
        if(!accountsWithBusinessSBMToDelete.isEmpty()){
            deleteSBM(accountsWithBusinessSBMToDelete,'Business');
        }
    }

    public static void deleteSBM(List<ID> accounts,String typeOfClassification){
        List<Speaker_Bureau_Membership_gne__c> sbmToDelete = new List<Speaker_Bureau_Membership_gne__c>();
        if(typeOfClassification=='Clinical'){
            sbmToDelete = [SELECT Id FROM Speaker_Bureau_Membership_gne__c WHERE Speaker_Status_gne__c = 'Pending' 
                            AND Speaker_Bureau_ID_gne__r.Speaker_Bureau_Type_gne__c = 'Clinical'
                            AND Bureau_Member_gne__c IN :accounts
                            AND (Bureau_Member_gne__r.EDM_Clinical_Classification_gne__c = 'Not Classified' 
                                OR Bureau_Member_gne__r.EDM_Clinical_Classification_gne__c = '')
                            ];
        } else if(typeOfClassification=='Business'){
            sbmToDelete = [SELECT Id FROM Speaker_Bureau_Membership_gne__c WHERE Speaker_Status_gne__c='Pending'
                            AND Speaker_Bureau_ID_gne__r.Speaker_Bureau_Type_gne__c = 'Business' 
                            AND Bureau_Member_gne__c IN :accounts 
                            AND (Bureau_Member_gne__r.EDM_Business_Classification_gne__c = 'Not Classified'
                                OR Bureau_Member_gne__r.EDM_Business_Classification_gne__c = '')
                            ];
        }
        delete sbmToDelete;
    }

    public static void updateSBMForClassification(List<ID> accounts, String classificationType){
        List<Speaker_Bureau_Membership_gne__c> sbm = getPendingSMBWithType(accounts, classificationType);
        Map<Id, Account> accs = getAccountsClassificationsAndExclusion(accounts);

        List<Speaker_Bureau_Membership_gne__c> sbmToUpdate = new List<Speaker_Bureau_Membership_gne__c>();

        for(Speaker_Bureau_Membership_gne__c s : sbm){
            Account a = accs.get(s.Bureau_Member_gne__c);
            if(a.AGS_EX_Exclusion_Status_gne__c=='Excluded'){
                s.Speaker_Status_gne__c='Excluded';    
                sbmToUpdate.add(s);
            } else if(a.AGS_EX_Exclusion_Status_gne__c=='Verified and Clear'){
                s.Speaker_Status_gne__c='Nominated';
                sbmToUpdate.add(s);
            }
        }
        update sbmToUpdate;
    }

    public static List<Speaker_Bureau_Membership_gne__c> getPendingSMBWithType(List<Id> accIds, String bureauType){
    	return [SELECT Id, Speaker_Status_gne__c, Bureau_Member_gne__c FROM Speaker_Bureau_Membership_gne__c 
                WHERE Speaker_Status_gne__c='Pending' AND Bureau_Member_gne__c IN :accIds
                AND Speaker_Bureau_ID_gne__r.Speaker_Bureau_Type_gne__c = :bureauType];
    }

    public static Map<Id, Account> getAccountsClassificationsAndExclusion(List<Id> accIds){
    	return new Map<Id, Account>([SELECT Id, Name, EDM_Business_Classification_gne__c, EDM_Clinical_Classification_gne__c, 
                                    AGS_EX_Exclusion_Status_gne__c FROM Account WHERE Id IN :accIds]);
    }


    public static void onAfterUpdateExclusion(Map<Id,AGS_EX_Exclusion_Request_gne__c> triggerOldMap,List<AGS_EX_Exclusion_Request_gne__c> triggerNew) {
        
        List<ID> accounts = new List<ID>();    
        for(AGS_EX_Exclusion_Request_gne__c er : triggerNew){
            if(er.AGS_EX_Request_Status_gne__c == 'Completed' && triggerOldMap.get(er.Id).AGS_EX_Request_Status_gne__c != 'Completed'){
                accounts.add(er.AGS_EX_Account_Name_gne__c);
            }
        }
        updateSBM(accounts);
    }

    public static void onAfterInsertExclusion(List<AGS_EX_Exclusion_Request_gne__c> triggerNew) {
        
        List<ID> accounts = new List<ID>();    
        for(AGS_EX_Exclusion_Request_gne__c er : triggerNew){
            if(er.AGS_EX_Request_Status_gne__c == 'Completed'){
                accounts.add(er.AGS_EX_Account_Name_gne__c);
            }
        }
        updateSBM(accounts);
    }

    public static void updateSBM(List<ID> accounts){
        List<Speaker_Bureau_Membership_gne__c> sbm = getSMBToUpdate(accounts);
        Map<Id, Account> accs = getAccountsClassificationsAndExclusion(accounts);
        List<Speaker_Bureau_Membership_gne__c> sbmToUpdate = new List<Speaker_Bureau_Membership_gne__c>();
        List<Speaker_Bureau_Membership_gne__c> noLongerExcludedSBMs = new List<Speaker_Bureau_Membership_gne__c>();

        for(Speaker_Bureau_Membership_gne__c s : sbm){
            Account a = accs.get(s.Bureau_Member_gne__c);
            if(checkClassification(a, s.Speaker_Bureau_ID_gne__r.Speaker_Bureau_Type_gne__c)){
                //classification is done and good
                if(a.AGS_EX_Exclusion_Status_gne__c == 'Excluded'){
                    s.Speaker_Status_gne__c = 'Excluded';    
                    sbmToUpdate.add(s);
                } else {
                    //if it was pending it changes to nominated, if it was excluded we go back to previous status or to nominated
                    if(s.Speaker_Status_gne__c == 'Pending'){
                        s.Speaker_Status_gne__c = 'Nominated';
                        sbmToUpdate.add(s);    
                    } else if (s.Speaker_Status_gne__c == 'Excluded'){
                        noLongerExcludedSBMs.add(s);
                    }
                }
            }
        }

        sbmToUpdate.addAll(getPreviousValues(noLongerExcludedSBMs));
        update sbmToUpdate;
    }

    public static List<Speaker_Bureau_Membership_gne__c> getSMBToUpdate(List<Id> accIds){
        String currentYear = String.valueOf(Date.today().year());
        return [SELECT Id, Speaker_Status_gne__c, Bureau_Member_gne__c, Speaker_Bureau_ID_gne__r.Speaker_Bureau_Type_gne__c
                 FROM Speaker_Bureau_Membership_gne__c WHERE Bureau_Member_gne__c IN :accIds AND (Speaker_Status_gne__c='Pending' OR
                Speaker_Bureau_ID_gne__r.Speaker_Bureau_Year_gne__c >= :currentYear)];
    }

    public static Boolean checkClassification(Account acc, String classificationType){
        return (
                (classificationType == 'Clinical') ? 
                (String.isNotEmpty(acc.EDM_Clinical_Classification_gne__c) && acc.EDM_Clinical_Classification_gne__c != 'Not Classified') :
                (String.isNotEmpty(acc.EDM_Business_Classification_gne__c) && acc.EDM_Business_Classification_gne__c != 'Not Classified')
            );
    }

    public static List<Speaker_Bureau_Membership_gne__c> getPreviousValues(List<Speaker_Bureau_Membership_gne__c> noLongerExcludedSBMs){
        Set<Id> sbmIds = new Set<Id>();
        for(Speaker_Bureau_Membership_gne__c sbm :noLongerExcludedSBMs){
            sbmIds.add(sbm.Id);
        }

        Map<Id, String> previousStatus = new Map<Id, String>();
        for(EDM_SpeakerBureau_Membership_History_gne__c sbmHistory :[SELECT EDM_Created_Date_gne__c, EDM_Membership_Status_gne__c,
                                                                         EDM_Speaker_Bureau_Membership_gne__c, EDM_Updated_By_gne__c 
                                                                        FROM EDM_SpeakerBureau_Membership_History_gne__c
                                                                        WHERE EDM_Speaker_Bureau_Membership_gne__c IN :sbmIds 
                                                                        ORDER BY EDM_Created_Date_gne__c DESC]){
            if(!previousStatus.keySet().contains(sbmHistory.EDM_Speaker_Bureau_Membership_gne__c) 
                                        && sbmHistory.EDM_Membership_Status_gne__c != 'Excluded'){
                previousStatus.put(sbmHistory.EDM_Speaker_Bureau_Membership_gne__c, sbmHistory.EDM_Membership_Status_gne__c);
            }
        }
        for(Speaker_Bureau_Membership_gne__c sbm :noLongerExcludedSBMs){
            String status = previousStatus.get(sbm.Id);
            if(status == 'Pending'){
                status = 'Nominated';
            }
            sbm.Speaker_Status_gne__c = status;
        }
        return noLongerExcludedSBMs;
    }
}