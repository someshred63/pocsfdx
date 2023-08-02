global class GNE_FRM_DataSegregationJob extends GNE_ETL_DataSegregationVerificationJob implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    public Enum ActionType {UpdateUserRole, UpdateUserProfile, AccountShareTerritory, RemoveGroupMembers, RemovingTSF, 
        changeOwnerNonFRMContact, changeOwnerNonFRMAccount, changeOwnerFRMAccount, changeOwnerFRMContact,UsersUpdate}
    private List<ActionType> actionsToPerform;
    private ActionType currentaction;
    
    public GNE_FRM_DataSegregationJob(List<ActionType> actionsToPerform) {
        this.actionsToPerform = actionsToPerform;
        if(!actionsToPerform.isEmpty()){
            currentaction = actionsToPerform[0];
        }
    }
    
    public void execute(SchedulableContext sc){
        GNE_FRM_DataSegregationJob batch = new GNE_FRM_DataSegregationJob();
        Database.executeBatch(batch);
    }
    
    public GNE_FRM_DataSegregationJob () {
        countryISOCode = 'FRM' ;
        init(); 
    }    
        
    global Database.QueryLocator start(Database.batchableContext bc) {
        if(currentaction == null){
            return getQueryLocator();
        } else {
            return Database.getQueryLocator('SELECT Id FROM User LIMIT 1');
        }
    }

    global void execute(Database.BatchableContext BC, List<SObject> sObjectList){
        if(currentaction == null){
            doExecute(BC, sObjectList); 
        } else {
            if(currentaction == ActionType.UpdateUserRole){
                updateUserRole();
                actionsToPerform.remove(0);
            } else if (currentaction == ActionType.UpdateUserProfile) {
                updateUserProfile();
                actionsToPerform.remove(0);
            }
        }       
    }
            
    global void finish(Database.BatchableContext BC){
        if(currentaction == null){
            doFinish(BC);
        } else {
            System.debug(actionsToPerform.size());
            if(!actionsToPerform.isEmpty()){
                ActionType nextAction = actionsToPerform[0];
                if(nextAction == ActionType.AccountShareTerritory){
                    actionsToPerform.remove(0);
                    GNE_SFA2_FRM_RemovingAccShareBatch batch = new GNE_SFA2_FRM_RemovingAccShareBatch(GNE_SFA2_FRM_RemovingAccShareBatch.RemoveType.Territory);
                    Database.executeBatch(batch);
                } else if(nextAction == ActionType.RemoveGroupMembers){
                    actionsToPerform.remove(0);
                    GNE_SFA2_FRM_RemovingAccShareBatch batch = new GNE_SFA2_FRM_RemovingAccShareBatch(GNE_SFA2_FRM_RemovingAccShareBatch.RemoveType.RemoveGroupMembers);
                    Database.executeBatch(batch, 1);
                } else if(nextAction == ActionType.RemovingTSF){
                    actionsToPerform.remove(0);
                    GNE_SFA2_FRM_RemovingAccShareBatch batch = new GNE_SFA2_FRM_RemovingAccShareBatch(GNE_SFA2_FRM_RemovingAccShareBatch.RemoveType.TsfRemoving);
                    Database.executeBatch(batch);
                } else if(nextAction == ActionType.changeOwnerFRMContact){
                    actionsToPerform.remove(0);
                    GNE_SFA2_FRM_RemovingAccShareBatch batch = new GNE_SFA2_FRM_RemovingAccShareBatch(GNE_SFA2_FRM_RemovingAccShareBatch.RemoveType.changeOwnerFRMContact);
                    Database.executeBatch(batch);
                } else if(nextAction == ActionType.changeOwnerNonFRMContact){
                    actionsToPerform.remove(0);
                    GNE_SFA2_FRM_RemovingAccShareBatch batch = new GNE_SFA2_FRM_RemovingAccShareBatch(GNE_SFA2_FRM_RemovingAccShareBatch.RemoveType.changeOwnerNonFRMContact);
                    Database.executeBatch(batch);
                } else if(nextAction == ActionType.changeOwnerFRMAccount){
                    actionsToPerform.remove(0);
                    GNE_SFA2_FRM_RemovingAccShareBatch batch = new GNE_SFA2_FRM_RemovingAccShareBatch(GNE_SFA2_FRM_RemovingAccShareBatch.RemoveType.changeOwnerFRMAccount);
                    Database.executeBatch(batch);
                } else if(nextAction == ActionType.UsersUpdate){
                    actionsToPerform.remove(0);
                    GNE_SFA2_FRM_RemovingAccShareBatch batch = new GNE_SFA2_FRM_RemovingAccShareBatch(GNE_SFA2_FRM_RemovingAccShareBatch.RemoveType.UsersUpdate);
                    Database.executeBatch(batch,5);
                }
                system.debug(actionsToPerform);
                
                if(!actionsToPerform.isEmpty()){
                    GNE_FRM_DataSegregationJob batchJob = new GNE_FRM_DataSegregationJob(actionsToPerform);
                    Database.executeBatch(batchJob);
                }
            }
        }
    }  
    
    public static void updateUserRole(){
        Map<String, String> profile2role = new Map<String, String>{
            'GNE-MCCO-FRM-BFRM-Manager' => 'BFRMManager',
            'GNE-MCCO-FRM-BFRM' => 'BFRM',
            'GNE-MCCO-FRM-EFRM-Manager' => 'EFRMManager',
            'GNE-MCCO-FRM-EFRM' => 'EFRM',
            'GNE-MCCO-FRM-IFRM-Manager' => 'IFRMManager',
            'GNE-MCCO-FRM-IFRM' => 'IFRM',
            'GNE-MCCO-FRM-NFRM-Manager' => 'NFRMManager',
            'GNE-MCCO-FRM-NFRM' => 'NFRM',
            'GNE-MCCO-FRM-RFRM-Manager' => 'RFRMManager',
            'GNE-MCCO-FRM-RFRM' => 'RFRM',
            'GNE-CRM'=> 'CRM',
            'GNE-CRM-Manager'=>'CRM_Manager'                    
        };  
        Map<String, Id> roleName2Id = new Map<String, Id>();
        Map<String, Id> profile2roleId = new Map<String, Id>();
        for(UserRole ur:[
            SELECT PortalType, PortalRole, PortalAccountId, Name, Id, DeveloperName 
            FROM UserRole
            WHERE DeveloperName IN ('AFRM', 'BFRM', 'EFRM', 'IFRM', 'PFRM', 'NFRM', 'RFRM', 'AFRMManager', 'BFRMManager', 'EFRMManager', 'IFRMManager', 'PFRMManager', 'NFRMManager', 'RFRMManager', 'CRM_Manager','CRM' )
        ]){
            roleName2Id.put(ur.DeveloperName, ur.Id);
        }
        
        for(String profile: profile2role.keySet()){
            profile2roleId.put(profile, roleName2Id.get(profile2role.get(profile)));
        }

        User[] users=[
            SELECT Id, UserRoleId, Name, UserRole.Name, profile.Name
            FROM User
            WHERE (Role_Name_gne__c != 'BFRM' AND profile.Name = 'GNE-MCCO-FRM-BFRM' )
                OR (Role_Name_gne__c != 'EFRM' AND profile.Name = 'GNE-MCCO-FRM-EFRM' )
                OR (Role_Name_gne__c != 'IFRM' AND profile.Name = 'GNE-MCCO-FRM-IFRM' )
                OR (Role_Name_gne__c != 'NFRM' AND profile.Name = 'GNE-MCCO-FRM-NFRM' )
                OR (Role_Name_gne__c != 'RFRM' AND profile.Name = 'GNE-MCCO-FRM-RFRM' )
                OR (Role_Name_gne__c != 'BFRM Manager' AND profile.Name = 'GNE-MCCO-FRM-BFRM-Manager')
                OR (Role_Name_gne__c != 'EFRM Manager' AND profile.Name = 'GNE-MCCO-FRM-EFRM-Manager')
                OR (Role_Name_gne__c != 'IFRM Manager' AND profile.Name = 'GNE-MCCO-FRM-IFRM-Manager')
                OR (Role_Name_gne__c != 'NFRM Manager' AND profile.Name = 'GNE-MCCO-FRM-NFRM-Manager')
                OR (Role_Name_gne__c != 'RFRM Manager' AND profile.Name = 'GNE-MCCO-FRM-RFRM-Manager')
                OR (Role_Name_gne__c != 'CRM-Manager' AND profile.Name = 'GNE-CRM-Manager')
                OR (Role_Name_gne__c != 'CRM' AND profile.Name = 'GNE-CRM')
        ];
        for(User u:users){
             u.UserRoleId = profile2roleId.get(u.profile.Name);
        }
        Database.update(users, false); 
    }
    
    public static void updateUserProfile(){
        Id uRoleId = [SELECT Id FROM  UserRole WHERE Name ='Standard user' LIMIT 1].Id;

        User[] usersOtherProfiles=[
            SELECT Id, UserRoleId, Name, UserRole.Name, profile.Name
            FROM User
            WHERE (Role_Name_gne__c = 'BFRM' AND profile.Name != 'GNE-MCCO-FRM-BFRM' )
            OR (Role_Name_gne__c = 'EFRM' AND profile.Name != 'GNE-MCCO-FRM-EFRM' )
            OR (Role_Name_gne__c = 'IFRM' AND profile.Name != 'GNE-MCCO-FRM-IFRM' )
            OR (Role_Name_gne__c = 'NFRM' AND profile.Name != 'GNE-MCCO-FRM-NFRM' )
            OR (Role_Name_gne__c = 'RFRM' AND profile.Name != 'GNE-MCCO-FRM-RFRM' )
            OR (Role_Name_gne__c = 'BFRM Manager' AND profile.Name != 'GNE-MCCO-FRM-BFRM-Manager')
            OR (Role_Name_gne__c = 'EFRM Manager' AND profile.Name != 'GNE-MCCO-FRM-EFRM-Manager')
            OR (Role_Name_gne__c = 'IFRM Manager' AND profile.Name != 'GNE-MCCO-FRM-IFRM-Manager')
            OR (Role_Name_gne__c = 'NFRM Manager' AND profile.Name != 'GNE-MCCO-FRM-NFRM-Manager')
            OR (Role_Name_gne__c = 'RFRM Manager' AND profile.Name != 'GNE-MCCO-FRM-RFRM-Manager')
            OR (Role_Name_gne__c = 'CRM-Manager' AND profile.Name != 'GNE-CRM-Manager')
            OR (Role_Name_gne__c = 'CRM' AND profile.Name != 'GNE-CRM')
        ];
        
        for(User u:usersOtherProfiles){
            u.UserRoleId = uRoleId;
        }
        Database.update(usersOtherProfiles, false); 
    }
}