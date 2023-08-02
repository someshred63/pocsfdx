global class copyRosterInfoToGenentechCont implements  Schedulable  {
    //current active unloced Genentech Contact unix ID set
    set<string> curBEMUnixIds=new set<string>();
    List<Roster_Data__c> rstr;
    
    global void execute(SchedulableContext sc)
    {
        rstr = [Select First_Name__c, Last_Name__c, Email__c, Field_Ecosystem_Name__c,Login_Id__c,
            Region__c,Employee_Status_Code__c,Field_Title_Code__c,Active__c 
            From Roster_Data__c where Active__c = true
            order by Login_Id__c];
        if(rstr !=null && rstr.size()>0) {
            inactiveGenentechContact();
            copyDatatoBEM();
            removeInactiveBEM();
        }
    }
    
    public void copyDatatoBEM() {
       /* List<Roster_Data__c> rstr = [Select First_Name__c, Last_Name__c, Email__c, Field_Ecosystem_Name__c,Login_Id__c,
            Region__c,Employee_Status_Code__c,Field_Title_Code__c,Active__c 
            From Roster_Data__c where Active__c = true
            order by Login_Id__c];*/
        List<PRP_BEM__c> newBem = new List<PRP_BEM__c>();
        Set<string> unixids = new Set<string>();
        Map<string,PRP_BEM__c> bemMap=new Map<string,PRP_BEM__c>(); //for get unique BEM
        string tittlecode_Filter= system.label.Field_Title_Code_Filter_Condition;
        list<string> Titlecodefilter= new list<string>();
        if(string.isNotBlank(tittlecode_Filter)){
            Titlecodefilter= tittlecode_Filter.split(',', -1);
        }
        
        
        for(Roster_Data__c s : rstr){
            if(Titlecodefilter.size()>0)
                if(!Titlecodefilter.contains(s.Field_Title_Code__c))
                continue;
            
            PRP_BEM__c bem = new  PRP_BEM__c();
            bem.Email__c = s.Email__c;
            bem.Unix_Id__c = s.Login_Id__c;
            bem.Name = s.First_Name__c +' '+ s.Last_Name__c;
            bem.Region__c = s.Region__c;
            bem.Ecosystem__c = s.Field_Ecosystem_Name__c;
            bem.Field_Title_Code__c = s.Field_Title_Code__c;
            if (s.Employee_Status_Code__c == 'active__aln'){
                bem.Is_Active__c = true; 
            }else{
                bem.Is_Active__c = false; 
            }
            //newBem.add(bem);
            //unixids.add(s.Login_Id__c);
            bemMap.put(s.Login_Id__c, bem);
                      
        }
        if(bemMap.size() > 0)
        {
            unixids=bemMap.keySet();
            newBem=bemMap.values();
            Database.UpsertResult[] results = Database.upsert(newBem,PRP_BEM__c.Unix_Id__c,false);
            //assignUsers(unixids);
            //only send new UNIX IDs to assign permissionset and group
            set<string> toBeAssignBEMAccessUnixIds=new set<string>();
            for (string rid:unixids){
                boolean findit=false;
                for(string bid:curBEMUnixIds){                   
                    if(rid==bid){
                        findit=true;
                        curBEMUnixIds.remove(bid);
                        break;
                    }
                }
                if(!findit) toBeAssignBEMAccessUnixIds.add(rid);
            }
            assignBEMAccess(toBeAssignBEMAccessUnixIds);
         }
    }
    
    public static void assignUsers(Set<string> unixids) {
        Set<Id> userIdSet = new Set<Id>();
        
        for (User rec : [select id,External_ID_gne__c from user where External_ID_gne__c in:unixids  limit 10000]){
            userIdSet.add(rec.Id);                
        }
        
        if(!userIdSet.isEmpty()) {
            PRP_addUsersToPublicGroupUtil.addUsertoGrp(userIdSet);
            PRP_addUsersToPublicGroupUtil.assignPermissionSet(userIdSet);
        }
    }
    @future
    public static void updateusr(Set<string> unixid){
        User u =[Select id,External_ID_gne__c,IsActive from User where External_ID_gne__c =:unixid];
        if(!u.IsActive){
            u.IsActive =true;
            update u;      
        }
    }
    
    //Jie added in on 4/10/23 to inactive unlocked records in Genentech Contact before copy Veeva data over
    private void inactiveGenentechContact(){
        List<PRP_BEM__c> curBems=[select ID, Is_Active__c, Locked__c, unix_Id__c from PRP_BEM__c 
                                 where Locked__c=:false and Is_Active__c=:true
                                 order by unix_Id__c];
        List<PRP_BEM__c> inactiveBems=new List<PRP_BEM__c>();
        if (curBems!=null && curBems.size()>0){
            for(PRP_BEM__c b: curBems){
                b.Is_Active__c=false;
                inactiveBems.add(b);
                curBEMUnixIds.add(b.unix_Id__c );
            }
            Database.SaveResult[] results = Database.update(inactiveBems,false);
          
            for (Database.SaveResult sr : results ) {
                if (!sr.isSuccess()) {
                     // Operation failed, so get all errors  
                       
                     System.debug('Genentech Contact not got inactivate: ' + sr.getId());
                                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                       
                    }
               
                }
            }
        }    
    }
    
    //Jie added on 4/10/23 to remove inactive Genentect Contacts which are not linked to any PRP request
    private void removeInactiveBEM(){
        List<PRP_BEM__c> curBems=[select ID, Is_Active__c, Locked__c, unix_Id__c from PRP_BEM__c 
                                    where Is_Active__c=:false and Locked__c=:false];
        List<PRP_Request__c> prpRequests=[select id, BEM__c from PRP_Request__c];   
        List<PRP_BEM__c> toBeRemovedBems= new List<PRP_BEM__c>();
        set<string> toBeRemovedUnixId=new set<string>();
         
        if(curBems!=null && curBems.size()>0 && prpRequests!=null && prpRequests.size()>0){
            for (PRP_BEM__c b:curBems){
                boolean removeit=true;
                for(PRP_Request__c p:prpRequests){
                    if(p.BEM__c==b.id ) {
                        removeit=false; 
                        Integer index=prpRequests.indexOf(p);
                        prpRequests.remove(index);
                        break; 
                     }                 
                }
                if (removeit) {
                    toBeRemovedBems.add(b); 
                    toBeRemovedUnixId.add(b.unix_Id__c);
                }
            }
        }
        
        //remove BEM permissionset and group for Genenetech Contacts will be removed
        if(toBeRemovedBems.size()>0){
            
            Group gp=[select ID from group where name='PRP BEM Members' limit 1];
            List<GroupMember> gms= [select id, UserOrGroupId, GroupId from GroupMember 
                                    where UserOrGroupId in: toBeRemovedUnixId and GroupId=:gp.id];
            PermissionSet psBEM=[select id from PermissionSet where name='PRP_BEM_Member' limit 1];
            List<PermissionSetAssignment> psas=[select id, AssigneeId, PermissionSetId from PermissionSetAssignment 
                               where AssigneeId in: toBeRemovedUnixId and PermissionSetId =:psBEM.id];
                               
            Database.delete(toBeRemovedBems,false);
            Database.delete(gms,false);
            Database.delete(psas,false);
            
        }
    }
    
    
    //Jie added on 4/10/23 to assign PRP BEM permissionset and group to users who are added in the PRP Genentech Contact object    
    @future
    public static void assignBEMAccess(Set<string> unixids){       

       if(unixids==null || unixids.size()<=0) return;
       
        List<User> users=[select id, External_ID_gne__c, IsActive, Profile.UserLicense.Name from user 
                  where External_ID_gne__c in: unixids 
                  and (Profile.UserLicense.Name='Salesforce Platform' or Profile.UserLicense.Name='Salesforce')
                 order by External_ID_gne__c];

        set<ID> userIds=new set<ID>();
        if(users!=null && users.size()>0) {
            for(user u:users) userIds.add(u.id);
        }
        Group gp=[select ID from group where name='PRP BEM Members' limit 1];
        List<GroupMember> gms= [select id, UserOrGroupId, GroupId from GroupMember 
                                where UserOrGroupId in: userIds  and GroupId=:gp.id];
        PermissionSet psBEM=[select id from PermissionSet where name='PRP_BEM_Member' limit 1];
        List<PermissionSetAssignment> psas=[select id, AssigneeId, PermissionSetId from PermissionSetAssignment 
                           where AssigneeId in: userIds and PermissionSetId =:psBEM.id];
        List<user> tobeUpdateUsers=new List<user>();
        List<GroupMember> groupBem=new List<GroupMember>();       
        List<PermissionSetAssignment> pmBem=new List<PermissionSetAssignment>();
        for(user u: users){
            boolean findg=false;
            boolean findp=false;
            for(GroupMember gm:gms) {
                if(gm.UserOrGroupId==u.id){
                    findg=true;
                    Integer index=gms.indexOf(gm);
                    gms.remove(index);
                    break;
                }
            } 
            for(PermissionSetAssignment psa:psas){
                if(psa.AssigneeId==u.id){
                    findp=true;
                    Integer index=psas.indexOf(psa);
                    psas.remove(index);
                    break;
                }
            }
            if(findg==false || findp==false) {
                if(u.IsActive ==false) {
                    u.IsActive =true;
                    tobeUpdateUsers.add(u);
                }
            }
            if(findg==false) groupBem.add(new GroupMember(GroupId=gp.id, UserOrGroupId =u.id ));
            if(findp==false) pmBem.add(new PermissionSetAssignment(PermissionSetId =psBEM.id, AssigneeId=u.id ));
        }
        system.debug('to be activated users '+tobeUpdateUsers.size());
        system.debug('to be added group memebers '+groupBem.size());
        system.debug('to be assigned PM '+pmBem.size());
        Database.update (tobeUpdateUsers, false);
        Database.insert (groupBem,false);
        Database.insert (pmBem,false);
        for(user u:tobeUpdateUsers ){
            u.IsActive =false;
        }
        Database.update (tobeUpdateUsers, false);
          
        }   
}