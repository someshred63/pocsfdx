/**
* @author: Raheem
* @date: 06/26/2003
* @description: Handles Bulk file uploads.
**/
public class PRP_CreateDocuments_Queueable implements Queueable 
{
    public List<Object> files;
    public Set<Id> prpReqId;
    
    public PRP_CreateDocuments_Queueable(List<Object> files, Set<Id> prpReqId)
    {
        this.files = files;
        this.prpReqId = prpReqId;
    }
    
    public void execute(QueueableContext context) 
    {
        Set<Id> docIds = new Set<Id>();
        Set<Id> contentVersionIds = new Set<Id>();
        List<ContentVersion> cvs = new List<ContentVersion>();
        List<Database.SaveResult> dbSaveResults = new List<Database.SaveResult>();
        List<PRP_Request__c> prpList =[SELECT Id,Name,Product_Name__c FROM PRP_Request__c WHERE Id IN :prpReqId];
        
        if (files?.size() > 0)
        {
            for(PRP_Request__c prp : prpList){
                for (Object file : files)
                {
                    Map<String,Object> fileMap = (Map<String,Object>) file;
                    ContentVersion cv = new ContentVersion();
                    cv.VersionData = EncodingUtil.base64Decode((String)fileMap.get('base64'));
                    cv.Title = (String)fileMap.get('name');
                    cv.PathOnClient = (String)fileMap.get('name');
                    cv.SharingPrivacy = 'N';
                    cv.OwnerId= UserInfo.getUserId();
                    cv.FirstPublishLocationId  = prp.id;
                    cvs.add(cv);
                }
            }
            try 
            {
                dbSaveResults = Database.insert(cvs,true);
            } 
            catch (Exception e) 
            {
                System.debug('DB insert error: ' + e);
            }
            
            for (Database.SaveResult sr : dbSaveResults)
            {
                if (sr.isSuccess())
                {
                    contentVersionIds.add(sr.getId());
                }
                else 
                {
                    System.debug('Save Result: ' + sr);
                }
            }
        }
    }
}