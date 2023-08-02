/******************************************************************************************************************************
Purpose: ChannelOps_SAP_ConnectionHandler class contains actual business logic 
		to generate the XML file and send the XML file and PDF file to SAP via Email.
===============================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      Vijay      07/07/2019      INITIAL DEVELOPMENT
1.1		 Vijay 		09/12/2019		Added the processEmail method to parse SAP email and update the Spoilage Request status
1.2		 Vijay		09/20/2019      Added the method to send the signed COD pdf to SAP and update the Spoilage Request status
1.3      Vijay      06/22/2020      Added Tracking Original Order and Tracking Replacment Shipment fields for Self Admin 
                                    Spoilage type to send it SAP
1.4		 Kewal		10/07/2021		Added Susvimo BOM1 BOX B Product changes while sending data to SAP System. JIRA GCSME-123
*******************************************************************************************************************************/
public class ChannelOps_SAP_ConnectionHandler {
	
    //holds the xmlnode and Channelops Spoilage Request API field name mapping and used to prepare XML file
    static final Map<String, String> lyticsSpoilageRequestMap = new Map<String, String>{'SPOILAGE_TYPE'=>'Spoilage_Type__c', 
        'SFDC_REQUEST_ID'=>'Name','FACILITY_NAME'=>'Facility_Name__c','LICENSE_NUMBER'=>'License_Num__c',
        'DEA'=>'Facility_DEA__c','PHARMACY_REFERENCE'=>'Pharmacy_Reference_Num__c','STREET_ADDRESS'=>'Street_Name__c',
        'STREET2'=>'Street_2__c','CITY'=>'City__c','STATE'=>'State__c','ZIP_CODE'=>'Zip__c','CONTACT_FIRST_NAME'=>'Contact_First_Name__c', 
        'CONTACT_LAST_NAME'=>'Contact_Last_Name__c','CONTACT_PEMAIL_ID'=>'Contact_Email__c',
        'CONTACT_PHONE_NO'=>'Contact_Phone__c','CONTACT_FAX_NO'=>'Contact_Fax__c','DATE_OF_SPOILAGE'=>'Date_of_Spoilage__c',
        'SPOILAGE_EVENT_DEPLETE_INVENTORY'=>'Depleted_Inventory__c','CONFIRM_PROD_RETURN'=>'Return_Method__c','REASON_FOR_SPOILAGE'=>'SAP_Reason_Code__c','HUMAN_ERROR'=>'Human_Error__c', 
        'QUALITY_ISSUE'=>'Quality_Issue__c','ADVERSE_EVENT'=>'Adverse_Event__c'};
   	
    static final Map<String, String> selfAdminSpoilageRequestMap = new Map<String, String>{'SPOILAGE_TYPE'=>'Spoilage_Type__c','SFDC_REQUEST_ID'=>'Name','PHYSICIAN_FIRST_NAME'=>'Physician_First_Name__c',
        'PHYSICIAN_LAST_NAME'=>'Physician_Last_Name__c','FACILITY_NAME'=>'Facility_Name__c','LICENSE_NUMBER'=>'License_Num__c',
        'PHARMACY_REFERENCE'=>'Pharmacy_Reference_Num__c','DEA'=>'Facility_DEA__c','STREET_ADDRESS'=>'Street_Name__c',
        'STREET2'=>'Street_2__c','CITY'=>'City__c','STATE'=>'State__c','ZIP_CODE'=>'Zip__c','CONTACT_FIRST_NAME'=>'Contact_First_Name__c',
        'CONTACT_LAST_NAME'=>'Contact_Last_Name__c','CONTACT_PEMAIL_ID'=>'Contact_Email__c',
        'CONTACT_PHONE_NO'=>'Contact_Phone__c','CONTACT_FAX_NO'=>'Contact_Fax__c','DATE_OF_SPOILAGE'=>'Date_of_Spoilage__c','PROD_RECEIVE_VIA_GATCF'=>'GATCF_Product__c',
        'NOT_ACCEPT_DELIVERY'=>'Do_Not_Deliver_On__c','REASON_FOR_SPOILAGE'=>'SAP_Reason_Code__c','HUMAN_ERROR'=>'Human_Error__c','QUALITY_ISSUE'=>'Quality_Issue__c','ADVERSE_EVENT'=>'Adverse_Event__c',
        'TRACKING_ORG_ORD'=>'Tracking_of_original_order__c','TRACKING_REP_SHIPMENT'=>'Tracking_of_replacement_shipment__c',
        'CASE_ID'=>'Case_ID__c', 'REP_SHIPPED'=>'Replacement_Unit_Shipped__c'};
    
    static final Map<String, String> coldStorageSpoilageRequestMap = new Map<String, String>{'SPOILAGE_TYPE'=>'Spoilage_Type__c','SFDC_REQUEST_ID'=>'Name','PHYSICIAN_FIRST_NAME'=>'Physician_First_Name__c', 
        'PHYSICIAN_LAST_NAME'=>'Physician_Last_Name__c','LICENSE_NUMBER'=>'License_Num__c','DEA'=>'Facility_DEA__c',
        'FACILITY_NAME'=>'Facility_Name__c','STREET_ADDRESS'=>'Street_Name__c','STREET2'=>'Street_2__c','CITY'=>'City__c','STATE'=>'State__c',
        'ZIP_CODE'=>'Zip__c','CONTACT_FIRST_NAME'=>'Contact_First_Name__c','CONTACT_LAST_NAME'=>'Contact_Last_Name__c',
        'CONTACT_PEMAIL_ID'=>'Contact_Email__c','CONTACT_PHONE_NO'=>'Contact_Phone__c', 
        'CONTACT_FAX_NO'=>'Contact_Fax__c','DATE_OF_SPOILAGE'=>'Date_of_Spoilage__c','PROD_RECEIVE_VIA_GATCF'=>'GATCF_Product__c',
        'SPOILAGE_EVENT_DEPLETE_INVENTORY'=>'Depleted_Inventory__c','NOT_ACCEPT_DELIVERY'=>'Do_Not_Deliver_On__c', 
        'CONFIRM_PROD_RETURN'=>'Return_Method__c','REASON_FOR_SPOILAGE'=>'SAP_Reason_Code__c','HUMAN_ERROR'=>'Human_Error__c',
        'QUALITY_ISSUE'=>'Quality_Issue__c','ADVERSE_EVENT'=>'Adverse_Event__c','CATASTROPHIC_EVENT'=> 'CatastrophicEvent__c', 
        'DETERMINE_RA_COD_FLAG'=>'Return_Method_Exception__c','SPOILAGE_EXPLANATION1'=>'Reason_Detail__c', 'SPOILAGE_EXPLANATION2'=>'Reason_Detail_2__c'};
    
   static final Map<String, String> UniversalSpoilageRequestMap = new Map<String, String>{'SPOILAGE_TYPE'=>'Spoilage_Type__c','SFDC_REQUEST_ID'=>'Name',
        'PHYSICIAN_FIRST_NAME'=>'Physician_First_Name__c','PHYSICIAN_LAST_NAME'=>'Physician_Last_Name__c',
        'LICENSE_NUMBER'=>'License_Num__c','DEA'=>'Facility_DEA__c','FACILITY_NAME'=>'Facility_Name__c',
        'STREET_ADDRESS'=>'Street_Name__c','STREET2'=>'Street_2__c','CITY'=>'City__c','STATE'=>'State__c',
        'ZIP_CODE'=>'Zip__c','CONTACT_FIRST_NAME'=>'Contact_First_Name__c','CONTACT_LAST_NAME'=>'Contact_Last_Name__c',
        'CONTACT_PEMAIL_ID'=>'Contact_Email__c','CONTACT_PHONE_NO'=>'Contact_Phone__c', 
        'CONTACT_FAX_NO'=>'Contact_Fax__c','DATE_OF_SPOILAGE'=>'Date_of_Spoilage__c','PROD_RECEIVE_VIA_GATCF'=>'GATCF_Product__c',
        'SPOILAGE_EVENT_DEPLETE_INVENTORY'=>'Depleted_Inventory__c','NOT_ACCEPT_DELIVERY'=>'Do_Not_Deliver_On__c', 
        'CONFIRM_PROD_RETURN'=>'Return_Method__c','REASON_FOR_SPOILAGE'=>'SAP_Reason_Code__c','HUMAN_ERROR'=>'Human_Error__c', 
        'QUALITY_ISSUE'=>'Quality_Issue__c','ADVERSE_EVENT'=>'Adverse_Event__c','DETERMINE_RA_COD_FLAG'=>'Return_Method_Exception__c'};
             
    //holds the xmlnode and Channelops Spoilage Request Product API field name mapping and used to prepare xml file       
    static final Map<String, String> productMap =  new Map<String, String>{'PRODUCT_NAME'=>'Product_Name__c', 'NDC_NO'=>'NDC__c', 
        						'LOT_NO'=>'Lot_Number__c', 'QUANTITY'=>'Quantity__c','SERIAL_NO'=>'Serial_Number__c',
        						'PROD_INTENDED_TO_BE_USED_FOR'=>'Indication__c'};
    
   

    
    static GNE_Channel_Ops_Email_Tracker__c emailTracker;
    private ChannelOps_Spoilage_Request__c spoilageRequest;
    private ChannelOps_Spoilage_Request_COD__c spoilageRequestCOD;
    private Boolean isQuotationExists = false;
    
    /*********************************************************************************************
     Purpose: This method accepts the spoilageRequestId and send the details to SAP in XML and 
			 PDF file and return the success or error message
    **********************************************************************************************/                                
    public MessageWrapper sendToSAP(String spoilageRequestId){
        return sendSoilageRequestDataToSAP(spoilageRequestId);
    }

    @AuraEnabled
    public static MessageWrapper sendSoilageRequestDataToSAP(String spoilageRequestId){
        String msg = '';
        if(String.isBlank(spoilageRequestId)){
            return new MessageWrapper('Spoilage Request Id cannot be blank', ChannelOps_Constants.MSG_ERROR);
        }
        List<ChannelOps_Spoilage_Request__c> spoilageReqList = [SELECT Id, Status__c, Spoilage_Type__c FROM ChannelOps_Spoilage_Request__c
                                                                WHERE Id =: spoilageRequestId AND (Status__c =: ChannelOps_Constants.SPOILAGE_STATUS_ASSIGNED OR 
                                                                      Status__c=: ChannelOps_Constants.SPOILAGE_STATUS_PENDING_INVESTIGATION OR Status__c=: ChannelOps_Constants.SPOILAGE_STATUS_SAP_RESP_NOT_RECEIVED)];
        ChannelOps_Spoilage_Request__c spoilageReq = null;
        if(spoilageReqList != null &&  !spoilageReqList.isEmpty()){
            spoilageReq = spoilageReqList[0];
        }else{
            return new MessageWrapper('Valid Spoilage Request not found',ChannelOps_Constants.MSG_ERROR);
        }
        List<ChannelOps_App_Property__c> channelOpsAppPropList = getChannelOpsProperties(ChannelOps_Constants.CHANNELOPS_APP_PROPERTY_NAME);
        if((channelOpsAppPropList == null || channelOpsAppPropList.isEmpty()) 
            || String.isBlank(channelOpsAppPropList[0].SAP_Email_Address__c) ) {
            return new MessageWrapper('SAP Email Address cannot be blank',ChannelOps_Constants.MSG_ERROR);
        }
        MessageWrapper msgWrapper = new MessageWrapper();
        try{
			Set<String> fieldNameSet = new  Set<String>();
            if(spoilageReq.Spoilage_Type__c == ChannelOps_Constants.SPOILAGE_TYPE_LYTICS){
              fieldNameSet.addAll(lyticsSpoilageRequestMap.values());  
            }else if(spoilageReq.Spoilage_Type__c == ChannelOps_Constants.SPOILAGE_TYPE_SELF_ADMIN){
              fieldNameSet.addAll(selfAdminSpoilageRequestMap.values());  
            }if(spoilageReq.Spoilage_Type__c == ChannelOps_Constants.SPOILAGE_TYPE_UNIVERSAL){
              fieldNameSet.addAll(UniversalSpoilageRequestMap.values());  
            }if(spoilageReq.Spoilage_Type__c == ChannelOps_Constants.SPOILAGE_TYPE_COLD_STORAGE_FAILURE){
              fieldNameSet.addAll(coldStorageSpoilageRequestMap.values());  
            }          
					
			String condition = 'Id = \''+String.escapeSingleQuotes(spoilageRequestId)+'\'';
			String queryStr = buildDynamicQueryString(ChannelOps_Constants.CHANNELOPS_SPOILAGE_REQ_OBJ, fieldNameSet, 
													  ChannelOps_Constants.CHANNELOPS_SPOLAGE_REQ_PROD_MASTER_CHILDREL_NM, productMap.values(), 
													  condition);
			List<ChannelOps_Spoilage_Request__c> spoilageRequestList = null;
			if(String.isNotBlank(queryStr)){
				spoilageRequestList = (List<ChannelOps_Spoilage_Request__c>) Database.query(queryStr);
			}
			System.debug('spoilageRequestList-----'+spoilageRequestList);
			for(ChannelOps_Spoilage_Request__c req: spoilageRequestList){
				System.debug('Product-----'+req.ChannelOps_Spoilage_Product_Master__r);
			}
			String xmlString = generateXML(spoilageRequestList);
			List<Messaging.EmailFileAttachment> emailFileAttachmentList = new List<Messaging.EmailFileAttachment>();
			List<Attachment> emailTrackerAttachmentList = new List<Attachment>();
			if(String.isNotBlank(xmlString)){
				Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
				String fileName = ChannelOps_Constants.XMLFILE_PREFIX + ' ' + spoilageRequestList[0].Name + '.xml';
				emailAttachment.setBody(Blob.valueOf(xmlString)); 
				emailAttachment.setFileName(fileName);
				emailAttachment.setContentType(ChannelOps_Constants.XML_CONTENT_TYPE);
				emailFileAttachmentList.add(emailAttachment);
				Attachment attachmentRec = new Attachment();
				attachmentRec.Name = fileName;
				attachmentRec.ContentType = ChannelOps_Constants.XML_CONTENT_TYPE;
				attachmentRec.Body = Blob.valueOf(xmlString);
				emailTrackerAttachmentList.add(attachmentRec);
			}
			
			List<Attachment> attachmentList = [SELECT Id,Name, ParentId, body,ContentType FROM Attachment Where ParentId =: spoilageRequestList[0].Id ORDER BY LastModifiedDate DESC Limit 1];
			if(attachmentList != null && !attachmentList.isEmpty()){
				for(Attachment attachmentRec: attachmentList){
					Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
					String fileName = ChannelOps_Constants.PDFFILE_PREFIX + ' ' + spoilageRequestList[0].Name +'.pdf';
					emailAttachment.setBody(attachmentRec.body); 
					emailAttachment.setFileName(fileName);
					emailAttachment.setContentType(attachmentRec.ContentType);
					emailFileAttachmentList.add(emailAttachment);
				}
			}
			//Below email is hard coded for testing purpose, will get email address from app property.
			Messaging.SendEmailResult[] sendEmailResults = sendEmail(spoilageRequestList[0].Id, new String[] {channelOpsAppPropList[0].SAP_Email_Address__c}, ChannelOps_Constants.CHANNELOPS_SEND_SPOILAGE_REQ_SAP_TEMPLATE,
					 emailFileAttachmentList);
			Boolean isEmailSent = false;
			for(Messaging.SendEmailResult emailResult : sendEmailResults){
				if(emailResult.isSuccess()){
					msgWrapper.Message = ChannelOps_Constants.SUCCESS_MSG;
                    msgWrapper.Severity = ChannelOps_Constants.MSG_SUCCESS;
					isEmailSent = true;
				}else{
					for(Messaging.SendEmailError emailError: emailResult.getErrors()){
						System.debug('---'+emailError);
						msgWrapper.Message = ChannelOps_Constants.ERROR_MSG;
                        msgWrapper.Severity = ChannelOps_Constants.MSG_ERROR;
					}
				}
			}
			if(isEmailSent){
				spoilageRequestList[0].Status__c = ChannelOps_Constants.SPOILAGE_STATUS_SENT_TO_SAP;
				update spoilageRequestList[0];
				insert emailTracker;
				if(emailTrackerAttachmentList != null && !emailTrackerAttachmentList.isEmpty()){
					for(attachment attachmentRec: emailTrackerAttachmentList){
						attachmentRec.ParentId = emailTracker.Id;
					}
					insert emailTrackerAttachmentList;
				}
			}
        }catch(exception e){
          System.debug(Logginglevel.ERROR, e.getMessage());
          msgWrapper.Message = ChannelOps_Constants.ERROR_MSG;
          msgWrapper.Severity = ChannelOps_Constants.MSG_ERROR;
        }

        return msgWrapper;
    }
    
        
    /*********************************************************************************************
     Purpose: This method accepts the list of spoilageRequest and generates the XML file string and 
			  returns the xml file string
    **********************************************************************************************/
    public static String generateXML(List<ChannelOps_Spoilage_Request__c> spoilageRequestList){  
        String xmlString = '';
        if(spoilageRequestList != null && !spoilageRequestList.isEmpty()){
            Dom.Document doc = new Dom.Document();
			Dom.Xmlnode rootNode = doc.createRootElement('REQUEST', null, null);
    
            ChannelOps_Spoilage_Request__c spoilageRequest = spoilageRequestList[0];
            Map<String, String> spoilageRequestMap = new Map<String, String>();
            
            if(spoilageRequest.Spoilage_Type__c == ChannelOps_Constants.SPOILAGE_TYPE_LYTICS){
              spoilageRequestMap = lyticsSpoilageRequestMap;  
            }else if(spoilageRequest.Spoilage_Type__c == ChannelOps_Constants.SPOILAGE_TYPE_SELF_ADMIN){
              spoilageRequestMap = selfAdminSpoilageRequestMap;  
            }if(spoilageRequest.Spoilage_Type__c == ChannelOps_Constants.SPOILAGE_TYPE_UNIVERSAL){
              spoilageRequestMap = UniversalSpoilageRequestMap;  
            }if(spoilageRequest.Spoilage_Type__c == ChannelOps_Constants.SPOILAGE_TYPE_COLD_STORAGE_FAILURE){
              spoilageRequestMap = coldStorageSpoilageRequestMap;  
            }  
            
            for(String key : spoilageRequestMap.keySet()){
                Dom.Xmlnode xmlNode = rootNode.addChildElement(key, null, null);
                if(spoilageRequest.get(spoilageRequestMap.get(key)) != null){
                    if(key == ChannelOps_Constants.CONFIRM_PROD_RETURN){
                        String confirmToReturn = '';
                        if(spoilageRequest.get(ChannelOps_Constants.SPOILAGE_TYPE_FIELD) == ChannelOps_Constants.SPOILAGE_TYPE_LYTICS){
                             if(spoilageRequest.get(spoilageRequestMap.get(key)) == ChannelOps_Constants.SELF_ADMIN_RETURN_METHOD){
                            	confirmToReturn = ChannelOps_Constants.YES; 
                            }else{
                                confirmToReturn = ChannelOps_Constants.NO;
                            }
                        }else if(spoilageRequest.get(ChannelOps_Constants.SPOILAGE_TYPE_FIELD) == ChannelOps_Constants.SPOILAGE_TYPE_SELF_ADMIN || spoilageRequest.get(ChannelOps_Constants.SPOILAGE_TYPE_FIELD) == ChannelOps_Constants.SPOILAGE_TYPE_COLD_STORAGE_FAILURE){
                           if(spoilageRequest.get(spoilageRequestMap.get(key)) == ChannelOps_Constants.UNIVERSAL_COLD_STORAGE_RETURN_METHOD){
                            	confirmToReturn = ChannelOps_Constants.YES; 
                            }else{
                                confirmToReturn = ChannelOps_Constants.NO;
                            }
                        }else{
                            confirmToReturn = ChannelOps_Constants.NO;
                        }
                        xmlNode.addTextNode(confirmToReturn); 
                    }else if(key == ChannelOps_Constants.DATE_OF_SPOILAGE){
                       xmlNode.addTextNode(ChannelOps_SpoilageRequest_Util.formatDateInMMDDYYYY(Date.valueOf(spoilageRequest.get(spoilageRequestMap.get(key)))));  
                    }else{
                		xmlNode.addTextNode(String.valueOf(spoilageRequest.get(spoilageRequestMap.get(key)))); 
                    }
                }
            }
            if(spoilageRequest.ChannelOps_Spoilage_Product_Master__r != null && !spoilageRequest.ChannelOps_Spoilage_Product_Master__r.isEmpty()){
                ChannelOps_Spoilage_Product_Master__c bom1Boxb = new ChannelOps_Spoilage_Product_Master__c();
                if(spoilageRequest.get(ChannelOps_Constants.SPOILAGE_TYPE_FIELD) == ChannelOps_Constants.SPOILAGE_TYPE_UNIVERSAL || spoilageRequest.get(ChannelOps_Constants.SPOILAGE_TYPE_FIELD) == ChannelOps_Constants.SPOILAGE_TYPE_COLD_STORAGE_FAILURE){
                   bom1Boxb = [SELECT Id, Name, Brand__c, NDC__c, Spoilage_Type__c, Volume_limitation__c, Active__c 
                                                                      FROM ChannelOps_Spoilage_Product_Master__c 
                                                                      WHERE NDC__c =:System.label.PDS_SUSVIMO_BOM1_BOX_B_NDC AND Brand__c =:System.Label.PDS_SUSVIMO_BRAND AND Spoilage_Type__c =:(String)spoilageRequest.get(ChannelOps_Constants.SPOILAGE_TYPE_FIELD)
                                                                      LIMIT 1];
                }
                for(Sobject product: spoilageRequest.ChannelOps_Spoilage_Product_Master__r){
                   Dom.Xmlnode productNode = rootNode.addChildElement('PRODUCT', null, null);
                    for(String key :productMap.keySet()){	
                        Dom.Xmlnode childNode = productNode.addChildElement(key, null, null);
                        if(product.get(productMap.get(key)) != null){
                        	childNode.addTextNode(String.valueOf(product.get(productMap.get(key))));  
                        }
                    }
                    if(product.get('NDC__c') == System.label.PDS_SUSVIMO_BOM1_BOX_A_NDC && bom1Boxb != null){
                        Dom.Xmlnode productNode1 = rootNode.addChildElement('PRODUCT', null, null);
                        for(String key :productMap.keySet()){	
                            Dom.Xmlnode childNode1 = productNode1.addChildElement(key, null, null);
                            if(productMap.get(key) == 'Product_Name__c' && bom1Boxb != null){
                                childNode1.addTextNode(bom1Boxb.Name);  
                            }else if(productMap.get(key) == 'NDC__c' && bom1Boxb != null){
                                childNode1.addTextNode(bom1Boxb.NDC__c);
                            }else if(productMap.get(key) == 'Lot_Number__c' && bom1Boxb != null){
                                childNode1.addTextNode(System.Label.PDS_SUSVIMO_BOM1_BOX_B_LOT_NUMBER);
                            }else if(productMap.get(key) == 'Serial_Number__c' && bom1Boxb != null){ //Added gfor GCSME-146
                                childNode1.addTextNode('');
                            }else if(product.get(productMap.get(key)) != null){
                                childNode1.addTextNode(String.valueOf(product.get(productMap.get(key)))); 
                            }
                    }
                    }
                }
            }
            xmlString = doc.toXmlString();
			System.debug('xmlString =' + xmlString);
        }
        return xmlString;
    }
    
   
    /*********************************************************************************************
     Purpose: This method accepts sobjectName, field Names, Child object Relationship name, child object field names
			  and condition and prepares the SOQL query string.     
    **********************************************************************************************/
    public static String buildDynamicQueryString(String sObjectName, Set<String> fieldNameSet, String childRelationshipName,
                                           List<String> childFieldNameList, String condition){
        System.debug('sObjectName---------'+sObjectName);
        System.debug('condition---------'+condition);
        String queryStr ='';
        String childQueryStr = '';
                                               
        if(String.isNotBlank(sObjectName) && fieldNameSet != null && !fieldNameSet.isEmpty()){
            String extractedFields = '';
            //Schema.sObjectType sobjecType = Schema.getGlobalDescribe().get(sObjectName);
            for(String fieldName : fieldNameSet){
                if(String.isNotBlank(fieldName)){
                    extractedFields = extractedFields + fieldName + ', ';
                }
            } 
            extractedFields = extractedFields.removeEnd(', ');
            System.debug(extractedFields);
            String childExtractedFields = '';
            if(String.isNotBlank(childRelationshipName) && childFieldNameList != null && !childFieldNameList.isEmpty()){
                for(String fieldName : childFieldNameList){
                    if(String.isNotBlank(fieldName)){
                        childExtractedFields = childExtractedFields + fieldName + ', ';
                    }
                } 
            }
            if(String.isNotBlank(childExtractedFields)){
                childExtractedFields = childExtractedFields.removeEnd(', ');
                childQueryStr = '( SELECT ' + childExtractedFields + ' FROM '+ childRelationshipName + ' ) ';
            }
            if(String.isNotBlank(childQueryStr)){
            	queryStr = 'SELECT '+ extractedFields + ' , ' + childQueryStr +' FROM ' + sObjectName;  
            }else{
            	queryStr = 'SELECT '+ extractedFields +' FROM ' + sObjectName;
            }
            if(String.isNotBlank(condition)){
                queryStr += ' WHERE ' + condition;
            }
        }
        
        System.debug('queryStr---------'+queryStr);
        return queryStr;
    }
    
    /*********************************************************************************************
     Purpose: This method accepts whatId, array of to address, email template name and list of email
			  attachments and send the xml and pdf files with SAP and return the sendEmailResults.     
    **********************************************************************************************/
    public static Messaging.SendEmailResult[] sendEmail(Id whatId, String[] toAddresses, String emailTemplateName, List<Messaging.EmailFileAttachment> emailFileList){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        emailTracker = new GNE_Channel_Ops_Email_Tracker__c();
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        List<OrgWideEmailAddress> orgWideAddressList = null;
        if(sfdcBaseURL.contains('dev') || sfdcBaseURL.contains('sqa') || sfdcBaseURL.contains('uat')){
            orgWideAddressList = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'gneforms-d@gene.com'];
        }else{
            orgWideAddressList = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreplyco-d@gene.com'];
        }
        if(orgWideAddressList != null && !orgWideAddressList.isEmpty()){
            email.setOrgWideEmailAddressId(orgWideAddressList[0].Id);
            email.setReplyTo(orgWideAddressList[0].Address);
            emailTracker.From_Address__c = orgWideAddressList[0].Address;
        }
        List<Contact> contactList = [SELECT ID FROM Contact WHERE Name =: ChannelOps_Constants.DEFAULT_CONTACT_NAME AND 
                                                RecordType.DeveloperName =: ChannelOps_Constants.GCS_CONTACT_RECORDTYPE_DEV_NAME LIMIT 1];
        if(contactList == null || contactList.isEmpty()){
            contactList = [SELECT ID FROM Contact WHERE Email != null AND 
                                RecordType.DeveloperName =: ChannelOps_Constants.GCS_CONTACT_RECORDTYPE_DEV_NAME LIMIT 1];
        }
		List<EmailTemplate> templateList = [SELECT Id, Name, DeveloperName FROM EmailTemplate Where DeveloperName =:emailTemplateName LIMIT 1];
        if(templateList != null && !templateList.isEmpty()){
            email.setTemplateId(templateList[0].Id);
            emailTracker.Email_Template_Name__c = templateList[0].DeveloperName;
        }
        email.toaddresses = toAddresses;
        emailTracker.To_Address__c = String.valueOf(toAddresses);
        if(contactList != null && !contactList.isEmpty()){
        	email.setTargetObjectId(contactList[0].Id);
        }
        email.setWhatId(whatId);
        if(whatId != null){
        	Sobject sObj = whatId.getSobjectType().newSobject(whatId);
            if(sObj instanceOf ChannelOps_Spoilage_Request__c){
            	emailTracker.ChannelOps_Spoilage_Request__c = whatId; 
            }else if(sObj instanceOf ChannelOps_Spoilage_Request_COD__c){
            	emailTracker.ChannelOps_Spoilage_Request_COD__c = whatId; 
            }
        }
        
		emailTracker.Time_Stamp__c = System.now();
        emailTracker.Use_email_Tempate__c = true;
        email.setTreatTargetObjectAsRecipient(false);
        if(emailFileList != null && !emailFileList.isEmpty()){
        	email.setFileAttachments(emailFileList);
        }
        System.debug('email---'+email);
        return  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

    /*********************************************************************************************
     Purpose: This method accepts app name and retrieves the channelops app properties and returns 
			  the list of channelops app property.     
    **********************************************************************************************/    
    public static List<ChannelOps_App_Property__c> getChannelOpsProperties(String appName){
    	List<ChannelOps_App_Property__c> channelOpsAppProperties = null;
        if(String.isNotBlank(appName)){
        	channelOpsAppProperties = [SELECT	Id, Name, SAP_Email_Address__c 
                                       FROM		ChannelOps_App_Property__c 
                                       where Active__c=true and Application_Name__c=: appName limit 1];
        }
        return channelOpsAppProperties;
    }
    
   /*********************************************************************************************
     Purpose: This method accepts inboundEmail object and process the email details and 
			  update the spoilage request with Status, SAP Quotation Id and SAP Message in case of
			  failure
    **********************************************************************************************/ 
    public void processSAPEmail(Messaging.inboundEmail email){
        System.debug('In processSAPEmail method email ----'+email);
        Map<String, Map<String, String>> functionNmResponseMap = parseEmail(email);
        System.debug('functionNmResponseMap ----'+functionNmResponseMap);
        if(functionNmResponseMap != null && !functionNmResponseMap.isEmpty()){
            Map<String, String> sapResponseMap = null;
            if(functionNmResponseMap.containsKey(ChannelOps_Constants.SAP_FN_SPOILAGE_QT)){
                sapResponseMap = functionNmResponseMap.get(ChannelOps_Constants.SAP_FN_SPOILAGE_QT);
                System.debug('sapResponseMap ----'+sapResponseMap);
                if(sapResponseMap != null && !sapResponseMap.isEmpty()){
                    String sapStatus = sapResponseMap.get('Status');
                    if(String.isNotBlank(sapStatus)){
                        if(sapStatus.trim() == ChannelOps_Constants.SAP_SUCCESS_RESPONSE ||
                          sapStatus.trim() == ChannelOps_Constants.SAP_DUPLICATE_RESPONSE){
                            //update the spoilage request status
                            updateSpoilageStatus(sapResponseMap, ChannelOps_Constants.SPOILAGE_STATUS_SAP_QUOTATION_CREATED);
                            //create ChannelOps spoilage COD
                            if(!isQuotationExists){
                              createChannelOpsSpoilageRequestCOD(sapResponseMap);
                            }
                        }else if(sapStatus.trim() == ChannelOps_Constants.SAP_ERROR_RESPONSE){
                            updateSpoilageStatus(sapResponseMap, ChannelOps_Constants.SPOILAGE_STATUS_SAP_QUOTATION_CREATION_FAILED);
                        }
                    }
                }
            }else if(functionNmResponseMap.containsKey(ChannelOps_Constants.SAP_FN_SIGNED_COD)){
                sapResponseMap = functionNmResponseMap.get(ChannelOps_Constants.SAP_FN_SIGNED_COD);
                System.debug('sapResponseMap ----'+sapResponseMap);
                if(sapResponseMap != null && !sapResponseMap.isEmpty()){
                    String sapStatus = sapResponseMap.get('Status');
                    if(String.isNotBlank(sapStatus)){
                        if(sapStatus.trim() == ChannelOps_Constants.SAP_SUCCESS_RESPONSE){
                        	updateSpoilageStatus(sapResponseMap, ChannelOps_Constants.SPOILAGE_STATUS_COD_RECEIVED_BY_SAP);     
                        }else if(sapStatus.trim() == ChannelOps_Constants.SAP_ERROR_RESPONSE){
                            updateSpoilageStatus(sapResponseMap, ChannelOps_Constants.SPOILAGE_STATUS_SAP_FAILED_TO_PROCESS_COD);     
                        }
                    }
                }
            }else if(functionNmResponseMap.containsKey(ChannelOps_Constants.SAP_FN_REJECTED_QT)){
                sapResponseMap = functionNmResponseMap.get(ChannelOps_Constants.SAP_FN_REJECTED_QT);
                System.debug('sapResponseMap ----'+sapResponseMap);
                if(sapResponseMap != null && !sapResponseMap.isEmpty()){
                    String sapStatus = sapResponseMap.get('Status');
                    if(String.isNotBlank(sapStatus)){
                        if(sapStatus.trim() == ChannelOps_Constants.SAP_SUCCESS_RESPONSE){
                        	updateSpoilageStatus(sapResponseMap, ChannelOps_Constants.SPOILAGE_STATUS_SAP_REJECTED);
                        }
                    }
                }                
            }
        }
        try{
            if(spoilageRequest != null && !isQuotationExists){
                if(spoilageRequestCOD != null){
                    insert spoilageRequestCOD;
                    spoilageRequest.COD__c = spoilageRequestCOD.Id;
                }
                update spoilageRequest;
                createChannelOpsEmailTracker(email, spoilageRequest.Id);
                System.debug('emailTracker ----'+emailTracker);
                if(emailTracker != null){
                    insert emailTracker;
                }
            }
        }catch(Exception e){
            System.debug(Logginglevel.ERROR, e.getMessage());
        }
    }
	
   /*********************************************************************************************
     Purpose: This method accepts inboundEmail object and parse the email and prepare the map with 
			  function name as key and details with map of key and value pair and return map.
    **********************************************************************************************/     
    private Map<String, Map<String, String>> parseEmail(Messaging.inboundEmail email){
        String emailBody= '';
        String errorMsg = '';
        Map<String, Map<String, String>> functionNmResponseMap = new Map<String, Map<String, String>>();
        if(email != null){
            // Add the email plain text into the local variable 
            String emailSubject = email.subject;
            if(String.isNotBlank(emailSubject)){
                List<String> valueList = emailSubject.split('\\|');
                if(valueList != null && !valueList.isEmpty()){
                    functionNmResponseMap.put(valueList[0].trim(), new Map<String, String>());
                    
                    // Add the email plain text into the local variable 
                    emailBody = email.plainTextBody;
                     System.debug('functionNmResponseMap---'+ functionNmResponseMap); 
                    Map<String,String> emailBodyResponseMap = functionNmResponseMap.get(valueList[0].trim());
                    if(String.isNotBlank(emailBody)){
                        for(String msg: emailBody.split('\n')){            
                           System.debug('msg---'+ msg); 
                           List<String> keyValueList = msg.split(':');
                           System.debug('keyValueList---'+ keyValueList); 
                           if(keyValueList != null && !keyValueList.isEmpty()){
                            if(String.isNotBlank(keyValueList[0]) && !emailBodyResponseMap.containsKey(keyValueList[0].trim())){
                                System.debug('emailBodyResponseMap---'+ emailBodyResponseMap); 
                               emailBodyResponseMap.put(keyValueList[0].trim(),'');
                            }
                            if(keyValueList.size() > 1 && String.isNotBlank(keyValueList[1])){
                             if(String.isNotBlank(emailBodyResponseMap.get(keyValueList[0].trim()))){ 
                              String key = emailBodyResponseMap.get(keyValueList[0].trim());
                              key += '\n' + keyValueList[1].trim();
                              emailBodyResponseMap.put(keyValueList[0].trim(),key);
                             }else{
                                emailBodyResponseMap.put(keyValueList[0].trim(),keyValueList[1].trim());
                             }
                           }
                        }
                      }
                    }else{
                       errorMsg = 'No Body in the Email'; 
                    }
                }               
            }else{
               errorMsg = 'No Subject in Email'; 
            }
        }
        return functionNmResponseMap;
    }
	
   /*********************************************************************************************
     Purpose: This method accepts SAP details in map and status, update the status and SAP details 
			  on spoilage request			  
    **********************************************************************************************/     
    private void updateSpoilageStatus(Map<String, String> sapResponseMap, String status){
        if(sapResponseMap != null && !sapResponseMap.isEmpty()){
            String channelOpsRequestName = sapResponseMap.get('SFDC_Request_ID');
            List<ChannelOps_Spoilage_Request__c> spoilageRequestList = [SELECT Id, Name, Status__c, SAP_Message__c,
                                                                        	   SAP_Quotation_ID__c
                                                                        FROM   ChannelOps_Spoilage_Request__c
                                                                        WHERE  Name=: channelOpsRequestName];
            if(!spoilageRequestList.isEmpty()){
                spoilageRequest = spoilageRequestList[0];
            }
            if(spoilageRequest != null){
                String sapStatus = sapResponseMap.get('Status');
                spoilageRequest.Status__c = status;
                if(String.isNotBlank(sapResponseMap.get('SAP_Quotation#')) && sapResponseMap.get('SAP_Quotation#') != spoilageRequest.SAP_Quotation_ID__c){
            		spoilageRequest.SAP_Quotation_ID__c = (String.isNotBlank(sapResponseMap.get('SAP_Quotation#'))) ? sapResponseMap.get('SAP_Quotation#') : spoilageRequest.SAP_Quotation_ID__c;
                }else if(String.isNotBlank(sapStatus) && sapStatus.trim() == ChannelOps_Constants.SAP_DUPLICATE_RESPONSE){
                    isQuotationExists = true;
                }
                //String sapMessage =  spoilageRequest.SAP_Message__c;
                if(String.isNotBlank(sapStatus) && sapStatus.trim() != ChannelOps_Constants.SAP_DUPLICATE_RESPONSE){
                	spoilageRequest.SAP_Message__c = (String.isNotBlank(sapResponseMap.get('Error_Message'))) ? sapResponseMap.get('Error_Message') : '';
                }
				//spoilageRequest.SAP_Message__c += sapMessage;
            }
        }
    }
    
    /*********************************************************************************************
     Purpose: This method accepts SAP details in map and create a spoilage request COD record
    **********************************************************************************************/
    private void createChannelOpsSpoilageRequestCOD(Map<String, String> sapResponseMap){
        if(spoilageRequest != null && sapResponseMap != null && !sapResponseMap.isEmpty() && 
          String.isNotBlank(sapResponseMap.get('SAP_Quotation_End_Date')) && String.isNotBlank(sapResponseMap.get('SAP_Ship_To_ID'))){          
              spoilageRequestCOD = new ChannelOps_Spoilage_Request_COD__c();
              spoilageRequestCOD.ChannelOps_Spoilage_Request__c = spoilageRequest.Id;
              spoilageRequestCOD.SAP_Quotation_ID__c =  (String.isNotBlank(sapResponseMap.get('SAP_Quotation#'))) ? sapResponseMap.get('SAP_Quotation#') :'';
              spoilageRequestCOD.SAP_Ship_To_ID__c =  (String.isNotBlank(sapResponseMap.get('SAP_Ship_To_ID'))) ? sapResponseMap.get('SAP_Ship_To_ID') : '';
              spoilageRequestCOD.Ship_To_Name__c =  (String.isNotBlank(sapResponseMap.get('Ship_To_Name'))) ? sapResponseMap.get('Ship_To_Name') : '';
              spoilageRequestCOD.State_License__c =  (String.isNotBlank(sapResponseMap.get('State_License'))) ? sapResponseMap.get('State_License') : '';
              spoilageRequestCOD.DEA__c =  (String.isNotBlank(sapResponseMap.get('DEA'))) ? sapResponseMap.get('DEA') : '';
              spoilageRequestCOD.Contact_Name__c =  (String.isNotBlank(sapResponseMap.get('Contact_Person_Name'))) ? sapResponseMap.get('Contact_Person_Name') : '';
              spoilageRequestCOD.Contact_Email__c =  (String.isNotBlank(sapResponseMap.get('Contact_Person_Email_Address'))) ? sapResponseMap.get('Contact_Person_Email_Address') : '';
              spoilageRequestCOD.Contact_Phone__c =  (String.isNotBlank(sapResponseMap.get('Contact_Person_Phone'))) ? sapResponseMap.get('Contact_Person_Phone') : '';
              spoilageRequestCOD.Street_Address__c =  (String.isNotBlank(sapResponseMap.get('Street_Address'))) ? sapResponseMap.get('Street_Address') : '';
              spoilageRequestCOD.Street_Address2__c =  (String.isNotBlank(sapResponseMap.get('Street_Address2'))) ? sapResponseMap.get('Street_Address2') : '';
              spoilageRequestCOD.City__c =  (String.isNotBlank(sapResponseMap.get('City'))) ? sapResponseMap.get('City') : '';
              spoilageRequestCOD.State__c =  (String.isNotBlank(sapResponseMap.get('State'))) ? sapResponseMap.get('State') : ''; 
              spoilageRequestCOD.Zip_Code__c =  (String.isNotBlank(sapResponseMap.get('Zip_Code'))) ? sapResponseMap.get('Zip_Code') : '';   
              spoilageRequestCOD.Quotation_Document_Date__c =  (String.isNotBlank(sapResponseMap.get('Quotation_Document_Date'))) ? Date.parse(sapResponseMap.get('Quotation_Document_Date')) : null;
              spoilageRequestCOD.Quotation_Request_Date__c =  (String.isNotBlank(sapResponseMap.get('Quotation_Request_Date'))) ? Date.parse(sapResponseMap.get('Quotation_Request_Date')) : null;
              spoilageRequestCOD.SAP_Quotation_End_Date__c =  (String.isNotBlank(sapResponseMap.get('SAP_Quotation_End_Date'))) ? Date.parse(sapResponseMap.get('SAP_Quotation_End_Date')) : null;  
              spoilageRequestCOD.Facility_Name__c =  (String.isNotBlank(sapResponseMap.get('Facility_Name'))) ? sapResponseMap.get('Facility_Name') : '';  
              //update spoilage request status to Waiting for COD
              spoilageRequest.Status__c = ChannelOps_Constants.SPOILAGE_STATUS_WAITING_FOR_COD;
        } 
    }
    
    /*********************************************************************************************
     Purpose: This method accepts inbound email object and spoilage request ID, create a instance with
              ChannelOps Email Tracker
    **********************************************************************************************/
    private void createChannelOpsEmailTracker(Messaging.inboundEmail email, String spoilageRequestId){
        if(email != null && spoilageRequestId != null){
            emailTracker = new GNE_Channel_Ops_Email_Tracker__c();       
            emailTracker.From_Address__c = email.fromAddress;            
            emailTracker.To_Address__c = String.valueOf(email.toAddresses);
            emailTracker.ChannelOps_Spoilage_Request__c = spoilageRequestId;
            emailTracker.Time_Stamp__c = System.now();
            emailTracker.Use_email_Tempate__c = false;
            emailTracker.Body__c = email.plainTextBody;
            emailTracker.Subject__c = email.subject;
            emailTracker.BCC__c = String.valueOf(email.ccAddresses);
        }
    }
    
    //wrapper class to hold the message
    public class MessageWrapper{
        @AuraEnabled public String message {get;set;} 
        @AuraEnabled public String severity {get;set;} 
        
        public MessageWrapper(){
            
        }
        public MessageWrapper(String message, String severity){
            this.message = message;
            this.severity = severity;
        }        
    }
    
    /*********************************************************************************************
     Purpose: This method accepts the spoilageRequestCODId and send the signed COD pdf file to SAP
			  and return the success or error message
    **********************************************************************************************/  
    public MessageWrapper sendSignedCODToSAP(String spoilageRequestCODId){
        return sendSignedDataCODToSAP(spoilageRequestCODId);
    }  
    @AuraEnabled
    public static MessageWrapper sendSignedDataCODToSAP(String spoilageRequestCODId){
        MessageWrapper msgWrapper = new MessageWrapper();
    	if(String.isBlank(spoilageRequestCODId)){
            return new MessageWrapper('Spoilage Request COD Id cannot be blank', ChannelOps_Constants.MSG_ERROR);
        }
        try{
            List<ChannelOps_App_Property__c> channelOpsAppPropList = getChannelOpsProperties(ChannelOps_Constants.CHANNELOPS_APP_PROPERTY_NAME);
            if((channelOpsAppPropList == null || channelOpsAppPropList.isEmpty()) 
                || String.isBlank(channelOpsAppPropList[0].SAP_Email_Address__c) ) {
                return new MessageWrapper('SAP Email Address cannot be blank',ChannelOps_Constants.MSG_ERROR);
            }
            List<ChannelOps_Spoilage_Request_COD__c> spoilageReqCODList = [SELECT Id, Name, ChannelOps_Spoilage_Request__c, ChannelOps_Spoilage_Request__r.Id, ChannelOps_Spoilage_Request__r.Name 
                                                                           FROM	  ChannelOps_Spoilage_Request_COD__c 
                                                                           WHERE  Id =: spoilageRequestCODId AND ChannelOps_Spoilage_Request__r.Status__c =: ChannelOps_Constants.SPOILAGE_STATUS_SIGNED_COD_AWAITING_REVIEW];
            ChannelOps_Spoilage_Request_COD__c spoilageReqCOD = null;
            ChannelOps_Spoilage_Request__c spoilageRequest = null;
            if(spoilageReqCODList != null &&  !spoilageReqCODList.isEmpty()){
                spoilageReqCOD = spoilageReqCODList[0];
                spoilageRequest = spoilageReqCOD.ChannelOps_Spoilage_Request__r;
            }else{
                return new MessageWrapper('Valid Spoilage Request COD not found',ChannelOps_Constants.MSG_ERROR);
            }
            List<Messaging.EmailFileAttachment> emailFileAttachmentList = new List<Messaging.EmailFileAttachment>();
            List<Attachment> attachmentList = [SELECT Id,Name, ParentId, body,ContentType FROM Attachment Where ParentId =: spoilageReqCOD.Id ORDER BY LastModifiedDate DESC Limit 1];
                if(attachmentList != null && !attachmentList.isEmpty()){
                    for(Attachment attachmentRec: attachmentList){
                        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                        emailAttachment.setBody(attachmentRec.body); 
                        emailAttachment.setFileName(attachmentRec.Name);
                        emailAttachment.setContentType(attachmentRec.ContentType);
                        emailFileAttachmentList.add(emailAttachment);
                    }
                }
            //Below email is hard coded for testing purpose, will get email address from app property.
            Messaging.SendEmailResult[] sendEmailResults = sendEmail(spoilageReqCOD.Id, new String[] {channelOpsAppPropList[0].SAP_Email_Address__c}, ChannelOps_Constants.CHANNELOPS_SPOILAGE_SEND_SIGNED_COD_EMAIL_TEMPLATE,
                                                                     emailFileAttachmentList);
            Boolean isEmailSent = false;
            for(Messaging.SendEmailResult emailResult : sendEmailResults){
                if(emailResult.isSuccess()){
                    msgWrapper.Message = ChannelOps_Constants.SEND_SIGNED_COD_SUCCESS_MSG;
                    msgWrapper.Severity = ChannelOps_Constants.MSG_SUCCESS;
                    isEmailSent = true;
                }else{
                    for(Messaging.SendEmailError emailError: emailResult.getErrors()){
                        System.debug('---'+emailError);
                        msgWrapper.Message = ChannelOps_Constants.SEND_SIGNED_COD_ERROR_MSG;
                        msgWrapper.Severity = ChannelOps_Constants.MSG_ERROR;
                    }
                }
            }
            if(isEmailSent){
                spoilageRequest.Status__c = ChannelOps_Constants.SPOILAGE_STATUS_COD_SENT_BY_SAP;
                update spoilageRequest;
                insert emailTracker;
            }
        }catch(exception e){
          System.debug(Logginglevel.ERROR, e.getMessage());
          msgWrapper.Message = ChannelOps_Constants.SEND_SIGNED_COD_ERROR_MSG;
          msgWrapper.Severity = ChannelOps_Constants.MSG_ERROR;
        }
        
        return msgWrapper;
    }

}