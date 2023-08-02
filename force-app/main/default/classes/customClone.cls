global class customClone
{
    webservice static String cloneBrand(Id brandId) // you can pass parameters
    { 
        
        try{
            
            CHV_Unpublished_Brand__c unpublishBrand = [SELECT ID,Name, Business_Unit__c,Distribution_Model_Description__c,Distribution_Model_Diagram_URL__c,iPad_Brand_Logo_HD_URL__c,iPad_Brand_Logo_SD_URL__c,
                                                       iPhone_Brand_Logo_HD_URL__c,iPhone_Brand_Logo_SD_URL__c FROM CHV_Unpublished_Brand__c WHERE Id = : brandId];
            
            if(![SELECT Id FROM CHV_Brand__c WHERE Name = : unpublishBrand.Name].isEmpty()){
                  return unpublishBrand.Name + ' is already published.Please update existing '+ unpublishBrand.Name +' or publish under a new brand name.';
            }
            
            CHV_Brand__c publishBrand = new CHV_Brand__c();
            publishBrand.Name = unpublishBrand.Name;
            publishBrand.iPad_Brand_Logo_SD_URL__c =unpublishBrand.iPad_Brand_Logo_SD_URL__c;
            publishBrand.iPad_Brand_Logo_HD_URL__c =unpublishBrand.iPad_Brand_Logo_HD_URL__c;
            publishBrand.Distribution_Model_Description__c = unpublishBrand.Distribution_Model_Description__c;
            publishBrand.Distribution_Model_Diagram_URL__c =unpublishBrand.Distribution_Model_Diagram_URL__c;
            publishBrand.Business_Unit__c = unpublishBrand.Business_Unit__c;
            publishBrand.iPhone_Brand_Logo_HD_URL__c =unpublishBrand.iPhone_Brand_Logo_HD_URL__c;
            publishBrand.iPhone_Brand_Logo_SD_URL__c =unpublishBrand.iPhone_Brand_Logo_SD_URL__c;
            
            insert publishBrand;
            
            cloneAcessType(brandId,publishBrand.Id);
            cloneTalkingPoint(brandId,publishBrand.Id);
            updateUnpublishedFlds(brandId);
            return publishBrand.Name + ' is published successfully';
            
        }
        catch(Exception ex){
            return ex.getMessage();
        }
        
    }
    public static void cloneAcessType(String brandid,String publishid){
        List<CHV_Brand_Customer_Access__c> customerAccessList = [SELECT Id, Brand__c FROM CHV_Brand_Customer_Access__c WHERE CHV_Unpublished_Brand__c = : brandid];
        
        if(customerAccessList.isEmpty()){
            return;
        }
        
        for(CHV_Brand_Customer_Access__c c : customerAccessList){
            c.Brand__c = publishid;
        }
        
        update customerAccessList;
    }
    public static void cloneTalkingPoint(String brandid,String publishid){
        List<CHV_Talking_Point__c> talkingptList = [SELECT Id, Brand__c FROM CHV_Talking_Point__c WHERE CHV_Unpublished_Brand__c = : brandid];
        
        if(talkingptList.isEmpty()){
            return;
        }
        
        for(CHV_Talking_Point__c t : talkingptList){
            t.Brand__c = publishid;
        }
        
        update talkingptList;
    }
    public static void updateUnpublishedFlds(String brandid){
        List<CHV_Unpublished_Brand__c> updteFlds = [SELECT Id, Brand_Published_By__c,Brand_Published_Date__c,Published__c FROM CHV_Unpublished_Brand__c WHERE Id = : brandid];
        
        if(updteFlds.isEmpty()){
            return;
        }
        
        for(CHV_Unpublished_Brand__c brnd : updteFlds){
            brnd.Brand_Published_By__c =UserInfo.getName();
            brnd.Brand_Published_Date__c= System.Now();
            brnd.Published__c= true;
        }
        
        update updteFlds;
    }
}