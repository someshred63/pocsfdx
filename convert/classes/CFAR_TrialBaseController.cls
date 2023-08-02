public virtual class CFAR_TrialBaseController extends CFAR_BaseController{
	
	public Boolean trialNotAvailable {
		get {
			return ApexPages.currentPage().getParameters().get('id') != null && trial == null;
		}
		set;
	}
	
	@TestVisible private Boolean isFromTab;
	public static final String DRUG_ONLY = 'Drug Only';
	
	public String printTrialName(){
		return (trial == null) ? 'Trial has no name ' : trial.name;
	}

	public CFAR_TrialWrapper trialWrapper; 
	@TestVisible protected Map<Id, String> dollarAndDrugMap;

    public virtual CFAR_TrialWrapper getTrialWrapper(){
    	if (trialWrapper == null) {
    		trialWrapper = new CFAR_TrialWrapper(); 
    	}
    			
        CFAR_Utils.logError('CFAR_TrialBaseController getting trialWrapper.name: ' + 
            (null  != trialWrapper && null  != trialWrapper.innerObject ? (String.valueOf(trialWrapper.innerObject.get('name'))) : ' --pusty name- ' )); 

		if(isFromTab && CFAR_Utils.getActualTrialId() != null && trialWrapper.innerObject.Id != CFAR_Utils.getActualTrialId()) {
			trialWrapper.innerObject  = (sObject) CFAR_DAO.getTrial(CFAR_Utils.getActualTrialId());
			editMode = false;
			oldTrialId = CFAR_Utils.getActualTrialId(); 
            refreshTrialChildObjects();			
		} else if(trialWrapper.innerObject != null && trialWrapper.innerObject.Id != null) {
			CFAR_Utils.setActualTrialId(trialWrapper.innerObject.Id);
		}
    	return trialWrapper; 
    }
    
    /* oldTrialId - stored in viewstate, used for detection when trialId was changed - especially during setting of trialWrapper and trial itself*/ 
    @TestVisible private String oldTrialId = '';
    public virtual void setTrialWrapper(CFAR_TrialWrapper value){
    		System.debug(' componentId: ' + componentId + ' trialName before Set: ' + trialWrapper.getTrialName() + ' new trialName: ' + value.getTrialName() ); 
    		
    		
            CFAR_Utils.logError('SETTINGtrial wrapper Start'); 
            trialWrapper = value;  
    		System.debug(' componentId: ' + componentId + ' oldTrialId: ' + oldTrialId + ' new trialId: ' + trialId ); 
            if( ! trialId.equals(oldTrialId))
            {
	    		System.debug(' refreshTrialChildObjects: ' + componentId +  ' oldTrialId: ' + oldTrialId + ' trialId: ' + printTrialName());
	    		editMode = false;
            	oldTrialId = trialId; 
            	refreshTrialChildObjects();
            }
            if(trialId != null)
            	CFAR_Utils.setActualTrialId(Id.valueOf(trialId));
    }
    
    /*this method will fetch all trial-related data and and child objects. The method will be overriden in subclasses*/ 
    public virtual void refreshTrialChildObjects(){
    }
    
    public CFAR_Trial_gne__c trial {
        get{
            return (CFAR_Trial_gne__c)getTrialWrapper().innerObject; 
            }
        set{
        	trialWrapper.innerObject = (sObject)value; 
            if(trialWrapper.innerObject != null)
            	CFAR_Utils.setActualTrialId(trialWrapper.innerObject.id);
        }
    }
    
    public String trialId {
        get
        {
        		return trial != null ?  trial.id : null; 
        }
    }

    public CFAR_TrialBaseController(){
    	if(this.isFromTab == null)
    		this.isFromTab = false;
    	if(trialId == null)
        {
            ID param = ApexPages.currentPage().getParameters().get('id'); 
            if(param != null) {
            	System.debug('#####trialWrapper.innerObject.id before query ' +trialWrapper.innerObject.id); 
            	
                CFAR_Utils.logError(' CFAR_TrialBaseController constructor + param ' + param);
                
                trial = CFAR_DAO.getTrial(param);
            	//System.debug('#####trialWrapper.innerObject.id after query ' +trialWrapper.innerObject.id); 
		        if(trial != null) refreshTrialChildObjects(); 
            }
        }
        prepareDollarAndDrugMap();
        
        //initWholeContactsSearchList();
        editMode = false;
    }
    
    public CFAR_TrialBaseController(Boolean isFromTab){
    	this();
    	this.isFromTab = true;
    }
    
    /**
    protected List<SelectOption> wholeContactsSearchList;
    
    public void initWholeContactsSearchList() {
        wholeContactsSearchList = new SelectOption[]{};
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.andEqualsParameters.put('Active_gne__c','true'); 
        searchParms.sortExpression = 'Search_Name__c'; 
        searchParms.sortDirection = 'asc';  
        wholeContactsSearchList.addAll(CFAR_Utils.getContactSelectOptions(searchParms)) ;
    }
    */

    /*if trial id is not empty assigns to trial variable corresponding trial from DB, else creates new Trial and assigns*/  
    public virtual void refreshTrial(){
        CFAR_Utils.logError(' Refreshing Trial by id = ' + trialId);
        CFAR_Trial_gne__c refreshedTrial; // = CFAR_DAO.getTrial(trialId); 
            
        if (!(String.isBlank(trialId))){
            trial  = CFAR_DAO.getTrial(trialId);
        }
    }
    
    public void prepareDollarAndDrugMap() {
    	dollarAndDrugMap = new Map<Id, String>();
        CFAR_SearchParameters searchParameters = new CFAR_SearchParameters();
     	searchParameters.andEqualsParameters.put('Active_gne__c','true');
        CFAR_Dollar_and_Drug_gne__c [] dollarToDrugs = CFAR_DAO.getDollarAndDrug(searchParameters);
        for(CFAR_Dollar_and_Drug_gne__c dollarAndDrug : dollarToDrugs) {
        	dollarAndDrugMap.put(dollarAndDrug.Id, dollarAndDrug.Name);
        }
    }
    
    //public integer getMilestonesSize(){return milestoneActivities.size(); }
        

    
    public virtual override PageReference cancel(){
    	refreshTrial(); 
        editMode = false;
        return null;
    }
    
    public virtual void edit(){
        editMode = true;
    }


    public String componentID; 

    //////////////////////////
    public virtual void save(){
        //try{
            
            CFAR_Utils.logError(' componentID = ' + componentID);
            CFAR_Utils.logError(' Saving = ' + trialId);
            CFAR_Utils.logError(' Saving trial obj: ' + trial);
            CFAR_Utils.logError(' Saving trial.CFAR_Enrollment_Start_Date_gne__c: ' + trial.CFAR_Enrollment_Start_Date_gne__c);         
            PageReference pr = (new ApexPages.StandardController(trial)).save();
            if(pr != null) {
            	CFAR_Utils.logError(' Save result ' + pr);  
            	editMode = false;
	            refreshTrial(); 
            }
        /*
        } catch (Exception e){
            CFAR_Utils.logError(' CFAR_TrialBaseController.save() ' +  e.getStackTraceString() ); 
        }
        */
        
        CFAR_Utils.logInfo(' CFAR_TrialBaseController.save() - finished ' ); 
        
    }
    
    
    public Boolean trialhasContractAmendment(){
        return(trial.Has_Amendment_Amount_gne__c > 0); 
    }
    
    public Boolean getRenderNotClosedOrIsAdmin() {
    	return (trial != null && !trial.frm_Is_Closed_gne__c && !getIsAdminFixStatus())
    		|| (getCurrentUserIsAdmin() && !getIsAdminFixStatus())
            || getIsSFDCSystemAdministrator() || getIsGNEMASupport();

    }
    
    public Boolean getRenderNotReadOnlyAndNotClosedOrIsAdmin() {
    	return trial != null && ((!getIsReadOnly() && !trial.frm_Is_Closed_gne__c && !getIsAdminFixStatus()) 
    		|| (getCurrentUserIsAdmin() && !getIsAdminFixStatus()));
    }
    
    public Boolean getRenderTrialClosedAndUserIsAdmin() {
    	return trial != null && (getCurrentUserIsAdmin() && trial.frm_Is_Closed_gne__c);
    }
	
	public Boolean getRenderTrialClosed() {
    	return trial != null && trial.frm_Is_Closed_gne__c;
    }

	public Boolean getRerenderTrialClosedAndUserNotAdmin() {
		return trial != null && trial.frm_Is_Closed_gne__c && !getCurrentUserIsAdmin();
	}
	
	public Boolean getIsReadOnlyOrAdminFixStatus() {
		return getIsReadOnly() || getIsAdminFixStatus();
	}
	
	public Boolean getIsAdminFixStatus() {
		return trial != null && trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX;
	}
    
}