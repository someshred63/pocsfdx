/************************************************************
*  @author: Lukasz Bieniawski
*  Date: 2012-01-15
*  This class controls the threeSixtyDegreeReport
*  Modification History
*  Date        Name        Description
*************************************************************/

public class GNE_SFA2_ThreeSixtyDegreeController{
	
	public GNE_SFA2_ThreeSixtyDegreeController(ApexPages.StandardController controller){}
	
	public static String runThreeSixtyDegreeReport(String accountID){
		if(accountID != null && accountID != ''){
			deleteOldReport();
			generateNewReport(accountID);           
		}        
		// Must to disable 'Grant Access Using Hierarchies'
		String env_list = getGlobalVariable('reportIDFor360Degree');        
		System.debug('env_list: ' + env_list);
		String rptURL = (ApexPages.currentPage()!=null ? ('//' + ApexPages.currentPage().getHeaders().get('Host')) : '') + '/apex/GNE_SFA2_Report_layout?id=' + env_list+'&pv0='+System.UserInfo.getUserId();
		return rptURL;
	}   

	private static void deleteOldReport(){
		List<ThreeSixtyDegreeReport_gne__c> deletedList = [Select Id, UserId_gne__c, OwnerId from ThreeSixtyDegreeReport_gne__c where OwnerId = :System.UserInfo.getUserId()];
		if (deletedList != null && deletedList.size() > 0){          
			System.debug('deletedList: ' + deletedList);
			delete deletedList;
		}       
	}

	private static void generateNewReport(String accountID){
		List<ThreeSixtyDegreeReport_gne__c> threeSixtyDegreeReport_List = new List<ThreeSixtyDegreeReport_gne__c>();
		Set<ID> affiliationAccountIDs = new Set<ID>();      
		List<Affiliation_vod__c> affiliationList = [Select a.Account_No_gne__c, a.CreatedById, a.CreatedDate, a.From_Account_vod__c, a.To_Account_vod__c, a.Id 
													from Affiliation_vod__c a where a.From_Account_vod__c = :accountID OR a.To_Account_vod__c = :accountID];
		
		for(Affiliation_vod__c affiliation: affiliationList){
			affiliationAccountIDs.add(affiliation.From_Account_vod__c);
			affiliationAccountIDs.add(affiliation.To_Account_vod__c);
		}
		affiliationAccountIDs.add(accountID);
		
		List<Contact> contactAccID_List = [Select AccountId from Contact where HCP_gne__c = :accountID];
		for(Contact obj :contactAccID_List ){
			affiliationAccountIDs.add(obj.AccountId);
		}
		
		List<Call2_vod__c> interactionList = [Select Account_vod__c, CreatedById, CreatedDate, CreatedBy.Profile_Name_gne__c, Account_vod__r.Name,
												CreatedBy.Name, CreatedBy.ProfileId, Id, Call_Date_vod__c, Name from Call2_vod__c
												where Account_vod__c IN :affiliationAccountIDs and (Call_Date_vod__c = LAST_90_DAYS OR Call_Date_vod__c = NEXT_90_DAYS ) and Account_vod__c != null];

		for(Call2_vod__c interaction : interactionList ){
			ThreeSixtyDegreeReport_gne__c obj360Report = new ThreeSixtyDegreeReport_gne__c();
			obj360Report.Account_gne__c = interaction.Account_vod__c;
			obj360Report.Interaction_Created_Date_gne__c = interaction.Call_Date_vod__c;
			obj360Report.Interaction_gne__c = interaction.id;
			obj360Report.User_Profile_Name_gne__c = interaction.CreatedBy.Name +' ( '+ interaction.CreatedBy.Profile_Name_gne__c+' ) ';
			threeSixtyDegreeReport_List.add(obj360Report);
		}
		if(!threeSixtyDegreeReport_List.isEmpty()){       
			insert threeSixtyDegreeReport_List;
		}
	}
	
	private static String getGlobalVariable(String key){
		List<Environment_Variables__c> var = [Select Environment__c, Key__c, Value__c from Environment_Variables__c where Key__c = :key and Environment__c =:getEnvironmentName()];
		if(var.size() == 0){ 
			return null;
		} else { 
			return var[0].Value__c;
		}    
	}
	
	private static String getEnvironmentName(){
		String domainName='gene.com';
		String userName = UserInfo.getUserName();
		if(userName.endsWith(domainName)){
			return 'prod';
		} else {
			return userName.substring(userName.indexOf(domainName) + domainName.length() + 1);
		}
	}    
}