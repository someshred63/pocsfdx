public class addUsersToPublicGroupUtil {
    @future
  public static void addUsertoGrp(List<Id> userIds){
        List<GroupMember> GMlist = new List<GroupMember>();
        Id groupId = Label.PRP_BEM_Group_Id;
        GroupMember GM = new GroupMember();
        GM.GroupId = groupId;
        GM.UserOrGroupId = userIds[0];
        GMList.add(GM) ;
        if(GMList.size() > 0) {
            insert GMList;
        }
    }
    @future
    public static void delUserFromGrp(List<Id> userIds) {
        Id grpId = Label.PRP_BEM_Group_Id;
        List<GroupMember> grpList  = [Select Id from GroupMember where GroupId =: grpId and UserOrGroupId in : userIds ];
        if(grpList.size() > 0){
            delete grpList;
        }
    }
    
}