global class medEventHandler_gne{

   /**
    * Call is calldiscussion point to child medical event
    * updates discussion to point to parent even in child->granchild->... scenairio
    */
   public @future static void changetoMedEventParent(List<Id> callDisscussionIds){
   
          List<Call2_Discussion_vod__c> callDs = [Select id, name, Medical_event_vod__c, Medical_event_vod__r.parent_medical_event_gne__c from call2_Discussion_vod__c where id in :callDisscussionIds];
          
          System.debug('changetoMedEventParent called with :'+callDs.size()+' calls');
          for(Call2_Discussion_vod__c callDisc:  callDs){
             System.debug('call.Medical_event_vod__c :'+callDs.size()+' calls');
          
             Medical_event_vod__c me = [Select id, name, parent_medical_event_gne__c from Medical_event_vod__c where id = :callDisc.Medical_event_vod__c];
             while(true){
                if (me.parent_medical_event_gne__c != null){
                   System.debug('Updating call: '+callDisc.name+ 'from me: '+callDisc.Medical_event_vod__c+ '   to : '+ me.parent_medical_event_gne__c);          
                   callDisc.Medical_event_vod__c = me.parent_medical_event_gne__c;
                   break;
                }   
                else
                    me = [Select id, name, parent_medical_event_gne__c from Medical_event_vod__c where id = :me.parent_medical_event_gne__c];
             }/* while () */
          }/* for */   
          update callDs;
    }/* changetoMedEventParent */
    
    public static void testMe(){
       List<Id> callDs=new List<Id>();
       
       callDs.add('a09Q000000566v2IAA');
       changetoMedEventParent(callDs);
    }
//    public TestMethod static void testYou(){
//       List<Id> calls=new List<Id>();
//       
//       calls.add('a09Q000000566v2IAA');
//       changetoMedEventParent(calls);
//    }
    
}/* class */