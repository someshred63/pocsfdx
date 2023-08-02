public without sharing class SPCM_Product_To_Object_Controller 
{
	
	private final String OBJECT_NAME { get; set; }
	private final String PARENT_OBJECT_NAME { get; set; }
	private final String OBJECT_ID { get; set; }
	
	public final String OBJECT_LABEL { get; set; }
	
	public final SObject PARENT_OBJECT { get; set; }
	
	public Map<Id, Boolean> productIdToChecked { get; private set; }
	public Map<Id, String> productIdToNameMap { get; private set; }
	
	public Boolean canEdit { get; private set; }
	
	public SPCM_Product_To_Object_Controller() 
	{
		
		OBJECT_NAME = (ApexPages.currentPage().getParameters().get('objectName') != null && ApexPages.currentPage().getParameters().get('objectName') != '') ? ApexPages.currentPage().getParameters().get('objectName') : '';
		PARENT_OBJECT_NAME = (ApexPages.currentPage().getParameters().get('objectName') != null && ApexPages.currentPage().getParameters().get('parentObjectName') != '') ? ApexPages.currentPage().getParameters().get('parentObjectName') : '';
		OBJECT_ID = (ApexPages.currentPage().getParameters().get('objectId') != null && ApexPages.currentPage().getParameters().get('objectId') != '') ? ApexPages.currentPage().getParameters().get('objectId') : '';
		
		OBJECT_LABEL = Schema.describeSObjects(new List<String>{ PARENT_OBJECT_NAME })[0].getLabel();
		
		productIdToChecked = new Map<Id, Boolean>();
		productIdToNameMap = new Map<Id, String>();
		
		for(SPCM_Product__c product : [SELECT Id, Name FROM SPCM_Product__c WHERE Is_Active__c = true ORDER BY Name]) 
		{
			productIdToNameMap.put(product.Id, product.Name);
		}
		
		PARENT_OBJECT = getParentObject();
		canEdit = checkIfUserCanEdit();
		
		productIdToChecked = getCheckedProducts();
		
		System.debug(productIdToChecked);
		
	}
	
	private Boolean checkIfUserCanEdit()
	{
		if(PARENT_OBJECT.get('OwnerId') == UserInfo.getUserId() && (PARENT_OBJECT.get('Approval_Status__c') == 'New' || PARENT_OBJECT.get('Approval_Status__c') == 'Recalled')) {
			return true;
		} else {
			return false;
		}
		return false;
	}
	
	private Map<Id, Boolean> getCheckedProducts() 
	{
		Map<Id, Boolean> result = new Map<Id, Boolean>();
		
		List<SObject> products = getProducts();

		for(Id key : productIdToNameMap.keySet())
		{
			result.put(key, false);
		}
				
		for(SObject obj : products) 
		{
			result.put((Id)obj.get('SPCM_Product__c'), true);
		}
		
		return result;
	}
	
	private List<SObject> getProducts()
	{
		String query = 'SELECT SPCM_Product__c FROM ' + OBJECT_NAME + ' WHERE CARS_Wholesaler_Exception_Payment__c = \'' + OBJECT_ID + '\'';
		return Database.query(query);
	}	
	
	private SObject getParentObject()
	{
		String query = 'SELECT OwnerId, Name, Id, Approval_Status__c FROM ' + PARENT_OBJECT_NAME + ' WHERE Id = \'' + OBJECT_ID + '\'';
		return Database.query(query);
	}
	
	public PageReference save() 
	{
		for(Id key : productIdToChecked.keySet()) {
			System.debug(key + ' : ' + productIdToNameMap.get(key) + ' : ' + productIdToChecked.get(key));
		}
		
		List<SObject> products = getProducts();
		delete products;
		
		if(OBJECT_NAME == 'SPCM_CARS_Wholesaler_Payment_Products__c')
		{
			List<SPCM_CARS_Wholesaler_Payment_Products__c> listToInsert = new List<SPCM_CARS_Wholesaler_Payment_Products__c>();
			
			for(Id key : productIdToChecked.keySet()) 
			{
				if(productIdToChecked.get(key)) 
				{
					listToInsert.add(
						new SPCM_CARS_Wholesaler_Payment_Products__c (
							CARS_Wholesaler_Exception_Payment__c = OBJECT_ID,
							SPCM_Product__c = key
						)
					);
				}
			}
			
			insert listToInsert;
			
		}
		
		PageReference redirectPage = new PageReference('/'+OBJECT_ID);
		redirectPage.setRedirect(true);
	    return redirectPage;
	}
	
	public PageReference cancel() 
	{
		PageReference redirectPage = new PageReference('/'+OBJECT_ID);
		redirectPage.setRedirect(true);
	    return redirectPage;
	}

}