/**
 * Created by kozminsl on 15.04.2019.
 */

public with sharing class GNE_FCR_Attachment_Controller {
    public Id fcrId { get; set; }
    public Id userId { get; set; }
    public Boolean isReadOnly { get; set; }
    public Id attachmentIdToRemove { get; set; }
    public String msgThrown { get; set; }


    public void loadAttachments() {

    }

    public void throwErrorMsg() {
        if (String.isNotBlank(msgThrown)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msgThrown);
            ApexPages.addMessage(myMsg);
        }
    }

    @RemoteAction
    public static String uploadAttachment(Id attachmentId, String base64BlobValue, String fileName, String contentType, String fcrId) {
        Savepoint sp = Database.setSavepoint();
        try {
            if (attachmentId != null) {
                List<Attachment> existingAttachment = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE Id = :attachmentId];
                if (existingAttachment.size() > 0) {
                    String existingBody = EncodingUtil.base64Encode(existingAttachment[0].Body);
                    String presentBody = existingBody + base64BlobValue;
                    existingAttachment[0].Body = EncodingUtil.base64Decode(presentBody);
                    update existingAttachment[0];
                    return existingAttachment[0].Id;
                }
            }

            Attachment attachment = new Attachment(
                    ParentId = fcrId,
                    Body = EncodingUtil.base64Decode(base64BlobValue),
                    Name = fileName,
                    contentType = contentType
            );
            insert attachment;
            return attachment.Id;

        } catch (Exception ex) {
            Database.rollback(sp);
            throw ex;
        }
    }

    private class FcrAttachment {
        public Id Id { get; private set; }
        public Boolean CanBeRemoved { get; private set; }
        public String Name { get; private set; }
        public Datetime DateAdded { get; private set; }

        public FcrAttachment(Attachment attachment) {
            this.Id = attachment.Id;
            this.CanBeRemoved = attachment.OwnerId == UserInfo.getUserId();
            this.Name = attachment.Name;
            this.DateAdded = attachment.CreatedDate;
        }
    }

}