public class GNE_FRM_Prod2Team_TriggerHandlerLogic {
    public static final String ERROR_MESSAGE_PRODUCT_NOT_EXIST = 'Product {0} does not exist in the Product Catalog. Please correct the name and try again.';
    
    public static void checkFRMProductExists() {
        Set<String> existingProductNames = fetchExistingProductsByName();
        for(FRM_Prod_2_Team_gne__c p2t:(FRM_Prod_2_Team_gne__c[])Trigger.new){
            if(!existingProductNames.contains(p2t.Product_Name_gne__c)){
                p2t.addError(String.format(ERROR_MESSAGE_PRODUCT_NOT_EXIST, new String[]{p2t.Product_Name_gne__c}));
            }
        }
    }
    
    private static Set<String> fetchExistingProductsByName(){
        Set<String> existingProductNames = new Set<String>();
        Set<String> productNames = fetchProductNamesFromTrigger();
        for(Product_vod__c prod:[
            SELECT Id, Name
            FROM Product_vod__c
            WHERE Product_Type_vod__c = 'Detail'																									
                AND Detail_Product_Subtype_Code_gne__c != 'Molecule'																									
                AND Detail_Product_Subtype_Code_gne__c != 'TheraDisease'																									
                AND Region_Code_gne__c =1																									
                AND Name IN : productNames																							
                AND Owner.Name = 'GNE-SFA-QUEUE'
        ]){
            existingProductNames.add(prod.Name);
        }
        return existingProductNames;
    }
    
    private static Set<String> fetchProductNamesFromTrigger(){
        Set<String> productNames = new Set<String>();
        for(FRM_Prod_2_Team_gne__c p2t:(FRM_Prod_2_Team_gne__c[])Trigger.new){
            productNames.add(p2t.Product_Name_gne__c);
        }
        return productNames;
    }
}