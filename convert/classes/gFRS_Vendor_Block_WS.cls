global class gFRS_Vendor_Block_WS {

	public static final String VENDOR_BLOCK_WARNING_EMAIL_TEMPLATE	= 'gFRS_Vendor_Block_Warning';
	public static final String EMAIL_TEMPLATES_FOLDER				= 'gFRS_Templates';// Email templates folder, where available for use templates are stored
	
    webService static String checkVendorBlock(String reqId) {
    	String internalRecipient = gFRS_Settings__c.getValues('Vendor Block Internal Recipient').Value__c != null ? gFRS_Settings__c.getValues('Vendor Block Internal Recipient').Value__c : '';//'fpopaymentfail-d@gene.com';
    	String externalRecipient = gFRS_Settings__c.getValues('Vendor Block External Recipient').Value__c != null ? gFRS_Settings__c.getValues('Vendor Block External Recipient').Value__c : '';//'gfrspaymentblock-d@gene.com'; 
    	System.debug('check if vendor is blocked, id: '+reqId);
    	System.debug(internalRecipient+', '+externalRecipient);
    	String vendorBlockMessage = '';
		String recipient = '';

    	gFRS_Funding_Request__c fundReq = [SELECT id, Name, Status__c, Sub_Status__c, Record_Type_Name__c, Foundation_Classified__c,
                                   Location__r.Vendor_Id__c, Location__r.Vendor_Name__c, Location__r.Organization__r.Tax_Status__c,
                                   Location__r.Organization__r.Tax_Id__c, Legal_Decision__c, Financial_Approver_2_Decision__c,
                                   Financial_Approver_1_Decision__c, Location__r.Address_Line_1__c, Location__r.City_1__c,
																	 Location__r.State_1__c, Location__r.Zip_Code_1__c, Location__r.Province_Region_Territory__c,
																	 Location__r.Country_1__c, Location__r.Organization__r.W9_Form_W_8BEN_Form__c, Location__r.Organization__r.Id,
																	 Requested_Amount__c
                                   from gFRS_Funding_Request__c where id=:reqId];

        Set<Id> profiles = new Set<Id>(new Map<Id, Profile>([Select Id from Profile 
        						where Name like '%-CS' 
                        		or Name like '%-DM'
                        		or Name like '%-Manager']).keySet());

   		if ((fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME && 
   			(fundReq.Sub_Status__c==gFRS_Util.REQUEST_SUB_STATUS_BUSINESS_REV || (fundReq.Sub_Status__c==gFRS_Util.REQUEST_SUB_STATUS_LEGAL_REV && fundReq.Requested_Amount__c<5000)))
   			 || ( !profiles.contains(UserInfo.getProfileId()))){

   		if(gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c) && ( fundReq.Sub_Status__c==gFRS_Util.REQUEST_SUB_STATUS_CCO || //CCO Review all internal
   			( (fundReq.Sub_Status__c==gFRS_Util.REQUEST_SUB_STATUS_BUSINESS_REV || (fundReq.Sub_Status__c==gFRS_Util.REQUEST_SUB_STATUS_LEGAL_REV && fundReq.Requested_Amount__c<5000)) && fundReq.Record_Type_Name__c==gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) ||		//FIE Business/Financial Approver
   			( fundReq.Sub_Status__c==gFRS_Util.REQUEST_SUB_STATUS_FINANCIAL_APPROVAL &&  fundReq.Financial_Approver_2_Decision__c==gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED))		//NOT FIE Financial Approver 3
   		) {
   			recipient = internalRecipient; 	//set internal message recipient - also a flag to call vendor lookup WS (if not empty)
   			System.debug('Internal check');
   		} else if(((gFRS_Util.isExternalRequest(fundReq.Record_Type_Name__c) || fundReq.Record_Type_Name__c==gFRS_Util.TYPE_IMED_NAME) && (fundReq.Sub_Status__c==gFRS_Util.REQUEST_SUB_STATUS_GC || //IS EXTERNAL in GC Review substatus
   				(fundReq.Financial_Approver_1_Decision__c==gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED && (fundReq.Sub_Status__c==gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA || fundReq.Sub_Status__c==gFRS_Util.REQUEST_SUB_STATUS_PAYMENT)))) //is after the financial approval - approval process finished - will trigger when 'Submit for payment' clicked
   				&& (fundReq.Foundation_Classified__c=='FALSE') ) { //is not foundation
    		recipient = externalRecipient;
    		System.debug('External check');
    	}

    	if (fundReq.Location__r.Vendor_Id__c != null && String.isNotBlank(recipient)) {	//if vendor id is known and the request qualify for one of the cases
    		try {
    			gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0 sapLookup = new gFRS_VendorLookupWS.GneCOMM_VendorMaster_SAP_ServicesPort0();
        		sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
        		GFRS_VendorLookupSAP.VendorLookupResponse_element response = sapLookup.VendorLookup( '', fundReq.Location__r.Vendor_Id__c, '', '', '', '100' );

    			if (response.MessageType=='S') {
    				System.debug(response);
    				if (handleResponse(response, fundReq, recipient)) {
    					vendorBlockMessage = 'Warning: Vendor ID '+fundReq.Location__r.Vendor_Id__c+', Vendor company Name '+fundReq.Location__r.Vendor_Name__c +' is blocked. An automated email will be sent to '+recipient+' with additional information about this vendor. Please follow up with vendor finance team.';
    					System.debug(vendorBlockMessage);
    				}
    			} else {
    				System.debug(response);
    				vendorBlockMessage = response.MessageText;
    			}

    		} catch( Exception err ) {
    			System.debug( 'ERROR OCCURRED:' + err.getMessage() );
    			vendorBlockMessage = 'Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem';
    			System.debug(vendorBlockMessage);
    		}
    	} else if(fundReq.Location__r.Vendor_Id__c == null) {
    		System.debug('No vendor id had been provided');
    		vendorBlockMessage = 'Vendor is not added';
    		System.debug(vendorBlockMessage);
    	}

			if ((recipient==internalRecipient && fundReq.Sub_Status__c!=gFRS_Util.REQUEST_SUB_STATUS_CCO ) || profiles.contains(UserInfo.getProfileId())) { 
				vendorBlockMessage = ''; //don't show popup message for internal requests in financial phase (not in cco review)
			}
    	System.debug(vendorBlockMessage);
    	}
    	return vendorBlockMessage;
    }

    public static Boolean handleResponse(GFRS_VendorLookupSAP.VendorLookupResponse_element response, GFRS_Funding_Request__c fundReq, String recipient) {
		Boolean isVendorBlocked = false;
        for (GFRS_VendorLookupSAP.VendorDetails_element  d : response.VendorDetails) {

	        fundReq.Location__r.Posting_block_for_all_company_codes__c	= d.PostingBlockAllCompanyCode;
	       	fundReq.Location__r.Posting_block_for_1000_or_1010__c		= d.PostingBlockSpecifiedCompanyCode;
	        fundReq.Location__r.Deletion_Flag_for_all_company_codes__c	= d.DeletionFlagAllArea;
	        fundReq.Location__r.Deletion_Flag_for_all_1000_or_1010__c	= d.DeletionFlagSelectedCompanyCode;
	        fundReq.Location__r.Payment_Block_Indicator__c				= d.PaymentBlockIndicator;
	        fundReq.Location__r.Payment_Block_Description__c			= d.PaymentBlockDescription;

	        if (String.isNotBlank(d.PostingBlockAllCompanyCode) &&  String.isNotBlank(d.DeletionFlagAllArea)) {
	        		isVendorBlocked=true;
	        }
        }

		update fundReq.Location__r;
		if (isVendorBlocked) {
			String[] toAddresses = new String[] {};

	   		toAddresses.add(recipient);

			try {
				EmailTemplate et = [SELECT Id, Subject, Body,DeveloperName
	                                FROM EmailTemplate
	                                WHERE Folder.DeveloperName = :EMAIL_TEMPLATES_FOLDER AND DeveloperName = :VENDOR_BLOCK_WARNING_EMAIL_TEMPLATE];

	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'Funding Request System'];
	            if ( owea.size() > 0 ) {
	            	mail.setOrgWideEmailAddressId(owea.get(0).id);
	            }
	            mail.setToAddresses(toAddresses);
	            mail.setSubject(prepareEmailSubject(et.Subject, fundReq));
	            GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults(); 
	            String recipientContact = '';
	            if (gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)){
	            	recipientContact = customSettings.gFRS_Vendor_Block_Internal_Recipient__c != null ? customSettings.gFRS_Vendor_Block_Internal_Recipient__c : recipient;
            	} else {
            		recipientContact = customSettings.gFRS_Vendor_Block_External_Recipient__c != null ? customSettings.gFRS_Vendor_Block_External_Recipient__c : recipient;
            	}
	            mail.setPlainTextBody(prepareEmailBody(et.Body, fundReq).replace('<<Recipient>>', recipientContact));
							System.debug('Attachment start');

							if (fundReq.Location__r.Organization__r.W9_Form_W_8BEN_Form__c != null) {
			            System.debug( 'w9 form is not null' );
									GFRS_Organization__c objOrg;
									objOrg = [SELECT Id, W9_Form_W_8BEN_Form__c,
												(SELECT Id, ParentID, Name FROM Attachments)
												FROM GFRS_Organization__c
												WHERE Id= :fundReq.Location__r.Organization__r.Id];  
									if (objOrg!=null) {
				            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
				            GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( objOrg.Attachments );
				            Attachment w9FormAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne(objOrg.W9_Form_W_8BEN_Form__c, objOrg.id);

				            Blob attBody = [SELECT Body FROM Attachment WHERE Id = :w9FormAttachment.Id].Body;
				            if (attBody!= null) {
				                att.setBody(attBody);
				                att.setFileName(w9FormAttachment.Name);
				                att.setInline(false);
				                att.setContentType('application/octet-stream');
				                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {att});
				            }
									}
			        }
							Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			} catch (Exception err) {
				System.debug( 'ERROR OCURRED:' + err.getMessage() );
			}
		}
		return isVendorBlocked;
    }

    private static String prepareEmailSubject(String subject, gFRS_Funding_Request__c fundReq) {
    	return subject.replace('<<G-#####>>', fundReq.Name!=null?fundReq.Name:'');
    }
    private static String prepareEmailBody(String body, gFRS_Funding_Request__c fundReq) {
    	String resultBody = body.replace('<<G-#####>>', fundReq.Name!=null?fundReq.Name:'');
    		resultBody = resultBody.replace('<<Vendor ID>>', fundReq.Location__r.Vendor_Id__c!=null? fundReq.Location__r.Vendor_Id__c:'');
			resultBody = resultBody.replace('<<Vendor Name>>', fundReq.Location__r.Vendor_Name__c!=null? fundReq.Location__r.Vendor_Name__c:'');
    	resultBody = resultBody.replace('<<Tax ID>>', fundReq.Location__r.Organization__r.Tax_Id__c!=null? fundReq.Location__r.Organization__r.Tax_Id__c:'');
			resultBody = resultBody.replace('<<Tax Status>>', fundReq.Location__r.Organization__r.Tax_Status__c!=null? fundReq.Location__r.Organization__r.Tax_Status__c:'');
    	resultBody = resultBody.replace('<<Vendor Name>>', fundReq.Location__r.Vendor_Name__c!=null? fundReq.Location__r.Vendor_Name__c:'');
			resultBody = resultBody.replace('<<Address Line 1>>', fundReq.Location__r.Address_Line_1__c!=null? fundReq.Location__r.Address_Line_1__c:'');
			resultBody = resultBody.replace('<<City>>', fundReq.Location__r.City_1__c!=null? fundReq.Location__r.City_1__c:'');
			resultBody = resultBody.replace('<<State>>', fundReq.Location__r.State_1__c!=null? fundReq.Location__r.State_1__c:'');
			resultBody = resultBody.replace('<<Zip Code>>', fundReq.Location__r.Zip_Code_1__c!=null? fundReq.Location__r.Zip_Code_1__c:'');
			resultBody = resultBody.replace('<<Province>>', fundReq.Location__r.Province_Region_Territory__c!=null? fundReq.Location__r.Province_Region_Territory__c:'');
			resultBody = resultBody.replace('<<Country>>', fundReq.Location__r.Country_1__c!=null? fundReq.Location__r.Country_1__c:'');
			resultBody = resultBody.replace('<<Request ID>>', fundReq.Name!=null?fundReq.Name:'');
    	return resultBody;
    }
}