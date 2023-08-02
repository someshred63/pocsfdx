public class AGS_GNE_Mass_Case_Create {
    
    public AGS_GNE_Mass_Case_Create(){
    }
    public pageReference content (){
        AGS_CCO_Case_Reason__c reasonID_0A = [select Id from AGS_CCO_Case_Reason__c where Name = '0A'limit 1]; 
        AGS_Case_gne__c new_case = new AGS_Case_gne__c();
        new_case.Reason_gne__c = reasonID_0A.Id;
        List<AGSSpendCCOCase_gne__c> spend = new List<AGSSpendCCOCase_gne__c>();
        Map<String,String> Content = new Map<String,String>(ApexPages.currentPage().getParameters());
        system.debug('Content: Map Values' +Content.values().size());
        system.debug('Content: Map Values' +Content.values());
        system.debug('Content: Map KeySet' +Content.keySet());   
        Database.SaveResult lsr = Database.insert(new_case);
        for(Integer i=0; i<Content.values().size(); i++) {
            AGSSpendCCOCase_gne__c s_x = new AGSSpendCCOCase_gne__c(AGS_Case_gne__c=lsr.getId(), AGS_Spend_Expense_Transaction_gne__c=Content.values()[i]);
            spend.add(s_x);
        }
        if (spend.size() > 0){
        insert spend;
        }
        List<AGSSpendCCOCase_gne__c> junctionList = new List<AGSSpendCCOCase_gne__c>([select ID, User_from_AllUserHeirarchy__c, MDM_ID__c, AGS_Case_gne__c, Source_Transaction_ID_gne__c,User_External_ID__c, Spend_Transaction_Amounts_gne__c ,AGS_Expense_Transaction_Spend_UserID_gne__c,
        AGS_Spend_Expense_Transaction_gne__c,Reason_Code__c,Reason_Type_gne__c,
        Case_Resolver_gne__c, AGS_Spend_Expense_Transaction_Amount_gne__c,Case_Status__c, AGS_Spend_Expense_Trans_Infq_User_gne__c,
        AGS_Spend_Transaction_ID__c from AGSSpendCCOCase_gne__c where CreatedDate = THIS_YEAR and Id IN :spend]);
        
        //starts updated by sandeep
        //ID ccoManager = [Select ID from user where username like '%ccomanager%'].id;
        ID ccoManager = [Select ID from user where external_id_gne__c = :Utilities.ccoManager].id;
         
        //ID cco = [Select ID from All_User_Hierarchy_gne__c where Name like '%cco manager%'].id;
        ID cco = [Select ID from All_User_Hierarchy_gne__c where User_External_Id_gne__c  = :Utilities.ccoManager].id;
        //ends updated by sandeep
        
        Map<string, All_User_Hierarchy_gne__c> allUsersHierarchy = new Map<string, All_User_Hierarchy_gne__c>();
        set<string> unixIdfromJunction_set = new set<string>(); 
        List<AGSSpendCCOCase_gne__c> juncWithAllUser = new List<AGSSpendCCOCase_gne__c>(); 
        Map <ID,AGS_Case_gne__c> caseMap = new Map <ID,AGS_Case_gne__c>([select ID, Analyst_gne__r.Email,Analyst_Response_Level_cco_gne__c,Resolver_gne__c, Inactive_resolver__c, Reason_gne__r.Reason_Type__c,Problem_Severity_Level_cco_gne__c,AGS_Case_Reason_Code_gne__c,Reason_gne__c, Reason_Type_gne__c, Aggregate_Recipient_MDM_ID_gne__c,
                                                Case_Status_gne__c, Expense_Transaction_count__c,Case_Closed_Reason_gne__c, Expense_Transaction_Total_gne__c, Brand_gne__c from AGS_Case_gne__c where  ID =:lsr.getId()]);
    try{    
        for ( AGSSpendCCOCase_gne__c junc   :junctionList){
            if (!unixIdfromJunction_set.contains(junc.User_External_ID__c))
                unixIdfromJunction_set.add(junc.User_External_ID__c);
                system.debug('junc.User_External_ID__c  :' + junc.User_External_ID__c);
        }
        // Users from All User Heirarchy
        List <All_User_Hierarchy_gne__c> allUserexternalID = new List <All_User_Hierarchy_gne__c> ([Select ID,Name,Active_gne__c, User_External_Id_gne__c,All_User_Hierarchy_Level1_gne__c, All_User_Hierarchy_Level2_gne__c,FirstName_gne__c,LastName_gne__c From All_User_Hierarchy_gne__c where User_External_Id_gne__c IN :unixIdfromJunction_set]);
        
        for (All_User_Hierarchy_gne__c ex   :allUserexternalID){
            if (!allUsersHierarchy.containsKey(ex.User_External_Id_gne__c))
                allUsersHierarchy.put(ex.User_External_Id_gne__c, ex);
        }
        
        for ( AGSSpendCCOCase_gne__c junc   :junctionList){
            if (junc.User_External_ID__c != null){
                for (string  hier :allUsersHierarchy.keySet() )   {  
                    if (junc.User_External_ID__c.equals(hier)){     
                        boolean userActive = allUsersHierarchy.get(hier).Active_gne__c;
                        if (userActive){
                            junc.User_from_AllUserHeirarchy__c = allUsersHierarchy.get(hier).Id;
                            system.debug('hier   :' + hier);
                            juncWithAllUser.add(junc);
                        }else{
                            //Write to error log that user is not active 
                        }
                    }
                }
            }
        }
        
            if (juncWithAllUser.size()>0){
                update (juncWithAllUser);
            }
         
         
        for (AGSSpendCCOCase_gne__c ju  :junctionList ){
            system.debug('Going to Find a Case'+ junctionList );
            AGS_Case_gne__c caseToUpdate =  caseMap.get(ju.AGS_Case_gne__c);
            system.debug('caseToUpdate  :'+ caseToUpdate);
            if(caseToUpdate.Id ==ju.AGS_Case_gne__c){
               system.debug('caseToUpdate.Id  :'+ caseToUpdate.Id); 
               system.debug('ju.AGS_Case_gne__c  :'+ ju.AGS_Case_gne__c); 
               system.debug('caseToUpdate.Expense_Transaction_Total_gne__c   :'+ caseToUpdate.Expense_Transaction_Total_gne__c ); 
               system.debug('ju.Spend_Transaction_Amounts_gne__c  :'+ ju.Spend_Transaction_Amounts_gne__c );
               if (caseToUpdate.Expense_Transaction_Total_gne__c == null)
               caseToUpdate.Expense_Transaction_Total_gne__c =ju.Spend_Transaction_Amounts_gne__c; 
               else{
               caseToUpdate.Expense_Transaction_Total_gne__c +=ju.Spend_Transaction_Amounts_gne__c; 
               }
               caseToUpdate.Problem_Severity_Level_cco_gne__c = 'Low';
               caseToUpdate.Analyst_Response_Level_cco_gne__c = 'Low';
               caseToUpdate.Case_Status_gne__c = 'Open - Pending Manual Analysis';
               caseToUpdate.Analyst_gne__c = UserInfo.getUserId();
                  
               if (ju.User_from_AllUserHeirarchy__c != null && ju.AGS_Expense_Transaction_Spend_UserID_gne__c != null) {
                  caseToUpdate.Resolver_gne__c = ju.AGS_Expense_Transaction_Spend_UserID_gne__c;
                  system.debug('caseToUpdate.Resolver_gne__c'+ ju.AGS_Expense_Transaction_Spend_UserID_gne__c); 
                  caseToUpdate.Inactive_resolver__c = ju.User_from_AllUserHeirarchy__c;
                  system.debug('caseToUpdate.Id  :'+ caseToUpdate.Id); 
                }
                else{
                   caseToUpdate.Resolver_gne__c = ccoManager;
                   caseToUpdate.Inactive_resolver__c = cco;
                }
                system.debug('Expense_Transaction_count__c  :' + caseToUpdate.Expense_Transaction_count__c );
                system.debug('ju.AGS_Spend_Expense_Trans_Infq_User_gne__c :' + ju.AGS_Spend_Expense_Trans_Infq_User_gne__c);
                if (caseToUpdate.Expense_Transaction_count__c == 1 && ju.AGS_Spend_Expense_Trans_Infq_User_gne__c == 'Yes'){
                   caseToUpdate.Infrequent_User__c = True;
                
                }
               
               
            }
        }
        Database.UpsertResult[] upsResults=Database.Upsert(caseMap.values(),true);
    }catch(DmlException e){
      system.debug('Could not upsert');
      throw e;
     
    }   
        pageReference splashPage = new pageReference('/'+lsr.getId());
        system.debug('RETURN FROM INSERT: '+lsr);
        return splashPage;
    }
}