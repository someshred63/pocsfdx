public without sharing class AGG_InfUserDisplayProduct 
{
    
    /*##################################################
    #Project Name           : Genentec - Infrequent Users Search
    # File                  : AGG_SearchUser.cls
    # Version               : 1.0 
    # Created by            : <<Sandeep Kumar>> 
    # Created Date          : <<13 Nov 09>> 
    # Last Modified by      : <<Sandeep Kumar>> 
    # Last Modified Date    : <<13 Nov 09>> 
    # Description           : <<This is the controller class for Infrequent User Search that searches Products>>  
    # 
    # 
    ##################################################*/
    
    Product_vod__c objProductCatalog;
    List<Product_vod__c> lstProductCatalog = new List<Product_vod__c>();
    
    public String sErrMessage{get; set;}
    public String sProductAddName{get; set;}
    public String sProductAddNameType{get; set;}
    public String sProductButtonName{get; set;}
     public String sSpenduserId;
    
    public AGG_InfUserDisplayProduct()
    {
        
    }
    
    public AGG_InfUserDisplayProduct(ApexPages.StandardController stdController)
    {
        //names of input Text fields in calling form pased as parameter values. 
        //These names will be referenced from called form to post values back to parent/called form
        if(System.currentPageReference().getParameters().get('hcpname')!=null )
        {
            sProductAddName=System.currentPageReference().getParameters().get('hcpname');
        }
        if(System.currentPageReference().getParameters().get('hcpnametype')!=null )
        {
            sProductAddNameType=System.currentPageReference().getParameters().get('hcpnametype');
        }
        if(System.currentPageReference().getParameters().get('hcpbutton')!=null )
        {
            sProductButtonName=System.currentPageReference().getParameters().get('hcpbutton');
        }
        if(System.currentPageReference().getParameters().get('SpenduserId')!=null )
        {
            sSpenduserId=System.currentPageReference().getParameters().get('SpenduserId');
        }
        //starts updated by sandeep
        /*
        String  spenduserrprofile=[Select Id, Profile.name from user where id= :sSpenduserId].Profile.name;
        system.debug('spenduserrprofile ='+spenduserrprofile);
        if(spenduserrprofile== 'GNE-INFREQUENT-USER'){
            //starts updated by sandeep on 22Oct10
            //lstProductCatalog=[Select Id, Name, Product_Code_gne__c,Disease_Indication_gne__c, Product_Type_vod__c, GNE_Part_Number_gne__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c from Product_Vod__c where Product_Type_vod__c='Detail' and (Detail_Product_Subtype_Code_gne__c = 'Approved Product Indications' or Detail_Product_Subtype_Code_gne__c='Brand') ORDER BY Name];
            lstProductCatalog=[Select Id, Name, Product_Code_gne__c,Disease_Indication_gne__c, Product_Type_vod__c, GNE_Part_Number_gne__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c from Product_Vod__c where (Name='No Product discussed') OR (Product_Type_vod__c='Detail' AND Detail_Product_Subtype_Code_gne__c='Brand') ORDER BY Name];
        	//ends updated by sandeep on 22Oct10
        }
        else
     	{
         	List<Infrequent_interaction_enabled_profiles__c> infenabled= [Select Id,Infrequent_interaction_enabled__c from Infrequent_interaction_enabled_profiles__c  where Infrequent_enabled_profile__c =:spenduserrprofile and Infrequent_interaction_enabled__c=true];
			system.debug('infenabled ='+infenabled);
            if (infenabled.size()>0)//fetch from set up object
            { 
            	List<My_Setup_Products_vod__c> Setprods=[Select m.Id, m.OwnerId, m.Product_vod__c from My_Setup_Products_vod__c m where OwnerId=:sSpenduserId];
                system.debug('Setprods ='+Setprods);
                Set <Id> SetprodIds=new Set<Id>();
                for(My_Setup_Products_vod__c s : Setprods){
                	SetprodIds.add(s.Product_vod__c);
                }
                system.debug('SetprodIds= '+SetprodIds);
                //starts updated by sandeep on 22Oct10
                //lstProductCatalog=[Select Id, Name, Product_Code_gne__c,Disease_Indication_gne__c, Product_Type_vod__c, GNE_Part_Number_gne__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c from Product_Vod__c where Id in :SetprodIds ORDER BY Name];  
                lstProductCatalog=[Select Id, Name, Product_Code_gne__c,Disease_Indication_gne__c, Product_Type_vod__c, GNE_Part_Number_gne__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c from Product_Vod__c where (Name='No Product discussed') OR ((Product_Type_vod__c='Detail' AND Detail_Product_Subtype_Code_gne__c='Brand') and Id in :SetprodIds) ORDER BY Name];
                //ends updated by sandeep on 22Oct10
                system.debug('lstProductCatalog= '+lstProductCatalog);
           }
        }
        */
        
        lstProductCatalog=[Select Id, Name, Product_Code_gne__c,Disease_Indication_gne__c, Product_Type_vod__c, GNE_Part_Number_gne__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c from Product_Vod__c where (Name='No Product discussed') OR (Product_Type_vod__c='Detail' AND Detail_Product_Subtype_Code_gne__c='Brand') ORDER BY Name];
        //ends updated by sandeep
            
    } 
    
    public List<Product_vod__c> getProductCatalog()
    {
        
        return lstProductCatalog;
        
    }
    

}