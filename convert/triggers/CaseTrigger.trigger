/********************************************************************************************************************************
Purpose: CaseTrigger is used to handles the DML operations.

Note:Currently, we have "SCM_MovePERTrigger" on case object and named specific to project. Also, it may be decommsioned in future.
The Casetrigger can be used to implement the business logic for different applications and there will be only one trigger to
handle all the DML events
=================================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raheem       07/07/2020      INITIAL DEVELOPMENT
                    
***********************************************************************/
trigger CaseTrigger on Case (before insert,before update, after update) {

     CaseTriggerHandler caseTriggerHandler = new CaseTriggerHandler();
     if(Trigger.isBefore){
          if(Trigger.isInsert){
               /***Email To Case assign GCS contact contact on GCS case record   **/             
               caseTriggerHandler.onBeforeInsert(Trigger.new); 
               
          }
         if(Trigger.isUpdate){
            /*** Send bell notification when case Isescalted equals True**/
               caseTriggerHandler.onBeforeUpdate( Trigger.new, Trigger.oldMap, Trigger.newMap); 
         }
     }else{
          if(Trigger.isUpdate){
               caseTriggerHandler.onAfterUpdate( Trigger.new, Trigger.oldMap, Trigger.newMap); 
          }
         if(Trigger.isInsert){
            
              caseTriggerHandler.onAfterInsert( Trigger.new);
         }
     } 
   
}