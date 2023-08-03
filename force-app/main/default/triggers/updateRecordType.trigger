/**
* @File Name:   updateRecordType
* @Description: This trigger will set up the record type based on the Request type .
* @group:       Apex Trigger
* @Modification Log :
______________________________________________________________________________________
* Ver       Date        Author        Modification
* 1.0       2021-11-23  Rabindranath
* 1.1       2022-08-11  Palani Jayachandran
*/
trigger updateRecordType on PRP_Request__c (before insert, before update) {
    
    String sitApprovalErrorMsg = 'Please update the status for the site(s) associated with the product in the request.';
    Map<String, Id> recordTypeMap = new Map<String, Id>();
    Set<String> submissionIds = new Set<String>();
    Set<String> approvedRequestIds = new Set<String>();
    Set<String> siteApprovalRequiredIds = new Set<String>();
    Set<String> submissionIdsToSkip = new Set<String>();
    List<PRP_Request__c> allRequests = new List<PRP_Request__c>();
    List<RecordType> recTypes = [
        SELECT Id, Name 
          FROM RecordType 
         WHERE sObjectType = 'PRP_Request__c' 
           AND isActive = true 
    ];
    
    for (RecordType rt : recTypes)
    {
        recordTypeMap.put(rt.Name, rt.Id);
    }
    
    for (PRP_Request__c pr : Trigger.new)
    {     
        if (pr.Request_Type__c == 'New Request')
        {
            pr.RecordTypeId = recordTypeMap.get('PRP New Request');
        }
        else if (pr.Request_Type__c == 'Update Information')
        {
            pr.RecordTypeId = recordTypeMap.get('PRP Update Request');
        }
        else
        {
            pr.RecordTypeId = recordTypeMap.get('PRP Transfer Request');
        }

        if (Trigger.isBefore && Trigger.isUpdate)
        {
            if (pr.Request_Status__c == 'In Revision' && trigger.oldMap.get(pr.Id).Request_Status__c != 'In Revision') {
                submissionIds.add(pr.Submission_Number__c);
            }
            
            if (pr.Request_Status__c == 'Approved' && trigger.oldMap.get(pr.Id).Request_Status__c != 'Approved') {
                approvedRequestIds.add(pr.Id);
            }
        }
    }

    if (submissionIds != null && submissionIds.size() > 0) {
        allRequests = [
            SELECT Id, Returned_To_Customer__c, Submission_Number__c 
              FROM PRP_Request__c 
             WHERE Submission_Number__c IN :submissionIds 
               AND Returned_To_Customer__c=1
        ];

        if (allRequests?.size() > 0) {
            for (PRP_Request__c pr:allRequests) {
                submissionIdsToSkip.add(pr.Submission_Number__c);
            }
        }

        for (PRP_Request__c pr : Trigger.new)
        {  
            if (submissionIds.contains(pr.Submission_Number__c) && 
               (submissionIdsToSkip == null || !submissionIdsToSkip.contains(pr.Submission_Number__c)))
            {
                pr.Returned_To_Customer__c = 1;
                submissionIdsToSkip.add(pr.Submission_Number__c);
            }
        }
    }

    System.debug('approvedRequestIds: ' + approvedRequestIds);
    if (approvedRequestIds != null && approvedRequestIds.size() > 0) {
        List<PRP_Site_Request__c> siteRequests = new List<PRP_Site_Request__c>();
        
        siteRequests = [
            SELECT Id, Request__c, Request__r.Product_Name__c, Site__r.Actemra_Status__c, Site__r.Hemlibra_Status__c,
                   Site__r.Lucentis_Status__c, Site__r.Rituxan_Status__c, Site__r.Xolair_Status__c,Site__r.Ocrevus_Status__c,site__r.Products__c
              FROM PRP_Site_Request__c 
             WHERE Request__c IN :approvedRequestIds
        ];

        for (PRP_Site_Request__c psr:siteRequests) 
        {
            System.debug(psr);
            String reqProduct = psr.Request__r.Product_Name__c;
            String siteProducts = psr.site__r.Products__c;

            if (siteProducts.containsIgnoreCase(reqProduct)) 
            {
                if ((reqProduct.equalsIgnoreCase('Actemra')  && String.isBlank(psr.Site__r.Actemra_Status__c))  ||
                    (reqProduct.equalsIgnoreCase('Hemlibra') && String.isBlank(psr.Site__r.Hemlibra_Status__c)) ||
                    (reqProduct.equalsIgnoreCase('Lucentis') && String.isBlank(psr.Site__r.Lucentis_Status__c)) ||
                    (reqProduct.equalsIgnoreCase('Rituxan')  && String.isBlank(psr.Site__r.Rituxan_Status__c))  ||
                    (reqProduct.equalsIgnoreCase('Ocrevus')  && String.isBlank(psr.Site__r.Ocrevus_Status__c))  ||
                    (reqProduct.equalsIgnoreCase('Xolair')   && String.isBlank(psr.Site__r.Xolair_Status__c))) 
                {
                    siteApprovalRequiredIds.add(psr.Request__c);
                }
            }
        }

        if (siteApprovalRequiredIds !=null) {
            for (Id reqId:siteApprovalRequiredIds) {
                Trigger.newMap.get(reqId).addError(sitApprovalErrorMsg);    
            }
        }
    }
}