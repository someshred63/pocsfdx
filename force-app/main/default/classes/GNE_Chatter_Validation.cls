public with sharing class GNE_Chatter_Validation {

    private static Set<String> chatterPermissionSetNames = GNE_Chatter_Permission_Set_Name__c.getAll().keySet();

    public static Boolean isChatterEnabled() {
        if(GNE_SFA2_Util.isCrmUser() || GNE_SFA2_Util.isChatterUser() || GNE_SFA2_Util.isChatterFreeUser() || GNE_SFA2_Util.isFrmUser()) {
        	return true;
        } else {
        	return false;
        }
    }

    public static void onBeforeInsertFeedItem(Map<Id, FeedItem> oldFeedItemMap,  List<FeedItem> newFeedItemList) {
        feedItemAdding(oldFeedItemMap, newFeedItemList);
    }

    public static void onBeforeInsertFeedComment(Map<Id, FeedComment> oldFeedCommentMap,  List<FeedComment> newFeedCommentList) {
        feedCommentAdding(oldFeedCommentMap, newFeedCommentList);
    }

    public static void onBeforeInsertCollaborationGroup(Map<Id, CollaborationGroup> oldCollaborationGroupMap,  List<CollaborationGroup> newCollaborationGroupList) {
        collaborationGroupAdding(oldCollaborationGroupMap, newCollaborationGroupList);

    }

    public static void onBeforeInsertCollaborationGroupMember(Map<Id, CollaborationGroupMember> oldCollaborationGroupMemberMap,  List<CollaborationGroupMember> newCollaborationGroupMemberList) {
        collaborationGroupMemberAdding(oldCollaborationGroupMemberMap, newCollaborationGroupMemberList);

    }

    /*Check base on custom setting if user has permission to add FeedItem */
    private static void feedItemAdding(Map<id, FeedItem> oldFeddItemMap, List<FeedItem> newFeedItems) {
        if (!isChatterEnabled()) {
            for (FeedItem f : newFeedItems) {
                f.addError(System.Label.GNE_Chatter_Insufficient_Priviliges);
            }
        }
    }

    /*Check base on custom setting if user has permission to add FeedComment */
    private static void feedCommentAdding(Map<id, FeedComment> oldFeddCommentMap, List<FeedComment> newFeedComments) {
        if (!isChatterEnabled()) {
            for (FeedComment f : newFeedComments) {
                f.addError(System.Label.GNE_Chatter_Insufficient_Priviliges);
            }
        }
    }

    /*Check base on custom setting if user has permission to add Collaboration Group */
    private static void collaborationGroupAdding(Map<id, CollaborationGroup> oldCollaborationGroupMap, List<CollaborationGroup> newCollaborationGroups) {
        if (!isChatterEnabled()) {
            for (CollaborationGroup f : newCollaborationGroups) {
                f.addError(System.Label.GNE_Chatter_Insufficient_Priviliges);
            }
        }
    }

    /*Check base on custom setting if user has permission to add CollaborationGroupMember */
    private static void collaborationGroupMemberAdding(Map<id, CollaborationGroupMember> oldCollaborationGroupMap, List<CollaborationGroupMember> newCollaborationGroupMembers) {
        if (!isChatterEnabled()) {
            for (CollaborationGroupMember f : newCollaborationGroupMembers) {
                f.addError(System.Label.GNE_Chatter_Insufficient_Priviliges);
            }
        }
    }

}