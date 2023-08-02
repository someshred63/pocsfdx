/**
* @author GFRS Dev Team
* @date 04/09/2013
* @description Setting up users data into GNE_User_Delegation__c object.
* Only internal users will have records in this object. Use this script only once.
*/
global with sharing class GNE_SetupUserDelegateBatch implements Database.Batchable<sObject>
{
    List<GNE_User_Delegation__c> listUserDelegationInsert = new List<GNE_User_Delegation__c>();     
    
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query= 'select username,id from user where UserType=\'Standard\' and IsActive=true and (NOT Profile.Name like \'%Canada%\') and (NOT Profile.Name like \'%SYS%\') and (NOT Profile.Name like \'%ReadOnly%\')';    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
       if(scope.Size()>0)
       {
       	  ID gfrsRecordTypeID=[select Id from RecordType where SobjectType='GNE_User_Delegation__c' and Name='GFRS'][0].Id;
          for (User u :  (List<User>)scope )
          {
            if(gFRS_Util_NoShare.IsUserHasDelegationRecord(u.username,'GFRS')==false)
            {
                // to do implement logic here
                GNE_User_Delegation__c newDelegation = new GNE_User_Delegation__c(Name = u.username,Username__c=u.id,RecordTypeId=gfrsRecordTypeID,UniqueContent__c=u.username+'GFRS');
                newDelegation.OwnerId = u.id;
                listUserDelegationInsert.add(newDelegation);
               
            }
          }
          
          if(listUserDelegationInsert.Size()>0)
          { 
              system.debug('Amount of records for upsert->' + listUserDelegationInsert.Size());
              upsert listUserDelegationInsert;
          }   
       }
       else
       {
           system.debug('No data set. End Job');
       }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('GNE_SetupUserDelegateBatch execution ended successfully');
    }
    
}