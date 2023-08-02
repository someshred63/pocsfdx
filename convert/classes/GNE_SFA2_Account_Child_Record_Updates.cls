/************************************************************
*  @author: Bartosz Osowiecki, Roche
*  Date: 2012-12-19
*  Description: Helper class for GNE_SFA2_Account_Trigger
*  Test class: GNE_SFA2_Account_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Account_Child_Record_Updates{

    public static final String STEWARDSHIP_SYSTEM_NAME = 'SFDC';
    public static final String DCR_RECORD_TYPE_SYSTEM_CREATED = 'System Created';
    public static final String DCR_DEFAULT_VENDOR_TYPE = 'sfdc';
    public static final String DCR_DEFAULT_STATUS = 'Submitted';
    public static final String RECORD_TYPE_DOC = 'Department of Corrections Location';
    public static final String ALTERNATE_NAME_TYPE = 'Formerly Known As (FKA)';
    public static final String ALTERNATE_NAME_SOURCE = 'GENENTECH';
    public static final String ALTERNATE_NAME_NOTES = 'Created in SaveOldAccountNames trigger';
    public static final String ALTERNATE_NAME_STATUS = 'Active';
    private static Id recordTypeIdForSystemCreatedDCR;

    public static final Map<String,String> SPEAKER_CLASSIFICATION_TO_SCOPE_MAP = new Map<String,String>{
        'Local' => 'Community',
        'Global' => 'National'};

    private static void runHospitalDepartmentOnAfterInsert(List<Account> triggerNew) {
        Acct_Hospital_Dept_onCreate_Helper.triggerHelperMethod(new Map<Id,Account>(triggerNew).keySet());
    }

    /**
        This trigger ensures that once a BOT stewardship has been rejected
        a DCR ticket is automatically created for internal stewardship
    **/

    private static void createDCRForInternalStewardship(List<Account> triggerOld, List<Account> triggerNew) {
        List<Change_Request_gne__c> newDCRs=new List<Change_Request_gne__c>();
        List<Change_Request_gne__Share> newDCRShares=new List<Change_Request_gne__Share>();
        List<Id> creatorsId=new List<Id>();

        Integer accSize = triggerNew.size();
        for (Integer i = 0 ;  i < accSize; i++)  {
            Account accNew = triggerNew[i];
            Account accOld = triggerOld[i];

            if(accNew.Stewardship_System_Name_gne__c==STEWARDSHIP_SYSTEM_NAME && accOld.Stewardship_System_Name_gne__c!=STEWARDSHIP_SYSTEM_NAME) {
                string rs='Account Stewardship changed ';
                if ( accOld.Stewardship_System_Name_gne__c != null ) {
                    rs+=  ' from ' + accOld.Stewardship_System_Name_gne__c;
                }

                rs+= ' to Internal Stewardship System. ';

                if( accNew.Internal_Stewardship_Reason_gne__c !=null ) {
                    rs+= ' Reason Code received: ' + accNew.Internal_Stewardship_Reason_gne__c;
                } else {
                    rs+= ' No Reason Code received from CADS.';
                }

                newDCRs.add(
                    new Change_Request_gne__c(
                        RecordTypeId = getRecordTypeIdForSystemCreatedDCR(),
                        Type_gne__c = DCR_RECORD_TYPE_SYSTEM_CREATED,
                        Description_gne__c = rs,
                        Account_gne__c = accNew.Id,
                        Vendor_Type_gne__c = DCR_DEFAULT_VENDOR_TYPE,
                        Status_gne__c = DCR_DEFAULT_STATUS));

                creatorsId.add(accNew.OwnerId);
            }
        }

        insert newDCRs;

        Integer newDcrSize = newDCRs.size();
        for (Integer i = 0 ;  i < newDcrSize; i++)  {
            newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(creatorsId[i],newDCRs[i],'Read',Change_Request_gne__Share.RowCause.Original_Owner_gne__c));
        }
        insert newDCRShares;
    }

    private static Id getRecordTypeIdForSystemCreatedDCR() {
    	if(recordTypeIdForSystemCreatedDCR==null) {
    		RecordTypeInfo rtInfo = Change_Request_gne__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(DCR_RECORD_TYPE_SYSTEM_CREATED);
    		recordTypeIdForSystemCreatedDCR = rtInfo!=null ? rtInfo.getRecordTypeId() : null;
    	}

    	return recordTypeIdForSystemCreatedDCR;
    }

    private static void createDoCLocationAffiliation(List<Account> triggerOld, List<Account> triggerNew) {
        Map <Id, Id> newAffMap = new Map <Id, Id>();
        Integer accSize = triggerNew.size();
        for (Integer i=0; i<accSize; i++) {
            Account accNew = triggerNew[i];
            Account accOld = triggerOld[i];

            if (accNew.Record_Type_Name_gne__c == RECORD_TYPE_DOC &&
                accOld.Parent_DoC_gne__c != accNew.Parent_DoC_gne__c) {

                newAffMap.put(accNew.Id, accNew.Parent_DoC_gne__c);
            }
        }

        if ( newAffMap.size() > 0 ) {
            DOC_Location_Create.Create_Affiliation_On_Parent_Change(newAffMap);
        }
    }

    private static void assignAMSIdToDCR(List<Account> triggerOld, List<Account> triggerNew) {
        List<Id> acctIdList=new List<Id>();
        Integer accSize = triggerNew.size();
        for (Integer i = 0; i< accSize;i++)  {
            Account accNew  = triggerNew[i];
            Account accOld  = triggerOld[i];

            if( accNew.Stewardship_System_Name_gne__c == GNE_SFA2_Account_Trigger_Helper.DEFAULT_STEWARDSHIP_SYSTEM_NAME &&
                accNew.ams_id_gne__c != null &&
                accOld.ams_id_gne__c == null) {

                acctIdList.add(accNew.Id);
            }
        }

        if ( acctIdList.size() > 0 ) {
            ChangeRequestControllerHelper.moveToAMSQueueOnAccountAMSIdUpdate(acctIdList);
        }
    }

    private static void saveAccountOldNames(List<Account> triggerOld, List<Account> triggerNew) {
        List <Alternate_Name_gne__c> altNames = new List<Alternate_Name_gne__c>();
        String newName = '';
        String oldName = '';

        try {
            Integer i = 0;
            for (Account accNew : triggerNew) {
                Account accOld = triggerOld[i++];
                if (accNew.IsPersonAccount) {
                    newName = accNew.FirstName +' ' + accNew.LastName;
                    oldName = accOld.FirstName +' ' + accOld.LastName;
                } else {
                    newName = accNew.Name ;
                    oldName = accOld.Name ;
                }

                if (newName != oldName )
                {
                    Alternate_Name_gne__c altName = new Alternate_Name_gne__c();
                    altName.Alternate_Name_gne__c = oldName.abbreviate(Alternate_Name_gne__c.Alternate_Name_gne__c.getDescribe().getLength());
                    altName.Alternate_Name_Type_gne__c = ALTERNATE_NAME_TYPE;
                    altName.Source_gne__c = ALTERNATE_NAME_SOURCE;
                    altName.Account_Name_gne__c = accNew.Id;
                    altName.Notes_gne__c = ALTERNATE_NAME_NOTES;
                    altName.Status_gne__c = ALTERNATE_NAME_STATUS;
                    altNames.add(altName);
                }
            }

            if (altNames.size() > 0) {
                insert altNames;
            }
        } catch ( Exception e) {
            System.debug ( 'Exception occured. getMessage--> ' + e.getMessage() );
            InsertErrorLog(e,oldName,newName);
        }
    }
  // Error Handeling - Inserting Error Records in Error Log Table
    public static void InsertErrorLog(Exception Error, string accOldId, string accNewId){
        List<Error_Log_gne__c> errorLogList = new List<Error_Log_gne__c>();
        try
        {
          errorLogList.add(new Error_Log_gne__c(Object_Name__c = 'Account',
                                      Error_Level_gne__c = 'High',
                                      Snippet_Name__c = 'Account Trigger - Validation Rules',
                                      Code_Type__c = 'Apex Class',
                                      Error_Description__c = GlobalUtils.getExceptionDescription(Error) + ':Old Id:'+accOldId+ ':New Id'+accNewId,
                                      User_Name__c = UserInfo.getUserName()));

        if(errorLogList.size() > 0)
            insert errorLogList;
        }
        catch(exception ex)
        {
            system.debug('ERROR WHILE EXC LOG METHOD.............' + ex.getMessage());
        }
        finally
        {
            errorLogList.clear();
        }
    }
    //
    private static void updateSpeakerBureauMemberships(List<Account> triggerOld, List<Account> triggerNew) {
        Map<Id,String> accountsWithUpdatedClinicalClassification = new Map<Id,String>();
        Map<Id,String> accountsWithUpdatedBusinessClassification = new Map<Id,String>();
        Map<Id,String> accountsWithUpdatedExclusionStatus = new Map<Id,String>();
        Datetime currentTime = System.now();
        String currentYear = String.valueOf(currentTime.year());
        Map<Id,Account> triggerNewMap = new Map<Id,Account>(triggerNew);
        Map<Id,Set<Speaker_Bureau_Membership_gne__c>> accountsWithUpdatedSBMs = new Map<Id,Set<Speaker_Bureau_Membership_gne__c>>();

        Integer i = 0;
        for (Account accNew : triggerNew) {
            Account accOld = triggerOld[i++];

            if(accNew.EDM_Business_Classification_gne__c != accOld.EDM_Business_Classification_gne__c){
                accountsWithUpdatedBusinessClassification.put(accNew.Id,accNew.FirstName + ' ' + accNew.LastName);
            }
            if(accNew.EDM_Clinical_Classification_gne__c != accOld.EDM_Clinical_Classification_gne__c){
                accountsWithUpdatedClinicalClassification.put(accNew.Id,accNew.FirstName + ' ' + accNew.LastName);
            }

            if(accNew.AGS_EX_Exclusion_Status_gne__c != accOld.AGS_EX_Exclusion_Status_gne__c) {
                accountsWithUpdatedExclusionStatus.put(accNew.Id,accNew.FirstName + ' ' + accNew.LastName);
            }
        }

        Set<Id> accountsWithUpdatedClassificationOrExclusion = new Set<Id> (accountsWithUpdatedClinicalClassification.keySet());
        accountsWithUpdatedClassificationOrExclusion.addAll(accountsWithUpdatedBusinessClassification.keySet());
        accountsWithUpdatedClassificationOrExclusion.addAll(accountsWithUpdatedExclusionStatus.keySet());

        List<Speaker_Bureau_Membership_gne__c> speakerBureauMemberships =
                [SELECT Id, Bureau_Member_gne__c,Speaker_Bureau_ID_gne__r.Name, Speaker_Bureau_ID_gne__r.Speaker_Bureau_Type_gne__c, Name
                 FROM Speaker_Bureau_Membership_gne__c
                 WHERE Bureau_Member_gne__c in :accountsWithUpdatedClassificationOrExclusion
                    AND Speaker_Bureau_ID_gne__r.Speaker_Bureau_Year_gne__c >= :currentYear for update];


        for(Speaker_Bureau_Membership_gne__c membership : speakerBureauMemberships) {
            Account acc = triggerNewMap.get(membership.Bureau_Member_gne__c);
            Boolean needToAddToAccountsWithUpdatedSBMs = false;

            if (accountsWithUpdatedBusinessClassification.keySet().contains(membership.Bureau_Member_gne__c) &&
                membership.Speaker_Bureau_ID_gne__r.Speaker_Bureau_Type_gne__c == 'Business') {
                updateSpeakerScopeField(membership, acc.EDM_Business_Classification_gne__c);
                needToAddToAccountsWithUpdatedSBMs = true;
            }

            if (accountsWithUpdatedClinicalClassification.keySet().contains(membership.Bureau_Member_gne__c) &&
                membership.Speaker_Bureau_ID_gne__r.Speaker_Bureau_Type_gne__c == 'Clinical') {
                updateSpeakerScopeField(membership, acc.EDM_Clinical_Classification_gne__c);
                needToAddToAccountsWithUpdatedSBMs = true;
            }

            if (accountsWithUpdatedExclusionStatus.keySet().contains(membership.Bureau_Member_gne__c)) {
                membership.Exclusion_Status_gne__c = ( acc.AGS_EX_Exclusion_Status_gne__c == 'Request Pending' ) ? 'Check Pending' : acc.AGS_EX_Exclusion_Status_gne__c;

                if (membership.Exclusion_Status_gne__c == 'Excluded') {
                    needToAddToAccountsWithUpdatedSBMs = true;
                }
            }

            if (needToAddToAccountsWithUpdatedSBMs) {
                if(!accountsWithUpdatedSBMs.containsKey(acc.Id)) {
                    accountsWithUpdatedSBMs.put(acc.Id, new Set<Speaker_Bureau_Membership_gne__c>());
                }

                accountsWithUpdatedSBMs.get(acc.Id).add(membership);
            }
        }


        GNE_SFA2_Account_Trigger_Helper.setAccountsWithUpdatedSBMs(accountsWithUpdatedSBMs);

        update speakerBureauMemberships;
    }

    private static void updateSpeakerScopeField(Speaker_Bureau_Membership_gne__c membership, String currentClassification) {
        if(SPEAKER_CLASSIFICATION_TO_SCOPE_MAP.containsKey(currentClassification)) {
            membership.Speaker_Scope_gne__c = SPEAKER_CLASSIFICATION_TO_SCOPE_MAP.get(currentClassification);
        } else {
            membership.Speaker_Scope_gne__c = currentClassification;
        }
    }

    private static void processChildrenAfterDelete(List<Account> triggerOld) {
        GNE_SFA2_Account_Trigger_Helper.cacheAccountChildren(new Map<Id,Account>(triggerOld).keySet());

        List<Affiliation_vod__c> affiliationToDel = new List<Affiliation_vod__c> ();

        for (Account accOld : triggerOld) {
            Account acct = GNE_SFA2_Account_Trigger_Helper.getCachedAccount(accOld.Id);

            Id masterRecordId = accOld.masterRecordId;
            if (masterRecordId == null) {
                for (Affiliation_vod__c afilRec : acct.Affiliation_vod__r) {
                    affiliationToDel.add(new Affiliation_vod__c(Id = afilRec.Id));
                }

                for (Affiliation_vod__c afilRec : acct.Affiliation_vod__pr) {
                    affiliationToDel.add(new Affiliation_vod__c(Id = afilRec.Id));
                }
            }
        }

        delete affiliationToDel;
    }

    private static void insertMergeHistoryAfterDelete(List<Account> triggerOld) {
        List <Account_Merge_History_vod__c> newMergeRecords = new List<Account_Merge_History_vod__c> ();
        Set <Id> accts = new Set<Id> ();

        for (Account accOld : triggerOld) {
            if (accOld.MasterRecordId != null && accOld.IsPersonAccount == true) {
                accts.add(accOld.MasterRecordId);
            }
        }

        Map<Id, Account> accMap = null;

        if (accts.size() > 0) {
            accMap = new Map<Id,Account>([SELECT Id, PersonContactId FROM Account where Id in :accts]);
        }

        for (Account accOld : triggerOld) {
            // if the Master != null then we have a merge.
            if (accOld.MasterRecordId != null) {
                Account_Merge_History_vod__c newMerge = new Account_Merge_History_vod__c (Name = accOld.Id, Account_vod__c  = accOld.MasterRecordId);
                if (accOld.IsPersonAccount == true) {
                    if (accMap != null) {
                        Account lAcct = accMap.get(accOld.MasterRecordId);
                        if (lAcct != null) {
                            newMerge.PersonContactId_vod__c = accOld.PersonContactId;
                            newMerge.Account_PersonContactId_vod__c = lAcct.PersonContactId;
                        }
                    }
                }
                newMergeRecords.add(newMerge);
            }
        }

        if (newMergeRecords.size() > 0 ) {
            insert newMergeRecords;
        }
    }

    private static void updateMergeTypeCandidates(List<Account> triggerOld, List<Account> triggerNew) {
    	Integer idx = 0;
    	Map<Id,String> approvalStatuses = new Map<Id,String>();

    	for(Account newRec : triggerNew) {
    		Account oldRec = triggerOld[idx++];

    		if(newRec.DCH_Approval_Status_gne__c!=oldRec.DCH_Approval_Status_gne__c) {
    			approvalStatuses.put(newRec.Id, newRec.DCH_Approval_Status_gne__c);
    		}
    	}

    	if(!approvalStatuses.isEmpty()) {
    		Merge_Type_Util.updateCandidatesApprovalStatus(approvalStatuses);
    	}
    }

    private static void insertMces(List<Account> triggerNew) {
        Map<String,Account> mdmIdToAccMap = new Map<String,Account>();
        Map<Id,Account> accIdToAccMap = new Map<Id,Account>();
        for(Account newRec : triggerNew) {
            if(String.isNotBlank(newRec.MDMId_gne__c) && newRec.isPersonAccount) {
                mdmIdToAccMap.put(newRec.MDMId_gne__c.toUpperCase(), newRec);
                accIdToAccMap.put(newRec.Id, newRec);
            }
        }

        if(!mdmIdToAccMap.isEmpty()) {
            List<Staging_MCE_gne__c> stgMces = [
                SELECT MDM_Id_gne__c, Team_Code_gne__c, Subteam_Code_gne__c, Brand_gne__c, Onlabel_gne__c
                FROM Staging_MCE_gne__c
                WHERE MDM_Id_gne__c IN :mdmIdToAccMap.keySet()
                LIMIT 2000
            ];

            List<MCE_gne__c> mcesToInsert = new List<MCE_gne__c>();

            for(Staging_MCE_gne__c smce : stgMces) {
                Account acc = mdmIdToAccMap.get(smce.MDM_Id_gne__c.toUpperCase());
                MCE_gne__c mce = new MCE_gne__c(
                    Account_gne__c = acc.Id,
                    Team_Code_gne__c = smce.Team_Code_gne__c, Subteam_Code_gne__c = smce.Subteam_Code_gne__c,
                    Brand_gne__c = smce.Brand_gne__c, OnLabel_gne__c = smce.OnLabel_gne__c
                );

                mcesToInsert.add(mce);
            }

            if(!mcesToInsert.isEmpty()) {
	            Database.SaveResult[] sResult = Database.insert(mcesToInsert, false);

	            Integer idx = 0;
	            for(Database.SaveResult sr : sResult) {
	               if (!sr.isSuccess()) {
	                   Account acc = accIdToAccMap.get(mcesToInsert[idx].Account_gne__c);

	                   for(Database.Error err : sr.getErrors()) {
	                       acc.addError(err.getMessage());
	                   }
	               }

	               idx++;
	            }
            }
        }
    }

    private static void removeAffiliationForDeactivatedAccounts(List<Account> triggerOld, List<Account> triggerNew) {
        try {
            Set<Id> accountsToClear = new Set<Id>();
            Integer index = 0;
            for(Account updatedAccount : triggerNew) {
                Account oldAccount = triggerOld[index++];

                if(oldAccount.Status_gne__c == 'Active' && updatedAccount.Status_gne__c == 'Inactive') {
                    if(isAccountManaged(oldAccount, updatedAccount)) {
                        accountsToClear.add(updatedAccount.Id);
                    }
                }
            }

            if(!accountsToClear.isEmpty()) {
                List<Affiliation_vod__c> affiliationsToRemove = [SELECT Id FROM Affiliation_vod__c WHERE (From_Account_vod__c IN :accountsToClear OR
                                                                To_Account_vod__c IN :accountsToClear) AND Region_Code_gne__c = 2
                                                                AND ((
                                                                    (From_Account_vod__r.Account_Type_gne__c = 'Hospital' AND
                                                                            (To_Account_vod__r.Account_Type_gne__c = 'Physician' OR To_Account_vod__r.Account_Type_gne__c LIKE '%Nurse%'))
                                                                    OR
                                                                    (From_Account_vod__r.Account_Type_gne__c LIKE '%Pharmacy' AND To_Account_vod__r.Account_Type_gne__c = 'Pharmacist')
                                                                ) OR ((To_Account_vod__r.Account_Type_gne__c = 'Hospital' AND
                                                                    (From_Account_vod__r.Account_Type_gne__c = 'Physician' OR From_Account_vod__r.Account_Type_gne__c LIKE '%Nurse%'))
                                                                    OR
                                                                    (To_Account_vod__r.Account_Type_gne__c LIKE '%Pharmacy' AND From_Account_vod__r.Account_Type_gne__c = 'Pharmacist'))
                                                                )];
                delete affiliationsToRemove;
            }
        } catch(Exception ex) {
            System.debug('removeAffiliationForDeactivatedAccounts: '+ex.getMessage());
        }
    }

    private static Boolean isAccountManaged(Account oldAccount, Account updatedAccount) {
        Set<String> managedAccountTypes  = new Set<String>{ 'Physician', 'Hospital', 'Pharmacist'};
        return oldAccount.Account_Type_gne__c == updatedAccount.Account_Type_gne__c && (managedAccountTypes.contains(updatedAccount.Account_Type_gne__c) ||
            updatedAccount.Account_Type_gne__c.contains('Nurse') || updatedAccount.Account_Type_gne__c.contains('Pharmacy'));
    }

    public static void onAfterUpdate(List<Account> triggerOld, List<Account> triggerNew) {
        createDCRForInternalStewardship(triggerOld, triggerNew);
        saveAccountOldNames(triggerOld, triggerNew);
        updateSpeakerBureauMemberships(triggerOld, triggerNew);
        updateMergeTypeCandidates(triggerOld, triggerNew);
        
        if(!GNE_SFA2_Util.isMergeMode()){
        	createDoCLocationAffiliation(triggerOld, triggerNew);
	        assignAMSIdToDCR(triggerOld, triggerNew);

            if(!GNE_SFA2_Address_Trigger_Helper.inAddressTrig()) {
            	GNE_SFA2_DCR_Util.onAfterUpdateParent(triggerOld, triggerNew);
            }

            if(GNE_SFA2_Util.isCanadaUser()) {
                removeAffiliationForDeactivatedAccounts(triggerOld, triggerNew);
            }
        }
    }

    public static void onAfterInsert(List<Account> triggerOld, List<Account> triggerNew) {
        if(!GNE_SFA2_Util.isMergeMode()){
        	runHospitalDepartmentOnAfterInsert(triggerNew);
        	insertMces(triggerNew);
    	}
    }

    public static void onAfterDelete(List<Account> triggerOld) {
        if(!GNE_SFA2_Util.isMergeMode()){
        	processChildrenAfterDelete(triggerOld);
        }
        insertMergeHistoryAfterDelete(triggerOld);
    }
}