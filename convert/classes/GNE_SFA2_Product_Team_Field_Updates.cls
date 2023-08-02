public with sharing class GNE_SFA2_Product_Team_Field_Updates {
	
	
	
	public static void onBeforeInsert(List<Speaker_Bureau_Product_gne__c> triggerNewList){
		
		updateSpeakerProduct(triggerNewList);
	} 
	
	
	public static void onBeforeUpdate(List<Speaker_Bureau_Product_gne__c> triggerNewList){
		
		updateSpeakerProduct(triggerNewList);
	}
	
	public static void onAfterInsert(List<Speaker_Bureau_Product_gne__c> triggerNewList){
		upsertBrandAffiliations(triggerNewList);
	}
	
	public static void onAfterUpdate(List<Speaker_Bureau_Product_gne__c> triggerNewList){
		
		upsertBrandAffiliations(triggerNewList);
	}
	
	
	 
	public static void updateSpeakerProduct(List<Speaker_Bureau_Product_gne__c> triggerNewList){
		
		for (Speaker_Bureau_Product_gne__c objSPeakrBureauProduct : triggerNewList) { 
			if(objSPeakrBureauProduct.Product_vod_gne__c != null && objSPeakrBureauProduct.Speaker_Bureau_gne__c!=null){
				objSPeakrBureauProduct.Speaker_Product_value_gne__c = objSPeakrBureauProduct.Unique_Key_Calc_gne__c;       
			} else if(objSPeakrBureauProduct.Product_vod_gne__c == null || objSPeakrBureauProduct.Speaker_Bureau_gne__c==null){
				objSPeakrBureauProduct.addError(System.Label.Product_Tem_RequiredFields);
			}
		}
	}
	
		public static void upsertBrandAffiliations(List<Speaker_Bureau_Product_gne__c> triggerNewList){
		
		List<String> speakerBureauIDList = new List<String>();
		List<String> productIDList = new List<String>();
		List<String> speakerID_List = new List<String>();
		List<String> speakerContract_List = new List<String>();
		Date endDate = null;
		Map<String,Date> accountID_Date_Map = new Map<String,Date>();
		for (Integer i = 0 ;  i < triggerNewList.size(); i++)  { 
			speakerBureauIDList.add(triggerNewList[i].Speaker_Bureau_gne__c);
			productIDList.add(triggerNewList[i].Product_vod_gne__c);
		}
		//System.debug('Sud speakerBureauIDList: ' + speakerBureauIDList);
		for(Speaker_Bureau_Membership_gne__c speakerID : [Select Bureau_Member_gne__c from Speaker_Bureau_Membership_gne__c where Speaker_Bureau_ID_gne__c IN:speakerBureauIDList]){
			speakerID_List.add(speakerID.Bureau_Member_gne__c);
		}
		for(Speaker_Contract_gne__c spkr_Contract : [Select Begin_Date_gne__c, Contracted_Party_ID__c, End_Date_gne__c from Speaker_Contract_gne__c where Contracted_Party_ID__c IN:speakerID_List]){
			endDate = spkr_Contract.End_Date_gne__c; 
			endDate = date.newinstance(endDate.year(), endDate.month(), endDate.day()); 
			accountID_Date_Map.put(spkr_Contract.Contracted_Party_ID__c,endDate); 
		}
		UpsertBrandAffiliations.update_InsertSpContractBrandAff_beforeInsertUpdate(accountID_Date_Map); 
	}
}