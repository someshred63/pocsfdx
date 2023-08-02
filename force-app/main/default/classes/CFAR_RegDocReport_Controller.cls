global with sharing class CFAR_RegDocReport_Controller {

	//private static Map<Id, String> dollarAndDrugMap;
	//private static final Set<String> expiryRegDocActivities = new Set<String>{'CV', 'Sub-I CV', 'Medical License', 'Sub-I Medical License', 'IRB Approval Letter'};
	private static final Set<String> expiryRegDocActivities = new Set<String>{'CV', 'Sub-I CV', 'Medical License', 'Sub-I Medical License', 'IRB Approval Letter for Original Protocol'};
	//private static final Map<String, String> rdtColumnsWithOtherNames = new Map<String, String>{'CV'=>'CV (Signed Date)', 'Medical License'=>'ML (expiration date)', 'IB Signature Page'=>'IB Version & Signature Page Date', 'clinicaltrials.gov'=>'ClinicalTrial.gov Registration', 'IRB Closure Letter'=>'IRB Closure Notification Date', 'Final Study Report'=>'Manuscript or Final Study Report Received', 'Study Closure Letter'=>'Study Closure Letter sent', 'IRB Approval Letter'=>'IRB Expiration Date'};
	private static final Map<String, String> rdtColumnsWithOtherNames = new Map<String, String>{'CV'=>'CV (Signed Date)', 'Medical License'=>'ML (expiration date)', 'IB Signature Page'=>'IB Version & Signature Page Date', 'clinicaltrials.gov'=>'ClinicalTrial.gov Registration', 'IRB Closure Letter Received'=>'IRB Closure Notification Date', 'Final Study Report Received'=>'Manuscript or Final Study Report Received', 'Study Closure Letter Sent'=>'Study Closure Letter sent', 'IRB Approval Letter for Original Protocol'=>'IRB Expiration Date'};
	private transient RegDocReportDataWrapper reportDataToShow;
	private transient List<List<RegDocReportCommentWrapper>> reportCommentsToShow;
	//public transient Map<String, String> parametersMap {get; set;}
	private transient Map<String, String> parametersMap;
	
	public CFAR_RegDocReport_Controller() {
		parametersMap = ApexPages.currentPage().getParameters();
	}
	
	public String getWorkbookProperties() {
        String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + 'Regulatory Document Report' + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
        return workbook;
    }
    
    public String getFileName() {
        String fileName = 'Regulatory_Document_Report_' + String.valueOf(Date.today());
        return fileName;
    }
    
    public RegDocReportDataWrapper getRegDocReportData() {
    	reportDataToShow = getRegDocReportDataAction(parametersMap.get('indication'), parametersMap.get('product'), parametersMap.get('studyNo'), parametersMap.get('studyStatus'), parametersMap.get('therapeuticArea'), parametersMap.get('trialType'), parametersMap.get('subjectType'), parametersMap.get('ctms'), parametersMap.get('wbs'), parametersMap.get('pediatricStudies'),
													parametersMap.get('specificIndication'),parametersMap.get('impact'),parametersMap.get('SRT'),parametersMap.get('teamMember'),parametersMap.get('gneSupport'),parametersMap.get('inclusive'));
    	return reportDataToShow;
    }
    
    public List<List<RegDocReportCommentWrapper>> getRegDocCommentsData() {
    	reportCommentsToShow = getRegDocReportCommentsAction(parametersMap.get('indication'), parametersMap.get('product'), parametersMap.get('studyNo'), parametersMap.get('studyStatus'), parametersMap.get('therapeuticArea'), parametersMap.get('trialType'), parametersMap.get('subjectType'), parametersMap.get('ctms'), parametersMap.get('wbs'), parametersMap.get('pediatricStudies'),
													parametersMap.get('specificIndication'),parametersMap.get('impact'),parametersMap.get('SRT'),parametersMap.get('teamMember'),parametersMap.get('gneSupport'),parametersMap.get('inclusive'));
		return reportCommentsToShow;
    }

    @RemoteAction
    global static RegDocReportDataWrapper getRegDocReportDataAction(String indication, String product, String studyNo, String studyStatus, String therapeuticArea, String trialType, String subjectType, String ctms, String wbs, String pediatricStudies,
																	String specIndication, String impact, String SRT, String teamMember, String GNEs, String inclusiveResearch) {
    	RegDocReportDataWrapper rdrdw = new RegDocReportDataWrapper();//object that holds a list of trials
    	List<String> rdal = new List<String>(); //activity list
    	Set<String> rdas = new Set<String>();  //activity set
    	List<String> rdhl = new List<String>();  //header list
    	Map<String, String> rdhtam = new Map<String, String>();  //activity to header map
    	fillRegDocActivitiesListAndSet(rdal, rdas, rdhl, rdhtam);
        List<CFAR_Trial_gne__c> trialsOnProduct = CFAR_DAO.getTrialsForRegDocReport(setSearchParams(indication, product, studyNo, studyStatus, therapeuticArea, trialType, subjectType, ctms, wbs, pediatricStudies, specIndication, impact, SRT, teamMember, GNEs, inclusiveResearch));
        trialsOnProduct.sort();
    	Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>> trial2ContractTrackings = getTrial2ContractTrackingsMap(trialsOnProduct);
    	List<RegDocReportTrialInvestigatorsWrapper> trialWrappersList = new List<RegDocReportTrialInvestigatorsWrapper>(); //list of trials

    	for (CFAR_Trial_gne__c t : trialsOnProduct) {
    		RegDocReportTrialInvestigatorsWrapper investigatorListWrapper = new RegDocReportTrialInvestigatorsWrapper(); //object that holds a list of report rows for a trial
    		List<RegDocReportTrialWrapper> investigatorList = new List<RegDocReportTrialWrapper>(); //list of report rows for a trial
    		//for the trial get set of investigators (team members) that created any reg docs 
    		Set<CFAR_Team_Member_gne__c> RegDocInvestigators = new Set<CFAR_Team_Member_gne__c>();
    		Set<Id> ContactsSet = new Set<Id>(); //a helper list of already listed contact ids in case someone has been desactivated and activated again
    		for (CFAR_Team_Member_gne__c member : t.CFAR_Team_Members__r) {
    			if (!ContactsSet.contains(member.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c)) {
	    			for (CFAR_Regulatory_Document_Tracking_gne__c regdoc :t.CFAR_Regulatory_Document_Trackings__r) {
	    				if (regdoc.Reg_Doc_Investigator_gne__r.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c==member.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c) {//group by contact not by member - member.id change when member edited
							if (member.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c==null) {//if contact has been deleted but it's reg doc remains
								if (regdoc.Reg_Doc_Investigator_gne__r.frm_Name_gne__c==member.frm_Name_gne__c){//additionally chcek member name to avoid duplicates
									RegDocInvestigators.add(member);
								}
							} else {
	    						RegDocInvestigators.add(member);
	    						ContactsSet.add(member.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c);
							}
	    				}
	    			}
    			}
    		}
    		Integer tmpNo = 0;
    		for (CFAR_Team_Member_gne__c member : RegDocInvestigators) {
	    		RegDocReportTrialWrapper rdrtw = new RegDocReportTrialWrapper();
	    		rdrtw.mainSite = (member.frm_Function_Role_gne__c == 'PI = Primary (or Principal) Investigator') ? 'Yes' : (member.frm_Function_Role_gne__c != null) ? 'No' : null;
		    	if (tmpNo == 0) {	//fill cells that are visible once for whole trail
		    		rdrtw.protocolNumber = (t.Other_Trial_gne_Id__c != null) ? CFAR_Utils.customEscape(t.Other_Trial_gne_Id__c) : (t.CTMS_gne__c!=null) ? CFAR_Utils.customEscape(t.CTMS_gne__c) : CFAR_Utils.customEscape(t.Name);
		    		rdrtw.CTMS = CFAR_Utils.customEscape(t.CTMS_gne__c);
		    		rdrtw.trialNumber = CFAR_Utils.customEscape(t.Name);
					rdrtw.csm = CFAR_Utils.customEscape(t.frm_Genentech_Primary_Contact_ref_gne__c);
					for (CFAR_Team_Member_gne__c tm : t.CFAR_Team_Members__r) {
						if (tm.frm_Function_Role_gne__c == 'CSA = Clinical Study Associate') {
							rdrtw.csa += (String.isBlank(rdrtw.csa)) ? tm.frm_Name_gne__c : '; ' + tm.frm_Name_gne__c;
						}
					}
		    		rdrtw.trialStatus = t.frm_Trial_Status_ref_gne__c;
		    	} else {
		    		rdrtw.protocolNumber = null;
					rdrtw.CTMS = null;
					rdrtw.trialNumber = null;
					rdrtw.csm = null;
					rdrtw.csa = null;
					rdrtw.trialStatus = null;
		    	}	
	    		rdrtw.invastigatorSponsorName=CFAR_Utils.customEscape(member.frm_Name_gne__c);
	    		rdrtw.institutionName = CFAR_Utils.customEscape(member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name);
	    		rdrtw.gneSupport = /*dollarAndDrugMap.get(t.Dollar_and_Drug_ref_gne__c)*/ member.Dollar_and_Drug_ref_gne__r.Name;
	    		//DONE: ITERATION2 MultiContract
	            List<CFAR_Budget_Contract_Tracking_gne__c> trackingList = trial2ContractTrackings.get(t.Id);
	    		Datetime expDate =(trackingList!=null)?setContractExpirationDate(trackingList,member):null;
	    		rdrtw.contractExpiration = (expDate!=null)? expDate.formatGmt('yyyy-MM-dd') : NULL;
	    		rdrtw.indReq = t.IND_Required_gne__c;
	    		rdrtw.indNumber = (t.IND_gne__c==null)?((t.IND_Required_gne__c=='Yes')?'N/A':null):CFAR_Utils.customEscape(t.IND_gne__c);
	    		rdrtw.exemptDate = (t.IND_Exempt_Letter_Date_gne__c==null)?((t.IND_Required_gne__c=='Yes')?'N/A':null):(t.IND_Exempt_Letter_Date_gne__c.year()+'-'+t.IND_Exempt_Letter_Date_gne__c.month()+'-'+t.IND_Exempt_Letter_Date_gne__c.day());
	    		rdrtw.rdaw = fillRegDocsListForTrial(t.CFAR_Regulatory_Document_Trackings__r, member);
	    		rdrtw.rdaw.sort();
	    		investigatorList.add(rdrtw); //list of investigators
	    		tmpNo++;
    		}
    		if (!investigatorList.isEmpty()) { 
    			investigatorListWrapper.trials=investigatorList;//for each trial the object holds a list of investigators
    			trialWrappersList.add(investigatorListWrapper); 
    		}
    	}
	    rdrdw.regDocActivitiesList = rdal;
	    rdrdw.regDocHeadersList = rdhl;
	    rdrdw.regDocHeaderToActivityMap = rdhtam;
	    rdrdw.trials = trialWrappersList;
    	return rdrdw;
    }
    
    @RemoteAction
    global static List<List<RegDocReportCommentWrapper>> getRegDocReportCommentsAction(String indication, String product, String studyNo, String studyStatus, String therapeuticArea, String trialType, String subjectType, String ctms, String wbs, String pediatricStudies,
																						String specIndication, String impact, String SRT, String teamMember, String GNEs, String inclusiveResearch) {
		List<List<RegDocReportCommentWrapper>> rdrcwList = new List<List<RegDocReportCommentWrapper>>();
    	List<RegDocReportCommentWrapper> tmpList = new List<RegDocReportCommentWrapper>();
    	List<CFAR_Trial_gne__c> trialsListForComments = CFAR_DAO.getCommentsForRegDocReport(setSearchParams(indication, product, studyNo, studyStatus, therapeuticArea, trialType, subjectType, ctms, wbs, pediatricStudies, specIndication, impact, SRT, teamMember, GNEs, inclusiveResearch));
    	for (CFAR_Trial_gne__c trial : trialsListForComments) {
    		for (CFAR_Regulatory_Document_Tracking_gne__c tracking : trial.CFAR_Regulatory_Document_Trackings__r) {
    			//if (tracking.Comments2_gne__c != null) {
    				tmpList.add(new RegDocReportCommentWrapper(trial.Name, tracking.frm_Regulatory_Tracking_Activity_gne__c, tracking.Comments2_gne__c));
    				//10.000 is size limit for apex:dataTable, apex:dataList and apex:repeat in case, page has attribute: readOnly="true"
    				//Without it, this limit is only 1000. ReadOnly page can't use DML operations, which are: insert, update, merge, delete and restore
    				if (tmpList.size() == 10000) {
    					rdrcwList.add(tmpList);
    					tmpList = new List<RegDocReportCommentWrapper>();
    				}
    			//}
    		}
    	}
    	if (!tmpList.isEmpty()) {
    		rdrcwList.add(tmpList);
    	}
    	return rdrcwList;
    }

    private static Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>> getTrial2ContractTrackingsMap(List<CFAR_Trial_gne__c> trials) {
        Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>> trial2ContractTrackings = new Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>>();
        Set<Id> trialIds = new Map<Id, CFAR_Trial_gne__c>(trials).keySet(); //ids in 18-character format
        Set<String> trialIds15 = new Set<String>();  
        for (Id i : trialIds) {
        	trialIds15.add(String.valueOf(i).substring(0,15)); //convert ids to 15-character format to use in SOQL query
        }
        for (CFAR_Budget_Contract_Tracking_gne__c tracking : [select Frm_Trial_Id_gne__c, Contract_Expiry_Date_gne__c, frm_Type_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, CreatedDate from CFAR_Budget_Contract_Tracking_gne__c
                where Frm_Trial_Id_gne__c IN :trialIds15
                and frm_Type_gne__c IN ('Original Contract', 'Contract Amendment Increase', 'Contract Amendment Decrease', 'Contract Amendment No Change')
                and Contract_Expiry_Date_gne__c != null and frm_Type_gne__c != null]) {
            if (trial2ContractTrackings.containsKey(tracking.Frm_Trial_Id_gne__c)) {
                trial2ContractTrackings.get(tracking.Frm_Trial_Id_gne__c).add(tracking);
            } else {
                trial2ContractTrackings.put(tracking.Frm_Trial_Id_gne__c, new List<CFAR_Budget_Contract_Tracking_gne__c>{tracking});
            }
        }
        return trial2ContractTrackings;
    }

    private static CFAR_SearchParameters setSearchParams(String indication, String product, String studyNo, String studyStatus, String therapeuticArea, String trialType, String subjectType, String ctms, String wbs, String pediatricStudies,
														String specIndication, String impact, String SRT, String teamMember, String GNEs, String inclusiveResearch) {
		CFAR_SearchParameters searchParams = new CFAR_SearchParameters();
		if (!String.isBlank(indication)) {
    		List<String> giIds = indication.split(';', -1);
            List<CFAR_General_Indication_for_Trial_gne__c> gis = [Select CFAR_Trial_ref_gne__c, CFAR_General_Indication_ref_gne__c from CFAR_General_Indication_for_Trial_gne__c where CFAR_General_Indication_ref_gne__c in :giIds];
            Set<String> trialIdsForGI = new Set<String>();
            Map<String, Set<String>> trialsMapForGI = new Map<String, Set<String>>();
            for(CFAR_General_Indication_for_Trial_gne__c gi : gis) {
            	if(!trialsMapForGI.containsKey(gi.CFAR_Trial_ref_gne__c)) 
                	trialsMapForGI.put(gi.CFAR_Trial_ref_gne__c, new Set<String>());
                trialsMapForGI.get(gi.CFAR_Trial_ref_gne__c).add(gi.CFAR_General_Indication_ref_gne__c);                        
            }
            for(String trialId : trialsMapForGI.keySet()) {
            	if(trialsMapForGI.get(trialId).size() == giIds.size())
                	trialIdsForGI.add(trialId); 
            }
        	searchParams.andInParameters.put('Id', new List<String>(trialIdsForGI));
    	}
    	if (!String.isBlank(product)) {
    		searchParams.andInParameters.put('Product_ref_gne__c', product.split(';', -1));
    	}
    	if (!String.isBlank(studyNo)) {
    		searchParams.andLikeParameters.put('Name', studyNo);
    	}
    	if (!String.isBlank(studyStatus)) {
    		searchParams.andInParameters.put('Trial_Status_ref_gne__c', studyStatus.split(';', -1));
    	}
    	if (!String.isBlank(therapeuticArea)) {
    		searchParams.andInParameters.put('Therapeutic_Area_ref_gne__c', therapeuticArea.split(';', -1));
    	}
    	if (!String.isBlank(trialType)) {
    		searchParams.andInParameters.put('Trial_Type_ref_gne__c', trialType.split(';', -1));
    	}
    	if (!String.isBlank(subjectType)) {
    		searchParams.orEqualsParameters.put('Subject_Type__c', subjectType.split(';', -1));
    	}
        if (!String.isBlank(pediatricStudies)) {
            searchParams.orEqualsParameters.put('Pediatric_Study_gne__c', pediatricStudies.split(';', -1));
        }
    	if (String.isNotBlank(ctms)) {
			searchParams.andLikeParameters.put('CTMS_gne__c', ctms);
		}
        if (String.isNotBlank(wbs)) {
	        Map<String,String> WBSesMap = new Map<String,String>();
            WBSesMap.put('CFAR_WBS_ref_gne__r.GSR_WBS_gne__c', wbs);
            WBSesMap.put('CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c', wbs);
            searchParams.orLikeParameters.put('WBS', WBSesMap);  
        }
		if (String.isNotBlank(specIndication)) {
			List<CFAR_Specific_Indication_for_Trial_gne__c> sis = [SELECT CFAR_Trial_ref_gne__c, CFAR_Specific_Indication_ref_gne__c FROM CFAR_Specific_Indication_for_Trial_gne__c WHERE CFAR_Specific_Indication_ref_gne__c IN : specIndication.split(';', -1)];
			Set<String> trialIdsForSI = new Set<String>();
			for (CFAR_Specific_Indication_for_Trial_gne__c si : sis) {
				trialIdsForSi.add((String)si.CFAR_Trial_ref_gne__c);
			}
			if (searchParams.andInParameters.containsKey('Id') && !searchParams.andInParameters.get('Id').isEmpty()) {
				trialIdsForSI.retainAll(searchParams.andInParameters.get('Id'));
				searchParams.andInParameters.put('Id', new List<String>(trialIdsForSI));
			} else {
				searchParams.andInParameters.put('Id', new List<String>(trialIdsForSI));
			}
		}
		if (String.isNotBlank(impact)) {
			searchParams.includesAny.put('Impacts_gne__c', impact.split(';'));

		}
		if (String.isNotBlank(SRT)) {
			searchParams.andInParameters.put('SRT_Team_ref_gne__c', SRT.split(';'));
		}
		if (String.isNotBlank(teamMember)) {
			Set<String> tmTrialIds = CFAR_Utils.getTrialsForContacts(teamMember.split(';'));
			if (searchParams.andInParameters.containsKey('Id') && !searchParams.andInParameters.get('Id').isEmpty()) {
				tmTrialIds.retainAll(searchParams.andInParameters.get('Id'));
			}
			searchParams.andInParameters.put('Id', new List<String>(tmTrialIds));
		}
		if (String.isNotBlank(GNEs)) {
			searchParams.andInParameters.put('Dollar_and_Drug_ref_gne__c', GNEs.split(';'));

		}
		if (String.isNotBlank(inclusiveResearch)) {
			searchParams.andInParameters.put('Inclusive_Research_gne__c', inclusiveResearch.split(';'));
		}
    	return searchParams;
    }
    
    private static void fillRegDocActivitiesListAndSet(List<String> actList, Set<String> actSet, List<String> headersList, Map<String, String> headerToActivityMap) {
    	List<CFAR_Tracking_Activity_gne__c> activities = [select Name from CFAR_Tracking_Activity_gne__c order by Name];
    	for (CFAR_Tracking_Activity_gne__c ta: activities) {
    		actList.add(ta.Name);
    	}
    	actSet.addAll(actList);
    	for (String s : actSet) {
    		if (rdtColumnsWithOtherNames.containsKey(s)) {
    			headersList.add(rdtColumnsWithOtherNames.get(s));
    			headerToActivityMap.put(rdtColumnsWithOtherNames.get(s), s);
    		}
    		else {
    			headersList.add(s);
    			headerToActivityMap.put(s, s);
    		}
    	}
    	headersList.sort();
    }
	
	    private static List<RegDocActivityWrapper> fillRegDocsListForTrial(List<CFAR_Regulatory_Document_Tracking_gne__c> trackingsOnTrial, CFAR_Team_Member_gne__c member) {
    	List<RegDocActivityWrapper> trackingsToRet = new List<RegDocActivityWrapper>();
    	
    	for (CFAR_Regulatory_Document_Tracking_gne__c RegDoc : trackingsOnTrial) {
   			if (RegDoc.Reg_Doc_Investigator_gne__r.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c==member.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c) {
    			RegDocActivityWrapper rdaw = new RegDocActivityWrapper();
    			rdaw.Name = CFAR_Utils.customEscape(RegDoc.frm_Regulatory_Tracking_Activity_gne__c);
    			rdaw.Id = RegDoc.Id;
    			datetime tmp = (datetime)RegDoc.Date_Received_gne__c;
    			rdaw.receivedDate = (tmp!=null)?tmp.addDays(1).format('yyyy-MM-dd'):null;
    			tmp = RegDoc.Expiry_Date_gne__c;
    			rdaw.expiryDate = (tmp!=null)?tmp.addDays(1).format('yyyy-MM-dd'):null;
    			rdaw.comment = CFAR_Utils.customEscape(RegDoc.Comments2_gne__c);
    			trackingsToRet.add(rdaw);
    		}
    	}
    	
    	return trackingsToRet;
    }
    
    private static Datetime setContractExpirationDate(List<CFAR_Budget_Contract_Tracking_gne__c> trackings, CFAR_Team_Member_gne__c member) {
    	Datetime retVal = null;
    	CFAR_Budget_Contract_Tracking_gne__c newest = trackings.get(0);
    	for (CFAR_Budget_Contract_Tracking_gne__c tracking : trackings) {
    		//if (tracking.frm_Type_gne__c.equals('Original Contract')) {
    		if (tracking.frm_Type_gne__c != ('Contract Cancelled')) {
    			if (tracking.CreatedDate>=newest.CreatedDate && tracking.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c == member.id) {
	    			newest=tracking;
	    			retVal = tracking.Contract_Expiry_Date_gne__c;
	    		}
    		}
    	}
    	return retVal;
    }
    
    global class RegDocReportDataWrapper {
    	public List<String> regDocActivitiesList {get; set;}
    	public List<String> regDocHeadersList {get; set;}
    	public Map<String, String> regDocHeaderToActivityMap {get; set;}
    	public List<RegDocReportTrialInvestigatorsWrapper> trials {get; set;}
    }
    
    global class RegDocReportTrialInvestigatorsWrapper {
    	public List<RegDocReportTrialWrapper> trials {get; set;}
    }
    
    global class RegDocReportTrialWrapper {
    	public String trialNumber {get; set;}
    	public String protocolNumber {get; set;}
    	public String invastigatorSponsorName {get; set;}
    	public String studyNumber {get; set;}
    	public String institutionName {get; set;}
    	public String gneSupport {get; set;}
    	public String trialStatus {get; set;}
    	public Date activationDate {get; set;}
    	public String contractExpiration {get; set;}
    	public String indReq {get; set;}
    	public String indNumber {get; set;}
    	public String exemptDate {get; set;}
    	public Integer no {get; set;}
    	public Map<String, RegDocActivityWrapper> rdawMap {get; set;}
    	public List<RegDocActivityWrapper> rdaw {get; set;}  //keep activities to display
    	public String finalEnrollmentLogYesNo {get; set;}
    	public Date contractExtensionLetterToSite {get; set;}
    	public String mainSite {get; set;}
    	public String CTMS {get; set;}
    	public String csm {get; set;}
    	public String csa {get; set;}

		global RegDocReportTrialWrapper() {
			csm = '';
			csa = '';
		}
    }
    
    global class RegDocActivityWrapper implements Comparable {
    	public String Id {get; set;}
    	public String Name {get; set;}
    	public String receivedDate {get; set;}
    	public String expiryDate {get; set;}
    	public Date dateDisplayed {get; set;}
    	public String comment {get; set;}
    	
    	global Integer compareTo(Object compareTo) {
    		RegDocActivityWrapper compareToRdaw = (RegDocActivityWrapper)compareTo;
    		if (receivedDate == compareToRdaw.receivedDate) return 0;
    		if (receivedDate < compareToRdaw.receivedDate) return -1;
    		return 1;
		}
    }
    
    global class RegDocReportCommentWrapper {
    	public String trialNumber {get; set;}
    	public String regDocActivity {get; set;}
    	public String comment {get; set;}
    	
    	public RegDocReportCommentWrapper(String tn, String rda, String c) {
    		this.trialNumber = tn;
    		this.regDocActivity = rda;
    		this.comment = c;
    	}
    }

}