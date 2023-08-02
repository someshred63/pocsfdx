/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-07-16
*  This is a dynamic Contact layout controller
*
*  Modification History
*  Date        Name        Description
*  02.22.2013    Kozminski    recordACallClick method added
*************************************************************/

public with sharing class GNE_SFA2_Contact_Ext extends GNE_SFA2_DynamicVFLoader {
    public GNE_SFA2_Contact_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/GNE_SFA2_Contact_Layout');
    }

    public PageReference edit() {
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Contact_Edit_Create_Layout?id=' + myObject.id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference newContact() {
        Id accountId = [SELECT AccountId FROM Contact WHERE Id =: myObject.Id Limit 1].AccountId;
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Contact_Edit_Create_Layout?objectId=' + accountId + '&retURL=/apex/GNE_SFA2_Contact_Layout?id=' + myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference addAttachmentsClick() {
        String sbcURL = '/apex/GNE_SFA2_UploadAttachment?Id=' + myObject.Id + '&retURL=%2F' + myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference viewAttachmentsClick() {
        String sbcURL = '/apex/GNE_SFA2_Attachment_layout?Id=' + myObject.Id + '&retURL=%2F' + myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
        return null;
    }
    public PageReference recordACallClick() {
        String sbcURL = '/apex/GNE_SFA2_Interaction_Edit_Create?accountId=' + myObject.get('accountId') + '&contactId=' + myObject.id + '&retURL=%2F' + myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference addAffiliationClick() {
        String sbcURL = '/apex/GNE_SFA2_Affiliation_Edit_Create_Layout?CF00N70000001tDNv_lkid=' + myObject.id + '&save_new=1&sfdc.override=1&retUrl=%2F' + myObject.id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    private PageReference newSurveyClick() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Create_Survey_Layout?objectId=' + myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    //relatedList Custom Buttons
    public override PageReference callMethod(String methodName) {
        if ('addAffiliationClick'.compareTo(methodName) == 0) {
            return addAffiliationClick();
        } else if ('newSurveyClick'.compareTo(methodName) == 0) {
            return newSurveyClick();
        }
        return super.callMethod(methodName);
    }
}