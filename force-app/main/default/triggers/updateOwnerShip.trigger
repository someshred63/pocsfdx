trigger updateOwnerShip on gFRS_Ltng_Customer_Intraction__c (before delete, before insert, before update, 
                                    after delete, after insert, after update) {


 /* Set<String> grpNames=new Set<String>();
  Map<String,Id> mapOfQueues=new Map<String,Id>();
  
  if(Trigger.isBefore && Trigger.isUpdate)
  {
  
       for (gFRS_Ltng_Customer_Intraction__c a : Trigger.new) 
       {
       
               grpNames.add(a.Triaged_to__c);
           
       }
    
  }
  
  for(Group grp:[select Id, NAME from Group where Type = 'Queue' AND NAME IN : grpNames])
  {
      
      mapOfQueues.put(grp.Name,grp.Id);
  
  }
    
    
  if(Trigger.isBefore && Trigger.isUpdate)
  {
  
       for (gFRS_Ltng_Customer_Intraction__c a : Trigger.new) 
       {
       
               a.ownerId=mapOfQueues.get(a.Triaged_to__c);
           
       }
    
  }*/


}