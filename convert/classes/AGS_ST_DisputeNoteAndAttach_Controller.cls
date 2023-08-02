/** @date 11/25/2012
* @Author Pawel Sprysak
* @description Controller Extension for AGS_ST_DisputeNoteAndAttachment_gne page
*/
public without sharing class AGS_ST_DisputeNoteAndAttach_Controller {
    private final static String CCO_GROUP_NAME = 'GNE-AGS-CCO-Analyst-Group';

    public Id disputeId { get; set; }
    public Id disputeNoteAndAttachmentId { get; set; }
    public Boolean isFromEmail { get; set; }
    public Note disputeNote { get; set; }
    public AGS_ST_Dispute_Note_and_Attachment_gne__c dnaObject { get; set; }
    public List<AttachmentWrapper> disputeAttachments { get; set; }
    public String actionMessages { get; set; }
    // Flag for checking is this actual user note
    public Boolean isOwner {
        get {
            if(dnaObject.LastModifiedById == Userinfo.getUserId()) {
                return true;
            } else {
                return false;
            }
        }
    }

    /** @date 11/25/2012
    * @Author Pawel Sprysak
    * @description Constructor for AGS_ST_DisputeNoteAndAttach_Controller
    */
    public AGS_ST_DisputeNoteAndAttach_Controller() {
        // GETTERS
        disputeId = (Id) ApexPages.currentPage().getParameters().get('id');
        disputeNoteAndAttachmentId = (Id) ApexPages.currentPage().getParameters().get('dnaId');

        // Initialization
        disputeAttachments = new List<AttachmentWrapper>();
        fillAttachmentList();
        disputeNote = AGS_ST_DbUtils.getNoteByNoteAndAttachmentId(disputeNoteAndAttachmentId);
        dnaObject = AGS_ST_DbUtils.getDisputeNotesAndAttById(disputeNoteAndAttachmentId);
        if(dnaObject.Communication_Method_gne__c == '' || dnaObject.Communication_Method_gne__c == null) {
            isFromEmail = false;
        } else {
            isFromEmail = true;
        }
        actionMessages = '';
    }

    /** @date 11/25/2012
    * @Author Pawel Sprysak
    * @description Method for filling up Attachment List
    */
    private void fillAttachmentList() {
        disputeAttachments.clear();
        for(Attachment aw : AGS_ST_DbUtils.getAttachmentsByNoteAndAttachmentId(disputeNoteAndAttachmentId)) {
            disputeAttachments.add(new AttachmentWrapper(aw));
        }
    }

    /** @date 11/25/2012
    * @Author Pawel Sprysak
    * @description Method for redirecting back to Dispute Detail Page
    * @return PageReference
    */
    public PageReference backToDisputeDetail() {
        return new PageReference('/apex/AGS_ST_DisputeDetail_gne?id='+disputeId);
    }

    /** @date 11/25/2012
    * @Author Pawel Sprysak
    * @description Method for deleting selected attachmetns
    * @return PageReference
    */
    public PageReference deleteAttachments() {
        actionMessages = '';
        // Check is this attachment from email and actual logged user is owner
        if(!isFromEmail && isOwner) {
            List<Attachment> attToDel = new List<Attachment>();
            for(AttachmentWrapper aw : disputeAttachments) {
                if(aw.isSelected) {
                    attToDel.add(aw.attachment);
                }
            }
            if(attToDel.size() > 0) {
                delete attToDel;
            }
            fillAttachmentList();
        }
        actionMessages = 'Attachment has been deleted<br/>';
        return null;
    }

    /** @date 11/25/2012
    * @Author Pawel Sprysak
    * @description Attachment wrapper class (added selecting possibility)
    */
    class AttachmentWrapper {
        public Boolean isSelected { get; set; }
        public Attachment attachment { get; set; }
        // Constructor
        public AttachmentWrapper(Attachment att) {
            attachment = att;
        }
    }
}