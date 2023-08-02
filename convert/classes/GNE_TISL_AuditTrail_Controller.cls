public class GNE_TISL_AuditTrail_Controller
{
    public List<DocumentList> lstOfDocument{ get; set;}  
    public String prevOptions{get;set;}        
    public String chooseOptions{get;set;}        
    public String filterScript{get;set;}          
    public Boolean Script{get;set;} 
    public Boolean filter{get;set;} 
    
    
    public class DocumentList
    {
        public String DocName { get; set; }
        public String Doclink { get; set; }
        public String FolderName{ get; set; }
        public String Versions{ get; set; }
        public String UploadByUser{ get; set; }
        public String UploadDate{ get; set; }
        public String Status{ get; set; }
        public String modifiedByUser{ get; set; }
        public String modifiedDate{ get; set; }
    }
    
    public GNE_TISL_AuditTrail_Controller()
    {   
        try
        {   
            List<Profile> pList = [SELECT id FROM Profile WHERE name=: 'GNE_TISL_ADMIN' and id =: UserInfo.getProfileId()];                        
            //List<Profile> pList = [SELECT id FROM Profile WHERE id =: UserInfo.getProfileId()];                        
            if(pList.size() > 0)
            {
                 Script=true;
            }
            else
            {
                 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Profile));
                 Script=false;
            }  
            filter=false;        
       }
       catch(Exception ex)
       {
               Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));            
       }   
    }
    
    public PageReference goBack()
    {
        PageReference pageRef;
        pageRef = new PageReference('/apex/GNE_TISL_Edit_Home_Tab_Page');              
        pageRef.setRedirect(true);                  
        return pageRef;
    }
    
    public List<SelectOption> getScripts() 
    {
        List<SelectOption> options = new List<SelectOption>();        
        try
        {    
            options.add(new SelectOption('None','None'));
            list<RecordType> rt = [SELECT id FROM RecordType where name= :chooseOptions]; 
            if( rt.size() > 0 ) 
            {   
                List<GNE_TISL_Script__c> listScripts= [Select Id,Name From GNE_TISL_Script__c where Content_Type__c =: rt[0].id and Scripts_Status__c=:true order by Name];
                if( listScripts.size() > 0)
                {
                    for(integer i=0; i<listScripts.size(); i++)
                    {
                        options.add(new SelectOption(listScripts[i].id,listScripts[i].Name));
                    }
                }              
            }                                   
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));            
        }    
        return options;                
    }
    
    public PageReference show()
    {
        try
        {
            Script=true;
            filter=true;
            List<Id> uid=new List<Id>();
            List<GNE_TISL_Script__c> lstId = new List<GNE_TISL_Script__c>();
            lstOfDocument = new List<DocumentList>();
            
            if(prevOptions <> chooseOptions)
            {
                filterScript = 'None';
            }
            list<RecordType> rt = [SELECT id FROM RecordType where name= :chooseOptions]; 
            if(rt.size() > 0 )                
            {                
                if(filterScript == 'None' || filterScript == null)
                {
                    lstId= [Select id from GNE_TISL_Script__c where Scripts_Status__c=true and Content_Type__c =: rt[0].id order by name];          
                }
                else
                {
                    lstId= [Select id from GNE_TISL_Script__c where Scripts_Status__c=true and id =: filterScript and Content_Type__c =: rt[0].id order by name];          
                }
                if(lstId.size()>0)                
                {  
                   List<GNE_TISL_Script_Document__c> lstDocument=[Select Name,GNE_TISL_Script__r.name,Document_Id__c,Number_Of_Version__c,CreatedById,CreatedBy.Name,LastModifiedById,CreatedDate,LastModifiedDate,Document_Status__c from GNE_TISL_Script_Document__c where GNE_TISL_Script__c in: lstId order by GNE_TISL_Script__r.name,Name,Number_Of_Version__c desc]; 
                   if(lstDocument.size()>0)
                   {
                       for(GNE_TISL_Script_Document__c Obj : lstDocument)
                       {
                           DocumentList doc = new DocumentList();
                           doc.DocName = obj.Name;
                           doc.Doclink = obj.Document_Id__c;
                           doc.FolderName = obj.GNE_TISL_Script__r.name;
                           doc.Versions =  String.valueOf(obj.Number_Of_Version__c);
                           doc.UploadByUser = Obj.CreatedBy.Name;   
                           doc.UploadDate =  String.valueOf(obj.CreatedDate);
                           if(obj.Document_Status__c==true) doc.Status = 'Active';
                           else doc.Status =  'Inactive';     
                           doc.modifiedDate =  String.valueOf(obj.LastModifiedDate); 
                           lstOfDocument.add(doc);                                      
                       }                                            
                    }    
                    else
                    {
                         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'No Audit Trails Data Found'));     
                    }                     
                 }
                 prevOptions=chooseOptions;
            }           
            
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));            
        }  
        return null; 
    }           
}