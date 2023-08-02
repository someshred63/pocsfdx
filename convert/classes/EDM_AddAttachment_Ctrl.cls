global without sharing class EDM_AddAttachment_Ctrl { //global because of iframe and remoteAction
	public Attachment newAtt { get; set; }
	public EDM_Attachment_gne__c edmAttachment { get; set; }	
	public Id parentId { get; set; }
	private Id attachmentIdToUpdate;
	private EDM_IABP_gne__c parentIABP;

    public String SystemType {get; set; }

	public Boolean isAABP {
		get {
			return parentId != null && Schema.EDM_AABP_gne__c.SObjectType == parentId.getSobjectType();
		}
	}
	public Boolean isIABP {
		get {
			return parentId != null && Schema.EDM_IABP_gne__c.SObjectType == parentId.getSobjectType();
		}
	}

	public Boolean isExeSum {get; private set;}

	public Boolean attachmentUploaded {get; set;}
	public String uploadedFileName {get; set;}
    public EDM_ABS_Comment_gne__c ABSComment {get; set;}

    public EDM_AddAttachment_Ctrl() {
		newAtt = new Attachment();

		attachmentIdToUpdate = ApexPages.currentPage().getParameters().get('attachmentId');

        parentId = ApexPages.currentPage().getParameters().get('parentId');
		SystemType = ApexPages.currentPage().getParameters().get('SystemType');
		initEdmAttachmentRecord();
        initEdmABSCommentRecord();

		isExeSum = false;
		EDM_IABP_gne__c iabp;
		if (isIABP) {
			iabp = [SELECT EDM_Parent_IABP_gne__c, EDM_Executive_Summary_gne__c from EDM_IABP_gne__c where id = :parentId LIMIT 1];
			isExeSum = iabp.EDM_Executive_Summary_gne__c;
		}

		if(isExeSum) {
			parentIABP = [SELECT Id FROM EDM_IABP_gne__c WHERE Id =: iabp.EDM_Parent_IABP_gne__c AND EDM_Historical_gne__c = false LIMIT 1];
		}

		attachmentUploaded = false;
	}

	private void initEdmAttachmentRecord() {
		if (attachmentIdToUpdate == null) {
			edmAttachment = new EDM_Attachment_gne__c();
		} else {
			edmAttachment = [SELECT ID FROM EDM_Attachment_gne__c WHERE Id = :attachmentIdToUpdate];
		}
	}

    private void initEdmABSCommentRecord() {
	    ABSComment = new EDM_ABS_Comment_gne__c();
    }

	public PageReference addAttachment() {
		if(newAtt.body == null && SystemType != 'ABS Comment') {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please choose a File to upload'));
			return ApexPages.currentPage();
		}
		SavePoint sp = Database.setSavepoint(); 
		try {
			if ((isExeSum && systemType == 'Final Agenda') || systemType == 'Spend') {
				removeAttachmentOfSpecifiedSystemType(parentId, systemType);
			}

			edmAttachment.EDM_Upload_Date_gne__c = System.today();

			if (attachmentIdToUpdate == null && newAtt.body != null) {
				insertEdmAttachment();
				insertAttachment(edmAttachment.Id);
				updateEdmAttachmentLink();
			} else if(SystemType != 'ABS Comment') {
				insertAttachment(attachmentIdToUpdate);
				edmAttachment.Name = newAtt.Name;
				updateEdmAttachmentLink();
			}

			if (SystemType == 'ABS Comment') {
				ABSComment.EDM_Attachment_gne__c = edmAttachment.EDM_Link_gne__c;
				ABSComment.EDM_Parent_IABP_gne__c = parentId;
				ABSComment.EDM_Date_Added_gne__c = System.now();
				insert ABSComment;
				if (isExeSum) {
					EDM_ABS_Comment_gne__c newAbsComment = ABSComment.clone(false, true);
					newAbsComment.EDM_Parent_IABP_gne__c = parentIABP.Id;
					newAbsComment.EDM_Parent_ABS_Comment_gne__c = ABSComment.Id;
					insert newAbsComment;
				}
			}
		} catch (Exception ex) {
			Database.rollback(sp);
			System.debug(ex.getMessage());
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
		} finally {
			System.debug('finally');
			attachmentUploaded = true;
			uploadedFileName = newAtt.Name;

			newAtt = new Attachment();
			initEdmAttachmentRecord();
            initEdmABSCommentRecord();
		}
		
		return null;
	}

	public static void removeExeSumFinalAgendaFor(Id iabpId) {
		removeAttachmentOfSpecifiedSystemType(iabpId, 'Final Agenda');
	}

	private static void removeAttachmentOfSpecifiedSystemType(Id iabpId, String systemTypesToDel) {
		delete [SELECT Id From EDM_Attachment_gne__c where EDM_Parent_IABP_gne__c = :iabpId and EDM_System_Type_gne__c = :systemTypesToDel];
	}

	private void insertEdmAttachment() {
		edmAttachment.Name = newAtt.Name;
		if (String.isBlank(edmAttachment.EDM_Document_Name_gne__c)) {
			edmAttachment.EDM_Document_Name_gne__c = newAtt.Name;
		}
		setParent();

		edmAttachment.EDM_System_Type_gne__c = systemType;

		if (isExeSum && systemType == 'Final Agenda') {
			EDM_IABP_gne__c exeSumRecord = [SELECT Id, EDM_ExeSum_Final_Agenda_Source_gne__c FROM EDM_IABP_gne__c WHERE Id = :parentId LIMIT 1];
			exeSumRecord.EDM_ExeSum_Final_Agenda_Source_gne__c = 'ExeSum';
			update exeSumRecord;
		}
		//if (String.isBlank(edmAttachment.EDM_Type_gne__c)) {
		//	edmAttachment.EDM_Type_gne__c = 'TBD';
		//}
		edmAttachment.EDM_ID_For_Comparator_gne__c = parentId + '_' + EDM_ABM_Utils.getRandomID();
		insert edmAttachment;
	}

    private void insertAttachment(Id edmAttachmentId) {
        newAtt.parentId = edmAttachmentId;
        insert newAtt;
    }

	private void setParent() {
		if (isAABP) {
			edmAttachment.EDM_Parent_AABP_gne__c = parentId;
		} else if (isIABP || isExeSum) {
			edmAttachment.EDM_Parent_IABP_gne__c = ABSComment.EDM_Parent_IABP_gne__c = parentId;
		}
	}

	private void updateEdmAttachmentLink() {
		edmAttachment.EDM_Link_gne__c = EDM_Classification_Utils.prepareLinkToAttachment(newAtt);
		update edmAttachment;
	}

	@RemoteAction
	global static Integer getAttachmentCount(Id pId) { //global because of iframe
		if (Schema.EDM_AABP_gne__c.SObjectType == pId.getSobjectType()) {
			return [SELECT Id FROM EDM_Attachment_gne__c WHERE EDM_Parent_AABP_gne__c = :pId].size();
		} else if (Schema.EDM_IABP_gne__c.SObjectType == pId.getSobjectType()) {
			return [SELECT Id FROM EDM_Attachment_gne__c WHERE EDM_Parent_IABP_gne__c = :pId].size();
		}
		return 0;
	}

	public Integer getAttachmentCountLimit() {
		return isAABP ? 20 : 100;
	}

	public String getFileTypesAvailableForSelection() {
		return isExeSum && systemType == 'Final Agenda' ? 'application/pdf' : '';
	}

	public Boolean getShowTypeAndDescriptionFields(){
		Boolean showFields = isIABP && !isExeSum;

		if (systemType == 'Spend') {
			showFields = false;
		} else if (isIABP && isExeSum && systemType == 'Final Agenda'){
			showFields = false;
		} else if(isIABP && systemType == 'Event Document'){
			showFields = true;
		} else if(isIABP && systemType == 'ABS Comment'){
            showFields = false;
        }

		return showFields;
	}

    public Boolean getShowABSCommentField(){
        Boolean showFields = isIABP && !isExeSum;

        if (systemType == 'Spend') {
            showFields = false;
        } else if (isIABP && isExeSum && systemType == 'Final Agenda'){
            showFields = false;
        } else if(isIABP && systemType == 'Event Document'){
            showFields = false;
        } else if(isIABP && systemType == 'ABS Comment'){
            showFields = true;
        }

        return showFields;
    }
}