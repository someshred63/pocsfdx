public with sharing class CFAR_Search_Controller extends CFAR_BaseController{
    public CFAR_SearchWrapper searchWrapper{get;set;}
    public Boolean basicSearch{get; set;}


    public List<String> selectedSearchContacts { get; set; }
    public List<String> selectedSearchCSA { get; set; }
    public List<String> selectedSearchInvestigator { get; set; }
    public List<String> parentOrganizationPrefix { get; set; }
    public List<String> institutionPrefix { get; set; }
    public List<String> selectedSearchMSL { get; set; }
    public List<String> selectedSearchPartnership { get; set; } 
    public List<String> selectedSearchProducts { get; set; }  
	public List<String> selectedSearchTherapeuticArea { get; set; }  
    public List<String> selectedSearchOtherGNEAgents {get; set;}
    public String otherGNEAgentsOrAndLogic {get; set;}

    public List<String> selectedSearchGI {get; set;}
    public List<String> selectedSearchSI {get; set;}
    public String GIOrAndLogic {get; set;} 
    public String SIOrAndLogic {get; set;}   
    public List<String> selectedWBSCode {get; set;}
    public List<String> selectedInterventional {get; set;}
    public List<String> selectedStudyStatus {get; set;}
    public String selectedPediatricStudy { get { return (selectedPediatricStudy == null) ? '' : selectedPediatricStudy; } set; }
    public List<String> selectedGNESupport {get; set;}
    public List<String> selectedSRTTeam {get; set;}
    public List<String> selectedSubjectType {get; set;}
    public String selectedBOMSupport { get { return (selectedBOMSupport == null) ? '' : selectedBOMSupport; } set; }
    public List<String> selectedImpact {get; set;}
    public String ImpactOrAndLogic {get; set;}
    public List<String> selectedSRT {get; set;}

    public PageReference myTrialsRef{get;private set;}  

    public CFAR_Search_Controller(){
        init(); 
    }
    
    private void init(){
        myTrialsRef = Page.CFAR_MyTrials;
        ApexPages.currentPage().getParameters().put('parentPage','BasicSearch');
        basicSearch=true; 
        searchWrapper = new CFAR_SearchWrapper();
		searchWrapper.initWholePrimaryContactSelectOptions();
		searchWrapper.initWholeInvestigatorSelectOptions();
		searchWrapper.initWholeMSLSelectOptions();
        selectedSearchContacts = new List<String>();
        selectedSearchCSA = new List<String>();
        selectedSearchInvestigator = new List<String>();
        parentOrganizationPrefix = new List<String>();
        institutionPrefix = new List<String>();
        selectedSearchMSL = new List<String>();
        selectedWBSCode = new List<String>();
        selectedSearchProducts = new List<String>();   
        selectedSearchTherapeuticArea = new List<String>();
        selectedSearchOtherGNEAgents = new List<String>();
        selectedSearchPartnership = new List<String>();
        otherGNEAgentsOrAndLogic = 'OR'; 
        selectedSearchGI = new List<String>();
        selectedSearchSI = new List<String>();
        GIOrAndLogic = 'OR';
        SIOrAndLogic = 'OR';
        selectedInterventional = new List<String>();
        selectedStudyStatus = new List<String>();
        selectedPediatricStudy =  '';
        selectedGNESupport = new List<String>();
        selectedSRTTeam = new List<String>();
        selectedSubjectType = new List<String>();
        selectedBOMSupport = '';
        selectedImpact = new List<String>();
        ImpactOrAndLogic = 'OR';
        selectedSRT = new List<String>();
    }
    
    public PageReference switchSearchType(){
        basicSearch = !basicSearch; 
        addErrorMessage('####basicSearch:' +basicSearch); 
        return null; 
    }

    public String createQueryParametersString (String[] listString) {
        String queryParametersString = '';
        for(String s : listString) {
            queryParametersString += s + ',';
        } 
        queryParametersString = queryParametersString.removeEnd(',');
        return queryParametersString;  
    }
    
    public PageReference clear(){       
        searchWrapper = new CFAR_SearchWrapper();
        searchWrapper.initWholePrimaryContactSelectOptions();
        searchWrapper.initWholeInvestigatorSelectOptions();
        searchWrapper.initWholeMSLSelectOptions();

        ApexPages.currentPage().getParameters().put('aosParam','');        
        ApexPages.currentPage().getParameters().put('ssParam','');
        ApexPages.currentPage().getParameters().put('trialPrefix','');
        ApexPages.currentPage().getParameters().put('otherTrialPrefix','');
        ApexPages.currentPage().getParameters().put('institutionPrefix',''); 
        ApexPages.currentPage().getParameters().put('parentOrganizationPrefix','');
        ApexPages.currentPage().getParameters().put('institutionPrefix','');         
        ApexPages.currentPage().getParameters().put('selectedSearchContacts','');
        ApexPages.currentPage().getParameters().put('selectedSearchCSA','');
        ApexPages.currentPage().getParameters().put('selectedSearchInvestigator','');
        ApexPages.currentPage().getParameters().put('selectedSearchMSL','');  
        ApexPages.currentPage().getParameters().put('selectedSearchPartnership','');
        ApexPages.currentPage().getParameters().put('selectedSearchProducts','');
        ApexPages.currentPage().getParameters().put('selectedSearchTherapeuticArea','');
        ApexPages.currentPage().getParameters().put('CTMSPrefix','');
        ApexPages.currentPage().getParameters().put('selectedWBSCode','');
		ApexPages.currentPage().getParameters().put('selectedSearchOtherGNEAgents','');
        otherGNEAgentsOrAndLogic = 'OR';
        ApexPages.currentPage().getParameters().put('otherGNEAgentsOrAndLogic','OR');
        
        ApexPages.currentPage().getParameters().put('selectedSearchGI','');
        GIOrAndLogic = 'OR';
        ApexPages.currentPage().getParameters().put('selectedSearchSI','');
        SIOrAndLogic = 'OR';
        ApexPages.currentPage().getParameters().put('selectedInterventional','');
        ApexPages.currentPage().getParameters().put('selectedStudyStatus', '');
        ApexPages.currentPage().getParameters().put('selectedPediatricStudy', '');
        ApexPages.currentPage().getParameters().put('selectedGNESupport', '');
        ApexPages.currentPage().getParameters().put('selectedSRTTeam', '');
        ApexPages.currentPage().getParameters().put('selectedSubjectType', '');
        ApexPages.currentPage().getParameters().put('selectedBOMSupport', '');
        ApexPages.currentPage().getParameters().put('GIOrAndLogic','OR');
        ApexPages.currentPage().getParameters().put('SIOrAndLogic','OR');
        ApexPages.currentPage().getParameters().put('selectedImpact','');
        ApexPages.currentPage().getParameters().put('ImpactOrAndLogic', 'OR');
        ApexPages.currentPage().getParameters().put('selectedSRT', '');

        selectedSearchContacts.clear(); 
        selectedSearchCSA.clear();
        selectedSearchInvestigator.clear(); 
        parentOrganizationPrefix.clear();
        institutionPrefix.clear();
        selectedSearchMSL.clear();  
        selectedSearchProducts.clear();   
        selectedSearchTherapeuticArea.clear();       
        selectedSearchOtherGNEAgents.clear();   
        selectedSearchGI.clear(); 
        selectedSearchSI.clear(); 
        selectedSearchPartnership.clear();
        selectedWBSCode.clear();
        selectedInterventional.clear();
        selectedStudyStatus.clear();
        selectedPediatricStudy = '';
        selectedGNESupport.clear();
        selectedSRTTeam.clear();
        selectedSubjectType.clear();
        selectedBOMSupport = '';
        selectedImpact.clear();
        selectedSRT.clear();

        return null;
    }    
    
    public PageReference search(){
        if(basicSearch) {
            ApexPages.currentPage().getParameters().put('parentPage','BasicSearch');
            ApexPages.currentPage().getParameters().put('aosParam',searchWrapper.getAreaOfSearchToFieldMap().get(searchWrapper.areaOfSearch));        
            ApexPages.currentPage().getParameters().put('ssParam',searchWrapper.searchString);
        } 

        if(!basicSearch) {
            ApexPages.currentPage().getParameters().put('parentPage','AdvancedSearch');

            if(searchWrapper.trialPrefix != null) {
                ApexPages.currentPage().getParameters().put('trialPrefix',searchWrapper.trialPrefix );
            }               

            if(searchWrapper.otherTrialPrefix != null) {
                ApexPages.currentPage().getParameters().put('otherTrialPrefix',searchWrapper.otherTrialPrefix );
            }
            
            if(parentOrganizationPrefix != null) {
                ApexPages.currentPage().getParameters().put('parentOrganizationPrefix',createQueryParametersString(parentOrganizationPrefix));
            }            
            
            if(institutionPrefix != null) {
                ApexPages.currentPage().getParameters().put('institutionPrefix',createQueryParametersString(institutionPrefix));
            }   

            if(selectedSearchContacts != null) {
                System.debug('listParams Contacts: ' + createQueryParametersString(selectedSearchContacts));            
                ApexPages.currentPage().getParameters().put('selectedSearchContacts', createQueryParametersString(selectedSearchContacts));
            }
            
            if(selectedSearchContacts != null) {
                System.debug('listParams Investigator: ' + createQueryParametersString(selectedSearchInvestigator));            
                ApexPages.currentPage().getParameters().put('selectedSearchInvestigator', createQueryParametersString(selectedSearchInvestigator));
            }
            if (selectedSearchContacts != null) {
                ApexPages.currentPage().getParameters().put('selectedSearchCSA', createQueryParametersString(selectedSearchCSA));
            }
            if(selectedSearchContacts != null) {
                System.debug('listParams MSL: ' + createQueryParametersString(selectedSearchMSL));            
                ApexPages.currentPage().getParameters().put('selectedSearchMSL', createQueryParametersString(selectedSearchMSL));
            }                        
           
            if(selectedSearchPartnership != null) {
                System.debug('listParams Partnership: ' + createQueryParametersString(selectedSearchPartnership));
                ApexPages.currentPage().getParameters().put('selectedSearchPartnership', createQueryParametersString(selectedSearchPartnership));
            }   

            if(selectedSearchProducts != null) {
                System.debug('listParams Products: ' + createQueryParametersString(selectedSearchProducts));            
                ApexPages.currentPage().getParameters().put('selectedSearchProducts', createQueryParametersString(selectedSearchProducts));
            }
                       
            if(selectedSearchTherapeuticArea != null) {
                System.debug('listParams TA: ' + createQueryParametersString(selectedSearchTherapeuticArea));
                ApexPages.currentPage().getParameters().put('selectedSearchTherapeuticArea', createQueryParametersString(selectedSearchTherapeuticArea));
            }
            if(searchWrapper.CTMSPrefix != null) {
                ApexPages.currentPage().getParameters().put('CTMSPrefix',searchWrapper.CTMSPrefix);
            } 
            
            if(selectedWBSCode != null) {
            	System.debug('listParams TA: ' + createQueryParametersString(selectedWBSCode));
                ApexPages.currentPage().getParameters().put('selectedWBSCode', createQueryParametersString(selectedWBSCode));
            }
            
            if(selectedSearchOtherGNEAgents != null) {
                System.debug('listParams Other GNE Agents: ' + createQueryParametersString(selectedSearchOtherGNEAgents));            
                ApexPages.currentPage().getParameters().put('selectedSearchOtherGNEAgents', createQueryParametersString(selectedSearchOtherGNEAgents));
            }
            
            ApexPages.currentPage().getParameters().put('otherGNEAgentsOrAndLogic', otherGNEAgentsOrAndLogic);            
            
            if(selectedSearchGI != null) {
                System.debug('listParams GI: ' + createQueryParametersString(selectedSearchGI));            
                ApexPages.currentPage().getParameters().put('selectedSearchGI', createQueryParametersString(selectedSearchGI));
            }
            
            ApexPages.currentPage().getParameters().put('GIOrAndLogic', GIOrAndLogic);     
            
            if(selectedSearchSI != null) {
                System.debug('listParams SI: ' + createQueryParametersString(selectedSearchSI));            
                ApexPages.currentPage().getParameters().put('selectedSearchSI', createQueryParametersString(selectedSearchSI));
            }
            if(selectedInterventional != null) {
                ApexPages.currentPage().getParameters().put('selectedInterventional', createQueryParametersString(selectedInterventional));
            }
            if (selectedStudyStatus != null) {
                ApexPages.currentPage().getParameters().put('selectedStudyStatus', createQueryParametersString(selectedStudyStatus));
            }
            if (selectedGNESupport != null) {
                ApexPages.currentPage().getParameters().put('selectedGNESupport', createQueryParametersString(selectedGNESupport));
            }
            if (selectedSRTTeam != null) {
                ApexPages.currentPage().getParameters().put('selectedSRTTeam', createQueryParametersString(selectedSRTTeam));
            }
            if (selectedSubjectType != null) {
                ApexPages.currentPage().getParameters().put('selectedSubjectType', createQueryParametersString(selectedSubjectType));
            }
            if (selectedImpact != null) {
                ApexPages.currentPage().getParameters().put('selectedImpact', createQueryParametersString(selectedImpact));
            }
            if (selectedSRT != null) {
                ApexPages.currentPage().getParameters().put('selectedSRT', createQueryParametersString(selectedSRT));
            }
            ApexPages.currentPage().getParameters().put('SIOrAndLogic', SIOrAndLogic);
            ApexPages.currentPage().getParameters().put('ImpactOrAndLogic', ImpactOrAndLogic);
            ApexPages.currentPage().getParameters().put('selectedPediatricStudy', selectedPediatricStudy);
            ApexPages.currentPage().getParameters().put('selectedBOMSupport', selectedBOMSupport);
            
        }
                               
        return null;
    }    
    
}