/**
* @author : Rabindranath
* @date 10/21/22
* @description : Calling the PRP_addUsersToPublicGroupUtil class from trigger as soon as records are getting created in PRP_BEM__c.
-----------------------------------------------------------------------------------------------------------------------------------
**/
trigger PRP_addDeleteUsersFromBEMGrp on PRP_BEM__c (before insert, before update,after insert, after update) {
    List<Id> userIdSet = new List<Id>();
    List<Id> deluserIdSet = new List<Id>();
    List<string> unixids = new List<string>();
    if(Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate )) {
        for (PRP_BEM__c bm : trigger.new){
            if(string.isNotBlank(bm.Unix_Id__c))
                unixids.add(bm.Unix_Id__c);
        }
        
        list<user> users=[select id,External_ID_gne__c from user where External_ID_gne__c in:unixids  limit 10000];
        Map<string, user> usersmap= new map<string,user>();
        for(user use:users){
            usersmap.put(use.External_ID_gne__c,use);
        }
        
        for (PRP_BEM__c bm : trigger.new){
            if(string.isNotBlank(bm.Unix_Id__c) && usersmap.containsKey(bm.Unix_Id__c))
                bm.User__c=usersmap.get(bm.Unix_Id__c).id;
        }
    }
    if(Trigger.isafter && (Trigger.isInsert || Trigger.isUpdate )) {
        for (PRP_BEM__c bm : trigger.new){
            if(string.isNotBlank(bm.User__c))
                if(bm.Is_Active__c == true){                
                    userIdSet.add(bm.User__c);                
                }else if(bm.Is_Active__c == false){
                    deluserIdSet.add(bm.User__c);
                }
        }
        if(!userIdSet.isEmpty()) {
         //   PRP_addUsersToPublicGroupUtil.addUsertoGrp(userIdSet);
           
        }
       if(!deluserIdSet.isEmpty()) {
           // PRP_addUsersToPublicGroupUtil.delUserFromGrp(deluserIdSet);
        }
    }
}