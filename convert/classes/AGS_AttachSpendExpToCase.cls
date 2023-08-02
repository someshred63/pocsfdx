public with sharing class AGS_AttachSpendExpToCase{
      
    public String sRetUrl='';
    public String sErrMessage{get; set;} 
    public String spendExpNo {get; set;} 
      
    AGSSpendCCOCase_gne__c objNewJunction = new AGSSpendCCOCase_gne__c();
    AGS_Spend_Expense_Transaction_gne__c objNewSpendExp = new AGS_Spend_Expense_Transaction_gne__c();
    AGS_Case_gne__c objAGScase = new AGS_Case_gne__c();
     
    
    public AGS_AttachSpendExpToCase(ApexPages.StandardController controller){               
        
        
        if(ApexPages.currentPage().getParameters().get('retURL')!=null){
            sRetUrl=ApexPages.currentPage().getParameters().get('retURL');
            system.debug('sRetUrl :'+sRetUrl);
        }
        system.debug('URL index :'+sRetUrl.indexOf('?'));
        if(sRetUrl!=null && sRetUrl!=''){
            if(sRetUrl.indexOf('?')!=-1){
                sRetUrl=sRetUrl.substring(0, sRetUrl.indexOf('?'));
               
                sRetUrl=sRetUrl.replace('/','');
                system.debug('sRetUrl.replace :'+sRetUrl.replace('/',''));
            }
            sRetUrl=sRetUrl.replace('/','');  
            system.debug('sRetUrl.replace :'+sRetUrl.replace('/',''));                  
        }
        
    }
     public AGS_AttachSpendExpToCase()
             {
            
                // System.currentPagereference().getParameters().put('msg',objAGSCaseaction.AGS_Case_gne__c);
                
            }
    public AGSSpendCCOCase_gne__c getObjNewJunction(){
        try{
            objAGSCase = [select Id, Name from AGS_Case_gne__c where Id=:sRetUrl];
        }catch(Exception e){}
        if(objAGSCase!=null && objAGSCase.Id!=null){
          objNewJunction.AGS_Case_gne__c = objAGSCase.Id;
          system.debug('objAGSCase'+ objAGSCase.Id);
          
       }      
        system.debug('objNewJunction.AGS_Case_gne__c'+ objNewJunction.AGS_Case_gne__c);
          //objNewJunction.AGS_Spend_Expense_Transaction_gne__c =objAGSCase.Id;
        return objNewJunction;    
    }
    
     //SAVE BUTTON    
    public PageReference Save() {     
        try{
            objAGSCase = [select Id, Name,Reason_Type_gne__c,Case_Status_gne__c from AGS_Case_gne__c where Id=:sRetUrl];
        }catch(Exception ex){}      
        system.debug('objAGSCase.Id :' +objAGSCase.Id);                             
        string caseId = objAGSCase.Id;
        system.debug('caseId :' +caseId);
        AGSSpendCCOCase_gne__c newjunction;
        ID SpendID =  [Select ID from AGS_Spend_Expense_Transaction_gne__c where Name =:spendExpNo].id;
        system.debug('SpendID :' +SpendID); 
        List<AGSSpendCCOCase_gne__c> juncObj = new List<AGSSpendCCOCase_gne__c>
                                                ([select AGS_Case_gne__c, Source_Transaction_ID_gne__c,
            AGS_Spend_Expense_Transaction_gne__c,Reason_Code__c, AGS_Spend_Expense_Transaction_Amount_gne__c,Case_Status__c, 
            AGS_Spend_Transaction_ID__c  from AGSSpendCCOCase_gne__c where AGS_Case_gne__c=:caseId]);
        system.debug('juncObj :'+  juncObj);
        
        for (AGSSpendCCOCase_gne__c ju :juncObj){
            if(ju.AGS_Spend_Expense_Transaction_gne__c ==SpendID){
                 sErrMessage='The Spend Exp chosen is already part of this Case';
                 return null;
            }
        }
           
        if (objAGSCase.Case_Status_gne__c=='Closed'){
        
            sErrMessage='Cannot add Spend Exp Transaction to a Closed Case';
            return null;
        
        }
        if (objAGSCase.Reason_Type_gne__c=='Instance Rule'){
        
            sErrMessage='Cannot add Spend Exp Transaction to an Instance Case';
           
            return null;
        
        }
        
        if (objAGSCase.Reason_Type_gne__c !='Instance Rule'&& objAGSCase.Case_Status_gne__c !='Closed' ){
        
            newjunction = new AGSSpendCCOCase_gne__c(AGS_Case_gne__c=caseId, AGS_Spend_Expense_Transaction_gne__c=SpendID);
           
        }
        try{
            if(newjunction !=null){
                insert newjunction;
                system.debug('newjunction Inserted:'+newjunction);
                            
            }else{
            sErrMessage='The Spend Exp Txn could not be attached to the Case';
                return null;
            }
        }catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
            system.debug('New Junction could not be created');
        }
           
            
            
        
        List<AGSSpendCCOCase_gne__c> junctionList = new List<AGSSpendCCOCase_gne__c>([select ID, User_from_AllUserHeirarchy__c, MDM_ID__c, AGS_Case_gne__c, Source_Transaction_ID_gne__c,User_External_ID__c, Spend_Transaction_Amounts_gne__c ,AGS_Expense_Transaction_Spend_UserID_gne__c,
        AGS_Spend_Expense_Transaction_gne__c,Reason_Code__c,Reason_Type_gne__c,
        Case_Resolver_gne__c, AGS_Spend_Expense_Transaction_Amount_gne__c,Case_Status__c, AGS_Spend_Expense_Trans_Infq_User_gne__c,
        AGS_Spend_Transaction_ID__c from AGSSpendCCOCase_gne__c where CreatedDate = THIS_YEAR and Id =:newjunction.Id]);
        
        Map<string, All_User_Hierarchy_gne__c> allUsersHierarchy = new Map<string, All_User_Hierarchy_gne__c>();
        set<string> unixIdfromJunction_set = new set<string>(); 
        List<AGSSpendCCOCase_gne__c> juncWithAllUser = new List<AGSSpendCCOCase_gne__c>(); 
        
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
        
    }catch(Exception e){
      system.debug('Could not update the Junction in Attaching Spend Exp- class');
    }  
    system.debug('Reached Page reference :'+ caseId);
    PageReference opp = new PageReference('/'+caseId);   
        return opp;     
 } 
}