public without sharing class AGS_Action_Creation_Controller
{
    static String DEFAULT_TIME_ZN = 'America/Los_Angeles';
    static String DEFAULT_LOCALE_KEY = 'en_US';
    static String DEFAULT_EMAIL_KEY = 'ISO-8859-1';
    static String DEFAULT_LANG_LOC_KEY = 'en_US';
    
    public AGS_Action_Creation_Controller(ApexPages.StandardController controller) 
    {
    }

    public String sRetUrl='';
    public String sErrMessage{get; set;}    
    public String sActionPicklist{get; set;}
    Boolean blRedirect = false;
    AGS_Case_Action_gne__c objAGSCaseaction = new AGS_Case_Action_gne__c();
    AGS_Case_gne__c objAGScase = new AGS_Case_gne__c();
    set<string> spendUserSet = new set<string>();
    set<string> resolverSet = new set<string>();
    set<string> managersUnixid = new set<string>();
    set<string> UserSetAGGClosedActions = new set<string>();
    List<RecordType> RecTypeNEW = new List<RecordType>([select Name, Id from RecordType where Name like 'AGS%']);
    Map<String, RecordType> AGS_RecTypes_map;    
    
    public AGS_Action_Creation_Controller(ApexPages.StandardSetController controller)
    {               
        sActionPicklist='None';
        if(ApexPages.currentPage().getParameters().get('id')!=null)
        {
            sRetUrl=ApexPages.currentPage().getParameters().get('id');
            system.debug('sRetUrl :'+sRetUrl);
        }
    }
    public AGS_Action_Creation_Controller()
    {
    }
    
    public AGS_Case_Action_gne__c getObjAGSCaseaction()
    {
        try
        {
            objAGSCase = [select Id, Name from AGS_Case_gne__c where Id=:sRetUrl];
        }
        catch(Exception e)
        {
        }
        if(objAGSCase!=null && objAGSCase.Id!=null)
        {
            objAGSCaseaction.AGS_Case_gne__c = objAGSCase.Id;
        }       
        return objAGSCaseaction;    
    }
    
    //SAVE BUTTON    
    public PageReference autoRun() {
        System.debug('Made It to AutoRun');
        try {
            objAGSCase = [select Id, Name,Reason_Type_gne__c from AGS_Case_gne__c where Id=:sRetUrl];
        } catch(Exception ex){
            // Nothing to do
        }
        
        if(objAGSCase!=null && objAGSCase.Id!=null) {
            objAGSCaseaction.AGS_Case_gne__c = objAGSCase.Id;
            system.debug('objAGSCase.Id :' +objAGSCase.Id);
        } 
        
        List<AGSSpendCCOCase_gne__c> juncObj = new List<AGSSpendCCOCase_gne__c>
            ([select AGS_Case_gne__r.Name, 
            AGS_Spend_Expense_Transaction_gne__r.Spend_User_gne__c,
            AGS_Case_gne__r.Resolver_gne__c,
            User_External_ID__c,
            AGS_Case_gne__r.Reason_Type_gne__c,
            AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c, 
            AGS_Case_gne__r.Inactive_resolver__r.Active_gne__c,
            AGS_Case_gne__r.Inactive_resolver__r.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c,                                              
            User_from_AllUserHeirarchy__r.All_User_Hierarchy_Level1_gne__c,
            User_from_AllUserHeirarchy__r.Active_gne__c,
            User_from_AllUserHeirarchy__r.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c
            from AGSSpendCCOCase_gne__c where AGS_Case_gne__c=:objAGSCaseaction.AGS_Case_gne__c]);
        
        system.debug('juncObj :'+  juncObj);
        system.debug('objAGSCaseaction.AGS_Case_gne__c :'+  objAGSCaseaction.AGS_Case_gne__c);
        
        All_User_Hierarchy_gne__c dummy = [Select Id, User_External_Id_gne__c from All_User_Hierarchy_gne__c  where User_External_Id_gne__c = :Utilities.noSpendUser];
        
        for (AGSSpendCCOCase_gne__c ju : juncObj) {
            if(ju.AGS_Case_gne__r.Resolver_gne__c != null) {
                if(ju.AGS_Case_gne__r.Inactive_resolver__r.Active_gne__c) {
                    User usr = [SELECT Id, isActive FROM User WHERE External_ID_gne__c = :ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c LIMIT 1];
                    if(usr != null && usr.isActive) {
                        resolverSet.add(ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c); 
                        UserSetAGGClosedActions.add(ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c);
                    } else {
                        resolverSet.add(dummy.User_External_Id_gne__c); 
                        UserSetAGGClosedActions.add(dummy.User_External_Id_gne__c);
                    }
	                if(ju.AGS_Case_gne__r.Inactive_resolver__r.All_User_Hierarchy_Level1_gne__c != null) {
	                    managersUnixid.add(ju.AGS_Case_gne__r.Inactive_resolver__r.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c);
	                }
                } else {
                    resolverSet.add(dummy.User_External_Id_gne__c); 
                    UserSetAGGClosedActions.add(dummy.User_External_Id_gne__c);
                }             
                system.debug('Resolver External ID :'+  resolverSet);
            } else {
                sErrMessage= 'There is NO case resolver, please assign a resolver to the case!';
                return null;
            }
            if (ju.User_from_AllUserHeirarchy__c !=null && ju.User_from_AllUserHeirarchy__r.Active_gne__c) {
                if(ju.User_External_ID__c != null) {
                    User usr = [SELECT Id, isActive FROM User WHERE External_ID_gne__c = :ju.User_External_ID__c LIMIT 1];
                    if(usr != null && usr.isActive) {
                        spendUserSet.add(ju.User_External_ID__c);
                        UserSetAGGClosedActions.add(ju.User_External_ID__c);
                        //managersUnixid.add(ju.User_from_AllUserHeirarchy__r.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c);
                    } else {
                        spendUserSet.add(dummy.User_External_Id_gne__c);
                        UserSetAGGClosedActions.add (dummy.User_External_Id_gne__c);
                    }
                } else {
                    spendUserSet.add(dummy.User_External_Id_gne__c);
                    UserSetAGGClosedActions.add (dummy.User_External_Id_gne__c);
                }
            } else {
                spendUserSet.add(dummy.User_External_Id_gne__c);
                UserSetAGGClosedActions.add (dummy.User_External_Id_gne__c);
                system.debug('Prakash 12 :'+  ju.AGS_Case_gne__r.Inactive_resolver__r.User_External_Id_gne__c);
            }
            system.debug(' Spend User External ID' + spendUserSet);
        }
        set<string> UnixidSet = new set<string>(resolverSet);
        UnixidSet.addAll(spendUserSet);
        UnixidSet.addAll(UserSetAGGClosedActions);
        UnixidSet.addAll(managersUnixid);
        system.debug('UnixidSet which includes Manager, SpendUser, Resolver  :'+UnixidSet);
        
        List<All_User_Hierarchy_gne__c> activeUserListAUH = new List <All_User_Hierarchy_gne__c> ([Select ID, User_External_Id_gne__c from All_User_Hierarchy_gne__c where Active_gne__c = True and User_External_Id_gne__c IN :UnixidSet ]);
        List<User> userlistFromUser = new List<User> ([select ID,External_ID_gne__c,isactive,profile_name_gne__c from User where External_ID_gne__c in : UnixidSet and UserType ='Standard' order by email]);
        set<string> userHierarchy = new set<string>();
        set<string> userTable = new set<string>();
        List<User> userToActivate = new List<User>();
        
        for (All_User_Hierarchy_gne__c usr   :activeUserListAUH) 
        { 
            if (!userHierarchy.contains(usr.User_External_Id_gne__c))
            {
                userHierarchy.add(usr.User_External_Id_gne__c);
            }
        }
        
        for (User usr  :userlistFromUser)
        {
            if(!usr.isactive && usr.profile_name_gne__c =='GNE-INFREQUENT-USER')
            {
                if (!UserTable.contains(usr.External_ID_gne__c))
                {
                    UserTable.add(usr.External_ID_gne__c);
                    userToActivate.add(usr);
                }
            }
            else if(!usr.isactive && usr.profile_name_gne__c !='GNE-INFREQUENT-USER')
            {
                if (!UserTable.contains(usr.External_ID_gne__c))
                    UserTable.add(usr.External_ID_gne__c);
                if(resolverSet.contains(usr.External_ID_gne__c))
                    resolverSet.add(dummy.User_External_Id_gne__c);
                if(spendUserSet.contains(usr.External_ID_gne__c))
                    spendUserSet.add(dummy.User_External_Id_gne__c);
                if(UserSetAGGClosedActions.contains(usr.External_ID_gne__c))
                    UserSetAGGClosedActions.add(dummy.User_External_Id_gne__c);
                if(managersUnixid.contains(usr.External_ID_gne__c)) 
                    managersUnixid.add(dummy.User_External_Id_gne__c);
            }
            else if (usr.isactive)
            {
                if (!UserTable.contains(usr.External_ID_gne__c))
                    UserTable.add(usr.External_ID_gne__c);
            }
        }
        
        for(User usr: userToActivate)
        {
            usr.isactive = true;
        }
        update userToActivate;
        
        set<string> setUserActivation = new set<string>(userHierarchy);
        system.debug('userHierarchy :'+userHierarchy);
        system.debug('UserTable :'+UserTable);
        
        setUserActivation.removeAll(UserTable);
        system.debug('setUserActivation :'+setUserActivation);
        
        if (setUserActivation != null && setUserActivation.size()>0)
        {
            for ( string usr :setUserActivation)
            {
                //CreateINFUUser(usr);
            }
        }
        return null;
    }
    
    public PageReference Saveaction() {
        try {
            objAGSCase = [select Id, Name,Reason_Type_gne__c from AGS_Case_gne__c where Id=:sRetUrl];
        } catch(Exception ex) {
            // Nothing to do
        }

        system.debug('RecTypeNEW  :'+RecTypeNEW);
        AGS_RecTypes_map= new Map<String, RecordType>();
        for(RecordType r :RecTypeNEW) {
            AGS_RecTypes_map.put(r.name, r);                
        }
        system.debug('AGS_RecTypes_map'+AGS_RecTypes_map);
        
        if(sActionPicklist==null || sActionPicklist=='None') {
            sErrMessage='Please enter value for Case Action';
            return null;
        }
        
        System.debug('objAGSCaseaction.AGS_Case_gne__c: '+objAGSCaseaction.AGS_Case_gne__c);
        System.debug('ResolverSet: '+resolverSet);

        List< AGS_Case_Action_gne__c> lstCaseActionInsert= new List< AGS_Case_Action_gne__c>();

        List<User> usr_list = new List<User>([
            SELECT Id, Name, Email, IsActive, External_ID_gne__c
            FROM User 
            WHERE External_ID_gne__c IN :resolverSet AND IsActive = true AND UserType = 'Standard' 
            ORDER BY Email]);
        system.debug('usr_list :'+usr_list);
        for(Integer i=0; i <usr_list.size(); i++) {
            AGS_Case_Action_gne__c aca;
            if(sActionPicklist == 'Please Validate Data') {
                aca = createCaseAction(usr_list[i] ,AGS_RecTypes_map.get('AGS Case Action-ValidateData-Edit-Rect'));
            } else if(sActionPicklist == 'Please Validate Data - Follow Up') {
                aca = createCaseAction(usr_list[i] ,AGS_RecTypes_map.get('AGS Case Action-ValidateDataFollowUp-Edit-Rect'));
            } else if(sActionPicklist == 'Confirm Compliance Understanding') {
                aca = createCaseAction(usr_list[i] ,AGS_RecTypes_map.get('AGS Case Action-ConfirmCompliance-Edit-Rect'));
            } else if(sActionPicklist == 'Alert') {
                aca = createCaseAction(usr_list[i] ,AGS_RecTypes_map.get('AGS Case Action-SendCustomNotification-Edit-Rect'));
            }
            if (aca !=null)
                lstCaseActionInsert.add(aca);
        }

        if(objAGSCase.Reason_Type_gne__c =='Instance Rule') {
            for (Integer i=0; i <usr_list.size(); i++) {
                AGS_Case_Action_gne__c aca;
                if(sActionPicklist == 'Close Case - No Issue') {
                    aca = createCaseAction(usr_list[i] ,AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'));
                } else if(sActionPicklist == 'Close Case - Issue Resolved') {
                    aca = createCaseAction(usr_list[i] ,AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'));
                } else if(sActionPicklist == 'Close Case - HCO To Resolve') {
                    aca = createCaseAction(usr_list[i] ,AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'));
                } else if(sActionPicklist == 'Close Case - No Notification') {
                    aca = createCaseAction(usr_list[i] ,AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'));
                }
                if (aca !=null)
                    lstCaseActionInsert.add(aca);
            }
        }

        if(objAGSCase.Reason_Type_gne__c =='Aggregation Rule' || objAGSCase.Reason_Type_gne__c =='Manual' ) {
            List<User> usrListClosedActions = new List<User>([
                SELECT Id, Name, Email, IsActive, External_ID_gne__c 
                FROM User 
                WHERE External_ID_gne__c IN :UserSetAGGClosedActions AND IsActive = true AND UserType = 'Standard' 
                ORDER BY Email]);
            for (Integer i=0; i<usrListClosedActions.size(); i++) {
                AGS_Case_Action_gne__c aca;
                if(sActionPicklist == 'Close Case - No Issue') {
                    aca = createCaseAction(usrListClosedActions[i] ,AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'));
                } else if(sActionPicklist == 'Close Case - Issue Resolved') {
                    aca = createCaseAction(usrListClosedActions[i] ,AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'));
                } else if(sActionPicklist == 'Close Case - HCO To Resolve') {
                    aca = createCaseAction(usrListClosedActions[i] ,AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'));
                } else if(sActionPicklist == 'Close Case - No Notification') {
                    aca = createCaseAction(usrListClosedActions[i] ,AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect'));
                }
                if (aca !=null)
                    lstCaseActionInsert.add(aca);
            }
        }

        List<User> usrSpendList = new List<User>([
            SELECT Id, Name, Email, IsActive, External_ID_gne__c 
            FROM User 
            WHERE External_ID_gne__c IN :spendUserSet AND IsActive = true AND UserType = 'Standard' 
            ORDER BY Email]); 
        system.debug('usrSpendList :'+usrSpendList);
        for(Integer i=0; i<usrSpendList.size(); i++) {
            AGS_Case_Action_gne__c aca ;
            if(sActionPicklist == 'Aggregate Recommended Spending Limit Reached') {
                aca = createCaseAction(usrSpendList[i] ,AGS_RecTypes_map.get('AGS Case Action-SendAggregationLimit-Edit-Rect'));
            } else if(sActionPicklist == 'Acknowledge Aggregate Spending Limit Reached') {
                aca = createCaseAction(usrSpendList[i] ,AGS_RecTypes_map.get('AGS Case Action-AcknowledgeStopSpending-Edit-Rect'));
            } else if(sActionPicklist == 'Acknowledge Aggregate Legal Spending Limit Reached') {
                aca = createCaseAction(usrSpendList[i] ,AGS_RecTypes_map.get('AGS Case Action-AcknowledgeStopSpending-Edit-Rect'));
            }
            if (aca !=null)
                lstCaseActionInsert.add(aca);
        }
        if(sActionPicklist == 'Confirm Compliance Understanding - Manager Escalated') {
            system.debug('Prakash 16 List size' + managersUnixid.size());
            if(managersUnixid.size()==0) {
                sErrMessage='The Resolver has no first level Manager';
                return null;
            }
            
            List<User> usrManagerList = new List<User>
            ([select email, 
            name, id,Isactive,External_ID_gne__c
            from User where External_ID_gne__c in : managersUnixid and isactive=true and UserType ='Standard' order by email]); 
            system.debug('$ List of spend user B4 assignign : usrManagerList :'+usrManagerList);
            
            for (Integer i=0; i <usrManagerList.size(); i++)
            { 
                AGS_Case_Action_gne__c aca ;
                aca = createCaseAction(usrManagerList[i] ,AGS_RecTypes_map.get('AGS Case Action-EscalatedConfirmCompliance-Edit-Rect')); 
                system.debug('Created Case Action Manager escalated'+aca );
                
                if (aca !=null)
                lstCaseActionInsert.add(aca);
            }
            
        }   
        system.debug('CASE ACTION:'+sActionPicklist+';');                 
        system.debug('&'+lstCaseActionInsert);                                   
        
        try
        {
            if(lstCaseActionInsert.size()==0)
            {
                sErrMessage='The Action could not be created';
                return null;            
            }       
            if(lstCaseActionInsert!=null && lstCaseActionInsert.size()>0)
            {
                insert lstCaseActionInsert;
                system.debug('Inserted Case Action Successfully'  + lstCaseActionInsert);
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);//gitika June 2nd
            return null;
            sErrMessage= ' Could NOT INSERT the Case Action'; 
            system.debug('Case Action could not be inserted');
        }   

        PageReference opp = null;
        if(blRedirect) 
        {
            opp = new PageReference('/'+objAGSCaseaction.AGS_Case_gne__c);
            if(lstCaseActionInsert!=null && lstCaseActionInsert.size()>0) 
            {
                opp = new PageReference('/'+lstCaseActionInsert[0].Id);
            }
        }
        else
        {
            opp = new PageReference('/'+objAGSCaseaction.AGS_Case_gne__c);   
        }
        return opp;
    }   
    
    public AGS_Case_Action_gne__c createCaseAction(user usrRecord,RecordType recType) 
    {
        AGS_Case_Action_gne__c aca = new AGS_Case_Action_gne__c();              
        aca.ownerId=usrRecord.id;     
        aca.AGS_Case_gne__c =objAGSCaseaction.AGS_Case_gne__c;              
        aca.Action_gne__c=sActionPicklist;
        aca.Action_Status_internal_gne__c = 'Open';
        aca.recordtypeid=recType.Id;
        system.debug('Rec Type for Aggregate reco spending Reached  :' +recType.Id );
        system.debug('aca.recordtypeid  :' +aca.recordtypeid );
        return aca;
    }

    public static String CreateINFUUser(String UnixId)
    {
        List<All_User_Hierarchy_gne__c> allUsers = [Select id,email_id__c, FirstName_gne__c, LastName_gne__c, Active_gne__c,User_External_Id_gne__c  from All_User_Hierarchy_gne__c where User_External_Id_gne__c = :UnixID];
        try
        {
            if (allUsers.size() == 1){
                User newUser = new User();
                newUser.TimeZoneSidKey = DEFAULT_TIME_ZN;
                newUser.LocaleSidKey = DEFAULT_LOCALE_KEY;
                newUser.EmailEncodingKey = DEFAULT_EMAIL_KEY;
                newUser.LanguageLocaleKey = DEFAULT_LANG_LOC_KEY;         
                newUser.firstName = allUsers[0].FirstName_gne__c;
                newUser.lastName = allUsers[0].LastName_gne__c;
                newUser.alias = UnixId.Substring(0,8);
                string [] user_Name_Temp = allUsers[0].email_id__c.split('@');
                newUser.username = UnixId +'@'+user_Name_Temp[1]+'new';
                newUser.email = allUsers[0].email_id__c; 
                newUser.isactive = true;
                newUser.external_id_gne__c = allUsers[0].User_External_Id_gne__c;
                if (Utilities.getEnvironmentName() <> 'prod')
                {
                    newUser.username += '.'+ Utilities.getEnvironmentName();
                }
                newUser.CommunityNickname = UnixId+'new';
                List<UserRole> stdRoles = [Select Id, name from UserRole where name = 'Standard User'];
                
                if (stdRoles.size() < 1){
                    return 'Error: Could not find Standard Role to assign to new user.';
                }
                
                newUser.UserRoleId = stdRoles[0].Id;
                
                List<Profile> infreqProfs = [Select Id, name from Profile where name = 'GNE-INFREQUENT-USER'];
                
                if (infreqProfs.size() < 1){
                    return 'Error: Could not find Standard Role to assign to new user.';
                }             
                
                newUser.ProfileId = infreqProfs[0].Id;
                newUser.USERPERMISSIONSMOBILEUSER = false;
                insert newUser;
                return newUser.Id;                            
            }
            else
            {             
                return 'Error: Create of new user account failed due to no user found in All User Hierarchy.';
            } 
        }catch (Exception e)
        {
            System.debug('Exception '+e);
            return 'Error: Create of new user account failed.';
        }
    }
}