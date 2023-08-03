/**
* @author : Rabindranath
* @date 10/21/22
* @description : Assigning permission set and public groups to the records getting created from New Button
-----------------------------------------------------------------------------------------------------------------------------------
**/

trigger PRP_addLockedUsersToBEMGrp on PRP_BEM__c (after insert,after update) {
    set<string> userIdSet = new set<string>();
    for (PRP_BEM__c bm : trigger.new){
        if(bm.Locked__c){
            userIdSet.add(bm.Unix_Id__c);
            }
    }
    if(userIdSet.size()>0){
       copyRosterInfoToGenentechCont.assignUsers(userIdSet);
    
        copyRosterInfoToGenentechCont.updateusr(userIdSet);
    }
    
}