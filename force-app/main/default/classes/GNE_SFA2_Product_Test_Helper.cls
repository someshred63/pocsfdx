/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-21
*  Description: This is a helper class for Product Catalog related unit tests
*  
*  Modification History
*  Date        Name        Description
*  
*************************************************************/
public with sharing class GNE_SFA2_Product_Test_Helper {
	
	public static Integer BATCH_SIZE = 201;	// 201 to test agains governor limits
	
	public static List<Product_vod__c> referenceTAProduct() {
    	List<Product_vod__c> refTAProd = [Select Id, Name from Product_vod__c where Detail_Product_Subtype_Code_gne__c = 'Therapeutic Area' limit 2];
    	return refTAProd;
    }
    
    public static String getProductType() {
    	Product_vod__c prodType = [Select Product_Type_vod__c from Product_vod__c where Product_Type_vod__c != null limit 1];
    	return prodType.Product_Type_vod__c;
    }
	
	public static List<Product_vod__c> insertTestProducts(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
		List<Product_vod__c> testProduct = prepareTestProducts(emptyFieldNames, testFieldValues);
		insert testProduct;
		return testProduct;
	}
	
	/* helper method used for preparing test data */
	public static List<Product_vod__c> prepareTestProducts(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
		List<Product_vod__c> testData = new List<Product_vod__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			Product_vod__c product = new Product_vod__c();
				
			// populate Name field
			product.Name = (String) getFieldValue('Name', emptyFieldNames, testFieldValues);
			// populate Product_Type_vod__c field
			product.Product_Type_vod__c = (String) getFieldValue('Product_Type_vod__c', emptyFieldNames, testFieldValues);
			// populate Therapeutic_Area_Reference__c field
			product.Therapeutic_Area_Reference__c = (Id) getFieldValue('Therapeutic_Area_Reference__c', emptyFieldNames, testFieldValues);
			
			testData.add(product);
		}
		
		return testData;
	}
	
	/* helper method for getting field value */
	public static Object getFieldValue(String fieldName, Set<String> emptyFieldNames, Map<String, Object> testFieldValues){
		Object result = null;
		if(emptyFieldNames != null && emptyFieldNames.contains(fieldName)) {
			result = '';			
		} else if(testFieldValues != null && testFieldValues.containsKey(fieldName)) {
			result = (Object) testFieldValues.get(fieldName);
		} else {
			result = 'test';
		}
		return result;
	}
}