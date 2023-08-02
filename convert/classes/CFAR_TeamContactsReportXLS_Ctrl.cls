public with sharing class CFAR_TeamContactsReportXLS_Ctrl {
	
	public static Set<String> externals = new Set<String> { 'PI = Primary (or Principal) Investigator', 'Sub-I = Sub-investigator', 'Other-External', 'SLC = Specialty Lab Contact', 'RCC = Reading Center Contact', 'DDC = Drug Depot Contact', 'Ph = Pharmacist', 'SC = Study Coordinator' };
	
	public class TeamContactsData {
		public String protocolNo {get; set;} 
		public String gstarsNo {get; set;} 
		public String csm {get; set;}
		public String csa {get; set;}
		public String trialStatus {get; set;}
		public String product {get; set;}
		public String functionRole {get; set;}
		public String teamMemberName {get; set;}
		public String internalExternal {get; set;}
		public String parentOrganization {get; set;}
		public String institution {get; set;}
		public String address {get; set;}
		public String phoneNumber {get; set;}
		public String faxNumber {get; set;}
		public String emailAddress {get; set;}
		public String activeOn {get; set;}
		public String inactiveOn {get; set;} 
		
	}
	
	public transient List<TeamContactsData> teamContactsXLSData {get; private set;}
	
	public String getFileName() {
        return 'Team_Contacts_Report_' + String.valueOf(Date.today());
    }
    
    public CFAR_TeamContactsReportXLS_Ctrl() {
		String searchParams = '';
		String products = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('products'));
		String tmNames = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('tmNames'));
		String csms = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('csm'));
		String csas = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('csa'));
		String parentOrganizations = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('parentOrganizations'));
		String studyStatus = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('studyStatus'));
		String institutions = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('institutions'));
		String ctmsParam = CFAR_TeamContactsReport_Helper.secureParam(ApexPages.currentPage().getParameters().get('ctmsNo'));
		String gstarsParam = CFAR_TeamContactsReport_Helper.secureParam(ApexPages.currentPage().getParameters().get('gstarsNo'));
		String tmStatus = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('tmStatus'));
		String internalExternal = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('internalExternal'));
		String functionRoles = CFAR_TeamContactsReport_Helper.secureParam(Apexpages.currentpage().getparameters().get('functionRoles'));
    	String externalsStr = '';

    	for (String ext : externals) {
    		externalsStr += ext + ';';
    	}
    	List<Id> csacsmTrialIds = new List<Id> ();
    	
		if (String.isNotEmpty(csms)) {
			List<String> csmNames = new List<String> ();
			csmNames = csms.split(';');
			system.debug(csmNames);
			List<CFAR_Trial_gne__c> trialsForCMS = [
				SELECT Id, Name, frm_Genentech_Primary_Contact_ref_gne__c 
				FROM CFAR_Trial_gne__c 
				WHERE frm_Genentech_Primary_Contact_ref_gne__c in :csmNames
			];
			for(CFAR_Trial_gne__c t : trialsForCMS) {
				csacsmTrialIds.add(t.Id);
			} 
		}
		if (String.isNotEmpty(csas)) {
			List<String> csaNames = new List<String> ();
			csaNames = csas.split(';');
			system.debug(csaNames);
			List<CFAR_Team_member_gne__c> teamMembersCSA = [
				SELECT Id, CFAR_Trial_ref_gne__r.Id, Name,frm_Name_gne__c, frm_Function_Role_gne__c, frm_Is_Inactive_gne__c 
				FROM CFAR_Team_member_gne__c 
				WHERE frm_Function_Role_gne__c = :CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE 
				AND frm_Name_gne__c in :csaNames
				AND frm_Is_Inactive_gne__c = false
			];
			for(CFAR_Team_Member_gne__c t : teamMembersCSA) {
				csacsmTrialIds.add(t.CFAR_Trial_ref_gne__r.Id);
		}
		
		}

    	teamContactsXLSData = new List<TeamContactsData>();
    	String queryString = '';
    	String queryStringParams = '';
    	queryString += 'SELECT CFAR_Trial_ref_gne__r.Id, CFAR_Trial_ref_gne__r.Name, CFAR_Trial_ref_Gne__r.frm_Is_Closed_gne__c, CFAR_Trial_ref_gne__r.frm_Protocol_number_gne__c, CFAR_Trial_ref_gne__r.Brief_title_gne__c, CFAR_Trial_ref_gne__r.Other_Trial_gne_Id__c,CFAR_Trial_ref_gne__r.Trial_Status_ref_gne__c,CFAR_Trial_ref_gne__r.frm_trial_status_ref_gne__c, CFAR_Trial_ref_gne__r.CTMS_gne__c, CFAR_Trial_ref_gne__r.Product_ref_gne__c, CFAR_Trial_ref_gne__r.Product_ref_gne__r.Name,';
    	queryString += 'Id, frm_Function_Role_gne__c, frm_Is_Inactive_gne__c, Function_Role_gne__c, frm_Name_gne__c, contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__r.Name,';
		queryString += 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name, contact_address_ref_gne__r.Contact_Address_ref_gne__r.Department_Division_gne__c,'; 
		queryString += 'contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Phone_gne__c,contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Mobile_Phone_gne__c, CFAR_Trial_ref_gne__r.frm_Genentech_Primary_Contact_ref_gne__c, ';
		queryString += 'contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Alternate_Phone_gne__c, contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Fax_gne__c,';
		queryString += 'contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Email_gne__c, contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Active_Date_gne__c,';
		queryString += 'contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Inactive_Date_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c,';
		queryString += 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c,';
		queryString += 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c,';
		queryString += 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c,contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c, Active_On_gne__c, Inactive_On_gne__c ';											
		queryString += ' FROM CFAR_Team_Member_gne__c WHERE ';
		
		
		String selectedTMNames = (tmNames != '' ? tmNames + ';' : '');//+ (csms != '' ? csms + ';' : '') + (csas != '' ? csas : '') ;
		queryStringParams += selectedTMNames.length() > 2 ? createSubCriteria(selectedTMNames, 'frm_Name_gne__c') : '';
		queryStringParams += csacsmTrialIds.isEmpty() ? '' : createSubCriteria(csacsmTrialIds, 'CFAR_Trial_ref_gne__r.Id');
		queryStringParams += createSubCriteria(parentOrganizations, 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__r.Name');
		queryStringParams += createSubCriteria(institutions, 'contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name');
		queryStringParams += tmStatus == 'All' ? '' :  'frm_Is_Inactive_gne__c = false AND ';
		queryStringParams += internalExternal == 'All' ? createSubCriteria(functionRoles, 'frm_Function_Role_gne__c') : 
								internalExternal == 'External' ? createSubCriteria(externalsStr + ';' + functionRoles, 'frm_Function_Role_gne__c') : 
								createNotInCriteria(externalsStr,'frm_Function_Role_gne__c') + createSubCriteria(functionRoles, 'frm_Function_Role_gne__c');
		queryStringParams += createSubCriteria(products, 'CFAR_Trial_ref_gne__r.Product_ref_gne__c');
		queryStringParams += String.isBlank(studyStatus) || studyStatus == '' ? createSubCriteria(CFAR_TeamContactsReport_Helper.getAvailableTrialStatuses(), 'CFAR_Trial_ref_gne__r.Trial_Status_ref_gne__c') : createSubCriteria(studyStatus, 'CFAR_Trial_ref_gne__r.Trial_Status_ref_gne__c');
		queryStringParams += createSubCriteria(ctmsParam, 'CFAR_Trial_ref_gne__r.CTMS_gne__c');
		queryStringParams += createSubCriteria(gstarsParam, 'CFAR_Trial_ref_gne__r.Name');
		if (queryStringParams != '') {
			queryStringParams = queryStringParams.removeEnd('AND ');
		} else {
			queryString = queryString.removeEnd('WHERE ');
		}
		queryString += queryStringParams;
		queryString += ' order by CFAR_Trial_ref_gne__r.frm_Is_Closed_gne__c, CFAR_Trial_ref_gne__r.frm_Protocol_number_gne__c, frm_Name_gne__c';
		
		List<CFAR_Team_Member_gne__c> tmRecords = Database.query(queryString);
		
		Map<String,String> csaMap = new Map<String,String>();
		for(CFAR_Team_Member_gne__c member : tmRecords){
			if (member.frm_Function_Role_gne__c == CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE && !csaMap.containsKey(member.CFAR_Trial_ref_gne__c) && member.frm_Is_Inactive_gne__c == false) {
				csaMap.put(member.CFAR_Trial_ref_gne__c, member.frm_Name_gne__c);
			}
		}
		for (CFAR_Team_Member_gne__c tm : tmRecords) {
			TeamContactsData tcData = new TeamContactsData ();
			
			tcData.protocolNo = getProtocolNumber(tm.CFAR_Trial_ref_gne__r);
			tcData.gstarsNo = tm.CFAR_Trial_ref_gne__r.Name;
			
			tcData.csm = tm.CFAR_Trial_ref_gne__r.frm_Genentech_Primary_Contact_ref_gne__c;
			tcData.csa = csaMap.get(tm.CFAR_Trial_ref_gne__c);  
			
			String address = createAddress(tm);
			String phoneNum = setPhoneNumber(tm);
			
			tcData.trialStatus = String.isBlank(tm.CFAR_Trial_ref_gne__r.frm_trial_status_ref_gne__c) ? '' : CFAR_Utils.customEscape(tm.CFAR_Trial_ref_gne__r.frm_trial_status_ref_gne__c);
			tcData.product = CFAR_Utils.customEscape(tm.CFAR_Trial_ref_gne__r.Product_ref_gne__r.Name);
			tcData.functionRole = String.isBlank(tm.frm_Function_Role_gne__c) ? '' : CFAR_Utils.customEscape(tm.frm_Function_Role_gne__c.split(' ').get(0));
			tcData.teamMemberName = String.isBlank(tm.frm_Name_gne__c) ? '' : CFAR_Utils.customEscape(tm.frm_Name_gne__c);
			tcData.internalExternal = isExternal(tm.frm_Function_Role_gne__c) ? 'External' : 'Internal';
			tcData.parentOrganization = String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__r.Name) ? '' : CFAR_Utils.customEscape(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__r.Name);
			tcData.institution = String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name) ? '' : CFAR_Utils.customEscape(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name);
			tcData.address = String.isBlank(address) ? '' : CFAR_Utils.customEscape(address);
			tcData.phoneNumber = String.isBlank(phoneNum) ? '' : CFAR_Utils.customEscape(phoneNum);
			tcData.faxNumber = String.isBlank(tm.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Fax_gne__c) ? '' : CFAR_Utils.customEscape(tm.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Fax_gne__c);
			tcData.emailAddress = String.isBlank(tm.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Email_gne__c) ? '' : CFAR_Utils.customEscape(tm.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Email_gne__c);
			tcData.activeOn = tm.Active_On_gne__c != null ?  CFAR_Utils.customEscape(tm.Active_On_gne__c.format()) : '';
			tcData.inactiveOn = tm.Inactive_On_gne__c != null ? CFAR_Utils.customEscape(tm.Inactive_On_gne__c.format()) : '';
			teamContactsXLSData.add(tcData);
		}
	}
    
    public static String getProtocolNumber(CFAR_Trial_gne__c trial){
     if( !String.isBlank(trial.Other_Trial_gne_Id__c) ){
            return trial.Other_Trial_gne_Id__c;  
        } else if( !String.isBlank(trial.CTMS_gne__c))
            return trial.CTMS_gne__c;
        else{
            return trial.Name;
        }
    } 
    
	public Boolean isExternal(String funcRole) {
		
		Boolean isExt = externals.contains(funcRole);
		return isExt;
	}
    
	public String createAddress(CFAR_Team_Member_gne__c member) {
		String add = (String.isBlank(member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Department_Division_gne__c) ? '' : member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Department_Division_gne__c + ' ' ) +
                (String.isBlank(member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c) ? '' : member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c + ' ' ) + 
                (String.isBlank(member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c) ? '' : member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c + ', ' ) +
                (String.isBlank(member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c) ? (String.isBlank(member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c) ? '' : member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c + ', ') : member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c + ', ') +
                (String.isBlank(member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c) ? (String.isBlank(member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c) ? '' : member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c + ', ') : member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c + ', ') +
                (String.isBlank(member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c ) ? '' : member.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c );
		return add;
	}
	
	public String setPhoneNumber(CFAR_Team_Member_gne__c member) {
		String phone = '';
		phone = String.isBlank(member.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Phone_gne__c) ? 
					(String.isBlank(member.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Mobile_Phone_gne__c) ? 
						(String.isBlank(member.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Alternate_Phone_gne__c) ? '' : member.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Alternate_Phone_gne__c ) :
					member.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Mobile_Phone_gne__c ) :
				member.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Phone_gne__c;
		return phone;
	}
	
    private static String createSubCriteria(String input, String fieldApiname){
        String output = '';
        if(String.isNotBlank(input)){
            output += fieldApiname + ' IN (';
            String [] table = input.split(';');
            for(String s : table){
                output += '\'' + s +'\',';
        	}
            output = output.removeEnd(',');
            output += ') AND ';
        }
        system.debug('output '+output);
        return output;        
    }
    
    private static String createSubCriteria(List<String> input, String fieldApiname){
        String output = '';
        if(!input.isEmpty()){
            output += fieldApiname + ' IN (';
            for(String s : input){
                output += '\'' + s +'\',';
        	}
            output = output.removeEnd(',');
            output += ') AND ';
        }
        system.debug('output '+output);
        return output;        
    }
    
    private static String createNotInCriteria(String input, String fieldApiname){
        String output = '';
        if(String.isNotBlank(input)){
            output += fieldApiname + ' NOT IN (';
            String [] table = input.split(';');
            for(String s : table){
                output += '\'' + s +'\',';
        	}
            output = output.removeEnd(',');
            output += ') AND ';
        }
        return output;        
    }
}