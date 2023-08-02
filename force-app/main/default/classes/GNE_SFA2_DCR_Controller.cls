/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-12-21
*  Description: This is a controller class for GNE_SFA2_DCR page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_DCR_Controller extends GNE_SFA2_List_View_Base_Controller {
	
	private static Integer RECORDS_LIMIT = 10000; // Limit for the List items in readOnly mode
	
	public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
	public Boolean isCanadaUser {
		get { return GNE_SFA2_Util.isCanadaUser(); }
	}
    public String iconBase64 { get; private set; }
    
    public GNE_SFA2_DCR_Controller() {
        super('Change_Request_gne__c');
        thisController = this;
        iconBase64	= '/img/icon/custom51_100/pencil32.png';
    }
	
	public List<Change_Request_gne__c> getRecords(){
		String accountRelName = Change_Request_gne__c.Account_gne__c.getDescribe().getRelationshipName();
		String addressRelName = Change_Request_gne__c.Current_Address_gne__c.getDescribe().getRelationshipName();
		
		String selectString = String.format('SELECT Id, Name, CreatedDate, RecordType.Name, {0}, {1}, {2}, {3}, {4} FROM Change_Request_gne__c ',
			new String[]{
				String.valueOf(Change_Request_gne__c.Account_gne__c),	// 0
				String.valueOf(Change_Request_gne__c.Status_gne__c),	// 1
				String.valueOf(Change_Request_gne__c.Status_CS_gne__c),	// 2
				accountRelName + '.Name',								// 3
				addressRelName + '.Name'								// 4
			}
		);
		
		String whereString = 'WHERE ';
		
		if (GNE_SFA2_Util.getCurrentUserProfileName() == 'RCanada-SFA-OPS'){
			whereString += 'CreatedById IN (SELECT Id From User WHERE Profile.Name LIKE \'RCANADA-%\') ';
		} else {
			whereString += String.format('({0} != \'\'Closed\'\' OR CreatedDate = LAST_N_DAYS:180) ',
				new String[]{
					String.valueOf(Change_Request_gne__c.Status_CS_gne__c)	// 0
				}
			);
			//show dcr only if users has access to at lest read account permission: (Account_gne__r.Name != null)  
			whereString += 'AND CreatedById = \'' + UserInfo.getUserId() + '\' AND Account_gne__r.Name != null ';
		}
		
		String orderString = 'ORDER BY CreatedDate DESC LIMIT ' + RECORDS_LIMIT;
		
		String queryString = String.format('{0} {1} {2}',
			new String[]{
				selectString,
				whereString,
				orderString
			}
		);
		
		List<Change_Request_gne__c> result;		
		try {
			result = Database.query(queryString);
		} catch (Exception ex){
			result = new List<Change_Request_gne__c>();			 
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		return result;
	}
}