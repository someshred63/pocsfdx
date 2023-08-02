public without sharing class SPCM_ICFRLogUtils {

    static Map <Id, Id> agreementTypeToActivationTimeline = new Map <Id, Id>();
    public static Boolean actionFromController = false;
    public static Boolean skipTriggerActions = false;

    public static void setActionFromController(Boolean action) {
        actionFromController = action;
    }

    /*****
    * @author Wojciech Jaskula
    *
    * @Description: This method Update activation timeline for each Log entry, as long as the status == 'New' , newRecords are records comming from ESB by Webservice SPCM_ICFR_Log_Webservice.
    * Method puts all activation timeline entries into map , after gets Contract Activation Timeline Id for given agreement type
    */
    public static void UpdateActivationTimeline(List<SPCM_ICFR_Log__c> newRecords) {

        //put all activation timeline entries into map
        for (Contract_Activation_Timeline__c t : [select id, Agreement_Type_MCC__c from Contract_Activation_Timeline__c]) {
            agreementTypeToActivationTimeline.put(t.Agreement_Type_MCC__c, t.id);
        }

        for (SPCM_ICFR_Log__c log : newRecords) {
            if (log.status__c == 'New' && log.Agreement_Type__c != null) {
                //get Contract Activation Timeline Id for given agreement type
                log.Contract_Activation_Timeline__c = agreementTypeToActivationTimeline.get(log.Agreement_Type__c);
            }
        }
    }
    
    public static void UpdateExpectedApprovedActivationDate(List<SPCM_ICFR_Log__c> records) {
        Set<Id> logIds = new Set<Id>();
    	for (SPCM_ICFR_Log__c record : records) {
    		system.debug(LoggingLEvel.error, record);
    		if (record.CUT_Approval_Id__c != null && 
    			(((SPCM_ICFR_Log__c)Trigger.oldMap.get(record.Id)).Status__c != record.Status__c || 
    			 ((SPCM_ICFR_Log__c)Trigger.oldMap.get(record.Id)).Contract_Activation_Timeline__c != record.Contract_Activation_Timeline__c)) {
    			logIds.add(record.Id);
    		}
    	}
    	if (!logIds.isEmpty()) {
    		system.debug(LoggingLEvel.error, logIds);
    		List<SPCM_ICFR_Log__c> logsToUpdate = new List<SPCM_ICFR_Log__c>();
    		for (SPCM_ICFR_Log__c record : [SELECT ID, Status__c, Expected_Activation_Date__c FROM SPCM_ICFR_Log__c WHERE ID in :logIds]) {
    			if (record.Status__c.startsWith('Pending') || record.Status__c.startsWith('In') || record.Status__c.startsWith('New')) {
    				logsToUpdate.add(new SPCM_ICFR_Log__c(Id = record.Id, Expected_Approved_Activation_Date__c = null));
    			} else {
    				logsToUpdate.add(new SPCM_ICFR_Log__c(Id = record.Id, Expected_Approved_Activation_Date__c = record.Expected_Activation_Date__c));
    			}
    		}
    		
    		system.debug(LoggingLEvel.error, logsToUpdate);
    		try {
    			SPCM_ICFRLogUtils.skipTriggerActions = true;
    			update logsToUpdate;	
    		} finally {
    			SPCM_ICFRLogUtils.skipTriggerActions = false;
    		}
    	}
    }
    

    /*****
    * @author Wojciech Jaskula
    *
    * @Description: This method validate all Required Fields , newRecords are records comming from ESB by Webservice SPCM_ICFR_Log_Webservice
    */
    public static void ValidateRequiredFields(List<SPCM_ICFR_Log__c> newRecords) {
        system.debug(newRecords);
        system.debug(SPCM_ICFR_Log_Webservice.IS_WEBSERVICE);
        system.debug(actionFromController);
        // Don't validate this if comming from ESB by WebService SPCM_ICFR_Log_Webservice
        if (SPCM_ICFR_Log_Webservice.IS_WEBSERVICE && actionFromController == false) {
            return;
        }

        //if user has admin permission set, skip validations
        List<string> adminPermissionSets = new List<string> {'SPCM_EC_SFDC_IT_Administrator', 'SPCM_EC_IT_Support', 'SPCM_Systems_Administrator'};
        Boolean IsAdminUser = [SELECT PermissionSetId  FROM PermissionSetAssignment
                               WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name in :adminPermissionSets
                                       limit 1].size() > 0;
        system.debug(isAdminUser);
        //if (IsAdminUser)
        //    return;
        system.debug('not admin user');
        for (SPCM_ICFR_Log__c log : newRecords) {
            system.debug(log.Status__c);
            system.debug(log.CARS_Activation_Date__c);
            // all MCC fields must be filled when changing status to New
            if ( log.Status__c != 'In Process'
                    && (  string.IsBlank(log.Account__c)
                          || log.Agreement_Type__c == null
                          || string.IsBlank(log.Contract_ID__c)
                          || string.IsBlank(log.Document_Type__c)
                          || log.Customer__c == null
                          || log.Effective_Date__c == null
                          || log.MCC_Manager__c == null
                          || log.MCC_Contract_Manager__c == null
                          || log.Created_Date__c == null)
               ) {
                System.debug(Logginglevel.ERROR, log.name + ': Please fill required fields before changing status to New.');
                log.addError(log.name + ': Please fill required fields before changing status to New.');
            }
            //activation date must be set before closing
            else if (log.Status__c == 'Closed' && log.CARS_Activation_Date__c == null) {
                System.debug(Logginglevel.ERROR, log.name + ': Please enter the Activation Date before changing status to Closed.');
                log.addError(log.name + ': Please enter the Activation Date before changing status to Closed.');
            }

            //C-ops contract manager must be set
            else if (log.Status__c != 'In Process' && log.Status__c != 'New' && log.C_Ops_Contract_Manager__c == null) {
                System.debug(Logginglevel.ERROR, log.name + ': Please enter C-Ops Contract Manager value.');
                log.addError(log.name + ': Please enter C-Ops Contract Manager value.');
            }
            system.debug(log);
        }
        

    }

    /*****
    * @author Wojciech Jaskula
    *
    * @Description: This method validate if Trigger contains {ARG} value 
    */
    public static void validateFieldArgumments(List<SPCM_ICFR_Log_Settings__c> newRecords) {
        for (SPCM_ICFR_Log_Settings__c record : newRecords) {
            if (!record.CMS_Environment_Url__c.contains('{ARG}')) {
                record.addError('Cms Record Id must contain {ARG} value');
            }
        }
    }

    /*****
    * @author Wojciech Jaskula
    *
    * @Description: This method is used in Trigger to prevent insert more than 1 record to Icfr Log Settings Object
    */
    public static void preventInsertingRecords(List<SPCM_ICFR_Log_Settings__c> newRecords) {
        List<SPCM_ICFR_Log_Settings__c> icfrList = [Select Id , CMS_Environment_Url__c FROM SPCM_ICFR_Log_Settings__c];
        for (SPCM_ICFR_Log_Settings__c record : newRecords) {
            if (!icfrList.isEmpty()) {
                record.addError('You can\'t add more than 1 record to settings');
            }
        }
    }
    /*****
    * @author Wojciech Jaskula
    *
    * @Description: This method is used to prevent deleting record from Icfr Log Settings Object
    */
    public static void preventDeleteingIcfrLogSettingRecord(List<SPCM_ICFR_Log_Settings__c> newRecords) {
        for (SPCM_ICFR_Log_Settings__c record : newRecords) {
            record.addError('You can\'t delete record from Settings');
        }   
    }
}