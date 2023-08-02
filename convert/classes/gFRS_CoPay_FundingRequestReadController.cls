public class gFRS_CoPay_FundingRequestReadController {

    public GFRS_CoPay_Funding_Request__c fundingRequest {
        get;
        set;
    }
    public List < SelectOption > rightOptionForCloseForm {
        get;
        set;
    }
    private Map < String, String > mappingForCorrespondingEmailTemplateAndDecisonReason = null;
    private List < EmailTemplate > emailTemplatedForClosingForm = null;
    public String closeFundingEmailBody {
        get;
        set;
    }
    public String closeFundingEmailSubject {
        get;
        set;
    }
    public List < SelectOption > getAvailableET() {
        return this.lETs;
    }
    public String baseUrl {
        get;
        set;
    }
    public String requestID {
        get;
        set;
    }


    public gFRS_CoPay_FundingRequestReadController(apexPages.StandardController std) {
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        fundingRequest = (gFRS_Copay_Funding_Request__c) std.getRecord();
        requestID = this.fundingRequest.id;

        GFRS_Copay_Funding_Request__c request = (GFRS_Copay_Funding_Request__c) std.getRecord();
        this.fundingRequest = [SELECT Record_Type_Name__c, Payment_Type_Temp__c, Estimated_Current_Revenue_Exceeded_33__c,
            Owner.Id, Finance_Approver__r.Email, YTD_Total_Approved_Donations__c, Estimated_Donation_Limit__c,
            owner.Name, owner.Email, LastModifiedBy.Name, Donation_Requested_for_YY_quarter1__c, Payment_Type__c,
            ParentRecord__c, Accountable_Employee_Approval__c, Total_Approved_Amt__c, Inside_CST_CFO_Approval__c,
            Actual_Annual_Revenue_for_Prior_Fiscal_Y__c, Actual_YeartoDate_Annual_Revenue_for_Fis__c, Estimated_Remaining_Donation_Limit__c,
            Are_designed_in_accordance_with_widely_r__c, Are_not_defined_by_reference_to_specific__c, Org_Quarter__c,
            Are_you_requesting_a_co_pay_donation__c, Attention_To__c, Authorized_Signer__c, Basic_Research_Fellow__c,
            Benefits_Exchanged_for_Funding__c, Building__c, Business_Approver_1__c, Business_Approver_2__c, Business_Approver_3__c,
            Business_Approver_Decision_Date__c, Business_Approver__c, Business_Reviewer_1__c, Business_Reviewer_Decision_Date__c,
            Business_Reviewer_Decision__c, CFO_Approver_Decision_Date__c, CFO_Approver_Decision__c, CFO_Approver__c, clonedRequestOwner__c,
            Compliance_flags_PDF__c, ConnectionReceivedId, ConnectionSentId, Cover_a_wide_spectrum_of_FDA_approved_pr__c,
            Co_payApproval_Step__c, Co_paySYSRequest_Approved__c, CreatedById, CreatedDate, CST_Approver_Decision_Date__c,
            CST_Approver_Decision__c, CST_Approver__c, CST_Reviewer_Decision_Date__c, CST_Reviewer_Decision__c, Date_Submitted__c,
            Decision_Compliance_Flags_PDF__c, Decision_Date__c, Decision_Flags_PDF_Snapshot__c, Decision_Reasons__c,
            Delivery_Method__c, Does_your_organization_have_an_unfavorab__c, Donation_Requested_for_YY_quarter__c, Donation_URL__c,
            Donation__c, Do_you_have_a_donation_agreement__c, Evaluation_Completed__c, Evaluation_submitted_date__c, Event_Program_Title__c,
            Event_Program_Type__c, External_Sub_status__c, Fellowship_Project_Description__c, Finance_Approver_Decision_Date__c,
            Finance_Approver_Decision__c, Finance_Approver__c, Financial_Approver_1_Decision_Date__c, Summary_PDF_snapshot__c,
            Financial_Approver_2_Decision_Date__c, Financial_Approver_2__c, Financial_Approver_3_Decision_Date__c,
            Financial_Approver_3__c, Fiscal_Year_Ending__c, Foundation_Classified__c, Foundation_Eligible__c,
            Funding_Approval_Step_Status__c, Funding_Sub_Type__c, Funding_Type__c, HC_Compliance_Date__c,
            HC_Compliance_Decision_Date__c, HC_Compliance_Decision__c, HC_Compliance_Flags_PDF_Snapshot__c,
            HC_Compliance_Flags_PDF__c, Hunger__c, Id, Information_Needed__c, IsDeleted, IsLocked, isValidationExternalOnly__c,
            Is_Outcomes_In_RFI__c, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Legal_Reviewer_1__c,
            Letter_of_Request__c, LOAPDF__c, LOA_PDF__c, LOA_Signed__c, Locationcopay__c, Manual_Resolution__c, MayEdit, Meeting_Agenda__c,
            Name, OIG_Opinion_URL__c, OIG_Opinion__c, Organization_DiseaseFundDefinition__c, Organization_Name__c,
            Organization_Outdated_OIG_Opinion_Notes__c, Organization_Outdated_OIG_Opinion__c, Organization_Reputation_Blacklist__c,
            Organization_Type_Owned_by_HCPs__c, Organization_Type_Political_Sectarian__c, Organization_Type_Religious_Notes__c,
            Organization_Type_Religious__c, Organization__c, Org_Disease_Fund_Definition_Notes__c, Org_Reputation_Blacklist_Notes__c,
            Org_Type_Owned_by_HCPs_Notes__c, Org_Type_Political_Sectarian_Notes__c, OwnerId, Patients_treated_annually__c,
            Payment_Call_Counter__c, Payment_Email_Notification__c, Payment_Method__c, Pending_Action_from_gCOI__c,
            Please_enter_the_co_pay_donation_request__c, Projected_Annual_Revenue_for_Fiscal_Year__c, Promotional_Event_Advertising__c,
            QCO_Decision__c, QCO_Review_Decision_Date__c, Recall_Date__c, Reconciliation_Required_Status_Date__c, RecordTypeId,
            Refundable_Deposit_Amount_if_any__c, Requested_Amount1__c, Total_Paid_Amount__c, Total_Payment_Amount__c, Requested_Amount__c, Request_AutoNumber__c, Request_Cloned__c,
            Signing_Authority_Email__c, Signing_Authority_First_Name__c, Signing_Authority_Last_Name__c, Status__c, Sub_Status__c,
            SystemModstamp, Total_Activity_Cost_per_Attendee__c, Total_Program_Budget__c, Unix_ID__c, VP_Approver_Decision_Date__c,
            VP_Approver_Decision__c, VP_Approver__c, Will_the_funding_from_this_request_be_us__c, Will_You_be_Working_With_a_3rd_Party__c,
            W_9_URL__c, W_9__c, Year_1_Annual_Report_URL__c, Year_1_Annual_Report__c, Year_1_Audit_URL__c, Year_1_Audit__c,
            Year_1_Form990_URL__c, Year_1_Form990__c, Year_2_Annual_Report_URL__c, Year_2_Annual_Report__c, Year_2_Audit_URL__c,
            Year_2_Audit__c, Year_2_Form990_URL__c, Year_2_Form990__c, Year_3_Annual_Report_URL__c, Year_3_Annual_Report__c,
            Year_3_Audit_URL__c, Year_3_Audit__c, Year_3_Form990_URL__c, Year_3_Form990__c, Post_Submission_Report__c, Date_for_33_logic__c

            FROM GFRS_Copay_Funding_Request__c
            WHERE Id =: request.Id LIMIT 1
        ];


        //get email used in email service to attached sent emails
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        if (myOrgCS.gFRS_Inbound_Email__c != null) {

            bccmail2 = myOrgCS.gFRS_Inbound_Email__c;
        }
            bccEmailAddress  = System.Label.gFRS_Copay_CC_Mail_Id;  
    }

    /**
     *@Author gFRS CoPay Team
     *@Date 12/12/2017
     *@Description method called on page load, captures HC Compliance and Decision Compliance PDF snapshots during the time of their approval
     **/
    public void managePDFs() {


        if ((String.isBlank(fundingRequest.HC_Compliance_Flags_PDF__c) &&
            fundingRequest.QCO_Decision__c == 'Approved' &&
            fundingRequest.HC_Compliance_Decision_Date__c != null)
            || (String.isBlank(fundingRequest.HC_Compliance_Flags_PDF__c) &&
                fundingRequest.Funding_Approval_Step_Status__c == 'Rejected')) {

            PageReference pageRefPdf = null;
            pageRefPdf = new ApexPages.Pagereference(Page.gFRS_CoPay_ComplianceFlagPDF.getURL());
            pageRefPdf.getParameters().put('id', fundingRequest.id);
            pageRefPdf.setRedirect(true);
            String documentName = 'HC_Compliance_Flags_' + fundingRequest.Name + '.pdf';

            gFRS_Util_NoSharecopay.insertCopayHCComplianceAttachment(documentName, pageRefPdf.getContent(), fundingRequest);
        } else if (!String.isBlank(fundingRequest.HC_Compliance_Flags_PDF__c) &&
            fundingRequest.HC_Compliance_Decision_Date__c == null) {

            List < Attachment > oldAttachments = [SELECT Id, Parent.Id
                FROM Attachment
                WHERE Id =: this.fundingRequest.HC_Compliance_Flags_PDF__c
            ];
            if (oldAttachments.size() > 0) {
                delete oldAttachments;
                fundingRequest.HC_Compliance_Flags_PDF__c = null;
            }
        }

        if ((String.isBlank(fundingRequest.Decision_Compliance_Flags_PDF__c) &&
            fundingRequest.Sub_Status__c == 'Approved' &&
            fundingRequest.Funding_Approval_Step_Status__c == 'Approved')
            || (String.isBlank(fundingRequest.Decision_Compliance_Flags_PDF__c) && 
                fundingRequest.Funding_Approval_Step_Status__c == 'Rejected')) {

            PageReference pageRefPdf = null;
            pageRefPdf = new ApexPages.Pagereference(Page.gFRS_CoPay_ComplianceFlagPDF.getURL());
            pageRefPdf.getParameters().put('id', fundingRequest.id);
            pageRefPdf.setRedirect(true);


            List < Attachment > requestAttachments = [Select Name From Attachment Where ParentId =: this.fundingRequest.Id and Name like '%Decision_Compliance_Flags%'];
            Integer max = 0;
            if (requestAttachments.size() > 0) {
                for (Attachment att: requestAttachments) {
                    String attachmentNumber = att.Name.substring(att.Name.indexOf('_V') + 2, att.Name.length() - 4);
                    if (max < Integer.valueOf(attachmentNumber)) {
                        max = Integer.valueOf(attachmentNumber);
                    }
                }
            }
            max = max + 1;
            String documentName = 'Decision_Compliance_Flags_' + this.fundingRequest.Name + '_V' + max + '.pdf';

            //String documentName      = 'Decision_Compliance_Flags_' + fundingRequest.Name + '.pdf';

            gFRS_Util_NoSharecopay.insertCopayDecisionComplianceAttachment(documentName, pageRefPdf.getContent(), fundingRequest);

        } else if (!String.isBlank(fundingRequest.Decision_Compliance_Flags_PDF__c) &&
            fundingRequest.Decision_Date__c == null) {

            List < Attachment > oldAttachments = [SELECT Id, Parent.Id
                FROM Attachment
                WHERE Id =: this.fundingRequest.Decision_Compliance_Flags_PDF__c
            ];
            if (oldAttachments.size() > 0) {
                delete oldAttachments;
                fundingRequest.Decision_Compliance_Flags_PDF__c = null;
            }

        }

        if ((String.isBlank(fundingRequest.Summary_PDF_snapshot__c) &&
            fundingRequest.Sub_Status__c == gFRS_Utilcopay.REQUEST_EXTERNAL_SUB_STATUS_CST_APPROVAL &&
            fundingRequest.Inside_CST_CFO_Approval__c == 'YES')
            ||(String.isBlank(fundingRequest.Summary_PDF_snapshot__c) &&
                fundingRequest.Funding_Approval_Step_Status__c == 'Rejected' &&
                fundingRequest.CST_Reviewer_Decision__c == 'Rejected')) {
            PageReference pageRefPdf = null;
            pageRefPdf = new ApexPages.Pagereference(Page.gFRS_Copay_AmountApprovalSnapShotPage.getURL());
            pageRefPdf.getParameters().put('id', fundingRequest.id);
            pageRefPdf.setRedirect(true);

            List < Attachment > requestAttachments = [Select Name From Attachment Where ParentId =: this.fundingRequest.Id and Name like '%Summary_PDF_snapshot%'];
            Integer max = 0;
            if (requestAttachments.size() > 0) {
                for (Attachment att: requestAttachments) {
                    String attachmentNumber = att.Name.substring(att.Name.indexOf('_V') + 2, att.Name.length() - 4);
                    if (max < Integer.valueOf(attachmentNumber)) {
                        max = Integer.valueOf(attachmentNumber);
                    }
                }
            }
            max = max + 1;
            String documentName = 'Summary_PDF_snapshot_' + this.fundingRequest.Name + '_V' + max + '.pdf';

            gFRS_Util_NoSharecopay.insertSummaryPDFAttachment(documentName, pageRefPdf.getContent(), fundingRequest);

        } else if (!String.isBlank(fundingRequest.Summary_PDF_snapshot__c) &&
            fundingRequest.Sub_Status__c == gFRS_Utilcopay.REQUEST_EXTERNAL_SUB_STATUS_CST_REVIEW &&
            fundingRequest.Inside_CST_CFO_Approval__c == 'YES' &&
            (fundingRequest.CST_Approver_Decision__c == 'Rejected' ||
                fundingRequest.Finance_Approver_Decision__c == 'Rejected' ||
                fundingRequest.VP_Approver_Decision__c == 'Rejected' ||
                fundingRequest.CFO_Approver_Decision__c == 'Rejected')) {

            List < Attachment > oldAttachments = [SELECT Id, Parent.Id
                FROM Attachment
                WHERE Id =: this.fundingRequest.Summary_PDF_snapshot__c];
            if (oldAttachments.size() > 0) {
                delete oldAttachments;
                fundingRequest.Summary_PDF_snapshot__c = null;
            }

        }

        if (String.isNotBlank(fundingRequest.Organization__c)) {
            gFRS_CoPay_Operational_Budget.setTotalDonation(fundingRequest);
            gFRS_CoPay_Operational_Budget.calculateExhaustedOperationalBudget(fundingRequest);
            gFRS_Util_NoSharecopay.saveLockedFundingRequestcopay(fundingRequest);
        }

    }

    public ApexPages.PageReference showClosingPopup() {

        id userid = UserInfo.getUserId();
        User userdata = [select id, profileId, profile.name FROM User where id = :userid];
        if(userdata.profile.name == 'GNE-GFRS-Copay-User'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, system.label.gFRS_Copay_insufficient_privileges));
            return null;
        }
        
        if (gFRS_Util.REQUEST_STATUS_CLOSED.equals(this.fundingRequest.Status__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.gFRS_ERROR_ALREADY_CLOSED));
            return (null);
        }

        this.originalStatusValues = this.fundingRequest.clone();
        List < User > tmpUsers = new List < User > ([SELECT Id, FirstName, LastName, Name, Email, ContactId FROM User WHERE Id =: fundingRequest.OwnerId]);

        if (tmpUsers.size() > 0) {
            this.recipient = tmpUsers[0];
            rightOptionForCloseForm = new List < SelectOption > ();
            rightOptionForCloseForm.add(new SelectOption(recipient.Id, 'Owner - ' + recipient.Name));
        }

        this.fundingRequest.Status__c = gFRS_Util.REQUEST_STATUS_CLOSED;
        this.fundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_CANCELLED;
        this.fundingRequest.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_CANCELLED;
        this.isClosingPopUpShown = true;
        populateDecisionReasonForFoundation();
        return (null);

    }

    /** 
     * @Author gFRS CoPay Team
     * @date 12/14/2017
     * @description populateDecisionReasonForFoundation method - method populate values for Decision Reason select list if funding type is Foundation classified.
     */
    public void populateDecisionReasonForFoundation() {

        decisionReasonForFoundation = new List < Selectoption > ();
        if (this.fundingRequest != null && this.fundingRequest.Sub_Status__c == 'Canceled') {
            decisionReasonForFoundation = new List < Selectoption > {
                new Selectoption('', '--None--'),
                new Selectoption('Canceled at the Request of Applicant', 'Canceled at the Request of Applicant'),
                //new Selectoption('Incorrect Funding Type', 'Incorrect Funding Type'),
                new Selectoption('Canceled due to updated request', 'Canceled due to updated request')
            };
        } else if (this.fundingRequest != null && this.fundingRequest.Sub_Status__c == 'Denied') {
            decisionReasonForFoundation = new List < Selectoption > {
                new Selectoption('', '--None--'),
                new Selectoption('QCO Compliance Denial', 'QCO Compliance Denial')
            };
        } else {

            decisionReasonForFoundation = new List < Selectoption > {
                new Selectoption('', '--None--')
            };
        }

        selectedDecisionReason = '';
    }

    public ApexPages.PageReference resetForm() {

        fundingRequest.External_Sub_status__c = fundingRequest.Sub_Status__c;
        fundingRequest.Decision_Reasons__c = null;
        populateDecisionReasonForFoundation();
        return null;
    }

    public ApexPages.PageReference refreshCloseFundingForm() {

        fundingRequest.Decision_Reasons__c = selectedDecisionReason;
        if (mappingForCorrespondingEmailTemplateAndDecisonReason == null) {

            //All Emails template are keeped in following folder:gFRS Close Request Templates
            mappingForCorrespondingEmailTemplateAndDecisonReason = new Map < String, String > {
                'QCO Compliance Denial' => 'Denial Email Copay',
                //'Incorrect Funding Type' => 'Incorrect funding type (CoPay)',
                'Canceled due to updated request' => 'Email template for 2nd request within a quarter',
                'Canceled at the Request of Applicant' => 'Canceled at the Request of Applicant Copay'
            };
        }

        String decisionReasonKey = fundingRequest.Decision_Reasons__c;

        if (decisionReasonKey != null && mappingForCorrespondingEmailTemplateAndDecisonReason.containsKey(decisionReasonKey)) {

            String emailTemplatesName = mappingForCorrespondingEmailTemplateAndDecisonReason.get(decisionReasonKey);
            emailTemplatedForClosingForm = [SELECT TemplateType, Subject, Name, Body, HtmlValue
                FROM EmailTemplate
                WHERE Name =: emailTemplatesName
                AND Folder.DeveloperName =: EMAIL_CLOSE_TEMPLATES_FOLDER
                ORDER BY Name ASC
            ];

            emailBodyDisabled = true;
            if (emailTemplatedForClosingForm.size() > 0) {
                if (emailTemplatesName == 'Email template for 2nd request within a quarter') emailBodyDisabled = false;
                closeFundingEmailBody = replaceEmailBody(emailTemplatedForClosingForm[0].Body, this.recipient);
                closeFundingEmailSubject = replaceEmailSubject(emailTemplatedForClosingForm[0].Subject);
            }
        }

        return null;
    }

    /** 
     * @Author gFRS CoPay Team
     * @date 12/14/2017
     * @description replaceEmailSubject method replace dynamic values defined in subject of emailTemplate
     * 
     */
    public String replaceEmailSubject(String emailSub) {
        if (emailSub != null) {
            return EmailSub.replace('<<G-#####>>', this.fundingRequest.Name);
        }
        return '';

    }

    public List < Selectoption > getEmpytSelectList() {

        return new List < SelectOption > ();
    }

    /** 
     * @Author gFRS CoPay Team
     * @date 12/14/2017
     * @description replaceEmailBody method set dynamic values in defined in body of emailTemplate
     * 
     */
    public String replaceEmailBody(String emailBody, User recipient) {

        String outputBody = '';

        if (emailBody != null) {
            outputBody = emailBody.replace('<<G-#####>>', this.fundingRequest.Name).replace('<<Program/Event Title>>', checkNull(this.fundingRequest.Event_Program_Title__c));
            String senderName = checkNull(Userinfo.getFirstName()) + ' ' + checkNull(Userinfo.getLastName());
            outputBody = outputBody.replace('<<Sender First Name Last Name>>', senderName);

            //recipient will be always owner of requesx
            String recipientName = checkNull(recipient.FirstName) + ' ' + checkNull(recipient.LastName);
            outputBody = outputBody.replace('<<First Name Last Name>>', recipientName);

            String authorizedSingnerName = checkNull(fundingRequest.Signing_Authority_First_Name__c) + ' ' + checkNull(fundingRequest.Signing_Authority_Last_Name__c);
            outputBody = outputBody.replace('<<Authorized Signer>>', authorizedSingnerName);
            outputBody = outputBody.replace('<<Authorized Signer Email>>', checkNull(fundingRequest.Signing_Authority_Email__c));

            String modifUser = checkNull(fundingRequest.LastModifiedBy.Name);
            outputBody = outputBody.replace('<<LastModifyBy>>', modifUser);
            outputBody = outputBody.replace('<<funding type>>', this.fundingRequest.Funding_Type__c);



        }

        return outputBody;
    }

    /** 
     * @Author gFRS CoPay Team
     * @date 28/02/2018
     * @description replaceEmailBody method set dynamic values in defined in body of emailTemplate
     * 
     */
    public static String replaceEmailBodyIntToDonate(String emailBody, gFRS_Copay_Funding_Request__c fundReq, list < gFRS_CoPay_Disease_State__c > DiseaseSt) {

        String outputBody = '';
        String DisStateDetails = '';

        if (emailBody != null) {
            outputBody = emailBody.replace('<<G-#####>>', fundReq.Name);
            outputBody = outputBody.replace('<<Foundation name>>', fundReq.Organization_Name__c);
            for (gFRS_CoPay_Disease_State__c DS: DiseaseSt) {
               // Currency Curr = DS.Payment_Amount__c;            
                Decimal pA = DS.Payment_Amount__c;
                List<String> args = new String[]{'0','number','##,###,##0'};
                String pmtAmt = String.format(pA.format(), args);

                DisStateDetails = DisStateDetails + DS.Disease_State_Fund_Name__c + ': $' + pmtAmt + '\n';
            }
            outputBody = outputBody.replace('<<Disease area: amount for each donation line item>>', DisStateDetails);
        }

        return outputBody;
    }

    /** 
     * @Author gFRS CoPay Team
     * @date 12/14/2017
     * @description dateToString method - Converts a null to a blank string for replacement.
     */
    private String checkNull(String v) {
        return (v == null || v == 'null' ? '' : v);
    }

    /** 
     * @Author gFRS CoPay Team
     * @date 12/14/2017
     * @description hideClosingPopup method - Closes Popup.
     */
    public void hideClosingPopup() {
        this.revertStatusChanges();
        this.isClosingPopUpShown = false;
    }

    /**    
     * @Author gFRS CoPay Team
     * @date 12/14/2017
     * @description revertStatusChanges method - Revert the status changes.
     */
    private void revertStatusChanges() {
        if (this.originalStatusValues != null) {

            this.fundingRequest.Status__c = this.originalStatusValues.Status__c;
            this.fundingRequest.Sub_Status__c = this.originalStatusValues.Sub_Status__c;
            this.fundingRequest.External_Sub_status__c = this.originalStatusValues.External_Sub_status__c;
            this.fundingRequest.Decision_Reasons__c = this.originalStatusValues.Decision_Reasons__c;
        }
        this.originalStatusValues = null;
    }

    /** 
     * @Author gFRS CoPay Team
     * @date 12/14/2017
     * @description closeFundingRequest method - Method used by the custom button to close the funding request
     * (so the status can remain read-only through the page layouts)
     */
    public ApexPages.PageReference closeFundingRequest() {

        this.fundingRequest.Status__c = gFRS_Util.REQUEST_STATUS_CLOSED;


        if (!gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED.equals(this.fundingRequest.Sub_Status__c) &&
            this.fundingRequest.Decision_Reasons__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_DECISION_REASON_REQ));
            return (null);
        }

        if (fundingRequest.Sub_Status__c != 'Approved') {
            if (String.isBlank(closeFundingEmailSubject)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptySubject));
                return null;
            }
            if (String.isBlank(closeFundingEmailBody)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptyContent));
                return null;
            }

        /*    if (this.fundingRequest.Co_paySYSRequest_Approved__c != 'No') {
                gFRS_Util_NoSharecopay.autoRejectRecord(this.fundingRequest);
            } */

            sendCloseFundingEmail();
        } else {
            if (this.fundingRequest.Co_paySYSRequest_Approved__c != 'YES') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record pending Approval cannot be approved'));
                return null;
            } else if (this.fundingRequest.Post_Submission_Report__c != true) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Post Submission Report checkbox should be checked'));
                return null;
            }
        }

        gFRS_Util_NoSharecopay.saveLockedFundingRequestcopay(this.fundingRequest);
        this.isClosingPopUpShown = false;
        return (new ApexPages.PageReference(gFRS_Utilcopay.initializeLinkcopay(PATH_REQUEST, this.fundingRequest, null)).setRedirect(true));

    }


    /** 
     * @Author gFRS CoPay Team
     * @date 12/14/2017
     * @description sendCloseFundingEmail method - Method used to sent email if user  
     * close the funding request using custom button Close Funding Request
     */
    public void sendCloseFundingEmail() {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List < String > {
                recipient.Email
            });
            mail.setSubject(this.closeFundingEmailSubject);

            if (ccEmailAddress != null) {
                mail.setCcAddresses(new List < String > {
                    ccEmailAddress
                });
            }

            if (bccEmailAddress != null) {
                mail.setBccAddresses(new List < String > {
                    bccmail2, System.Label.gFRS_Copay_CC_Mail_Id
                });
            }

            closeFundingEmailBody += '\n\n' + '[ref:' + fundingRequest.id + ']';
            mail.setPlainTextBody(closeFundingEmailBody);
            mail.setOrgWideEmailAddressId([SELECT Id, Address
                FROM OrgWideEmailAddress
                WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com'
                limit 1
            ][0].id);


            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
            });

        } catch (Exception ex) {

        }
    }


    /**
     * #####  ################  ###########  ##############  ###########
     * #####  ################  ###########  ##############  ###########
     * #####  ################  ###########  ##############  ###########
     * #####  ################  ###########  ##############  ###########
     **/

    public static final String EMAIL_TEMPLATES_FOLDER = 'gFRS_RFI_Templates'; // Email templates folder, where available for use templates are stored
    public static final String EMAIL_TEMPLATES_FOLDER1 = 'gFRS_Templates';
    public static final String EMAIL_CLOSE_TEMPLATES_FOLDER = 'gFRS_Close_Request_Templates';
    public static final String CONTENT_TYPE = 'RFI'; // The type of page this is
    public static final String PATH_DECISION_RESULT = Page.gFRS_Application.getURL() + '?id='; //The URL address to send teh client on their task.
    public static final String PATH_REQUEST = Page.gFRS_CoPay_Funding_Request_Read.getURL(); //The URL address of the funding request Read
    public static final String PATH_RFI_TARGET = System.Label.GFRS_Server_URL + '/apex/gFRS_Org_Info?id='; // the URL address to send the client when receiving the RFI **/
    public static final Map < String, String > URLs = new Map < String, String > {
        'Organization' => '/apex/GFRS_Org_Info',
        'Budget' => 'gFRS_Budget',
        'Program' => 'GFRS_Program',
        'Application' => 'GFRS_Home'
    }; // URL used in email templates

    public User recipient;
    public string bccmail2;
    public List < SelectOption > lETs; //  List of Email Templates taken from db
    public List < SelectOption > recipientsList; //  List of available recipients, build in controller constructor
    public List < Selectoption > recipientListSelected {
            get;
            set;
        } //  List of selected recipients
    public Map < Id, EmailTemplate > mEtId2Body = new Map < Id, EmailTemplate > ();
    public Map < Id, User > recipientsToBeDisplayed; // list of possibile recipients and its criteria - to be defined
    private RecordType RT_PAY_HISTORY_READONLY; // READONLY payment history record type

    public String subjectContent {
        get;
        set;
    }
    public List < String > finalSelectedRecipients {
        get;
        set;
    }

    public Boolean isClosingPopUpShown {
        get;
        set;
    } // Whether the funding request 'closing' pop-up is shown
    public Boolean isClongPopUpShown {
        get;
        set;
    }
    public Boolean emailBodyDisabled {
        get;
        set;
    }
    //public Boolean canCreateAnotherPaymentFA   { get { return checkIfUserCanCrateAnotherFundingAllocation();}}//Property can user create another Payment Funding Allocation 
    public Boolean isRFI_PopUpShown {
        get;
        set;
    } // Whether the RFI pop-up is shown.
    public Boolean isCCChecked {
        get;
        set;
    }
    public Boolean isAuthorizedSignerSelected {
        get;
        set;
    }
    public Boolean isAccountableEmploySelected {
        get;
        set;
    }
    public Boolean showAccountableRecipient {
        get;
        set;
    }
    public Boolean showAuthorizedSigner {
        get;
        set;
    }
    public String selectedET {
        get;
        set;
    } // Points Email Template which has been send
    public string etBody {
        get;
        set;
    } //  Email body content variable

    // public gFRS_Copay_Funding_Request__c fundingRequest   { get; set; }// The Funding Request object used  
    public gFRS_Copay_Funding_Request__c requestTemp {
        get;
        set;
    } // Stores only the email recipient address, fake record
    public gFRS_Copay_Funding_Request__c originalStatusValues {
        get;
        set;
    } // original status values when the funding request
    public Map < String, String > contentItems {
        get;
        set;
    }
    public Boolean isRFIdisabled {
        get;
        set;
    }
    public String selectedDecisionReason {
        get;
        set;
    }
    public List < Selectoption > decisionReasonForFoundation {
        get;
        set;
    }
    public String bccEmailAddress {
        get;
        set;
    }
    public String ccEmailAddress {
        get;
        set;
    }
    public User ownerOfReqest {
        get;
        set;
    }
    public gFRS_Copay_Funding_Request__c clonedRequest {
        get;
        set;
    }
    public String clonedRequestName {
        get;
        set;
    }
    public Boolean cloningProcessFinished {
        get;
        set;
    }
    public boolean disButton {
        get;
        set;
    } // Specifies, whether the button SEND should be disabled or not and its negation is used for Email Content visibility
    public String vendorBlockMessage {
        get;
        set;
    }

    Map < Id, Profile > profileIdToRecord;
    Set < String > profileNames;

    public String parentRecord {
        get {
            return fundingRequest.ParentRecord__c;
            return null;
        }

        set;
    }



    /*    public void showRFI_Popup(){
            this.isRFI_PopUpShown = true;
            selectedET            = 'NONE';
            disButton             = true;
            isRFIdisabled         = true;
            this.lETs             = new List<SelectOption>();
            String userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;
            
            if(fundingRequest.Record_Type_Name__c != null && (fundingRequest.Record_Type_Name__c == gFRS_Utilcopay.TYPE_CO_PAY_NAME)
               && this.fundingRequest.Accountable_Employee_Approval__c != null)
            {    
                showAccountableRecipient = true;
            }
            else
            {
                showAccountableRecipient = false;
            }
            
            this.recipient=[SELECT Id, FirstName, LastName, Name, Email, ContactId 
                            FROM User 
                            WHERE Id =:fundingRequest.OwnerId].get(0);
            
            System.debug('**************4'+this.recipient);
            this.lETs.add(new SelectOption('NONE', ' - please select template -'));
            
            EmailTemplate[] ets = [SELECT Subject, Name, Id, Description, Body,DeveloperName 
                                   FROM EmailTemplate 
                                   WHERE Folder.DeveloperName = :EMAIL_TEMPLATES_FOLDER 
                                   ORDER BY Name ASC];
            System.debug('**************1'+ets);
            for(EmailTemplate et1 : ets){
                this.mEtId2Body.put(et1.Id, et1);
                if(this.fundingRequest.Foundation_Classified__c == 'TRUE'){
                    if(et1.DeveloperName.contains('Foundation')){
                        this.lETs.add(new SelectOption(et1.Id, et1.Name));
                    }         
                }else {
                    if(this.fundingRequest.Record_Type_Name__c == 'Copay'){
                        System.debug('**************'+this.fundingRequest.Record_Type_Name__c);
                        if(et1.DeveloperName == 'gFRS_RFI' 
                           || et1.DeveloperName == 'Evaluation_Reminder_Communication' 
                           || et1.DeveloperName == 'LOA_Reminder_Communication' 
                           || et1.DeveloperName == 'General_Communication_External' ){
                               
                               this.lETs.add(new SelectOption(et1.Id, et1.Name));
                               System.debug('**************2'+et1.DeveloperName);
                               
                               
                           }  
                    }
                }
            }
            
            //System.debug( 'isRFI_PopUpShown:' + isRFI_PopUpShown );
        }*/

    public void showRFI_Popup() {
        id userid = UserInfo.getUserId();
        User userdata = [select id, profileId, profile.name FROM User where id = :userid];
        if(userdata.profile.name == 'GNE-GFRS-Copay-User'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, system.label.gFRS_Copay_insufficient_privileges));
        }
        this.isRFI_PopUpShown = true;
        selectedET = 'NONE';
        disButton = true;
        isRFIdisabled = true;
        this.lETs = new List < SelectOption > ();
        String userProfileName = gFRS_DAO.getProfileById(Userinfo.getProfileId()).Name;

        if (fundingRequest.Record_Type_Name__c != null && (fundingRequest.Record_Type_Name__c == gFRS_Utilcopay.TYPE_CO_PAY_NAME) &&
            this.fundingRequest.Accountable_Employee_Approval__c != null) {
            showAccountableRecipient = true;
        } else {
            showAccountableRecipient = false;
        }

        this.recipient = [SELECT Id, FirstName, LastName, Name, Email, ContactId
            FROM User
            WHERE Id =: fundingRequest.OwnerId
        ].get(0);

        System.debug('**************4' + this.recipient);
        this.lETs.add(new SelectOption('NONE', ' - please select template -'));

        List<String> folderNames = new List<String>{EMAIL_TEMPLATES_FOLDER, EMAIL_TEMPLATES_FOLDER1};
        List<String> templateNames = new List<String>{'RFI_Information_Request_Copay', 'General_Communication_Copay', 'Intent_to_Donate'};
        EmailTemplate[] ets = [SELECT Subject, Name, Id, Description, Body, DeveloperName
            FROM EmailTemplate
            WHERE Folder.DeveloperName in :folderNames AND DeveloperName in :templateNames
            ORDER BY Name ASC
        ];
        
        System.debug('**************1' + ets);
        system.debug('Query Results iterated ' + ets.size());
        for (EmailTemplate et1: ets) {
            this.mEtId2Body.put(et1.Id, et1);
            if (this.fundingRequest.Foundation_Classified__c == 'TRUE') {
                if (et1.DeveloperName.contains('Foundation')) {
                    this.lETs.add(new SelectOption(et1.Id, et1.Name));
                }
            } else {
                if (this.fundingRequest.Record_Type_Name__c == 'Copay') {
                    System.debug('**************' + this.fundingRequest.Record_Type_Name__c);
                    if (et1.DeveloperName == 'RFI_Information_Request_Copay' ||
                        et1.DeveloperName == 'General_Communication_Copay' ||
                        et1.DeveloperName == 'Intent_to_Donate') {
                        this.lETs.add(new SelectOption(et1.Id, et1.Name));
                        System.debug('**************2' + et1.DeveloperName);


                    }
                }
            }
        }

        //System.debug( 'isRFI_PopUpShown:' + isRFI_PopUpShown );
    }

    public void generateEmailContent() {

        String selectedTemplateLabel = getSelectedTemplateLabel(this.lETs, this.selectedET);

        if (selectedTemplateLabel != null && selectedTemplateLabel == 'LOA Reminder Communication') {

            isAuthorizedSignerSelected = true;
            showAuthorizedSigner = true;
        } else {

            isAuthorizedSignerSelected = false;
            showAuthorizedSigner = false;
        }

        if (selectedTemplateLabel != 'NONE' && selectedTemplateLabel != '') {

            this.disButton = false;

            if (selectedTemplateLabel != null && (selectedTemplateLabel.contains('RFI') || selectedTemplateLabel.contains('Program'))) {
                isRFIdisabled = false;
            } else {
                isRFIdisabled = true;
            }
            // try{
            EmailTemplate selectedEmailTemlate = mEtId2Body.get(this.selectedET);
            if (selectedEmailTemlate != null) {
                this.etBody = selectedEmailTemlate.Body;
                //this.subjectContent   =   selectedEmailTemlate.Subject;
                this.subjectContent = replaceEmailSubject(selectedEmailTemlate.Subject);
                if (selectedEmailTemlate.DeveloperName == 'Intent_to_Donate') {
                    list < gFRS_CoPay_Disease_State__c > DiseaseSt = new list < gFRS_CoPay_Disease_State__c > ();
                    DiseaseSt = [Select id, Disease_State_Fund_Name__c, Approved_Amount__c, Payment_Amount__c, PmtAmtTemp__c FROM gFRS_CoPay_Disease_State__c WHERE Copay_Funding_Request__c =: this.fundingRequest.id];
                    for(gFRS_CoPay_Disease_State__c DS : DiseaseSt){
                        if(DS.Payment_Amount__c == NULL){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, system.label.gFRS_Payment_Amount_Null));
                            this.disButton = true;
                            return;
                        }
                    }
                    this.etBody = replaceEmailBodyIntToDonate(selectedEmailTemlate.Body, this.fundingRequest, DiseaseSt);
                }else if((selectedEmailTemlate.DeveloperName == 'General_Communication_Copay' ||
                    selectedEmailTemlate.DeveloperName == 'RFI_Information_Request_Copay') &&
                    this.fundingRequest.Total_Paid_Amount__c > 0.0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, system.label.gFRS_Communication_After_First_Payment_Error));
                        this.disButton = true;
                        return;
                } else {
                    this.etBody = replaceEmailBody(selectedEmailTemlate.Body, this.recipient);
                }
                
                id userid = UserInfo.getUserId();
                User userdata = [select id, profileId, profile.name FROM User where id = :userid];
                if(userdata.profile.name == 'GNE-GFRS-Copay-User'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, system.label.gFRS_Copay_insufficient_privileges));
                    this.disButton = true;
                    return;
                }               

            }
            /* }catch(Exception ex){
                 this.etBody        = ' ';
                 //system.debug ('you screwed up! ' + ex.getStackTraceString());
                 this.disButton     = true;
                 this.isRFIdisabled = true;
             }       
             */


        } else {
            this.etBody = '';
            this.isRFIdisabled = true;
            this.disButton = true;
        }
    }

    public String getSelectedTemplateLabel(List < Selectoption > emailTemplateList, String idOfSelectedTemplate) {
        try {
            for (SelectOption option: emailTemplateList) {
                if (option.getValue() == idOfSelectedTemplate) {
                    return option.getLabel();
                }
            }
        } catch (Exception ex) {
            system.debug('user selected empty email template');
            return '';
        }

        return '';
    }

    public void hideRFI_Popup() {

        selectedET = 'NONE';
        this.isRFI_PopUpShown = false;
    }

    public ApexPages.PageReference sendEmail() {
        //method for email sending

        String[] toAddresses = new String[] {};

         if(fundingRequest.Information_Needed__c != null){
            fundingRequest.IsReviewedbyExternalUser__c = false;
            }
            
        if (fundingRequest.Owner.Email != null) {
            toAddresses.add(fundingRequest.Owner.Email);
        }
        if (isAuthorizedSignerSelected && fundingRequest.Signing_Authority_Email__c != null) {
            if (!checkIfStringIsInList(toAddresses, fundingRequest.Signing_Authority_Email__c)) {
                toAddresses.add(fundingRequest.Signing_Authority_Email__c);
            }
        }
        if (isAccountableEmploySelected != null && isAccountableEmploySelected && fundingRequest.Accountable_Employee_Approval__c != null && fundingRequest.Accountable_Employee_Approval__r.Email != null) {
            if (!checkIfStringIsInList(toAddresses, fundingRequest.Accountable_Employee_Approval__r.Email)) {
                toAddresses.add(fundingRequest.Accountable_Employee_Approval__r.Email);
            }

        }


        //String[] ccAddresses = new String[]{};

        /* temporary email address */
        String selectedTemplate = '';
        for (SelectOption item: this.lETs) {
            if (item.getValue() == this.selectedET) {

                selectedTemplate = item.getLabel();
            }
        }

        if ((selectedTemplate == 'RFI Information Request' || selectedTemplate == 'Program Denial Communication' || selectedTemplate == 'Program Cancelation Communication') && fundingRequest.Information_Needed__c == null) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_CommunicationErrorEmptyInfoNeeded));
            return null;
        }

        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            if (bccEmailAddress != null) {
                if (selectedTemplate == 'RFI Information Request') {
                    mail.setBccAddresses(new List < String > {
                        bccmail2,System.Label.gFRS_Copay_CC_Mail_Id
                    });
                }
                else {
                    mail.setBccAddresses(new List < String > {
                        bccmail2
                    });
                }
            }
            if (selectedTemplate == 'General Communication' || selectedTemplate == 'Intent to Donate') {
                mail.setCcAddresses(new List < String > { System.Label.gFRS_Copay_CC_Mail_Id });            
            }

            mail.setSubject(this.subjectContent);
            if (this.subjectContent == null || this.subjectContent == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptySubject));
                return null;
            }
            if (this.etBody == null || this.etBody == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Error_RFI_EmptyContent));
                return null;
            }


            etBody += '\n\n' + '[ref:' + fundingRequest.id + ']';
            mail.setPlainTextBody(etBody);

            /*//Cancel Post Funding email should be sent from following address: fundingrequestsystem-donotreply-d@gene.com
            if(selectedTemplate == 'Canceled Post Funding Communication'){
                mail.setOrgWideEmailAddressId([SELECT Id, Address 
                                                FROM OrgWideEmailAddress 
                                                WHERE Address='fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
            } */
            //for rest communication email notification is sent from current user context

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
            });

            try {

                if (selectedTemplate == 'RFI Information Request') {

                    fundingRequest.Sub_Status__c = gFRS_Util.REQUEST_STATUS_RFI;
                    fundingRequest.External_Sub_status__c = gFRS_Util.REQUEST_STATUS_RFI;

                } else if (selectedTemplate == 'Intent to Donate') {
                    fundingRequest.Sub_Status__c = gFRS_Utilcopay.REQUEST_SUB_STATUS_PAYMENT;
                    fundingRequest.External_Sub_status__c = gFRS_Utilcopay.REQUEST_EXTERNAL_SUB_STATUS_INTENT_TO_DONATE;

                } /* else if (selectedTemplate == 'General Communication') {
                    fundingRequest.Status__c = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
                    fundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                    fundingRequest.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                    fundingRequest.Evaluation_Completed__c = 'No';

                } */ else if (selectedTemplate == 'LOA Reminder Communication') {
                    fundingRequest.Status__c = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
                    fundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                    fundingRequest.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                    fundingRequest.Evaluation_Completed__c = 'No';

                }
                /*else if(selectedTemplate == 'Evaluation Reminder Communication'){
                                    fundingRequest.Status__c               = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
                                    fundingRequest.Sub_Status__c           = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                                    fundingRequest.External_Sub_status__c  = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                                    fundingRequest.Evaluation_Completed__c = 'No';
                                    
                                }*/


                /*       if((this.fundingRequest.Record_Type_Name__c == gFRS_Utilcopay.TYPE_CO_PAY_NAME 
                               || this.fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) 
                           && (this.fundingRequest.Information_Needed__c != null 
                               && this.fundingRequest.Information_Needed__c.contains('Application') 
                               && !this.fundingRequest.Information_Needed__c.contains('Third Party'))){

                           this.fundingRequest.Information_Needed__c += ';Third Party';
                       }  */

                //gFRS_Util_NoShare.saveLockedFundingRequestInternalPage( this.fundingRequest );
                gFRS_Util_NoSharecopay.saveLockedFundingRequestcopay(this.fundingRequest);
            } catch (Exception err) {
                System.debug('err:' + err.getMessage());
            }

            //hideRFI_Popup();

            //-- return to the current page to ensure the information is updated and refreshed
            return (new ApexPages.PageReference('/' + this.fundingRequest.id));
        } catch (Exception err) {
            System.debug('ERROR OCURRED:' + err.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
        }

        return (null);
    }

    public Boolean checkIfStringIsInList(List < String > lOfStrings, String stringToFind) {
        for (String s: lOfStrings) {
            if (s == stringToFind) {
                return true;
            }
        }
        return false;
    }

    /** 
     * @Author ADMD Team
     * @date 08/03/2013
     * @description Creates a new payment funding allocation record. Used by button New Payment Allocation.
     * 
     */
    public ApexPages.PageReference createNewPaymentAllocation() {

        try {
            if (this.fundingRequest.Payment_Type_Temp__c == 'Full') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_new_payment_allocation_not_allowed));
                return null;
            }        
            if (this.fundingRequest.Total_Paid_Amount__c >= this.fundingRequest.Requested_Amount1__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_CoPay_Requested_Amount_Exhausted));
                return null;
            }
            if (this.fundingRequest.Sub_Status__c != 'Paid') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_CoPay_Funding_Allocation_is_in_Process));
                return null;
            }
            RecordType rt = [SELECT Id
                FROM RecordType
                WHERE Name = 'Payment'
                AND SobjectType = 'GFRS_Copay_Funding_Allocation__c'
                limit 1
            ];
            GFRS_Copay__c gc = GFRS_Copay__c.getOrgDefaults();
            String strGLaccount = gc.GL_Account__c;
            GFRS_Copay_Funding_Allocation__c paymentFA;

            if (this.fundingRequest.Status__c == 'Processing & Disposition' &&
                this.fundingRequest.Sub_Status__c == 'Paid' &&
                this.fundingRequest.External_Sub_status__c == 'Approved') {

                paymentFA = new GFRS_Copay_Funding_Allocation__c(Grant_Request__c = this.fundingRequest.Id, Fiscal_Year__c = String.valueOf(date.today().year()), GL_Account_ref__c = strGLaccount, RecordTypeId = rt.id);
                insert paymentFA;

                GFRS_Copay_Funding_Allocation_Line_Item__c lineitem = new GFRS_Copay_Funding_Allocation_Line_Item__c(Funding_Allocation__c = paymentFA.id,
                    Percent__c = 100,
                    Funding_Record_Type__c = paymentFA.Grant_Request__r.Record_Type_Name__c,
                    Cost_Center_Lookup__c = gc.Cost_Center__c,
                    WBS_Code_Lookup__c = gc.WBS_Code__c
                );

                insert lineitem;

                this.fundingRequest.Funding_Approval_Step_Status__c = gFRS_Utilcopay.APPROVAL_SUBMITTED;
                this.fundingRequest.Inside_CST_CFO_Approval__c = 'NO';
                this.fundingRequest.Sub_Status__c = gFRS_Utilcopay.REQUEST_EXTERNAL_SUB_STATUS_CST_REVIEW;
                this.fundingRequest.Status__c = 'Decision';
             //   this.fundingRequest.External_Sub_status__c = 'Under Review';

                update this.fundingRequest;
                return (new ApexPages.PageReference('/apex/GFRS_FundingAllocationReadCopay?id=' + paymentFA.id).setRedirect(true));
            }

            return null;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex)));
            return null;
        }
    }

}