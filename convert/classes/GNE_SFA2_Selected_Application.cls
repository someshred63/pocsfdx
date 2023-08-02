/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-02-01
*  Description: Represents selected application based on sales roster entries for SFA2 user.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Selected_Application {
	public List<SFA2_User_Sales_Roster_gne__c> userSalesRosters { get; private set; }
    public String brand { get; private set; }
    public String role { get; private set; }
    public String application { get; private set; }
            
    public GNE_SFA2_Selected_Application(List<SFA2_User_Sales_Roster_gne__c> salesRosters){
    	this.userSalesRosters = salesRosters;           
        if (salesRosters != null && salesRosters.size() > 0){
        	this.brand = GNE_SFA2_Util.getUserBrandName(this.userSalesRosters);
            this.role = salesRosters[0].Role_gne__c;
            this.application = salesRosters[0].Sales_Roster_gne__r.type_gne__c;
        }            
    } 
}