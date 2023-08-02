public without sharing class EMS_Attachment_Edit_Create_Ext {
    public Attachment attachment { get; set; }
    public EMS_Attachment_gne__c record { get; set; }
    private ApexPages.StandardController controller;

    public EMS_Attachment_Edit_Create_Ext(ApexPages.StandardController controller) {
        this.controller = controller;
        String preSetRecordTypeId = ApexPages.currentPage().getParameters().get('preSetRecordType');
        String eventId = ApexPages.currentPage().getParameters().get('objectId');

        record = (EMS_Attachment_gne__c) controller.getRecord();

        List<Attachment> attachmentsList = [SELECT Id, Name, Body, BodyLength FROM Attachment WHERE ParentId = :record.Id];
        if (attachmentsList.isEmpty()) {
            attachment = new Attachment();
        } else {
            attachment = attachmentsList[0];
        }

        if (preSetRecordTypeId != null) {
            record.RecordTypeId = (Id) preSetRecordTypeId;
        }

        if (eventId != null) {
            record.EMS_Event_gne__c = (Id) eventId;
        }
    }

    public PageReference save() {
        if (String.isBlank(record.Description_gne__c) && String.isBlank(attachment.Name)) {
            // no file was selected
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No file selected / hyperlink provided'));
            return null;
        }

        System.Savepoint sp = Database.setSavepoint();
        try {
            if(String.isNotBlank(attachment.Name)) {
                record.File_gne__c = attachment.Name;
            } else {
                record.File_gne__c = null;
            }


            upsert record;

            if(String.isNotBlank(record.File_gne__c)) {
                if(String.isBlank(attachment.Id)) attachment.ParentId = record.Id;
                upsert attachment;
            } else {
                delete [SELECT Id FROM Attachment WHERE ParentId = :record.Id];
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug(ex);
            attachment.Body = null; // Clear body to avoid viewstate error.
            attachment.Name = null;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured while saving the attachment: ' + ex.getMessage()));
            return null;
        }
        String url;
        if (ApexPages.currentPage().getParameters().get('retUrl') != null) {
            url = ApexPages.currentPage().getParameters().get('retUrl');
        } else {
            url = '/' + record.Id;
        }

        System.debug(url);
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
}