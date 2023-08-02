/*********************************************************************************************
*  @author: Michal Hrycenko, Roche (contractor)
*  @email: michal.hrycenko@contractors.roche.com   
*  Created: 2013-07-22
*  Project: OTR2
*  Description: REST Webservice, returns a list of TASubTA for which there is no available MSLs.             
**********************************************************************************************/
@RestResource(urlMapping='/iPhoneGetTASubTANotSuppAutoAsgmt/*')
global with sharing class iPhone_Get_TASubTA_NotSupp_AutoAsgmt_gne {

	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetTATASubTANotSupportAutoAsgmtResponseBuilder(),
	    		unixId    		
    	);     	     	    	 
    }
    
    public without sharing class GetTATASubTANotSupportAutoAsgmtResponseBuilder implements iPhone_Commons_gne.ResponseBuilder { 
    	
    	public iPhone_Commons_gne.RestResponse build(Object args) {
    		String unixId = (String)args;
    		User user = iPhone_DAO.getUserByExternalId(unixId);
    		List<Product_vod__c> tASubTAsList = getTASubTA();
    		system.debug('tASubTAsList.size: '+tASubTAsList.size());
    		
    		return new GetTATASubTANotSupportAutoAsgmtResponse(prepareTASubTANotSupportAutoAsgmtList(user, tASubTAsList));
    	}
    	
    	/**
			Get all available TASubTA. 
		*/
    	
    	private List<Product_vod__c> getTASubTA() {
    		List<String> productOwnerQueueNames = new List<String>{'GNE-SFA-CANADA-Queue','GNE-INACTIVE-PROD-QUEUE'};
    		List<Id> productOwnerQueueId = GNE_Referral_Utils.getProductOwnerQueueId(productOwnerQueueNames);
    		List<String> medAffairsMoleculeNames = GNE_Referral_Utils.getRestrictedProductName();
    		
    		List<Product_vod__c> tempList;
    		List<Product_vod__c> tASubTAsList = new List<Product_vod__c>();
    		if(productOwnerQueueId.size() > 0) {
    			tempList = getAllProductsForMedAffairsMoleculeNames(productOwnerQueueId, medAffairsMoleculeNames);
    		} else {
    			tempList = getAllProductsForMedAffairsMoleculeNames(medAffairsMoleculeNames);
    		}
    		
    		if(!tempList.isEmpty()) {
    			for(Product_vod__c prod : tempList) {
    				tASubTAsList.add(prod);
    			}
    		}
    		return tASubTAsList;
    	}
    	
    	public List<Product_vod__c> getAllProductsForMedAffairsMoleculeNames(List<Id> productOwnerQueueId, List<String> medAffairsMoleculeNames) {
			return [
				SELECT
					Id, Name
				FROM 
					Product_vod__c 
				WHERE 
					Name NOT IN : medAffairsMoleculeNames 
					AND OwnerId NOT IN : ProductOwnerQueueId
					AND Product_Type_vod__c = 'Detail'
					AND Detail_Product_Subtype_Code_gne__c = 'TheraDisease'
				ORDER BY Name
			];
		}
		
		public List<Product_vod__c> getAllProductsForMedAffairsMoleculeNames(List<String> medAffairsMoleculeNames) {
			return [
				SELECT
					Id, Name
				FROM 
					Product_vod__c 
				WHERE 
						Name NOT IN : medAffairsMoleculeNames
					AND Product_Type_vod__c = 'Detail'
					AND Detail_Product_Subtype_Code_gne__c = 'TheraDisease' 
				ORDER BY Name
			];
		}
		
		public List<Product_vod__c> getOtherTaSubTas(Set<String> otherTaSubTaNamesList) {
			return [
				SELECT
					Id, Name
				FROM 
					Product_vod__c 
				WHERE 
					Name IN : otherTaSubTaNamesList
				ORDER BY Name
			];
		}
    	
    	/**
			Prepare autoassignment list based on current user, TASubTAs. List contains TASubTAs Ids for which there is no available MSLs.
			Note: If there is no MSL available for i.e. Ophthamology � Uveitis TASubTA, then we search for MSLs for Ophthamology � Other TASubTA
			and if there is MSL for this TASubTA found, then all Ophthamology - ... TASubTAs are not being returned.
		*/
    	private Set<Id> prepareTASubTANotSupportAutoAsgmtList(User user, List<Product_vod__c> tASubTAsList) {
    		Set<Id> tASubTANotSupportAutoAsgmt = new Set<Id>();
			Map<String, List<Id>> allOtherTaSubTasMap = new Map<String, List<Id>>();
			List<Product_vod__c> tASubTANotSupportAutoAsgmtProdList = new List<Product_vod__c>();

    		
    		if (user !=null && (user.Profile_Name_gne__c == 'GNE-MedAffairs-MCL' || user.Profile_Name_gne__c == 'GNE-MedAffairs-MCL-Manager')){
                User mclManager = iPhone_DAO.getUserByAlias(System.Label.GNE_MCL_Manager);
                if(mclManager == null) {
                	for(Product_vod__c product : tASubTAsList){
                		tASubTANotSupportAutoAsgmt.add(product.Id);
                	}
                	return tASubTANotSupportAutoAsgmt;
                }             
            } else {
            	Set<String> taSubTAFromReferralRosterDetail = new Set<String>();
            	
            	for(Referral_Roster_Detail_gne__c refRosDet : iPhone_DAO.getAllReferralRosterDetails(tASubTAsList)) {
            		taSubTAFromReferralRosterDetail.add(refRosDet.Product_TA_SubTA_gne__c);
            	}
            	
            	for(Product_vod__c prod : tASubTAsList) {
            		if(!taSubTAFromReferralRosterDetail.contains(prod.id)) {
            			tASubTANotSupportAutoAsgmt.add(prod.id);
            			tASubTANotSupportAutoAsgmtProdList.add(prod);
            		}
            	}
    		}			
    		
    		for(Product_vod__c taSubTaProduct : tASubTANotSupportAutoAsgmtProdList){
    			if(taSubTaProduct.Name != null && taSubTaProduct.Name.indexOf('-') != -1){
    				String tmpOtherProductName = taSubTaProduct.Name.substring(0, taSubTaProduct.Name.indexOf('-')) + '- Other';
    				if(!allOtherTaSubTasMap.containsKey(tmpOtherProductName)){
						List<Id> tmpTaSubTaIdList = new List<Id>();
						tmpTaSubTaIdList.add(taSubTaProduct.Id);
						allOtherTaSubTasMap.put(tmpOtherProductName, tmpTaSubTaIdList);
					}else{
						allOtherTaSubTasMap.get(tmpOtherProductName).add(taSubTaProduct.Id);
					}
    			}
    		}
    		
    		List<Product_vod__c> otherTaSubTAsQueriedList = getOtherTaSubTas(allOtherTaSubTasMap.keySet());
    		
    		List<Referral_Roster_Detail_gne__c> otherReferralRosterDetails = iPhone_DAO.getAllReferralRosterDetails(otherTaSubTAsQueriedList);
        	
        	Set<String> otherTaSubTAFromReferralRosterDetail = new Set<String>();
        	
        	for(Referral_Roster_Detail_gne__c refRosDet : otherReferralRosterDetails) {
        		otherTaSubTAFromReferralRosterDetail.add(refRosDet.Product_TA_SubTA_gne__c);
        	}
        	
        	for(Product_vod__c prod : otherTaSubTAsQueriedList) {
        		if(otherTaSubTAFromReferralRosterDetail.contains(prod.id)) {
	        		for(Id idToRemove : allOtherTaSubTasMap.get(prod.Name)){
	        			tASubTANotSupportAutoAsgmt.remove(idToRemove);
	        		}
        		}
        	}
    		return tASubTANotSupportAutoAsgmt;
    	}    	       	
    }
    
    class GetTATASubTANotSupportAutoAsgmtResponse extends iPhone_Commons_gne.RestResponse {
    	
    	public Set<Id> tASubTANotSupportAutoAsgmtList;
    	
    	public GetTATASubTANotSupportAutoAsgmtResponse(Set<Id> tASubTANotSupportAutoAsgmtList) {
    		this.tASubTANotSupportAutoAsgmtList = tASubTANotSupportAutoAsgmtList;
    	}
    }
}