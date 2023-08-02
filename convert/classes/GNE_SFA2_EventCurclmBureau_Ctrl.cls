/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-31
*  Description: This is a controller class for GNE_SFA2_EventCurclmBureau_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_EventCurclmBureau_Ctrl extends GNE_SFA2_DynamicVFLoader {   
	public String description{get;set;}

	public GNE_SFA2_EventCurclmBureau_Ctrl(ApexPages.StandardController controller){
		super(controller,'/apex/GNE_SFA2_EventCurclmBureau_Layout');
	}
	
	public PageReference edit() {
		PageReference pageref = new PageReference('/apex/GNE_SFA2_EventCurclmBureau_Edit_Create?id=' + myObject.Id + '&retURL=/apex/GNE_SFA2_EventCurclmBureau_Layout?id=' + myObject.Id);
		pageref.setredirect(true);
		return pageref;
	}
	
	public class BrandsWithIndicationsLists {
		public String Brand { get; private set; }
		public List<String> indicationsList { get; private set; }
		
		public BrandsWithIndicationsLists(String brand, List<String> indicationsList) {
			this.Brand = brand;
			this.indicationsList = indicationsList;
		}
	}
	
	public List<EDM_Event_Curriculum_Brand__c> getBrandsWithIndications() {
		List<EDM_Event_Curriculum_Brand__c> result = [
			SELECT Id, EDM_Brand__c, EDM_Brand_Indications__c 
				FROM EDM_Event_Curriculum_Brand__c 
				WHERE EDM_Parent_Curriculum__c = :myObject.Id
				ORDER BY EDM_Brand__c];

		if (result.isEmpty()) {
			result.add(new EDM_Event_Curriculum_Brand__c(EDM_Brand__c = 'No records'));
		}

		return result;
	}
	
	public List<BrandsWithIndicationsLists> getBrandsWithIndicationsLists() {
		List<BrandsWithIndicationsLists> result = new List<BrandsWithIndicationsLists>();
		
		for (EDM_Event_Curriculum_Brand__c currBrand : getBrandsWithIndications()) {
			if (String.isBlank(currBrand.EDM_Brand_Indications__c)) {
				result.add(new BrandsWithIndicationsLists(currBrand.EDM_Brand__c, new List<String>{'No records'}));
			} else {
				result.add(new BrandsWithIndicationsLists(currBrand.EDM_Brand__c, currBrand.EDM_Brand_Indications__c.split(';')));
			}
		}
		
		return result;
	}
}