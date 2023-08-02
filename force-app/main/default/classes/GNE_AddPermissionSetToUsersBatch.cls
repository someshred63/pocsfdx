/**
* @author GFRS Dev Team
* @date 04/09/2013
* @description grant access to GNE_User_Delegation__c object by assign permission set to internal users.
* Use this class only once.
*/
global with sharing class GNE_AddPermissionSetToUsersBatch implements Database.Batchable<sObject>
{
    List<PermissionSetAssignment> listPermissionAssignment = new List<PermissionSetAssignment>();       
    
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query= 'select username from user where UserType=\'Standard\' and  IsActive=true';    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
       if(scope.Size()>0)
       {
          id permissionSetId = [select id from PermissionSet where Name='GNE_Standard_User_Delegation'].id;
          
          for (User u :  (List<User>)scope )
          {
            if(gFRS_Util_NoShare.IsUserHasPSStandardUserDelegation(u.id)==false)
            {
            PermissionSetAssignment newPermission = new PermissionSetAssignment();
            newPermission.PermissionSetId = permissionSetId;
            newPermission.AssigneeId = u.id;
            listPermissionAssignment.add(newPermission);
            }
          }
          
          if(listPermissionAssignment.Size()>0)
          { 
              system.debug('Amount of records for insert->' + listPermissionAssignment.Size());
              insert listPermissionAssignment;
          }   
       }
       else
       {
           system.debug('No data set. End Job');
       }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('GNE_AddPermissionSetToUsersBatch execution ended successfully');
    }
    
}