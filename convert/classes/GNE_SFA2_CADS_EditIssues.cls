public class GNE_SFA2_CADS_EditIssues {
    
    public PageReference saveIssue{ get; set; }
    public PageReference ShowList{ get; set; }
    public Boolean SalesTeam = true;
    
    public Boolean isSalesTeam 
    {
        get
        {
            return this.SalesTeam;
        } 
        set;
    } 

    boolean ShowEditBtn =true;    
    boolean ShowHistoryBtn = false;
    boolean showSubmitBtn =true;
    public boolean ShowTransactionHistoryBtn = false;
    boolean HideSubmitMsg =true;
    String msg ;    
    String mode = '';
    String tab;
    ID IssueId;
    // Id QueueId;===3

    public String SAddAddrId {get; set;}

    //public String sAddHCPId {get; set;}
    public String SAddHCPIdType {get; set;}
    public String SAddHCPAddressId {get; set;}
    
    public String isSubscribeSuccess{get; set;}
    
    public String accountId;
    public String accountAddressId;
    public String accountPrimaryAddress;
    public Integer hcpActual{get;set;} 
    
    private transient GNE_Account_Dao acctDao;        
    private transient GNE_Stg_Party_Dao ptyDao;
    
    CADS_Account_Address_Issues_gne__c Issue; 
    CADS_Account_Address_Issues_gne__c EditIssue; 
    
    Attendee receivedAttendee;
    
    private Set<string> variable = new Set<string>{'Bo_Report_Variable'};
    private List<Environment_Variables__c> env_var = new List<Environment_Variables__c>();
    public Map<String, String> environment_var_val = new Map<String, String>();
    
    String radioItemValue = null;
    
    public Static String getKeyprefix(){   
        Schema.DescribeSObjectResult sObjectDescription = CADS_Account_Address_Issues_gne__c.sObjectType.getDescribe();  
        return '/'+ sObjectDescription.keyPrefix;
    }
    
    public GNE_SFA2_CADS_EditIssues(ApexPages.StandardController sc){
        try
        {
            System.Debug('--------------controller');
            //....... Check if logged in user is DS Team User or Sales Team User.......
            
            //String[] Profile_list = system.Label.DataStewardship_SalesTeam.split(',');
            //String loggedInUser_profile = Utilities.getProfileName();
            // for (String p : Profile_list)
            //if ( loggedInUser_profile.startsWith('GNE-SYS') == true || loggedInUser_profile.startsWith('GNE-AGS-CCO') == true || loggedInUser_profile == 'System Administrator' ) 
            //  SalesTeam = false;
            //else
            //  SalesTeam = true;
            
            hcpActual = 0;
            
            List<Group> Groups = [Select id from group where name = 'Data Stewardship' or name='GNE-AGS-CCO-Manager-Group' or name='GNE-AGS-CCO-Analyst-Group' or name='GNE-AGS-CCO-TempAnalyst-Group' or name='GNE-AGS-CCO-TEAM'];
            
            List<Id> groupId = new List<Id>();
            for(Group grp :Groups)
            {
                groupId.add(grp.Id);
            }
            
            Integer grpCnt = [Select count() FROM GroupMember 
            WHERE UserOrGroupId = :UserInfo.getUserId()
            and groupId in :groupId];
            
            /*
            Id GroupId = [Select id from group where name = 'Data Stewardship'].id;
            
            Integer grpCnt = [Select count() FROM GroupMember 
            WHERE UserOrGroupId = :UserInfo.getUserId()
            and groupId = :GroupId];*/
                        
            if (grpCnt == 0) {
                SalesTeam = true;
            } else {
                SalesTeam = false;
            }               
            
            // [LB: test mode]
            /*String stMode = ApexPages.currentPage().getParameters().get('stMode');
            if (stMode != null){
                SalesTeam = stMode == '1';
            } */ 
            
            //QueueId = [select id from group
            //          where name = 'Data Stewardship Queue'
            //          and Type = 'Queue'].id;
            
            CADS_Account_Address_Issues_gne__c iRecord= (CADS_Account_Address_Issues_gne__c)sc.getRecord(); 
            if (iRecord.id == null){
                return;
            }
            
            IssueId = iRecord.id;
            
            this.Issue = [Select Id, name, APRMO_ABTRACKER_ID_gne__c, APRMO_ATTEND_STS_gne__c, 
            APRMO_EVENT_DATE_gne__c, APRMO_EVENT_ID_gne__c, APRMO_Event_Status_gne__c,
            APRMO_Event_Meal_Amount_gne__c, CDIP_VNDR_STS_gne__c, CITY_NM_gne__c, 
            CRDL_VAL_TXT_gne__c, FALLOUT_CD_gne__c, FALLOUT_CD_DESC_gne__c,SFDC_Profile_Name_gne__c,
            IMED_SAP_DOCNO_gne__c, IMED_SAP_VNDR_ID_gne__c, State_License_gne__c,
            IMED_TX_AMOUNT_gne__c, IMED_TX_DATE_gne__c, INDV_BUS_CLL_PHN_TXT_gne__c, 
            INDV_BUS_EMAIL_ADDR_TXT_gne__c, INDV_FMLY_NM_gne__c, INDV_GEN_SUFX_gne__c, 
            INDV_GIVEN_NM_gne__c, INDV_MID_NM_gne__c, INST_LVL_1_gne__c, 
            LNDLN_PHN_EXT_TXT_gne__c, LNDLN_PHN_TXT_gne__c,Manual_Action_gne__c,
            ORG_FULL_NM_gne__c, Has_Spend_ETL_populate_gne__c,SFDC_User_Id_Text_gne__c,
            PHYS_ADDR_KEY__c, PRIM_ST_ADDR_gne__c, PSTL_CD_gne__c, PTY_ADDR_KEY_gne__c, 
            PTY_CRDL_KEY_gne__c, PTY_KEY_gne__c, PTY_TAX_ID_gne__c, PTY_TYP_CD_gne__c, 
            Processing_STS_gne__c, SAPBW_DOCNO_gne__c, SAPBW_POST_DATE_gne__c, 
            SAPBW_TX_AMOUNT_gne__c, SFDC_TX_AMOUNT_gne__c, SFDC_TX_DATE_gne__c, 
            SFDC_TX_ID_gne__c, SFDC_USERID_gne__c, SRC_PHYS_ADDR_KEY_gne__c, 
            SRC_PTY_ADDR_KEY_gne__c, SRC_PTY_CRDL_KEY_gne__c, SRC_PTY_KEY_gne__c, 
            SRC_SYS_gne__c,  STEWARD_COMMENT_gne__c,    Invalid_unixId_gne__c,
            STEWARD_STS_CD_gne__c, STEWARD_STS_DESC_gne__c,  
            ST_CD_gne__c, CNTRY_CD_gne__c, APRMO_PARTICIPANT_PROFESSION_gne__c,
            TWRKS_PAYMT_ID_gne__c, TWRKS_SAP_VNDR_ID_gne__c, TWRKS_TX_AMOUNT_gne__c, 
            TWRKS_TX_Date_gne__c, CRO_Name_gne__c, CRO_Trial_Name_gne__c, Roche_Trial_Id_gne__c, Grant_Id_gne__c,
            WBS_Desc_gne__c, CostCenter_Desc_gne__c, GL_Desc_gne__c, Unit_gne__c,
            APRMO_Event_Expense_Amount_Exists_gne__c, APRMO_Participant_Role_gne__c,
            APRMO_Accountable_Party_Name_gne__c, APRMO_Accountable_Party_UNIXID_gne__c,                      
            SFDC_EVENT_EXPENSE_AMOUNT_EXISTS_gne__c, SFDC_MEAL_AMOUNT_gne__c,
            Is_Speaker_gne__c , Has_Spend_gne__c,
            APRMO_AFFL_ORG_FULL_NM_gne__c, APRMO_EVENT_VENUE_NAME_gne__c, APRMO_EVENT_CITY_gne__c, APRMO_EVENT_STATE_gne__c,
            APRMO_EVENT_COUNTRY_gne__c, APRMO_MDM_gne__c, APRMO_AMS_ID_gne__c, APRMO_SFDC_gne__c,
            TWRKS_EVENT_EXPENSE_AMOUNT_EXISTS_gne__c,SAPBW_EVENT_EXPENSE_AMOUNT_EXISTS_gne__c,
            IMED_EVENT_EXPENSE_AMOUNT_EXISTS_gne__c,Issue_Opened_Date_gne__c,
            Issue_Condition_gne__c,Issue_Condition_Description_gne__c,Is_International_gne__c,
            LastModifiedDate, LastModifiedById, LastModifiedBy.Name ,ETL_Override_Flag_gne__c,
            Has_DCR_gne__c,CreatedDate,DQXI_ERR_CD_gne__c,DQXI_ERR_CD_DESC_gne__c,UNIT_TYP_TXT_gne__c,UNIT_VAL_TXT_gne__c
            FROM CADS_Account_Address_Issues_gne__c                         
            Where Id = :IssueId];

            this.EditIssue = [Select NEW_CITY_NM_gne__c,APRMO_Event_Status_gne__c, 
            NEW_CRDL_VAL_TXT_gne__c, NEW_INDV_BUS_CLL_PHN_TXT_gne__c, Issue_Opened_Date_gne__c,
            NEW_INDV_FMLY_NM_gne__c,NEW_INDV_BUS_EMAIL_ADDR_TXT_gne__c,PTY_TYP_CD_gne__c,
            NEW_INDV_GEN_SUFX_gne__c, NEW_INDV_GIVEN_NM_gne__c, NEW_INDV_MID_NM_gne__c, 
            NEW_INST_LVL_1_gne__c, NEW_LNDLN_PHN_EXT_TXT_gne__c, NEW_LNDLN_PHN_TXT_gne__c, 
            NEW_PRIM_ST_ADDR_gne__c, NEW_PSTL_CD_gne__c, NEW_STEWARD_COMMENT_gne__c, 
            NEW_ST_CD_gne__c, NEW_UNIT_TYP_TXT_gne__c, NEW_UNIT_VAL_TXT_gne__c,SFDC_USERID_gne__c,
            New_ORG_FULL_NM_gne__c, New_Steward_Sts_cd_gne__c, New_Cntry_cd_gne__c,Current_Action_Code_gne__c,                    
            VND_MSTR_KEY_gne__c, VND_SYS_gne__c,Has_DCR_gne__c,APRMO_SFDC_gne__c,SFDC_Profile_Name_gne__c, 
            Next_Action_Type_gne__c, Next_Action_Owner_gne__c, Has_Spend_ETL_populate_gne__c,
            Next_Action_Condition_gne__c, Next_Action_Comment_gne__c,Manual_Action_gne__c,
            Current_Action_Condition_gne__c,Current_Action_Owner_gne__c,Current_Action_Owner_gne__r.Name,
            Current_Action_Type_gne__c, Current_Action_Comment_gne__c , Invalid_unixId_gne__c,
            Current_Action_Created_Date_gne__c, Current_Action_Created_By_gne__c,Current_Action_Created_By_gne__r.Name,
            Current_Action_Last_Modified_Date_gne__c, Current_Action_Last_Modified_By_gne__c ,
            Issue_Closed_Date_gne__c,DEA_gne__c, HIN_gne__c, Tax_Id_gne__c, NPI_gne__c,
            ME_gne__c, State_License_No_gne__c, Specialty_gne__c,License_Issue_State_gne__c, Qtr_gne__c, Transition_Card_Id_gne__c,
            Brand_gne__c, Claims_Paid_gne__c, Total_Claim_Count_gne__c, New_Enrollment_Count_gne__c, Total_Enrollment_Count_gne__c,
            Order_Number_gne__c, Order_Date_gne__c, CHILD_SRC_PTY_KEY_gne__c, CHILD_RELTIO_ID_gne__c, PARENT_SRC_PTY_KEY_gne__c, PARENT_RELTIO_ID_gne__c,
			NO_OF_SRS_gne__c, REQ_UNIX_ID_gne__c
            FROM CADS_Account_Address_Issues_gne__c                         
            Where Id = :IssueId];  
            
            //.....Get parameter values
            String msg = ApexPages.currentPage().getParameters().get('msg');
            tab =  ApexPages.currentPage().getParameters().get('tab'); 
            mode = ApexPages.currentPage().getParameters().get('mode');   
            
            //......if Reopening an issue set the Next Action Type to Corrective
            //...... if logged in user is Sales Team user set Next Action Type to Corrective
            if (mode == 'reopen' && SalesTeam == False)
            {
                EditIssue.Next_Action_Type_gne__c = 'Corrective';
                
            }     
            else if (SalesTeam)
            {
                EditIssue.Next_Action_Type_gne__c = 'Review'; //'Corrective';
                EditIssue.Next_Action_Condition_gne__c ='Added or Corrected Information';
            }                 
            
            //...Issue is submitted show Submit Successful message on View page 
            if (msg == 'submit')
            {
                HideSubmitMsg = false;
            }
            
            //....If issue is submitted lock Issue from Edit  
            if (this.issue.Processing_STS_gne__c == 'Submitted' )
            {
                ShowEditBtn = false;
            }
            else if (SalesTeam)
            {
                if (EditIssue.Current_Action_Type_gne__c != 'Corrective')
                ShowEditBtn = false;
            }
            
            
            //....Get record count of the Action history records for this issue, if more than 1 then Show History button
            Integer recCnt = [Select count()  from Stewardship_Issue_Action_History_gne__c Where Issue_Id_gne__c = :IssueId ];
            
            if (recCnt > 1)
            {
                ShowHistoryBtn = true;
            }
            
            if(Issue.Has_Spend_ETL_populate_gne__c == 'Yes')
            {
                ShowTransactionHistoryBtn = true;
            }
            if (this.issue.Processing_STS_gne__c == 'Submitted'  && mode !='reopen'){
                showSubmitbtn = False;
            }else if (mode =='reopen'){
                if(this.issue.Processing_STS_gne__c == 'Submitted')
                    showSubmitbtn = True;
                else
                    showSubmitbtn = false;
            }
            if(SalesTeam)
            {
               
                if(EditIssue.New_ORG_FULL_NM_gne__c ==null || EditIssue.New_ORG_FULL_NM_gne__c ==''){
                
                    EditIssue.New_ORG_FULL_NM_gne__c = Issue.ORG_FULL_NM_gne__c;
                    EditIssue.NEW_INDV_GIVEN_NM_gne__c = Issue.INDV_GIVEN_NM_gne__c;
                    EditIssue.NEW_INDV_MID_NM_gne__c = Issue.INDV_MID_NM_gne__c;
                    EditIssue.NEW_INDV_FMLY_NM_gne__c = Issue.INDV_FMLY_NM_gne__c;
                    EditIssue.NEW_INDV_GEN_SUFX_gne__c = Issue.INDV_GEN_SUFX_gne__c;
                    EditIssue.NEW_CRDL_VAL_TXT_gne__c = Issue.CRDL_VAL_TXT_gne__c;
                    //EditIssue.State_License_gne__c =
                    //EditIssue.License_Issue_State_gne__c =
                    
                    EditIssue.NEW_PRIM_ST_ADDR_gne__c = Issue.PRIM_ST_ADDR_gne__c;
                    EditIssue.NEW_UNIT_TYP_TXT_gne__c = Issue.UNIT_TYP_TXT_gne__c;
                    EditIssue.NEW_UNIT_VAL_TXT_gne__c = Issue.UNIT_VAL_TXT_gne__c;
                    EditIssue.NEW_CITY_NM_gne__c = Issue.CITY_NM_gne__c;
                    EditIssue.NEW_ST_CD_gne__c = Issue.ST_CD_gne__c;
                    EditIssue.NEW_PSTL_CD_gne__c = Issue.PSTL_CD_gne__c;
                    EditIssue.NEW_LNDLN_PHN_TXT_gne__c = Issue.LNDLN_PHN_TXT_gne__c;
                    EditIssue.NEW_LNDLN_PHN_EXT_TXT_gne__c = Issue.LNDLN_PHN_EXT_TXT_gne__c;
                } 
               
            }

            GenerateEnvVar();
            

        }
        catch (exception e)
        {
            return;
        }
    }

    public PageReference submitIssue()
    {
        try
        {
            All_User_Hierarchy_gne__c u = new All_User_Hierarchy_gne__c();
            
            if (EditIssue.Next_Action_Owner_gne__c != null)
            {
                //Check if user belongs to a Infrequent Enabled Profile
                u  = [select User_External_Id_gne__c, Active_gne__c,email_id__c
                from All_User_Hierarchy_gne__c
                Where Id = :EditIssue.Next_Action_Owner_gne__c limit 1];
                
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
                    system.debug('3333');
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
                    MAP<String,CADS_User_Exception_List_gne__c> exception_users = CADS_User_Exception_List_gne__c.getAll();
                    boolean CADS_User_Exception = false;
                    for(CADS_User_Exception_List_gne__c usr : exception_users.values())
                    {
                        if (usr.User_External_ID_gne__c == externalId)
                        {
                            CADS_User_Exception = true;
                        }
                    } 
                             
                    system.debug('4444');
                    if (Infrequent_enabled_profile == true && !CADS_User_Exception)
                    {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'The individual you have assigned is not authorized to resolve this Issue. Please select another individual'));
                        return null;
                    }
                }
            }
            system.debug('5555');
            Id NewActionId = null;
            //CP Update - 1
            system.debug('EditIssue.SFDC_USERID_gne__c :'+ EditIssue.SFDC_USERID_gne__c);
            if(EditIssue.SFDC_USERID_gne__c !=null){
                List<User> objUser = [Select Id, Name, Profile.Name, Email,External_ID_gne__c from User where IsActive = true and External_ID_gne__c =:EditIssue.SFDC_USERID_gne__c];           
                system.debug('objUser :' +objUser );
                if(objUser.size()>0){
                    Map<string,User>userObjMap =new Map<string, User>();
                    for(User userMap  :objUser){
                        if(!userObjMap.containsKey(userMap.External_ID_gne__c)){
                            userObjMap.put(userMap.External_ID_gne__c,userMap);
                        }   
                    }
                    EditIssue.SFDC_Profile_Name_gne__c =userObjMap.get(EditIssue.SFDC_USERID_gne__c).Profile.Name;              
                system.debug('EditIssue.SFDC_Profile_Name_gne__c:' +EditIssue.SFDC_Profile_Name_gne__c);
                system.debug('User Map result  :' +userObjMap.get(EditIssue.SFDC_USERID_gne__c).Profile.Name);
                }
            }
            List<CADS_IssueActionCondition_gne__c> actionConds = CADS_IssueActionCondition_gne__c.getAll().values();
            Map <string,CADS_IssueActionCondition_gne__c> actionConditions = new Map <string,CADS_IssueActionCondition_gne__c>();
            for (CADS_IssueActionCondition_gne__c cond :actionConds)
            {       
                if(!actionConditions.containskey(cond.Action_Code_Description_For_User_gne__c) )
                {
                    actionConditions.put(cond.Action_Code_Description_For_user_gne__c,cond);                    
                }            
            }
            List<Change_Request_gne__c> dcrList =  new List<Change_Request_gne__c>();
            Map<String,Change_Request_gne__c> dcrMap = new Map<String,Change_Request_gne__c>();
            
            dcrList = [Select Account_gne__c,Id, Name, Status_gne__c from Change_Request_gne__c where Status_gne__c !='Closed' and  Status_gne__c !='Ready to Close' and  Status_gne__c !='Ready to Load'];
            system.debug('dcrList  : '+dcrList.size());
            for(Change_Request_gne__c dcr :dcrList){
                if(!dcrMap.containsKey(dcr.Account_gne__c)){
                    dcrMap.put(dcr.Account_gne__c,dcr);         
                }       
            }
            //CP Update End  
            
            //........ Add action to action history
            Stewardship_Issue_Action_History_gne__c actionHistory = new Stewardship_Issue_Action_History_gne__c();
            actionHistory.Action_Condition_gne__c = EditIssue.Next_Action_Condition_gne__c;
            actionHistory.Action_Type_gne__c = EditIssue.Next_Action_Type_gne__c;
            
            if (SalesTeam)
            {
                Id DStwd_Id = [select id from All_User_Hierarchy_gne__c
                Where User_External_Id_gne__c = 'dstwd' limit 1].id;
                system.debug('avccc : '+DStwd_Id);
                actionHistory.Action_Owner_gne__c = DStwd_Id;  //action owner = Data Stewardship team
            } 
            else
            {
                actionHistory.Action_Owner_gne__c = EditIssue.Next_Action_Owner_gne__c;
            }               
            actionHistory.Comment_gne__c = EditIssue.Next_Action_Comment_gne__c;
            actionHistory.Issue_Id_gne__c = EditIssue.id;
            actionHistory.Email_Address_gne__c = u.email_id__c;
            actionHistory.Email_Status_gne__c ='Not Sent';
            if(actionConditions.get(EditIssue.Next_Action_Condition_gne__c) !=null){
                actionHistory.Action_Condition_Type_gne__c=actionConditions.get(EditIssue.Next_Action_Condition_gne__c).Action_Condition_Type_gne__c; //CP Update - 2
            }
            if(actionConditions.get(EditIssue.Next_Action_Condition_gne__c) !=null){
                    actionHistory.Action_Code_gne__c=actionConditions.get(EditIssue.Next_Action_Condition_gne__c).Action_Code_gne__c; 
                }        
            
            insert actionHistory;
            NewActionId = actionHistory.Id;
            system.debug('666');
            //.......... get action details for latest action fron action history
            Stewardship_Issue_Action_History_gne__c a = [Select Action_Type_gne__c, Action_Condition_gne__c,
            Action_Owner_gne__c, Action_Condition_Type_gne__c,
            Comment_gne__c,Email_Address_gne__c,
            CreatedDate, CreatedById,Action_Code_gne__c,
            LastModifiedDate, LastModifiedById
            From Stewardship_Issue_Action_History_gne__c
            Where id = :NewActionId ];
            
            EditIssue.Current_Action_Type_gne__c = a.Action_Type_gne__c;
            EditIssue.Current_Action_Condition_gne__c = a.Action_Condition_gne__c;
            EditIssue.Current_Action_Comment_gne__c = a.Comment_gne__c;
            EditIssue.Current_Action_Owner_gne__c = a.Action_Owner_gne__c;
            EditIssue.Current_Action_Created_By_gne__c = a.CreatedById;
            EditIssue.Current_Action_Created_Date_gne__c =a.CreatedDate;
            EditIssue.Current_Action_Last_Modified_By_gne__c = a.LastModifiedById;
            EditIssue.Current_Action_Last_Modified_Date_gne__c = a.LastModifiedDate;
            EditIssue.Current_Action_Condition_Type_gne__c=a.Action_Condition_Type_gne__c;  //CP Update - 3 
            EditIssue.Current_Action_Code_gne__c =a.Action_Code_gne__c;
            EditIssue.Next_Action_Comment_gne__c = null;
            EditIssue.Next_Action_Owner_gne__c= null;
            EditIssue.Next_Action_Type_gne__c= null;
            EditIssue.Next_Action_Condition_gne__c= null;
            EditIssue.Alert_User_Email_Id_gne__c = a.Email_Address_gne__c;
            EditIssue.Current_Action_Email_Status_gne__c = 'Not Sent';
            EditIssue.Is_Alert_User_Active_gne__c = true;
            system.debug('APRMO_SFDC_gne__c  :'+EditIssue.APRMO_SFDC_gne__c);
            system.debug('DCRmapContainsKey :' +dcrMap.ContainsKey(EditIssue.APRMO_SFDC_gne__c));
            if(EditIssue.APRMO_SFDC_gne__c !=null && dcrMap.ContainsKey(EditIssue.APRMO_SFDC_gne__c)){
                EditIssue.Has_DCR_gne__c = True;                                      
            }
            //If reopening an issue, make Issue Closed Date as Null
            if (mode == 'reopen' && a.Action_Type_gne__c != 'Approve')
            {
                EditIssue.Issue_Closed_Date_gne__c = null;
            }
            
            
            if (a.Action_Type_gne__c == 'Approve')
            {
                EditIssue.Processing_STS_gne__c = 'Submitted';
                EditIssue.Issue_Closed_Date_gne__c = a.CreatedDate;
                EditIssue.STEWARD_REVIEW_STS_gne__c='N'; //CP Update -4
            } 
            else if(a.Action_Type_gne__c == 'Review')
            {
                EditIssue.Processing_STS_gne__c = 'Modified';
                EditIssue.Manual_Action_gne__c = 'Yes';
                EditIssue.STEWARD_REVIEW_STS_gne__c='Y'; //CP Update -5 -End of CP Update
            }else
            {
                EditIssue.Processing_STS_gne__c = 'Unmodified';
                EditIssue.Manual_Action_gne__c = 'Yes';
                EditIssue.STEWARD_REVIEW_STS_gne__c='Y';            
            }         
            update EditIssue;  
            
            //.....Close all previous actions of this issue
            List<Stewardship_Issue_Action_History_gne__c> prevIssue = [Select Id,Is_Closed_gne__c
            From Stewardship_Issue_Action_History_gne__c
            Where Issue_Id_gne__c = :EditIssue.id 
            and Is_Closed_gne__c = false
            and Id <> :NewActionId];
            
            List<Stewardship_Issue_Action_History_gne__c> prevIssue_updatedList = new List<Stewardship_Issue_Action_History_gne__c>() ;
            
            for (Stewardship_Issue_Action_History_gne__c pIssue : prevIssue)
            {
                pIssue.Is_Closed_gne__c = true;
                pIssue.Closed_Date_gne__c = datetime.now();
                prevIssue_updatedList.add (pIssue);
            }
            update prevIssue_updatedList;       
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,'Data Submitted.'));
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
            return null;
        }
        
        PageReference pgRef_ViewIssue = null;
        if(!SalesTeam)
        {
            pgRef_ViewIssue = new PageReference(getKeyPrefix());
            //pgRef_ViewIssue = new PageReference('/a40/o');
        }
        else
        {
            pgRef_ViewIssue = Page.GNE_SFA2_CADS_My_Issues;
        }
        pgRef_ViewIssue.setRedirect(true);
        return pgRef_ViewIssue;
    }
    
    public PageReference saveIssue()
    {
        try
        {
            EditIssue.Processing_STS_gne__c = 'Modified';
            
            if (mode == 'reopen'){
                EditIssue.Issue_Closed_Date_gne__c = null;
            }
            
            EditIssue.Next_Action_Comment_gne__c = null;
            EditIssue.Next_Action_Owner_gne__c= null;
            EditIssue.Next_Action_Type_gne__c= null;
            EditIssue.Next_Action_Condition_gne__c= null;
            
            update EditIssue;   
        }
        catch (Exception e){
            ApexPages.addMessages(e);
            return null;
        }
        PageReference pgRef_ViewIssue = null;
        pgRef_ViewIssue = new PageReference('/' + IssueId + '?tab='+tab);
        pgRef_ViewIssue.setRedirect(true);
        return pgRef_ViewIssue; 
    }      

    public PageReference reopenIssue(){     
        PageReference pgRef_EditIssue = null;
        pgRef_EditIssue = new PageReference('/apex/GNE_SFA2_CADS_Issue_Edit_Layout?id=' + IssueId + '&mode=reopen&tab='+tab);
        pgRef_EditIssue.setRedirect(true); 
        return pgRef_EditIssue;
    }

    public PageReference edit(){
        PageReference pgRef_EditIssue = null;
        pgRef_EditIssue = new PageReference('/apex/GNE_SFA2_CADS_Issue_Edit_Layout?id=' + IssueId + '&tab='+tab);
        pgRef_EditIssue.setRedirect(true); 
        return pgRef_EditIssue;
    }

    public PageReference cancel(){
        PageReference pgRef_ViewIssue = null;
        if(!SalesTeam)
        {
            pgRef_ViewIssue = new PageReference('/' + IssueId + '?tab='+tab);
        }
        else
        {
            pgRef_ViewIssue = Page.GNE_SFA2_CADS_My_Issues;
        }
        //pgRef_ViewIssue = new PageReference('/' + IssueId + '?tab='+tab);
        pgRef_ViewIssue.setRedirect(true);
        return pgRef_ViewIssue; 
    }

    public PageReference back(){
        if (tab == 'myissues' || SalesTeam){
            PageReference pgRef = Page.GNE_SFA2_CADS_My_Issues;
            pgRef.setRedirect(true);
            return pgRef; 
        }
        else{
            PageReference pageRef_IssueList = new PageReference(getKeyPrefix());
            return pageRef_IssueList;
        }
    }

    private PageReference GetProductMetricsPage(string URL)
    {
        PageReference productMetricsPage = new PageReference(URL);
        productMetricsPage.setRedirect(true);
        return productMetricsPage ;
    }
    
    public void GenerateEnvVar()
    {
        env_var = GNE_CM_Environment_variable.get_env_variable(variable);
        for (integer i = 0; i < env_var.size(); i++)
        {
            environment_var_val.put(env_var[i].Key__c, env_var[i].Value__c); 
        }
    }
    
    public CADS_Account_Address_Issues_gne__c getIssue(){
        return Issue;
    }
    
    public CADS_Account_Address_Issues_gne__c getEditIssue(){
        return EditIssue;
    }
    
    public boolean getShowHistoryBtn(){
        return ShowHistoryBtn;
    }
    
    public boolean getShowEditBtn(){
        return ShowEditBtn;
    }    
    
    public boolean getHideMsg(){
        return HideSubmitMsg;
    }
    public boolean getShowSubmitBtn(){
        return showSubmitBtn;
    }
    public boolean getSalesTeam(){
        return SalesTeam;
    }
    public PageReference ShowList(){
        PageReference pageRef_IssueList = new PageReference(getKeyPrefix());
        return pageRef_IssueList;
    }
    
    public String getMode(){
        return mode;
    }
    public String getTab(){
        return tab;
    }
    
    public boolean getShowTransactionHistoryBtn(){
        return ShowTransactionHistoryBtn;
    }
    public string BO_URL
    { 
        get
        {
            try
            {
                return 'https://'+environment_var_val.get('Bo_Report_Variable')+'/OpenDocument/opendoc/openDocument.jsp?sType=wid&sDocName=Source%20Party%20Transactions%20Report&sPath=[Commercial],[AGS],[2.%20Management%20and%20Compliance%20Reporting]&sRefresh=Y&sWindow=New&lsSSRC_PTY_ID='+Issue.SRC_PTY_KEY_gne__c;
            }
            catch(Exception ex)
            {
            } 
            return '';
        }
        set; 
    }
    
    public string GetHost
    { 
        get
        {
            return 'https://'+ApexPages.currentPage().getHeaders().get('Host');
        }
        set; 
    }
    
    /*public String getQuickSaveValue() {
        return quickSaveValue;
    }
    
    public void setQuickSaveValue(String quickSaveValue) 
    { 
        this.quickSaveValue = quickSaveValue; 
    }*/

    public PageReference qetHcpDetails()
    {
        try
        {
            string sId = addAttendeeFormSubmit(sAddAddrId);
            if(!Utility.isNull(sId)){
                this.receivedAttendee = addPersonAccount(sId); 
            }
            this.EditIssue.NEW_INDV_GIVEN_NM_gne__c = this.receivedAttendee.firstname;
            this.EditIssue.NEW_INDV_FMLY_NM_gne__c = this.receivedAttendee.lastName;
            this.EditIssue.NEW_INDV_BUS_EMAIL_ADDR_TXT_gne__c = this.receivedAttendee.email;
            this.EditIssue.NEW_INDV_BUS_CLL_PHN_TXT_gne__c = this.receivedAttendee.cellPhone;
            this.EditIssue.NEW_INDV_MID_NM_gne__c= this.receivedAttendee.middleName;
            this.EditIssue.New_ORG_FULL_NM_gne__c= this.receivedAttendee.organization;
            this.EditIssue.NEW_PRIM_ST_ADDR_gne__c= this.receivedAttendee.address;
            this.EditIssue.NEW_UNIT_VAL_TXT_gne__c= this.receivedAttendee.unitNumber;
            this.EditIssue.NEW_CITY_NM_gne__c= this.receivedAttendee.city;
            this.EditIssue.NEW_ST_CD_gne__c= this.receivedAttendee.state;
            this.EditIssue.NEW_PSTL_CD_gne__c= this.receivedAttendee.postalCode;
            this.EditIssue.NEW_CNTRY_CD_gne__c= this.receivedAttendee.country;
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unexpected Exception: Message = qetHcpDetails'+ex.getMessage()));
        }  
        return null; 
    }
   
    
    public string addAttendeeFormSubmit(string id)
    {
        isSubscribeSuccess = '';
        try
        {
            String sAddHCPId = '';
            if (!Utility.isNull(id)) 
            {
                if (sAddAddrId.startsWith(Schema.SObjectType.Account.getKeyPrefix()))
                {
                    sAddHCPId = id;
                } 
                else if (id.startsWith(Schema.SObjectType.Address_vod__c.getKeyPrefix()))
                {
                    SAddHCPAddressId = id;
                    acctDao = new GNE_Account_Dao(false);
                    sAddHCPId = acctDao.getAccountIdForAddressId(sAddAddrId);
                } 
                else    
                {     
                    ptyDao = new GNE_Stg_Party_Dao(false);
                    try
                    {
                        Account acct = ptyDao.subscribeAddress(id);
                        sAddHCPId = acct.Id;
                    }
                    catch(Exception ex)
                    {
                        isSubscribeSuccess = 'The account cannot be added.';
                        return '';
                    }
                }  
                sAddHCPIdType = 'Account';  
            }
            return sAddHCPId;
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unexpected Exception: Message = addAttendeeFormSubmit'+ex.getMessage()));
        }   
        return '';
    }
    
    public class Attendee{
        public String id{get;set;}
        
        public String organization{get;set;}  
        public String firstname {get;set;}
        public String cellPhone {get;set;}
        public String comment {get;set;}
        public String sourceVendorReference {get;set;}
        public String sourceVendorReferenceValue {get;set;}
        public String middleName {get;set;}
        public String lastName {get;set;}
        public String generationSuffix {get;set;}
        public String email {get;set;}
        public String credentialType {get;set;}
        
        public String address{get;set;} 
        public String unitNumber {get;set;}
        public String city {get;set;}
        public String country {get;set;}
        public String businessPhone {get;set;}
        public String unitType {get;set;}
        public String institutionalLevel {get;set;}
        public String postalCode {get;set;}
        public String businessExtension {get;set;}
        public String state {get;set;}
    }
    
    private Attendee addPersonAccount(String addHCPId){      
        Account acct; 
        String acctPrimaryAdd = '';
        Attendee tempAttendee = new Attendee();
        
        try
        {
            acct = [Select id,name,FirstName,Middle_Name_gne__pc,LastName,PersonEmail,Cell_Phone_gne__c,Organization_gne__c,(select id, Name,Country_gen__c,Address_line_2_vod__c,City_vod__c, State_vod__c,Zip_vod__c from Address_vod__r) from Account where id = :addHCPId];
            System.Debug('-------------------acct'+acct);
            if(acct!=null)
            {
                Address_vod__c selectedAddr;
                if (!Utility.isNull(SAddHCPAddressId))
                {
                    if(acct.Address_vod__r != null)
                    {
                        for (Address_vod__c addrRow : acct.Address_vod__r)
                        {
                            if (addrRow.Id == SAddHCPAddressId)
                            {
                                selectedAddr = addrRow;                             
                            }
                        }
                    }   
                }   
                System.Debug('-------------------selectedAddress1'+selectedAddr);
                if (selectedAddr == null && acct.Address_vod__r != null && acct.Address_vod__r.size() > 0)
                { 
                    selectedAddr = acct.Address_vod__r[0];
                }
                
                if (!Utility.isNull(selectedAddr.Name))
                { 
                    tempAttendee.address = selectedAddr.Name; 
                } 
                else
                {
                    tempAttendee.address = ''; 
                }   
                if (!Utility.isNull(selectedAddr.Address_line_2_vod__c))
                { 
                    tempAttendee.unitNumber = selectedAddr.Address_line_2_vod__c; 
                }
                else
                {
                    tempAttendee.unitNumber = ''; 
                } 
                if (!Utility.isNull(selectedAddr.City_vod__c))
                { 
                    tempAttendee.city = selectedAddr.City_vod__c;
                } 
                else
                {
                    tempAttendee.city = ''; 
                }    
                if (!Utility.isNull(selectedAddr.State_vod__c))
                { 
                    tempAttendee.state = selectedAddr.State_vod__c;
                }
                else
                {
                    tempAttendee.state = ''; 
                } 
                if (!Utility.isNull(selectedAddr.Zip_vod__c))
                { 
                    tempAttendee.postalCode = selectedAddr.Zip_vod__c;
                }
                else
                {
                    tempAttendee.postalCode = ''; 
                } 
                if (!Utility.isNull(selectedAddr.Country_gen__c))
                { 
                    tempAttendee.country = selectedAddr.Country_gen__c;
                }
                else
                {
                    tempAttendee.country = ''; 
                } 
                
                if (!Utility.isNull(acct.id))
                { 
                    tempAttendee.id = acct.id;
                }
                else
                {
                    tempAttendee.id = ''; 
                } 
                if (!Utility.isNull(acct.FirstName))
                { 
                    tempAttendee.firstname = acct.FirstName;
                }
                else
                {
                    tempAttendee.firstname = ''; 
                } 
                if (!Utility.isNull(acct.LastName))
                { 
                    tempAttendee.lastName = acct.LastName;
                }
                else
                {
                    tempAttendee.lastName = ''; 
                } 
                if (!Utility.isNull(acct.PersonEmail))
                { 
                    tempAttendee.email = acct.PersonEmail;
                }
                else
                {
                    tempAttendee.email = ''; 
                } 
                if (!Utility.isNull(acct.Cell_Phone_gne__c))
                { 
                    tempAttendee.cellPhone = acct.Cell_Phone_gne__c;
                }  
                else
                {
                    tempAttendee.cellPhone = ''; 
                }   
                if (!Utility.isNull(acct.Middle_Name_gne__pc))
                { 
                    tempAttendee.middleName = acct.Middle_Name_gne__pc;
                } 
                else
                {
                    tempAttendee.middleName = ''; 
                }  
                if (!Utility.isNull(acct.Organization_gne__c))
                { 
                    tempAttendee.organization = acct.Organization_gne__c;
                }    
                else
                {
                    tempAttendee.organization = ''; 
                }         
            }
            return tempAttendee;
        } 
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unexpected Exception: Message = addPersonAccount'+ex.getMessage()));
            return null;
        }          
        return tempAttendee;
    }
    
    public string acName
    {
       get
       {
            return this.EditIssue.NEW_INDV_GIVEN_NM_gne__c;
       }
       set
       {
            this.EditIssue.NEW_INDV_GIVEN_NM_gne__c = value;
       } 
    }
    
    public string acLastName
    {
        get
        {
            return this.EditIssue.NEW_INDV_FMLY_NM_gne__c;
        }
        set
        {
            this.EditIssue.NEW_INDV_FMLY_NM_gne__c = value;
        }
    }
    
    public string acEmail
    {
        get
        {
            return this.EditIssue.NEW_INDV_BUS_EMAIL_ADDR_TXT_gne__c;
        }
        set
        {
            this.EditIssue.NEW_INDV_BUS_EMAIL_ADDR_TXT_gne__c = value;
        }
    }
    
    public string acCellPhone
    {
        get
        {
            return this.EditIssue.NEW_INDV_BUS_CLL_PHN_TXT_gne__c;
        }
        set
        {
            this.EditIssue.NEW_INDV_BUS_CLL_PHN_TXT_gne__c = value;
        }
    }
    
    public string acMiddleName
    {
        get
        {
            return this.EditIssue.NEW_INDV_MID_NM_gne__c;
        }
        set
        {
            this.EditIssue.NEW_INDV_MID_NM_gne__c = value;
        }
    }
    
    public string acOrganization
    {
        get
        {
            return this.EditIssue.New_ORG_FULL_NM_gne__c;
        }
        set
        {
            this.EditIssue.New_ORG_FULL_NM_gne__c = value;
        }
    }
    
    public string adAddress
    {
        get
        {
            return this.EditIssue.NEW_PRIM_ST_ADDR_gne__c;
        }
        set
        {
            this.EditIssue.NEW_PRIM_ST_ADDR_gne__c = value;
        }
    }
    
    public string adUnitNumber
    {
        get
        {
            return this.EditIssue.NEW_UNIT_VAL_TXT_gne__c;
        }
        set
        {
            this.EditIssue.NEW_UNIT_VAL_TXT_gne__c = value;
        }
    }
    
    public string adCity
    {
        get
        {
            return this.EditIssue.NEW_CITY_NM_gne__c;
        }
        set
        {
            this.EditIssue.NEW_CITY_NM_gne__c = value;
        }
    }
    
    public string adState
    {
        get
        {
            return this.EditIssue.NEW_ST_CD_gne__c;
        }
        set
        {
            this.EditIssue.NEW_ST_CD_gne__c = value;
        }
    }
    
    public string adPostalCode
    {
        get
        {
            return this.EditIssue.NEW_PSTL_CD_gne__c;
        }
        set
        {
            this.EditIssue.NEW_PSTL_CD_gne__c = value;
        }
    }
    
    public string adCountry
    {
        get
        {
            return this.EditIssue.NEW_CNTRY_CD_gne__c;
        }
        set
        {
            this.EditIssue.NEW_CNTRY_CD_gne__c = value;
        }
    }
    
    public List<SelectOption> getStates() {
       List<SelectOption> options = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult =  CADS_Account_Address_Issues_gne__c.NEW_ST_CD_gne__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('', '-None-'));
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }  
       return options;
    }   
    
    public List<SelectOption> getUnitTypes() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', '-None-'));
       options.add(new SelectOption('APT', 'APT'));
       options.add(new SelectOption('BLDG', 'BLDG'));
       options.add(new SelectOption('BRNCH', 'BRNCH'));
       options.add(new SelectOption('DEPT', 'DEPT'));
       options.add(new SelectOption('POBOX', 'POBOX'));
       options.add(new SelectOption('RM', 'RM'));
       options.add(new SelectOption('STE', 'STE'));
       options.add(new SelectOption('UNIT', 'UNIT'));
       return options;
    }    
    public String getRadioItemValue() {
        return radioItemValue;
    }
    
    public void setRadioItemValue(String quickSaveValue) 
    { 
        this.radioItemValue = radioItemValue; 
    }

    public List<SelectOption> getRadioItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Added or Corrected Information','Customer')); 
        options.add(new SelectOption('Is a GNE Employee','Genentech Employee'));
        options.add(new SelectOption('Is a GNE Partner','Genentech Partner')); 
        options.add(new SelectOption('Is a GNE Vendor','Genentech Vendor')); 
        options.add(new SelectOption('Is an International Customer','International Party'));
        options.add(new SelectOption('See Comment','Unable to provide response(Please enter comment)')); 
        return options; 
    }   
}