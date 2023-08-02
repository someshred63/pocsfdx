public with sharing class CFAR_RegulatoryDocument_Controller extends CFAR_TrialBaseController {
     public CFAR_TrialWrapper trialWrapper{
        get {
			if((CFAR_Utils.getActualTrialId() != null && trialWrapper == null) || 
				(trialWrapper != null && trialWrapper.innerObject != null && CFAR_Utils.getActualTrialId() != null && trialWrapper.innerObject.id != CFAR_Utils.getActualTrialId())) {
				trialWrapper = new CFAR_TrialWrapper(CFAR_DAO.getTrial(CFAR_Utils.getActualTrialId()));
				editMode = false;
			}
			return trialWrapper;
        }
        set
        { 
            trialWrapper = value;
            if(trialWrapper != null){
                setStatusEditMode((CFAR_Trial_gne__c)trialWrapper.innerObject);
            }
            if(trial == null && trialWrapper.innerObject != null) {
            	trial = (CFAR_Trial_gne__c)trialWrapper.innerObject;
            	init();
            }
            if(null  != trialWrapper && null != trialWrapper.innerObject && trial != null){
                if(trial.Id != trialWrapper.innerObject.Id){
                    trial = (CFAR_Trial_gne__c)trialWrapper.innerObject;
                    editMode = false;
                    init();
                }
                trial.Original_Contract_Execution_Date_gne__c = ((CFAR_Trial_gne__c)trialWrapper.innerObject).Original_Contract_Execution_Date_gne__c;
            }
        }
    }
    
    public List<SelectOption> INDRequiredOptions {get;set;}
    public List<SelectOption> IRBRequiredOptions {get;set;}
    public List<SelectOption> FSRRequiredOptions {get;set;}
    public List<SelectOption> SDEARequiredOptions {get;set;}
    public List<SelectOption> CapaAssessRequiredOptions {get;set;}
    public List<SelectOption> activityOptions {get;set;}
    
    public String selectedINDRequired {get;set;}
    public String selectedIRBRequired {get;set;}
    public String selectedFSRRequired {get;set;}
    public String selectedSDEARequired {get;set;}
    public String selectedCapaAssessRequired {get;set;}
    public String selectedActivity {get;set;}

    public Boolean editMode {get;set;}
    public Boolean rdcDateCriteria {get;set;}
    public Boolean rdcDateMessage {get;set;}
    public Boolean indDateInFuture {get;set;}
    public Boolean displayNewButton {get;set;}
    public Boolean statusEditMode {get;set;}
    private Boolean constructorRun = true;
    public Boolean editActivationRdts {get;set;}
    public Boolean editClosureRdts {get;set;}
    public Boolean editMaintenanceRdts {get;set;}
    
    public List<CFAR_Regulatory_Document_Tracking_gne__c> rdtList {get;set;}
    public CFAR_Regulatory_Document_Tracking_gne__c currentRDT {get;set;}
    private Set<String> rdtActivitySet = new Set<String>();

    public List<CFAR_Regulatory_Document_Tracking_gne__c> activationRdtList {get;set;}
    public CFAR_Regulatory_Document_Tracking_gne__c activationCurrentRDT {get;set;}
    private Set<String> activationRdtActivitySet = new Set<String>();

    public List<CFAR_Regulatory_Document_Tracking_gne__c> closureRdtList {get;set;}
    public CFAR_Regulatory_Document_Tracking_gne__c closureCurrentRDT {get;set;}
    private Set<String> closureRdtActivitySet = new Set<String>();

    public List<CFAR_Regulatory_Document_Tracking_gne__c> maintenanceRdtList {get;set;}
    public CFAR_Regulatory_Document_Tracking_gne__c maintenanceCurrentRDT {get;set;}
    private Set<String> maintenanceRdtActivitySet = new Set<String>();
    
    public String iNDNumber {get;set;}
    public CFAR_Trial_gne__c tempTrial {get;set;}
    
    private Id refreshedId;
    public Id currentRDTId {get;set;}
    public Id activationCurrentRDTId {get;set;}
    public Id closureCurrentRDTId {get;set;}
    public Id maintenanceCurrentRDTId {get;set;}
    
    public ApexPages.StandardSetController stdSetControllerProjection;
    
    private static final Set<String> IRBActivitiesSet = new Set<String>{'IRB Approval for Amendment', 'IRB Approval Letter for Original Protocol', 'IRB Approved Amendment', 'IRB Approved Protocol', 'IRB Closure Letter Received', 'IRB Renewal', 'Sub-I IRB Approval', 'Sub-I IRB Renewal'};
    private static final Set<String> INDActivitiesSet = new Set<String>{'Cross Reference Letter', '1571', '1572', 'FDA response to IND Submission (copy)', 'FDA Notification of Closure'};
    private static final String ACTIVATION = 'Activation';
    private static final String CLOSURE = 'Closure';
    private static final String MAINTENANCE = 'Maintenance';

    public CFAR_RegulatoryDocument_Controller() {
        super(true);
        editMode = false;
        sortExpression = 'Regulatory_Tracking_Activity_gne__r.Name';
        sortDirection = 'asc';
        init();
    }
    
    private void init(){
        tempTrial = new CFAR_Trial_gne__c();
        currentRDT = new CFAR_Regulatory_Document_Tracking_gne__c();
        activationCurrentRDT = new CFAR_Regulatory_Document_Tracking_gne__c();
        closureCurrentRDT = new CFAR_Regulatory_Document_Tracking_gne__c();
        maintenanceCurrentRDT = new CFAR_Regulatory_Document_Tracking_gne__c();
        if(trial != null) {
        	sortRdt(); 
        	setSelectOptionValues();
        	setStartValues();
        	setRDCDateMessage();
        	indDateInFuture = false;
        }
    }

    private void setStatusEditMode(CFAR_Trial_gne__c trial){
        if(trial == null){
           statusEditMode = true;
           return; 
        }
        if(trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX 
            || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED 
            || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED 
            || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION){
            statusEditMode = false;
        } else {
            statusEditMode = true;
        }    
    }

    private void setSelectOptionValues(){
        indRequiredOptions = getINDRequiredOptions();
        IRBRequiredOptions = getIRBRequiredOptions(); 
        FSRRequiredOptions = getFSRRequiredOptions();
        SDEARequiredOptions = getSDEARequiredOptions();
        CapaAssessRequiredOptions = getCapaAssessRequiredOptions();
        activityOptions = getActivityOptions();
    }
    
    private void setStartValues(){
        selectedINDRequired = trial.IND_Required_gne__c;
        selectedIRBRequired = trial.IRB_Required_gne__c;   
        selectedFSRRequired = trial.FSR_Required_gne__c;
        selectedSDEARequired = trial.SDEA_Required__c;
        selectedCapaAssessRequired = trial.Capability_Assessment_Required__c;
        tempTrial.IND_Exempt_Letter_Date_gne__c = trial.IND_Exempt_Letter_Date_gne__c;
        tempTrial.Regulatory_Document_Complete_Date_gne__c = trial.Regulatory_Document_Complete_Date_gne__c;
        iNDNumber = trial.IND_gne__c;
    }
    
    private void setRDCDateMessage(){
        rdcDateMessage = trial.Regulatory_Document_Complete_Date_gne__c != null && selectedINDRequired == 'YES' && (trial.IND_gne__c == null || trial.IND_gne__c == '');
    }
    
    public PageReference sortRdt(){
        refreshTrial();
        String searchId;
        rdtActivitySet = new Set<String>();
        activationRdtActivitySet  = new Set<String>();
        closureRdtActivitySet  = new Set<String>();
        maintenanceRdtActivitySet  = new Set<String>();
        if(constructorRun){
            searchId = trial != null ? trial.Id : null;
            setStatusEditMode(trial);
            constructorRun = false;            
        } else {
            searchId = (trialWrapper != null && trialWrapper.innerObject!= null) ? trialWrapper.innerObject.id : null;  
            if(trialWrapper != null && trialWrapper.innerObject != null){
                setStatusEditMode((CFAR_Trial_gne__c)trialWrapper.innerObject);
            }            
        }
        if(searchId!= null){
            String queryString = 'SELECT Activity_gne__c, Id, Date_Received_gne__c, Expiry_Date_gne__c, Comments2_gne__c, Regulatory_Tracking_Activity_gne__r.Name, Regulatory_Tracking_Activity_gne__r.Study_Stage__c, Reg_Doc_Investigator_gne__c, Reg_Doc_Investigator_gne__r.frm_Name_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE Active_gne__c = true AND Regulatory_Tracking_Activity_gne__c != null AND CFAR_Trial_gne__c = \'' + searchId + '\' ORDER BY ' + sortExpression + ' ' + sortDirection;
            String activationQueryString = 'SELECT Activity_gne__c, Id, Date_Received_gne__c, Expiry_Date_gne__c, Comments2_gne__c, Regulatory_Tracking_Activity_gne__r.Name, Regulatory_Tracking_Activity_gne__r.Study_Stage__c, Reg_Doc_Investigator_gne__c, Reg_Doc_Investigator_gne__r.frm_Name_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE Active_gne__c = true AND Regulatory_Tracking_Activity_gne__r.Study_Stage__c = :ACTIVATION AND Regulatory_Tracking_Activity_gne__c != null AND CFAR_Trial_gne__c = \'' + searchId + '\' ORDER BY ' + sortExpression + ' ' + sortDirection;
            String closureQueryString = 'SELECT Activity_gne__c, Id, Date_Received_gne__c, Expiry_Date_gne__c, Comments2_gne__c, Regulatory_Tracking_Activity_gne__r.Name, Regulatory_Tracking_Activity_gne__r.Study_Stage__c, Reg_Doc_Investigator_gne__c, Reg_Doc_Investigator_gne__r.frm_Name_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE Active_gne__c = true AND Regulatory_Tracking_Activity_gne__r.Study_Stage__c = :CLOSURE AND Regulatory_Tracking_Activity_gne__c != null AND CFAR_Trial_gne__c = \'' + searchId + '\' ORDER BY ' + sortExpression + ' ' + sortDirection;
            String maintenanceQueryString = 'SELECT Activity_gne__c, Id, Date_Received_gne__c, Expiry_Date_gne__c, Comments2_gne__c, Regulatory_Tracking_Activity_gne__r.Name, Regulatory_Tracking_Activity_gne__r.Study_Stage__c, Reg_Doc_Investigator_gne__c, Reg_Doc_Investigator_gne__r.frm_Name_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE Active_gne__c = true AND Regulatory_Tracking_Activity_gne__r.Study_Stage__c = :MAINTENANCE AND Regulatory_Tracking_Activity_gne__c != null AND CFAR_Trial_gne__c = \'' + searchId + '\' ORDER BY ' + sortExpression + ' ' + sortDirection;
            rdtList = Database.query(queryString);
            List<CFAR_Regulatory_Document_Tracking_gne__c> activationRdtListToProcess = Database.query(activationQueryString);
            activationRdtList  = processRtdList(activationRdtListToProcess);
            List<CFAR_Regulatory_Document_Tracking_gne__c> closureRdtListToProcess = Database.query(closureQueryString);
            List<CFAR_Regulatory_Document_Tracking_gne__c> maintenanceRdtListToProcess = Database.query(maintenanceQueryString);
            closureRdtList  = processRtdList(closureRdtListToProcess);
            maintenanceRdtList  = processRtdList(maintenanceRdtListToProcess);       
        } else {
            rdtList = new List<CFAR_Regulatory_Document_Tracking_gne__c>();
            activationRdtList = new List<CFAR_Regulatory_Document_Tracking_gne__c>();
            closureRdtList = new List<CFAR_Regulatory_Document_Tracking_gne__c>();
            maintenanceRdtList = new List<CFAR_Regulatory_Document_Tracking_gne__c>();
        }
        for(CFAR_Regulatory_Document_Tracking_gne__c rdt : rdtList){
            rdtActivitySet.add(rdt.Regulatory_Tracking_Activity_gne__c);
        }
        for(CFAR_Regulatory_Document_Tracking_gne__c actRdt : activationRdtList){
            activationRdtActivitySet.add(actRdt.Regulatory_Tracking_Activity_gne__c);
        }
        for(CFAR_Regulatory_Document_Tracking_gne__c closeRdt : closureRdtList){
            closureRdtActivitySet.add(closeRdt.Regulatory_Tracking_Activity_gne__c);
        }
        for(CFAR_Regulatory_Document_Tracking_gne__c maintRdt : maintenanceRdtList){
            maintenanceRdtActivitySet.add(maintRdt.Regulatory_Tracking_Activity_gne__c);
        }
        return null;
    }

    // public List<CFAR_Regulatory_Document_Tracking_gne__c> getActivationRDTList() {
    //     List<CFAR_Regulatory_Document_Tracking_gne__c> activationRDTList = new List<CFAR_Regulatory_Document_Tracking_gne__c>();
    //     for(CFAR_Regulatory_Document_Tracking_gne__c rdt : rdtList)
    //         if(rdt.Regulatory_Tracking_Activity_gne__r.Study_Stage__c  == 'Activation'){
    //             activationRDTList.add(rdt);
    //         }
    //     return activationRDTList;
    // }
    public void editAllActivationRdts(){
        editActivationRdts = true;
        activityOptions = getActivityOptions();
    }

    public void cancelAllActivationRdts(){
        editActivationRdts = false;
    }

    public void editAllClosureRdts(){
        editClosureRdts = true;
        activityOptions = getActivityOptions();
    }

    public void cancelAllClosureRdts(){
        editClosureRdts = false;
    }

    public void editAllMaintenanceRdts(){
        editMaintenanceRdts = true;
        activityOptions = getActivityOptions();
    }

    public void cancelAllMaintenanceRdts(){
        editMaintenanceRdts = false;
    }

    public List<CFAR_Regulatory_Document_Tracking_gne__c> processRtdList(List<CFAR_Regulatory_Document_Tracking_gne__c> rdtList){
        List<CFAR_Regulatory_Document_Tracking_gne__c> rtdListToReturn = new List<CFAR_Regulatory_Document_Tracking_gne__c>();
        for(CFAR_Regulatory_Document_Tracking_gne__c rtd : rdtList){
            if(IRBActivitiesSet.contains(rtd.Regulatory_Tracking_Activity_gne__r.Name)){
                if(trial.IRB_Required_gne__c == 'YES'){
                    rtdListToReturn.add(rtd);
                }
            } else if(INDActivitiesSet.contains(rtd.Regulatory_Tracking_Activity_gne__r.Name)){
                if(trial.IND_Required_gne__c == 'YES'){
                    rtdListToReturn.add(rtd);
                }
            } else if(rtd.Regulatory_Tracking_Activity_gne__r.Name == 'Final Study Report Received'){
                if(trial.FSR_Required_gne__c == 'YES'){
                    rtdListToReturn.add(rtd);
                }
            } else if(rtd.Regulatory_Tracking_Activity_gne__r.Name == 'Capability Assessment Form Completed'){
                if(trial.Capability_Assessment_Required__c == 'YES'){
                    rtdListToReturn.add(rtd);
                }
            } else {
                rtdListToReturn.add(rtd);             
            }      
        }
        return rtdListToReturn;
    }

    public List<SelectOption> getActivityOptions(){
        list<SelectOption> displayoptions = new list<SelectOption>();
        list<SelectOption> options = new list<SelectOption>();
        CFAR_SearchParameters searchParameters = new CFAR_SearchParameters();
        CFAR_Regulatory_Document_Tracking_gne__c tempRDT;
        if(currentRDT != null && currentRDT.Id != null) {
        	List<CFAR_Regulatory_Document_Tracking_gne__c> rdts = [SELECT Regulatory_Tracking_Activity_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE Id = :currentRDT.Id AND Regulatory_Tracking_Activity_gne__r.Study_Stage__c != null];
        	if(rdts.size() > 0) tempRDT = rdts.get(0);
        }
        
        for (CFAR_Tracking_Activity_gne__c trAct :  CFAR_DAO.getRegDocTrackingActivity(searchParameters)) {
            if (trAct.Study_Stage__c != null && (trAct.Active_gne__c == true || (tempRDT != null && trAct.Id == tempRDT.Regulatory_Tracking_Activity_gne__c))) {
                options.add(new SelectOption(trAct.Id, trAct.Name));
            }        	
        } 
        for (SelectOption entry : options)
        {
            if(IRBActivitiesSet.contains(entry.getLabel())){
                if(trial.IRB_Required_gne__c == 'YES'){
                    displayoptions.add(new SelectOption(entry.getValue(),entry.getLabel()));
                }
            } else if(INDActivitiesSet.contains(entry.getLabel())){
                if(trial.IND_Required_gne__c == 'YES'){
                    displayoptions.add(new SelectOption(entry.getValue(),entry.getLabel()));
                }
            } else if(entry.getLabel() == 'Final Study Report Received'){
                if(trial.FSR_Required_gne__c == 'YES'){
                    displayoptions.add(new SelectOption(entry.getValue(),entry.getLabel()));
                }
            } else if(entry.getLabel() == 'Capability Assessment Form Completed'){
                if(trial.Capability_Assessment_Required__c == 'YES'){
                    displayoptions.add(new SelectOption(entry.getValue(),entry.getLabel()));
                }
            } else {
                displayoptions.add(new SelectOption(entry.getValue(),entry.getLabel()));
            }       
        }
        if(displayoptions.size() > 0){
            displayNewButton = true;
        } else {
            displayNewButton = false;
        }
        return displayoptions;
    }

    public void processTrialAfterRdtsInsert(List<CFAR_Regulatory_Document_Tracking_gne__c> rdtList, CFAR_Trial_gne__c trial){
        Boolean updateTrial = false;
        Map<CFAR_Regulatory_Document_Tracking_gne__c, String> rdtNameMap = new Map<CFAR_Regulatory_Document_Tracking_gne__c, String>();

        for(CFAR_Regulatory_Document_Tracking_gne__c rdt : rdtList){
            rdtNameMap.put(rdt, rdt.Regulatory_Tracking_Activity_gne__c);
        }

        Set<String> rdtNames = new Set<String>();

        for(SelectOption ao : activityOptions) {
            for(CFAR_Regulatory_Document_Tracking_gne__c rdt : rdtList){
                if(ao.getValue().equals(rdt.Regulatory_Tracking_Activity_gne__c)) {
                    rdtNames.add(ao.getLabel());
                }
            }       
        }

        for(CFAR_Regulatory_Document_Tracking_gne__c rdt : rdtList){
            if(rdtNames.contains('IRB Renewal') && rdt.Expiry_Date_gne__c != null){
                trial.IRB_Renewal_Date_gne__c = rdt.Expiry_Date_gne__c;
                CFAR_Utils.setAlreadyProcessed();
                updateTrial = true;
            }
            if(rdtNames.contains('IRB Closure Letter Received') && selectedIRBRequired == 'YES'){
                trial.IRB_Closure_Letter_Received_gne__c = true;
                trial.IRB_Closure_Received_Date_gne__c = rdt.Date_Received_gne__c;
                CFAR_Utils.setAlreadyProcessed();
                updateTrial = true;
            }               
            if(rdtNames.contains('Study Closure Letter Sent')){
                trial.Study_Closure_Letter_Received_gne__c = true;
                trial.Study_Closure_Received_Date_gne__c = rdt.Date_Received_gne__c;
                CFAR_Utils.setAlreadyProcessed();
                updateTrial = true;
            }
            if(rdtNames.contains('Final Study Report Received') && selectedFSRRequired =='YES'){
                trial.Final_Study_Report_Received_gne__c = true;
                trial.Final_Study_Report_Received_Date_gne__c = rdt.Date_Received_gne__c;
                CFAR_Utils.setAlreadyProcessed();
                updateTrial = true;
            }
            if(updateTrial){
                CFAR_SecurityUtils.updateRecord(trial);
            }
        }
    }

    public PageReference saveAllActivationRtds() {
        try {
            ApexPages.StandardSetController ctrl = new ApexPages.StandardSetController(activationRdtList);     
            PageReference pr = ctrl.save();
            isError = pr == null && ApexPages.hasMessages();
            refreshTrial();
            if (isError) {
                logMessage();
            } else {         
                editActivationRdts = false;
            }
        } catch (Exception ex) {
            super.addErrorMessage(ex.getMessage());
        }
        sortRdt();
        return null;
    }

    public PageReference saveAllClosureRtds() {
        try {        
            ApexPages.StandardSetController ctrl = new ApexPages.StandardSetController(closureRdtList);
            processTrialAfterRdtsInsert(closureRdtList, trial);
            PageReference pr = ctrl.save();
            isError = pr == null && ApexPages.hasMessages();
            refreshTrial();
            if (isError) {
                logMessage();
            } else {         
                editClosureRdts = false;
            }
        } catch (Exception ex) {
            super.addErrorMessage(ex.getMessage());
        }
        sortRdt();
        return null;
    }

    public PageReference saveAllAMaintenanceRtds() {
        try {        
            ApexPages.StandardSetController ctrl = new ApexPages.StandardSetController(maintenanceRdtList);
            PageReference pr = ctrl.save();
            isError = pr == null && ApexPages.hasMessages();
            refreshTrial();
            if (isError) {
                logMessage();
            } else {         
                editMaintenanceRdts = false;
            }
        } catch (Exception ex) {
            super.addErrorMessage(ex.getMessage());
        }
        sortRdt();
        return null;
    }
    
    public List<SelectOption> getInvestigatorsOptions() {
    	List<SelectOption> options = new List<SelectOption>();
    	List<CFAR_Team_Member_gne__c> investigators = [select Id, frm_Name_gne__c, frm_Is_Inactive_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c from CFAR_Team_Member_gne__c where CFAR_Trial_ref_gne__c = :trial.Id and frm_Function_Role_gne__c IN ('PI = Primary (or Principal) Investigator', 'Sub-I = Sub-investigator') order by frm_Function_Role_gne__c, frm_Name_gne__c, frm_Is_Inactive_gne__c];
        CFAR_Regulatory_Document_Tracking_gne__c tempRDT;
        if(currentRDT != null && currentRDT.Id != null) {
        	List<CFAR_Regulatory_Document_Tracking_gne__c> rdts = [SELECT Reg_Doc_Investigator_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE Id = :currentRDT.Id];
        	if(rdts.size() > 0) tempRDT = rdts.get(0);
        }
    	Set<Id> contactsIds = new Set<Id>();
    	for (CFAR_Team_Member_gne__c member : investigators) {
    		if (member.frm_Is_Inactive_gne__c == false || (member.frm_Is_Inactive_gne__c == true && tempRDT != null && tempRDT.Reg_Doc_Investigator_gne__c == member.Id)) {
    			//in case we've got document on inactive member and there's also added to team active member for the same contact, let's show only active one
    			if (contactsIds.add(member.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c)) {
    				options.add(new SelectOption(member.Id, member.frm_Name_gne__c));
    			}
    		}
    	}
    	return options;
    }  
    
    public List<SelectOption> getINDRequiredOptions(){
        List<SelectOption> options = new List<SelectOption>();
        list<Schema.PicklistEntry> values = CFAR_Trial_gne__c.sObjectType.getDescribe().fields.getMap().get('IND_Required_gne__c').getDescribe().getPickListValues();
        options.add(new SelectOption('', '--None--'));
        for (Schema.PicklistEntry entry : values)
        {
            options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
        }        
        return options;
    }
    
    public List<SelectOption> getFSRRequiredOptions(){
        List<SelectOption> options = new List<SelectOption>();
        list<Schema.PicklistEntry> values = CFAR_Trial_gne__c.sObjectType.getDescribe().fields.getMap().get('FSR_Required_gne__c').getDescribe().getPickListValues();
        options.add(new SelectOption('', '--None--'));
        for (Schema.PicklistEntry entry : values)
        {
            options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
        }       
        return options;
    }

    public List<SelectOption> getCapaAssessRequiredOptions(){
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> values = CFAR_Trial_gne__c.sObjectType.getDescribe().fields.getMap().get('FSR_Required_gne__c').getDescribe().getPickListValues();
        options.add(new SelectOption('', 'N/A'));
        for (Schema.PicklistEntry entry : values) {
            options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
        }     
        return options;
    }

    public List<SelectOption> getSDEARequiredOptions(){
        List<SelectOption> options = new List<SelectOption>();
        list<Schema.PicklistEntry> values = CFAR_Trial_gne__c.sObjectType.getDescribe().fields.getMap().get('FSR_Required_gne__c').getDescribe().getPickListValues();
        options.add(new SelectOption('', 'N/A'));
        for (Schema.PicklistEntry entry : values) {
            options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
        }      
        return options;
    }
    
    public List<SelectOption> getIRBRequiredOptions(){
        List<SelectOption> options = new List<SelectOption>();
        list<Schema.PicklistEntry> values = CFAR_Trial_gne__c.sObjectType.getDescribe().fields.getMap().get('IRB_Required_gne__c').getDescribe().getPickListValues();
        options.add(new SelectOption('', 'None'));
        for (Schema.PicklistEntry entry : values)
        {
            options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
        }       
        return options;
    }
    
    public void editRDT(){
        indDateInFuture = false;
        editMode = false;
        isError = false;
        for(CFAR_Regulatory_Document_Tracking_gne__c rdt : rdtList){
            if(rdt.Id == currentrdtId){
                currentRDT = rdt;
            }
        }
        for(CFAR_Regulatory_Document_Tracking_gne__c activationRdt : activationRdtList){
            if(activationRdt.Id == activationCurrentRDTId){
                currentRDT = activationRdt;
            }
        }
        for(CFAR_Regulatory_Document_Tracking_gne__c closureRdt : closureRdtList){
            if(closureRdt.Id == closureCurrentRDTId){
                currentRDT = closureRdt;
            }
        }
        for(CFAR_Regulatory_Document_Tracking_gne__c maintRdt : maintenanceRdtList){
            if(maintRdt.Id == maintenanceCurrentRDTId){
                currentRDT = maintRdt;
            }
        }
        activationCurrentRDTId = null;
        closureCurrentRDTId = null;
        maintenanceCurrentRDTId = null;
        activityOptions = getActivityOptions();
    }
    
    public void saveRDT(){
        isError = false;
        Boolean updateTrial = false;
        if(currentRDT.Date_Received_gne__c > System.today()){
            isError = true;
            errorMessage = 'Date cannot be in the future';
            sortRdt();
            for(CFAR_Regulatory_Document_Tracking_gne__c rdt : rdtList){
                if(rdt.Id == currentrdtId){
                    currentRDT = rdt;
                }
            }
            for(CFAR_Regulatory_Document_Tracking_gne__c activationRdt : activationRdtList){
                if(activationRdt.Id == activationCurrentRDTId){
                    currentRDT = activationRdt;
                }
            }
            for(CFAR_Regulatory_Document_Tracking_gne__c closureRdt : closureRdtList){
                if(closureRdt.Id == closureCurrentRDTId){
                    currentRDT = closureRdt;
                }
            }
            for(CFAR_Regulatory_Document_Tracking_gne__c maintRdt : maintenanceRdtList){
                if(maintRdt.Id == maintenanceCurrentRDTId){
                    currentRDT = maintRdt;
                }
            }
            return;
        } else {
            upsert currentRDT;  
        }
           
        sortRdt();
        //rdcDateCriteria = CFAR_Utils.setRDCCriteria(trial, rdtList);
        trialWrapper.innerObject.put('Regulatory_Document_Complete_Date_gne__c', trial.Regulatory_Document_Complete_Date_gne__c);
        System.debug('----------- ' + currentRDT.Regulatory_Tracking_Activity_gne__c + ' ' + currentRDT.Regulatory_Tracking_Activity_gne__r.Name + ' ' +selectedIRBRequired+ ' ' + selectedFSRRequired );
            
        String rdtName = '';
        for(SelectOption ao : activityOptions) {
            if(ao.getValue().equals(currentRDT.Regulatory_Tracking_Activity_gne__c)) {
                rdtName = ao.getLabel();
                break;
            }       
        }
        if(rdtName.equals('IRB Renewal') && currentRDT.Expiry_Date_gne__c != null){
            trial.IRB_Renewal_Date_gne__c = currentRDT.Expiry_Date_gne__c;
            CFAR_Utils.setAlreadyProcessed();
            updateTrial = true;
        }
        if(rdtName.equals('IRB Closure Letter Received') && selectedIRBRequired == 'YES'){
            trial.IRB_Closure_Letter_Received_gne__c = true;
            trial.IRB_Closure_Received_Date_gne__c = currentRDT.Date_Received_gne__c;
            CFAR_Utils.setAlreadyProcessed();
            updateTrial = true;
        }               
        if(rdtName.equals('Study Closure Letter Sent')){
            trial.Study_Closure_Letter_Received_gne__c = true;
            trial.Study_Closure_Received_Date_gne__c = currentRDT.Date_Received_gne__c;
            CFAR_Utils.setAlreadyProcessed();
            updateTrial = true;
        }
        if(rdtName.equals('Final Study Report Received') && selectedFSRRequired =='YES'){
            trial.Final_Study_Report_Received_gne__c = true;
            trial.Final_Study_Report_Received_Date_gne__c = currentRDT.Date_Received_gne__c;
            CFAR_Utils.setAlreadyProcessed();
            updateTrial = true;
        }
        if(updateTrial){
            CFAR_SecurityUtils.updateRecord(trial);
        }
        sortRDT();      
        setRDCDateMessage();
    }
    
    public void refreshView(){
        setRDCDateMessage();
        refreshTrial();
        sortRDT();         
    }
    public void refreshIRB(){
    	refreshTrial();
    	if(trial != null) {
    		sortRdt();
        	setStartValues();
        }
    }
    public void refreshIND(){
    	refreshTrial();
    	if(trial != null) {
    		sortRdt();
        	setStartValues();
        }
    }
    public void cancelRDT(){
        isError = false;
        sortRdt();
    }

    public void addNewRDT(){
        editMode = false;
        currentRDT = new CFAR_Regulatory_Document_Tracking_gne__c();
        currentRDT.CFAR_Trial_gne__c = trial.Id;
        //refreshTrial();
        List<CFAR_Team_Member_gne__c> inv = [select Id from CFAR_Team_Member_gne__c where CFAR_Trial_ref_gne__c = :trial.Id and Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c = :((CFAR_Trial_gne__c)trialWrapper.innerObject).Investigator_ref_gne__c and frm_Function_Role_gne__c = 'PI = Primary (or Principal) Investigator' and frm_Is_Inactive_gne__c = false];
        if (inv.size() == 1) {
        	currentRDT.Reg_Doc_Investigator_gne__c = inv.get(0).Id;
        }
        activityOptions = getActivityOptions();
    }
    
    public void saveTrial(){
        indDateInFuture = false;
        if(tempTrial.IND_Exempt_Letter_Date_gne__c > system.today()){
            indDateInFuture = true;      
            return;
        }    
        editMode = false;
        trial.IND_Required_gne__c = selectedINDRequired;
        trial.IRB_Required_gne__c = selectedIRBRequired;
        trial.FSR_Required_gne__c = selectedFSRRequired;
        trial.Capability_Assessment_Required__c = selectedCapaAssessRequired;
        trial.SDEA_Required__c = selectedSDEARequired;
        trial.IND_gne__c = iNDNumber;
        trial.IND_Exempt_Letter_Date_gne__c = tempTrial.IND_Exempt_Letter_Date_gne__c;      
        trial.Regulatory_Document_Complete_Date_gne__c = tempTrial.Regulatory_Document_Complete_Date_gne__c;
        CFAR_SecurityUtils.updateRecord(trial);
        //rdcDateCriteria = CFAR_Utils.setRDCCriteria(trial, rdtList);
        trialWrapper.innerObject.put('Regulatory_Document_Complete_Date_gne__c', trial.Regulatory_Document_Complete_Date_gne__c);
        setSelectOptionValues();
        setRDCDateMessage();
        sortRdt();
    }

    public void cancelTrial(){
        indDateInFuture = false;
        editMode = false;
        refreshTrial();
        setStartValues();
        setRDCDateMessage();
    }
    
    public void editTrial(){
        editMode = true;
        iNDNumber = trial.IND_gne__c;
        tempTrial.Regulatory_Document_Complete_Date_gne__c = trial.Regulatory_Document_Complete_Date_gne__c;  
    }

    public CFAR_Publication_gne__c currentPublication {get; set;}
    public Boolean addEditPublication {get;set;}
    public String publicationId {get; set;}

    public PageReference submitPublication() {
    	if (currentPublication.Source_gne__c == null && 
    		currentPublication.Status_gne__c == null && 
    		currentPublication.Author_gne__c == null && 
    		currentPublication.Date_Received_gne__c == null && 
    		currentPublication.Date_Published_gne__c == null) {
    		isError = true;
    		errorMessage = 'Cannot save publication without any input';
    		return null;
    	}
        if(currentPublication.Date_Received_gne__c > system.today()){
            isError = true;
            errorMessage = 'Date Received cannot be in the future';
            return null;
        }
        if (currentPublication.Date_Planned_gne__c < System.today() ) {
            CFAR_Publication_gne__c oldPublication;
            if (currentPublication.Id != null) {
                oldPublication = [SELECT Id, Date_Planned_gne__c FROM CFAR_Publication_gne__c WHERE Id = :currentPublication.Id];
            }
            if ((oldPublication == null || (oldPublication.Date_Planned_gne__c != currentPublication.Date_Planned_gne__c))
                    && currentPublication.Date_Planned_gne__c < Date.today()) {                isError = true;
                errorMessage = 'Date Planned cannot be in the past';
                return null;
            }
        }
        ApexPages.StandardController ctrl = new ApexPages.StandardController(currentPublication);
        PageReference pr = ctrl.save();
        isError = pr == null && ApexPages.hasMessages();
        if(isError) {
            logMessage();
        } else {
            refreshTrial();
            getPubications();
        }
        return null;
    }

    public CFAR_Publication_gne__c[] getPubications() {
    	if(trial != null) {
	        stdSetControllerProjection = new ApexPages.StandardSetController(CFAR_DAO.getPubicationsBytrialId(trial.Id));
	        stdSetControllerProjection.setPageSize(100);
	        return stdSetControllerProjection.getRecords();
    	} else return null;
    }

    public void editPublication() {
        resetError();
        currentPublication = CFAR_DAO.getPubicationById(PublicationId); 
        addEditPublication = true;
    }
    
    public void createNewPublication() {
        currentPublication = new CFAR_Publication_gne__c(CFAR_Trial_ref_gne__c = trialId);
        addEditPublication = true;
    }
    
    public void cancelCreatePublication() {
        addEditPublication = false;
        resetError();
    }
	
	public void clearDatePublished(){
		if(currentPublication.Status_gne__c != null && currentPublication.Status_gne__c.equals('Rejected')){
			currentPublication.Date_Published_gne__c=null;
		}
	}
 
}