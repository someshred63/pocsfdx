/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-08-21
*  Description: This is a helper class for GNE_SFA2_MedComm_Trigger
*  Test class: GNE_SFA2_MedComm_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_MedComm_Trigger_Helper {
	
	static final String SOBJECT_TYPE_NAME = 'Medical_Communication_gne__c';
    static final String RECORD_TYPE_NAME = 'Referral';
    static final String RECORD_TYPE_NAME_CANADA = 'ReferralCanada';
    
    public static Id getReferralRecordTypeId() {
    	RecordType referralRecordType = [Select Id from RecordType where Name =: RECORD_TYPE_NAME and SobjectType =: SOBJECT_TYPE_NAME and IsActive =: true limit 1];
    	return referralRecordType.id;
    }
    
    public static Id getReferralCanadaRecordTypeId() {
    	RecordType referralRecordType = [Select Id from RecordType where Name =: RECORD_TYPE_NAME_CANADA and SobjectType =: SOBJECT_TYPE_NAME and IsActive =: true limit 1];
    	return referralRecordType.id;
    }
}