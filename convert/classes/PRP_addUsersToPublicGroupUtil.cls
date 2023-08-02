/**
* @author : Rabindranath
* @date 10/21/22
* @description : Util class for mapping the User to BEM Members Public group and BEM permission set.
----------------------------------------------------------------------------------------------------
**/
public  class PRP_addUsersToPublicGroupUtil {
    
    @future
    public static void addUsertoGrp(Set<Id> userIds){
        System.debug('idlist!!!!###'+userIds);
        List<GroupMember> GMlist = new List<GroupMember>();
        Id groupId = Label.PRP_BEM_Group_Id;
        List<user> userlist= [select id from user where id in:userIds and IsActive = true  limit 10000 for view];
        
        for(user recid:userlist){          
            GroupMember GM = new GroupMember();
            GM.GroupId = groupId;            
            GM.UserOrGroupId = recid.id;
            GMList.add(GM) ;
        }
        if(!GMList.isEmpty() ) {
            upsert GMList;
        }
    }
    @future
    public static void delUserFromGrp(List<Id> userIds) {
        Id grpId = Label.PRP_BEM_Group_Id;
        List<GroupMember> grpList  = [Select Id from GroupMember where GroupId =: grpId and UserOrGroupId in : userIds ];
        if(!grpList.isEmpty()){
            delete grpList;
        }
    }
    @future
    public static void assignPermissionSet(Set<Id> userIds){
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PRP_BEM_Member'];
        for (User u : [SELECT ID,UserRole.Name,Profile.Name,IsActive FROM User WHERE IsActive = true AND id in: userIds AND id Not in(SELECT AssigneeId from PermissionSetAssignment where PermissionSetId =:ps.Id) for view] ){ // Add fields as per your requirement...
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.Id, AssigneeId = u.Id);
            permissionSetList.add(psa);
        }
        try{
            
            System.debug('permissionSetList'+permissionSetList);
            if(!permissionSetList.isEmpty()){
                Database.UpsertResult[] results = Database.upsert(permissionSetList,false);
        }
            
        }catch(exception e){
            system.debug('exception caught' + e);
        }
    }
}