/************************************************************
*  @author: Sudhanshu Jain,Saama Technologies
*  Date: 08-February-2010 
*  Description: On Insertion and Updation of any record of Product Team or Speaker Contract Brand Affiliations are updated or created.
*                          
*  Modification History
*  Date        Name        Description
*                
*************************************************************/
public class UpsertBrandAffiliations {

    @future
    public static void update_InsertSpContractBrandAff_beforeInsertUpdate(Map<String,Date> validAccountID_Date_Map){ 
        List<String> accountIDList = new List<String>(); 
        Map<String,List<String>> Account_SB_Map = new Map<String,List<String>>();
        Map<String,List<String>> SB_Product_Map = new Map<String,List<String>>();
        Map<String,List<String>> Account_Product_Map = new Map<String,List<String>>();
        List<String> SBId_List = new List<String>();
        List<String> tempList = new List<String>();
        //List<String> tempList2 = new List<String>();
        //List<String> tempList3 = new List<String>();
        List<String> ProductId_List = new List<String>();
        List<String> AccProductId_List = new List<String>();
        List<Product_Metrics_vod__c> listToBInserted = new List<Product_Metrics_vod__c>();
        //Set<Product_Metrics_vod__c> listToBInserted_set = new Set<Product_Metrics_vod__c>();
        Set<String> SB_Set = new Set<String>();
        Set<String> acctProdsSet = new Set<String>();
        List<String> acctProds = new List<String>();
        List<String> product_Set = new List<String>();
        List<String> product_List = new List<String>();
        List<String> speakerBureauSet = new List<String>();
        String tempStr1 = null;
        String tempStr2 = null;
        //String tempStr3 = null;
        String strAcct1 = null;
        String strAcct2 = null;
        String strSB = null;


        if(validAccountID_Date_Map!=null && validAccountID_Date_Map.size()!=0){
            accountIDList.addAll(validAccountID_Date_Map.keySet());

            tempStr1=null;


        //-------------Update the Brand affiliations so that the formula in Brand affiliation would populate the flag accordingly-----------------------
            List<Product_Metrics_vod__c> objBrandAff_List = new List<Product_Metrics_vod__c>();
            for(Product_Metrics_vod__c objBrandAff : [Select Id from Product_Metrics_vod__c where  Account_vod__c IN: accountIDList]){
                objBrandAff_List.add(objBrandAff);
            }
            System.debug('Sud objBrandAff_List: ' + objBrandAff_List);//Remove this code

            try{
                update objBrandAff_List; //Step 1 : updating all Brand Affiliations 
            } catch(DmlException dmlException){
                System.debug('Exception while updating');
                System.debug('Exception: '+dmlException.getMessage());
            }

            //System.debug('Sud Insert method accountIDList'+ accountIDList);


            //Removing the Invalid Contracts - start
            for(String accountID : accountIDList){
                Date endDate = validAccountID_Date_Map.get(accountID);

                if(endDate < Date.today()){
                    validAccountID_Date_Map.remove(accountID);
                } else {
                    tempStr1=''+accountID+', ';
                }
            }
            System.debug('Valid accounts: '+ tempStr1);
            accountIDList.clear();
            accountIDList.addAll(validAccountID_Date_Map.keySet());
            //Removing the Invalid Accounts - end


        //--------------End Of Logic to update the Brand Affiliations-----------------------------------------------------------------------------------


        //--------------Start inserting the missing Brand affiliations----------------------------------------------------------------------------------
        //To overcome the governor limits we need to create 3 maps for different objects and work with the maps.

    //    tempList = new List<String>();
            if(validAccountID_Date_Map!=null && validAccountID_Date_Map.size()>0){
                //---------------Get a map for account and related speaker bureaus---------------------------
                for(Speaker_Bureau_Membership_gne__c objMem : [Select Bureau_Member_gne__c, Id, Speaker_Bureau_ID_gne__c from Speaker_Bureau_Membership_gne__c where Bureau_Member_gne__c IN : validAccountID_Date_Map.keySet() order by Bureau_Member_gne__c]){
                    strAcct1 = objMem.Bureau_Member_gne__c;
                    SBId_List.add(objMem.Speaker_Bureau_ID_gne__c);

                    System.debug('Insert method strAcct: '+ strAcct1);
                    System.debug('Insert method tempStr: '+ tempStr1);

                    if(Account_SB_Map.get(strAcct1) == null){
                        tempList = new List<String>();
                        Account_SB_Map.put(strAcct1,tempList);
                    } else if(tempStr1!=strAcct1){
                        tempList = new List<String>();
                        System.debug('Entering elseif : ' + tempStr1+' Speaker Bureau: '+tempList);
                        Account_SB_Map.put(strAcct1,tempList);
                    }

                    Account_SB_Map.get(strAcct1).add(objMem.Speaker_Bureau_ID_gne__c);
                    //System.debug('Sud Insert method tempList'+ tempList);
                    tempStr1 = strAcct1;
                    //System.debug('Insert method tempStr: '+ tempStr1);
                }
                System.debug('Sud Account_SB_Map:'+ Account_SB_Map+' and size of map is: '+ Account_SB_Map.size());
                tempStr1=null;
                //here we got Map containing <Account>,<sb1,sb2,sb3> and unique set of speaker bureaus
                //System.debug('Sud SBId_List: '+ SBId_List);
            //------------------------------Get a map for account and related speaker bureaus COMPLETE---------------------------

    //        tempList = new List<String>();
                //---------------Get a map for speaker bureaus and related products---------------------------
                for( Speaker_Bureau_Product_gne__c objSBP : [Select Id,Product_vod_gne__c, Speaker_Bureau_gne__c from Speaker_Bureau_Product_gne__c where Speaker_Bureau_gne__c IN : SBId_List order by Speaker_Bureau_gne__c] ){
                    strSB = objSBP.Speaker_Bureau_gne__c;

                    System.debug('Sud Insert method objSBP strSB: '+ strSB);
                    System.debug('Sud Insert method objSBP tempStr1: '+ tempStr1);

                    if(SB_Product_Map.get(strSB) == null){
                        tempList = new List<String>();
                        System.debug('Sud strSB: '+ strSB + ' and products are: ' + tempList);
                        SB_Product_Map.put(strSB,tempList);
                    } else if(tempStr1 != strSB){
                        tempList = new List<String>();
                        System.debug('Entering elseif : ' + tempStr1+' Related products: '+tempList);
                        SB_Product_Map.put(strSB,tempList);
                    }
                    System.debug('Sud SB_Product_Map.get(strSB): ' + SB_Product_Map.get(strSB)+' for SB: '+ strSB);
                    SB_Product_Map.get(strSB).add(objSBP.Product_vod_gne__c);
                    //tempList.add(objSBP.Product_vod_gne__c);
                    tempStr1 = strSB;
                }
                System.debug('Sud SB_Product_Map: '+ SB_Product_Map+' and size of map is: '+SB_Product_Map.size());
                tempStr1=null;
                //here we got Map containing <SB>,<p1,p2,p3> 

                //---------------Get a map for speaker bureaus and related products COMPLETE---------------------------

    //        tempList = new List<String>();
            //---------------Get a map for account and related products---------------------------
                for(Product_Metrics_vod__c objBrandAff : [Select Account_vod__c,Products_vod__c from Product_Metrics_vod__c where  Account_vod__c IN: validAccountID_Date_Map.keySet() order by Account_vod__c]){
                    strAcct2 = objBrandAff.Account_vod__c;
                    System.debug('Sud Insert method objBrandAff strAcct: '+ strAcct2);
                    System.debug('Sud Insert method objBrandAff tempStr: '+ tempStr1);

                    if(Account_Product_Map.get(tempStr1) ==null){
                        tempList = new List<String>();
                        Account_Product_Map.put(strAcct2,tempList);
                    }else if(strAcct2 != tempStr1){
                        tempList = new List<String>();
                        System.debug('Sud Account: ' + tempStr1+' Related products: '+tempList);
                        Account_Product_Map.put(strAcct2 ,tempList);
                    }

                    Account_Product_Map.get(strAcct2).add(objBrandAff.Products_vod__c);
                    tempStr1 = strAcct2;
                }
                System.debug('Sud Account_Product_Map: '+ Account_Product_Map+' and size of Map is : '+ Account_Product_Map.size());
                //here we got Map containing <AccountID>,<p1,p2,p3>
                //---------------Get a map for account and related products---------------------------



                for(String acct : accountIDList){
                    System.debug('Sud while Inserting Account_SB_Map: '+ Account_SB_Map);
                    system.debug(acct);
                    speakerBureauSet = Account_SB_Map.get(acct);
                    System.debug('Sud speakerBureauSet: '+ speakerBureauSet);
                    System.debug('Sud while Inserting Account_Product_Map: '+ Account_Product_Map);
                    acctProds = Account_Product_Map.get(acct);
                    System.debug('Sud For Existing Brand Affiliations Prods: '+ acctProds+' for acct:'+ acct);
                    if(acctProds != null){
                        acctProdsSet.addAll(acctProds);
                    }
                    System.debug('Sud For Existing Brand Affiliations acctProdsSet: '+ acctProdsSet);
                    if (speakerBureauSet != null) {
                        for(String str_SB : speakerBureauSet){
                            product_List = SB_Product_Map.get(str_SB);
                            if(product_List != null){
                                product_Set.addAll(product_List);
                            }
                            System.debug('Sud product_List: '+ product_List +'And product_Set is :'+ product_Set+' for SB: '+  str_SB);
                            if (product_Set != null) {
                                for(String prod : product_Set){
                                    if(!acctProdsSet.contains(prod)){
                                        System.debug('Sud prod: ' + prod);
                                        Product_Metrics_vod__c productMetricsToBInserted=new Product_Metrics_vod__c();
                                        productMetricsToBInserted.Account_vod__c=acct;
                                        productMetricsToBInserted.Products_vod__c=prod;
                                        acctProdsSet.add(prod);
                                        listToBInserted.add(productMetricsToBInserted);
                                    }
                                }
                            }
                        }
                    }       
                }
                System.debug('Sud :List to be Inserted: ' + listToBInserted);
                try{
                    insert listToBInserted;
                }catch(DmlException dmlException){
                    System.debug('Exception while inserting');
                    System.debug('Exception: '+dmlException.getMessage());
                }
            }
        }
    }
}