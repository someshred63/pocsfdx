// Added By: Deepak Yadav
// Collection class for Fulfillment_gne__c table
public virtual class SCM_MF_FulFillmentCollection extends SCM_MergeField {

	protected Fulfillment_gne__c fulfillmentRecord;	
 	private static List<Fulfillment_gne__c>fulFillList;
	public SCM_MF_FulFillmentCollection(String caseId) {
		
		//Extract records	   
	 	if(fulFillList==null)
	 	{
		fulFillList = [Select   f.In_network_name_gne__c , 
							    f.Out_network_name_gne__c, 
							    f.In_Network_Selected_Distributor_gne__c, 
								f.Out_Network_Selected_Distributor_gne__c, 
								f.In_network_Contact_Name_gne__c, 
								f.Out_network_Contact_Name_gne__c,
								f.In_network_Fax_Number_gne__c,
								f.Out_network_Fax_Number_gne__c ,
								f.In_network_name_gne__r.Name ,
								f.Out_network_Name_gne__r.Name,
								f.Out_network_Phone_Number_gne__c,
								f.In_network_Phone_Number_gne__c
		From Fulfillment_gne__c f 
		Where f.Case_Fulfillment_gne__c = :caseId 
		order by f.LastModifiedDate desc limit 100 ];
	 	}
		if(fulFillList.size() >= 1) {	
			fulfillmentRecord = fulFillList[0];
		}
		else {			
			fulfillmentRecord =  null ;
		}	
		   
	}
}