public abstract with sharing class EMS_Dynamic_VF_Edit_Create extends GNE_SFA2_Dynamic_VF_Edit_Create {

    public EMS_Dynamic_VF_Edit_Create(ApexPages.StandardController controller, String viewPage) {
        super(controller, viewPage);
    }

    public override virtual PageReference save() {
        isClone = false;
        if (System.currentPageReference().getParameters().get('isClone') != null && System.currentPageReference().getParameters().get('isClone') == 'true') {
            myObject = myObject.clone();
            isClone = true;
        }
        if (myObject.id == null && !isClone) {
            if (recordTypeName != null && recordTypeName != '') {
                RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName AND SobjectType = :myObjectType limit 1][0];
                myObject.put('recordTypeId', recordType.Id);
            }
        }
        pagereference pageref;
        try {
            upsert myObject;
            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), myObject.Id);
            if (!userRecordAccess.HasReadAccess) {
                return Page.GNE_SFA2_Access_Denied;
            }
            String viewURL = viewPage + '?id=' + myObject.Id;
            if (retURL != null) {
                viewURL = viewURL + '&retURL=' + retURL;
            }
            pageref = new pagereference(viewURL);
        } catch (Exception e) {
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                String strId = e.getMessage().substring(e.getMessage().indexof('id:') + 4, e.getMessage().indexof('id:') + 19);
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Invalid Data: Duplicate Value On Record ' + strId));
                return null;
            } else if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                Apexpages.addMessages(e);
                return null;
            } else if (e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Value does not exist or does not match filter criteria.'));
                return null;
            } else if (e.getMessage().contains('TRANSFER_REQUIRES_READ')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'User you selected can not be owner of the record. New owner must have object read permission.'));
                return null;
            } else if (e.getMessage().contains('CIRCULAR_DEPENDENCY')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, ''));
                return null;
            } else if (e.getMessage().contains('INVALID_CROSS_REFERENCE_KEY')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, ''));
                return null;
            } else if (e.getMessage().contains('INSUFFICIENT')) {
                return GNE_SFA2_Util.redirectToErrorPage('You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.', Apexpages.currentPage().getUrl(), e.getMessage());
            } else if (e.getMessage().contains('ENTITY_IS_LOCKED')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Error: This item is currently pending approval and cannot be updated at this time.'));
                return null;
            } else {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, e.getMessage()));
                return null;
            }
            return null;
        }

        if (myObjectType.equals('Task')) {
            //Removed additional condition && retURL.contains('id')
            if (retURL != null) {
                pageref = new pagereference(retURL);
            } else {
                pageref = new pagereference('/apex/GNE_SFA2_MyTasks');
            }
        }
        pageref.setredirect(true);
        return pageref;
    }
}