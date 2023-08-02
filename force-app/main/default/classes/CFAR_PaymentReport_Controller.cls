public with sharing class CFAR_PaymentReport_Controller {
    public Id selectedTrialId {get; set;}
    public Id selectedCtmsTrialId {get; set;} 
    public List<String> selectedPISubIs {get; set;} 
    public String errorMessage {get; set;}
    public Boolean isError {get; set;}
    public Boolean includeSummary {get; set;}
    
    @testVisible private List<SelectOption> wholeTrialSearchList;
    private transient List<SelectOption> trialSelectOptions1;
    private transient List<SelectOption> trialSelectOptions2;
    private transient List<SelectOption> trialSelectOptions3;
    private transient List<SelectOption> trialSelectOptions4;

    private List<SelectOption> wholeCTMSSearchList;
    private transient List<SelectOption> ctmsSelectOptions1;
    private transient List<SelectOption> ctmsSelectOptions2;
    private transient List<SelectOption> ctmsSelectOptions3;
    private transient List<SelectOption> ctmsSelectOptions4;    
    
    private static List<SelectOption> ctms;
    
    public CFAR_PaymentReport_Controller() {
        initWholeTrialSelectOptionsList();
        initWholeCTMSSelectOptionsList();
    }
    
    private SelectOption[] getTrialSelectOptions(){
        SelectOption[] selectOptions = new SelectOption[]{};
        selectOptions.add(new SelectOption('','--None--'));
        CFAR_SearchParameters searchParameters = new CFAR_SearchParameters();
        searchParameters.sortExpression ='Name';
        searchParameters.sortDirection = 'asc';
        selectOptions.addAll(CFAR_Utils.getTrialSelectOptions( searchParameters)) ;             
        return selectOptions;          
    }
    
    private void initWholeTrialSelectOptionsList() {
        wholeTrialSearchList = getTrialSelectOptions();
    }
    
    public List<SelectOption> getTrialSelectOptions1() {
        trialSelectOptions1 = CFAR_Utils.getObjectSearchListPart1(wholeTrialSearchList);
        return trialSelectOptions1;
    }
    
    public List<SelectOption> getTrialSelectOptions2() {
        trialSelectOptions2 = CFAR_Utils.getObjectSearchListPart2(wholeTrialSearchList);
        return trialSelectOptions2;
    }
        
    public List<SelectOption> getTrialSelectOptions3() {
        trialSelectOptions3 = CFAR_Utils.getObjectSearchListPart3(wholeTrialSearchList);
        return trialSelectOptions3;
    }
        
    public List<SelectOption> getTrialSelectOptions4() {
        trialSelectOptions4 = CFAR_Utils.getObjectSearchListPart4(wholeTrialSearchList);
        return trialSelectOptions4;
    }    
    
    public List<SelectOption> getInvestigatorsOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Id finalTrialId = fetchFinalTrialId();
        if(String.isNotBlank(finalTrialId)) {
            List<CFAR_Team_Member_gne__c> investigators = [
                SELECT Id, frm_Name_gne__c, frm_Is_Inactive_gne__c,
                (SELECT Id FROM Budget_Contracts__r)
                FROM CFAR_Team_Member_gne__c 
                WHERE CFAR_Trial_ref_gne__c = :finalTrialId 
                    AND frm_Function_Role_gne__c IN (
                        :CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR,
                        :CFAR_TeamMemberHelper.ROLE_SUB_INVESTIGATOR,
                        :CFAR_TeamMemberHelper.ROLE_DRUG_DEPOT_CONTACT,
                        :CFAR_TeamMemberHelper.ROLE_READING_CENTER_CONTACT,
                        :CFAR_TeamMemberHelper.ROLE_SPECIALTY_LAB_CONTACT
                    ) 
                ORDER BY frm_Name_gne__c, frm_Is_Inactive_gne__c
            ];
            if(investigators != null && !investigators.isEmpty())
            options.add(new SelectOption('All Investigators', 'All Investigators'));        
            for (CFAR_Team_Member_gne__c member : investigators) {
                options.add(new SelectOption(member.Id, member.frm_Name_gne__c));
            }
        }
        return options;
    }
    
    public List<SelectOption> getCtmsOptions() {
        if(ctms == null){
            ctms = new List<SelectOption>();
            ctms.add(new SelectOption('','--None--'));
            Set<String> tempSet = new Set<String>();
            for (CFAR_Rate_Table_gne__c member : [
                SELECT Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.CTMS_gne__c    
                FROM CFAR_Rate_Table_gne__c   
                WHERE Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.CTMS_gne__c != null  
            ]) { 
                String key = member.Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c;
                String value = member.Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.CTMS_gne__c;
                if(tempSet.contains(value)){
                    continue;
                }
                tempSet.add(value);
                ctms.add(new SelectOption(key, value));
            }
        }   
        return ctms;
    }

    
    private void initWholeCTMSSelectOptionsList() {
        wholeCTMSSearchList = getCtmsOptions();
    }
    
    public List<SelectOption> getCTMSSelectOptions1() {
        ctmsSelectOptions1 = CFAR_Utils.getObjectSearchListPart1(wholeCTMSSearchList);
        return ctmsSelectOptions1;
    }
    
    public List<SelectOption> getCTMSSelectOptions2() {
        ctmsSelectOptions2 = CFAR_Utils.getObjectSearchListPart2(wholeCTMSSearchList);
        return ctmsSelectOptions2;
    }
        
    public List<SelectOption> getCTMSSelectOptions3() {
        ctmsSelectOptions3 = CFAR_Utils.getObjectSearchListPart3(wholeCTMSSearchList);
        return ctmsSelectOptions3;
    }
        
    public List<SelectOption> getCTMSSelectOptions4() {
        ctmsSelectOptions4 = CFAR_Utils.getObjectSearchListPart4(wholeCTMSSearchList);
        return ctmsSelectOptions4;
    }
    
    private Id fetchFinalTrialId(){
        Id finalId = selectedTrialId == null ? (selectedCtmsTrialId == null ? null : selectedCtmsTrialId) : selectedTrialId;
        return finalId;
    }
    
    public PageReference generateReport() {
        Id finalTrialId = fetchFinalTrialId();
        if(String.isBlank(finalTrialId)) {
            isError = true;
            errorMessage = 'You must choose one Trial or CTMS Number.';
            return null;
        }
        if(selectedPISubIs == null || selectedPISubIs.isEmpty()) {
            isError = true;
            errorMessage = 'At least one PI/Sub-I must be selected.';
            return null;            
        }
        PageReference redirect = new PageReference('/apex/CFAR_BudgetReport'); 
        String piIds = '';
        Boolean allInvSelected = false;
        for(String selectedPiSubI : selectedPISubIs) {
            if('All Investigators'.equals(selectedPiSubI)) {
                allInvSelected = true;
                break;
            }
        }
        if(allInvSelected) {
            List<SelectOption> invSelectOptions = getInvestigatorsOptions();
            for(SelectOption inv : invSelectOptions) {
                if(!'All Investigators'.equals(inv.getValue()))
                    piIds += inv.getValue()+';';
            }
        } else {
            for(String selectedPiSubI : selectedPISubIs) {
                piIds += selectedPiSubI+';';
            }
        }
        
        if(piIds.endsWith(';'))
            piIds = piIds.substring(0, piIds.length() - 1);    
        redirect.getParameters().put('piIds',piIds); 
        redirect.getParameters().put('tId', finalTrialId); 
        redirect.getParameters().put('includeSummary', String.valueOf(includeSummary));
         redirect.setRedirect(true);
         return redirect; 
    }
    
    public PageReference clearFilters() {
        selectedTrialId = null;
        selectedCtmsTrialId = null;
        return null;
    }
    
    public PageReference cancelGenerateReport() {
        PageReference redirect = new PageReference('/apex/CFAR_TrialReportNav');
        return redirect;
    }
}