/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-11-01
*  This is a class for handling Account Mass update actions
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
public with sharing class GNE_SFA2_Account_Mass_Update_Ext {
       
        public static List<TSF_vod__c> selectedTSFs = new List<TSF_vod__c>();
        public static List<Product_Metrics_vod__c> selectedBrandAffiliations = new List<Product_Metrics_vod__c>();
        
        private static GNE_SFA2_My_Accounts_Setttings__c settings = null;
        //private static GNE_SFA2_My_Accounts_Setttings__c lstsettings = null;
        private static GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_Util.getUserApplicationContext();
                
        public GNE_SFA2_Account_Mass_Update_Ext(ApexPages.StandardController controller) {
        }
        
        public GNE_SFA2_Account_Mass_Update_Ext(GNE_SFA2_MyAccounts_Controller controller) {     
        }

        private static List<SelectOptionClass> getObjectsFields(List<String> availableFields, Map<String, Schema.SObjectField> objectFieldsDescribe){
                List<SelectOptionClass> options = new List<SelectOptionClass>();
           try{     
                for(String fieldName: availableFields){
                    if(objectFieldsDescribe.get(fieldName).getDescribe().isUpdateable()){
                        system.debug(objectFieldsDescribe.get(fieldName).getDescribe().getLabel()+'->');
                        options.add(new SelectOptionClass(fieldName,objectFieldsDescribe.get(fieldName).getDescribe().getLabel()));
                    }
                }
           }
           catch (exception e)
           { system.debug(e.getMessage());}
                return options;
        }
        
        @RemoteAction
        public static List<SelectOptionClass> refreshProducts(String userId) {
                List<Product_vod__c> mySetupProducts = [ SELECT Id, Name FROM Product_vod__c WHERE Id IN (SELECT Product_vod__c FROM My_Setup_Products_vod__c) ORDER BY Name ASC ];
                List<SelectOptionClass> options = new List<SelectOptionClass>();
            for(Product_vod__c product : mySetupProducts) {  
                        options.add(new SelectOptionClass(product.Id, product.Name));
            }
            return options;
        }
        /*
        @RemoteAction 
        public static List<SelectOptionClass> refreshFieldNames(String objectApiName) {
            if(settings == null) {
                settings =  [SELECT Account_View_Columns_gne__c, Address_View_Columns_gne__c, Brand_Affiliation_View_Columns_gne__c, PageSize_gne__c, Privileged_Profiles_gne__c, TSF_View_Columns_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c limit 1 ];
            }
                
            List<SelectOptionClass> result  = new List<SelectOptionClass>();
            if(objectApiName == 'TSF_vod__c') {
                result.add(new SelectOptionClass('My_Target_vod__c', TSF_vod__c.My_Target_vod__c.getDescribe().getLabel()));
            } else if (objectApiName == 'Account'){
                result.addAll(getObjectsFields(settings.Account_View_Columns_gne__c.split(','), Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap()));
            } else if (objectApiName == 'Product_Metrics_vod__c'){
                result.addAll(getObjectsFields(settings.Brand_Affiliation_View_Columns_gne__c.split(','), Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap()));
            }
            return result;

                Map<String, Schema.SObjectField> objectFieldsDescribe=Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
                if(objectApiName == 'TSF_vod__c') {
                   for(GNE_SFA2_My_Accounts_Setttings__c objSetting:lstsettings){ 
                    if(objectFieldsDescribe.get(objSetting.TSF_View_Columns_gne__c).getDescribe().isUpdateable()){
                        result.add(new SelectOptionClass(objSetting.TSF_View_Columns_gne__c,objectFieldsDescribe.get(objSetting.TSF_View_Columns_gne__c).getDescribe().getLabel()));
                    }
                   }
                }else if (objectApiName == 'Account'){
                   for(GNE_SFA2_My_Accounts_Setttings__c objSetting:lstsettings){ 
                    if(objectFieldsDescribe.get(objSetting.Account_View_Columns_gne__c).getDescribe().isUpdateable()){
                        result.add(new SelectOptionClass(objSetting.Account_View_Columns_gne__c,objectFieldsDescribe.get(objSetting.Account_View_Columns_gne__c).getDescribe().getLabel()));
                    }
                   }
                }else if (objectApiName == 'Product_Metrics_vod__c'){
                  for(GNE_SFA2_My_Accounts_Setttings__c objSetting:lstsettings){ 
                    if(objectFieldsDescribe.get(objSetting.Brand_Affiliation_View_Columns_gne__c).getDescribe().isUpdateable()){
                        result.add(new SelectOptionClass(objSetting.Brand_Affiliation_View_Columns_gne__c,objectFieldsDescribe.get(objSetting.Brand_Affiliation_View_Columns_gne__c).getDescribe().getLabel()));
                    }
                   }
                }

        }*/
        
        @RemoteAction 
        public static List<SelectOptionClass> refreshFieldNames(String objectApiName) {
            
            /*GNE_SFA2_Selected_Application selectedApplication;
            List<SFA2_User_Sales_Roster_gne__c> userSalesRosters = GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId());        
            if(userSalesRosters.size() > 0){           
                selectedApplication = new GNE_SFA2_Selected_Application(userSalesRosters);
            }*/
            //List<GNE_SFA2_My_Accounts_Setttings__c> lstsettings = null;
            List<SelectOptionClass> result  = new List<SelectOptionClass>();
            
            if(userAppContext != null) {
                settings =  [ SELECT Account_View_Columns_gne__c, Address_View_Columns_gne__c, Brand_Affiliation_View_Columns_gne__c, PageSize_gne__c, Privileged_Profiles_gne__c,
                 TSF_View_Columns_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c Where Brand_gne__c = :userAppContext.Brand_gne__c AND Role_gne__c = :userAppContext.Role_gne__c AND Application_Type__c = :userAppContext.App_Name_gne__c LIMIT 1 ];

                //List<SelectOptionClass> result  = new List<SelectOptionClass>();
                if(objectApiName == 'TSF_vod__c') {
                    result.add(new SelectOptionClass('My_Target_vod__c', TSF_vod__c.My_Target_vod__c.getDescribe().getLabel()));
                } else if (objectApiName == 'Account'){
                    result.addAll(getObjectsFields(settings.Account_View_Columns_gne__c.split(','), Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap()));
                } else if (objectApiName == 'Product_Metrics_vod__c'){
                    result.addAll(getObjectsFields(settings.Brand_Affiliation_View_Columns_gne__c.split(','), Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap()));
                }
                             
            }
            return result;
        }
        
        
        @RemoteAction
        public static String refreshFieldType(String objectApiName, String fieldApiName) {
                String result;
                Schema.DisplayType fieldType = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getType();
                if(fieldType == Schema.DisplayType.Boolean) {
                        result = 'Boolean';
                } else if(fieldType == Schema.DisplayType.Date){
                        result = 'Date';
                } else if(fieldType == Schema.DisplayType.Picklist){
                        result = 'Picklist';
                } else if(fieldType == Schema.DisplayType.Double) {
                        result = 'Double';
                } else {
                        result = 'Other';
                }
                return result;
        }
                
       @RemoteAction
       public static List<SelectOptionClass> getPicklistValues(String objectApiName, String fieldApiName) {
                List<SelectOptionClass> options = new List<SelectOptionClass>();
                        
                Schema.DescribeFieldResult fieldResult =     Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                        options.add(new SelectOptionClass(f.getLabel(), f.getValue()));
                }       
                return options;
       }
        
       public class SelectOptionClass {
            public String value { get; set; }
            public String label { get; set; }
                
            SelectOptionClass(String value, String label) {
                this.value = value;
                this.label = label;
            }
        }
}