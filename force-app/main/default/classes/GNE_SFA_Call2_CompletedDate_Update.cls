public without sharing class GNE_SFA_Call2_CompletedDate_Update{

      public static boolean Call2onUpdate(Call2_Vod__c[] Call2) {
     
        boolean Call2Status = false;
        
        Integer countCall2 =Call2.Size();
        for(integer i=0; i<countCall2; i++){
          if (Call2[i].Completed_gne__c == true && Call2[i].Date_Completed_gne__c == null) {
            Call2[i].Date_Completed_gne__c = date.today();
          }
          else {
            Call2[i].Date_Completed_gne__c =null;             
          } 

            Call2Status=true;
        }
       
         return Call2Status;
       
        
        
    }/* Call2OnUpdate() */
 }