public with sharing class gFRS_W9AttachmentController {

    private final GFRS_Organization__c organization ;

    public List<Attachment> lAttachments { get; set; }
    public Id currentAtt                 { get; set; }
    public String SelectedId             { get; set; }

    public gFRS_W9AttachmentController(ApexPages.StandardController controller) {

        List<String> lFields = new List<String>{'W9_Form_W_8BEN_Form__c'};

        controller.addFields(lFields);
        
        organization = (GFRS_Organization__c)controller.getRecord();
        currentAtt   = organization.W9_Form_W_8BEN_Form__c;
        lAttachments = new List<Attachment>([SELECT Id, Name, CreatedBy.Name, LastModifiedDate FROM Attachment WHERE ParentId =:organization.id ORDER BY LastModifiedDate DESC]);

    }
    public PageReference redirect(){
        
        PageReference pageRef = new PageReference('/p/attach/NoteAttach?pid='+organization.id+'&retURL=/apex/gFRS_W9Attachment?id='+organization.id);
        pageRef.setRedirect(true);

        return pageRef;
    }

    public PageReference saveAndRedirect(){
        
        organization.W9_Form_W_8BEN_Form__c = SelectedId;

        try{

            update organization;
            currentAtt = organization.W9_Form_W_8BEN_Form__c;
            
            //PageReference pageRef = new PageReference('/apex/gFRS_W9Attachment?id='+organization.id);
            //pageRef.setRedirect(true);

            return null;
            

        }catch (Exception e){

            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));

            return null;

        }

        return null;

    }

}