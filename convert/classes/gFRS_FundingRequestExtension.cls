/**
* @author GFRS Dev Team
* @date 27/09/2017
* @description gFRS_CustomLinkController class - controller for Custom Link Visualforce Pages
*/
public without sharing class gFRS_FundingRequestExtension {
    
    private final ApexPages.StandardController stdCtrl;
    
    private final Set<Boolean> userTypes = new Set<Boolean>();
    
    public final GFRS_Organization__c org { get; private set; }
    
    public final gFRS_Tasks__c selectedOwner { get; private set; }
    
    public Note notes { get; private set; }
    
    public final List<GFRS_FundingRequestWrapper> requests { get; private set; }
    
    public final Id inboundFundingRequest { get; private set; }
    
    public Boolean isInternal { get; private set; }
    
    public Boolean oldOwner;
    
    public Attachment changeOwner_doc{
        get {
        if (changeOwner_doc == null)
            changeOwner_doc = new Attachment();
            return changeOwner_doc;
        }
        set;
    }
    
    public SelectOption[] orgTypeOptions {
        get {
            final SelectOption[] results = new SelectOption[]{ };
            for (String orgType : sObjectType.GFRS_Organization__c.getRecordTypeInfosByName().keySet()) {
                results.add(new SelectOption(orgType, orgType));
            }
            return results;
        }
    }
    
    public gFRS_FundingRequestExtension(final ApexPages.StandardController ctrl) {
        try {
            final Map<String, String> params = ApexPages.currentPage().getParameters();
            userTypes.add(gFRS_Util_NoShare.checkCustomPermission('gFRS_Transfer_Internal_Requests') ? true : null);
            userTypes.add(gFRS_Util_NoShare.checkCustomPermission('gFRS_Transfer_External_Requests') ? false : null);
            final GFRS_Organization__c[] orgs = String.isBlank(params.get('orgId')) ? new GFRS_Organization__c[]{ } : [
                SELECT Id, Name, RecordType.Name FROM GFRS_Organization__c
                WHERE Id = :params.get('orgId') LIMIT 1
            ];
            org = orgs.isEmpty() ? new GFRS_Organization__c() : orgs[0];
            inboundFundingRequest = params.get('frId');
        } catch (QueryException e) {
            ApexPages.addMessages(e);
        } finally {
            isInternal = userTypes.contains(true) ? true : userTypes.contains(false) ? false : null;
            requests = new GFRS_FundingRequestWrapper[]{ };
            selectedOwner = new gFRS_Tasks__c();
            notes = new Note();
            userTypes.remove(null);
            findRequests();
            stdCtrl = ctrl;
            oldOwner = false;
        }
    }
    
    public void findRequests() {
        isInternal = ApexPages.currentPage() != null &&
            ApexPages.currentPage().getParameters().get('isInternalUser') != null ?
            Boolean.valueOf(ApexPages.currentPage().getParameters().get('isInternalUser')) : isInternal;
        isInternal = userTypes.contains(isInternal) ? isInternal : null;
        requests.clear();
        for (GFRS_Funding_Request__c req : org.Id == null || isInternal == null ? new GFRS_Funding_Request__c[]{ } : [
            SELECT Name, CreatedById, LastModifiedById, OwnerId, RecordTypeId, Sub_Status__c, Status__c, Event_Program_Title__c
            FROM GFRS_Funding_Request__c
            WHERE Organization__c = :org.Id
            AND ((Status__c != 'Closed' AND (Record_Type_Name__c = 'Field Initiated Exhibits' OR Record_Type_Name__c = 'Sci/Pipeline Exhibits & Other Non-Promo' OR Record_Type_Name__c = 'Corporate Memberships' OR Record_Type_Name__c = 'Exhibits & Other Promos')) OR (Record_Type_Name__c = 'Fellowships' OR Record_Type_Name__c = 'IMED' OR Record_Type_Name__c = 'HC Char' OR Record_Type_Name__c = 'Philanthropic' OR Record_Type_Name__c = 'Scientific Projects'))
            AND Status__c != 'Intake'
            AND Is_Funding_Type_Internal__c = :isInternal
            ORDER BY Name LIMIT 1000
        ]) {
            requests.add(new GFRS_FundingRequestWrapper(req, req.Id == inboundFundingRequest));
        }
    }
    
     public void uploadDoc() {
        
        try {
            if(this.changeOwner_doc.ParentId == null){
                this.changeOwner_doc.ParentId = org.Id;
                gFRS_Util_NoShare.saveLockedAttachment(this.changeOwner_doc);
            } else {
                gFRS_Util_NoShare.saveLockedAttachment(this.changeOwner_doc);
            }
        } catch (DmlException e) {
            ApexPages.addMessages(e);
        }
        changeOwner_doc.body = null;
        
        //PageReference pref = ApexPages.currentPage();
        //pref.setRedirect(false);
        //return pref;
     }
    
    public ApexPages.Pagereference changeOwner() {
        final GFRS_Funding_Request__c[] transferredRequests = new GFRS_Funding_Request__c[]{ };
        for (GFRS_FundingRequestWrapper req : requests) {
            if (req.isSelected && req.fundingRequest.OwnerId != selectedOwner.User__c) {
                req.fundingRequest.put('OwnerId', selectedOwner.User__c);
                transferredRequests.add(req.fundingRequest);
            }
            if (req.isSelected && req.fundingRequest.OwnerId == selectedOwner.User__c) {
                oldOwner = true;
            }
        }
        if(transferredRequests.size() == 0 && oldOwner == true){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please select a new owner for the request.' ));
            oldOwner = false;
        }
        else if(transferredRequests.size() == 0){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please select atleast one request.' ));
        }
        else {
            try {
                update transferredRequests;
            } catch (DmlException e) {
                ApexPages.addMessages(e);
            }
            if(!ApexPages.hasMessages()){
                if(this.changeOwner_doc.name != null && this.changeOwner_doc.name != ''){
                    org.Owner_Change_Documentation__c = this.changeOwner_doc.id;
                    update org;
                }
                            
                this.notes.ParentId = org.Id;
                insert notes;
                notes = new Note(); 
                changeOwner_doc = new Attachment();
                oldOwner = false;               
                PageReference pref = ApexPages.currentPage();
                pref.setRedirect(true);
                return pref;                
            }
        }
        
        return null;
    }
    
    public class GFRS_FundingRequestWrapper {
        
        public Boolean isSelected { get; set; }
        
        public GFRS_Funding_Request__c fundingRequest { get; private set; }
        
        public GFRS_FundingRequestWrapper(final GFRS_Funding_Request__c fundingRequest, final Boolean isChecked) {
            this.fundingRequest = fundingRequest;
            this.isSelected = isChecked;
        }
    }
}