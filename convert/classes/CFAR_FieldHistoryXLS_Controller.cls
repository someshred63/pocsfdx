public with sharing class CFAR_FieldHistoryXLS_Controller {

	public List<CFAR_Administrator_Controller.HistoryWrapper> fieldHistory {get;set;}
	public List<CFAR_Administrator_Controller.HistoryWrapper> displayedFieldHistory {get;set;}          
    private String historyTrialId;
    private String historyTrialName;
	private Set<Id> trialObjectIdSet = new Set<Id>();
	private Map<Id, CFAR_Team_Member_gne__c> tmMap;
	private Map<Id, CFAR_Budget_Contract_Tracking_gne__c> bctMap;
	private Map<Id, CFAR_Comment_gne__c> cMap;
	private Map<Id, CFAR_Budget_CPS_Payments_gne__c> bpMap;
	
	private Map<Id, CFAR_Contact_gne__c> contactMap;

	public CFAR_FieldHistoryXLS_Controller() {
		historyTrialId = ApexPages.currentPage().getParameters().get('id');
		historyTrialName = (!String.isBlank(historyTrialId)) ? [select Name from CFAR_Trial_gne__c where id = :historyTrialId limit 1][0].Name : '';
		initFieldHistory();
	}
	
	private void initFieldHistory() {
		populateTrialObjectIdSet();
		populateFieldHistory();
	}
	
	private void populateTrialObjectIdSet(){
		trialObjectIdSet = new Set<Id>();
		tmMap = new Map<Id, CFAR_Team_Member_gne__c>([SELECT Id,frm_Name_gne__c FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c = :historyTrialId]);
        //DONE: ITERATION2 MultiContract
		bctMap = new Map<Id, CFAR_Budget_Contract_Tracking_gne__c>([SELECT Id, Name, Type_ref_gne__r.Name FROM CFAR_Budget_Contract_Tracking_gne__c WHERE Frm_Trial_Id_gne__c = :historyTrialId]);
		cMap = new Map<Id, CFAR_Comment_gne__c>([ SELECT Id, Name, Created_By_CFAR_Contact_ref_gne__r.Name  FROM CFAR_Comment_gne__c WHERE CFAR_Trial_ref_gne__c = :historyTrialId]);
        //DONE: ITERATION2 MultiContract
		bpMap = new Map<Id, CFAR_Budget_CPS_Payments_gne__c>([SELECT Id, Name, Payment_Status_ref_gne__r.Name, Line_Num_gne__c FROM CFAR_Budget_CPS_Payments_gne__c WHERE Frm_Trial_Id_gne__c = :historyTrialId]);
		
		contactMap = new Map<Id, CFAR_Contact_gne__c>([SELECT Id, Name, Search_Name__c FROM CFAR_Contact_gne__c]);

		system.debug(LoggingLevel.INFO,'***** tmMap: ' + tmMap);
		system.debug(LoggingLevel.INFO,'***** bctMap: ' + bctMap);
		system.debug(LoggingLevel.INFO,'***** cMap: ' + cMap);
		system.debug(LoggingLevel.INFO,'***** bpMap: ' + bpMap);
		
		for(Id tm : tmMap.keySet()){
			trialObjectIdSet.add(tm);
		}
		for(Id bct : bctMap.keySet()){
			trialObjectIdSet.add(bct);
		}
		for(Id c : cMap.keySet()){
			trialObjectIdSet.add(c);
		}
		for(Id bp : bpMap.keySet()){
			trialObjectIdSet.add(bp);
		}	
		system.debug(LoggingLevel.INFO,'**** trialObjectIdSet:' + trialObjectIdSet);
	}
	
	private void populateFieldHistory() {	
        fieldHistory = new List<CFAR_Administrator_Controller.HistoryWrapper>();
        List<CFAR_Team_Member_gne__history> teamList = database.query(String.escapeSingleQuotes('Select NewValue, OldValue, CreatedDate, CreatedById, Field, ParentId FROM CFAR_Team_Member_gne__history where parentId IN: trialObjectIdSet'));
        List<CFAR_Budget_Contract_Tracking_gne__history> contractList = database.query(String.escapeSingleQuotes('Select NewValue, OldValue, CreatedDate, CreatedById, Field, ParentId FROM CFAR_Budget_Contract_Tracking_gne__history where parentId IN: trialObjectIdSet'));
        List<CFAR_Comment_gne__history> commentList = database.query(String.escapeSingleQuotes('Select NewValue, OldValue, CreatedDate, CreatedById, Field, ParentId FROM CFAR_Comment_gne__history where parentId IN: trialObjectIdSet'));
        List<CFAR_Budget_CPS_Payments_gne__history> paynmentList = database.query(String.escapeSingleQuotes('Select NewValue, OldValue, CreatedDate, CreatedById, Field, ParentId FROM CFAR_Budget_CPS_Payments_gne__history where parentId IN: trialObjectIdSet'));

        Map<String, Schema.SObjectField> tmFieldMap =  Schema.SObjectType.CFAR_Team_Member_gne__c.fields.getMap();
        Map<String, Schema.SObjectField> bctFieldMap =  Schema.SObjectType.CFAR_Budget_Contract_Tracking_gne__c.fields.getMap();
        Map<String, Schema.SObjectField> cFieldMap =  Schema.SObjectType.CFAR_Comment_gne__c.fields.getMap();
        Map<String, Schema.SObjectField> bpFieldMap =  Schema.SObjectType.CFAR_Budget_CPS_Payments_gne__c.fields.getMap();
        Set<Id> userIdSet = new Set<Id>();
        for(CFAR_Team_Member_gne__history h : teamList){
        	userIdSet.add(h.CreatedById);
        }
        for(CFAR_Budget_Contract_Tracking_gne__history h : contractList){
        	userIdSet.add(h.CreatedById);
        }
        for(CFAR_Comment_gne__history h : commentList){
        	userIdSet.add(h.CreatedById);
        }
        for(CFAR_Budget_CPS_Payments_gne__history h : paynmentList){
        	userIdSet.add(h.CreatedById);
        }
        Map<ID, User> userMap = new Map<ID, User>([SELECT Id, Name FROM User WHERE Id IN :userIdSet]);
        for(CFAR_Team_Member_gne__history h : teamList){
            CFAR_Administrator_Controller.HistoryWrapper history = new CFAR_Administrator_Controller.HistoryWrapper();
            history.objectName = 'Team Member';
            history.parentId = (tmMap.containsKey(h.parentId)) ? tmMap.get(h.parentId).frm_Name_gne__c : '';
            history.changeDate = h.CreatedDate;
            history.modifyBy = userMap.get(h.CreatedById).Name;
            if(tmFieldMap.get(h.Field) != null){
            	history.Field = tmFieldMap.get(h.Field).getDescribe().getLabel();
            } else {
            	history.Field = h.Field;
            }
            if(history.Field == 'Active On' || history.Field == 'Inactive On'){
            	history.newValue = CFAR_Administrator_Controller.parseDate(h.NewValue != null ? String.valueOf(h.NewValue): null);
            	history.oldValue = CFAR_Administrator_Controller.parseDate(h.NewValue != null ? String.valueOf(h.NewValue): null);
            } else {
           	 	history.newValue = h.NewValue != null ? String.valueOf(h.NewValue): null;
           		history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue): null;        
            }                      
            fieldHistory.add(history);
        }
        for(CFAR_Budget_Contract_Tracking_gne__history h : contractList){
            CFAR_Administrator_Controller.HistoryWrapper history = new CFAR_Administrator_Controller.HistoryWrapper();
            history.objectName = 'Budget Contract Tracking';
            history.parentId = (bctMap.containsKey(h.parentId)) ? bctMap.get(h.parentId).Name : '';
            history.changeDate = h.CreatedDate;
            history.modifyBy = userMap.get(h.CreatedById).Name;
            if(bctFieldMap.get(h.Field) != null){
            	history.Field = bctFieldMap.get(h.Field).getDescribe().getLabel();
            } else {
            	history.Field = h.Field;
            }
            if(history.Field == 'Contract Expiry Date' || history.Field == 'Fully Executed Date'){
            	history.newValue = CFAR_Administrator_Controller.parseDate(h.NewValue != null ? String.valueOf(h.NewValue): null);
            	history.oldValue = CFAR_Administrator_Controller.parseDate(h.OldValue != null ? String.valueOf(h.OldValue): null);
            } else if(history.Field == 'Contract Type'){
            	if(CFAR_Administrator_Controller.checkIsId(emptyIfNull(h.OldValue)) && CFAR_Administrator_Controller.checkIsId(emptyIfNull(h.NewValue))){
            		continue;
            	}
            	history.newValue = h.NewValue != null ? String.valueOf(h.NewValue) : null;
            	history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue) : null;
            	/**
            	if(bcTypeMap.containsKey(String.valueOf(h.NewValue))){
            		history.newValue = bcTypeMap.get(String.valueOf(h.NewValue)).Name;
            	} else {
            		history.newValue = '';
            	}
            	if(bcTypeMap.containsKey(String.valueOf(h.OldValue))){
            		history.oldValue = bcTypeMap.get(String.valueOf(h.OldValue)).Name;
            	} else {
            		history.oldValue = '';
            	}
            	*/           	
            } else {
           	 	history.newValue = h.NewValue != null ? String.valueOf(h.NewValue): null;
           		history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue): null;        
            }             
            fieldHistory.add(history);            
        }
        for(CFAR_Comment_gne__history h : commentList){
            CFAR_Administrator_Controller.HistoryWrapper history = new CFAR_Administrator_Controller.HistoryWrapper();
            history.objectName = 'Comment';
            history.parentId = (cMap.containsKey(h.parentId)) ? cMap.get(h.parentId).Name : '';
            history.changeDate = h.CreatedDate;
            history.modifyBy = userMap.get(h.CreatedById).Name;
            if(cFieldMap.get(h.Field) != null){
            	history.Field = cFieldMap.get(h.Field).getDescribe().getLabel();
            } else {
            	history.Field = h.Field;
            }           
            if(history.Field == 'Activity Date'){
            	history.newValue = CFAR_Administrator_Controller.parseDate(h.NewValue != null ? String.valueOf(h.NewValue): null);
            	history.oldValue = CFAR_Administrator_Controller.parseDate(h.OldValue != null ? String.valueOf(h.OldValue): null);
            } else if(history.Field == 'Created By'){
            	if(!CFAR_Administrator_Controller.checkIsId(emptyIfNull(h.OldValue)) && !CFAR_Administrator_Controller.checkIsId(emptyIfNull(h.NewValue))){
            		continue;
            	}
            	if(contactMap.containsKey(String.valueOf(h.NewValue))){
            		history.newValue = contactMap.get(String.valueOf(h.NewValue)).Search_Name__c;
            	} else {
            		history.newValue = '';
            	}
            	if(contactMap.containsKey(String.valueOf(h.OldValue))){
            		history.oldValue = contactMap.get(String.valueOf(h.OldValue)).Search_Name__c;
            	} else {
            		history.oldValue = '';
            	}              	
            } else {
           	 	history.newValue = h.NewValue != null ? String.valueOf(h.NewValue): null;
           		history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue): null;        
            }     
            fieldHistory.add(history);            
        }
        for(CFAR_Budget_CPS_Payments_gne__history h : paynmentList){
            CFAR_Administrator_Controller.HistoryWrapper history = new CFAR_Administrator_Controller.HistoryWrapper();
            history.objectName = 'Budget CPS Payments';
            history.parentId = (bpMap.containsKey(h.parentId)) ? String.valueOf(bpMap.get(h.parentId).Line_Num_gne__c) : '';
            history.changeDate = h.CreatedDate;
            history.modifyBy = userMap.get(h.CreatedById).Name;
            if(bpFieldMap.get(h.Field) != null){
            	history.Field = bpFieldMap.get(h.Field).getDescribe().getLabel();
            } else {
            	history.Field = h.Field;
            }            
            if(history.Field == 'Invoice Date' || history.Field == 'Paid On' || history.Field == 'Planned Date'){
            	history.newValue = CFAR_Administrator_Controller.parseDate(h.NewValue != null ? String.valueOf(h.NewValue): null);
            	history.oldValue = CFAR_Administrator_Controller.parseDate(h.OldValue != null ? String.valueOf(h.OldValue): null);
            } else if(history.Field == 'Payment Status'){
            	if(CFAR_Administrator_Controller.checkIsId(emptyIfNull(h.OldValue)) && CFAR_Administrator_Controller.checkIsId(emptyIfNull(h.NewValue))){
            		continue;
            	}
            	history.newValue = h.NewValue != null ? String.valueOf(h.NewValue) : null;
            	history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue) : null;
            	/**
            	if(pssMap.containsKey(String.valueOf(h.NewValue))){
            		history.newValue = pssMap.get(String.valueOf(h.NewValue)).Name;
            	} else {
            		history.newValue = '';
            	}
            	if(pssMap.containsKey(String.valueOf(h.OldValue))){
            		history.oldValue = pssMap.get(String.valueOf(h.OldValue)).Name;
            	} else {
            		history.oldValue = '';
            	}
            	*/               	
            } else {
           	 	history.newValue = h.NewValue != null ? String.valueOf(h.NewValue): null;
           		history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue): null;        
            } 
            fieldHistory.add(history);            
        }
        system.debug(LoggingLevel.INFO,'**** fieldHistory:' + fieldHistory);
        system.debug(LoggingLevel.INFO,'**** fieldHistory size:' + fieldHistory.size());
        fieldHistory.sort();
        if (fieldHistory.size() <= 1000) {
        	displayedFieldHistory = fieldHistory.clone();
        }
        else {
			if(displayedFieldHistory == null){ displayedFieldHistory = new List<CFAR_Administrator_Controller.HistoryWrapper>();}
        	for (Integer i = fieldHistory.size() - 1000; i < fieldHistory.size(); i++) {
        		displayedFieldHistory.add(fieldHistory[i]);
        	}
        }
        /**
        for(HistoryWrapper fh : fieldHistory){
            if(index >= currentPageFieldHistory * pageSize && index < (currentPageFieldHistory + 1) * pageSize){
                displayedFieldHistory.add(fh);
            }
            index++;
        } 
        system.debug(LoggingLevel.INFO,'**** displayedFieldHistory:' + displayedFieldHistory);
        */
	}

	private String emptyIfNull(Object obj) {
		return obj != null ? String.valueOf(obj) : '';
	}

	public String getWorkbookProperties() {
        String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + 'History Tracking for trial: ' + historyTrialName + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
        return workbook;
    }
    
    public String getFileName() {
        String fileName = 'Field History - ' + historyTrialName + ' - ' + String.valueOf(DateTime.now());
        return fileName ;
    }

}