/**
* @author ADMD Team
* @date 18/06/2013
* @description gFRS_UnitTestHelperExhibitsOtherPromo class - helper class for Unit Tests. Creates data for tests.
*
*/


public  without sharing class gFRS_UnitTestHelperExhibitsOtherPromo  {
	
	private static id ID_FR_EXHIBITS_OTHER_PROMO = [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Exhibits_Other_Promos'].id;
	
	/**
	* @author: GFRS Dev Team
	* @date: 18/06/2013
	* @description:createExhibitOtherPromosDecisionStep method which create Exhibit other Promo funding request after Decision page step	  
	*/
 	public static GFRS_Funding_Request__c createExhibitOtherPromosDecisionStep(Id orgId, Id locId, User usr)
    {
	    GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
		    recordTypeId = ID_FR_EXHIBITS_OTHER_PROMO,
		    Organization__c = orgId,
		    Location__c = locId,
		    Funding_Sub_Type__c='Sponsorship',
		    Status__c = 'Intake',
            Sub_Status__c = 'Not Submitted',
            External_Sub_status__c = 'Not Submitted',
            Information_Needed__c = 'Organization;Location;Application;Program'
	    );
    
    	insert req;
    
    	return req;
    }
    
    /**
	* @author: GFRS Dev Team
	* @date: 18/06/2013
	* @description:createExhibitOtherPromosAfterApplicationStep method which create Exhibit other Promo funding request with data after Application page
	* sample execution of method: 	 createExhibitOtherPromosAfterApplicationStep(existingOrganizationId, existingLocalizationId, User, 1000,10,10,'Cardiology','Cholesterol','Patient education','Exhibit space') 
	*/
 	public static GFRS_Funding_Request__c createExhibitOtherPromosAfterApplicationStep(Id orgId, Id locId, User usr,Decimal requestedAmount,Decimal refundableAmount,Decimal totalProgramBudget, String tA_Parent,String diseaseState,String eventProgrmaType,String benefits)
    {
	    GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
		    recordTypeId = ID_FR_EXHIBITS_OTHER_PROMO,
		    Organization__c = orgId,
		    Location__c = locId,
		    Funding_Sub_Type__c='Sponsorship',
		    Status__c = 'Intake',
            Sub_Status__c = 'Not Submitted',
            External_Sub_status__c = 'Not Submitted',
            Information_Needed__c = 'Organization;Location;Application;Program',
            Requested_Amount__c=requestedAmount,
            Refundable_Deposit_Amount_if_any__c=refundableAmount,
            Total_Program_Budget__c=totalProgramBudget,
            Therapeutic_Area_Parent__c=tA_Parent,
            Therapeutic_Area__c=diseaseState,
            Event_Project_type__c=eventProgrmaType,
            Event_Program_Title__c='Test Program',
            Support_Purpose_Program_Description__c='Some test description',
            Intended_Audience__c='Some test Audience',
            Other_Commercial_Supporters__c='No',
            Open_to_public__c='No',
            Clinical_Practice_Guideline_Development__c='No',
            Benefits_Exchanged_for_Funding__c='Exhibit space',
            Delivery_Method__c='Vendor',
            Attention_To__c='test Attention',
            Payment_Delivery_Notifications__c=usr.id,
            Send_By_FedEx_cost_center_will_be_charg__c='No',
            Finance_Managers__c='Alexandra Schuman (alehr)',
            Entering_on_Behalf_of_Another__c='No'
	    );
    
    	insert req;
        updateFundingAllocationLineItem(req.id);
    	return req;
    }
    
    /**
	* @author: GFRS Dev Team
	* @date: 19/06/2013
	* @description:createExhibitOtherPromosAfterProgramStep method which create Exhibit other Promo funding request with data after Progrma page - all data for program will be filled.
	* sample execution of method: 	 createExhibitOtherPromosAfterProgramStep(existingOrganizationId, existingLocalizationId, User, 1000,10,10,'Cardiology','Cholesterol','Patient education','Exhibit space',Date.today()+60,Date.today()+61,10,10,Actemra,'US Booth','Not Applicable',20,'VenueName','VenueCity','23-345','United States','IN')  
	*/
	
 	public static GFRS_Funding_Request__c createExhibitOtherPromosAfterProgramStep(Id orgId, Id locId, User usr,Decimal requestedAmount,Decimal refundableAmount,Decimal totalProgramBudget, String tA_Parent,String diseaseState,String eventProgrmaType,String benefits,Date programStartDate,Date programEndDate,Integer expectedNumOfAttendess,Integer expectedNumOfAttendesHCP,String programBeingPromoted,String boothType,String sizeOfExhibits,Integer actualTimeInHours,String venueName,String venueCity,String venueZipCode,String venueCountry,String venueState){
 		
 		GFRS_Funding_Request__c request=createExhibitOtherPromosAfterApplicationStep(orgId, locId, usr, requestedAmount, refundableAmount, totalProgramBudget, tA_Parent, diseaseState, eventProgrmaType, benefits);
 		List<GFRS_Program__c> programList=gFRS_DAO.getProgramListByRequestId(request.id);
 		for(GFRS_Program__c program:programList){ 
 			program.Start_Date__c=programStartDate; 
			program.End_Date__c=programEndDate; 
			program.Expected_Number_of_Attendees__c=expectedNumOfAttendess;
			program.Expected_of_Attendees_US_Based_HCPs__c=expectedNumOfAttendesHCP;
			program.Product_being_Promoted__c=programBeingPromoted;
			program.Booth_Type__c=boothType;
			program.Size_of_Exhibit__c=sizeOfExhibits;
			program.Actual_Time_at_Display_Table_Hours__c=actualTimeInHours;
			program.Venue_Name__c=venueName;
			program.Venue_City__c=venueCity;
			program.Venue_Zip_Code__c=venueZipCode;
			program.Venue_Country__c=venueCountry;
			program.Venue_State__c=venueState;
 		}
 		if(programList.size()>0){
 			update programList;
 		}
 		return request;
 	}
 	
 	
 	/**
	* @author: GFRS Dev Team
	* @date: 19/06/2013
	* @description:createExhibitOtherPromosAfterConfirmationStep method which create Exhibit other Promo funding request with data after Progrma page - all data for program will be filled.
	* sample execution of method: 	 createExhibitOtherPromosAfterConfirmationStep(existingOrganizationId, existingLocalizationId, User, 1000,10,10,'Cardiology','Cholesterol','Patient education','Exhibit space',Date.today()+60,Date.today()+61,10,10,Actemra,'US Booth','Not Applicable',20,'VenueName','VenueCity','23-345','United States','IN')  
	*/
	
 	public static GFRS_Funding_Request__c createExhibitOtherPromosAfterConfirmationStep(Id orgId, Id locId, User usr,Decimal requestedAmount,Decimal refundableAmount,Decimal totalProgramBudget, String tA_Parent,String diseaseState,String eventProgrmaType,String benefits,Date programStartDate,Date programEndDate,Integer expectedNumOfAttendess,Integer expectedNumOfAttendesHCP,String programBeingPromoted,String boothType,String sizeOfExhibits,Integer actualTimeInHours,String venueName,String venueCity,String venueZipCode,String venueCountry,String venueState){
 		GFRS_Funding_Request__c request=createExhibitOtherPromosAfterProgramStep(orgId, locId, usr,requestedAmount,refundableAmount,totalProgramBudget,tA_Parent,diseaseState,eventProgrmaType,benefits,programStartDate,programEndDate,expectedNumOfAttendess,expectedNumOfAttendesHCP,programBeingPromoted,boothType,sizeOfExhibits,actualTimeInHours,venueName,venueCity,venueZipCode,venueCountry,venueState);
 		request.Signing_Authority_Email__c=usr.Email;
 		request.Signing_Authority_First_Name__c=usr.FirstName;
 		request.Signing_Authority_Last_Name__c=usr.LastName;
 		update request;
 		
 		return request;
 	}
    
    /**
	* @author: GFRS Dev Team
	* @date: 18/06/2013
	* @description:updateFundingAllocationLineItem method which updating wbs code and cost center under Funding allocation line items. 
	* This information is populated under application portal page on section "Allocation Items"	  
	*/
	
     public static void updateFundingAllocationLineItem(Id requestID){
     	List<GFRS_Funding_Allocation_Line_Item__c> allocationLineItemsList=gFRS_DAO.getAllocationLineItemListByRequestId(requestID);
     	List<GFRS_WBS_Codes__c> wbsList=gFRS_DAO.getWBSCodeList('1010');
     	List<GFRS_Cost_Center_Code__c> costCenterList=gFRS_DAO.getCostCenterList('1010');
     	try{
	     	for(GFRS_Funding_Allocation_Line_Item__c item:allocationLineItemsList){
	     		item.Cost_Center_Lookup__c=costCenterList[0].id;
	     		item.WBS_Code_Lookup__c=wbsList[0].id;
	     	}
     	}catch(Exception ex){
     		system.debug('exception occurs probably data is not proper WBS Code and Cost Center');
     	}
     	if(allocationLineItemsList.size()>0){
     		update allocationLineItemsList;
     	}
     }
}