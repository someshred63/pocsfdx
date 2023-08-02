global class GNE_MED_MSLRoleHierarchyBatch 
    implements Database.Batchable<SObject>, Database.Stateful  
{
    
    /*
    Creates and/or deletes MSL Role Hierarchiy based on the MSL Roster. Keeps the Role Hierarchy in Synch with the MSL Roster
    Author : Sandeep Kumar
    Created on : 22 Aug 2011
    Last Modified : 22 Aug 2011
    */
    
    String TERR_PREFIX_MGR = 'MedAffairs-MSLMGR-';
    String TERR_PREFIX_MSL = 'MedAffairs-MSL-';
    
    String emailMsg = '';
    
    Integer nRows = 0;
    Integer nErrors = 0;
    
    Integer mgrRoleCreated = 0;
    Integer mslRoleCreated = 0;
    Integer mslRoleUpdated = 0; 
    
    Integer mgrUsersUpdated = 0;
    Integer mgrUsersUpdatedNoRole = 0;
    Integer mslUsersUpdated = 0;
    
    DateTime startTime = DateTime.now();
    
    
    //default constructor
    public GNE_MED_MSLRoleHierarchyBatch()
    {
        
    }
    
    public void processTest()
    {
         String sql = 'Select Id, Manager_gne__c, UnixId_Manager_gne__c, ' +  
                     'UnixId_User_gne__c, User_gne__c, ' +
                     '(Select Id, Product_TA_SubTA_gne__c, Product_TA_SubTA_gne__r.Name, Product_TA_SubTA_gne__r.Therapeutic_Area_vod__c  From Referral_Roster_Details__r limit 1) ' +
                     'from Referral_Roster_gne__c where User_gne__r.IsActive=true limit 5';
         
         List<sObject> lstObjects = Database.query(sql);
         
         for(sObject obj : lstObjects)
         {
             Referral_Roster_gne__c referralRecordList = (Referral_Roster_gne__c )obj;
             processUserRoleHierarchy(referralRecordList);
         }
        
         
    }
    
    //method the creates returns the query or the list of records to process
    global Database.QueryLocator start(Database.batchableContext bc) 
    {        
        String sql = 'Select Id, Manager_gne__c, UnixId_Manager_gne__c, ' +  
                     'UnixId_User_gne__c, User_gne__c, ' +
                     '(Select Id, Product_TA_SubTA_gne__c, Product_TA_SubTA_gne__r.Name, Product_TA_SubTA_gne__r.Therapeutic_Area_vod__c  From Referral_Roster_Details__r limit 1) ' +
                     'from Referral_Roster_gne__c where User_gne__r.IsActive=true ';
        return Database.getQueryLocator ( sql );  
    }
    
    //method that runs when the batch class is executed
    global void execute(Database.BatchableContext BC, List<SObject> objectList)
    {                       
        
        Referral_Roster_gne__c referralRecordList = (Referral_Roster_gne__c ) objectList[0];
        processUserRoleHierarchy(referralRecordList);
        
    }    
    
    
    public void processUserRoleHierarchy(Referral_Roster_gne__c referralRecord)
    {
        ID userId ;
        ID managerId ;
        String theraName;
        
        try
        {
            nRows++;
            if(referralRecord!=null)
            {
                if(referralRecord.User_gne__c!=null)
                {
                    userId = referralRecord.User_gne__c;
                }
                if(referralRecord.Manager_gne__c!=null)
                {
                    managerId = referralRecord.Manager_gne__c;
                    
                }
            }

            //get the terapeutic area of the msl to suffix to the role name
            Referral_Roster_Detail_gne__c refDetail = referralRecord.Referral_Roster_Details__r;
            if(refDetail!=null)
            {
                Product_vod__c product = refDetail.Product_TA_SubTA_gne__r;
                if(product!=null)
                {
                    theraName = product.Therapeutic_Area_vod__c;
                }
            }

            //create or update msl amd msl manager role
            createAndAssignRole (userId, managerId, theraName ); 
        
        }
        catch (Exception ex)
        {
            nErrors++;
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + ex.getMessage() );    
        }   
         
    }
    
    public void createAndAssignRole(Id userIdMSL, Id userIdMGR, String  theraName)
    {
        
        String userMSLRole40Chars ;
        String userMGRRole40Chars ;
        String UserMGRRole;
        String UserMSLRole;
        
        UserRole mslRole = null, mgrRole = null;
        User     mslUser = null, mgrUser = null;
         
        List<User> userList = [select id, alias, Name, managerId, userroleId from user
                                   where id = :userIdMSL or id = :userIdMGR]; 
                                   
    
        
        // get msl and msl manager user records for update 
        for (User userRecord : userList ) {
            if ( userIdMSL!=null && userRecord.Id == userIdMSL ) { 
                mslUser = userRecord; 
            } else if ( userIdMGR != null && userRecord.Id == userIdMGR) {
                mgrUser = userRecord;      
            }
        }         
        
        //ceate msl and msl manger textual role names to be used to create or update roles in sfdc
        UserMSLRole = TERR_PREFIX_MSL + theraName + '-' + mslUser.Name;
        UserMGRRole = TERR_PREFIX_MGR + theraName + '-' + mgrUser.Name;
        
        System.debug('UserMGRRole : ' + UserMGRRole );
        
        
        if ( userMSLRole.length() > 40 ) 
            userMSLRole40Chars = userMSLRole.substring(0,40).trim();
        else
            userMSLRole40Chars = userMSLRole;
            
        if ( userMGRRole != null && userMGRRole.length() > 40 ) 
            userMGRRole40Chars = userMGRRole.substring(0,40).trim();
        else
            userMGRRole40Chars = userMGRRole;
        
        List<UserRole> roleList = [SELECT id, name, parentRoleId FROM userrole 
                                WHERE name = :userMSLRole40Chars OR name = :userMGRRole40Chars
                                ORDER BY lastmodifieddate desc  ];  
                                    
        //get the msl and msl manager roles if they exist
        if(roleList!=null && roleList.size()>0)
        {
            for (UserRole userRoleRecord : roleList )
            {
                if ( userRoleRecord.Name.equalsIgnoreCase(userMSLRole40Chars) ) { 
                    mslRole = userRoleRecord; } 
                else if ( userMGRRole != null && userRoleRecord.Name.equalsIgnoreCase(userMGRRole40Chars) ) {
                    mgrRole = userRoleRecord;      
                }
            }
        }
        
        //create or update msl and msl manager user roles
        //new MGR role
        if ( mgrRole == null && userMGRRole != null ) 
        {
            System.debug('userMGRRole40Chars : ' + userMGRRole40Chars );
            mgrRole = new UserRole(Name=userMGRRole40Chars, RollupDescription=userMGRRole,
                                    OpportunityAccessForAccountOwner='None',
                                    CaseAccessForAccountOwner='None');
            
            insert mgrRole;
            mgrRoleCreated++;                                      
        }
                                    
        // new MSL Role
        if ( mslRole == null )
        {
            mslRole = new UserRole(Name=userMSLRole40Chars, RollupDescription=userMSLRole,
                                  OpportunityAccessForAccountOwner='None',
                                  CaseAccessForAccountOwner='None' 
                                  );
            if ( mgrRole != null ) 
                mslRole.parentRoleId = mgrRole.Id;
                                                      
            insert mslRole;
            mslRoleCreated++;
                                                        
        } 
        else //update MSL role
        {                
            if ( mgrRole != null && mgrRole.Id != mslRole.ParentRoleId ) { 
                mslRole.parentRoleId = mgrRole.Id;
                update mslRole;
                mslRoleUpdated++;
            }                   
        }                           
        
        //update users(msl and masl manager roles
        List<User> updateUserList = new List<User>();
        
        if ( mgrUser != null && mgrUser.UserRoleId != mgrRole.Id ) { 
            mgrUser.UserRoleId = mgrRole.Id;
            updateUserList.add ( mgrUser );
            mgrUsersUpdated++;  
        }                
        
        if ( mslUser!=null && mslUser.UserRoleId != mslRole.Id )
        { 
            mslUser.UserRoleId = mslRole.Id;
            updateUserList.add ( mslUser );
            mslUsersUpdated++;  
        }                
        
        if ( updateUserList.size() > 0 ) 
            update updateUserList;      
        
        String msg = 'User, User Role / DM User Id, DM Role -> ' + 
                        mslUser.alias + '-' + userMSLRole + '-' + mslUser.Id + '/' + 
                        userIdMGR         + '-' + userMGRRole + '\n'; 
         System.debug ( LoggingLevel.INFO,  msg );
         emailMsg = emailMsg + msg;                                                                                      
    }
    
    
    //clean up method
    global void finish(Database.BatchableContext BC)
    {
        try{
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, ApexClass.Name, 
                              JobItemsProcessed, TotalJobItems, CreatedBy.Email,
                              CreatedDate, CompletedDate
                              from AsyncApexJob 
                              where Id =:BC.getJobId()
                              ];
            User createdUser = a.CreatedBy;
            ApexClass batchApexClass = a.ApexClass;

            Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
            String addr = configItemsMap.get('MSLRoleHierarchyNotifyEmail').Configuration_Value_gne__c;
                                              
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses ( new String[] {addr} );
            mail.setSubject('Apex Job ' + batchApexClass.Name +
                            ' status ' + a.Status);
            
            mail.setPlainTextBody
                            ('The batch Apex job processed completed.  Summary below: \n' + 
                             'Total user records processed ' + nRows + '\n' + 
                             'MGR Roles created ' + mgrRoleCreated + '\n' + 
                             'MSL Roles created ' + mslRoleCreated + '\n' + 
                             'MSL Roles updated ' + mslRoleUpdated + '\n' + 
                             'MGR Users role assigned ' + mgrUsersUpdated + '\n' + 
                             'MGR Users role removed  ' + mgrUsersUpdatedNoRole + '\n' + 
                             'MSL Users updated '       + mslUsersUpdated + '\n' +
                             'Role/User Errors '       + nERrors + '\n' +
                            
                             'Start / End Times --> ' + startTime + ' - ' + DateTime.now() + '\n\n' +
                             'Assignment Data processing summary: \n ' +  
                              emailMsg );

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 'Unable to send email ' + e.getMessage() );    
        }
        
    }
}