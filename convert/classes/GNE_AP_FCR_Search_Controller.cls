public without sharing  class GNE_AP_FCR_Search_Controller {
	
	public static final List<String> feProfileMatches = new List<String>{'GNE-SFA-%-CS', 'GNE-SFA%PS', 'GNE-SFA%Specialist'};
	private static final String ARCHIVED_STATUS = GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS);
	private static final String ARCHIVED_AP_STATUS = 'Archived';

	public Id dayPlanId {get; set;}
	public String sInputValue {get; set;}
	public List<FCR_AP_Wrapper> wrapps {get;set;}
	public Boolean isAdvancedSearch {get;set;}
	public String dateFrom {get;set;}
	public String dateTo {get;set;}
	public List<String> pickedFRs {get;set;}
	public List<String> pickedFEs {get;set;}
	private String advancedParameters {get; set;}
	private String advancedReferencedParameters {get; set;}
	private String advancedAPParameters {get; set;}
	private String advancedAPReferencedParameters {get; set;}
	private Date dFrom {get; set;}
	private Date dTo {get; set;}
	
		
		public GNE_AP_FCR_Search_Controller(){
			wrapps = new List<FCR_AP_Wrapper>();
		}
		
		private  Boolean isNotLeadingObject(SObject ob){
			return (Schema.AP_Account_Planning_gne__c.getSobjectType() != ob.getSobjectType() && Schema.FCR_Days_Plan_gne__c.getSobjectType() != ob.getSobjectType() );
		}
		
		public PageReference simpleSearch(){
			try{
					if((!isAdvancedSearch && isQueryInputValid(sInputValue)) || (isQueryInputValid(sInputValue) && areDatesValid())){
						prepareQueryParameters();
						String input = '*"'+sInputValue+'"*';
						String queryString = 'FIND \'( '+input+' )\' IN ALL FIELDS RETURNING FCR_Days_Plan_gne__c(Territory_Name_gne__c,DM_Action_Plan__c,DM_Comments_gne__c,Field_Objectives_gne__c,GPM_Objective_Comments_gne__c, CS_user_gne__r.name, Date_Field_Visit_gne__c,FR_User_gne__r.name WHERE status_gne__c = \''+ARCHIVED_STATUS+'\' '+advancedParameters+' )'
						+', FCR_DaysPlan_Job_Competency_gne__c (Assess_Comments_gne__c, Clarify_Comments_gne__c, Execute_Comments_gne__c,FCR_Days_Plan_gne__c,FCR_Days_Plan_gne__r.CS_User_gne__r.name,FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c,FCR_Days_Plan_gne__r.FR_User_gne__r.name, FCR_Days_Plan_gne__r.status_gne__c, FCR_Days_Plan_gne__r.Territory_Name_gne__c WHERE FCR_Days_Plan_gne__r.status_gne__c = \''+ARCHIVED_STATUS+'\' '+advancedReferencedParameters+')'
						+',FCR_Action_Plan_gne__c (Description_gne__c ,FCR_Days_Plan_gne__c,FCR_Days_Plan_gne__r.CS_User_gne__r.name,FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c,FCR_Days_Plan_gne__r.FR_User_gne__r.name, FCR_Days_Plan_gne__r.Territory_Name_gne__c WHERE FCR_Days_Plan_gne__r.status_gne__c = \''+ARCHIVED_STATUS+'\' '+advancedReferencedParameters+')'
						+',FCR_Days_Objective_gne__c (Objective_gne__c ,FCR_Days_Plan_gne__c,FCR_Days_Plan_gne__r.CS_User_gne__r.name,FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c,FCR_Days_Plan_gne__r.FR_User_gne__r.name,  FCR_Days_Plan_gne__r.Territory_Name_gne__c WHERE FCR_Days_Plan_gne__r.status_gne__c = \''+ARCHIVED_STATUS+'\' '+advancedReferencedParameters+')'
						+',AP_Account_Planning_gne__c (CreatedDate, CS_User_gne__r.name, DM_User_gne__r.name WHERE status_gne__c = \''+ARCHIVED_AP_STATUS+'\' )'
						+',AP_Territory_Planning_gne__c (AP_Account_Planning_gne__r.CreatedDate, AP_Account_Planning_gne__r.CS_User_gne__r.name, AP_Account_Planning_gne__r.DM_User_gne__r.name WHERE AP_Account_Planning_gne__r.status_gne__c = \''+ARCHIVED_AP_STATUS+'\' )'
						+',AP_Detail_gne__c (AP_Account_Planning_gne__r.CreatedDate, AP_Account_Planning_gne__r.CS_User_gne__r.name, AP_Account_Planning_gne__r.DM_User_gne__r.name, resource_gne__c WHERE AP_Account_Planning_gne__r.status_gne__c = \''+ARCHIVED_AP_STATUS+'\' )'
						+',AP_Account_User_gne__c (AP_Account_Planning_gne__r.CreatedDate, AP_Account_Planning_gne__r.CS_User_gne__r.name, AP_Account_Planning_gne__r.DM_User_gne__r.name WHERE AP_Account_Planning_gne__r.status_gne__c = \''+ARCHIVED_AP_STATUS+'\' )';
						List<List<SObject>> objects = search.query(queryString);
						wrapps = new List<FCR_AP_Wrapper>();
						Set<Id> resultIds = new Set<Id>();
						Id obId;
						for(Integer i = 0; i < objects.size(); i++){
							for(SObject ob : objects[i]){
									if(i==0){
										if(!resultIds.contains(obId=(Id)ob.get('id'))){
											wrapps.add(new FCR_AP_Wrapper((FCR_Days_Plan_gne__c)ob));
											resultIds.add(obId);
										}
									}else if( i==1 || i==2 || i==3 ){
										if(!resultIds.contains(obId=(Id)ob.get('FCR_Days_Plan_gne__c'))){
											wrapps.add(new FCR_AP_Wrapper((FCR_Days_Plan_gne__c)ob.getSobject('FCR_Days_Plan_gne__r')));
											resultIds.add(obId);
										}
									}else if(i==4){
										if(!resultIds.contains(obId=(Id)ob.get('id'))){
											wrapps.add(new FCR_AP_Wrapper((AP_Account_Planning_gne__c)ob));
											resultIds.add(obId);
										}
									}else{
										if(!resultIds.contains(obId=(Id)ob.get('AP_Account_Planning_gne__c'))){
											wrapps.add(new FCR_AP_Wrapper((AP_Account_Planning_gne__c)ob.getSobject('AP_Account_Planning_gne__r')));
											resultIds.add(obId);
										}
									}
							}
						}
				}
				return null;
			}catch(Exception e){
				PageReference pr = Page.GNE_FCR_Error;
				pr.getParameters().put('exMessage',e.getMessage());
				return pr;
			}
		}
		
		private Boolean isQueryInputValid(String input){
			input = input.replaceAll('"','');
			if(String.isBlank(input) || input.length()<2){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_FCR_Search_Text_Validation));
				return false;
			}else{
				return true;
			}
		}
		
		private void parseDates(){
			dFrom = null;
			dTo=null;
			if(!String.isBlank(dateFrom)){
				dFrom = Date.parse(dateFrom);
			}
			if(!String.isBlank(dateTo)){
				 dTo = Date.parse(dateTo);
			}
		}
		
		private Boolean areDatesValid(){
			if((!String.isBlank(dateFrom) && !GNE_FCR_Util.isDateStringValid(dateFrom)) || (!String.isBlank(dateTo) && !GNE_FCR_Util.isDateStringValid(dateTo))){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_FCR_Date_Format_Validation));
				return false;
			}
			parseDates();
			if(dFrom!=null && dTo!=null && dFrom > dTo){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_FCR_Dates_Validation));
				return false;
			}
			return true;
		}
			
		private void prepareQueryParameters(){
			advancedParameters ='';
			advancedReferencedParameters ='';
			if(isAdvancedSearch){
				if(pickedFEs != null && !pickedFEs.isEmpty()){
				 advancedParameters+= ' AND CS_User_gne__c IN :pickedFEs';
				 advancedReferencedParameters+=' AND FCR_Days_Plan_gne__r.CS_User_gne__c IN :pickedFEs';
				 advancedAPParameters += 'AND CS_User_gne__c IN :pickedFEs';
				 advancedAPReferencedParameters += 'AND AP_Account_Planning_gne__r.CS_User_gne__c IN :pickedFEs';
				}
				if(pickedFRs!=null && !pickedFRs.isEmpty()){
					advancedParameters+= ' AND FR_User_gne__c IN :pickedFRs';
					advancedReferencedParameters+=' AND FCR_Days_Plan_gne__r.FR_User_gne__c IN :pickedFRs';
					advancedAPParameters += 'AND DM_User_gne__c IN :pickedFRs';
				 	advancedAPReferencedParameters += 'AND AP_Account_Planning_gne__r.DM_User_gne__c IN :pickedFRs';
				}
				if(dFrom!=null){
					advancedParameters+= ' AND Date_Field_Visit_gne__c >= :dFrom';
					advancedReferencedParameters+=' AND FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c >= :dFrom';
					advancedAPParameters += 'AND CreatedDate >= :dFrom';
				 	advancedAPReferencedParameters += 'AND AP_Account_Planning_gne__r.CreatedDate >= :dFrom';
				}
				if(dTo!=null){
					advancedParameters+= ' AND Date_Field_Visit_gne__c <= :dTo';
					advancedReferencedParameters+=' AND FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c <= :dTo';
					advancedAPParameters += 'AND CreatedDate <= :dTo';
				 	advancedAPReferencedParameters += 'AND AP_Account_Planning_gne__r.CreatedDate <= :dTo';
				}
			}
			
		}
		
		
		public List<SelectOption> getAvailableFRs(){
			List<SelectOption> frs = new List<SelectOption>();
			for(User u: GNE_FCR_DAO.getAvailableFRs(UserInfo.getUserId())){
				frs.add(new SelectOption(u.id, u.name));
			}
			return frs;
		}
		
		public List<SelectOption> getAvailableFEs(){
			List<SelectOption> results = new List<SelectOption>();
			Set<Id> distinctUsers = new Set<Id>();
			for(List<FCR_Days_Plan_gne__c> fcrs : [SELECT CS_user_gne__r.name, CS_user_gne__c FROM FCR_Days_Plan_gne__c ]){
				for(FCR_Days_Plan_gne__c fcr : fcrs){
					if(!distinctUsers.contains(fcr.CS_user_gne__c)){
						distinctUsers.add(fcr.CS_user_gne__c);
						results.add(new SelectOption(fcr.CS_user_gne__c, fcr.CS_user_gne__r.name));
					}
				}
			}
			return results;
		}
		
		public class FCR_AP_Wrapper{
			public Id id {get;private set;}
			public String fr {get;private set;}
			public String fe {get;private set;}
			public String feId {get;private set;}
			public String frId {get;private set;}
			public String territory {get;private set;}
			public Date wrapperDate {get;private set;}
			public Boolean isFCR {get;private set;}
			
			public FCR_AP_Wrapper(FCR_Days_Plan_gne__c fcr){
				id = fcr.id;
				fr = fcr.FR_User_gne__r.name;
				fe = fcr.CS_User_gne__r.name;
				feId = fcr.CS_User_gne__c;
				frId = fcr.FR_User_gne__c;
				territory = fcr.Territory_Name_gne__c;
				wrapperDate = fcr.Date_Field_Visit_gne__c;
				isFCR = true;
			}
			
			public FCR_AP_Wrapper(AP_Account_Planning_gne__c ap){
				id = ap.id;
				frId=ap.DM_User_gne__c;
				feId=ap.CS_User_gne__c;
				fr = ap.DM_User_gne__r.name;
				fe = ap.CS_User_gne__r.name;
				territory='';
				if(ap.AP_Territory_Plannings__r.size()>0){
					territory = ap.AP_Territory_Plannings__r.get(0).Territory_Name_gne__c;
				}
				wrapperDate = ap.CreatedDate.date();
				isFCR=false;
			}
		}
}