/*
 * File Name        : GNE_My_Setup_MSL
 * Description  : Used to populate the Mysetup page for MSL profiles
 * Copyright    : Saama Technologies Limited Copyright (c) 2011 *
 * @author      : Saama
 * Modification Log
 * =============================================================================
 * Ver  Date        Author          Modification
 * ---  ----        --------------- -------------
 * 1.0  10-Jul-2011   Saama          Initial Code
 * 1.1  20-Aug-2011   Saama          Added validation, code to display
                                     products alphabetically row wise
                                     and added comments

 */

public class GNE_My_Setup_MSL {
    //private String message = 'false';
    public List<Product_vod__c> productList = new List<Product_vod__c>();
    public List<product_vod__c> productListMSL=new List<product_vod__C>();
    public boolean checkFieldSelf=false;
    public boolean checkSearchFlag=false;
    public String sCheckEnterClick='false';
    public Id userIdInputText { get; set; }
    public String userToPopulate2;
    public Boolean flagCheck=false;
    List<My_Setup_Products_vod__c> mysetupRecord=new List<My_Setup_Products_vod__c>();
    Id GneSFACanadaQueueId = null;
    public String userToPopulate;
    public GNE_My_Setup_MSL(ApexPages.StandardController controller) {
        userToPopulate=System.currentPageReference().getParameters().get('userid');
        GneSFACanadaQueueId = GNE_Referral_Utils.getMSLQueueId(System.Label.GNE_SFA_Canada_Queue);
        System.debug('GneSFACanadaQueueId: --> ' + GneSFACanadaQueueId);
    }



    public List<productDisplayWrapper> finalProductList { get; set; } /*Product wrapper object*/
    public List<productDisplayWrapper> finalFetchedProductList { get; set; } /*Product wrapper object*/


    public List<productDisplayWrapper> getproducts() /*Method to fetch products to be displayed*/
    {
        mysetupRecord=[select id,ownerid,product_vod__c from My_Setup_Products_vod__c
        where ownerid=:userToPopulate];/*query to fetch mysetup records for the logged in user*/
        List<id> productIdList=new List<id>();
        System.debug('#### mysetupRecord:-'+mysetupRecord);
        if(mysetupRecord!=null && mysetupRecord.size()>0)/*loopin over the mysetup record list*/
        {
            for(My_Setup_Products_vod__c mysetup:mysetupRecord)
            {
                productIdList.add(mysetup.product_vod__c);/*adding the ids into an Id list to use it in the query ahead*/
            }
        }
        if(GneSFACanadaQueueId != null){
            productList=[select id,name,DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C from product_vod__c where (DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C='TheraDisease'
                or name='Non-Commercial Molecule') and OwnerId != : GneSFACanadaQueueId and product_type_vod__c='Detail' order by name];/*query to fetch the prods to be displayed for MedAffairs users*/

            productListMSL=[select id,name,DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C from product_vod__c where id in:productIdList
                and (DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C='TheraDisease' or name='Non-Commercial Molecule') and OwnerId != : GneSFACanadaQueueId and product_type_vod__c='Detail' order by name];
                        /*query to fetch the theradisease products from the user's mysetup list*/
        }
        else
        {
            productList=[select id,name,DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C from product_vod__c where (DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C='TheraDisease'
                or name='Non-Commercial Molecule') and product_type_vod__c='Detail' order by name];/*query to fetch the prods to be displayed for MedAffairs users*/

            productListMSL=[select id,name,DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C from product_vod__c where id in:productIdList
                and (DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C='TheraDisease' or name='Non-Commercial Molecule') and product_type_vod__c='Detail' order by name];
                        /*query to fetch the theradisease products from the user's mysetup list*/
        }         System.debug('%%%%% productListMSL'+productListMSL);

        //REMS product check
        system.debug('MICK System.Label.GNE_MedAffairs_Immunology_Terr:' + System.Label.GNE_MedAffairs_Immunology_Terr);
        system.debug('MICK userToPopulate:' + userToPopulate);
        system.debug('MICK system.label.GNE_REMS_PROD_NAME:' + system.label.GNE_REMS_PROD_NAME);
        if(!checkUseragainsTerr(userToPopulate,System.Label.GNE_MedAffairs_Immunology_Terr))
        {
        	// user is not assigned to L1MA02-Immunology terr so remove REMS product from list
        	productList = removeProductfromList(productList,system.label.GNE_REMS_PROD_NAME);
        	productListMSL = removeProductfromList(productListMSL,system.label.GNE_REMS_PROD_NAME);
        }


        finalFetchedProductList = new List<productDisplayWrapper>();
        if(productList!=null && productList.size()>0)/*checking if the list is empty*/
        {

            for(product_vod__c prodLoopVariable:productList)/*looping over products that need to be visible to Medaffairs users*/
            {
                System.debug(' All Prod Id:' + prodLoopVariable.id + ' All Prod Name: ' + prodLoopVariable.name);
                for(product_vod__c prodLoopVariable2:productListMSL)/*looping over logged in user's theradisease products to set the selected products*/
                {
                    System.debug(' MSL Prod Id:' + prodLoopVariable2.id + ' MSL Prod Name: ' + prodLoopVariable2.name);
                    if(prodLoopVariable.id==prodLoopVariable2.id)/*checking if the product id matches in the two lists*/
                    {
                        System.debug('{{{{ prodLoopVariable'+prodLoopVariable);
                        finalFetchedProductList.add(new productDisplayWrapper(prodLoopVariable,true));/*if it matches then set the checkbox to true*/
                        flagCheck=true;
                    }
                }
                if(flagCheck==false)
                {
                    finalFetchedProductList.add(new productDisplayWrapper(prodLoopVariable,false));/*if it matches then set the checkbox to false*/
                }
                flagCheck=false;

            }
                System.debug('@@@@@@@ finalFetchedProductList'+finalFetchedProductList);



        }

        return finalFetchedProductList;


    }
    // the list of row wrappers that contain a transposed view of the account
    public List<productDisplayWrapper> rows; /*Wrapper object*/


    public List<productDisplayWrapper>  getRowWrappers()/*Method to align the products in a 4 column view*/
     {


       rows=new List<productDisplayWrapper>();/*initialize the row wrapper object*/

       finalProductList=getproducts();/*fetch the products to be displayed from the method*/
      // create a row for each field - there are 4 of these
    if(finalProductList!=null && finalProductList.size()>0)/*check if the list is empty*/

    {
              System.debug('##### finalProductList.size()=>'+finalProductList.size());
              // iterate the accounts and populate the rows
              for (Integer idx=0; idx<(finalProductList.size()/4)+1; idx++)/*loop to create/initialize the number of rows*/
                    {
                        rows.add(new productDisplayWrapper());
                    }

                    // iterate the accounts and populate the rows for columns
                    Integer count = 0;
                    for (Integer idx=0; idx<(finalProductList.size()/4)+1; idx++)/*loop for the first column which contains 1st,5th,9th.... products in the first column of each row*/
                    {
                             System.debug('##### second loop count=>'+count);
                             if(count<finalProductList.size())/*check if the count is lesser than the product list size*/
                                {
                                    System.debug('##### second loop finalProductList[count]=>'+finalProductList[count]);
                                    rows[idx].addValue(finalProductList[count]);/*add the 1st,5th,9th.... products in Row[0],Row[1],Row[2]...*/

                                    count=count+4; /*increment the product count by 4 to fetch the 1st,5th,9th.. products*/
                                }
                       }
                  count=1; /*set the counter to 1 for the 2nd column*/
                  for (Integer idx=0; idx<(finalProductList.size()/4)+1; idx++)/*loop for the first column which contains 2nd,6th,10th.... products in the first column of each row*/
                    {
                              System.debug('##### third loop count=>'+count);
                              if(count<finalProductList.size())/*check if the count is lesser than the product list size*/
                                {
                                    System.debug('##### third loop finalProductList[count]=>'+finalProductList[count]);
                                    rows[idx].addValue(finalProductList[count]);/*add the 2nd,6th,10th.... products in Row[0],Row[1],Row[2]...*/

                                    count=count+4;  /*increment the product count by 4 to fetch the 2nd,6th,10th.... products*/
                                }
                       }
                 count=2; /*set the counter to 2 for the 3rd column*/
                 for (Integer idx=0; idx<(finalProductList.size()/4)+1; idx++)/*loop for the first column which contains 3rd,7th,11th.... products in the first column of each row*/
                    {
                             System.debug('##### fourth loop count=>'+count);
                             if(count<finalProductList.size())/*check if the count is lesser than the product list size*/
                                {
                                    System.debug('##### fourth loop finalProductList[count]=>'+finalProductList[count]);
                                    rows[idx].addValue(finalProductList[count]);/*add the 3rd,7th,11th.... products in Row[0],Row[1],Row[2]...*/

                                    count=count+4;   /*increment the product count by 4 to fetch the 3rd,7th,11th.... products*/
                                }
                       }

                 count=3;/*set the counter to 3 for the 4th column*/

                 for (Integer idx=0; idx<(finalProductList.size()/4)+1; idx++)/*loop for the first column which contains 4th,8th,12th.... products in the first column of each row*/
                    {
                             System.debug('##### fourth loop count=>'+count);
                             if(count<finalProductList.size())/*check if the count is lesser than the product list size*/
                                {
                                    System.debug('##### fifth loop finalProductList[count]=>'+finalProductList[count]);
                                    rows[idx].addValue(finalProductList[count]);/*add the 4th,8th,12th.... products in Row[0],Row[1],Row[2]...*/

                                    count=count+4;   /*increment the product count by 4 to fetch the 4th,8th,12th.... products*/
                                }
                       }


             system.debug('Rooooooooooowsss'+rows);
             for(productDisplayWrapper rowObject:rows)
             system.debug('####  valuesssss'+rowObject.values);
    }

     return rows;
    }


    public class productDisplayWrapper
    {
        public boolean disabledIs{get; set;}
        public Boolean selected {get; set;}/*boolean value for the select checkbox on the product list*/
        public List<productDisplayWrapper> values {get; set;}/*wrapper self object to create the display list on row list*/
        public void addValue(productDisplayWrapper value)/*method to add values to the value self wrapper object*/
        {
            values.add(value);
        }
        public Product_vod__c productObject{get; set;} /*product object*/
        public productDisplayWrapper()/*constructor method*/
        {
            values=new List<productDisplayWrapper>();/*initialize the wrapper self object*/
        }
        public productDisplayWrapper(Product_vod__c prodObj,Boolean checkBoxValue)/*constructor method*/
        {
            productObject=prodObj;/*set the product object to the parameter*/
            selected=checkBoxValue;/*set the checkbox select field to the parameter*/


        }
    }

    public PageReference SavePage() /*controller save method*/
    {
        List<My_Setup_Products_vod__c> mysetupToInsert=new List<My_Setup_Products_vod__c>();/*list of mysetup object*/
        List<My_Setup_Products_vod__c> mysetupToDelete=new List<My_Setup_Products_vod__c>();/*list of mysetup object*/
        Map<Id,My_Setup_Products_vod__c> flagIdCheck=new Map<Id,My_Setup_Products_vod__c>();/*Map of id and mysetup object*/
        Boolean flagChecker=false;
        System.debug('$$$$$ finalFetchedProductList:-'+finalFetchedProductList);
        for(productDisplayWrapper objWrapper : finalFetchedProductList)/*loop over the static fetched list*/
        {
            if(objWrapper.selected)/*check if the checkbox is selected for the iterator*/
            {
                System.debug('objWrapper.productObject.name:-'+objWrapper.productObject.name);
                System.debug('objWrapper.productObject.id:-'+objWrapper.productObject.id);
                System.debug('mysetupRecord:-'+mysetupRecord);
                if(mysetupRecord!=null && mysetupRecord.size()>0)/*check if the logged in user's mysetup has any record or not*/
                {
                    for(My_Setup_Products_vod__c mysetup:mysetupRecord)/*loop over the logged in user's mysetup if present*/
                    {
                        if(mysetup.product_vod__c!=objWrapper.productObject.id)/*check if for every mysetup record if it matches the selected product*/
                        {
                            System.debug('$$$$$ objWrapper.productObject.name:-'+objWrapper.productObject.name);
                            System.debug('$$$$$ objWrapper.productObject.id:-'+objWrapper.productObject.id);
                            System.debug('$$$$$ mysetup.id:-'+mysetup.id);
                            flagChecker=true;/*set the flag to true*/
                            if(flagIdCheck.containsKey(mysetup.id)==false)/*if the mysetup record does not exist in the map*/
                            {
                                System.debug('88888 mysetup.id:-'+mysetup.id);
                                flagIdCheck.put(mysetup.id,mysetup);/*then add the mysetup record into the map*/
                                mysetupToDelete.add(flagIdCheck.get(mysetup.id));/*the mysetup record should be added to the deletion list*/
                            }

                        }

                    }
                    if(flagChecker==true)/*check if the flag is set to true*/
                        {
                           My_Setup_Products_vod__c mySetupNew= new My_Setup_Products_vod__c(ownerid= userToPopulate,
                                Product_vod__c=objWrapper.productObject.id);/*initialize a new mysetup record*/
                            mysetupToInsert.add(mySetupNew);   /*add the new record to the insert list*/
                        }
                }
                else
                {
                    System.debug('99999 mysetupToInsert:-'+mysetupToInsert);
                    My_Setup_Products_vod__c mySetupNew= new My_Setup_Products_vod__c(ownerid= userToPopulate,
                                Product_vod__c=objWrapper.productObject.id);/*initialize a new mysetup record*/
                            mysetupToInsert.add(mySetupNew);    /*add the new record to the insert list*/
                }
            }
            else if(!objWrapper.selected)/*check if checkbox not selected*/
            {
                for(My_Setup_Products_vod__c mysetup:mysetupRecord)/*for every mysetup record of the logged in user*/
                {
                        if(flagIdCheck.containsKey(mysetup.id)==false)/*check if the mysetup record exists in the map*/
                        {
                            System.debug('88888 mysetup.id:-'+mysetup.id);
                            flagIdCheck.put(mysetup.id,mysetup);/*if it does not exist add it to the map*/
                            mysetupToDelete.add(flagIdCheck.get(mysetup.id));/*then add this record to the list for deletion*/
                        }
                }
            }

        }
        System.debug('$$$$$ mysetupToDelete:-'+mysetupToDelete);
        System.debug('$$$$$ mysetupToInsert:-'+mysetupToInsert);
        if(mysetupToInsert!=null && mysetupToInsert.size()>0)
        insert mysetupToInsert;
        if(mysetupToDelete!=null && mysetupToDelete.size()>0)
        delete mysetupToDelete;

        //finalFetchedProductList.clear();
        return null;
    }

    //public Account objProxy=new Account();

    /*public Account getMySetupRecords()
    {
      User userToDisplay=new User();

      User userObj=new User();
      if(userToPopulate2==null)
      userObj=[select id from user where id=:userToPopulate];
      else
      userObj=[select id from user where id=:userToPopulate2];
      objProxy.ownerid=userObj.id;

      return objProxy;
    }*/
    private boolean checkUseragainsTerr (String userId,String TerrName)
    {
		String rootTerrName = TerrName ;
		Map<Id,Territory2> root = new Map<Id,Territory2>([select Id from Territory2 where Name = :rootTerrName]);

		set<Id> tmpIds = new Set<Id>(root.keySet());
		set<Id> finalIds = new Set<Id>(root.keySet());

		for(integer i=0;i<99;i++)
		{
		   Map<Id,Territory2> tempMap = new Map<Id,Territory2>([select Id  from Territory2 where ParentTerritory2Id IN :tmpIds]);
		   finalIds.addAll(tempMap.keySet());
		   if(tempMap.keySet().size() < 1) break;
		   tmpIds.clear();
		   tmpIds.addAll(tempMap.keySet());
		}

		List<UserTerritory2Association> userAssignment = [select Id, Territory2Id, UserId from UserTerritory2Association where UserId =:userId AND Territory2Id IN : finalIds];
		  system.debug('MICK userAssignment:' + userAssignment);
		if(userAssignment.size() > 0) {
			system.debug('MICK return: true');
			return true;
		}
		else {
			system.debug('MICK return: false');
			return false;
		}


    }

    private List<product_vod__c> removeProductfromList(List<product_vod__c> temp,String prodName)
    {
    	List<product_vod__c> finalProdList = new List<product_vod__c> ();
    	for(product_vod__c elem : temp)
    	{
    		if(elem.Name != prodName) finalProdList.add(elem);
    	}

    	return finalProdList;
    }


}