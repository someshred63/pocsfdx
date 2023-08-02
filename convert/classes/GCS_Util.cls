/*****************************************************************************************
Purpose: GCS_Util class is used to maintain common methods and 
         constants
==========================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      Vijay        08/04/2020      INITIAL DEVELOPMENT
1.1      Raheem       21/12/2020      Added methods for genrating CryptoKey,  encrypt and decrypt the values
********************************************************************************************/
public with sharing class GCS_Util {
    
    public static final String GCS_CASE_RECORDTYPE_DEV_NAME = 'GCS_Case';
    public static final String GCS_CONTACT_RECORDTYPE_DEV_NAME = 'GCS_Contact';
    public static final String GCS_CASE_ORIGIN_EMAIL = 'Email';
    public static final String GCS_CASE_STATUS_ALERT = 'Alert';
    public static final String USER_ID_PREFIX = '005';
    public static final String GROUP_ID_PREFIX = '00G';

    public static Id cocsRecordTypeId;
    public static final String GCS_CUSTOM_NOTIFICATION_TYPE = 'GCS_Case_Email_Notification';
    public static final String GCS_CUSTOM_VOICE_NOTIFICATION_TYPE = 'GCS_Case_Voice_Mail_Notification';
    public static final String GCS_CASE_EMAIL_STATUS_NEW = 'New';
    public static Id notificationTypeId;
    public static Id voiceNotificationTypeId;
    public static Id gcsContactRecordTypeId;
    public static final String GCS_DEFAULT_ACCOUNT = 'Unassigned';

    public static Id getCaseReocrdTypeId(String caseRecTypeDevName){
        if(cocsRecordTypeId == null){
            cocsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(GCS_CASE_RECORDTYPE_DEV_NAME).getRecordTypeId();
        }
        return cocsRecordTypeId;
    }
    
    public static Id getCustomNotificationTypeId(){
        // Get the Id for our custom notification type
        if(notificationTypeId == null){
            List<CustomNotificationType> notificationTypeList = [SELECT   Id, DeveloperName FROM CustomNotificationType 
                                                             WHERE    DeveloperName =: GCS_CUSTOM_VOICE_NOTIFICATION_TYPE];
            if(notificationTypeList != null && !notificationTypeList.isEmpty()){
                notificationTypeId = notificationTypeList[0].Id;
            }
        }
        return notificationTypeId;
    }
      public static Id getVoiceCustomNotificationTypeId(){
        // Get the Id for our custom notification type
        if(voiceNotificationTypeId == null){
            List<CustomNotificationType> notificationTypeList = [SELECT   Id, DeveloperName FROM CustomNotificationType 
                                                             WHERE    DeveloperName =: GCS_CUSTOM_NOTIFICATION_TYPE];
            if(notificationTypeList != null && !notificationTypeList.isEmpty()){
                voiceNotificationTypeId = notificationTypeList[0].Id;
            }
        }
        return voiceNotificationTypeId;
    }
    /**generating CryptoKey **/
    @AuraEnabled
    public static string getCryptoKey() {
        String key = string.valueOf([SELECT Id, CreatedDate FROM Organization LIMIT 1].CreatedDate.getTime());
        key = EncodingUtil.base64Encode(Blob.valueOf(key)).left(16);
        return string.valueOf(key);
        
    }
    /**Encrypt the values
     * param: decryptedString:decrypted values, key:CryptoKey 
    **/
    @AuraEnabled
    public static string encryptData(String decryptedString, string key) {  
     if(!String.isBlank(decryptedString) && !String.isBlank(key)){
          Blob encryptedBlobData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf(key) , Blob.valueOf(decryptedString));
         return EncodingUtil.convertToHex(encryptedBlobData);      
      }
      return null;
  }
    
    /**decrypt the values
     * param: encryptedString:decrypted values, key:CryptoKey 
    **/
    public static string decryptData(String encryptedString, String key) {
        if(!String.isBlank(encryptedString) && !String.isBlank(key)){    
           Blob decryptedBlobData = Crypto.decryptWithManagedIV('AES128', Blob.valueOf(key), EncodingUtil.convertFromHex(encryptedString));
            return decryptedBlobData.toString();
        }
        return null;
    }
    
    public static Id getContactReocrdTypeId(String contactRecTypeDevName){
        if(gcsContactRecordTypeId == null){
            gcsContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(GCS_CONTACT_RECORDTYPE_DEV_NAME).getRecordTypeId();
        }
        return gcsContactRecordTypeId;
    }
    
  
}