/**
 * A controller for the CMT_AttachmentUploader custom component.
 */
public class CMT_AttachmentUploaderController
{
    public Attachment attachment
    {
        get
        {
            if (attachment == null)
            {
                attachment = new Attachment();
                attachment.IsPrivate = false;
            }
            return attachment;
        }
        set;
    }
    
    public CMT_Attachment_gne__c attachmentObject
    {
        get
        {
            if (AttachmentObject == null)
            {
                AttachmentObject = new CMT_Attachment_gne__c();
            }
            return AttachmentObject;
        }
        set;
    }
    
    public String description { get; set; }
    public String allowedTypes { get; set; }
    public Integer maxAllowedAttachments { get; set; }
    public String parentType { get; set; }
    public String parentId { get; set; } 
    public String meetingId { get; set; }
    public String attachmentId { get; set; }
    public List<CMT_Attachment_gne__c> attachments { get; private set; }
    public List<SelectOption> typeOptions { get; private set; }
    public List<SelectOption> matOptions { get; private set; }
    public Boolean isMeetingAttachment { get; set; }
    public String redirectUrl { get; set; }
    public Boolean isArchived { get; set; }
    public String attachmentType
    { 
        get { return attachmentObject != null ? attachmentObject.Type_gne__c : ''; }
        set;
    }
    
    public Boolean initCollections
    {
    	get 
    	{
	    	initAttachments();
	    	
	    	if (isMeetingAttachment == true)
	    	{
	    		initMatOptions();
	    	}
	    	
	    	return false;
    	}
    }
    
    public Boolean renderAttachmentTypes
    {
        get
        {
            if (isMeetingAttachment == true)
            {
                attachmentObject.Type_gne__c = 'Image';
                
               	initMatOptions();  
                return false;
            }
        
            typeOptions = new List<SelectOption>();
            
            if (allowedTypes == null)
            {
                List<Schema.PicklistEntry> ple = CMT_Attachment_gne__c.Type_gne__c.getDescribe().getPicklistValues();
                
                for (Schema.PicklistEntry entry : ple)
                {
                    typeOptions.add(new SelectOption(entry.getLabel(), entry.getValue()));
                }   
            }
            else
            {
                List<String> allowedTypeNames = allowedTypes.split(',');
                
                for (String typeName : allowedTypeNames)
                {
                	String typePart = typeName.trim();
                	
                	String[] typeComponents = typePart.split('\\(');
                	
     				typeName = typeComponents[0];
     				
     				Map<String, Integer> countByType = countAttachmentsByType(attachments);
     				boolean skipType = false;
     				
     				System.debug('count = ' + countByType + ' att = ' + attachments + ' parent = ' + parentId);
     				
     				if (typeComponents.size() > 1)
     				{
     					Integer allowedCountForType = Integer.valueOf(typeComponents[1].replace(')', ''));
     					if (countByType.containsKey(typeName) && countByType.get(typeName) >= allowedCountForType)
     					{
     						skipType = true;
     					}
     				}           	
                	
                	if (!skipType)
                	{
                    	typeOptions.add(new SelectOption(typeName.trim(), typeName.trim()));
                	}
                }
            }
            
            // select the 1st type from the picklist
            if (attachmentObject.Type_gne__c == null || attachmentObject.Type_gne__c == '')
            {
            	System.debug('type 3 = ' + typeOptions.get(0).getValue());
                attachmentObject.Type_gne__c = typeOptions.get(0).getValue();
            }
            
            return true;
        }
        private set;
    }
    
    private static Map<String, Integer> countAttachmentsByType (List<CMT_Attachment_gne__c> attachments)
    {
    	Map<String, Integer> counter = new Map<String, Integer>();
    	
    	for (CMT_Attachment_gne__c a : attachments)
    	{
    		if (!counter.containsKey(a.Type_gne__c))
    		{
    			counter.put(a.Type_gne__c, 0);
    		}
    		
    		counter.put(a.Type_gne__c, counter.get(a.Type_gne__c) + 1);
    	}
    	
    	return counter;
    }
    
    public Boolean renderForm
    {
        get
        {
            if (attachments == null)
            {
                initAttachments();
            }
            
            if (isMeetingAttachment == true)
            {
                attachmentObject.Type_gne__c = 'Image';
            }
            
            initMatOptions();
            return (maxAllowedAttachments == null || (attachments.size() < maxAllowedAttachments)) && (isMeetingAttachment != true || !matOptions.isEmpty());
        }
        private set;
    }
    
    public Boolean renderAttachments
    {
        get
        {
            initAttachments();
            return attachments != null && !attachments.isEmpty();
        }
        private set;
    }
    
    public CMT_AttachmentUploaderController ()
    {
        initAttachments();
    }
    
    private void initMatOptions()
    {
    	if (matOptions != null)
    	{
    		return;
    	}
    	
    	matOptions = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = CMT_Attachment_gne__c.MeetingAttachmentType_gne__c.getDescribe().getPicklistValues();
        
        // make sure this meeting doesn't already have an attachment with this meeting attachment type
		List<CMT_Attachment_gne__c> existingAttachments = [SELECT MeetingAttachmentType_gne__c FROM CMT_Attachment_gne__c
															WHERE Meeting_gne__c = :meetingId];
		
		Set<String> existingAttachmentTypes = new Set<String>();
		for (CMT_Attachment_gne__c existingAttachment : existingAttachments)
		{
			existingAttachmentTypes.add(existingAttachment.MeetingAttachmentType_gne__c);
		}
        
        for (Schema.PicklistEntry entry : ple)
        {
            if (entry.getValue() != CMT_Config.DEFAULT_MEETING_ATTACHMENT_TYPE && !existingAttachmentTypes.contains(entry.getValue()))
            {
                matOptions.add(new SelectOption(entry.getLabel(), entry.getValue()));
            }
        }
    }
    
    private void initAttachments()
    {
        if (parentId != null)
        {
            attachments = [SELECT Id, Name, File_Name_gne__c, Description_gne__c, Type_gne__c, URL_gne__c  FROM CMT_Attachment_gne__c WHERE Parent_Id_gne__c = :parentId];
        }
        else
        {
            attachments = new List<CMT_Attachment_gne__c>();
        }
    }
    
    private CMT_Attachment_gne__c addIntermediaryAttachment ()
    {
        // make sure all attributes are filled
        if (parentId == null || parentId == '')
        {
            throw new CMT_Exception('Missing attribute \'parentId\' in component definition');
        }
        
        if (parentType == null || parentType == '')
        {
            throw new CMT_Exception('Missing attribute \'parentType\' in component definition');
        }
        
        if (meetingId == null || meetingId == '')
        {
            throw new CMT_Exception('Missing attribute \'meetingId\' in component definition');
        }
        
        if (isMeetingAttachment != true)
        {
            attachmentObject.MeetingAttachmentType_gne__c = CMT_Config.DEFAULT_MEETING_ATTACHMENT_TYPE;
        }
        else
        {
        	// make sure this meeting doesn't already have an attachment with this meeting attachment type
        	Integer aCount = [SELECT count() FROM CMT_Attachment_gne__c
        					WHERE Meeting_gne__c = :meetingId AND MeetingAttachmentType_gne__c = :attachmentObject.MeetingAttachmentType_gne__c];
        	if (aCount > 0)
        	{
        		throw new CMT_Exception('Attachment with type \'' + attachmentObject.MeetingAttachmentType_gne__c + '\' already exists for this meeting');
        	}
        
        	System.debug('test2');
        }
        
        // create new CMT_Attachment_gne__c object
        attachmentObject.Parent_Type_gne__c = parentType;
        attachmentObject.Parent_Id_gne__c = parentId;
        attachmentObject.Meeting_gne__c = meetingId;
        
        if (attachment != null && (attachmentObject.File_Name_gne__c==null || attachmentObject.File_Name_gne__c==''))
        {
            attachmentObject.File_Name_gne__c = attachment.name;
        }
        
        insert AttachmentObject;
        
        if (attachmentObject.Id == null)
        {
            throw new CMT_Exception('Adding attachment standard object failed');
        }
        
        return AttachmentObject;
    }
    
    public PageReference changeAttachmentType()
    {
        return null;
    }
    
    public PageReference deleteAttachment()
    {
        if (attachmentId != null)
        {
            CMT_MiscUtils.deleteAttachment(attachmentId);
        }
        
        if (redirectUrl == null || redirectUrl == '')
        {
        	// redirect to the view page of the parent object
        	redirectUrl = parentId;
        }
        
        PageReference pageRef = new PageReference('/' + redirectUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
   
    public PageReference upload()
    {   
        // add the intermediary attachment object
        try
        {
            attachmentObject = addIntermediaryAttachment();
        }
        catch (CMT_Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading attachment: ' + e.getMessage()));
            attachmentObject = null;
            return null;
        }
        
        if (attachmentObject.Type_gne__c == 'Image' || attachmentObject.Type_gne__c == 'Document')
        {
        	if (Attachment.Body == null)
        	{
        		// delete the already added intermediary attachment
        		delete attachmentObject;
        		AttachmentObject = null;
        		
        		// add error message
        		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please choose a file to upload'));
        		// exit upload
        		return null;
        	}
            addSystemAttachment();
        }
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Attachment uploaded successfully'));
        
        initAttachments();
        attachmentObject = null;
        
        if (redirectUrl == null || redirectUrl == '')
        {
        	// redirect to the view page of the parent object
        	redirectUrl = parentId;
        }
        
        PageReference pageRef = new PageReference('/' + redirectUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private void addSystemAttachment()
    {
        if (Attachment.Body == null)
        {
            // rollback the added intermediary object
            delete AttachmentObject;
            
            // add error message
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Attachment body not set'));
            throw new CMT_Exception('Body is empty');
        }
        
        if (Attachment.Name == null)
        {
            // rollback the added intermediary object
            delete AttachmentObject;
            
            // add error message
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Attachment name not set'));
            throw new CMT_Exception('Name is empty');
        }
        
        Attachment.OwnerId = UserInfo.getUserId();
        // the attachment is attached to the intermediary object
        Attachment.ParentId = AttachmentObject.Id;
        Attachment.IsPrivate = false;
 
        try
        {
            insert attachment;
        }
        catch (DMLException e)
        {
            // rollback the added intermediary object
            delete AttachmentObject;
            
            // add error message
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading attachment: ' + e.getMessage()));
            throw new CMT_Exception('Error adding system attachment: ' + e.getMessage());
        }
        finally
        {
            Attachment = new Attachment(); 
        }
    }
}