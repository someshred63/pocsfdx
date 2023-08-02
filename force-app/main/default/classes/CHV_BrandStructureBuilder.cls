public with sharing class CHV_BrandStructureBuilder {

	public static CHV_BrandBaseWrapper buildWrapper(CHV_Brand__c brand, Datetime luDate){
		
		List<Document> brandDocuments = new List<Document>();
		if (luDate != null) {
			Set<String> brandImagesIds = new Set<String>();
			brandImagesIds.add(CHV_Utils.getImageId(brand.Distribution_Model_Diagram_URL__c));
			brandImagesIds.add(CHV_Utils.getImageId(brand.iPad_Brand_Logo_HD_URL__c));
			brandImagesIds.add(CHV_Utils.getImageId(brand.iPad_Brand_Logo_SD_URL__c));
			brandImagesIds.add(CHV_Utils.getImageId(brand.iPhone_Brand_Logo_HD_URL__c));
			brandImagesIds.add(CHV_Utils.getImageId(brand.iPhone_Brand_Logo_SD_URL__c));
			brandImagesIds.remove(null);
			//only brand images modified after luDate
			brandDocuments = [select Id from Document where Id in :brandImagesIds and LastModifiedDate > :luDate];
		}
		
		CHV_BrandBaseWrapper brandW = (needFullObject(brand, luDate) || !brandDocuments.isEmpty()) ? new CHV_BrandWrapper(brand) : new CHV_BrandBaseWrapper(brand);
		String brandId = brandW.brandId;
		
		//----------6
		List<CHV_Talking_Point__c> tps = [SELECT Id, Name, Content__c, LastModifiedDate 
										  FROM CHV_Talking_Point__c 
										  WHERE Brand__c =: brandId];
		
		//----------5
		List<CHV_Brand_Customer_Access__c> bcas = [SELECT Id, Name, Brand_Customer_Access_Displayed_Name__c, Customer_Access__c, Brand__c, Notes__c, LastModifiedDate 
												   FROM CHV_Brand_Customer_Access__c 
												   WHERE Brand__c =: brandId];
		List<String> customerAccessesId = new List<String>();
		List<String> brandCustomerAccessesId = new List<String>();
		for (CHV_Brand_Customer_Access__c bca : bcas){
			customerAccessesId.add(bca.Customer_Access__c);
			brandCustomerAccessesId.add(bca.Id);
		}
		
		//----------4
		List<CHV_Customer_Access__c> cas = [SELECT Id, Name, Access_Icon_HD_URL__c, Access_Icon_SD_URL__c, Notes__c, LastModifiedDate 
											FROM CHV_Customer_Access__c 
											WHERE Id IN : customerAccessesId];
		
		//----------3
		List<CHV_Brand_Customer_Access_Distributor__c> bcads = [SELECT Id, Name, Authorized_Distributor_Note__c, Authorized_Distributor__c, Brand_Customer_Access__c, LastModifiedDate 
																FROM CHV_Brand_Customer_Access_Distributor__c 
																WHERE Brand_Customer_Access__c IN : brandCustomerAccessesId];
		List<String> authorizedDistributorsId = new List<String>();
		for (CHV_Brand_Customer_Access_Distributor__c bcad : bcads){
			authorizedDistributorsId.add(bcad.Authorized_Distributor__c);
		}
		
		//-----------2
		List<CHV_Authorized_Distributor__c> ads = [SELECT Id, Name, Corporate_URL__c, Corporate_Phone__c, Corporate_Fax__c, Account_Manager__c, LastModifiedDate 
												   FROM CHV_Authorized_Distributor__c 
												   WHERE Id IN : authorizedDistributorsId];
		List<String> accountManagersId = new List<String>();
		for (CHV_Authorized_Distributor__c ad : ads){
			accountManagersId.add(ad.Account_Manager__c);
		}
		
		//-----------1
		List<CHV_Account_Manager__c> ams = [SELECT Id, Name, Photo_URL__c, Email_ID__c, Desk_Phone__c, Cell_Phone__c, LastModifiedDate 
											FROM CHV_Account_Manager__c 
											WHERE Id IN : accountManagersId];
											
		//wwwwwwwwwww1
		Map<String, CHV_AccountManagerBaseWrapper> accountManagers = new Map<String, CHV_AccountManagerBaseWrapper>();
		
		Map<String,String> amIdToImageId = new Map<String,String>();
		Set<String> affectedAMs = new Set<String>();
		if (luDate != null) {
			for (CHV_Account_Manager__c am : ams) {
				amIdToImageId.put(am.Id, CHV_Utils.getImageId(am.Photo_URL__c));
			}
			if (!amIdToImageId.isEmpty()) {
				Map<Id,Document> amDocumentsMap = new Map<Id,Document>([select Id from Document where Id in :amIdToImageId.values() and LastModifiedDate > :luDate]);
				if (amDocumentsMap != null && !amDocumentsMap.isEmpty()) {
					for (String amId : amIdToImageId.keySet()) {
						if (amIdToImageId.get(amId) != null && amDocumentsMap.get(Id.valueOf(amIdToImageId.get(amId))) != null) {
							affectedAMs.add(amId);
						}
					}
				}
			}
		}
		
		for (CHV_Account_Manager__c am : ams){
			accountManagers.put(am.Id, (needFullObject(am, luDate) || affectedAMs.contains(am.Id)) ? new CHV_AccountManagerWrapper(am) : new CHV_AccountManagerBaseWrapper(am));
		}
		
		//wwwwwwwwwww2
		Map<String, CHV_AuthorizedDistributorBaseWrapper> authorizedDistributors = new Map<String, CHV_AuthorizedDistributorBaseWrapper>();
		for (CHV_Authorized_Distributor__c ad : ads){
			CHV_AuthorizedDistributorBaseWrapper adw = needFullObject(ad, luDate) ? new CHV_AuthorizedDistributorWrapper(ad) : new CHV_AuthorizedDistributorBaseWrapper(ad);
			adw.accountManager = accountManagers.get(ad.Account_Manager__c);
			authorizedDistributors.put(ad.Id, adw);
		}		
		
		//wwwwwwwwwww3
		Map<String, List<CHV_BrandCustAccessDistributBaseWrapper>> brandCustAccessDistributors = new Map<String, List<CHV_BrandCustAccessDistributBaseWrapper>>();
		for (CHV_Brand_Customer_Access_Distributor__c bcad : bcads){
			if (!brandCustAccessDistributors.containsKey(bcad.Brand_Customer_Access__c)){
				brandCustAccessDistributors.put(bcad.Brand_Customer_Access__c, new List<CHV_BrandCustAccessDistributBaseWrapper>());
			}
			CHV_BrandCustAccessDistributBaseWrapper bcadw = needFullObject(bcad, luDate) ? new CHV_BrandCustAccessDistributorsWrapper(bcad) : new CHV_BrandCustAccessDistributBaseWrapper(bcad);
			bcadw.authorizedDistributor = authorizedDistributors.get(bcad.Authorized_Distributor__c);
			brandCustAccessDistributors.get(bcad.Brand_Customer_Access__c).add(bcadw);
		}
		
		//wwwwwwwwwww4
		Map<String, CHV_CustomerAccessTypeBaseWrapper> customerAccessTypes = new Map<String, CHV_CustomerAccessTypeBaseWrapper>();
		
		Map<String,String> catIdToAIHDImageId = new Map<String,String>();
		Map<String,String> catIdToAISDImageId = new Map<String,String>();
		Set<String> affectedCATsByHD = new Set<String>();
		Set<String> affectedCATsBySD = new Set<String>();
		if (luDate != null) {
			for (CHV_Customer_Access__c ca : cas) {
				catIdToAIHDImageId.put(ca.Id, CHV_Utils.getImageId(ca.Access_Icon_HD_URL__c));
				catIdToAISDImageId.put(ca.Id, CHV_Utils.getImageId(ca.Access_Icon_SD_URL__c));
			}
			//logic for access icon HD
			if (!catIdToAIHDImageId.isEmpty()) {
				Map<Id,Document> catHDDocumentsMap = new Map<Id,Document>([select Id from Document where Id in :catIdToAIHDImageId.values() and LastModifiedDate > :luDate]);
				if (catHDDocumentsMap != null && !catHDDocumentsMap.isEmpty()) {
					for (String catId : catIdToAIHDImageId.keySet()) {
						if (catIdToAIHDImageId.get(catId) != null && catHDDocumentsMap.get(Id.valueOf(catIdToAIHDImageId.get(catId))) != null) {
							affectedCATsByHD.add(catId);
						}
					}
				}
			}
			//logic for access icon SD
			if (!catIdToAISDImageId.isEmpty()) {
				Map<Id,Document> catSDDocumentsMap = new Map<Id,Document>([select Id from Document where Id in :catIdToAISDImageId.values() and LastModifiedDate > :luDate]);
				if (catSDDocumentsMap != null && !catSDDocumentsMap.isEmpty()) {
					for (String catId : catIdToAISDImageId.keySet()) {
						if (catIdToAISDImageId.get(catId) != null && catSDDocumentsMap.get(Id.valueOf(catIdToAISDImageId.get(catId))) != null) {
							affectedCATsBySD.add(catId);
						}
					}
				}
			}
		}
		
		for (CHV_Customer_Access__c ca : cas){
			customerAccessTypes.put(ca.Id, (needFullObject(ca, luDate) || affectedCATsByHD.contains(ca.Id) || affectedCATsBySD.contains(ca.Id)) ? new CHV_CustomerAccessTypeWrapper(ca) : new CHV_CustomerAccessTypeBaseWrapper(ca));
		}
		
		//wwwwwwwwwww5
		Map<String, List<CHV_BrandCustomerAccessTypesBaseWrapper>> brandCustomerAccessTypes = new Map<String, List<CHV_BrandCustomerAccessTypesBaseWrapper>>();
		for (CHV_Brand_Customer_Access__c bca : bcas){
			if (!brandCustomerAccessTypes.containsKey(bca.Brand__c)){
				brandCustomerAccessTypes.put(bca.Brand__c, new List<CHV_BrandCustomerAccessTypesBaseWrapper>());
			}
			CHV_BrandCustomerAccessTypesBaseWrapper bcaw = needFullObject(bca, luDate) ? new CHV_BrandCustomerAccessTypesWrapper(bca) : new CHV_BrandCustomerAccessTypesBaseWrapper(bca);
			bcaw.accessType = customerAccessTypes.get(bca.Customer_Access__c);
			bcaw.accessDistributors = brandCustAccessDistributors.get(bca.Id);
			brandCustomerAccessTypes.get(bca.Brand__c).add(bcaw);			
		}
		
		//wwwwwwwwwww6
		if (CHV_Utils.listNotEmpty(tps)){
			brandW.talkingPoints = new List<CHV_TalkingPointBaseWrapper>();
			for (CHV_Talking_Point__c tp : tps){
				brandW.talkingPoints.add(needFullObject(tp, luDate) ? new CHV_TalkingPointWrapper(tp) : new CHV_TalkingPointBaseWrapper(tp));
			}
		}
		brandW.brandCustomerAccessTypes = brandCustomerAccessTypes.get(brandId);
		
		return brandW;
	}
	
	private static Boolean needFullObject(SObject obj, Datetime luDate){
		return luDate == null || (luDate != null && (Datetime)obj.get('LastModifiedDate') > luDate);
	}
}