public with sharing class EMS_Attachement_Ext extends EMS_DynamicVFLoader {

    public Attachment attachment { get; set; }

    public EMS_Attachement_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Attachement_Layout');
        attachment = fetchAttachment(controller.getId());
    }

    private Attachment fetchAttachment(Id recordId) {
        List<Attachment> attachments = [SELECT ID, ParentId, Name FROM Attachment WHERE parentId = :recordId LIMIT 1];
        if (attachments.size() > 0) {
            return attachments[0];
        } else {
            return null;
        }
    }

    public PageReference edit() {
        Pagereference pageref = new pagereference('/apex/EMS_Attachment_Edit_Create_Layout?id=' + myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
}