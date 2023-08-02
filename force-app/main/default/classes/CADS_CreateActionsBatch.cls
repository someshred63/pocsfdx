global Class CADS_CreateActionsBatch implements Database.Batchable<sObject> {
  
    global  string Query;
    //Scope of the batch
    global List<CADS_Account_Address_Issues_gne__c> ActionCreateData;
   //List to hold newly created actions
    List<Stewardship_Issue_Action_History_gne__c> InsertActions;
    //List of newly created actions 
    List<Stewardship_Issue_Action_History_gne__c> updateActions;
    //List of Issues that are being updated
    List<CADS_Account_Address_Issues_gne__c> upIssues;
    
    global CADS_CreateActionsBatch(String passedQuery){
        Query = passedQuery;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
          return Database.getQueryLocator(Query);
             
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
            Savepoint Savepoint = Database.setSavepoint();
        ActionCreateData = (List<CADS_Account_Address_Issues_gne__c>) scope;
        system.debug('ActionCreateData : '+ ActionCreateData.size());  
        // Map of Issue ID and Issue of the batch scope
        Map <Id,CADS_Account_Address_Issues_gne__c> newIssuesMap = new Map <Id,CADS_Account_Address_Issues_gne__c> ();
        // Map of Action code and Action condtion from the condition table - custom setting -CADS_IssueActionCondition_gne__c
        Map <string,CADS_IssueActionCondition_gne__c> actionConditions = new Map <string,CADS_IssueActionCondition_gne__c>();
        // List of custom setting -CADS_IssueActionCondition_gne__c
        List<CADS_IssueActionCondition_gne__c> actionConds = CADS_IssueActionCondition_gne__c.getAll().values();
        // set of Alert user Unix Id
        set<string> unix_set = new set<string>();
        InsertActions =new List<Stewardship_Issue_Action_History_gne__c>();
        upIssues = new List<CADS_Account_Address_Issues_gne__c>();
        //string IssueKey;
        //string conditionKey;      
        boolean isInsertSuccess = False;// We would update the Issues only if the actions are inserted 
        // List of Data change request records
        List<Change_Request_gne__c> dcrList =  new List<Change_Request_gne__c>();
        // Map of Account Name and DCR record
        Map<String,Change_Request_gne__c> dcrMap = new Map<String,Change_Request_gne__c>();
        
        dcrList = [Select Account_gne__c,Id, Name, Status_gne__c from Change_Request_gne__c where Status_gne__c !='Closed' and  Status_gne__c !='Ready to Close' and  Status_gne__c !='Ready to Load'];
        system.debug('dcrList  : '+dcrList.size());
        for(Change_Request_gne__c dcr :dcrList){
            if(!dcrMap.containsKey(dcr.Account_gne__c)){
                dcrMap.put(dcr.Account_gne__c,dcr);         
            }       
        }
                
        for (CADS_Account_Address_Issues_gne__c newIssue :ActionCreateData){
                  
            if(newIssue.Issue_Condition_gne__c !=null &&newIssue.Issue_Condition_Description_gne__c !=null ){
               
                if(!newIssuesMap.containskey(newIssue.Id) ){
                    newIssuesMap.put(newIssue.Id,newIssue);
                    system.debug('newIssuesMap Key : '+ newIssuesMap.keySet().size());                    
                }
                If(!unix_set.contains(newIssue.Alert_user_Unix_Id_gne__c)){
                    unix_set.add(newIssue.Alert_user_Unix_Id_gne__c);                               
                }
            }
        }
              
        for (CADS_IssueActionCondition_gne__c cond :actionConds){
           
            if(cond.Action_Code_Description_gne__c !=null &&cond.Action_Code_gne__c !=null ){
                //conditionKey = (cond.Action_Code_Description_gne__c+'_'+cond.Action_Code_gne__c).toUpperCase().trim();
               
                if(!actionConditions.containskey(cond.Action_Code_gne__c) ){
                    actionConditions.put(cond.Action_Code_gne__c,cond);
                   
                }
            } 
             
        }
        //List of All User Hierarchy records with external ID in Unix set
        List <All_User_Hierarchy_gne__c> externalID = new List <All_User_Hierarchy_gne__c> ([Select ID,Name,email_id__c, Active_gne__c, User_External_Id_gne__c,FirstName_gne__c,LastName_gne__c From All_User_Hierarchy_gne__c where Active_gne__c = True and User_External_Id_gne__c IN :unix_set]);
        Map<string, All_User_Hierarchy_gne__c> allUsers = new Map<string, All_User_Hierarchy_gne__c>();
        ID StwdId = [Select Id, User_External_Id_gne__c,Name from All_User_Hierarchy_gne__c where User_External_Id_gne__c ='dstwd'].Id;
        for (All_User_Hierarchy_gne__c ex   :externalID){
                if (!allUsers.containsKey(ex.User_External_Id_gne__c))
                    allUsers.put(ex.User_External_Id_gne__c, ex);
            }
        //List of User object records where the user unix id is in the Unix set  and the map with External ID and the user record 
        List<User> objUser = [Select Id, Name, Profile.Name, Email,External_ID_gne__c from User where IsActive = true and External_ID_gne__c IN  :unix_set];
        Map<string,User>userObjMap =new Map<string, User>();
        for(User userMap  :objUser){
            if(!userObjMap.containsKey(userMap.External_ID_gne__c)){
                userObjMap.put(userMap.External_ID_gne__c,userMap);
            }   
        }
        //List of Infrequent interaction enabled profiles and it's Map below
        List<Infrequent_interaction_enabled_profiles__c> infenabled = Infrequent_interaction_enabled_profiles__c.getall().values();
        Map<string,Infrequent_interaction_enabled_profiles__c>infProfile =new Map<string, Infrequent_interaction_enabled_profiles__c>();
        for(Infrequent_interaction_enabled_profiles__c inf  :infenabled){
            if(!infProfile.containsKey(inf.Infrequent_enabled_profile__c )){
                infProfile.put(inf.Infrequent_enabled_profile__c,inf);
            }   
        }
        
       
        try{
            for(CADS_Account_Address_Issues_gne__c Issue : newIssuesMap.values()){
               
                //IssueKey =(Issue.Issue_Condition_Description_gne__c+'_'+ Issue.Issue_Condition_gne__c).toUpperCase().trim();
                
                    CADS_IssueActionCondition_gne__c con = (actionConditions.containsKey(Issue.Issue_Condition_gne__c))?actionConditions.get(Issue.Issue_Condition_gne__c):null;
                    //system.debug('con : ' +con );   
                    
                    if(con!=null){
                        Stewardship_Issue_Action_History_gne__c createAction = new Stewardship_Issue_Action_History_gne__c ();
                        createAction.Action_Condition_gne__c = con.Action_Code_Description_For_User_gne__c;
                        createAction.Action_Type_gne__c = con.Action_Type_gne__c;
                        createAction.Action_Code_gne__c =con.Action_Code_gne__c;
                        createAction.Issue_Id_gne__c =Issue.Id;
                        createAction.Email_Status_gne__c ='Not Sent';
                        createAction.Action_Condition_Type_gne__c= con.Action_Condition_Type_gne__c;
                        if(allUsers.get(Issue.Alert_user_Unix_Id_gne__c)!=null){
                            createAction.Email_Address_gne__c = allUsers.get(Issue.Alert_user_Unix_Id_gne__c).email_id__c;
                            if(con.Action_Condition_Type_gne__c =='User'){
                                createAction.Action_Owner_gne__c = allUsers.get(Issue.Alert_user_Unix_Id_gne__c).Id;                            
                            }         
                        }else if((allUsers.get(Issue.Alert_user_Unix_Id_gne__c) ==null &&con.Action_Condition_Type_gne__c =='User')){
                                createAction.Action_Owner_gne__c = StwdId; 
                        }           
                        if(con.Action_Condition_Type_gne__c =='Stwd'){
                            createAction.Action_Owner_gne__c = StwdId;                                                
                        }
                        InsertActions.add(createAction);
                        //system.debug('createAction : '+ createAction);                        
                    }                
            }
            if(InsertActions.size()>0){
                insert InsertActions;  
                isInsertSuccess = True;
            }
            system.debug('InsertActions Size: '+ InsertActions.size());
            
        }catch(Exception E){
            System.debug ('Insert of Actions Failed');
        }
        if(isInsertSuccess){    
            updateActions  = [Select Id, Action_Type_gne__c, Issue_Id_gne__c, Action_Condition_gne__c,
                                                            Action_Owner_gne__c,Email_Address_gne__c,
                                                            Comment_gne__c,Action_Condition_Type_gne__c,
                                                            CreatedDate, CreatedById,Action_Code_gne__c,
                                                            LastModifiedDate, LastModifiedById
                                                        From Stewardship_Issue_Action_History_gne__c
                                                        Where Id in :InsertActions ];  
            
            try{                                               
                for  (CADS_Account_Address_Issues_gne__c iss :ActionCreateData){
                        for  (Stewardship_Issue_Action_History_gne__c act :updateActions){
                            if(iss.Id == act.Issue_Id_gne__c){
                                if(allUsers.get(Iss.Alert_user_Unix_Id_gne__c)!=null){
                                    iss.Is_Alert_User_Active_gne__c = allUsers.get(iss.Alert_user_Unix_Id_gne__c).Active_gne__c;
                                }else{
                                    iss.Invalid_unixId_gne__c ='Yes';
                                }                            
                                iss.Current_Action_Owner_gne__c =act.Action_Owner_gne__c;
                                iss.Current_Action_Condition_gne__c = act.Action_Condition_gne__c;
                                iss.Current_Action_Type_gne__c = act.Action_Type_gne__c;
                                iss.Issue_Condition_Type_gne__c = act.Action_Condition_Type_gne__c;
                                iss.Current_Action_Condition_Type_gne__c =act.Action_Condition_Type_gne__c;
                                iss.Current_Action_Created_By_gne__c = act.CreatedById;
                                iss.Current_Action_Created_Date_gne__c = act.CreatedDate;
                                iss.Alert_User_Email_Id_gne__c =act.Email_Address_gne__c;
                                iss.Current_Action_Code_gne__c =act.Action_Code_gne__c;
                                iss.Current_Action_Email_Status_gne__c= 'Not Sent';
                                string profileName;
                                if(userObjMap.get(iss.Alert_user_Unix_Id_gne__c) !=null){
                                    profileName = userObjMap.get(iss.Alert_user_Unix_Id_gne__c).Profile.Name; 
                                    system.debug('profileName   :'+profileName );
                                        if(infProfile.containsKey(profileName)){ 
                                            iss.Is_Infrequent_gne__c = infProfile.get(profileName).Infrequent_interaction_enabled__c;                               
                                        }
                                        system.debug('iss.SFDC_USERID_gne__c   :'+iss.SFDC_USERID_gne__c );
                                        if(iss.SFDC_USERID_gne__c !=null){
                                            iss.SFDC_Profile_Name_gne__c =userObjMap.get(iss.Alert_user_Unix_Id_gne__c).Profile.Name;
                                        }
                                        system.debug('iss.SFDC_Profile_Name_gne__c   :'+iss.SFDC_Profile_Name_gne__c );
                                }
                                    if(iss.APRMO_SFDC_gne__c !=null && dcrMap.ContainsKey(iss.APRMO_SFDC_gne__c)){
                                            iss.Has_DCR_gne__c = True;    
                                                            
                                    }  
                                                         
                                if(act.Action_Type_gne__c =='Approve'){
                                    iss.Issue_Closed_Date_gne__c=act.CreatedDate;
                                    iss.STEWARD_REVIEW_STS_gne__c = 'N';
                                    iss.Processing_STS_gne__c = 'Submitted';
                                                    
                                }else if (act.Action_Type_gne__c =='Review'){
                                    iss.STEWARD_REVIEW_STS_gne__c = 'Y';
                                    iss.Processing_STS_gne__c = 'Modified';                     
                                }else{
                                    iss.STEWARD_REVIEW_STS_gne__c = 'Y';
                                    iss.Processing_STS_gne__c = 'Unmodified';               
                                
                                }
                                
                                upIssues.add(iss);   
                            }
                        }
                }                               
               update upIssues;
               system.debug('upIssues: '+ upIssues.size());
            }catch(Exception E){
                system.debug('update of Issues Failed');
                Database.rollback ( savePoint ); 
          
            }
        }    
    }
       
    global void finish(Database.BatchableContext BC){   
      
        system.debug('Finished Batch');
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Action Creation Batch Job  : ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        // schedule the Email Creation batch
        DateTime presentdate=system.now();
        system.debug('presentdate :'+presentdate);
        Integer min;//=presentdate.minute();
        min=0;//presentdate.minute();
        Integer hour;               
        hour=presentdate.hour()+1; 
        Integer day=presentdate.day();
        Integer month=presentdate.month();
        Integer year=presentdate.year();
        String sch='0 '+string.valueof(min)+' '+string.valueof(hour)+' '+string.valueof(day)+' '+string.valueof(month)+' ? '+string.valueof(year);
            CADS_CreateEmailSchedulable a1=  new CADS_CreateEmailSchedulable(); 
            system.schedule('Create Issue Alert Email: '+sch ,sch,a1);
              
    }
}