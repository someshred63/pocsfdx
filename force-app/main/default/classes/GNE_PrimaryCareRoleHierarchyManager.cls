global class GNE_PrimaryCareRoleHierarchyManager
    implements Database.Batchable<SObject>, Database.Stateful  {

    String TERR_PREFIX_DM = 'PMC-DM-';
    String TERR_PREFIX_CS = 'PMC-CS-';

    Map<Id,Territory2> mapPCTerritories = null;
    Map<Id,Id> mapUserDM2TerritoryId   = new Map<Id, Id>();
    Map<Id,Id> mapTerritoryId2UserDM   = new Map<Id, Id>();
    Set<Id> setDMUserId = new Set<Id>();

    Integer nRows = 0;
    Integer nUsersWithoutAlignment = 0;
    Integer nErrors = 0;

    Integer dmUsersUpdated = 0;
    Integer dmUsersUpdatedNoRole = 0;
    Integer csUsersUpdated = 0;

    Integer dmRoleCreated = 0;
    Integer csRoleCreated = 0;
    Integer csRoleUpdated = 0;

    Integer nRepRosterCreated = 0;
    Integer nRepRosterUpdated = 0;
    Integer nRepRosterErrors  = 0;

    DateTime startTime = DateTime.now();

    String emailMsg = '';

    public GNE_PrimaryCareRoleHierarchyManager () {
        init();
    }

    void init() {

        mapPCTerritories = new Map<Id,Territory2>(
                                [select id, ParentTerritory2Id, Name
                                 from Territory2
                                 where Name like '00C%'
                                ]);

        List<UserTerritory2Association> userTerritorylist = [
                select userId , Territory2Id
                from UserTerritory2Association
                where     userId in ( select id from user
                                      where     isactive = true
                                            and profile.name ='GNE-SFA-Primary-Care-DM' )
                      and Territory2Id in ( select ParentTerritory2Id from Territory2 where name like '00C%' )
                      and isActive = true
                order by lastmodifieddate desc, Territory2Id desc
            ];

        for (UserTerritory2Association userTerritory : userTerritoryList ) {
            if ( mapUserDM2TerritoryId.get( userTerritory.userId ) == null ) {
                mapUserDM2TerritoryId.put ( userTerritory.userId, userTerritory.Territory2Id );
                mapTerritoryId2UserDM.put ( userTerritory.Territory2Id, userTerritory.userId );
            }
        }
        System.debug ( LoggingLevel.INFO, 'Total Territories / User DM 2 Territory Id Map ' +
                                           mapPCTerritories.size() + '/' +
                                           mapTerritoryId2UserDM.size() ) ;
    }

    global Database.QueryLocator start(Database.batchableContext bc) {
        String primaryCareProfileName = 'GNE-SFA-Primary-Care-CS';
        String sql = 'select id, managerId, userRoleId, alias from   user ' +
                     'where  isactive = true and profile.name = :primaryCareProfileName ' +
                     'order by lastmodifieddate desc  ';
        return Database.getQueryLocator ( sql );
    }

    public void processUserRoleHierarchy (User userRecord) {
        try {
            nRows++;
            System.debug ( LoggingLevel.INFO, 'Total Territories / User DM 2 Territory Id Map ' +
                                           mapPCTerritories.size() + '/' +
                                           mapTerritoryId2UserDM.size() ) ;

            List<UserTerritory2Association> userTerritorylist =
                [select id, userId, Territory2Id
                 from UserTerritory2Association
                 where Territory2Id not in ( select ParentTerritory2Id from Territory2 where name like '00C%' )
                       and Territory2Id in      ( select id from Territory2 where name like '00C%' )
                       and isActive = true
                       and userId = :userRecord.Id
                 order by lastmodifieddate desc, Territory2Id desc  limit 1
                ];


            if ( userTerritorylist.size() == 0 ) {
               nUsersWithoutAlignment++;
               return ; // no PC user assignment.
            }

            UserTerritory2Association userPCTerritory = userTerritoryList[0];
            Territory2 territoryRecord     = mapPCTerritories.get ( userPCTerritory.Territory2Id );

            System.debug ( LoggingLevel.INFO, 'Territory Record ' + territoryRecord.ParentTerritory2Id  );

            Id userIdDM                   = mapTerritoryId2UserDM.get (territoryRecord.ParentTerritory2Id);
            String userCSRole             = TERR_PREFIX_CS + territoryRecord.Name;
            String userDMRole             = null;
            if ( userIdDM != null )
                userDMRole                = TERR_PREFIX_DM + mapPCTerritories.get(territoryRecord.ParentTerritory2Id).Name;

            String msg                    = 'User, User Role / DM User Id, DM Role -> ' +
                                               userRecord.alias + '-' + userCSRole + '-' + userRecord.Id + '/' +
                                               userIdDM         + '-' + userDMRole + '\n';

            createAndAssignRole (userRecord.Id, userCSRole, userIdDM, userDMRole );
            createOrUpdateRepRoster ( userRecord.Id );

            if ( userIdDM != null )
                setDMUserId.add ( userIdDM );

            System.debug ( LoggingLevel.INFO,  msg );
            emailMsg = emailMsg + msg;

        }catch (Exception ex) {
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + ex.getMessage() );
        }
    }

    void createAndAssignRole (Id userIdCS, String userCSRole,
                              Id userIdDM, String userDMRole ) {
        try {

            String userCSRole40Chars = userCSRole;
            String userDMRole40Chars = userDMRole;

            if ( userCSRole.length() > 40 )
                userCSRole40Chars = userCSRole.substring(0,40).trim();

            if ( userDMRole != null && userDMRole.length() > 40 )
                userDMRole40Chars = userDMRole.substring(0,40).trim();

            List<User> userList = [select id, managerId, userroleId from user
                                   where id = :userIdCS or id = :userIdDM];

            List<UserRole> roleList = [select id, name, parentRoleId from userrole
                                       where name = :userCSRole40Chars or
                                             name = :userDMRole40Chars
                                       order by lastmodifieddate desc  ];

            UserRole csRole = null, dmRole = null;
            User     csUser = null, dmUser = null;

            // read user, role records for update
                for (User userRecord : userList ) {
                    if ( userRecord.Id == userIdCS ) {
                        csUser = userRecord;
                    } else if ( userIdDM != null && userRecord.Id == userIdDM) {
                        dmUser = userRecord;
                    }
                }

                for (UserRole userRoleRecord : roleList ) {
                    if ( userRoleRecord.Name.equalsIgnoreCase(userCSRole40Chars) ) {
                        csRole = userRoleRecord;
                    } else if ( userDMRole != null && userRoleRecord.Name.equalsIgnoreCase(userDMRole40Chars) ) {
                        dmRole = userRoleRecord;
                    }
                }

            // new DM Role
                if ( dmRole == null && userDMRole != null ) {
                    dmRole = new UserRole(Name=userDMRole40Chars, RollupDescription=userDMRole,
                                          OpportunityAccessForAccountOwner='None',
                                          CaseAccessForAccountOwner='None');
                    insert dmRole;
                    dmRoleCreated++;
                }

            // new CS Role
                if ( csRole == null ) {
                    csRole = new UserRole(Name=userCSRole40Chars, RollupDescription=userCSRole,
                                          OpportunityAccessForAccountOwner='None',
                                          CaseAccessForAccountOwner='None'
                                          );
                    if ( dmRole != null )
                        csRole.parentRoleId = dmRole.Id;

                    insert csRole;
                    csRoleCreated++;

                } else {
                    if ( dmRole != null && dmRole.Id != csRole.ParentRoleId ) {
                        csRole.parentRoleId = dmRole.Id;
                        update csRole;
                        csRoleUpdated++;
                    }
                }

            // user update
                List<User> updateUserList = new List<User>();

                if ( dmUser != null && ( dmUser.UserRoleId == null || dmUser.UserRoleId != dmRole.Id ) ) {
                    dmUser.UserRoleId = dmRole.Id;
                    updateUserList.add ( dmUser );
                    dmUsersUpdated++;
                }

                if ( (csUser.UserRoleId == null || csUser.UserRoleId != csRole.Id) ||
                     ( dmUser != null && (csUser.ManagerId == null || csUser.ManagerId != dmUser.Id) ) ||
                     ( dmUser == null & csUser.ManagerId != null )
                 ) {

                    csUser.UserRoleId = csRole.Id;

                    if ( dmUser == null )
                       csUser.ManagerId = null;
                    else
                       csUser.ManagerId = dmUser.Id;

                    updateUserList.add ( csUser );
                    csUsersUpdated++;
                }

                if ( updateUserList.size() > 0 )
                   update updateUserList;

        } catch (Exception ex) {
            nErrors++;
            System.debug ( LoggingLevel.INFO, 'createAndAssignRole Exception occured User Id / Exception -> ' +
                           userIdCS + '/' + ex );
        }
    }

    void removeDMRoleNoLongerNeeded () {
        //List<User> dmUserList = [];
    }

    void createOrUpdateRepRoster (Id userIdCS) {

        try {
            List<Rep_Roster_vod__c >  repRosterList = null;
            User csUser  = [ select id, name, username, alias, managerId
                             from user where id = :userIdCS ];

            repRosterList = [select id, name, ownerid, manager_gne__c,
                             username_external_id_vod__c
                             from rep_roster_vod__c
                             where ownerId = :userIdCS
                             order by createddate desc limit 1 ];

            if ( repRosterList.size() == 0 ) {
                Rep_Roster_vod__c createRepRoster = new Rep_Roster_vod__c();
                createRepRoster.ownerId                     = userIdCS;
                createRepRoster.name                        = csUser.Name;
                createRepRoster.Manager_gne__c              = csUser.ManagerId;
                createRepRoster.Username_External_Id_vod__c = csUser.UserName;
                createRepRoster.Status_gne__c               = 'Inspection Required';
                createRepRoster.Inspection_Deadline_gne__c  = System.today() + 30;
                insert createRepRoster;
                nRepRosterCreated++;
            } else {
                Rep_Roster_vod__c updateRepRoster = repRosterList[0];
                if ( updateRepRoster.Name                        != csUser.Name  ||
                     updateRepRoster.Username_External_Id_vod__c != csUser.UserName ||
                     (updateRepRoster.Manager_gne__c == null && csUser.ManagerId != null ) ||
                     (updateRepRoster.Manager_gne__c != null &&
                      csUser.ManagerId != null &&
                      updateRepRoster.Manager_gne__c != csUser.ManagerId
                     )
                   ) {
                        updateRepRoster.Name                        = csUser.Name;
                        updateRepRoster.Manager_gne__c              = csUser.ManagerId;
                        updateRepRoster.Username_External_Id_vod__c = csUser.Username;
                        update updateRepRoster;
                        nRepRosterUpdated++;
                   }
            }
        } catch (Exception ex ) {
            nRepRosterErrors++;
            System.debug ( LoggingLevel.INFO, 'createOrUpdateRepRoster Exception occured User Id / Exception -> ' +
                           userIdCS + '/' + ex );
            addErrorLog(ex, userIdCS);
        }
    }

    global void execute(Database.BatchableContext BC, List<SObject> objectList){
        User userRecord = (User ) objectList[0];
        processUserRoleHierarchy(userRecord);
    }


    global void finish(Database.BatchableContext BC){
        try {
            AsyncApexJob a = [Select Id, Status, NumberOfErrors, ApexClass.Name,
                              JobItemsProcessed, TotalJobItems, CreatedBy.Email,
                              CreatedDate, CompletedDate
                              from AsyncApexJob
                              where Id =:BC.getJobId()
                              ];
            User createdUser = a.CreatedBy;
            ApexClass batchApexClass = a.ApexClass;

            Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
            String addr = configItemsMap.get('RoleHierarchyNotfyEmail').Configuration_Value_gne__c;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses ( new String[] {addr} );
            mail.setSubject('Apex Job ' + batchApexClass.Name +
                            ' status ' + a.Status);

            mail.setPlainTextBody
                            ('The batch Apex job processed completed.  Summary below: \n' +
                             'Total user records processed ' + nRows + '\n' +
                             'Users without PC territory alignment ' + nUsersWithoutAlignment + '\n' +
                             'DM Roles created ' + dmRoleCreated + '\n' +
                             'CS Roles created ' + csRoleCreated + '\n' +
                             'CS Roles updated ' + csRoleUpdated + '\n' +
                             'DM Users role assigned ' + dmUsersUpdated + '\n' +
                             'DM Users role removed  ' + dmUsersUpdatedNoRole + '\n' +
                             'CS Users updated '       + csUsersUpdated + '\n' +
                             'Role/User Errors '       + nERrors + '\n' +
                             'Rep Roster created '     + nRepRosterCreated + '\n' +
                             'Rep Roster updated '     + nRepRosterUpdated + '\n' +
                             'Rep Roster Errors '      + nRepRosterErrors + '\n' +
                              'Start / End Times --> ' + startTime + ' - ' + DateTime.now() + '\n\n' +
                              'Assignment Data processing summary: \n ' +
                              emailMsg );

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 'Unable to send email ' + e.getMessage() );
        }
     }


    void addErrorLog (Exception ex, Id userIdCS) {
        try {
            Error_Log_gne__c errorLog =
                 new Error_log_gne__c(Error_Level_gne__c    = 'High',
                                      Code_Type__c          = 'Apex Class',
                                      Snippet_Name__c       = 'GNE_PrimaryCareRoleHierarchyManager',
                                      User_Name__c          = UserInfo.getUserName(),
                                      Object_Name__c        = 'User-' + userIdCS,
                                      Error_Description__c  = ex.getMessage()
                                      );

                insert errorLog;
        } catch ( Exception e ) {
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + e.getMessage() );
        }
    }


}