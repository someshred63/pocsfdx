public with sharing class GNE_AP_Attachment_Controller {
	
    public static String LIST_MODE { get { return 'LIST'; } }
    public static String ADD_MODE { get { return 'ADD'; } }    
	public ID accountPlanId { get; set; }
    public ID userId { get; set; }
	public Boolean isReadOnly { get; set; }
	public List<ApAttachment> attachments { get; private set; }
    public Boolean hasAttachments { get; private set; }
	public ID attachmentIdToRemove { get; set; }
    public String msgThrown { get; set; }
    public String viewMode { get; set; }               
    public ApAvailableAccounts apAvailableAccounts { get; private set; }

	public GNE_AP_Attachment_Controller(){
        this.viewMode = LIST_MODE;
    }
    
    public void loadAttachments(){
        try {
        	if (this.attachments != null && this.attachments.size() > 0){
            	this.attachments.clear();
        	}
        	this.attachments = getAttachments();
        	this.hasAttachments = this.attachments.size() > 0;
        } catch (Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
			ApexPages.addMessage(myMsg);
        }
    }
       	
    public PageReference removeAttachment(){
		try {
            AP_Attachment_gne__c toDelete = new AP_Attachment_gne__c(Id = attachmentIdToRemove);
			delete toDelete;
		} catch (Exception ex){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
			ApexPages.addMessage(myMsg);
        } finally{
            loadAttachments();
        }
        return null;
	}
    
    public void throwErrorMsg(){
        if (String.isNotBlank(msgThrown)){
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msgThrown);
			ApexPages.addMessage(myMsg);
        }
    }
        	
	private List<ApAttachment> getAttachments(){
		List<ApAttachment> result = new List<ApAttachment>();
		
		for (AP_Attachment_gne__c apAttachment : [
			SELECT Id, Name, OwnerId,
				(SELECT AP_Account_gne__r.Name FROM AP_Attachment_Details__r ORDER BY AP_Account_gne__r.Name DESC),
            	(SELECT Name, CreatedDate FROM Attachments)
			FROM AP_Attachment_gne__c
			WHERE ID IN (SELECT AP_Attachment_gne__c FROM AP_Attachment_Detail_gne__c WHERE AP_Account_Planning_gne__c = :accountPlanId)
			ORDER BY Name ASC]){			
		 	result.add(new ApAttachment(apAttachment));		
		}
		
		return result;
	}
    
    public void initAvailableAccounts(){
        try {
            this.apAvailableAccounts = new ApAvailableAccounts();            
            for(AP_Account_User_gne__c accountUser : [
               	SELECT AP_Account_gne__r.Id, AP_Account_gne__r.Name, AP_Account_gne__r.Address_gne__c
               	FROM AP_Account_User_gne__c
				WHERE CS_User_gne__c = :userId 
               	ORDER BY LastModifiedDate DESC]){
				this.apAvailableAccounts.addUserAccount(accountUser.AP_Account_gne__r);
			}            
			for(AP_Detail_gne__c apDetail : [
               	SELECT AP_Account_gne__r.Id, AP_Account_gne__r.Name, AP_Account_gne__r.Address_gne__c
               	FROM AP_Detail_gne__c 
               	WHERE AP_Account_Planning_gne__c != :accountPlanId AND AP_Account_Planning_gne__r.Status_gne__c != :GNE_AP_Util.AP_ARCHIVED]){
				this.apAvailableAccounts.addSharedAccount(apDetail.AP_Account_gne__r);
			}        	
        } catch (Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
			ApexPages.addMessage(myMsg);
        }
    }
    
    @RemoteAction
    public static String uploadAttachment(Id attachmentId, String base64BlobValue, String fileName, String contentType, String[] apAccountIds, String accountPlanId){
        String result = '';
        Savepoint sp = Database.setSavepoint();
        try {
            if(attachmentId != null) {
                List<Attachment> existingAttachment = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE Id =: attachmentId];
                if(existingAttachment.size() > 0) {
                    String existingBody = EncodingUtil.base64Encode(existingAttachment[0].Body);
                    String presentBody = existingBody + base64BlobValue;
                    existingAttachment[0].Body = EncodingUtil.base64Decode(presentBody);
                    update existingAttachment[0];
                    return existingAttachment[0].Id;
                }
            }

            AP_Attachment_gne__c attachment = new AP_Attachment_gne__c(
            	Name = fileName
            );
            insert attachment;
            
            Attachment attached = new Attachment(
            	ParentId = attachment.Id,
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            insert attached;
            
            List<AP_Attachment_Detail_gne__c> attachmentDetailList = new List<AP_Attachment_Detail_gne__c>();
            if (apAccountIds.size() > 0){
                Set<String> apAccountIdsSet = new Set<String>(apAccountIds);
                for (String accId : apAccountIdsSet){
                    attachmentDetailList.add(
                    	new AP_Attachment_Detail_gne__c(
                        	AP_Attachment_gne__c = attachment.Id,
                            AP_Account_gne__c = accId,
                            AP_Account_Planning_gne__c = accountPlanId
                        )
                    );
                }
            } else {
                attachmentDetailList.add(
                    new AP_Attachment_Detail_gne__c(
                    	AP_Attachment_gne__c = attachment.Id,                        
                        AP_Account_Planning_gne__c = accountPlanId
                    )
                );
            }
            insert attachmentDetailList;
            result = attached.Id;
        } catch(Exception ex){
            Database.rollback(sp);
            throw ex;
        }
        return result;
    }
	
	private class ApAttachment {
		public ID Id { get; private set; }
        public Boolean CanBeRemoved { get; private set; }
		public Attached Attached { get; private set; }
		public ApAttachedAccounts ApAttachedAccounts { get; private set; }        
		
		public ApAttachment(AP_Attachment_gne__c apAttachment){
			this.Id = apAttachment.Id;
            this.CanBeRemoved = apAttachment.OwnerId == UserInfo.getUserId();
			this.Attached = new Attached(apAttachment.Attachments.size() == 1 ? apAttachment.Attachments[0] : null);
			this.ApAttachedAccounts = new ApAttachedAccounts(apAttachment.AP_Attachment_Details__r);
		}				
	}
	
	private class Attached {
		public ID Id { get; private set; }
		public String Name { get; private set; }
		public DateTime DateAdded { get; private set; }
		
		public Attached(Attachment attached){
			if (attached != null){
				this.Id = attached.Id;
				this.Name = attached.Name;
				this.DateAdded = attached.CreatedDate;
			}
		}
	}
	
	private class ApAttachedAccounts {
		public String Names { get; private set; }
		
		public ApAttachedAccounts(List<AP_Attachment_Detail_gne__c> apAttachmentDetails){
			this.Names= '';
			for (AP_Attachment_Detail_gne__c apAttachmentDetail : apAttachmentDetails){
				if (String.isNotBlank(apAttachmentDetail.AP_Account_gne__r.Name)){
					this.Names += apAttachmentDetail.AP_Account_gne__r.Name + ', ';
				}
			}
			this.Names = this.Names.removeEnd(', ');
            if (String.isBlank(this.Names)){
                this.Names = 'None';
            }
		}
	}
    
    private class ApAvailableAccounts{
        public List<ApAccount> UserAccounts { get; private set; }
        public List<ApAccount> SharedAccounts { get; private set; }
        
        public Boolean hasUserAccounts {
            get { return this.UserAccounts != null && this.UserAccounts.size() > 0; }            
        }
        
        public Boolean hasSharedAccounts {
            get { return this.SharedAccounts != null && this.SharedAccounts.size() > 0; }
        }
                        
        public ApAvailableAccounts(){
            this.UserAccounts = new List<ApAccount>();
            this.SharedAccounts = new List<ApAccount>();             
        }
        
        public void addUserAccount(AP_Account_gne__c accountUser){
            this.UserAccounts.add(new ApAccount(accountUser));
        }
        
        public void addSharedAccount(AP_Account_gne__c apAccount){
            this.SharedAccounts.add(new ApAccount(apAccount));
        }                
    }
    
    private class ApAccount{
        public String Id { get; private set; }
        public String Name { get; private set; }
        public String Address { get; private set; }        
                       
        public ApAccount(AP_Account_gne__c apAccount){
            this.Id = apAccount.Id;
            this.Name = apAccount.Name;
            this.Address = apAccount.Address_gne__c;            
        }
    }
    
}