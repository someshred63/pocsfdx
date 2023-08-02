/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-01-28
*  Description: 
*    
*  Modification History
*  Date          Name                           Description
*  8/31/2012    Raghavendar Madireddy           Added code to update field Batch_Fax_AA_Maint_Sent_Date_gne__c to null
                                                for all the cases if patient contains atleast one Active case.
                                                BUG # 23797 && PFS - 432
*************************************************************/

public without sharing class GNE_CM_Batch_Fax_AA_post_processing 
{   
    private static List<Error_log_gne__c> errorLogList = new List<Error_log_gne__c>();
    public static Boolean executionDisabled = false;
    public static Boolean ActiveStatus = false;
    @future
    public static void processAddressData(Map<Id, Boolean> proactiveBIMap)
    {
        if(executionDisabled)
            return;
         
        System.debug('proactiveBIMap==='+proactiveBIMap);

        Set<String> caseBatchFaxAAValidStatus = getValidStatuses();
        Map<Id, List<Case>> accountCaseMap = new Map<Id, List<Case>>();

        for(Case c : [SELECT c.Id, c.Patient_gne__c, c.Address_gne__c, c.Case_Treating_Physician_gne__c, c.CaseNumber, c.Status, c.Batch_Fax_AA_Maint_Sent_Date_gne__c, c.Batch_Fax_AA_Updated_By_gne__c, c.Batch_Fax_AA_Maint_Updated_Date_gne__c, c.Batch_Fax_AA_Target_Date_gne__c, Batch_Fax_AA_Updated_By_gne__r.Name, Batch_Fax_AA_Maint_Sent_Overriden_gne__c 
                            FROM CASE c
                            WHERE c.Case_Treating_Physician_gne__c IN: proactiveBIMap.keySet()
                            AND c.RecordType.Name = 'C&R - Standard Case'
                            AND c.Product_gne__c = 'Rituxan RA'
                            AND (c.Batch_Fax_AA_Maint_Sent_Date_gne__c >= today OR c.Batch_Fax_AA_Maint_Sent_Date_gne__c = null)
                            ORDER BY c.Patient_gne__c ASC, c.CreatedDate DESC])
        {
            addCase2Collection(accountCaseMap, c);  
        }
        

        for(Id accountID : accountCaseMap.keySet())
        {
            if(!proactiveBIMap.get(accountID))
                removeCases(accountCaseMap.get(accountID)); 
            
            List<Case> allPatientCases = getAllPatientCases(accountCaseMap.get(accountID));
            recalculateEligibleCases(allPatientCases, caseBatchFaxAAValidStatus);                                       
        }       
    }
    
    @future 
    public static void processPatientData(Map<Id, Boolean> patientNotParticipatingMap)
    {
        if(executionDisabled)
            return;
                
        Set<String> caseBatchFaxAAValidStatus = getValidStatuses();
        List<Case> cases2recalculate = new List<Case>();
        List<Case> cases2remove = new List<Case>();

        for(Case c : [SELECT c.Id, c.Patient_gne__c, c.CaseNumber, c.Address_gne__c, c.Status, c.Batch_Fax_AA_Maint_Sent_Date_gne__c, c.Batch_Fax_AA_Updated_By_gne__c, c.Batch_Fax_AA_Maint_Updated_Date_gne__c, c.Batch_Fax_AA_Target_Date_gne__c, Batch_Fax_AA_Updated_By_gne__r.Name, Batch_Fax_AA_Maint_Sent_Overriden_gne__c 
                            FROM CASE c 
                            WHERE c.Patient_gne__c IN: patientNotParticipatingMap.keySet() 
                            AND c.RecordType.Name = 'C&R - Standard Case'
                            AND c.Product_gne__c = 'Rituxan RA'
                            AND (c.Batch_Fax_AA_Maint_Sent_Date_gne__c >= today OR c.Batch_Fax_AA_Maint_Sent_Date_gne__c = null)
                            ORDER BY c.Patient_gne__c ASC, c.CreatedDate DESC])
        {       
            if(patientNotParticipatingMap.get(c.Patient_gne__c))  
                cases2remove.add(c);                            
            else            
                cases2recalculate.add(c);           
            }            
                
        if(cases2recalculate.size() > 0)
            recalculateEligibleCases(cases2recalculate, caseBatchFaxAAValidStatus);
        
        if(cases2remove.size() > 0)
            removeCases(cases2remove);
    }
    
    @future 
    public static void processCaseData(Set<Id> patientIDs)
    {
        if(executionDisabled)
            return;
                    
        Set<String> caseBatchFaxAAValidStatus = getValidStatuses();
        List<Case> cases = [SELECT c.Id, c.Patient_gne__c, c.CaseNumber, Address_gne__c, c.Status, c.Batch_Fax_AA_Maint_Sent_Date_gne__c, c.Batch_Fax_AA_Updated_By_gne__c, c.Batch_Fax_AA_Maint_Updated_Date_gne__c, c.Batch_Fax_AA_Target_Date_gne__c, Batch_Fax_AA_Maint_Sent_Overriden_gne__c 
                            FROM CASE c
                            WHERE c.Patient_gne__c IN: patientIDs
                            AND c.RecordType.Name = 'C&R - Standard Case'
                            AND c.Product_gne__c = 'Rituxan RA'
                            AND (c.Batch_Fax_AA_Maint_Sent_Date_gne__c >= today OR c.Batch_Fax_AA_Maint_Sent_Date_gne__c = null)
                            ORDER BY c.Patient_gne__c ASC, c.CreatedDate DESC];     
        if(cases.size() > 0)                    
            recalculateEligibleCases(cases, caseBatchFaxAAValidStatus);
    }
    
    public static Boolean fieldsAllowed4EditChanged(Case oldCase, Case newCase, Map<String, Schema.SobjectField> caseFields, Id crsRecordTypeId)
    {
        Boolean result = false;
        Integer changedFieldsCounter = 0;
        
        Set<String> fieldsAllowed = new Set<String>{'batch_fax_aa_maint_sent_date_gne__c', 'batch_fax_aa_updated_by_gne__c', 'batch_fax_aa_maint_updated_date_gne__c', 'batch_fax_aa_maint_sent_overriden_gne__c'};
        if(oldCase.RecordTypeId != crsRecordTypeId)
        {
            return result;
        }
        
        for(String fieldName : caseFields.keySet())
        {
            if(oldCase.get(fieldName) != newCase.get(fieldName))
            {
                changedFieldsCounter++;
                if(fieldsAllowed.contains(fieldName.toLowerCase()))
                {               
                    result = true;
                }
                else
                {
                    result = false;                    
                    break;
                }                   
            }           
        }        
        if(changedFieldsCounter == 0)
        {
            result = true;
        }        
        return result;
    }

    public static Set<String> getMaintSentDateEditableProfiles()
    {
    	Set<String> profiles = new Set<String>();   
    	/*  
        List<Environment_Variables__c> envVar = GNE_CM_Environment_variable.get_envVariable(new Set<String>{'GNE_CM_AA_Batch_Fax_Admin_ByPass'});      
        for (Environment_Variables__c ev : envVar)
        {
            profiles.add(ev.Value__c.toLowerCase());
        }      
        */    
	    String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
	    for(GNE_CM_AA_Batch_Fax_Admin_ByPass__c envVar : GNE_CM_AA_Batch_Fax_Admin_ByPass__c.getAll().values()){
			if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
				profiles.add(envVar.Value__c.toLowerCase());
			}
		}       
        return profiles;    
    }

    private static void addCase2Collection(Map<Id, List<Case>> accountCaseMap, Case caseItem)
    {
        if(accountCaseMap.containsKey(caseItem.Case_Treating_Physician_gne__c))
            accountCaseMap.get(caseItem.Case_Treating_Physician_gne__c).add(caseItem);
        else
        {
            List<Case> caseList = new List<Case>();
            caseList.add(caseItem);
            accountCaseMap.put(caseItem.Case_Treating_Physician_gne__c, caseList);
        }
    }
    
    private static void removeCases(List<Case> cases)
    {
        errorLogList.clear();
        List<Case> case2Update = new List<Case>();
        for(Case caseItem : cases)
        {
            if (caseItem.Batch_Fax_AA_Maint_Sent_Date_gne__c >= System.Today())
            {       
                logAndEmailErr(caseItem.CaseNumber, caseItem.Batch_Fax_AA_Maint_Sent_Date_gne__c, caseItem.Batch_Fax_AA_Updated_By_gne__r.Name, caseItem.Batch_Fax_AA_Maint_Updated_Date_gne__c);           
                caseItem.Batch_Fax_AA_Maint_Sent_Date_gne__c = null;
                caseItem.Batch_Fax_AA_Updated_By_gne__c = null;
                caseItem.Batch_Fax_AA_Maint_Updated_Date_gne__c = null;
                caseItem.Batch_Fax_AA_Maint_Sent_Overriden_gne__c = false;
                case2Update.add(caseItem);
            }
        }   
        if(errorLogList.size() > 0)
        {
            insert errorLogList;
            executionDisabled = true;
            update case2Update;
            executionDisabled = false;
        }   
    }
        
    private static void recalculateEligibleCases(List<Case> cases, Set<String> caseBatchFaxAAValidStatus)
    {     
    	  
        Date maintSentDate;     
        Id currentPatient;
        Id previousPatient;
        List<Case> cases2Update = new List<Case>();
        List<Case> activeCases2Update = new List<Case>();      
        List<Case> casesWithMaintDate = new List<Case>();        
        Map<Id, Case> caseMap = new Map<Id, Case>(cases);
        Set<Id> casesWithBI = new Set<Id>();
        
        for (Benefit_Investigation_gne__c bi : [SELECT Case_BI_gne__c FROM Benefit_Investigation_gne__c
                                                WHERE Case_BI_gne__c IN: caseMap.keySet()])
        {
            if(!casesWithBI.contains(bi.Case_BI_gne__c))
            {
                casesWithBI.add(bi.Case_BI_gne__c);
            }
        }                
        
        for (Case caseItem : cases)
        {
        
            currentPatient = caseItem.Patient_gne__c;
            maintSentDate = null;
            
            if(caseItem.Status == 'Active' && ActiveStatus == false)
                    {      
                   ActiveStatus = true;
                } 
                       
            //validate eligibness of case           
            if (caseItem.Batch_Fax_AA_Target_Date_gne__c != null 
                && String.valueOf(caseItem.Batch_Fax_AA_Target_Date_gne__c).length() > 0                
                && caseBatchFaxAAValidStatus.contains(caseItem.Status.toLowerCase())
                && currentPatient != previousPatient
                && casesWithBI.contains(caseItem.Id))
            {                                                   
                Integer year = caseItem.Batch_Fax_AA_Target_Date_gne__c.year();
                Integer month = caseItem.Batch_Fax_AA_Target_Date_gne__c.month();               
                if (caseItem.Batch_Fax_AA_Target_Date_gne__c.day() < 14)
                    {                   
                        // Batch Fax AA Maint Sent Date on the 15th of each month                       
                        maintSentDate = date.newInstance(year, month, 15);
                    }
                    else
                    {                   
                        // Batch Fax AA Maint Sent Date on the last day of each month                       
                        Integer numberDays = date.daysInMonth(year, month);
                        maintSentDate = date.newInstance(year, month, numberDays);
                    }
                if(caseItem.Batch_Fax_AA_Maint_Sent_Overriden_gne__c == false)
                            {
                    caseItem.Batch_Fax_AA_Maint_Sent_Date_gne__c = maintSentDate;
                    casesWithMaintDate.add(caseItem);
                    cases2Update.add(caseItem);
                            }
                previousPatient = currentPatient;  
                    }                                 
            else //case is not eligible
                {
                if(caseItem.Batch_Fax_AA_Maint_Sent_Date_gne__c != null)
                    {                                    
                    caseItem.Batch_Fax_AA_Maint_Sent_Date_gne__c = null;                    
                }
                caseItem.Batch_Fax_AA_Maint_Sent_Overriden_gne__c = false;
                cases2Update.add(caseItem);                
            }                                                 
                    }

        //clear maint sent date for else cases from patient    
        for(Case caseMaintDate : casesWithMaintDate)
            {
            for(Case caseItem : cases)
            {
                if(caseMaintDate.Id != caseItem.Id 
                && caseMaintDate.Patient_gne__c == caseItem.Patient_gne__c 
                && caseItem.Batch_Fax_AA_Maint_Sent_Date_gne__c != null)
            {
                    caseItem.Batch_Fax_AA_Maint_Sent_Overriden_gne__c = false;
                    caseItem.Batch_Fax_AA_Maint_Sent_Date_gne__c = null;
                    cases2Update.add(caseItem);
                }
            }
            }
			
		if(ActiveStatus == true)
		{       	      	
			for(Case eachCase : cases2Update){   
				if(eachCase.Batch_Fax_AA_Maint_Sent_Date_gne__c != null) {  	
					eachCase.Batch_Fax_AA_Maint_Sent_Overriden_gne__c = false;
					eachCase.Batch_Fax_AA_Maint_Sent_Date_gne__c = null;
					activeCases2Update.add(eachCase);
				}
			}   
			executionDisabled = true;   
			//update activeCases2Update;
			List<Database.SaveResult> casesUpdateResults = Database.update(activeCases2Update, false);
            GNE_CM_MPS_Utils.createAndLogErrors(casesUpdateResults, 'Error in Updating activeCases2Update for Batch Fax Processing with ID: {sr}', new List<String>(), 'Case', 'GNE_CM_Batch_Fax_AA_post_processing.recalculateEligibleCases', activeCases2Update);
			executionDisabled = false;           	
		}
		else
		{
			executionDisabled = true;   
			//update cases2Update;
			List<Database.SaveResult> casesUpdateResults = Database.update(cases2Update, false);
            GNE_CM_MPS_Utils.createAndLogErrors(casesUpdateResults, 'Error in Updating cases2Update for Batch Fax Processing with ID: {sr}', new List<String>(), 'Case', 'GNE_CM_Batch_Fax_AA_post_processing.recalculateEligibleCases', cases2Update);
			executionDisabled = false;
			ActiveStatus = false;   
		}
	}
    
    private static Set<String> getValidStatuses()
    {
        Set<String> validStatuses = new Set<String>();    	
    	/*
        List<Environment_Variables__c> environmentVariables = GNE_CM_Environment_variable.get_envVariable(new Set<String>{'case_batch_fax_aa_valid_status'});
        
        for (Integer i = 0; i < environmentVariables.size(); i++)
        {
            validStatuses.add(environmentVariables[i].Value__c.toLowerCase());          
        }
        */
	    String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
	    for(case_batch_fax_aa_valid_status__c envVar : case_batch_fax_aa_valid_status__c.getAll().values()){
			if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
				validStatuses.add(envVar.Value__c.toLowerCase());
			}
		}
		
		return validStatuses;
    }
    
    private static List<Case> getAllPatientCases(List<Case> cases)
    {
        Set<Id> patientIDs = new Set<Id>();
        for(Case caseItem : cases)
        {
            patientIDs.add(caseItem.Patient_gne__c);
        }
        return [SELECT c.Id, c.Patient_gne__c, c.CaseNumber, Address_gne__c, c.Status, c.Batch_Fax_AA_Maint_Sent_Date_gne__c, c.Batch_Fax_AA_Updated_By_gne__c, c.Batch_Fax_AA_Maint_Updated_Date_gne__c, c.Batch_Fax_AA_Target_Date_gne__c, Batch_Fax_AA_Maint_Sent_Overriden_gne__c 
                            FROM CASE c
                            WHERE c.Patient_gne__c IN: patientIDs
                            AND c.RecordType.Name = 'C&R - Standard Case'
                            AND c.Product_gne__c = 'Rituxan RA'
                            AND (c.Batch_Fax_AA_Maint_Sent_Date_gne__c >= today OR c.Batch_Fax_AA_Maint_Sent_Date_gne__c = null)
                            ORDER BY c.Patient_gne__c ASC, c.CreatedDate DESC];  
    }
    
    private static void logAndEmailErr(String caseNumber, Date maintSentDate, String maintUpdatedByName, DateTime maintUpdatedByDate)
    {
        String updatedByDate = '';
        if(maintUpdatedByDate != null)
        {
            updatedByDate = maintUpdatedByDate.format();
        }       
        String warningText = 'Warning: Batch Fax AA Maint Override removed for Case'
                        + caseNumber 
                        + ' Batch Fax AA Maint Sent Date = '
                        + maintSentDate.format()
                        + ' Batch Fax AA Maint Updated By/Date = '
                        + maintUpdatedByName 
                        + ' ' 
                        + updatedByDate;
        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Low',
                                               Code_Type__c       = 'Apex Class',
                                               Snippet_Name__c    = 'GNE_CM_Batch_Fax_AA_post_processing',
                                               User_Name__c       = UserInfo.getUserName(),
                                               Object_Name__c     = 'Case',    
                                               Error_Description__c  = warningText
                                               ));
        Map<String, GNE_CM_Batch_Fax_Err_Mail_Rcp__c> emailAddress = CustomSettingsHelper.batchFaxSelf().getEmailRecipient();
        
        sendEmail(emailAddress.get(CustomSettingsHelper.BATCH_FAX_EMAIL_RECIPIENT).Email__c, 
                'Warning: Batch Fax AA Maint Override removed', warningText);
    }
    
    private static void sendEmail(String emailRecipient, String subject, String body)
    {
        Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
        message.setToAddresses(new String[]{emailRecipient});
        message.setSubject(subject);        
        message.setSenderDisplayName('GNE_CM_Batch_Fax_AA_post_processing');
        message.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.Singleemailmessage[] {message});
    }
}