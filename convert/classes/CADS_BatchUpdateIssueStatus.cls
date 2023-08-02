global class CADS_BatchUpdateIssueStatus {

    public integer noOfActionCount { get; set; }
    // Set of Current Action Owners
    set<Id> actionOwners = new set<Id>();
    //Map of Ids and User record. Used to ascertain wehter action owner is active or not
    Map<Id,All_User_Hierarchy_gne__c> activeOwners;
    //List of Action Owner . If the Steward teaam does not mention the Next Action owner we assign the previous action owner as the current Action owner
    List<Stewardship_Issue_Action_History_gne__c> createOwner = new List<Stewardship_Issue_Action_History_gne__c>();
    CADS_Account_Address_Issues_gne__c cadsAccountRecord = null;
  

    public string recordIdList = '';            
    
    WebService static String[] getSubmittedRecord (String[] recordIds) {
        
        String[] recordInSubmittedStatus = new String[] {};

        Set<String> idSet = new Set<String>();
        if ( recordIds != null )  {
            for (String recordId: recordIds )  
                idSet.add ( recordId );  
        }
        
        if ( idSet.size()> 0 ){         
            for (CADS_Account_Address_Issues_gne__c cadsRecord :
                           [select id,Name from CADS_Account_Address_Issues_gne__c
                            where  processing_sts_gne__c = 'Submitted' and id in :idSet ] ) {
               recordInSubmittedStatus.add ( cadsRecord.Name );                       
            }                                               
        }
                    
        return recordInSubmittedStatus; 
    }

    
    public CADS_Account_Address_Issues_gne__c getCADSAccountRecord() {
        return  cadsAccountRecord;
    }
        
    public CADS_BatchUpdateIssueStatus () {    
        recordIdList = ApexPages.currentPage().getParameters().get('recordIds');
        String[] actionIdList = recordIdList.split(',');  
        noOfActionCount = actionIdList.size();
        cadsAccountRecord = new CADS_Account_Address_Issues_gne__c();   
    }
        
    public PageReference updateStatus(){        
        
        PageReference pageRef = null;
        List<Stewardship_Issue_Action_History_gne__c> actionsHistory = new List <Stewardship_Issue_Action_History_gne__c>();
        try {
            All_User_Hierarchy_gne__c u = new All_User_Hierarchy_gne__c();
            
            if (cadsAccountRecord.Next_Action_Owner_gne__c != null)
            {
                //Check if user belongs to a Infrequent Enabled Profile
                u  = [select User_External_Id_gne__c, Active_gne__c,email_id__c
                from All_User_Hierarchy_gne__c
                Where Id = :cadsAccountRecord.Next_Action_Owner_gne__c limit 1];
                
                String externalId = u.User_External_Id_gne__c;
                
                if (externalId != 'dstwd')
                {
                    if (u.Active_gne__c == false)
                    {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Inactive user'));
                        return null;
                    }
                    List<User> actionOwner = [select Profile.Name from user 
                    where External_ID_gne__c = :externalId limit 1];
                    
                    if (actionOwner.size() == 0)
                    {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'User profile details not found'));
                        return null;
                    }
                    system.debug('Near Profile.Name');
                    String owner_profile = actionOwner.get(0).Profile.Name;
                    
                    MAP<String,Infrequent_interaction_enabled_profiles__c> inf_profiles = Infrequent_interaction_enabled_profiles__c.getAll();
                    boolean Infrequent_enabled_profile = false;
                    for(Infrequent_interaction_enabled_profiles__c p : inf_profiles.values())
                    {
                        if (p.Infrequent_enabled_profile__c == owner_profile)
                        {
                            Infrequent_enabled_profile = p.Infrequent_interaction_enabled__c;
                        }
                    }           
                    system.debug('Checking the infrequent Flag');
                    
                    MAP<String,CADS_User_Exception_List_gne__c> exception_users = CADS_User_Exception_List_gne__c.getAll();
                    boolean CADS_User_Exception = false;
                    for(CADS_User_Exception_List_gne__c usr : exception_users.values())
                    {
                        if (usr.User_External_ID_gne__c == externalId)
                        {
                            CADS_User_Exception = true;
                        }
                    }
                    
                    if (Infrequent_enabled_profile == true && !CADS_User_Exception)
                    {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'The individual you have assigned is not authorized to resolve this Issue. Please select another individual'));
                        return null;
                    }
                }
            }
            //List of Custom setting action conditions
            List<CADS_IssueActionCondition_gne__c> actionConds = CADS_IssueActionCondition_gne__c.getAll().values();
            // Map of Action code description for user and the record
            Map <string,CADS_IssueActionCondition_gne__c> actionConditions = new Map <string,CADS_IssueActionCondition_gne__c>();
            for (CADS_IssueActionCondition_gne__c cond :actionConds)
            {       
                if(!actionConditions.containskey(cond.Action_Code_Description_For_User_gne__c) )
                {
                    actionConditions.put(cond.Action_Code_Description_For_user_gne__c,cond);                    
                }            
            }
            String[] idList = recordIdList.split(',');
           
            system.debug('noOfActionCount :' + noOfActionCount );
            System.debug ( 'record Id list passed :' + idList );
            
            CADS_Account_Address_Issues_gne__c[] cadsRecordList = [select id,processing_sts_gne__c,Current_Action_Owner_gne__c from CADS_Account_Address_Issues_gne__c
                            where  processing_sts_gne__c != 'Submitted' and  id in :idList ]  ;
            System.debug ( 'cadsRecordList  :' + cadsRecordList ); 
            //Probably not using this
            string issueId = cadsRecordList.get(0).Id;
             // Create Actions           
            for ( CADS_Account_Address_Issues_gne__c cadsRecord: cadsRecordList) {
                Stewardship_Issue_Action_History_gne__c actionHistory = new Stewardship_Issue_Action_History_gne__c();
                actionHistory.Action_Condition_gne__c = cadsAccountRecord.Next_Action_Condition_gne__c;
                actionHistory.Action_Type_gne__c = cadsAccountRecord.Next_Action_Type_gne__c;
                if(cadsAccountRecord.Next_Action_Owner_gne__c !=null){
                    actionHistory.Action_Owner_gne__c = cadsAccountRecord.Next_Action_Owner_gne__c;
                }                
                actionHistory.Comment_gne__c = cadsAccountRecord.Next_Action_Comment_gne__c;
                actionHistory.Issue_Id_gne__c = cadsRecord.id;
                actionHistory.Email_Address_gne__c = u.email_id__c;
                actionHistory.Email_Status_gne__c ='Not Sent';
                if(actionConditions.get(cadsAccountRecord.Next_Action_Condition_gne__c) !=null){
                    actionHistory.Action_Condition_Type_gne__c=actionConditions.get(cadsAccountRecord.Next_Action_Condition_gne__c).Action_Condition_Type_gne__c; 
                }
                if(actionConditions.get(cadsAccountRecord.Next_Action_Condition_gne__c) !=null){
                    actionHistory.Action_Code_gne__c=actionConditions.get(cadsAccountRecord.Next_Action_Condition_gne__c).Action_Code_gne__c; 
                }
                actionsHistory.add(actionHistory);
                               
            }
            if ( actionsHistory.size() > 0 ) {
                insert actionsHistory;          
            }
            system.debug('Action Object  : ' +actionsHistory.size());
            string actionId = actionsHistory.get(0).Id;
            system.debug('Action Id   :' +actionId);  
            
            Stewardship_Issue_Action_History_gne__c act = [Select Action_Type_gne__c, Action_Condition_gne__c,
            Action_Owner_gne__c, Action_Condition_Type_gne__c,Action_Code_gne__c, Comment_gne__c,Email_Address_gne__c, CreatedDate, CreatedById,
            LastModifiedDate, LastModifiedById From Stewardship_Issue_Action_History_gne__c Where id = :actionId ];
            system.debug('act.Action_Owner_gne__c   :'+act.Action_Owner_gne__c);
           
           // If the Action Owner is null get the Current Action Owner on the Issue and go to All user and get his details and then assign Active flag
            if(act.Action_Owner_gne__c ==null){ 
                for ( CADS_Account_Address_Issues_gne__c cads :cadsRecordList) {
                    if(cads.Current_Action_Owner_gne__c !=null){
                        actionOwners.add(cads.Current_Action_Owner_gne__c);                                     
                    }           
                }
                system.debug('actionOwners :'+actionOwners);
                activeOwners = new Map<Id,All_User_Hierarchy_gne__c>([select User_External_Id_gne__c, Active_gne__c,email_id__c
                                from All_User_Hierarchy_gne__c Where Id IN :actionOwners]);
                system.debug('activeOwners   :'+activeOwners.keySet());  
                
                for ( CADS_Account_Address_Issues_gne__c cad :cadsRecordList) {
                    if(activeOwners.containsKey(cad.Current_Action_Owner_gne__c)){
                        if(activeOwners.get(cad.Current_Action_Owner_gne__c)!=null){
                            cad.Is_Alert_User_Active_gne__c =activeOwners.get(cad.Current_Action_Owner_gne__c).Active_gne__c;                               
                            system.debug('cad.Is_Alert_User_Active_gne__c:'+cad.Is_Alert_User_Active_gne__c);
                        }                        
                    }           
                }
            }
            system.debug('cadsRecordList:'+cadsRecordList);
                   
            ID StwdId = [Select Id, User_External_Id_gne__c,Name from All_User_Hierarchy_gne__c where User_External_Id_gne__c ='dstwd'].Id;    
           // Update the Issue 
           for ( CADS_Account_Address_Issues_gne__c cadsRecord: cadsRecordList) {
                cadsRecord.Current_Action_Type_gne__c =act.Action_Type_gne__c;
                cadsRecord.Current_Action_Condition_gne__c =act.Action_Condition_gne__c;
                cadsRecord.Current_Action_Comment_gne__c =act.Comment_gne__c;
                if(act.Action_Type_gne__c =='Approve'){
                    cadsRecord.Current_Action_Owner_gne__c =null;
                    cadsRecord.Alert_User_Email_Id_gne__c = '';
                }else{  
                    if(act.Action_Owner_gne__c !=null){
                        cadsRecord.Current_Action_Owner_gne__c =act.Action_Owner_gne__c;
                        cadsRecord.Alert_User_Email_Id_gne__c = act.Email_Address_gne__c;
                    }else if((cadsRecord.Current_Action_Owner_gne__c==null) || (cadsRecord.Is_Alert_User_Active_gne__c ==False) ){
                        cadsRecord.Current_Action_Owner_gne__c = StwdId;
                        cadsRecord.Alert_User_Email_Id_gne__c = '';                        
                    } 
                }
                system.debug('cadsRecord.Current_Action_Owner_gne__c  :'+cadsRecord.Current_Action_Owner_gne__c);
                cadsRecord.Current_Action_Created_By_gne__c =act.CreatedById;
                cadsRecord.Current_Action_Created_Date_gne__c =act.CreatedDate;
                cadsRecord.Current_Action_Last_Modified_By_gne__c =act.LastModifiedById;
                cadsRecord.Current_Action_Last_Modified_Date_gne__c =act.LastModifiedDate;
                cadsRecord.Current_Action_Condition_Type_gne__c=act.Action_Condition_Type_gne__c;                 
                cadsRecord.Current_Action_Email_Status_gne__c = 'Not Sent';
                cadsRecord.Current_Action_Code_gne__c =act.Action_Code_gne__c;
                if (act.Action_Type_gne__c == 'Approve'){
                    cadsRecord.Processing_STS_gne__c = 'Submitted';
                    cadsRecord.Issue_Closed_Date_gne__c = act.CreatedDate;
                    cadsRecord.STEWARD_REVIEW_STS_gne__c='N'; 
                } 
                else if(act.Action_Type_gne__c == 'Review'){
                    cadsRecord.Processing_STS_gne__c = 'Modified';
                    cadsRecord.STEWARD_REVIEW_STS_gne__c='Y'; 
                    cadsRecord.Manual_Action_gne__c = 'Yes';
                }else{
                    cadsRecord.Processing_STS_gne__c = 'Unmodified';
                    cadsRecord.Manual_Action_gne__c = 'Yes';
                    cadsRecord.STEWARD_REVIEW_STS_gne__c='Y';            
                }           
            }
            // Assigning the Action Owner based on the Current Action owner is active or not and update the Action object 
                for ( CADS_Account_Address_Issues_gne__c ownerRecord: cadsRecordList){
                    for(Stewardship_Issue_Action_History_gne__c actionRecord :actionsHistory){
                        if(ownerRecord.Id==actionRecord.Issue_Id_gne__c){
                            if(act.Action_Owner_gne__c ==null){
                                if((ownerRecord.Current_Action_Owner_gne__c !=null) && (ownerRecord.Is_Alert_User_Active_gne__c ==True) ){
                                    actionRecord.Action_Owner_gne__c = ownerRecord.Current_Action_Owner_gne__c;                     
                                }else {
                                    actionRecord.Action_Owner_gne__c = StwdId;                          
                                }
                                    createOwner.add(actionRecord);          
                            }                        
                        }               
                    }
                }
            
            if ( cadsRecordList.size() > 0 ) {
                System.debug('updating cadsRecordList : '+ recordIdList );
                update cadsRecordList;

            }
            if ( createOwner.size() > 0 ) {
                System.debug('updating createOwner :'+ createOwner );
                update createOwner;

            }
                //Close all previous actions of this issue
            List<Stewardship_Issue_Action_History_gne__c> prevIssue = [Select Id,Is_Closed_gne__c
                                                    From Stewardship_Issue_Action_History_gne__c
                                                    Where Issue_Id_gne__c IN  :cadsRecordList
                                                    and Is_Closed_gne__c = false
                                                    and Id  <>:actionsHistory];
        
            List<Stewardship_Issue_Action_History_gne__c> prevIssue_updatedList = new List<Stewardship_Issue_Action_History_gne__c>() ;
        
            for (Stewardship_Issue_Action_History_gne__c pIssue : prevIssue)
            {
                pIssue.Is_Closed_gne__c = true;
                pIssue.Closed_Date_gne__c = datetime.now();
                prevIssue_updatedList.add (pIssue);
            }
            update prevIssue_updatedList;       
            //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,'Data Submitted.'));           
        } catch (Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Could not Create Actions / update Previous Issues'));
            //ApexPages.addMessages(e);
            return null;
        }
        Schema.DescribeSObjectResult sObjectDescription = CADS_Account_Address_Issues_gne__c.sObjectType.getDescribe();  
            pageRef = new PageReference('/'+ sObjectDescription.keyPrefix );
            pageRef.setRedirect(true);
        
        return pageRef;
    }

    public PageReference cancel(){                
        PageReference pageRef = null;        
        try {
            Schema.DescribeSObjectResult sObjectDescription = CADS_Account_Address_Issues_gne__c.sObjectType.getDescribe();  
            pageRef = new PageReference('/'+ sObjectDescription.keyPrefix );
            pageRef.setRedirect(true);
        } catch (Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Unable to Cancel please inform Tech Team'));
            //ApexPages.addMessages(e);
        }        
        return pageRef;
    }
    
}