/**********************************************************************
Purpose: ChannelOps_Constants class is used to maintain the constants
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      Vijay      08/08/2019      INITIAL DEVELOPMENT
***********************************************************************/
public class ChannelOps_Constants {
    public static final String CHANNELOPS_SPOILAGE_REQ_OBJ = 'ChannelOps_Spoilage_Request__c'; 
    public static final String CHANNELOPS_SPOLAGE_REQ_PROD_MASTER_CHILDREL_NM = 'ChannelOps_Spoilage_Product_Master__r';
    public static final List<String> spoilagestatusList1 = new List<String>{'New','Assigned','Pending Investigation',
                        'Processing in SAP','Forwarded to Genentech Patient Foundation','Forwarded to Quality',
                        'Rejected - rejection email sent','Rejected - rejection email not sent'};
    public static final Set<String> STATUS_UPDATE_NOT_ALLOWED_SET1 = new Set<String> {'Draft','SAP Response not yet received','SAP Quotation Creation Failed',
                'COD Sent','SAP Quotation Created','Signed COD awaiting review','Customer COD Sent to SAP',
                'SAP Process Complete', 'Pending Customer Correction', 'Waiting for COD',
                'SAP Failed To Process COD','SAP Rejected','COD Received by SAP','Sent to SAP','Manually created in SAP'};
    public static final List<String> spoilagestatusList2 = new List<String>{'New','Assigned','Pending Investigation',
                        'Forwarded to Genentech Patient Foundation','Forwarded to Quality',
                        'Rejected - rejection email sent','Rejected - rejection email not sent'};
    public static final Set<String> STATUS_UPDATE_NOT_ALLOWED_SET2 = new Set<String> {'Draft','SAP Response not yet received',
                        'COD Sent','SAP Quotation Created','Signed COD awaiting review','Customer COD Sent to SAP',
                        'SAP Process Complete', 'Pending Customer Correction', 'Waiting for COD',
                        'SAP Rejected','COD Received by SAP','Sent to SAP','Processing in SAP','Manually created in SAP'};
                            
    public static final String SPOILAGE_STATUS_NEW = 'New';
    public static final String SPOILAGE_STATUS_ASSIGNED = 'Assigned';
    public static final String SPOILAGE_STATUS_DRAFT = 'Draft';
    public static final String SPOILAGE_STATUS_PENDING_INVESTIGATION = 'Pending Investigation';
    public static final String SPOILAGE_STATUS_PROCESSING_IN_SAP = 'Processing in SAP';
    public static final String SPOILAGE_STATUS_FTGPF = 'Forwarded to Genentech Patient Foundation';
    public static final String SPOILAGE_STATUS_FTQUAILITY = 'Forwarded to Quality';
    public static final String SPOILAGE_STATUS_REJECTED_EMAIL_SENT = 'Rejected - rejection email sent';
    public static final String SPOILAGE_STATUS_REJECTED_EMAIL_NOT_SENT = 'Rejected - rejection email not sent';
    public static final String SPOILAGE_STATUS_SAP_REJECTED = 'SAP Rejected';
    public static final String SPOILAGE_STATUS_REJECTED = 'Rejected';
    public static final String SPOILAGE_STATUS_PENDING_CUST_CORRECTION = 'Pending Customer Correction'; 
    public static final String SPOILAGE_TYPE_LYTICS = 'Lytics Spoilage'; 
    public static final String SPOILAGE_TYPE_UNIVERSAL = 'Universal Spoilage';
    public static final String SPOILAGE_TYPE_SELF_ADMIN = 'Self-Administered Product Spoilage'; 
    public static final String SPOILAGE_TYPE_COLD_STORAGE_FAILURE = 'Cold Storage Failure';
    public static final String REQ_FIELD_MSG = 'You must enter a value'; 
    public static final String NO_SPOILAGE_REQ_FOUND = 'No Spoilage Request Found'; 
    public static final String CHANNELOPS_SPOILAGE_REQ_STATUS_APINAME = 'Status__c'; 
    public static final String APP_NAME = 'Spoilage';
    public static final String CONFIRMATION_PAGE_LOCATION = 'ConfirmationPage';
    public static final String HOME_PAGE_LOCATION = 'HomePage';
    public static final String SYSTEM_MSG_TYPE = 'System';
    public static final String FIELD_MSG_TYPE = 'Field';
    public static final String ALL_MODULES = 'All';
    public static final String SAP_FN_SPOILAGE_QT = 'Spoilage QT';
    public static final String SAP_FN_SIGNED_COD = 'Signed COD';
    public static final String SAP_FN_REJECTED_QT = 'Rejected QT';
    public static final String SPOILAGE_STATUS_SAP_QUOTATION_CREATED = 'SAP Quotation Created';
    public static final String SPOILAGE_STATUS_SAP_QUOTATION_CREATION_FAILED = 'SAP Quotation Creation Failed';
    public static final String SPOILAGE_STATUS_SIGNED_COD_AWAITING_REVIEW = 'Signed COD awaiting review';
    public static final String SPOILAGE_STATUS_COD_RECEIVED_BY_SAP = 'COD Received by SAP';
    public static final String SPOILAGE_STATUS_COD_SENT_BY_SAP = 'Customer COD Sent to SAP';
    public static final String SPOILAGE_STATUS_WAITING_FOR_COD = 'Waiting for COD';
    public static final String SPOILAGE_STATUS_SENT_TO_SAP = 'Sent to SAP';
    public static final String SPOILAGE_STATUS_SAP_FAILED_TO_PROCESS_COD = 'SAP Failed To Process COD';
    public static final String SPOILAGE_STATUS_SAP_RESP_NOT_RECEIVED = 'SAP Response not yet received';
    public static final String SPOILAGE_STATUS_SAP_COD_RESP_NOT_RECEIVED = 'SAP COD Response not yet received';
    public static final String SPOILAGE_TYPE_FIELD = 'Spoilage_Type__c';
    public static final String SELF_ADMIN_RETURN_METHOD = 'Able to return product';
    public static final String UNIVERSAL_COLD_STORAGE_RETURN_METHOD = 'I cannot safely discard product';       
    public static final String YES = 'Yes';
    public static final String NO = 'No';
    public static final String CONFIRM_PROD_RETURN = 'CONFIRM_PROD_RETURN'; 
    public static final String DATE_OF_SPOILAGE = 'DATE_OF_SPOILAGE'; 
    public static final String CHANNELOPS_SEND_SPOILAGE_REQ_SAP_TEMPLATE = 'ChannelOps_Send_Spoilage_Request_To_SAP';
    public static final String XML_CONTENT_TYPE = 'application/xml';
    public static final String XMLFILE_PREFIX = 'Spoilage XML';
    public static final String PDFFILE_PREFIX = 'Spoilage PDF';
    public static final String DEFAULT_CONTACT_NAME = 'Public General';//'Lwo Monitor';
    public static final String CHANNELOPS_APP_PROPERTY_NAME = 'Spoilage From';
    public static final String SUCCESS_MSG = 'Spoilage request has been sent to SAP succcessfully';
    public static final String ERROR_MSG = 'There was some error occured while sending spoilage request to SAP, Please contact to system Administrator';
    public static final String NO_SPOILAGE_REQ_COD_FOUND = 'No Spoilage Request COD Found'; 
    public static final String CHANNELOPS_SPOILAGE_CODE_CONF_EMAIL_TEMPLATE = 'ChannelOps_Spoilage_COD_Confirmation_Email'; 
    public static final String MSG_SUCCESS = 'Success';
    public static final String MSG_INFO = 'Info';
    public static final String MSG_ERROR = 'Error';
    public static final String MSG_WARNING = 'Warning';
    public static final String OPERATION_QT = 'QT';
    public static final String OPERATION_COD = 'COD';
    public static final String PDFFILE_PREFIX_SIGNEDCOD = 'Signed COD Form';
    public static final String CHANNELOPS_SPOILAGE_SEND_SIGNED_COD_EMAIL_TEMPLATE = 'ChannelOps_Send_Signed_COD_To_SAP'; 
    public static final String SEND_SIGNED_COD_SUCCESS_MSG = 'Signed COD Form has been sent to SAP succcessfully';
    public static final String SEND_SIGNED_COD_ERROR_MSG = 'There was some error occured while sending signed COD Form to SAP, Please contact to system Administrator';
    public static final String SAP_SUCCESS_RESPONSE = 'SUCCESS';
    public static final String SAP_ERROR_RESPONSE = 'ERROR';
    public static final String SAP_DUPLICATE_RESPONSE = 'DUPLICATE';
    public static final String SPOILAGE_STATUS_MANUALLY_CRE_IN_SAP = 'Manually created in SAP';
    public static final String GCS_CONTACT_RECORDTYPE_DEV_NAME = 'GCS_Contact';
}