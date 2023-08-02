/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-11-14
*  Description: This is a wrapper class used for GNE_SFA2_Calendar component
*  
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public with sharing class GNE_SFA2_Calendar_Item {
	public Id itemId { get; set; }
	public String itemDate { get; set; }
	public String itemDescription { get; set; }
	
	public GNE_SFA2_Calendar_Item(String itemId, String itemDate, String itemDescription) {
		this.itemId = itemId;
		this.itemDate = itemDate;
		this.itemDescription = itemDescription;
	}
}