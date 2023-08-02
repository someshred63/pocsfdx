public class gFRS_Utilcopay {

    public static Boolean printPreview = false;
    public static final String SHARING_READ = 'Read';
    public static final String SHARING_EDIT = 'Edit';    
    public static final String TYPE_CORPORATE_MEMBERSHIPS_NAME = 'Corporate Memberships';
    public static final String TYPE_EXHIBHITS_OTHER_PROMOS_NAME = 'Exhibits & Other Promos';
    public static final String TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME = 'Sci/Pipeline Exhibits & Other Non-Promo';
    public static final String TYPE_FIELD_INITIATED_EXHIBITS_NAME = 'Field Initiated Exhibits';

    public static final String TYPE_FELLOWSHIPS_NAME = 'Fellowships';
    public static final String TYPE_PHILANTHROPIC_NAME = 'Philanthropic';
    public static final String TYPE_HC_CHAR_NAME = 'HC Char';
    //public static final String TYPE_CO_PAY_NAME = 'Copay Projects';//Added//


    public static final String FUNDING_COPAY_REQUEST_API_NAME = 'gFRS_CoPay_Funding_Request__c';
    public static final String TYPE_Copay_PROJECTS = 'Copay';
    public static final String TYPE_CO_PAY_NAME = 'Copay';
    public static final String TYPE_CO_PAY_DESCRIPTION = 'Copay Project Support';
    public static final String TYPE_CO_PAY_SAP = 'Scientific Project Support';
    public static final String REQUEST_SUB_STATUS_QCO = 'QCO Review';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_CST_REVIEW = 'CST Review';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_CST_APPROVAL = 'CST Approval';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_FINANCE_APPROVAL = 'Finance Approval';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_VP_CAO_APPROVAL = 'VP/CAO Approval';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_CFO_APPROVAL = 'CFO Approval';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_DENIED = 'Denied';
    public static final String REQUEST_SUB_STATUS_PAYMENT = 'Process Payment';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_INTENT_TO_DONATE = 'Intent to Donate';    

    public static final String APPROVAL_APPROVED = 'Approved';
    public static final String APPROVAL_REJECTED = 'Rejected';
    public static final String APPROVAL_RECALLED = 'Recalled';
    public static final String APPROVAL_CANCELED = 'Canceled';
    public static final String APPROVAL_SUBMITTED = 'Submitted';

    public static final String COPAY_FUNDING_REQUEST_API_NAME = 'gFRS_Copay_Funding_Request__c';

    /// gFRS_copay_FundingRequestTrigger referenced methods
    public static void removeIfUserHaveSharingcopay(Id fundingId, ID userID) {

        List<gFRS_copay_Funding_Request__Share> sharigList = new List<gFRS_copay_Funding_Request__Share>();
        List<gFRS_copay_Funding_Request__Share> selectedShares = new List<gFRS_copay_Funding_Request__Share>();
        
        gFRS_copay_Funding_Request__c copayRequest = [select id, (select AccessLevel, Id, ParentId, RowCause, UserOrGroupId from Shares) from gFRS_copay_Funding_Request__c where id =: fundingId];
        sharigList = copayRequest.Shares;
        
        for (gFRS_copay_Funding_Request__Share shareItem: sharigList) {
            if (shareItem.UserOrGroupId == userID && shareItem.ParentId == fundingId) {
                selectedShares.add(shareItem);
            }
        }

        delete  selectedShares;


    }

    public static gFRS_copay_Funding_Request__Share createRequestSharecopay(id parentId, id userOrGroupId, String sharingSetting) {
        return (
            new gFRS_copay_Funding_Request__Share(
                ParentId = parentId,
                UserOrGroupId = userOrGroupId,
                AccessLevel = sharingSetting,
                RowCause = Schema.gFRS_copay_Funding_Request__Share.RowCause.Manual
            )
        );
    }




    public static void submitForApprovalcopay(gFRS_copay_Funding_Request__c[] newRequests, Map < id, gFRS_copay_Funding_Request__c > oldRequests) {

        try {
            gFRS_copay_Funding_Request__c[] changedRequests = new gFRS_copay_Funding_Request__c[] {};
            gFRS_copay_Funding_Request__c[] changedRequestsFiltered = new gFRS_copay_Funding_Request__c[] {};

            gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Sub_Status__c', changedRequests);
            gFRS_copay_Funding_Request__c oldRequest = null;
            for (gFRS_copay_Funding_Request__c item: changedRequests) {

                if (oldRequests.containsKey(item.id)) {

                    oldRequest = oldRequests.get(item.Id);
                    if (oldRequest.Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_NEW &&
                        item.Sub_Status__c == gFRS_Utilcopay.REQUEST_SUB_STATUS_QCO) {

                        changedRequestsFiltered.add(item);
                    }


                    if (item.Funding_Approval_Step_Status__c == gFRS_Utilcopay.APPROVAL_SUBMITTED &&
                        item.Inside_CST_CFO_Approval__c == 'NO' &&
                        item.Sub_Status__c == gFRS_Utilcopay.REQUEST_EXTERNAL_SUB_STATUS_CST_REVIEW) {
                        changedRequestsFiltered.add(item);
                    }
                }
            }
            if (changedRequestsFiltered.size() > 0) {
                
                List<gFRS_copay_Funding_Request__c> copayList = new List<gFRS_copay_Funding_Request__c>();

                for (gFRS_copay_Funding_Request__c f: changedRequestsFiltered) {


                    Approval.ProcessSubmitRequest approvalItem = new Approval.ProcessSubmitRequest();
                    approvalItem.setComments('Submitting request for approval.');
                    approvalItem.setObjectId(f.id);

                    // -- In case of rejection approval is submitted as owner rather than the rejected approver.
                    approvalItem.setSubmitterId(f.OwnerId);

                    //-- submit the approval
                    Approval.ProcessResult result = Approval.process(approvalItem);
                    //-- verify
                    if (!result.isSuccess()) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while sending request for submission.'));
                    }

                }
                
                update copayList;

            }
        } catch (Exception ex) {
            //System.assertEquals('Error',ex.GetMessage());
            string exMsg = ex.GetMessage();
            system.debug('submitForApproval error=>' + ex.GetMessage());
        }
    }

    public static void shareRecordWithApprovers(gFRS_copay_Funding_Request__c[] newRequests, Map < id, gFRS_copay_Funding_Request__c > oldRequests) {
        gFRS_copay_Funding_Request__c[] changedRequests = new gFRS_copay_Funding_Request__c[] {};
        gFRS_copay_Funding_Request__c[] changedRequestsFiltered = new gFRS_copay_Funding_Request__c[] {};
        gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Sub_Status__c', changedRequests);

        gFRS_copay_Funding_Request__Share[] shares = new gFRS_copay_Funding_Request__Share[] {};
        gFRS_copay_Funding_Request__c requestWithApprovers = null;
        for (gFRS_copay_Funding_Request__c item: changedRequests) {
            gFRS_copay_Funding_Request__c oldRequest = null;

            if (oldRequests.containsKey(item.id)) {
                oldRequest = oldRequests.get(item.Id);
               
                if (item.Sub_Status__c == gFRS_Utilcopay.REQUEST_EXTERNAL_SUB_STATUS_CST_APPROVAL &&
                    oldRequest.Sub_Status__c == gFRS_Utilcopay.REQUEST_EXTERNAL_SUB_STATUS_CST_REVIEW) {

                    changedRequestsFiltered.add(item);
                }
                gFRS_copay_Funding_Request__c[] requestsWithApprovers = [select id, status__c, OwnerId,
                    (select AccessLevel, Id, ParentId, RowCause, UserOrGroupId from Shares), Record_Type_Name__c,
                    CST_Reviewer__c, CST_Reviewer__r.isActive,
                    CST_Approver__c, CST_Approver__r.isActive,
                    Finance_Approver__c, Finance_Approver__r.isActive,
                    VP_Approver__c, VP_Approver__r.isActive,
                    CFO_Approver__c, CFO_Approver__r.isActive
                    from gFRS_copay_Funding_Request__c where id in: changedRequestsFiltered
                ];

                Map < id, gFRS_copay_Funding_Request__c > requestApprovalMap = new Map < id, gFRS_copay_Funding_Request__c > (requestsWithApprovers);


                for (gFRS_copay_Funding_Request__c f: changedRequestsFiltered) {
                    if (requestApprovalMap.containsKey(f.id)) {
                        requestWithApprovers = requestApprovalMap.get(f.id);
                        
                        //-- add read only share to CST Reviewer
                        if (requestWithApprovers.CST_Reviewer__c != null && requestWithApprovers.CST_Reviewer__r.isActive) {
                            removeIfUserHaveSharingcopay(requestWithApprovers.id, requestWithApprovers.CST_Reviewer__c);
                            shares.add(createRequestSharecopay(requestWithApprovers.id, requestWithApprovers.CST_Reviewer__c, SHARING_READ));
                        }
                        //-- add read write share to CST Approver
                        if (requestWithApprovers.CST_Approver__c != null && requestWithApprovers.CST_Approver__r.isActive) {
                            removeIfUserHaveSharingcopay(requestWithApprovers.id, requestWithApprovers.CST_Approver__c);
                            shares.add(createRequestSharecopay(requestWithApprovers.id, requestWithApprovers.CST_Approver__c, SHARING_EDIT));
                        }

                        //-- add read write share to Finance Approver
                        if (requestWithApprovers.Finance_Approver__c != null && requestWithApprovers.Finance_Approver__r.isActive) {
                            removeIfUserHaveSharingcopay(requestWithApprovers.id, requestWithApprovers.Finance_Approver__c);
                            shares.add(createRequestSharecopay(requestWithApprovers.id, requestWithApprovers.Finance_Approver__c, SHARING_EDIT));
                        }

                        //-- add read write share to VP/CAO Approver
                        if (requestWithApprovers.VP_Approver__c != null && requestWithApprovers.VP_Approver__r.isActive) {
                            removeIfUserHaveSharingcopay(requestWithApprovers.id, requestWithApprovers.VP_Approver__c);
                            shares.add(createRequestSharecopay(requestWithApprovers.id, requestWithApprovers.VP_Approver__c, SHARING_EDIT));
                        }

                        //-- add read write share to CFO Approver
                        if (requestWithApprovers.CFO_Approver__c != null && requestWithApprovers.CFO_Approver__r.isActive) {
                            removeIfUserHaveSharingcopay(requestWithApprovers.id, requestWithApprovers.CFO_Approver__c);
                            shares.add(createRequestSharecopay(requestWithApprovers.id, requestWithApprovers.CFO_Approver__c, SHARING_EDIT));
                        }
                    }
                }
            }
        }
        gFRS_Util_NoSharecopay.upsertRequestSharescopay(shares);
    }

    /**
     * @author GFRS CoPay Dev Team 
     * @date 12/12/2017
     * @description initializeLink method - Intializes the url to include the funding request id, to ensure it is passed along.
     **/
    public static String initializeLinkcopay(String targetPage, gFRS_Copay_Funding_Request__c request, String parameters) {
        String result = targetPage + '?t=t';
        if (request != null && request.id != null) result += '&id=' + request.id;
        if (parameters != null) result += '&' + parameters;
        return (result);
    }

    /**
     * @author GFRS CoPay Dev Team 
     * @date 12/11/2017
     * @description cloneOrgW9toCopay method - Clones and uploads W-9 attachment of gfrs Organization to Copay request 
     */
    public static String cloneOrgW9toCopay(gFRS_Copay_Funding_Request__c coPayRequest) {

        String coPayW9AttachmentId = null;
        if (!String.isBlank(coPayRequest.Organization_W_9__c) && String.isBlank(coPayRequest.W_9__c)) {
            Attachment org_W_9 = [Select id, Name, body, ContentType from Attachment where id =: coPayRequest.Organization_W_9__c];
            coPayW9AttachmentId = insertedCloneAttachmentId(org_W_9, coPayRequest.Id);
        }
        else if (!String.isBlank(coPayRequest.Organization_W_9__c)) {
            Attachment req_W_9 = [Select id, Name, body, ContentType from Attachment where id =: coPayRequest.W_9__c];
            Attachment org_W_9 = [Select id, Name, body, ContentType from Attachment where id =: coPayRequest.Organization_W_9__c];
            if(req_W_9.name != org_W_9.name || req_W_9.ContentType != org_W_9.ContentType){
                coPayW9AttachmentId = insertedCloneAttachmentId(org_W_9, coPayRequest.Id);
            }
        }
        return coPayW9AttachmentId;
    }

    /**
     * @author GFRS CoPay Dev Team 
     * @date 12/11/2017
     * @description insertedCloneAttachmentId method - Create a clone to the given attachment(sourceAttachment) and uploads to mentioned record(ParentsId).
     */
    public static String insertedCloneAttachmentId(Attachment sourceAttachment, Id ParentsId) {

        Attachment clone = new Attachment();
        clone.Name = sourceAttachment.Name;
        clone.Body = sourceAttachment.body;
        clone.ContentType = sourceAttachment.ContentType;
        clone.ParentId = ParentsId;
        insert clone;

        return clone.Id;
    }

    /**
     * @author GFRS CoPay Dev Team 
     * @date 12/12/2017
     * @description isInternalRequest method - Method indicates if request is an internal request, based on request's record type name.
     */
    public static Boolean isInternalRequest(String recordTypeName) {
        return recordTypeName.equals(gFRS_Utilcopay.TYPE_CORPORATE_MEMBERSHIPS_NAME) || recordTypeName.equals(gFRS_Utilcopay.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) || recordTypeName.equals(gFRS_Utilcopay.TYPE_FIELD_INITIATED_EXHIBITS_NAME) || recordTypeName.equals(gFRS_Utilcopay.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) ? true : false;
    }



    public static boolean isUserInternal(id userId) {
        id userContactId = null;
        User u = [select id, ContactId from User where id =: userId];
        return (u != null);
    }


    public static Contact getUserContact(id userId) {
        try {
            User u = [select Contact.id, Contact.accountId, Contact.Account.Id, Contact.Account.Name, Contact.Organization__c, Contact.Organization__r.id, Contact.Organization__r.Organization_Name__c from User where Id =: userId];
            if (u.Contact == null || u.Contact.Account == null) {
                return (null);
            } else {
                return (u.Contact);
            }
        } catch (Exception err) {
            System.debug('unable to find user:' + userId);
            return (null);
        }
    }

    public static Boolean isCMEOShowncopay(gFRS_copay_Funding_Request__c requestcopay) {
        return true;
    }


    public static final String INFO_NEEDED_ORGANIZATION = 'Organization';
    public static final String INFO_NEEDED_LOCATION = 'Location';
    public static final String INFO_NEEDED_APPLICATION = 'Donation';
    public static final String INFO_NEEDED_PROGRAM_DESIGN = 'Program Design';
    public static final String INFO_NEEDED_THIRD_PARTY = 'Third Party';
    public static final String INFO_NEEDED_PROGRAM = 'Program';
    public static final String INFO_NEEDED_BUDGET = 'Budget';
    public static final String INFO_NEEDED_FILE_ATTACHMENTS = 'Attachments';
    public static final String INFO_NEEDED_DISEASE_STATE = 'Disease State';


    public static String getRequestStartingPage1(gFRS_Copay_Funding_Request__c request) {
            String resultURL = Page.GFRS_Org_Info.getURL();
            if (request == null || request.id == null) return (resultURL);
            String idParam = '?id=' + request.id;

            resultURL += idParam;

            if (request.Information_Needed__c == null) {
                //-- leave alone
            } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_ORGANIZATION)) {
                resultURL = Page.GFRS_Org_Info.getURL() + idParam;
            } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_LOCATION)) {
                resultURL = Page.GFRS_Org_Info.getURL() + idParam + '&ci=2';
            } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_APPLICATION)) {
                resultURL = Page.GFRS_Application.getURL() + idParam;
            } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_THIRD_PARTY)) {
                resultURL = Page.GFRS_Application.getURL() + idParam + '&ci=1';
            } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_PROGRAM_DESIGN)) {
                resultURL = Page.gFRS_ProgramDesign.getURL() + idParam;
            } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_PROGRAM)) {
                resultURL = Page.GFRS_Program.getURL() + idParam;
            } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_BUDGET)) {
                resultURL = Page.GFRS_Budget.getURL() + idParam;
            } else {
                //-- leave alone
            }
            return (resultURL);
        } //Added newly for Copay///

    public static String getRFI_StartingPage1(id requestId) {
        try {
            gFRS_Copay_Funding_Request__c request = [select id, Information_Needed__c from gFRS_Copay_Funding_Request__c where id =: requestId limit 1];
            return (gFRS_Utilcopay.getRequestStartingPage1(request));
        } catch (Exception err) {
            return (gFRS_Utilcopay.getRequestStartingPage1(null));
        }
    }

    public static Boolean isRequestFoundationType1(Id fundingRequestId) {
        return true;

    }

    /**
     * @author GFRS Dev Team 
     * @date 27/11/2013
     * @description determineCompanyCode method - Determines the company code for a specific funding request.
     * <p>Currently there must be a single company code, but the only knowledge of the company code
     * is through the allocation line items (which know the cost center which know the company code ).
     * This is intended to be a central place to put logic on which company code from possible multiple ones to use.
     * (Currently using FirstCome heuristic)</p>
     */
    public static String determineCompanyCode(GFRS_Copay_Funding_Allocation_Line_Item__c[] splits) {
        String result = null;
        try {
            if (splits != null && splits.size() > 0) {
                result = splits[0].Cost_Center_Lookup__r.SAP_Company_Code__c;
            }
        } catch (Exception err) {
            System.debug('Splits must have the cost center and company code to determine the company code.');
        }
        return (result);
    }

    public static final String RT_LOC_INTERNAL = 'Internal';
    public static final String RT_LOC_EXTERNAL = 'External';

    public static void locationDataFirewall(GFRS_Location_Copay__c[] locations, Map < Id, GFRS_Location_Copay__c > oldMap) {
        Contact userContact = gFRS_Util_NoShare.getUserContact(UserInfo.getUserId());
        Boolean isInternal = userContact == null;

        //-- create a map of the recordTypes to ids
        Map < String, Id > rtMap = new Map < String, Id > ();
        for (RecordType r: [SELECT id, DeveloperName from RecordType where SobjectType = 'GFRS_Location_Copay__c']) {
            rtMap.put(r.DeveloperName, r.Id);
        }

        if (rtMap.containsKey(gFRS_Utilcopay.RT_LOC_INTERNAL) &&
            rtMap.containsKey(gFRS_Utilcopay.RT_LOC_EXTERNAL)
        ) {
            if (isInternal) { //-- only set if it is new
                for (GFRS_Location_Copay__c loc: locations) {

                    if (oldMap == null || !oldMap.containsKey(loc.id)) {
                        loc.RecordTypeId = rtMap.get(gFRS_Utilcopay.RT_LOC_INTERNAL);
                        //system.debug('record type changed');
                    }
                }
            } else { //-- set if the org was saved on org page (Organization_LastModifiedBy) or if its new
                for (GFRS_Location_Copay__c loc: locations) {
                    //-- unlike the location, there isn't another page that we want to protect the user from making modifications from
                    loc.RecordTypeId = rtMap.get(gFRS_Utilcopay.RT_LOC_EXTERNAL);
                    system.debug('record type changed[' + loc.id + ']:External');
                }
            }
        }
    }


    /** 
     * @Author GFRS CoPay Team
     * @date 24/01/2018
     * @description autoPopulateHCOwnerIfNeeded method - method sets current user as a HC Compliance Owner, but only when Funding Request status changed to 'CQO Review' and HC Compliance Owner was not set before.
     */
    public static void autoPopulateApproverIfNeeded(gFRS_Copay_Funding_Request__c[] newRequests, Map < id, gFRS_Copay_Funding_Request__c > oldRequests) {
        for (gFRS_Copay_Funding_Request__c newRequest: newRequests) {
            gFRS_Copay_Funding_Request__c oldRequest = oldRequests.get(newRequest.id);

            if (newRequest.HC_Compliance_Owner__c == null &&
                newRequest.sub_status__c != oldRequest.sub_status__c &&
                oldRequest.sub_status__c == REQUEST_SUB_STATUS_QCO) {
                autoPopulateHCOwner(newRequest);
            } else if (newRequest.CST_Reviewer__c == null &&
                ((newRequest.sub_status__c != oldRequest.sub_status__c)||
                (newRequest.Funding_Approval_Step_Status__c == 'Rejected' &&
                oldRequest.CST_Reviewer_Decision__c != newRequest.CST_Reviewer_Decision__c &&
                newRequest.CST_Reviewer_Decision__c == 'Rejected')) &&
                oldRequest.sub_status__c == REQUEST_EXTERNAL_SUB_STATUS_CST_REVIEW) {
                autoPopulateCSTReviewer(newRequest);
            }
            
            
           if(newRequest.CST_Approver_picklist__c == null){
           newRequest.CST_Approver__c = null;
           }
           if(newRequest.VP_Approver_picklist__c == null){
           newRequest.VP_Approver__c = null;
           }
           if(newRequest.Finance_Approver_picklist__c == null){
           newRequest.Finance_Approver__c = null;
           }
           if(newRequest.CFO_Approver_picklist__c == null){
           newRequest.CFO_Approver__c = null;
           }
           
            
            
           if(newRequest.CST_Approver_picklist__c != oldRequest.CST_Approver_picklist__c &&
            newRequest.CST_Approver_picklist__c != null){ 
            
             Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
        Matcher unixIdMatcher = unixIdPattern.matcher( newRequest.CST_Approver_picklist__c );
        String unixId = null;
        
        if( unixIdMatcher.find() ){
            unixId = unixIdMatcher.group(1);
            System.debug( 'financeManager unixId:' + unixId );
        } else {
            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
          newRequest.addError('CST Approver not exists'); 
         }
        
        Id targetId = gFRS_Util_NoShare.getUserByUnixId(unixId);
        if( targetId == null ){
         newRequest.addError('CST Approver not exists');   
        }
        newRequest.CST_Approver__c = targetId;   
         } 
         
            if(newRequest.VP_Approver_picklist__c != oldRequest.VP_Approver_picklist__c && 
            newRequest.VP_Approver_picklist__c != null){ 
            
             Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
        Matcher unixIdMatcher = unixIdPattern.matcher( newRequest.VP_Approver_picklist__c );
        String unixId = null;
        
        if( unixIdMatcher.find() ){
            unixId = unixIdMatcher.group(1);
            System.debug( 'financeManager unixId:' + unixId );
        } else {
            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
          newRequest.addError('VP Approver not exists'); 
         }
        
        Id targetId = gFRS_Util_NoShare.getUserByUnixId(unixId);
        if( targetId == null ){
         newRequest.addError('VP Approver not exists');   
        }
        newRequest.VP_Approver__c = targetId;   
         }
         
            if(newRequest.Finance_Approver_picklist__c != oldRequest.Finance_Approver_picklist__c && 
            newRequest.Finance_Approver_picklist__c != null){ 
            
             Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
        Matcher unixIdMatcher = unixIdPattern.matcher( newRequest.Finance_Approver_picklist__c );
        String unixId = null;
        
        if( unixIdMatcher.find() ){
            unixId = unixIdMatcher.group(1);
            System.debug( 'financeManager unixId:' + unixId );
        } else {
            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
          newRequest.addError('Finance Approver not exists'); 
         }
        
        Id targetId = gFRS_Util_NoShare.getUserByUnixId(unixId);
        if( targetId == null ){
         newRequest.addError('Finance Approver not exists');   
        }
        newRequest.Finance_Approver__c = targetId;   
         }
         
            if(newRequest.CFO_Approver_picklist__c != oldRequest.CFO_Approver_picklist__c 
            && newRequest.CFO_Approver_picklist__c != null){ 
            
             Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
        Matcher unixIdMatcher = unixIdPattern.matcher( newRequest.CFO_Approver_picklist__c );
        String unixId = null;
        
        if( unixIdMatcher.find() ){
            unixId = unixIdMatcher.group(1);
            System.debug( 'financeManager unixId:' + unixId );
        } else {
            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
          newRequest.addError('CFO Approver not exists'); 
         }
        
        Id targetId = gFRS_Util_NoShare.getUserByUnixId(unixId);
        if( targetId == null ){
         newRequest.addError('CFO Approver not exists');   
        }
        newRequest.CFO_Approver__c = targetId;   
         }  
            
        }
    }

    /** 
     * @Author GFRS CoPay Team
     * @date 24/01/2018
     * @description autoPopulateHCOwner method - method sets current user as a HC Compliance Owner.
     */
    public static void autoPopulateHCOwner(gFRS_Copay_Funding_Request__c request) {
        try {
            request.HC_Compliance_Owner__c = UserInfo.getUserId();
        } catch (Exception err) {
            System.debug('Could not auto populate HC Compliance Owner: ' + request.Name);
        }
    }

    /** 
     * @Author GFRS CoPay Team
     * @date 24/01/2018
     * @description autoPopulateHCOwner method - method sets current user as a HC Compliance Owner.
     */
    public static void autoPopulateCSTReviewer(gFRS_Copay_Funding_Request__c request) {
        try {
            request.CST_Reviewer__c = UserInfo.getUserId();
        } catch (Exception err) {
            System.debug('Could not auto populate HC Compliance Owner: ' + request.Name);
        }
    }

    /** 
     * @Author ADMD Team
     * @date 29/01/2018
     * @description RfiResetInformationNeeded method - method resets Information_Needed__c field of Funding Request. That means the external portal forms will not bo editable.
     */
    public static void RfiResetInformationNeeded(gFRS_Copay_Funding_Request__c[] newFundingList) {
        for (gFRS_Copay_Funding_Request__c currentFunding: newFundingList) {
            system.debug('External_Sub_status__c :' + currentFunding.External_Sub_status__c + ' Check status :' + currentFunding.Status__c);
            if (currentFunding.External_Sub_status__c != null && currentFunding.External_Sub_status__c != 'RFI' && currentFunding.Status__c != 'Intake') {
                currentFunding.Information_Needed__c = null;

            }
           
        }
    }

    /** 
     * @Author gFRS CoPay Team
     * @date 2/14/2018
     * @description generateInviteCode method - method generates a unique 8 char long invite code to be shared with the copay user.
     */
    public static String generateInviteCode(GFRS_CopayUser__c newUser, Boolean isupdate) {
        String inviteCode;
        List < GFRS_CopayUser__c > copayUsersList = [select Invite_Code__c,User__c, User__r.Name  from GFRS_CopayUser__c];
        Set < String > inviteCodeSet = new Set < String > ();
        Set < Id > copayUsers = new Set < Id> ();

        for (GFRS_CopayUser__c copayUser: copayUsersList) {
            inviteCodeSet.add(copayUser.Invite_Code__c);
            copayUsers.add(copayUser.User__c);
        }

        do {
            inviteCode = generateRandomString();
        } while (inviteCodeSet.contains(inviteCode));
        
        if(copayUsers.contains(newUser.User__c) && !isupdate){
            inviteCode = null;
            User duplicateUser = [select Name from User where id = : newUser.User__c];
            newUser.addError('The user you entered ' + duplicateUser.Name + ' already exists.');
       }
        
        return inviteCode;

    }

    /** 
     * @Author gFRS CoPay Team
     * @date 2/14/2018
     * @description generateInviteCode method - method generates a random 8 char long alpha numeric string.
     */
    public static String generateRandomString() {

        String hexDigest = '';

        do {
            String hashString = String.valueOf(Crypto.getRandomInteger());
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            hexDigest = EncodingUtil.convertToHex(hash);
        } while (hexDigest.length() < 8);

        return hexDigest.SubString(0, 8);
    }

}