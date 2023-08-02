public without sharing class EMS_Upload_Attachments_Ctrl {

    public static final Integer NUMBER_OF_ATTACHMENTS = 5;

    public List<AttachmentWrapper> attachmentWrappers { get; set; }
    public List<AttachmentWrapper> notEmptyAttachmentWrappers;
    private ApexPages.StandardController controller;
    private String eventId;


    public EMS_Upload_Attachments_Ctrl(ApexPages.StandardController controller) {
        this.controller = controller;
        eventId = ApexPages.currentPage().getParameters().get('objectId');

        initAttachments();
    }

    public void initAttachments() {
        attachmentWrappers = new List<AttachmentWrapper>();
        for (Integer i = 0; i < NUMBER_OF_ATTACHMENTS; i++) {
            attachmentWrappers.add(new AttachmentWrapper(eventId));
        }
    }

    public PageReference save() {
        System.Savepoint sp = Database.setSavepoint();

        List<Attachment> toInsert = new List<Attachment>();
        List<EMS_Attachment_gne__c> emsAttachmentsToInsert = new List<EMS_Attachment_gne__c>();
        notEmptyAttachmentWrappers = new List<AttachmentWrapper>();

        for (AttachmentWrapper newAtt : attachmentWrappers) {
            if (newAtt.isEmpty == false) {
                notEmptyAttachmentWrappers.add(newAtt);
            }
        }

        for (AttachmentWrapper newAtt : notEmptyAttachmentWrappers) {
            if (newAtt.isEmpty == false) {
                emsAttachmentsToInsert.add(newAtt.att);
            }
        }

        try {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            insert emsAttachmentsToInsert;

            for (Integer i = 0; i < notEmptyAttachmentWrappers.size(); i++) {
                if (notEmptyAttachmentWrappers[i].hasFile) {
                    Attachment attach = new Attachment();
                    attach.Name = notEmptyAttachmentWrappers[i].att.File_gne__c;
                    attach.Body = notEmptyAttachmentWrappers[i].attachmentBody;
                    attach.ParentId = emsAttachmentsToInsert[i].Id;
                    toInsert.add(attach);
                }
            }
            insert toInsert;

            for (AttachmentWrapper att : attachmentWrappers) {
                att.attachmentBody = null; // Clear body to avoid viewstate error.
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            for (AttachmentWrapper att : attachmentWrappers) {
                att.attachmentBody = null; // Clear body to avoid viewstate error.
            }

            return null;
        }

        // send the user to the detail page for the sobject
        String url;
        if (ApexPages.currentPage().getParameters().get('retUrl') != null) {
            url = ApexPages.currentPage().getParameters().get('retUrl');
        } else {
            url = '/' + eventId;
        }
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        return page;
    }

    public PageReference cancel() {
        String url;
        if (ApexPages.currentPage().getParameters().get('retUrl') != null) {
            url = ApexPages.currentPage().getParameters().get('retUrl');
            PageReference page = new PageReference(url);
            page.setRedirect(true);
            return page;
        } else {
            return controller.cancel();
        }

    }

    public class AttachmentWrapper {
        public EMS_Attachment_gne__c att { get; set; }
        public Blob attachmentBody { get; set; }
        public Boolean isEmpty { get {return !hasFile && !hasHyperlink;} }
        public Boolean hasFile { get {return attachmentBody != null;} }

        public Boolean hasHyperlink {
            get {
                return String.isNotBlank(att.Description_gne__c);
            }
        }

        public AttachmentWrapper(Id eventId) {
            att = new EMS_Attachment_gne__c(EMS_Event_gne__c = eventId);
        }
    }
}