@RestResource(urlMapping='/INFU/getProducts/*')
global class iPhone_GetProducts_INFUService {
    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest() {
        return iPhone_Commons_gne.buildResponse(
            new GetProductResponseBuilder(),
            new RequestArgs(getUnixId())            
        );
    }
    
    private static String getUnixId() {
        return [SELECT External_Id_gne__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].External_Id_gne__c;
    }
 
    class GetProductResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args) {         
            
            return new RecordsResponse([
                SELECT Id, Name, Disease_Indication_gne__c, Product_Type_vod__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c
                FROM Product_vod__c
                WHERE (Name = 'No Product discussed') OR (Product_Type_vod__c = 'Detail' AND Detail_Product_Subtype_Code_gne__c = 'Brand')
                ORDER BY Name
            ]);
        }
    }

    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
        public RequestArgs(String unixId) {
            super(null, unixId, null, null, null);

        }               
    } 
    
    public class RecordsResponse extends iPhone_Commons_gne.RestResponse {
        public List<Product_vod__c> products;
        public RecordsResponse(List<Product_vod__c> searchList) {
            this.products = searchList;           
        }
    }

}