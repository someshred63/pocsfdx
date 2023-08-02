public with sharing class gFRS_decryptAttachmentController {
    
    public Id attachmentId { get; set; }
    public Attachment attched{get;set;}
    public String ACH_readTeam = 'GNE_GFRS_READ_ACH_INFO_Team';
    public Transient String decryptfile{get;set;}
    
    public gFRS_decryptAttachmentController(ApexPages.StandardController controller) {
        attachmentId = controller.getId();
    }
    
    public void decryptAttachment() {
        
        attched = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Id = :attachmentId];
        
        if(attched.ContentType==null){
            String path = attched.Name;
            string att = path.substring(path.lastindexof('.')+1);
            if(att.equalsIgnoreCase('pdf')){
                attched.ContentType = 'application/pdf';
            } else if(att.equalsIgnoreCase('jpg')){
                attched.ContentType = 'application/jpeg';
            } else if(att.equalsIgnoreCase('png')){
                attched.ContentType = 'application/png';
            } else if(att.equalsIgnoreCase('gif')){
                attched.ContentType = 'application/gif';
            }
        }
        EncryptionKey__c keySetting = EncryptionKey__c.getOrgDefaults();
        Blob aesKey = EncodingUtil.base64Decode(keySetting.AesKey__c);
        if(allowDecyption()){
            decryptfile = EncodingUtil.Base64Encode(Crypto.decryptWithManagedIV('AES256', aesKey, attched.Body));
        }
    }
    
    public boolean allowDecyption(){
        
        Boolean decryptAttachment = False;
        Set<String> groupNames = new Set<String>();
        
        if(gFRS_Util.isExternalRequestor(UserInfo.getUserId())){
            decryptAttachment = True;
        }else{
            for (GroupMember gm : [select group.name, group.DeveloperName from GroupMember 
                                    where UserOrGroupId = :UserInfo.getUserId()]){
                    groupNames.add(gm.group.DeveloperName);
            }
            if (groupNames.contains(ACH_readTeam)){
                decryptAttachment = True;
            }
        }
        
        return decryptAttachment;
    }

}