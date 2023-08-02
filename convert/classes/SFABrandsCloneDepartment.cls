public with sharing class SFABrandsCloneDepartment {
              
            //Local variables
            public String accId;
            public String accpageId;
            
           
            //Class Constructor 
            public SFABrandsCloneDepartment(ApexPages.StandardController stdController) {
            SObject sobjectInstance = stdController.getRecord();
            System.debug('#@#@Id is :'+(String) sobjectInstance.get('Id'));
            accId = (String) sobjectInstance.get('Id');//'001Q0000004Gxjt';
            
            }
            
            //To a clone the account
            public void createTwinDepartmentAccount(){
            
            Account[] acc = [select  name, recordtypeid, parentId, parent_hospital_gne__c, department_type_gne__c, account_type_gne__c from account where id =: accId];//'001Q0000004Gxjt'];
            Account[] twinAcc = acc.deepclone(false);
         
            
            try {
            twinAcc[0].name = acc[0].name + ' <copy>';
            Database.SaveResult[] AccSaveResult = Database.Insert(twinAcc, false);
            accpageId = AccSaveResult[0].Id;
            System.debug('@#@#@#@#@#@#@#@#Twin acct Id: '+AccSaveResult[0].Id);
           
                } catch (DMLException ex) {
                  ApexPages.addMessages(ex);
                  }
                        
            }           
       
           // Redirected to Cloned Page 
            public PageReference clonedAccountPage(){
            
            createTwinDepartmentAccount(); 
                
            PageReference acctPage = new PageReference ('/' + accpageId );
            System.debug('%%%%%%%%Page ref: '+ acctPage);
            acctPage.setRedirect(true);
            return acctPage;
            }

 }