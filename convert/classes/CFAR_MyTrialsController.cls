public virtual with sharing class CFAR_MyTrialsController extends CFAR_BaseController {
    
    private SFA2_Configuration_Object_gne__c pageConfiguration;
    private String andStartsWithParametersTrial;
    private Map<String, String> paramsForXLSMap;
    
    final Integer pageSize = 10;
    transient List<CFAR_SObjectWrapper> objectListTrial;
    
    public ApexPages.StandardSetController stdSetControllerTrial;
    public PageReference myTrialsRef {get;private set;}
    public Map<Id, CFAR_SObjectWrapper> objectMapTrial {get; set;}
    public CFAR_Trial_gne__c trialSummary {get; private set;}
    public Boolean showSummary {get;set;}
    public Boolean showAlerts {get; private set;}
    public CFAR_SearchParameters searchParam {get; set;}
    public CFAR_SearchParameters oldSearchParam {get; set;}
    public String title {get; set;}
    public String parentPage {get; set;}
    public String message { get; set; }


    public void setListMessage() {
        if (parentPage == 'CFAR_Home') {
            message = objectListTrial.isEmpty() ? 'No trials to display' : '';
        } else if (parentPage == 'BasicSearch' || parentPage == 'AdvancedSearch') {
            message = (searchParam != null && searchParam.isEmpty()) ? 'Please apply filters to see results' : (objectListTrial != null && objectListTrial.isEmpty()) ? 'Search returned no rows' : '';
        } else {
            message = '';
        }
    }

    public List<CFAR_SObjectWrapper> getobjectListTrial() {
        init();
        fillTrials();
        setListMessage();
        return objectListTrial;
    }
    
    public CFAR_MyTrialsController() {
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('CFAR_myTrials');
        myTrialsRef = Page.CFAR_MyTrials;
        myTrialsRef.getParameters().putAll(ApexPages.currentPage().getParameters());
        searchParam = new CFAR_SearchParameters();
        oldSearchParam = new CFAR_SearchParameters();
        showSummary = false;
        showAlerts = CFAR_Utils.isCurrentUserAdmin();
        paramsForXLSMap = new Map<String, String>();
    }
    
    public void refreshParams() {
        myTrialsRef.getParameters().putAll(ApexPages.currentPage().getParameters());
        parentPage = '';
        String areaOfSearchParam = '';
        String searchStringParam = '';
        String trialPrefix = '';
        String otherTrialPrefix = '';
        String institutionPrefix = '';
        String parentOrganizationPrefix = '';
        String selectedSearchContacts = '';
        String selectedSearchInvestigator = '';
        String selectedSearchCSA = '';
        String selectedSearchMSL = '';
        String selectedSearchPartnership = '';
        String selectedSearchProducts = '';
        String selectedSearchTherapeuticArea = '';
        String CTMSPrefix = '';
        String selectedWBSCode = '';
        String selectedSearchOtherGNEAgents = '';
        String otherGNEAgentsOrAndLogic = 'OR';
        String selectedSearchGI = '';
        String GIOrAndLogic = 'OR';
        String selectedSearchSI = '';
        String SIOrAndLogic = 'OR';
        String selectedInterventional = '';
        String selectedStudyStatus = '';
        String selectedPediatricStudy = '';
        String selectedGNESupport = '';
        String selectedSRTTeam = '';
        String selectedSubjectType = '';
        String selectedBOMSupport = '';
        String selectedImpact = '';
        String ImpactOrAndLogic = 'OR';
        String selectedSRT = '';
        searchParam = new CFAR_SearchParameters();
        paramsForXLSMap.clear();
        // walkthrough all URL parameters
        for (String p : myTrialsRef.getParameters().keySet()) {
            if (p == 'parentPage') {
                parentPage = myTrialsRef.getParameters().get(p);
                addToXlsMap('parentPage', parentPage);
            }
            if (p == 'aosParam') {
                areaOfSearchParam = myTrialsRef.getParameters().get(p);
                addToXlsMap('aosParam', areaOfSearchParam);
            }
            if (p == 'ssParam') {
                searchStringParam = myTrialsRef.getParameters().get(p);
                addToXlsMap('ssParam', searchStringParam);
            }
            if (p == 'trialPrefix') {
                trialPrefix = myTrialsRef.getParameters().get(p);
                addToXlsMap('trialPrefix', trialPrefix);
            }
            if (p == 'otherTrialPrefix') {
                otherTrialPrefix = myTrialsRef.getParameters().get(p);
                addToXlsMap('otherTrialPrefix', otherTrialPrefix);
            }
            if (p == 'institutionPrefix') {
                institutionPrefix = myTrialsRef.getParameters().get(p);
                addToXlsMap('institutionPrefix', institutionPrefix);
            }
            if (p == 'parentOrganizationPrefix') {
                parentOrganizationPrefix = myTrialsRef.getParameters().get(p);
                addToXlsMap('parentOrganizationPrefix', parentOrganizationPrefix);
            }
            if (p == 'selectedSearchContacts') {
                selectedSearchContacts = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchContacts', selectedSearchContacts);
            }
            if (p == 'selectedSearchInvestigator') {
                selectedSearchInvestigator = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchInvestigator', selectedSearchInvestigator);
            }
            if (p == 'selectedSearchCSA') {
                selectedSearchCSA = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchCSA', selectedSearchCSA);
            }
            if (p == 'selectedSearchMSL') {
                selectedSearchMSL = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchMSL', selectedSearchMSL);
            }
            if (p == 'selectedSearchPartnership') {
                selectedSearchPartnership = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchPartnership', selectedSearchPartnership);
            }
            if (p == 'selectedSearchProducts') {
                selectedSearchProducts = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchProducts', selectedSearchProducts);
            }
            if (p == 'selectedSearchTherapeuticArea') {
                selectedSearchTherapeuticArea = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchTherapeuticArea', selectedSearchTherapeuticArea);
            }
            if (p == 'CTMSPrefix') {
                CTMSPrefix = myTrialsRef.getParameters().get(p);
                addToXlsMap('CTMSPrefix', CTMSPrefix);
            }
            if (p == 'selectedWBSCode') {
                selectedWBSCode = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedWBSCode', selectedWBSCode);
            }
            if (p == 'selectedSearchOtherGNEAgents') {
                selectedSearchOtherGNEAgents = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchOtherGNEAgents', selectedSearchOtherGNEAgents);
            }
            if (p == 'otherGNEAgentsOrAndLogic') {
                otherGNEAgentsOrAndLogic = myTrialsRef.getParameters().get(p);
                addToXlsMap('otherGNEAgentsOrAndLogic', otherGNEAgentsOrAndLogic);
            }
            if (p == 'selectedSearchGI') {
                selectedSearchGI = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchGI', selectedSearchGI);
            }
            if (p == 'selectedSearchSI') {
                selectedSearchSI = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSearchSI', selectedSearchSI);
            }
            if (p == 'GIOrAndLogic') {
                GIOrAndLogic = myTrialsRef.getParameters().get(p);
                addToXlsMap('GIOrAndLogic', GIOrAndLogic);
            }
            if (p == 'SIOrAndLogic') {
                SIOrAndLogic = myTrialsRef.getParameters().get(p);
                addToXlsMap('SIOrAndLogic', SIOrAndLogic);
            }
            if(p == 'selectedInterventional') {
                selectedInterventional = myTrialsRef.getParameters().get(p);
                addtoXlsMap('selectedInterventional', selectedInterventional);
            }
            if (p == 'selectedStudyStatus') {
                selectedStudyStatus = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedStudyStatus', selectedStudyStatus);
            }
            if (p == 'selectedPediatricStudy') {
                selectedPediatricStudy = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedPediatricStudy', selectedPediatricStudy);
            }
            if (p == 'selectedGNESupport') {
                selectedGNESupport = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedGNESupport', selectedGNESupport);
            }
            if (p == 'selectedSRTTeam') {
                selectedSRTTeam = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSRTTeam', selectedSRTTeam);
            }
            if (p == 'selectedSubjectType') {
                selectedSubjectType = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSubjectType', selectedSubjectType);
            }
            if (p == 'selectedBOMSupport') {
                selectedBOMSupport = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedBOMSupport', selectedBOMSupport);
            }
            if (p == 'selectedImpact') {
                selectedImpact = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedImpact', selectedImpact);
            }
            if (p == 'ImpactOrAndLogic') {
                ImpactOrAndLogic =  myTrialsRef.getParameters().get(p);
                addToXlsMap('ImpactOrAndLogic', ImpactOrAndLogic);
            }
            if (p == 'selectedSRT') {
                selectedSRT = myTrialsRef.getParameters().get(p);
                addToXlsMap('selectedSRT', selectedSRT);
            }
        }
        // in case of Home tab
        if (parentPage == 'CFAR_Home') {
            title='My Trials';
            Set<String> trialsWhereCurrentUserShouldSeeAlerts = new Set<String>();
            List<CFAR_Team_Member_gne__c> currentUserIsMemberAndShouldSeeAlerts = [select CFAR_Trial_ref_gne__c from CFAR_Team_Member_gne__c where Alerts_gne__c = true and Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.User_ref_gne__c = :Id.valueOf(UserInfo.getUserId()) and CFAR_Trial_ref_gne__r.frm_Trial_Status_ref_gne__c not IN : CFAR_Utils.terminalStatusesWithoutAdminFix];
            for (CFAR_Team_Member_gne__c tm : currentUserIsMemberAndShouldSeeAlerts) {
                trialsWhereCurrentUserShouldSeeAlerts.add(tm.CFAR_Trial_ref_gne__c);
            }
            searchParam.andInParameters.put('Id', new List<String>(trialsWhereCurrentUserShouldSeeAlerts));
        }
        // in case of Basic Search
        if (parentPage == 'BasicSearch') {
            title = 'Search Result';
            if (String.isNotBlank(areaOfSearchParam) && String.isNotBlank(searchStringParam)) {
                if (areaOfSearchParam == 'Partnership_multi_gne__c') {
                    final CFAR_Partnership_gne__c[] partnerships = [
                        SELECT Id FROM CFAR_Partnership_gne__c WHERE Name = :searchStringParam LIMIT 1
                    ];
                    searchStringParam = partnerships.isEmpty() ?
                        sObjectType.CFAR_Partnership_gne__c.keyPrefix + '000000000000' : partnerships[0].Id;
                }
                searchParam.andLikeParameters.put(areaOfSearchParam, searchStringParam);
            }
        }
        // in case of Advanced Search
        if (parentPage == 'AdvancedSearch') {
            title='Search Result';
            if (trialPrefix != '') {
                searchParam.andStartsWithParameters.put('Name', trialPrefix);
            }
            if (otherTrialPrefix != '') {
                searchParam.andStartsWithParameters.put('Other_Trial_gne_Id__c', otherTrialPrefix);
            }
            if (parentOrganizationPrefix != '') {
                List<String> trialIds = new List<String>();
                CFAR_Team_Member_gne__c[] teamMembers = [SELECT CFAR_Trial_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__r.Name IN :parentOrganizationPrefix.split(',', -1) AND frm_Is_Inactive_gne__c = false AND (Is_Trial_Primary_Contact_gne__c = true OR Is_Trial_MSL_gne__c = true  OR frm_Function_Role_gne__c = 'PI = Primary (or Principal) Investigator')];
                for (CFAR_Team_Member_gne__c member : teamMembers)
                    trialIds.add(member.CFAR_Trial_ref_gne__c);
                searchParam.andInParameters.put('Id', trialIds);
            }
            if (institutionPrefix != '') {
                List<String> trialIds = new List<String>();
                CFAR_Team_Member_gne__c[]teamMembers = [SELECT CFAR_Trial_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name IN :institutionPrefix.split(',', -1) AND frm_Is_Inactive_gne__c = false AND (Is_Trial_Primary_Contact_gne__c = true OR Is_Trial_MSL_gne__c = true  OR frm_Function_Role_gne__c = 'PI = Primary (or Principal) Investigator')];
                for (CFAR_Team_Member_gne__c member : teamMembers) {
                    trialIds.add(member.CFAR_Trial_ref_gne__c);
                }
                searchParam.andInParameters.put('Id', trialIds);
            }
            if (selectedSearchContacts != '') {
                if (searchParam.andInParameters.containsKey('Id')) {
                    Set<String> selected = new Set<String>(searchParam.andInParameters.get('Id'));
                    selected.retainAll(CFAR_DAO.getTrialIdsForContactsInRole('CSM = Clinical Study Manager', selectedSearchContacts));
                    searchParam.andInParameters.put('Id', new List<String>(selected));
                } else {
                    searchParam.andInParameters.put('Id', CFAR_DAO.getTrialIdsForContactsInRole('CSM = Clinical Study Manager', selectedSearchContacts));
                }
            }
            if (selectedSearchInvestigator != '') {
                searchParam.andInParameters.put('Investigator_ref_gne__c', selectedSearchInvestigator.split(',', -1));
            }
            if (selectedSearchCSA != '') {
                if (searchParam.andInParameters.containsKey('Id')) {
                    Set<String> selected = new Set<String>(searchParam.andInParameters.get('Id'));
                    selected.retainAll(CFAR_DAO.getTrialIdsForContactsInRole('CSA = Clinical Study Associate', selectedSearchCSA));
                    searchParam.andInParameters.put('Id', new List<String>(selected));
                } else {
                    searchParam.andInParameters.put('Id', CFAR_DAO.getTrialIdsForContactsInRole('CSA = Clinical Study Associate', selectedSearchCSA));
                }
            }
            if (selectedSRT != '') {
                if (searchParam.andInParameters.containsKey('Id')) {
                    Set<String> selected = new Set<String>(searchParam.andInParameters.get('Id'));
                    selected.retainAll(CFAR_DAO.getTrialIdsForContactsInRole('SRT = Study Review Team Chair', selectedSRT));
                    searchParam.andInParameters.put('Id', new List<String>(selected));
                } else {
                    searchParam.andInParameters.put('Id', CFAR_DAO.getTrialIdsForContactsInRole('SRT = Study Review Team Chair', selectedSRT));
                }
            }
            if (selectedSearchMSL != '') {
                if (searchParam.andInParameters.containsKey('Id')) {
                    Set<String> selected = new Set<String>(searchParam.andInParameters.get('Id'));
                    selected.retainAll(CFAR_DAO.getTrialIdsForContactsInRole('MSL = Medical Science Liaison', selectedSearchMSL));
                    searchParam.andInParameters.put('Id', new List<String>(selected));
                } else {
                    searchParam.andInParameters.put('Id', CFAR_DAO.getTrialIdsForContactsInRole('MSL = Medical Science Liaison', selectedSearchMSL));
                }
            }
            if (selectedSearchPartnership != '') {
                searchParam.orInMultipicklistParameters.put('Partnership_multi_gne__c', selectedSearchPartnership.split(',', -1));
            }
            if (selectedSearchProducts != '') {
                searchParam.andInParameters.put('Product_ref_gne__c', selectedSearchProducts.split(',', -1));
            }
            if (selectedSearchTherapeuticArea != '') {
                searchParam.andInParameters.put('Therapeutic_Area_ref_gne__c', selectedSearchTherapeuticArea.split(',', -1));
            }
            if (CTMSPrefix != '') {
                searchParam.andStartsWithParameters.put('CTMS_gne__c', CTMSPrefix);
            }
            if (selectedWBSCode != '') {
                Map<String, List<String>> WBSesMap = new Map<String, List<String>>();
                searchParam.andInParameters.put('CFAR_WBS_ref_gne__c', selectedWBSCode.split(',', -1));
            }
            if (!String.isBlank(otherGNEAgentsOrAndLogic) && !String.isBlank(selectedSearchOtherGNEAgents)) {
                List<String> otherGNEAgentsIds = selectedSearchOtherGNEAgents.split(',', -1);
                List<CFAR_Trial_Other_GNE_Agent_gne__c> otherAgents = [Select CFAR_Trial_ref_gne__c, Other_GNE_Agent_ref_gne__c from CFAR_Trial_Other_GNE_Agent_gne__c where Other_GNE_Agent_ref_gne__c in :otherGNEAgentsIds];
                Set<String> trialIdsForOtherAgents = new Set<String>();
                if ('AND'.equals(otherGNEAgentsOrAndLogic)) {
                    Map<String, Set<String>> trialsMapForOther = new Map<String, Set<String>>();
                    for (CFAR_Trial_Other_GNE_Agent_gne__c oa : otherAgents) {
                        if (!trialsMapForOther.containsKey(oa.CFAR_Trial_ref_gne__c))
                            trialsMapForOther.put(oa.CFAR_Trial_ref_gne__c, new Set<String>());
                        trialsMapForOther.get(oa.CFAR_Trial_ref_gne__c).add(oa.Other_GNE_Agent_ref_gne__c);
                    }
                    for (String trialId : trialsMapForOther.keySet()) {
                        if (trialsMapForOther.get(trialId).size() == otherGNEAgentsIds.size())
                            trialIdsForOtherAgents.add(trialId);
                    }
                } else if ( 'OR'.equals(otherGNEAgentsOrAndLogic)) {
                    for (CFAR_Trial_Other_GNE_Agent_gne__c oa : otherAgents) {
                        trialIdsForOtherAgents.add(oa.CFAR_Trial_ref_gne__c);
                    }
                }
                searchParam.andInParameters.put('Id', new List<String>(trialIdsForOtherAgents));
            }
            if (!String.isBlank(GIOrAndLogic) && !String.isBlank(selectedSearchGI)) {
                List<String> giIds = selectedSearchGI.split(',', -1);
                List<CFAR_General_Indication_for_Trial_gne__c> gis = [Select CFAR_Trial_ref_gne__c, CFAR_General_Indication_ref_gne__c from CFAR_General_Indication_for_Trial_gne__c where CFAR_General_Indication_ref_gne__c in :giIds];
                Set<String> trialIdsForGI = new Set<String>();
                if ('AND'.equals(GIOrAndLogic)) {
                    Map<String, Set<String>> trialsMapForGI = new Map<String, Set<String>>();
                    for (CFAR_General_Indication_for_Trial_gne__c gi : gis) {
                        if (!trialsMapForGI.containsKey(gi.CFAR_Trial_ref_gne__c))
                            trialsMapForGI.put(gi.CFAR_Trial_ref_gne__c, new Set<String>());
                        trialsMapForGI.get(gi.CFAR_Trial_ref_gne__c).add(gi.CFAR_General_Indication_ref_gne__c);
                    }
                    for (String trialId : trialsMapForGI.keySet()) {
                        if (trialsMapForGI.get(trialId).size() == giIds.size())
                            trialIdsForGI.add(trialId);
                    }
                } else if ( 'OR'.equals(GIOrAndLogic)) {
                    for (CFAR_General_Indication_for_Trial_gne__c gi : gis) {
                        trialIdsForGI.add(gi.CFAR_Trial_ref_gne__c);
                    }
                }
                if (searchParam.andInParameters.containsKey('Id')) {
                    List<String> ids = new List<String>();
                    for (String id : searchParam.andInParameters.get('Id')) {
                        if ('OR'.equals(otherGNEAgentsOrAndLogic)) {
                            trialIdsForGI.add(id);
                        }
                        if ('AND'.equals(otherGNEAgentsOrAndLogic)) {
                            if (trialIdsForGI.contains(id)) {
                                trialIdsForGI.add(id);
                            }
                        }
                    }
                    searchParam.andInParameters.put('Id', new List<String>(trialIdsForGI));
                }
                else {
                    searchParam.andInParameters.put('Id', new List<String>(trialIdsForGI));
                }
            }
            if (!String.isBlank(SIOrAndLogic) && !String.isBlank(selectedSearchSI)) {
                List<String> siIds = selectedSearchSI.split(',', -1);
                List<CFAR_Specific_Indication_for_Trial_gne__c> sis = [Select CFAR_Trial_ref_gne__c, CFAR_Specific_Indication_ref_gne__c from CFAR_Specific_Indication_for_Trial_gne__c where CFAR_Specific_Indication_ref_gne__c in :siIds];
                Set<String> trialIdsForSI = new Set<String>();
                if ('AND'.equals(SIOrAndLogic)) {
                    Map<String, Set<String>> trialsMapForSI = new Map<String, Set<String>>();
                    for (CFAR_Specific_Indication_for_Trial_gne__c si : sis) {
                        if (!trialsMapForSI.containsKey(si.CFAR_Trial_ref_gne__c))
                            trialsMapForSI.put(si.CFAR_Trial_ref_gne__c, new Set<String>());
                        trialsMapForSI.get(si.CFAR_Trial_ref_gne__c).add(si.CFAR_Specific_Indication_ref_gne__c);
                    }
                    for (String trialId : trialsMapForSI.keySet()) {
                        if (trialsMapForSI.get(trialId).size() == siIds.size())
                            trialIdsForSI.add(trialId);
                    }
                } else if ( 'OR'.equals(SIOrAndLogic)) {
                    for (CFAR_Specific_Indication_for_Trial_gne__c si : sis) {
                        trialIdsForSI.add(si.CFAR_Trial_ref_gne__c);
                    }
                }
                if (searchParam.andInParameters.containsKey('Id')) {
                    List<String> ids = new List<String>();
                    for (String id : searchParam.andInParameters.get('Id')) {
                        if ('OR'.equals(GIOrAndLogic)) {
                            trialIdsForSI.add(id);
                        }
                        if ('AND'.equals(GIOrAndLogic)) {
                            if (trialIdsForSI.contains(id)) {
                                trialIdsForSI.add(id);
                            }
                        }
                    }
                    searchParam.andInParameters.put('Id', new List<String>(trialIdsForSI));
                }
                else{
                    searchParam.andInParameters.put('Id', new List<String>(trialIdsForSI));
                }
            }
            if (String.isNotBlank(selectedInterventional)) {
                searchParam.andInParameters.put('Non_Interventional_gne__c', selectedInterventional.split(',', -1));
            }
            if (String.isNotBlank(selectedStudyStatus)) {
                searchParam.andInParameters.put('Trial_Status_ref_gne__c', selectedStudyStatus.split(',', -1));
            }
            if (String.isNotBlank(selectedPediatricStudy)) {
                searchParam.andEqualsParameters.put('Pediatric_Study_gne__c', selectedPediatricStudy);
            }
            if (String.isNotBlank(selectedGNESupport)) {
                searchParam.andInParameters.put('Dollar_and_Drug_ref_gne__c', selectedGNESupport.split(',', -1));
            }
            if (String.isNotBlank(selectedSRTTeam)) {
                searchParam.andInParameters.put('SRT_Team_ref_gne__c', selectedSRTTeam.split(',', -1));
            }
            if (String.isNotBlank(selectedSubjectType)) {
                searchParam.andInParameters.put('Subject_Type__c', selectedSubjectType.split(',', -1));
            }
            System.debug('slowo dnia' + selectedBOMSupport);
            if (String.isNotBlank(selectedBOMSupport)) {
                searchParam.andEqualsParameters.put('Lab_Support_gne__c', selectedBOMSupport);
            }

            if (!String.isBlank(ImpactOrAndLogic) && !String.isBlank(selectedImpact)) {
                if (ImpactOrAndLogic == 'OR') {
                    searchParam.includesAny.put('Impacts_gne__c', selectedImpact.split(',', -1));
                } else if (ImpactOrAndLogic == 'AND') {
                    searchParam.includesAll.put('Impacts_gne__c', selectedImpact.split(',', -1));
                }
            }
        }
    }
    
    public virtual void addToXlsMap(String key, String value) {
        paramsForXLSMap.put(key, value);
    }
    
    private void init() {
        refreshParams();
        if ( (searchParam.andStartsWithParameters != oldSearchParam.andStartsWithParameters
                || searchParam.andInParameters!= oldSearchParam.andInParameters
                || searchParam.orLikeParameters != oldSearchParam.orLikeParameters
                || searchParam.orInMultipicklistParameters != oldSearchParam.orInMultipicklistParameters
                || searchParam.multipicklistFieldOrAndLogic != oldSearchParam.multipicklistFieldOrAndLogic
                || searchParam.andLikeParameters != oldSearchParam.andLikeParameters
                || searchParam.junctionOrAndLogic != oldSearchParam.junctionOrAndLogic
                || searchParam.inJunctionOrAndParameters != oldSearchParam.inJunctionOrAndParameters
                || searchParam.andEqualsParameters != oldSearchParam.andEqualsParameters
                || searchParam.includesAll != oldSearchParam.includesAll
                || searchParam.includesAny != oldSearchParam.includesAny
                )
                || stdSetControllerTrial == null) {
            if (!String.isBlank(sortDirection) && !String.isBlank(sortExpression)) {
                searchParam.sortDirection = sortDirection;
                searchParam.sortExpression = sortExpression;
            }
            if (!searchParam.isEmpty() || parentPage == 'CFAR_Home') {
                stdSetControllerTrial = new ApexPages.StandardSetController(CFAR_DAO.getTrialsLessFields(searchParam));
            } else {
                stdSetControllerTrial = new ApexPages.StandardSetController(new List<CFAR_Trial_gne__c>());
            }
            stdSetControllerTrial.setPageSize(pageSize);
        }
        
        oldSearchParam.andStartsWithParameters = searchParam.andStartsWithParameters;
        oldSearchParam.andInParameters = searchParam.andInParameters;
        oldSearchParam.orLikeParameters = searchParam.orLikeParameters;
        oldSearchParam.orInMultipicklistParameters = searchParam.orInMultipicklistParameters;
        oldSearchParam.multipicklistFieldOrAndLogic = searchParam.multipicklistFieldOrAndLogic;
        oldSearchParam.andLikeParameters = searchParam.andLikeParameters;
        oldSearchParam.junctionOrAndLogic = searchParam.junctionOrAndLogic;
        oldSearchParam.inJunctionOrAndParameters = searchParam.inJunctionOrAndParameters;
        oldSearchParam.andEqualsParameters = searchParam.andEqualsParameters;
        oldSearchParam.includesAll = searchParam.includesAll;
        oldSearchParam.includesAny = searchParam.includesAny;
    }
    
    private void fillTrials() {
        objectListTrial = new List<CFAR_SObjectWrapper>();
        objectMapTrial = new Map<Id, CFAR_SObjectWrapper>();
        for (SObject s : stdSetControllerTrial.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, s.Id == currentObjectRefId);
            objectListTrial.add(obj);
            objectMapTrial.put(s.Id, obj);
        }
    }
    
    public String getListPageName() {
        String result;
        if (pageConfiguration != null) {
            result = pageConfiguration.Section_Header_gne__c;
        } else {
            result = '';
        }
        return result;
    }
    
    public void displaySummary() {
        objectMapTrial.get(currentObjectRefId).selected = !objectMapTrial.get(currentObjectRefId).selected ? true : false;
        showSummary = objectMapTrial.get(currentObjectRefId).selected;
        trialSummary = [select Id, Name, Trial_Status_ref_gne__c, Next_Payment_Due_gne__c, Trial_Status_ref_gne__r.Name, Planned_Enrollment_gne__c, Enrolled_Sum_rollup_gne__c, CFAR_Actual_Enrollment_gne__c, IRB_Renewal_Date_gne__c,
                            (select Id, Name, Created_By_CFAR_Contact_ref_gne__c, Created_By_CFAR_Contact_ref_gne__r.Search_Name__c, Activity_Date_gne__c, Comments_gne__c, Active_gne__c, Trial_Status_ref_gne__c, frm_Trial_Status_gne__c
                             from CFAR_Comments__r where Activity_Date_gne__c >= :Date.today().addDays(-30) order by Activity_Date_gne__c desc nulls last, LastModifiedDate desc limit 1)
                             from CFAR_Trial_gne__c where Id = :currentObjectRefId];
        for (CFAR_SObjectWrapper w : objectListTrial) {
            if (w.innerObject.Id != currentObjectRefId) {
                w.selected = false;
            }
        }
    }
   
    public void sortTrial() {
        searchParam.sortDirection = sortDirection;
        searchParam.sortExpression = sortExpression;
        stdSetControllerTrial = new ApexPages.StandardSetController(CFAR_DAO.getTrialsLessFields(searchParam));
        stdSetControllerTrial.setPageSize(pageSize);
    }
    
    public void previousTrial() {
        stdSetControllerTrial.previous();
    }
    
    public void nextTrial() {
        stdSetControllerTrial.next();
    }
    
    public void firstTrial() {
        stdSetControllerTrial.first();
    }
    
    public void lastTrial() {
        stdSetControllerTrial.last();
    }
    
    public Boolean hasNextTrial {
        get {
            return stdSetControllerTrial.getHasNext();
        }
        private set;
    }
    
    public Boolean hasPreviousTrial {
        get {
            return stdSetControllerTrial.getHasPrevious();
        }
        private set;
    }
    
    public PageReference exportToExcelClick() {
        if (!String.isBlank(sortDirection) && !String.isBlank(sortExpression)) {
            paramsForXLSMap.put('sortDirection', sortDirection);
            paramsForXLSMap.put('sortExpression', sortExpression);
        }
        PageReference pageRef = null;
        pageRef = new PageReference('/apex/CFAR_MyTrialsXLS');
        pageRef.getParameters().putAll(paramsForXLSMap);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public Boolean getIsParentSearchPage() {
        return parentPage == 'BasicSearch' || parentPage == 'AdvancedSearch';
    }
}