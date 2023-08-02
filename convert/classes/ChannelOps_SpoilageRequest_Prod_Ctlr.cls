/**********************************************************************
Purpose: ChannelOps_SpoilageRequest_Prod_Ctlr class is used to display
the ChannelOps Spoilage Request Products data related to the
COD's Spoilage Request in the inline visualforce page.
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0                       INITIAL DEVELOPMENT
1.1    Raju Manche 24/09/2019    added business loigc to display
the ChannelOps Spoilage Request Products data related to the
COD's Spoilage Request in the inline visualforce page.
***********************************************************************/
public with sharing class ChannelOps_SpoilageRequest_Prod_Ctlr{
    
    public List<ChannelOps_Spoilage_Request_Product__c> ChnlCODList{get; set;}
    public Id Aid {get;set;}    
    //public String redirectURL{get;set;}        
    Public id spoilRecId;
    
    public ChannelOps_SpoilageRequest_Prod_Ctlr(ApexPages.StandardController controller) {                
        ChnlCODList = new list<ChannelOps_Spoilage_Request_Product__c>();        
        Aid = ApexPages.currentPage().getParameters().get('id');
        system.debug('Aid*****'+Aid);                
        spoilRecId = [select id,ChannelOps_Spoilage_Request__c from ChannelOps_Spoilage_Request_COD__c where id = :Aid].ChannelOps_Spoilage_Request__c;
        system.debug('spoilRecId****'+spoilRecId);        
        init();
    }        
    public void init() {
        if(Aid != null) {         
            ChnlCODList= [SELECT Id,Name,Lot_Number__c,brand__c,Indication__c,
                          NDC__c,Other_Indication__c,Product__c,Product_Name__c,
                          Quantity__c,Serial_Number__c,Spoilage_Request__c
                          FROM  ChannelOps_Spoilage_Request_Product__c 
                          WHERE Spoilage_Request__c=: spoilRecId
                          Order by Name asc];
            
        }        
    }    
}