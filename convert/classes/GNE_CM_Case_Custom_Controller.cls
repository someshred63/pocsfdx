/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2010-10-13
*  Description: 
*  
*  Modification History
*  Date        Name        Description
*                
*************************************************************/
public class GNE_CM_Case_Custom_Controller implements GNE_CM_DDS_Embeddable_Controller
{
    private final String caseProduct = 'case_product';
    private final String caseMedHistID = 'case_medhistoryid';
    
    private ApexPages.StandardController controller;
    private Case caseItem;
    private String patientID;
    private String productName; 
    public Boolean flag{get; set;}
    public Set<String> UserProfileSet = new Set<String>();
    //public List<Environment_Variables__c> envVars = new List<Environment_Variables__c>();    
    public boolean taskLoganErrorFlag {get; set;}
    public List<Task> lsttask; 
    public Boolean flagProfile{get; set;}
    public string ProfileName;
    //public List<Alerts_gne__c> alerts{get;set;}
    public Boolean TitleDisplayCRFlag {get; set;}
    public Boolean TitleDisplayGATCFFlag {get; set;}
    public Boolean TitleDisplayCRChildFlag {get; set;}
    public Boolean TitleDisplayGATCFChildFlag {get; set;}
    string Pertuzumab_product_Name = system.label.GNE_CM_Pertuzumab_Product_Name;
    Id gatcfStandardCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GATCF - Standard Case').getRecordTypeId();
    Id gesCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GATCF - Eligibility Screening').getRecordTypeId();
    Id crCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('C&R - Standard Case').getRecordTypeId();
    
    public Boolean showRequestEBIBtn { get; private set; }
    public Boolean showUpdateTasksBtn { get; private set; }
    
    public static final Date CURRENT_DATE = Date.today();
    public static final Date BR_CURRENT_YEAR_BATCH_START_DATE;
    public static final Date ELIGIBLE_ADOT_END_DATE;
    
    // controller of the DDS Eligibility View component
    private GNE_CM_DDS_Eligibility_View_Controller ddsController;
    
    public GNE_CM_Case_Custom_Controller caseCustomController { get { return this; } }
    
	public GNE_CM_Case_Custom_Controller (ApexPages.StandardController stdController) 
	{
		flag = false;
        //wilczekk: not used anywhere, please remove
		controller = stdController;
        controller.addFields(new List<String> {'DDS_BI_Eligible_gne__c', 'DDS_BI_Override_gne__c'});        
		caseItem = (Case)controller.getRecord(); 
               
        Profile profile = [select id,name from Profile where id=:UserInfo.getProfileId()];
        //alerts = [Select Id, Alert_Message_gne__c, Type_gne__c from Alerts_gne__c where Case_gne__c =: caseItem.Id];
        
        if (profile.name=='GNE-CM-GATCFFS')
        {
            flag = true;
        }  
        //KS: For Pertuzumab  
        
		if (caseItem.id != null)
		{
			lsttask =  [Select id,Subject from Task where whatid = : caseItem.id and Subject = 'Review Case Management Error Log Entry'];
		}
      
		if (lsttask != null && lsttask.size() > 0)
		{
			taskLoganErrorFlag = true;
		}
        else
        {
			taskLoganErrorFlag = false;
        }  
       
        ProfileName = profile.Name;
        
        if (ProfileName != '')
        {
            if (ProfileName.startsWith('GNE-CM') || ProfileName == 'GNE-SYS-Support' || ProfileName == 'GNE-SFA-InternalUser' || ProfileName == 'System Administrator')
            {
				flagProfile = true;
            }
            else
            {
				flagProfile = false;
            }    
        }
        
        if (caseItem.id != null && caseItem.Product_gne__c == Pertuzumab_product_Name && (caseitem.Combo_Therapy_Case_Flag_gne__c== true || caseItem.Combo_Therapy_Case_gne__c != null || caseitem.Combo_Therapy_Child_Case_gne__c != null))
       	{
			if (caseItem.recordTypeId == crCaseRecordTypeId)
			{
            	TitleDisplayCRFlag = true;
            	TitleDisplayGATCFFlag = false;
			}
			else if (caseItem.recordTypeId == gatcfStandardCaseRecordTypeId || caseItem.recordTypeId == gesCaseRecordTypeId)
			{
				TitleDisplayGATCFFlag = true;
				TitleDisplayCRFlag = false;
			}
		} 
		else if (caseItem.id != null && caseItem.Combo_Therapy_Case_gne__c != null && caseItem.Product_gne__c == 'Herceptin')
		{
			if (caseItem.recordTypeId == crCaseRecordTypeId)
			{
				TitleDisplayCRChildFlag = true;
				TitleDisplayGATCFChildFlag = false;
			}
			else if (caseItem.recordTypeId == gatcfStandardCaseRecordTypeId || caseItem.recordTypeId == gesCaseRecordTypeId)
			{
				TitleDisplayGATCFChildFlag = true;
				TitleDisplayCRChildFlag = false;
			}
		}
		
		if (caseItem.id != null && caseItem.Combo_Therapy_Case_Flag_gne__c == null && caseItem.Product_gne__c == 'Herceptin')
		{
			TitleDisplayGATCFFlag = false;
			TitleDisplayCRFlag = false;
		}
        //KS: For Pertuzumab Changes end here 
        
        // init env variables
        //initEnvVars();
        
        this.showRequestEBIBtn = GNE_CM_EBI_Util.isCaseEbiEligible(caseItem);
        
        if(!GNE_CM_DDS_Settings__c.getInstance().Functionality_Disabled__c) 
        {
			if(!caseItem.DDS_BI_Eligible_gne__c && !caseItem.DDS_BI_Override_gne__c)
			{
				this.showRequestEBIBtn = false;
			}        	
        }
        
		Boolean isProduct = caseItem.Product_gne__c == 'Actemra'  || caseItem.Product_gne__c == 'Lucentis';
		this.showUpdateTasksBtn = GNE_CM_Blizzard_Utils.isBlizzardPeriod(Date.today()) && isProduct;
	}
	
	public void setDdsController (GNE_CM_DDS_Eligibility_View_Controller ctrl)
    {
        this.ddsController = ctrl;
    }
    
    public Case getCase()
    {
        return (Case)this.controller.getRecord();
    }
	
    public void setRequestServicesVisible(boolean requestServicesVisible)
    {
    	this.flagProfile = requestServicesVisible;
    }
	
	/**
	 * Initializes environent variables used by all actions within this controller.
	 */
	 /*
	private void initEnvVars()
	{
		Set<String> envVarNames = new Set<String> { caseProduct, caseMedHistID, 'GNE_CM_EBI_Products', 'GNE_CM_Profiles' };
		this.envVars = GNE_CM_Environment_variable.get_envVariable(envVarNames);
	}
    */
    public PageReference edit()
    {
        PageReference editPage = null;
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Case.getRecordTypeInfosByName();    
        Id cr = recordTypes.get('C&R - Standard Case').getRecordTypeId();
        Id gatcf = recordTypes.get('GATCF - Standard Case').getRecordTypeId();
        Id ges = recordTypes.get('GATCF - Eligibility Screening').getRecordTypeId();
        Id ccc = recordTypes.get('C&R - Continuous Care Case').getRecordTypeId();
        
        if (caseItem.RecordTypeId == cr || caseItem.RecordTypeId == ccc)
        {
            editPage = new PageReference('/apex/GNE_CM_Case_VF_CRS_Edit?id=' + caseItem.Id);
        }
        else if (caseItem.recordTypeId == gatcf)
        {
            editPage = new PageReference('/apex/GNE_CM_Case_VF_GATCF_Edit?id=' + caseItem.Id);
        }
        else if (caseItem.recordTypeId == ges)
        {
            editPage = new PageReference('/apex/GNE_CM_Case_VF_GES_Edit?id=' + caseItem.Id);
        }
        
        return editPage;
    }
    
    public PageReference newCase()
    {
        system.debug('##########Inside New case##############');
        PageReference newPage = null;
        Map<String, String> parameters = System.currentPagereference().getParameters(); 
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Case.getRecordTypeInfosByName();
        Id cr = recordTypes.get('C&R - Standard Case').getRecordTypeId();
        Id gatcf = recordTypes.get('GATCF - Standard Case').getRecordTypeId();
        Id ges = recordTypes.get('GATCF - Eligibility Screening').getRecordTypeId();        
        Map<String, String> envVarMap = getEnvironmentVariables();
                
        String medHistID = parameters.get(envVarMap.get(caseMedHistID) + '_lkid');              
        
        //Kishore: Stream3 : 8/19/11
        getICD9Code();
        
        if (ges == caseItem.RecordTypeId)
        {
            ApexPages.Message gesCaseErr = new ApexPages.Message(ApexPages.Severity.ERROR,
                                     'GES Cases can only be created by cloning from a C&R Standard Case.');
            ApexPages.addMessage(gesCaseErr);           
            return null;            
        }
        
        getPatient(medHistID);
        
        // DSO 12/11/2014 PFS-1914 Pegasys sunset for C&R
        // DSO 2/13/2015  PFS-2101 Xeloda sunset, make the code generic and also covers Pegasys
        if (GNE_CM_MPS_Utils.isDisabledProduct(productName))
        {
        	if (caseItem.RecordTypeId == cr)
        	{
	            ApexPages.Message crPegasysCaseErr = new ApexPages.Message(ApexPages.Severity.ERROR,
	                                     'C&R cases cannot be created for ' + productName + ' patients.');
	            ApexPages.addMessage(crPegasysCaseErr);           
	            return null;
        	}
        	else if (caseItem.RecordTypeId == gatcf && !productName.equalsIgnoreCase('Pegasys'))
        	{
        		ApexPages.Message crPegasysCaseErr = new ApexPages.Message(ApexPages.Severity.ERROR,
	                                     'GATCF cases cannot be created for ' + productName + ' patients.');
	            ApexPages.addMessage(crPegasysCaseErr);           
	            return null;
        	}
        }

        if (caseItem.RecordTypeId == cr)
        {
            if (medHistID != null && medHistID != '') //Case created from Medical History record
                newPage = new PageReference('/apex/GNE_CM_Case_VF_CRS_Edit?caseRecType=CRS&new=true&medHistID=' + medHistID + 
                                                                                                    '&patientID=' + patientID + 
                                                                                                    '&productName=' + productName);
            else //Case created alone
                newPage = new PageReference('/apex/GNE_CM_Case_VF_CRS_Edit?caseRecType=CRS&new=true');
        }
        else if (caseItem.recordTypeId == gatcf)
        {
            if (medHistID != null && medHistID != '') //Case created from Medical History record
                newPage = new PageReference('/apex/GNE_CM_Case_VF_GATCF_Edit?caseRecType=GATCF&new=true&medHistID=' + medHistID + 
                                                                                                    '&patientID=' + patientID + 
                                                                                                    '&productName=' + productName);
            else //Case created alone
                newPage = new PageReference('/apex/GNE_CM_Case_VF_GATCF_Edit?caseRecType=GATCF&new=true');
        }
        
        return newPage;
    }
    
    private void getPatient(String mhID)
    {       
        if (mhID != null && mhID != '')
        {
            List<Medical_History_gne__c> mh = [Select Patient_Med_Hist_gne__c, Patient_Med_Hist_gne__r.Name, Product_gne__c 
            from Medical_History_gne__c where Id =: mhID];
            if (mh.size() > 0)
            {
                patientID = mh[0].Patient_Med_Hist_gne__c;
                productName = mh[0].Product_gne__c;             
            }
        }
    }
    
    private void getICD9Code()
    {
    	/*
        for (Environment_Variables__c envVar : this.envVars)
        {
        	if (envVar.Key__c == 'GNE_CM_Profiles')
        	{
            	UserProfileSet.add(envVar.Value__c);
        	}
        }
        */
        /*
		for(GNE_CM_Profiles__c envVar : GNE_CM_Profiles__c.getAll().values()){
			if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
		    	UserProfileSet.add(envVar.Value__c);     	
		    }
		}
		*/
        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
		UserProfileSet.addAll(GNE_CM_CustomSettings_Utils.getValues(GNE_CM_Profiles__c.getall().values(), env));
        
        system.debug('UserProfileSet.............' + UserProfileSet);
        
        system.debug('caseItem...'+ caseItem);
        system.debug('caseItem.Medical_History_gne__c.....'+caseItem.Medical_History_gne__c);
        // KS - 8/3/2011 : Added sec to auto populate fields on Enrollment Sec on Case only for GNE-CM-* profiles
        if (caseItem.Medical_History_gne__c != null)
        {
            system.debug('caseItem.Medical_History_gne__c.....'+caseItem.Medical_History_gne__c);
            
            List <Medical_History_gne__c> medicalHistory = [select ICD9_Code_1_gne__r.Name, 
            ICD9_Code_2_gne__r.Name, ICD9_Code_3_gne__r.Name, ICD9_Code_1_gne__c, ICD9_Code_2_gne__c, ICD9_Code_3_gne__c, ICD9_Code_1_gne__r.ICD9_Code_gne__c
            from Medical_History_gne__c where Id =: caseItem.Medical_History_gne__c];
            
            string icd_code_num = medicalHistory[0].ICD9_Code_1_gne__r.ICD9_Code_gne__c;
            system.debug('icd_code_num.........' + icd_code_num);
            
            /*if (UserProfileSet.contains(UserProfile))
            {*/
            if (icd_code_num.startsWith('999.'))
            {
                system.debug('INSIDE CONDITION TO SET EMROLLMENT SEC ccc');
                caseItem.Enroll_Comp_Original_Receipt_gne__c = 'No';
                if (caseItem.Enrollment_Not_Complete_Reason_gne__c != null)
                {
                    if (!caseItem.Enrollment_Not_Complete_Reason_gne__c.contains('No Diagnosis Code'))
                  {
                      system.debug('point a11111....call point...ccc');
                      caseItem.Enrollment_Not_Complete_Reason_gne__c = caseItem.Enrollment_Not_Complete_Reason_gne__c + ';' + 'No Diagnosis Code';
                  }
                  else
                  {
            system.debug('point b222222....call point...ccc');
                    system.debug('New Case + Not Null Enrollment Not Complete Reason Field.....');
                    caseItem.Enrollment_Not_Complete_Reason_gne__c = caseItem.Enrollment_Not_Complete_Reason_gne__c;
                  }
                }
                else
                {
                  system.debug('New Case + Null Enrollment Not Complete Reason Field......call point...ccc');
                  caseItem.Enrollment_Not_Complete_Reason_gne__c = 'No Diagnosis Code';
                }
                system.debug('caseItem.Enroll_Comp_Original_Receipt_gne__c' + caseItem.Enroll_Comp_Original_Receipt_gne__c);
                system.debug('caseItem.Enrollment_Not_Complete_Reason_gne__c' + caseItem.Enrollment_Not_Complete_Reason_gne__c);
            }
        //}
        }
        // Enhancement code ends here
    }
    
    private Map<String, String> getEnvironmentVariables()
    {
        Map<String, String> result = new Map<String, String>();
        /*
        for (Environment_Variables__c itemEV : this.envVars)
        {           
            result.put(itemEV.Key__c, itemEV.Value__c);
        }
        */
		/*
		for(GNE_CM_EBI_Products__c envVar : GNE_CM_EBI_Products__c.getAll().values()){
			if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
		    	result.put('GNE_CM_EBI_Products',envVar.Value__c);     	
		    }
		}    	
 		for(GNE_CM_case_product__c envVar : GNE_CM_case_product__c.getAll().values()){
			if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
		    	result.put('case_product',envVar.Value__c);     	
		    }
		}   	
 		for(GNE_CM_case_medhistoryid__c envVar : GNE_CM_case_medhistoryid__c.getAll().values()){
			if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
		    	result.put('case_medhistoryid',envVar.Value__c);     	
		    }
		}
		*/ 
		String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
		for(String value : GNE_CM_CustomSettings_Utils.getValues(GNE_CM_EBI_Products__c.getall().values(), env))
		{
			result.put('GNE_CM_EBI_Products', value);
		}
		for(String value : GNE_CM_CustomSettings_Utils.getValues(GNE_CM_case_product__c.getall().values(), env))
		{
			result.put('case_product', value);
		}
		for(String value : GNE_CM_CustomSettings_Utils.getValues(GNE_CM_case_medhistoryid__c.getall().values(), env))
		{
			result.put('case_medhistoryid', value);
		}
        return result;
    }
    

    // access to custom setting
    public Boolean MTVOff
    {
        get
        {
            return (Boolean) GNE_CM_CustomSettingsHelper.self().getCMConfig().CBO_MTV_Off__c;
        }
    }
    
	public String StandaloneURL
	{
		get
		{
			return GNE_CM_CustomSettingsHelper.self().getCMConfig().EBI_TE_Standalone_URL__c;
		}
	}
    
	public static String updateOpenTaskDueDates(String caseId)
	{
		PageReference pageRef = ApexPages.currentPage();
		//ID caseId = ((Case)controller.getRecord()).ID; 
        Date adot;
        Case c;
        String returnMessage;
        try{
            c = [SELECT Id, Anticipated_Date_of_Treatment_gne__c, Patient_Enrollment_Request_gne__r.Secondary_Insurance_Carrier_Name_gne__c, Patient_Enrollment_Request_gne__r.Primary_Insurance_Carrier_Name_gne__c 
                  FROM Case 
                  WHERE Id = :caseId][0];
            adot = c.Anticipated_Date_of_Treatment_gne__c;
        }catch(Exception e){
            returnMessage = 'Error. Unable to update tasks.';
            GNE_CM_MPS_Utils.createAndLogErrors(new List<Database.SaveResult>(), 'Error in querying for Case with ID: {0}', new List<String>{caseId}, 'Case', 'GNE_CM_Case_Custom_Controller.updateOpenTaskDueDates',null);
            return returnMessage;
        }
		
        
		if (c!=null && adot != null && GNE_CM_Blizzard_Utils.isAdotEligible(adot)) {
			Set<String> subjects = new Set<String>{'Perform ProActive Benefit Investigation','Provide status update to customer','Perform New Enrollment Review'}; //'Perform Benefit Investigation',
			List<Task> tasks = [SELECT Id, WhatId, ActivityDate 
								FROM Task 
								WHERE WhatId = :caseId 
								AND subject in :subjects
                                AND IsClosed = false];
			if (tasks.size() > 0) {
				Date newActivityDate = GNE_CM_Task_Queue_Mgmt_Helper.getADOTOffsetDate(adot);
				for (Task task : tasks) {
					task.ActivityDate = newActivityDate;
                    GNE_CM_Case_Trigger_Util.updateTaskFieldsForBR(task, adot, c.Patient_Enrollment_Request_gne__r);
				}
				GNE_CM_Static_Flags.setFlag(GNE_CM_Static_Flags.TASKS_UPSERT_IN_TRIGGER);
				try {
					Database.SaveResult[] saveResults = Database.update(tasks, false);
                    GNE_CM_MPS_Utils.createAndLogErrors(saveResults, 'Error in updating Task due dates for Task ID: {sr} with ADOT: {0}', new List<String>{String.valueOf(c.Anticipated_Date_of_Treatment_gne__c)}, 'Task','GNE_CM_Case_Custom_Controller.updateOpenTaskDueDates',tasks);
                    
					for (Database.SaveResult sr : saveResults) {
						if (!sr.isSuccess()) {
							//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error. Unable to update tasks.'));
                            returnMessage = 'Error. Unable to update tasks.';
                            //return pageRef;
						}					
					}
                    //If everything succeeded, then set the message to 'success'
					if(String.isBlank(returnMessage)){
                        returnMessage = 'Success';
                    }
				} catch (Exception e) {
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error. Unable to update tasks.'));
                    returnMessage = 'Error. Unable to update tasks.';
                    GNE_CM_MPS_Utils.createAndLogErrors(new List<Database.SaveResult>(), 'Exception in updating Task due dates for Case: {0} with ADOT: {1} and exception message is: {2}', new List<String>{caseId,String.valueOf(c.Anticipated_Date_of_Treatment_gne__c),GlobalUtils.getExceptionDescription(e)}, 'Task','GNE_CM_Case_Custom_Controller.updateOpenTaskDueDates',null);
				} finally {
					GNE_CM_Static_Flags.unsetFlag(GNE_CM_Static_Flags.TASKS_UPSERT_IN_TRIGGER);
				}
			}else{
                returnMessage = 'No tasks to update';
            }
		} else {
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Unable to update. Anticipated Date of Treatment is not in Benefits Reverification period.'));
            returnMessage = 'Unable to update. Anticipated Date of Treatment is not in Benefits Reverification period.';
		}		
		return returnMessage;
	}
}