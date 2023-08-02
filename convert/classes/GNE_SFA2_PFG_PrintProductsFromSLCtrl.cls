public with sharing class GNE_SFA2_PFG_PrintProductsFromSLCtrl {
    
    public List<SFA2_PFG_to_User_Detail_gne__c> CSProductsList {get; set;}  
    
    public GNE_SFA2_PFG_PrintProductsFromSLCtrl(){
        CSProductsList = GNE_SFA2_PFG_DAO.getPFGToUserDetailsForUsersWithPositiveQty(new Set<Id>{ UserInfo.getUserId() }, new Set<String>{'Hand Carry'}); //[select Distribution_Method_gne__c, Lot_NO_gne__c, Product_gne__c, Product_gne__r.NDC_Number_gne__c , Product_gne__r.Name , Expiration_Date_gne__c, Qty_Total_Available_gne__c, UOM_gne__c, User_gne__c from SFA2_PFG_to_User_Detail_gne__c where Distribution_Method_gne__c='Hand Carry' AND User_gne__c = :UserInfo.getUserId() AND Qty_Total_Available_gne__c>0];
    }

}