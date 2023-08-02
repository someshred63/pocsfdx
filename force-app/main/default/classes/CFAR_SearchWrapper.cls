public class CFAR_SearchWrapper extends CFAR_TrialWrapper{
    
    public String areaOfSearch{get;set;}
    public String searchString{get;set;}
    
      
    public CFAR_SearchWrapper(){
        innerObject = new CFAR_Trial_gne__c(); 
    }
    
    public Map<String,String> getAreaOfSearchToFieldMap(){
        Map<String,String> AreaOfSearchToFieldMap = new Map<String,String>();
        AreaOfSearchToFieldMap.put('Trial','Name');
        AreaOfSearchToFieldMap.put('CTMS','CTMS_gne__c');
        AreaOfSearchToFieldMap.put('Partnership','Partnership_multi_gne__c');
        AreaOfSearchToFieldMap.put('Investigator','frm_Investigator_ref_gne__c');
        AreaOfSearchToFieldMap.put('Primary Contact','frm_Genentech_Primary_Contact_ref_gne__c');
        AreaOfSearchToFieldMap.put('MSL','frm_MSL_ref_gne__c');
        AreaOfSearchToFieldMap.put('Product','Product_ref_gne__r.Name');       
        return AreaOfSearchToFieldMap;
    }

   
    public String trialPrefix{get;set;}
    public String otherTrialPrefix{get;set;}   
    public String briefTitlePrefix{get;set;}
    public String trialStatus{get;set;}
    public String Investigator{get;set;}
    public String CTMSPrefix{get;set;}
    public String WBSPrefix{get;set;}

    public override SelectOption[] getPrimaryContactSelectOptions(){
    	//system.debug('XXX search getPrimaryContactSelectOptions');
        SelectOption[] selectOptions = new SelectOption[]{};
//        selectOptions.add(new SelectOption('','--None--'));
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        //searchParms.andEqualsParameters.put('Primary_Role_Function_gne__c','PI = Primary (or Principal) Investigator');
        searchParms.orEqualsParameters.put('Primary_Role_Function_gne__c', CFAR_Utils.getAvailableRolesForPrimaryContact());
        searchParms.sortExpression = 'Search_Name__c'; 
        searchParms.sortDirection = 'asc';
        selectOptions.addAll(CFAR_Utils.getContactSelectOptions(searchParms)) ;             
        return selectOptions;           
    }
    
    public override SelectOption[] getInvestigatorSelectOptions(){
    	//system.debug('XXX search getInvestigatorSelectOptions');
        SelectOption[] selectOptions = new SelectOption[]{};
//        selectOptions.add(new SelectOption('','--None--'));
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        //searchParms.orEqualsParameters.put('Primary_Role_Function_gne__c',new List<String>{'PI = Primary (or Principal) Investigator','Sub-I = sub-investigator'});
        searchParms.orEqualsParameters.put('Primary_Role_Function_gne__c', CFAR_Utils.getAvailableRolesForInvestigator());
        searchParms.sortExpression = 'Search_Name__c'; 
        searchParms.sortDirection = 'asc';
        selectOptions.addAll(CFAR_Utils.getContactSelectOptions(searchParms)) ;             
        return selectOptions;           
    }
    
    public override SelectOption[] getMSLSelectOptions(){
    	//system.debug('XXX search getMSLSelectOptions');
        SelectOption[] selectOptions = new SelectOption[]{};
//        selectOptions.add(new SelectOption('','--None--'));
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        //searchParms.andEqualsParameters.put('Primary_Role_Function_gne__c','MSL = Medical Science Liaison');
        searchParms.orEqualsParameters.put('Primary_Role_Function_gne__c', CFAR_Utils.getAvailableRolesForMSL());
        searchParms.sortExpression = 'Search_Name__c'; 
        searchParms.sortDirection = 'asc';
        selectOptions.addAll(CFAR_Utils.getContactSelectOptions(searchParms)) ;             
        return selectOptions;           
    }  
    
    public SelectOption[] getPartnershipSelectOptions(){
        SelectOption[] selectOptions = new SelectOption[]{};
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name';
        searchParms.sortDirection = 'asc';
        selectOptions.addAll(CFAR_Utils.getPartnershipSelectOptions(searchParms));
        return selectOptions;
    }

    public override SelectOption[] getProductSelectOptions(){
        SelectOption[] selectOptions = new SelectOption[]{};
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Generic_Name_gne__c'; 
        searchParms.sortDirection = 'asc';            
        selectOptions.addAll(CFAR_Utils.getStudiedProductSelectOptions(searchParms)) ;             
        return selectOptions;             
    } 

    public SelectOption[] getInstitutions() {
        SelectOption[] selectOptions = new SelectOption[] {};
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name';
        searchParms.sortDirection = 'asc';
        selectOptions.addAll(CFAR_Utils.getInstitutions(searchParms)) ;
        return selectOptions;
    }

    public SelectOption[] getParentOrganizations(){
        SelectOption[] selectOptions = new SelectOption[]{};
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name'; 
        searchParms.sortDirection = 'asc';        
        selectOptions.addAll(CFAR_Utils.getParentOrganizations(searchParms)) ;             
        return selectOptions;             
    }
    
    public SelectOption[] getWBSCodes(){
    	SelectOption[] selectOptions = new SelectOption[]{};
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name'; 
        searchParms.sortDirection = 'asc';        
        selectOptions.addAll(CFAR_Utils.getWBSCodeSelectoptions(searchParms)) ;             
        return selectOptions;       
    }

    public SelectOption[] getInterventional() {
        SelectOption[] selectOptions = new SelectOption[]{};
        for (Schema.PicklistEntry pickVal : CFAR_Trial_gne__c.Non_Interventional_gne__c.getDescribe().getPicklistValues()) {
            selectOptions.add(new SelectOption(pickVal.getValue(), pickVal.getLabel()));
        }
        return selectOptions;
    }

    public List<SelectOption> getSubjectType() {
        return CFAR_Utils.getSelectOptionsFromPicklistValues(CFAR_Trial_gne__c.Subject_Type__c.getDescribe().getPicklistValues(), false);
    }

    public SelectOption[] getStudyStatuses(){
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name';
        searchParms.sortDirection = 'asc';
        return CFAR_Utils.getStudyStatusSelectoptions(searchParms);
    }

    public SelectOption[] getPediatricStudy() {
        return CFAR_Utils.getSelectOptionsFromPicklistValues(CFAR_Trial_gne__c.Pediatric_Study_gne__c.getDescribe().getPicklistValues(), true);
    }

    public List<SelectOption> getBOMSupport() {
        return CFAR_Utils.getSelectOptionsFromPicklistValues(CFAR_Trial_gne__c.Lab_Support_gne__c.getDescribe().getPicklistValues(), true);
    }

    public SelectOption[] getGNESupport() {
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name';
        searchParms.sortDirection = 'asc';
        return CFAR_Utils.getGNESupportSelectOptions(searchParms);
    }

    public SelectOption[] getGeneralIndicationSelectOptions(){
        SelectOption[] selectOptions = new SelectOption[]{};
//        selectOptions.add(new SelectOption('','--None--'));
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name'; 
        searchParms.sortDirection = 'asc';
        selectOptions.addAll(CFAR_Utils.getGeneralIndicationSelectOptions(searchParms)) ;             
        return selectOptions;          
    }

    public /*override*/ SelectOption[] getSpecificIndicationSelectOptions(){
        SelectOption[] selectOptions = new SelectOption[]{};
//        selectOptions.add(new SelectOption('','--None--'));
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name'; 
        searchParms.sortDirection = 'asc';
        selectOptions.addAll(CFAR_Utils.getSpecificIndicationSelectOptions(searchParms)) ;             
        return selectOptions;          
    }
    
    
    public override SelectOption[] getTherapeuticAreasSelectOptions() {
        SelectOption[] selectOptions = new SelectOption[]{};
        selectOptions.add(new SelectOption('','--None--'));
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        selectOptions.addAll(CFAR_Utils.getTherapeuticAreasSelectOptions(searchParms)) ;             
        return selectOptions;           
    }

    public List<SelectOption> getImpactSelectOptionsSearch() {
        return CFAR_Utils.getSelectOptionsFromSobj(CFAR_DAO.getImpacts(), 'Name', 'Name');
    }

    public List<SelectOption> getSRTSelectOptions() {
        return CFAR_Utils.getSelectOptionsFromSobj([SELECT Id, Search_Name__c FROM CFAR_Contact_gne__c WHERE Role_Function_gne__c = 'SRT = Study Review Team Chair' OR Primary_Role_Function_gne__c = 'SRT = Study Review Team Chair' OR Tertiary_Role_Function_gne__c = 'SRT = Study Review Team Chair'], 'Id', 'Search_Name__c');
    }

    public List<SelectOption> getSRTTeam() {
        System.debug(Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName());
        return CFAR_Utils.getCFARPicklistSelectOptions(Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('SRT Team').getRecordTypeId());
    }
  
}