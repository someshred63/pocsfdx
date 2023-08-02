public class GNE_CRM_340B_Case_TriggerHandler {
    public final static String CASE_STATUS_NEW        = 'New';
    public final static String CASE_STATUS_HOLD       = 'Hold';
    public final static String CASE_STATUS_ASSIGNED   = 'Assigned';
    public final static String CASE_STATUS_ENGAGEMENT = 'Engagement';
    public final static String CASE_STATUS_INVOICED   = 'Invoiced';
    public final static String CASE_STATUS_CLOSED     = 'Closed';

    public final static String CASE_TYPE_INITIATIVE         = 'Initiative';
    public final static String CASE_TYPE_SELFDISCLOSURE     = 'Self-disclosure';
    public final static String CASE_TYPE_DIVERSION          = 'Diversion';
    public final static String CASE_TYPE_OUT_DUPLICATEDISC  = 'Duplicate Discount';
    public final static String CASE_TYPE_IN_DUPLICATEDISC   = 'Carve-In Duplicate Discounts';
    
    public final static String INVOICE_TYPE_NOTAPPLICABLE = 'Not Applicable';
    
    private final static String ERROR_FOR_NOTAPPLICABLE = 'Please clear the following fields as these are not required when there is no invoicing and when Invoice Type is set to <B>Not Applicable</b> :{0}';
    
    private final static GNE_MCCO_340B_ProductMapping__c [] productMaping = GNE_MCCO_340B_ProductMapping__c.getall().values();
    private static Map<String, String> productName2code = new Map<String, String>();
    
    static {
        for(GNE_MCCO_340B_ProductMapping__c pm :productMaping){
            productName2code.put(pm.Product_Name__c, pm.Name);
        }
    }

    public static void onBeforeInsert(List<SObject> recordsNew) {
        GNE_CRM_340B_Case_TriggerHandler.setMPN(recordsNew);
        GNE_CRM_340B_Case_TriggerHandler.setState(recordsNew, null);
        GNE_CRM_340B_Case_TriggerHandler.updateNDConTrigger();
        GNE_CRM_340B_Case_TriggerHandler.setStatus(recordsNew);
        GNE_CRM_340B_Case_TriggerHandler.setCompletionDate(recordsNew);
        GNE_CRM_340B_Case_TriggerHandler.setApprovedDate();
        GNE_CRM_340B_Case_TriggerHandler.setIndirectRecoveryTotalAmount();
        GNE_CRM_340B_Case_TriggerHandler.setFutureSavingsTotalAmount();
    }

    public static void onBeforeUpdate(List<SObject> recordsNew, Map<Id, SObject> recordsOld) {
        GNE_CRM_340B_Case_TriggerHandler.setState(recordsNew, (Map<Id, GNE_CRM_340B_Case__c>) recordsOld);
        GNE_CRM_340B_Case_TriggerHandler.updateNDConTrigger();
        GNE_CRM_340B_Case_TriggerHandler.setStatus(recordsNew);
        GNE_CRM_340B_Case_TriggerHandler.setCompletionDate(recordsNew);
        GNE_CRM_340B_Case_TriggerHandler.setApprovedDate();
        GNE_CRM_340B_Case_TriggerHandler.setIndirectRecoveryTotalAmount();
        GNE_CRM_340B_Case_TriggerHandler.setFutureSavingsTotalAmount();
    }

    public static void onBeforeDelete(List<SObject> recordsOld) {
        GNE_CRM_340B_Case_TriggerHandler.validateDeletion(recordsOld);
    }

    public static void onAfterInsert(List<SObject> recordsNew, Map<Id, SObject> recordsOld) {
        GNE_CRM_340B_Case_TriggerHandler.setOpenCaseOnAccount(recordsNew);
        GNE_CRM_340B_Case_TriggerHandler.createTasks(recordsNew, (Map<Id, GNE_CRM_340B_Case__c>) recordsOld, Trigger.isInsert, Trigger.isUpdate);
    }

    public static void onAfterUpdate(List<SObject> recordsNew, Map<Id, SObject> recordsOld) {
        GNE_CRM_340B_Case_TriggerHandler.setOpenCaseOnAccount(recordsNew);
        GNE_CRM_340B_Case_TriggerHandler.createTasks(recordsNew, (Map<Id, GNE_CRM_340B_Case__c>) recordsOld, Trigger.isInsert, Trigger.isUpdate);
    }

    public static void onAfterDelete(List<SObject> recordsOld) {
        GNE_CRM_340B_Case_TriggerHandler.setOpenCaseOnAccount(recordsOld);
    }

    public static void validateDeletion(List<GNE_CRM_340B_Case__c> cases) {
	    for (GNE_CRM_340B_Case__c c : cases) {
	    	if (c.Case_Status__c != CASE_STATUS_NEW) {
	    		c.addError('You can only delete a case only with status New');
	    	}
	    }
    }

    public static Boolean isCeContactedSetUp(GNE_CRM_340B_Case__c c) {
        return c.CE_Contacted__c != null;
    }

    public static Boolean isInvoiceRequested(GNE_CRM_340B_Case__c c) {
        return c.Invoice_Requested__c != null;
    }

    public static Boolean isInvoiceTypeNotApplicable(GNE_CRM_340B_Case__c c) {
        return c.Invoice_Type__c == INVOICE_TYPE_NOTAPPLICABLE;
    }

    public static Boolean isCloseOutLetterSent(GNE_CRM_340B_Case__c c) {
        return c.Close_out_Letter_Sent__c != null;
    }

    public static void setStatus(List<GNE_CRM_340B_Case__c> cases) {
	    for (GNE_CRM_340B_Case__c c : cases) {
	    	if (c.Case_Type__c != CASE_TYPE_INITIATIVE && c.Case_Status__c != CASE_STATUS_HOLD && String.isBlank(c.Legacy_ID__c)) {
	    		c.Case_Status__c = CASE_STATUS_NEW;	    		
	    		if (c.X340B_Account_Manager__c != null) {
	    			c.Case_Status__c = CASE_STATUS_ASSIGNED;
	    		}
                if(c.X340B_Account_Manager__c != null && GNE_CRM_340B_Case_TriggerHandler.isCeContactedSetUp(c)) {
	    			c.Case_Status__c = CASE_STATUS_ENGAGEMENT;
	    		}
                if(c.X340B_Account_Manager__c != null && GNE_CRM_340B_Case_TriggerHandler.isCeContactedSetUp(c) &&
                        GNE_CRM_340B_Case_TriggerHandler.isInvoiceRequested(c)){
	    			c.Case_Status__c = CASE_STATUS_INVOICED;
	    		}
                if(c.X340B_Account_Manager__c != null && GNE_CRM_340B_Case_TriggerHandler.isCeContactedSetUp(c) && 
                (GNE_CRM_340B_Case_TriggerHandler.isInvoiceTypeNotApplicable(c) || (GNE_CRM_340B_Case_TriggerHandler.isInvoiceRequested(c) && GNE_CRM_340B_Case_TriggerHandler.isCloseOutLetterSent(c) ) ) ) {
                    c.Case_Status__c = CASE_STATUS_CLOSED;
                }
	    	}
            if(c.Invoice_Type__c == INVOICE_TYPE_NOTAPPLICABLE && c.Case_Status__c == CASE_STATUS_CLOSED)validateInvoiceSection(c);
	    }
    }
    
    private static void validateInvoiceSection(GNE_CRM_340B_Case__c record) {
        String notEmptyFields = '';
        for(Schema.FieldSetMember f : getFields()){
            String fieldApiName = f.getFieldPath();
            System.debug(record.get(fieldApiName));
            if(record.get(fieldApiName) != null) {
                notEmptyFields += '<LI> '+f.getLabel();
            }
        }
        if(String.isNotEmpty(notEmptyFields)){
            String errorMsg = String.format(ERROR_FOR_NOTAPPLICABLE, new List<String> {notEmptyFields});
            record.addError(errorMsg, FALSE);            
        }
    }
    
    private static List<Schema.FieldSetMember> getFields() {
        return SObjectType.GNE_CRM_340B_Case__c.FieldSets.Invoice_Section.getFields();
    }
    	
    public static void setCompletionDate(List<GNE_CRM_340B_Case__c> cases) {
	    for (GNE_CRM_340B_Case__c c : cases) {
	    	Date d = System.today();
	    	if (c.Case_Status__c == CASE_STATUS_ASSIGNED && c.Target_Completion_Date__c == null) {
                if(GNE_MCCO_CRM_340B_Case_Dates__c.getValues(c.Case_Type__c + ' - TCD') != null)
                c.Target_Completion_Date__c = d.addDays(Integer.valueOf(GNE_MCCO_CRM_340B_Case_Dates__c.getValues(c.Case_Type__c + ' - TCD').Days__c));
                if(GNE_MCCO_CRM_340B_Case_Dates__c.getValues(c.Case_Type__c + ' - ATCD') != null)
                c.Assigned_Target_Completion_Date__c = d.addDays(Integer.valueOf(GNE_MCCO_CRM_340B_Case_Dates__c.getValues(c.Case_Type__c  + ' - ATCD').Days__c));
                if(GNE_MCCO_CRM_340B_Case_Dates__c.getValues(c.Case_Type__c + ' - ETCD') != null)
                c.Engagement_Target_Completion_Date__c = d.addDays(Integer.valueOf(GNE_MCCO_CRM_340B_Case_Dates__c.getValues(c.Case_Type__c +' - ETCD').Days__c));
	    	}
	    }
    }
    
    public static void setMPN(List<GNE_CRM_340B_Case__c> cases) {
        Set<Id> accountIds = new Set<Id>();
        for (GNE_CRM_340B_Case__c c : cases) {
            if (c.Account__c != null) {
                accountIds.add(c.Account__c);
            }
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([ SELECT Id, Account_340B_ID__c, MPN__c FROM Account WHERE Id IN :accountIds ]); 
        for (GNE_CRM_340B_Case__c c : cases) {
            if (c.Account__c != null) {
                Account acc = accountMap.get(c.Account__c);
                if (acc != null) {
                    c.Account_340B_ID__c = acc.Account_340B_ID__c;
                    c.MPN__c = acc.MPN__c;
                } 
            }
        }
    }
    
    public static void setOpenCaseOnAccount(List<GNE_CRM_340B_Case__c> cases) {
    	Set<Id> accIds = new Set<Id>();
	    for (GNE_CRM_340B_Case__c c : cases) {
	    	if (c.Account__c != null) {
	    		accIds.add(c.Account__c);
	    	}
	    }
	    
	    List<Account> accList = [
	    	SELECT Id, (SELECT Id, Case_Status__c FROM X340B_Cases__r) FROM Account WHERE Id IN :accIds
	    ];
	    
	    if (accList.size()>0) {
		    for (Account a : accList) {
		    	a.X340B_Open_Case__c = false;
		   		for (GNE_CRM_340B_Case__c c : a.X340B_Cases__r) {
		   			if (c.Case_Status__c != CASE_STATUS_CLOSED) {
		   				a.X340B_Open_Case__c = true;
		   			}
		    	}
		    }

	    	update accList;
	    }
    }
    
    public static Task createSingleTask(GNE_CRM_340B_Case__c c) {
    	return new Task(
            OwnerId = c.X340B_Account_Manager__c,
            Status = 'Not Started',
            WhatId = c.Id,
            Subject = 'Your Account Has a New Case',
            ActivityDate = system.today(),
            Priority = 'Normal'
        );
    }
    
    public static void createTasks(List<GNE_CRM_340B_Case__c> newCases, Map<Id, GNE_CRM_340B_Case__c> oldCases, Boolean isInsert, Boolean isUpdate) {
		List<Task> tasks = new List<Task>(); 

		if (isInsert) { 
		    for (GNE_CRM_340B_Case__c c : newCases) {
		    	if (String.isNotEmpty(c.X340B_Account_Manager__c)) {
		    		tasks.add(createSingleTask(c));
		    	}
		    }
		}
    	
    	if (isUpdate) {
		    for (GNE_CRM_340B_Case__c c : newCases) {
		    	if (String.isNotEmpty(c.X340B_Account_Manager__c) && (oldCases.get(c.Id).X340B_Account_Manager__c != c.X340B_Account_Manager__c)) {
		    		tasks.add(createSingleTask(c));
		    	}
		    }
    	}

	    if (tasks.size()>0) {
	    	insert tasks;
	    }
    }
    
    public static void setState(List<GNE_CRM_340B_Case__c> cases, Map<Id, GNE_CRM_340B_Case__c> oldCases) {
        Set<Id> accountIds = new Set<Id>();
        for (GNE_CRM_340B_Case__c c : cases) {
            if (oldCases != null) {
                if (c.Account__c == null) {
                    c.State__c = '';
                } else if (c.Account__c != oldCases.get(c.Id).Account__c || (String.isBlank(c.State__c) && (c.Account__c != null))) {
                   accountIds.add(c.Account__c);
                }
            } else {
                if (c.Account__c != null) {
                    accountIds.add(c.Account__c);
                }
            }
        }
        
        if (accountIds.isEmpty()) {
            return ;
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([ SELECT Id, (SELECT State_vod__c FROM Address_vod__r ORDER BY Primary_vod__c DESC) FROM Account WHERE Id IN :accountIds ]); 
        for (GNE_CRM_340B_Case__c c : cases) {
            if (c.Account__c != null) {
                Account acc = accountMap.get(c.Account__c);
                if (acc != null) {
                    if (acc.Address_vod__r.size()>=1) {
	                    c.State__c = acc.Address_vod__r.get(0).State_vod__c;
                    }
                } 
            }
        }
    }
    
    public static void updateNDConTrigger() {
        for(GNE_CRM_340B_Case__c record : (GNE_CRM_340B_Case__c[])Trigger.new) {
            GNE_CRM_340B_Case__c oldRecord;
            if(Trigger.isInsert && String.isNotBlank(record.Negotiation_Products__c) ){
                updateNegotiationNDCfield(record);
            } else if(Trigger.isUpdate){
                oldRecord = (GNE_CRM_340B_Case__c)Trigger.oldMap.get(record.Id);
                if(oldRecord.Negotiation_Products__c != record.Negotiation_Products__c){
                    updateNegotiationNDCfield(record);
                }
            }
            if(Trigger.isInsert && String.isNotBlank(record.Initial_Products__c) ){
                updateInitialNDCfield(record);
            } else if(Trigger.isUpdate){
                if(oldRecord.Initial_Products__c != record.Initial_Products__c){
                    updateInitialNDCfield(record);
                }
            }
        }
    }
    
    private static void updateInitialNDCfield(GNE_CRM_340B_Case__c record) {
        String [] values = String.isBlank(record.Initial_Products__c) ? new String []{} : record.Initial_Products__c.split(';');
        values.sort();
        String result = '';
        String concatResult = '';
        Map<String, String> updatedValues = updateResults(result, concatResult, values);
        record.NDC_Initial_Products__c = new List<String>(updatedValues.keySet())[0];
        record.Initial_Product_with_NDC__c = updatedValues.values()[0];
    }
    
    private static void updateNegotiationNDCfield(GNE_CRM_340B_Case__c record) {
        String [] values = String.isBlank(record.Negotiation_Products__c) ? new String []{} : record.Negotiation_Products__c.split(';');
        values.sort();
        String result = '';
        String concatResult = '';
        Map<String, String> updatedValues = updateResults(result, concatResult, values);
        record.NDC_Negotiation_Products__c = new List<String>(updatedValues.keySet())[0];
        record.Negotiation_Product_with_NDC__c = updatedValues.values()[0];
    }
    
    private static Map<String, String> updateResults(String result, String concatResult, String [] values) {
        for(String str: values) {
            if(productName2code.get(str) != null) {
                result += productName2code.get(str) + ';';   
                concatResult += '<LI> '+ str + ' ('+ productName2code.get(str)+')';
            } else {
                concatResult += '<LI> '+ str + ' (no code found)';
            }
        }
        result = result.removeEnd(';');
        return new Map<String, String>{result => concatResult};
    }
    
    public static void setApprovedDate() {
        for(GNE_CRM_340B_Case__c record : (GNE_CRM_340B_Case__c[])Trigger.new) {
            if(isApplicableForSetApprovedDate(record)) {
                record.Case_Approved_Date__c = System.today();
            }
        }
    }
    
    private static Boolean isApplicableForSetApprovedDate(GNE_CRM_340B_Case__c record) {
        Boolean result = false;
        if(Trigger.isInsert && record.X340B_Account_Manager__c != null) {
            result = true;
        } else if(Trigger.isUpdate) {
            GNE_CRM_340B_Case__c oldRecord = (GNE_CRM_340B_Case__c)Trigger.oldMap.get(record.Id);
            if(oldRecord.X340B_Account_Manager__c == null && record.X340B_Account_Manager__c != null && record.Case_Approved_Date__c == null) {
                result = true;
            }
        }
        
        return result;
    }
    
    private static String setFutureSavingsTotalAmount() {
        for(GNE_CRM_340B_Case__c record : (GNE_CRM_340B_Case__c[])Trigger.new) {
            try{
                record.Future_Savings_TotalAmount__c = 0;
                if(record.Future_Savings_Amount1__c != null) {
                    record.Future_Savings_TotalAmount__c += record.Future_Savings_Amount1__c;
                }
                if(record.Future_Savings_Amount2__c != null) {
                    record.Future_Savings_TotalAmount__c += record.Future_Savings_Amount2__c;
                }
                if(record.Future_Savings_Amount3__c != null) {
                    record.Future_Savings_TotalAmount__c += record.Future_Savings_Amount3__c;
                }
                if(record.Future_Savings_Amount4__c != null) {
                    record.Future_Savings_TotalAmount__c += record.Future_Savings_Amount4__c;
                }
            } catch(Exception e) {
                record.addError(e);
            }
        }
        return '';
    }

    private static String setIndirectRecoveryTotalAmount() {
        for(GNE_CRM_340B_Case__c record : (GNE_CRM_340B_Case__c[])Trigger.new) {
            try{
                record.Indirect_Recovery_TotalAmount__c = 0;
                if(record.Accumulator_Adjustment__c != null) {
                    record.Indirect_Recovery_TotalAmount__c += record.Accumulator_Adjustment__c;
                }
                if(record.Medicaid_Rebate_Credit__c != null) {
                    record.Indirect_Recovery_TotalAmount__c += record.Medicaid_Rebate_Credit__c;
                }
                if(record.Wholesaler_Credit_Re_bill__c != null) {
                    record.Indirect_Recovery_TotalAmount__c += record.Wholesaler_Credit_Re_Bill__c;
                }
            } catch(Exception e) {
                record.addError(e);
            }
        }
        return '';
    }
}