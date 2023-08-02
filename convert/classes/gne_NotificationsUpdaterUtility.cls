/************************************************************************************
Name   : gne_NotificationsUpdaterUtility
Created: Oct 20th 2009 
Author : Vinod Koosam @ Appirio
Usage : This is just a utility future class used update gne_Notifications__c
object asynchronously.  This is calledout from triggers on updates to Objects whose
changes need to be notified to ESB.  These updates to gne_Notifications__c object 
will result in outbound calls to ESB.
*************************************************************************************/
global class gne_NotificationsUpdaterUtility {  

    @FUTURE(callout=true)    
    
    public static void writeTransaction(List<Id> objectIds, List<Boolean> isParents, List<String> objectNames, List<String> objectTypes, List<String> transactionTypes, List<String> transactionIds){      
        try{            
            System.debug('********************************************* ');
            System.debug('********************************************* event being update in gne_Notifications ... '+ System.now().format('yyyyMMddhhmmss.SSS') );
            System.debug('********************************************* ');
                        
            List<gne_Notification__c> gNotifications = new List<gne_Notification__c>();
            List<gne_Notification__c> gChildrenNotifications = new List<gne_Notification__c>();      
            
            for(Integer i=0;i<objectIds.size();++i){
                gne_Notification__c gNotify   = new gne_Notification__c(    
                                                objectId__c   = objectIds[i],
                                                objectName__c = objectNames[i],
                                                objectType__c = objectTypes[i],
                                                transactionId__c   = objectIds[i]+'_'+transactionIds[i],
                                                transactionType__c = transactionTypes[i]);
                                                
                if(isParents[i]){
                    gNotifications.add(gNotify); 
                    System.debug(' This is a parent call, adding it to parents id=' + gNotify.objectId__c);
                }else{
                    System.debug(' This is a CHILD call, adding it to CHILDREN id=' + gNotify.objectId__c);                
                    gChildrenNotifications.add(gNotify);
                }
                
                System.debug('** About to notify for id=' + gNotify.objectId__c);
                System.debug('** About to notify Name  =' + gNotify.objectName__c);
                System.debug('** About to notify type  =' + gNotify.objectType__c);
                System.debug('** About to notify trnsac=' + gNotify.transactionId__c);
                System.debug('** About to notify  type=' + gNotify.transactionType__c);
                System.debug('** Is Parent =' + isParents[i]);                
            }   
            
            System.debug('Total parents notifications being inserted = ' +  gNotifications.size());
            
            if(gNotifications.size() > 0){
                insert gNotifications;
            }   
            
            // now deal with children notifications
            List<gne_Notification__c> gParentNotifications = new List<gne_Notification__c>();
            if(gChildrenNotifications  != null && gChildrenNotifications.size() > 0){
                for(Integer c=0; c<gChildrenNotifications.size();++c){ 
                
                    try{
                        System.debug(' Working with child id=' + gChildrenNotifications[c].objectId__c);
                        Call2_vod__c parentCall = [select Parent_Call_vod__c from Call2_vod__c where id =:gChildrenNotifications[c].objectId__c];
                        System.debug('Query for parent returned parent=' + parentCall);
                        
                        if(parentCall != null && parentCall.Parent_Call_vod__c != null){
                            gChildrenNotifications[c].objectId__c = parentCall.Parent_Call_vod__c;
                            // remember, we are only concerned with DELETE type child notifications
                            // others, i.e., CREATE/UPDATE are ok.
                            /*
                            if(gChildrenNotifications[c].objectType__c == 'DELETE')
                                gChildrenNotifications[c].objectType__c = 'UPDATE';
                            */
                                
                            insert gChildrenNotifications[c];
                        }
                    }catch(Exception cI){
                        System.debug('child handler failed - message:' + cI.getMessage());
                    }
                    
                }
            }
            
            System.debug('********************************************* ');
            System.debug('********************************************* Done creating parent and children notifications ... '+ System.now().format('yyyyMMddhhmmss.SSS') );
            System.debug('********************************************* ');
            
        }catch(Exception nE){
            System.debug('gneNotifycationsUpdateUtility.updaet exception ' + nE.getMessage());
            // do nothing else
        }
    }    
}