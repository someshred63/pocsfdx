public without sharing class EDM_Section_Comments_Controller {

	public String componentID { get; set; }
	public String sectionHeader { get; set; }
	public Id objectId { get; 
		set {
			objectId = value;
			objectName = objectId.getSObjectType().getDescribe().getName();
		} 
	}
	
	public Boolean showDel { get; set; }

	public EDM_Comment_gne__c newComment { get ; set; }
	public String Body { get; set; }
	public String CommentToDel { get; set; }
	public List<EDM_Comment_gne__c> Comments { 
		get {
			if (Comments == null) {
				Comments = loadComments();
			}
			return Comments;
		} 
		set; 
	}

	private String objectName;

	public EDM_Section_Comments_Controller() {
		componentID = '_comm' + getRanomID();
	}

	public PageReference addComment() {
		newComment = new EDM_Comment_gne__c();	
		newComment.EDM_Body_gne__c = Body;
		if (objectName == 'EDM_IABP_gne__c') {
			newComment.EDM_Parent_IABP_gne__c = objectId;
		}
		else if (objectName == 'EDM_AABP_gne__c') {
			newComment.EDM_Parent_AABP_gne__c = objectId;
		}
		newComment.EDM_Section_gne__c = sectionHeader;
		insert newComment;
		Comments.clear();
		Comments = loadComments();		
		return null;
	}

	public PageReference delComment() {
		EDM_Comment_gne__c toDel = [SELECT Id FROM EDM_Comment_gne__c WHERE Id = :CommentToDel];
		Integer i = 0;
		for (EDM_Comment_gne__c cmt : Comments) {
			if (cmt.Id == CommentToDel) {
				break;
			}
			i++;
		}
		Comments.remove(i);
		delete toDel;
		return null;
	}

	private String getRanomID() {
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
	    String randStr = '';
	    while (randStr.length() < 20) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
	       randStr += chars.substring(idx, idx+1);
	    }
	    return randStr; 
	}

	private List<EDM_Comment_gne__c> loadComments() {
		if (objectName == 'EDM_IABP_gne__c') {
			return [SELECT Id, Name, CreatedById, CreatedDate, EDM_Body_gne__c, EDM_Parent_AABP_gne__c, 
									EDM_Parent_IABP_gne__c, EDM_Section_gne__c, EDM_Type_gne__c, CreatedBy.Name 
							FROM EDM_Comment_gne__c
							WHERE EDM_Parent_IABP_gne__c = :objectId AND EDM_Section_gne__c = :sectionHeader 
							ORDER BY CreatedDate];
		}
		else if (objectName == 'EDM_AABP_gne__c') {
			return [SELECT Id, Name, CreatedById, CreatedDate, EDM_Body_gne__c, EDM_Parent_AABP_gne__c, 
									EDM_Parent_IABP_gne__c, EDM_Section_gne__c, EDM_Type_gne__c, CreatedBy.Name 
							FROM EDM_Comment_gne__c
							WHERE EDM_Parent_AABP_gne__c = :objectId AND EDM_Section_gne__c = :sectionHeader
							ORDER BY CreatedDate];
		} 
		else {
			return null;
		}
	}

}