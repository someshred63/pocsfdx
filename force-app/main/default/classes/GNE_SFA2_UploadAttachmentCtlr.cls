/* Author: Kishroe Chandolu on 1/9/2013
 * Controller for upload multiple attachment component
 */

public class GNE_SFA2_UploadAttachmentCtlr {
    // the parent object it
    public Id sobjId {get; set;}
    public Id pId {get; set;}
    public Id attachmentId {get; set;}
    // list of existing attachments - populated on demand
    public List<Attachment> attachments;
    public Attachment attachment;

    // list of new attachments to add
    public List<AttachmentWrapper> newAttWrap {get; set;}

    // the number of new attachments to add to the list when the user clicks 'Add More'
    public static final Integer NUM_ATTACHMENTS_TO_ADD = 2;

    public Boolean isEditMode {get; set;}

    // constructor
    public GNE_SFA2_UploadAttachmentCtlr() {
        isEditMode = false;
        if (!String.isEmpty(ApexPages.currentPage().getParameters().get('objectId'))) {
            pId = ApexPages.currentPage().getParameters().get('objectId');
            attachmentId = ApexPages.currentPage().getParameters().get('id');
            isEditMode = true;
        } else {
            pId = ApexPages.currentPage().getParameters().get('id');
        }
        // instantiate the list with a single attachment
        newAttWrap = new List<AttachmentWrapper> {new AttachmentWrapper()};
        // append NUM_ATTACHMENTS_TO_ADD to the new attachments list
        AddMore();
        System.debug('##### New Att Wrap === ' + newAttWrap);

    }

    // retrieve the existing attachments
    public List<Attachment> getAttachments() {
        // only execute the SOQL if the list hasn't been initialised
        if (null == attachments) {
            attachments = [select Id, ParentId, Name, Description from Attachment where parentId = :pId];
        }

        return attachments;
    }

    public Attachment getExistingAttachment() {
        System.debug('isEditMode === ' + isEditMode);
        attachment = [SELECT Id, Name, Description FROM Attachment WHERE Id = :attachmentId];
        return attachment;
    }

    public Pagereference userAccess() {
        UserRecordAccess recordAccess = [ SELECT RecordId, HasEditAccess  FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :pId LIMIT 1 ];
        //if user doesn't have the record level access, need to redirect to the Exception Layout page.
        System.PageReference pageReference = System.currentPageReference();
        if (recordAccess != null && recordAccess.HasEditAccess == false) {
            PageReference pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
            pageref.setredirect(true);
            return pageref;
        } else {
            return null ;
        }

    }

    // Add more attachments action method
    public void addMore() {
        // append NUM_ATTACHMENTS_TO_ADD to the new attachments list
        for (Integer idx = 0; idx < NUM_ATTACHMENTS_TO_ADD; idx++) {
            newAttWrap.add(new AttachmentWrapper());
        }
        system.debug('========> ' + NUM_ATTACHMENTS_TO_ADD);
    }

    // Save action method
    public PageReference save() {

        try {
            List<Attachment> toInsert = new List<Attachment>();
            for (AttachmentWrapper newAtt : newAttWrap) {

                if (newAtt.attachmentBody != null) {
                    Attachment attach = new Attachment();
                    attach.Name = newAtt.attachmentName;
                    attach.Body = newAtt.attachmentBody;
                    attach.Description = newAtt.attachmentDescription;
                    attach.ParentId = sobjId;
                    toInsert.add(attach);
                }
            }
            Database.insert(toInsert);
            newAttWrap.clear();

            // null the list of existing attachments - this will be rebuilt when the page is refreshed
            attachments = null;
        } catch (Exception e) {
            System.debug('====Exception====' + e);
            return GNE_SFA2_Util.redirectToErrorPage('An error occured while saving the record.', Apexpages.currentPage().getUrl(), e.getMessage());
        }
        // send the user to the detail page for the sobject
        return new PageReference('/' + sobjId);
    }

    // Update action method
    public PageReference updateAttach() {
        update attachment;
        return new PageReference('/' + pId);
    }

    // Delete action method
    public Id attachId {get; set;}
    public PageReference deleteAttachment() {
        try {
            Attachment objAttach = [select Id, ParentId from Attachment where Id = :attachId];
            sobjId = objAttach.ParentId;
            Database.delete(objAttach);
        } catch (Exception e) {
            System.debug('====Exception====' + e);
            return GNE_SFA2_Util.redirectToErrorPage('An error occured while deleting the record.', Apexpages.currentPage().getUrl(), e.getMessage());
        }
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Attachment_layout?id=' + sobjId + '&retURL=' + sobjId);
        pageref.setredirect(true);
        return pageref;
    }

    // Action method when the user is done
    public PageReference Cancel() {
        // send the user to the detail page for the sobject
        return new PageReference('/' + pId);
    }


    // WRAPPER CLASS

    public class AttachmentWrapper {

        public String attachmentName {get; set;}
        public Blob attachmentBody {get; set;}
        public String attachmentDescription {get; set;}

    }

}