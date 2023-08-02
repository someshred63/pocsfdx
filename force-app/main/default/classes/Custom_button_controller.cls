public with sharing class Custom_button_controller {
    
    public Custom_button_controller(ApexPages.StandardController controller){}
    
    public PageReference autoRun(){
        String theId = ApexPages.currentPage().getParameters().get('id');
        system.debug('The Analyst Reopen Case  Id'+theId);
        if (theId == null){
            // Display the Visualforce page's content if no Id is passed over                   
            return null;                    
        }
        List<AGS_Case_gne__c> analystReopenCase = new List<AGS_Case_gne__c>() ;  
        Map<String, RecordType> RecTypes_map = new Map<String, RecordType>();
        List<RecordType> RecType =new List<RecordType>([select Name, Id from RecordType where Name like 'AGS%']);
        for(RecordType rec :RecType){
            if (!RecTypes_map.containsKey(rec.name)){
                RecTypes_map.put(rec.name,rec);
            }
        }   
        AGS_Case_gne__c  reOpenCase =[select Analyst_gne__r.Email,Resolver_gne__c, Inactive_resolver__c, Reason_gne__r.Reason_Type__c,id,Analyst_Response_Level_cco_gne__c,Problem_Severity_Level_cco_gne__c,AGS_Case_Reason_Code_gne__c,Reason_gne__c, Reason_Type_gne__c, Aggregate_Recipient_MDM_ID_gne__c,
                                                Case_Status_gne__c, Case_Closed_Reason_gne__c, Expense_Transaction_Total_gne__c, Brand_gne__c from AGS_Case_gne__c where ID =:theId ]; 
                  
        reOpenCase.Case_Status_gne__c= 'Analyst Reopen - Pending Analysis';
        reOpenCase.Case_Closed_Reason_gne__c = null;
        if (reOpenCase.Problem_Severity_Level_cco_gne__c !='High'){
            reOpenCase.Problem_Severity_Level_cco_gne__c ='Medium';
        }
        if(reOpenCase.Analyst_Response_Level_cco_gne__c !='High' ){
           reOpenCase.Analyst_Response_Level_cco_gne__c ='Medium';
        }
        if (reOpenCase.Reason_Type_gne__c == 'Instance Rule'){
            reOpenCase.RecordTypeId = RecTypes_map.get('AGS Case Per Instance RecordType').Id;
        }
        if (reOpenCase.Reason_Type_gne__c == 'Aggregation Rule' ){
            reOpenCase.RecordTypeId = RecTypes_map.get('AGS Case Aggregate RecordType').Id;
        }
        if (reOpenCase.Reason_Type_gne__c == 'Manual'){
            reOpenCase.RecordTypeId = RecTypes_map.get('AGS Case Per Instance RecordType').Id;
        }
        analystReopenCase.add(reOpenCase);   
                                                                
        try {
            if (analystReopenCase.size()>0){
                update (analystReopenCase);
            }
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Insufficient privileges'));
            return null;
        }     
                  
        List<AGSSpendCCOCase_gne__c> juncObj = new List<AGSSpendCCOCase_gne__c>
                                                ([select AGS_Case_gne__r.Name, 
                                                AGS_Spend_Expense_Transaction_gne__r.Spend_User_gne__c,
                                                AGS_Case_gne__r.Resolver_gne__c,
                                                AGS_Spend_Expense_Transaction_gne__r.Spend_User_Unix_ID_gne__c,
                                                AGS_Case_gne__r.Reason_Type_gne__c,
                                                AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c,  
                                                User_from_AllUserHeirarchy__r.All_User_Hierarchy_Level1_gne__c,
                                                User_from_AllUserHeirarchy__r.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c,
                                                User_from_AllUserHeirarchy__r.All_User_Hierarchy_Level2_gne__c,
                                                User_from_AllUserHeirarchy__r.All_User_Hierarchy_Level2_gne__r.User_External_Id_gne__c                                               
                                                from AGSSpendCCOCase_gne__c where AGS_Case_gne__c=:theId]);
        set<string> UnixidSet = new set<string>();                                                   
        set<ID> id_list = new set<ID>();
       
        for (AGSSpendCCOCase_gne__c ju : juncObj){   
            if(ju.AGS_Case_gne__r.Resolver_gne__c != null){
                UnixidSet.add(ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c); 
            }
        }        
        System.debug('LIST OF UERS WE GOT ##############'+UnixidSet);   
        List<User> usr_list = new List<User>([
                                            select Id, Name, Email, IsActive, External_ID_gne__c  
                                            from User 
                                            where External_ID_gne__c IN : UnixidSet 
                                            order by email]);  
        system.debug('List of spend user B4 assigning Case Actions'+usr_list);        
    
        List< AGS_Case_Action_gne__c> lstCaseActionInsert= new List< AGS_Case_Action_gne__c>();
        for (Integer i=0; i <usr_list.size(); i++) {
            AGS_Case_Action_gne__c aca = new AGS_Case_Action_gne__c();
            if(usr_list[i].IsActive) {
                aca.ownerId=usr_list[i].id;
            } else {
            	try {
		            User usr = [
			            SELECT Id, Name, Email, IsActive, External_ID_gne__c 
			            FROM User 
			            WHERE External_ID_gne__c = :Utilities.noSpendUser 
			            LIMIT 1];
	            	aca.ownerId=usr.Id;
            	} catch(Exception ex) {
            		// Do nothing
            	}
            }
            system.debug('The AGS Case action owner we assigned'+usr_list[i].id);
            aca.Action_Status_internal_gne__c = 'Open';
            aca.AGS_Case_gne__c =theId;
            aca.RecordTypeId = RecTypes_map.get('AGS Case Action - Reopen Record Type').id;
            aca.Action_gne__c='Analyst Reopen Case';
            lstCaseActionInsert.add(aca);
        }
          
        if(lstCaseActionInsert!=null && lstCaseActionInsert.size()>0){
            insert lstCaseActionInsert;
        }
                
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}