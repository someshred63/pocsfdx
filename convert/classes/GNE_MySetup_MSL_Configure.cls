/*
* Class: GNE_MySetup_MSL_Configure
* Author: Saama
* Date:   18 Aug 2011
* Description: This class is run to delete all My setup records for Non Theradisease products for MedAffairs users
* How to Run: System log
* Command to execute in System Log: GNE_MySetup_MSL_Configure.start();
    
* Requirement gMARS Phase 2 dev
*     -Revision-
      version 1.1 : Release: 1
*/
global class GNE_MySetup_MSL_Configure
    {
        global void GNE_MySetup_MSL_Configure() {}
        public static void start()
        {
            try
            {
                List<User> lstMSLUser=new List<User>();
                List<Product_vod__C> lstNonTheradiseaseProds=new List<Product_vod__C>();
                List<My_Setup_Products_vod__c> lstMySetup=new List<My_Setup_Products_vod__c>();
                List<My_Setup_Products_vod__c> lstMySetupToDelete=new List<My_Setup_Products_vod__c>();
                Map<Id,Product_vod__c> mapLstProdCatalog=new Map<Id,Product_vod__c>();
                lstNonTheradiseaseProds=[select id,name,Detail_Product_Subtype_Code_gne__c from product_vod__c where product_type_vod__c='Detail' and (DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C!='TheraDisease' and name!='Non-Commercial Molecule')];
                System.debug('##### lstNonTheradiseaseProds=>'+lstNonTheradiseaseProds);
                lstMSLUser=[select id,name,profile_name_gne__c from User where profile_name_gne__c like '%MedAffairs%'];
                System.debug('##### lstMSLUser=>'+lstMSLUser);
                if(lstMSLUser!=null && lstMSLUser.size()>0)
                {
                    lstMySetup=[select id,ownerid,product_vod__c from My_Setup_Products_vod__c where ownerid in :lstMSLUser];
                    if(lstMySetup!=null && lstMySetup.size()>0)
                    {
                        for(Product_vod__c prodCatalogObj:lstNonTheradiseaseProds)
                        {
                            //String strProdOwner=mySetupObj.product_vod__c+'-'+mySetupObj.ownerid;
                            mapLstProdCatalog.put(prodCatalogObj.id,prodCatalogObj);
                        }
                            System.debug('###### mapLstProdCatalog=>'+mapLstProdCatalog);
                            for(My_Setup_Products_vod__c mySetupObj:lstMySetup)
                            {
                                
                                if(mapLstProdCatalog.containsKey(mySetupObj.product_vod__c)==true)
                                {
                                    System.debug('###### mapLstProdCatalog.get(mySetupObj.product_vod__c)'+mapLstProdCatalog.get(mySetupObj.product_vod__c));
                                    lstMySetupToDelete.add(mySetupObj);
                                }
                            }
                            
                        
                    }
                }
                
                System.debug('###### lstMySetupToDelete'+lstMySetupToDelete);
                delete lstMySetupToDelete;
            }
            catch(Exception ex)
            {
                System.debug('Inside catch: ' + ex);
                throw ex;
            }
        }
    }