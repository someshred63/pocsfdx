/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-07-24
*  This is a My Setup Page controller
*    
*  Modification History
*  Date        Name        Description
*  2012-11-13  kwiatkol    Added edit option to the page
*  2013-01-04  osowiecb    Filter out My Setup records related to products not visible for current user


*************************************************************/

public with sharing class GNE_SFA2_MySetup_Controller {
	
    public List<My_Setup_Products_vod__c> mySetupProducts {get; set;}
    public List<Product_vod__c> products {get; set;}
                
    public User user {get; set;}
    public Boolean isEdit {get; set;}
    
    Set<String> originalvalues = new Set<String>{};
    Set<String> selectedProducts = new Set<String>{};
    public List<string> leftselected{get;set;}
    public List<string> rightselected{get;set;}
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    Map<Id, Product_vod__c> mySetupProductsMap = new Map<Id, Product_vod__c>();
    Map<Id, Product_vod__c> productsMap = new Map<Id, Product_vod__c>();
    Integer userRegionCode {get;set;}
    
    private Id userId = UserInfo.getUserId();
    private String profileName;
    
    // Contains products with repeating white space characters
    // key: product trimmed name
    // value: product oryginal name        
    private Map<String, String> productsMapNormalized = new Map<String, String>();
    
    private Map<String, GNE_SFA2_TheraDisease_Users__c> profilesMap = GNE_SFA2_TheraDisease_Users__c.getAll();
    
    private SFA2_Configuration_Object_gne__c pageConfiguration;

    private Map<Id, Product_vod__c> buildProductsMap(List<Product_vod__c> products) {
        Map<Id, Product_vod__c> productsMap = new Map<Id, Product_vod__c>();
        for(Product_vod__c prod : products) {
            productsMap.put(prod.Id, prod);
        }
        return productsMap;
    }
        
    private Map<Id, Product_vod__c> buildMySetupProductsMap(List<My_Setup_Products_vod__c> mySetupProducts, Map<Id, Product_vod__c> productsMap) {
        Map<Id, Product_vod__c> mySetupProductsMap = new Map<Id, Product_vod__c>();
        for(My_Setup_Products_vod__c prod : mySetupProducts) {
                mySetupProductsMap.put(prod.Product_vod__c, productsMap.get(prod.Product_vod__c));
        }
        return mySetupProductsMap;
    }
    
    public GNE_SFA2_MySetup_Controller(ApexPages.StandardController controller){
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('My_Setup_Products_vod__c');
        
        isEdit = false;
        
        user = [SELECT Id, Name, FirstName, LastName, Profile_Name_gne__c, Title, Alias, CompanyName, Email, Business_Role_gne__c, 
                        UserName, IsActive, TimeZoneSidKey, External_ID_gne__c, Phone, ManagerId, Extension, Fax, CreatedById, 
                        CreatedDate, LastModifiedBy.Name, LastModifiedById, LastModifiedDate, CreatedBy.Name, Street, City,
                        State, PostalCode, Country
                FROM User
                WHERE Id = :userId];        
                   
        profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        
        if(!profileName.contains('Canada')) {
            userRegionCode = 1;
        } else {
            userRegionCode = 2;
        }
                      
        if(profilesMap.containsKey(profileName)){
                products = [SELECT Id, Name
                            FROM Product_vod__c
                            WHERE Product_Type_vod__c = 'Detail' 
                            AND (Detail_Product_Subtype_Code_gne__c = 'TheraDisease' OR Detail_Product_Subtype_Code_gne__c = 'Molecule')
                            AND Region_Code_gne__c =: userRegionCode
                            AND Id NOT IN (SELECT Product_vod__c 
                                           FROM My_Setup_Products_vod__c 
                                           WHERE OwnerId = :userId)];
        } else {
            products = [SELECT Id, Name
                            FROM Product_vod__c
                            WHERE Product_Type_vod__c = 'Detail'
                            AND (Detail_Product_Subtype_Code_gne__c != 'Molecule' AND Detail_Product_Subtype_Code_gne__c != 'TheraDisease')
                            AND Region_Code_gne__c =: userRegionCode
                            AND Id NOT IN (SELECT Product_vod__c 
                                           FROM My_Setup_Products_vod__c 
                                           WHERE OwnerId = :userId)];
        }               
        productsMap = buildProductsMap(products);
        
        // US       
        if(userRegionCode == 1){
       		mySetupProducts = [SELECT Id, OwnerId, Product_vod__c, Product_vod__r.Name, CreatedById,CreatedBy.Name, CreatedDate,LastmodifiedBy.Name, LastmodifiedById, LastmodifiedDate
                                  FROM My_Setup_Products_vod__c
                                  WHERE OwnerId = :userId
                                  // make sure that we will display only my setup records related to products visible for current user
                                  AND Product_vod__c IN (SELECT ID FROM Product_vod__c WHERE Product_Type_vod__c = 'Detail') 
                                  ORDER BY Product_vod__r.Name];
        // Canada	
        }else{
        	mySetupProducts = [SELECT Id, OwnerId, Product_vod__c, Product_vod__r.Name, CreatedById,CreatedBy.Name, CreatedDate,LastmodifiedBy.Name, LastmodifiedById, LastmodifiedDate
                                  FROM My_Setup_Products_vod__c
                                  WHERE OwnerId = :userId
                                  // make sure that we will display only my setup records related to products visible for current user
                                  AND Product_vod__c IN (SELECT ID FROM Product_vod__c) 
                                  ORDER BY Product_vod__r.Name];
            }

                                   
        mySetupProductsMap = buildMySetupProductsMap(mySetupProducts, productsMap);
        
        for(Product_vod__c product : products){
        	originalValues.add(normalizeProductName(product.Name)); 
        }
       
        for(My_Setup_Products_vod__c mySetupProd : mySetupProducts){
                selectedProducts.add(normalizeProductName(mySetupProd.Product_vod__r.Name));            
            }
       
        leftselected = new List<String>();
        rightselected = new List<String>();
        leftvalues.addAll(originalValues);
        rightvalues.addAll(selectedProducts);
    }
        
    private String normalizeProductName(String productName){
        String productNameNormalized = productName.normalizeSpace();
        if (productName != productNameNormalized){
                productsMapNormalized.put(productNameNormalized, productName);
        }
        return productNameNormalized;
    }
    
    private String getUnormalizedProductName(String productNameNormalized){
        String productNameOryginal = productNameNormalized;
        if (productsMapNormalized.containsKey(productNameNormalized)){
                productNameOryginal = productsMapNormalized.get(productNameNormalized); 
        }
        return productNameOryginal;
    }
    
    private Set<String> getProductsUnormalized(Set<String> values){
        Set<String> result = new Set<String>();
        for (String val : values){
                result.add(getUnormalizedProductName(val));     
        }
        return result;
    }
    
    // redirect to my setup edit page
    public PageReference editProducts() {
        isEdit = true;
        return null;
    }
    
    public PageReference saveProducts() {
        PageReference ref = ApexPages.currentPage();
        //Savepoint savePoint = Database.setSavepoint();
        try {
        	isEdit = false; 
        	productsToBeDelete();
        	productsToBeInsert();
        } catch (Exception ex){
        	//Database.rollback(savePoint);
        	createErrorLog(ex);
        	//ref = GNE_SFA2_Util.redirectToErrorPage('An exception occured: ' + ex.getMessage(), Apexpages.currentPage().getUrl(), ex.getStackTraceString());
        }
        ref.setRedirect(true);                                 
        return ref;
    }
    
    private void createErrorLog(Exception ex){
    	String errorDescription = ex.getMessage() + ': ' + ex.getStackTraceString();
    	if (errorDescription.length() > 4000){
    		errorDescription = errorDescription.substring(0, 4000);
    	}    	
    	insert new Error_Log_gne__c(
    		Object_Name__c = String.valueOf(My_Setup_Products_vod__c.getSObjectType()),
    		Error_Level_gne__c = 'High',
            Snippet_Name__c = 'MySetup Controller', 
            Code_Type__c = 'Apex Class',
            Error_Description__c = errorDescription,
            User_Name__c = UserInfo.getUserName()
        );
    }
    
    public PageReference cancelProducts() {
        isEdit = false;
        leftvalues.clear();
        leftvalues.addAll(originalValues);
        rightvalues.clear();
        rightvalues.addAll(selectedProducts);
        return null;
    }
    
    public PageReference editUser() {
        String pageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
        Pagereference editPage;
        if(pageName == 'EMS_MySetup') {
            editPage = Page.EMS_Edit_User_Layout;            
            editPage.getParameters().put('retURL', '/apex/EMS_MySetup');            
        } else {
            editPage = Page.GNE_SFA2_Edit_User_Layout;            
            editPage.getParameters().put('retURL', '/apex/GNE_SFA2_MySetup');            
        }
        editPage.getParameters().put('id', userId);
        return editPage;
    }
    
    public Pagereference selectClick(){
        rightselected.clear();               
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }        
        return null;
    }
    
    public Pagereference unSelectClick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }
    
    public PageReference grantLoginAccessClick() {
        Pagereference pageref = new pagereference('/partnerbt/grantLoginAccess.apexp?setupid=GrantLoginAccess&retUrl=/apex/GNE_SFA2_MySetup');
        pageref.setredirect(true);
        return pageref;
    }
    
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }

    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    private void productsToBeInsert(){
        List<My_Setup_Products_vod__c> mySetupProductsToAdd = new List<My_Setup_Products_vod__c>();        
        Set<String> productsSelected = getProductsUnormalized(rightValues);
        
        if(profilesMap.containsKey(profileName)){
                products = [SELECT Id, Name
                            FROM Product_vod__c
                            WHERE Product_Type_vod__c = 'Detail'  
                            AND (Detail_Product_Subtype_Code_gne__c = 'TheraDisease' OR Detail_Product_Subtype_Code_gne__c = 'Molecule')
                            AND Region_Code_gne__c =: userRegionCode
                            AND Name IN : productsSelected];                                 
        } else {
                products = [SELECT Id, Name
                            FROM Product_vod__c
                            WHERE Product_Type_vod__c = 'Detail'
                            AND (Detail_Product_Subtype_Code_gne__c != 'Molecule' AND Detail_Product_Subtype_Code_gne__c != 'TheraDisease')
                            AND Region_Code_gne__c =: userRegionCode
                            AND Name IN : productsSelected]; 
        }
                   
        if(products != null && products.size() > 0){
            for(Product_vod__c prod : products){
                 if(! mySetupProductsMap.containsKey(prod.Id)) {
                    mySetupProductsToAdd.add(new My_Setup_Products_vod__c(Product_vod__c = prod.Id));
                }
            }
        }
         
        insert mySetupProductsToAdd;
    }
    
    private void productsToBeDelete(){
        List<My_Setup_Products_vod__c> mySetupProductsToDelete = new List<My_Setup_Products_vod__c>();
        Set<Id> prodToDelete = new Set<Id>();
        Set<String> productsSelected = getProductsUnormalized(leftValues);
              
        if(profilesMap.containsKey(profileName)){
                products = [SELECT Id, Name
                            FROM Product_vod__c
                            WHERE Product_Type_vod__c = 'Detail'
                            AND (Detail_Product_Subtype_Code_gne__c = 'TheraDisease' OR Detail_Product_Subtype_Code_gne__c = 'Molecule')
                            AND Region_Code_gne__c =: userRegionCode
                            AND Name IN : productsSelected]; 
        } else {
                products = [SELECT Id, Name
                            FROM Product_vod__c
                            WHERE Product_Type_vod__c = 'Detail' 
                            AND (Detail_Product_Subtype_Code_gne__c != 'Molecule' AND Detail_Product_Subtype_Code_gne__c != 'TheraDisease')
                            AND Region_Code_gne__c =: userRegionCode
                            AND Name IN : productsSelected]; 
        }
                   
        if(products != null && products.size() > 0){
                for(Product_vod__c prod : products) {
                        if(mySetupProductsMap.containsKey(prod.Id)) {
                                prodToDelete.add(prod.Id);
                }
            }
        }
        
        mySetupProductsToDelete = [Select product_vod__c, OwnerId from My_Setup_Products_vod__c where product_vod__c in :prodToDelete and OwnerId = : userId];
        delete mySetupProductsToDelete;
    }
    
    public String getActiveMenuItem(){
    	String result = 'More';    	
		if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
			result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
		}
		return result;
    }
    
    public Boolean getIsCanadaMSL() {
    	return GNE_SFA2_Util.isCanadaMSL();
    }
}