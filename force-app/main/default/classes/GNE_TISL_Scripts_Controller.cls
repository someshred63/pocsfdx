public class GNE_TISL_Scripts_Controller
{ 
    public String docTitle{get;set;}
    public String docId{get;set;}
    public String chooseOptions{get;set;}
    public String contentFolder{get;set;}
    public String contentScript{get;set;}
    public String Helpcontent{get;set;}
    public String changeReason{get;set;}    
    public String ScriptFolder{get;set;} 
    public ContentVersion file { get; set;} 
    public Boolean Script{get;set;}
    public Boolean Script1{get;set;} 
    public Boolean Document1{get;set;} 
    public Boolean Script2{get;set;} 
    public Boolean Script3{get;set;}
    public Boolean Document2{get;set;} 
    public Boolean Document3{get;set;} 
    public Boolean Document4{get;set;}          
    public Boolean Document5{get;set;}              
    public GNE_TISL_Script__c newScripts { get; set;}    
    public GNE_TISL_Script_Document__c newDocument { get; set;}    
    public List<GNE_TISL_Script_Document__c> lstDoc{ get; set;}
    public List<GNE_TISL_Script__c> lstScript{ get; set;}    
    public String pagename{ get; set;}
	
    integer i,count;
    
    public GNE_TISL_Scripts_Controller()
    {
        try{   
            List<Profile> pList = [SELECT id FROM Profile WHERE name=: 'GNE_TISL_ADMIN' and id =: UserInfo.getProfileId()];             
       //     List<Profile> pList = [SELECT id FROM Profile WHERE  id =: UserInfo.getProfileId()];             
            if(pList.size() > 0)
            {
                file = new ContentVersion();            
                changeReason='Version of Document';
                docId= ApexPages.currentPage().getParameters().get('docId');
                Script=Boolean.valueof(ApexPages.currentPage().getParameters().get('Script'));            
                if(docId!='' && docId!='C' && docId!='H')
                {
                    if(((ApexPages.currentPage().getParameters().get('Script'))=='DS') || ((ApexPages.currentPage().getParameters().get('Script'))=='NS')) pagename='Scripts';					
                    if(((ApexPages.currentPage().getParameters().get('Script'))=='DC') || ((ApexPages.currentPage().getParameters().get('Script'))=='NC'))  pagename='Corporate Contact List';                  					
					lstDoc=[select Name,GNE_TISL_Script__c,Number_Of_Version__c from GNE_TISL_Script_Document__c where ContentDocumentId__c=:docId and Document_Status__c=:true order by Number_Of_Version__c desc];
                    if(lstDoc.size() > 0)
                    {
                        docTitle=lstDoc[0].Name;
                        contentScript=lstDoc[0].GNE_TISL_Script__c;
                        count=Integer.valueOf(lstDoc[0].Number_Of_Version__c);
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoDocument));    
                    }
                    Document2=True;  
					if(((ApexPages.currentPage().getParameters().get('Script'))=='DS') || ((ApexPages.currentPage().getParameters().get('Script'))=='DC')){Document3=false;}
                    else{Document3=true;}                                
                    Document1=false; 
                    Document5=false; 
                }
                else if(docId=='C')
                {
					pagename='Corporate Contact List';
					Document1=true;
                    Document2=false;
                    Document3=true; 
                    Document4=false; 
                    Document5=false;                
                }                
                else if(docId=='H')
                {
					pagename='Help';
                    Document1=false;
                    Document2=false;
                    Document3=true; 
                    Document4=false; 
                    if(((ApexPages.currentPage().getParameters().get('Script'))=='DS') || ((ApexPages.currentPage().getParameters().get('Script'))=='DC'))
                    {
                        Document5=false;
                        List<GNE_TISL_Script__c> listScripts= [Select Id,Name,Number_Of_Documents__c From GNE_TISL_Script__c where Name='GNE_TISL_Help' and Scripts_Status__c=:true order by Name];
                        if(listScripts.size()>0)
                        {
                            if(listScripts[0].Number_Of_Documents__c > 0)                                                                                
                            Script3=true;
                            else
                            {
                                Script3=False;
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'No Help File Found'));
                            }    
                        }    
                    }
                    else{Document5=true;Script3=False;}                                
                }                
                else if(docId == '' && Script==True)
                {
					pagename='Scripts';
                    Document2=false;
                    Document3=True;
                    Document5=false; 
                }
                Script1=false;
                Script2=false;
                if(docId!='H'){Script3=False;}
             }             
             else
             {
                 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Profile));
                 Script1=false;
                 Script2=false;
                 Script3=false;
                 Document1=false;
                 Document2=false;
                 Document5=false; 
             }   
            }
           catch(Exception ex)
           {
               Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
           }         
    }
    
    public List<SelectOption> getItems() 
    {
        List<SelectOption> options = new List<SelectOption>();
        try
        {
            if(docId!='C')
            {
                list<RecordType> rt = [SELECT id FROM RecordType where name= :'All Script']; 
                if( rt.size() > 0 )
                {
                    List<ContentWorkspace> list_contentWorkSpace = [Select Id,Name,DefaultRecordTypeId,Description From ContentWorkspace where                                                                                       
                                                                                                DefaultRecordTypeId =: rt[0].id ];
                    if( list_contentWorkSpace.size() > 0)
                    {
                        for(i=0; i<list_contentWorkSpace.size(); i++)
                        {
                            options.add(new SelectOption(list_contentWorkSpace[i].id,list_contentWorkSpace[i].Name));
                        }    
                        return options;
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Content_Header));//GNE_TISL_Content_Header
                        return options;
                    }
                }
                else
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Content_Type));//GNE_TISL_Content_Type
                    return options;
                }
            }
            else
            {
                list<RecordType> rt = [SELECT id FROM RecordType where name= :'Corporate Contact Lists']; 
                if( rt.size() > 0 )
                {
                    List<ContentWorkspace> list_contentWorkSpace = [Select Id,Name,DefaultRecordTypeId,Description From ContentWorkspace where                                                                                       
                                                                                                DefaultRecordTypeId =: rt[0].id ];
                    if( list_contentWorkSpace.size() > 0)
                    {
                        for(i=0; i<list_contentWorkSpace.size(); i++)
                        {
                            options.add(new SelectOption(list_contentWorkSpace[i].id,list_contentWorkSpace[i].Name));
                        }    
                        return options;
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Content_Header));//GNE_TISL_Content_Header
                        return options;
                    }
                }
                else
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Content_Type));//GNE_TISL_Content_Type
                    return options;
                }
            }
        }    
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
            return options;
        }         
    }        
    public List<SelectOption> gethelps()
    {
        List<SelectOption> options = new List<SelectOption>();    
        List<GNE_TISL_Script__c> listScripts= [Select Id,Name From GNE_TISL_Script__c where Name='GNE_TISL_Help' and Scripts_Status__c=:true order by Name];
        if(listScripts.size() > 0)
        {
            List<GNE_TISL_Script_Document__c> lstDocument=[Select Id,Name From GNE_TISL_Script_Document__c where GNE_TISL_Script__c =:listScripts[0].id and Document_Status__c=:True order by Name];           
            for(i=0; i<lstDocument.size(); i++)
            { 
                    options.add(new SelectOption(lstDocument[i].id,lstDocument[i].Name));    
            }             
        }       
        return options;
    }
    
    public List<SelectOption> getScripts() 
    {
        List<SelectOption> options = new List<SelectOption>();        
        try
        {    
            list<RecordType> rt = [SELECT id FROM RecordType where name= :'All Script']; 
            if( rt.size() > 0 ) 
            {   
                List<GNE_TISL_Script__c> listScripts= [Select Id,Name From GNE_TISL_Script__c where Content_Type__c =: rt[0].id and Scripts_Status__c=:true order by Name];
                if( listScripts.size() > 0)
                {
                    for(i=0; i<listScripts.size(); i++)
                    {
                        options.add(new SelectOption(listScripts[i].id,listScripts[i].Name));
                    }    
                    return options;
                }
                else
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Content_Script));//GNE_TISL_Content_Script
                    return options;
                }
            }
            else
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Content_Type));//GNE_TISL_Content_Type
                return options;
            }            
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
            return options;
        }                    
    }
    
    public PageReference goBack()
    {
        PageReference pageRef;
        pageRef = new PageReference('/apex/GNE_TISL_Edit_Home_Tab_Page');              
        pageRef.setRedirect(true);                  
        return pageRef;
    }
    
    public PageReference saveMethod()
    {
        try
        {
            PageReference pageRef;
            if(ScriptFolder == '' )
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ScriptFolder));    
            }
            else
            {    
                List<GNE_TISL_Script__c> testGTS = [Select id from GNE_TISL_Script__c where Name=: ScriptFolder and Scripts_Status__c=:True];
                if(testGTS.size()>0)
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Duplicate Script Name, Script already exist'));//GNE_TISL_Content_Uploaded
                    Script1=False;
                    Document1=True;
                    Document4=True;
                    contentScript=ScriptFolder;
                }
                else                
                {
                    list<RecordType> rt = [SELECT id FROM RecordType where name= :'All Script']; 
                    if( rt.size() > 0 )
                    {
                        List<ContentWorkspace> list_contentWorkSpace = [Select Id From ContentWorkspace where Name =:'All Scripts' and DefaultRecordTypeId =: rt[0].id ];
                        if( list_contentWorkSpace.size() > 0)
                        {
                            newScripts = new GNE_TISL_Script__c();
                            newScripts.Name=ScriptFolder;
                            newScripts.Content_Type__c = rt[0].id;
                            newScripts.Scripts_Folder_Id__c=list_contentWorkSpace[0].id;
                            newScripts.Scripts_Status__c=true;
                            insert newScripts;
                            if(newScripts.id != null)
                            {      
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Content_Uploaded));//GNE_TISL_Content_Uploaded
                                Script1=False;
                                Document1=True;
                                Document4=True;
                            }                
                            else
                            {
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ContentScript_NotCreated )); // GNE_TISL_ContentScript_NotCreated             
                            }    
                        }
                        else
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoContent_Header ));  // GNE_TISL_NoContent_Header             
                        }
                    }
                    else
                    {    
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoContent_Type));  //GNE_TISL_NoContent_Header  
                    }   
                } 
            }    
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }   
        return null;
    }
    
       
    public PageReference uploadVersionMethod()
    {
        try{
            PageReference pageRef;
            if(changeReason == '')
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_File_Reason));
            }
            else if(file== null || file.versionData == null )
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_File_Reason));    
            }
            else
            {   
                List<GNE_TISL_Script_Document__c> testGTSD = [Select Id from GNE_TISL_Script_Document__c where name=:docTitle and Number_Of_Version__c=:(count+1) and Document_Status__c=:True and GNE_TISL_Script__c=:contentScript];
                if(testGTSD.size()>0)
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Version already Created')); 
                     return null;    
                }
                else
                {            
                    file.ContentDocumentId=docid;
                    file.ReasonForChange=changeReason;
                    if((file.versionData).size()<=0)
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Incorrect File Size' ));
                        return null;    
                    }
                    else { insert file;    }
                    if(file.id != null)
                    {
                        newDocument= new GNE_TISL_Script_Document__c();
                        newDocument.Name=docTitle;                
                        newDocument.ContentDocumentId__c=docid;
                        newDocument.Document_Id__c=file.id;
                        newDocument.Document_Status__c=True;            
                        newDocument.GNE_TISL_Script__c=contentScript;
                        newDocument.Number_Of_Version__c=count + 1;   
                        insert newDocument;               
						lstDoc=[select Name from GNE_TISL_Script_Document__c where ContentDocumentId__c=:docId and Document_Status__c=:true order by Number_Of_Version__c desc];
                        for(i=0;i<lstDoc.size();i++)
                        {
                            lstDoc[i].Name =docTitle;
                            Update lstDoc;
                        }      
                        pageRef = new PageReference('/apex/TISL');              
                        pageRef.setRedirect(true);                  
                        return pageRef;    
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Document_Uploaded ));//GNE_TISL_Document_Uploaded            
                    }
                }       
            }
           } 
            catch(Exception ex)
           {
               Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
           }  
        return null;
    }
        
    public PageReference uploadFileMethod()
    {
        try
        {
            PageReference pageRef;
            if(docTitle == '')
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_File));
            }
            else if(file== null || file.versionData == null || contentFolder=='' || contentScript== '')
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_File));
            }
            else
            {      
                List<GNE_TISL_Script_Document__c> testGTSD = [Select Id from GNE_TISL_Script_Document__c where name=:docTitle and Document_Status__c=:True and GNE_TISL_Script__c=:contentScript];
                if(testGTSD.size()>0)
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Duplicate Document Name in a Script folder')); 
                     return null;    
                }
                else
                {      
                    list<RecordType> rt = [SELECT id FROM RecordType where name= :'All Script'];  
                    if( rt.size() > 0 )
                    {        
                        file.title = docTitle;        
                        file.RecordTypeId=rt[0].id;
                        file.FirstPublishLocationId=contentFolder;
                        if((file.versionData).size()<=0)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Incorrect File Size' ));
                            return null;    
                        }
                        else  {    insert file;    }
                        if(file.id != null)
                        {
                            newDocument= new GNE_TISL_Script_Document__c();
                            newDocument.Name=docTitle;
                            List<ContentVersion> lstversion = [Select Id,ContentDocumentId from ContentVersion where Id= :file.id];
                            if(lstversion.size()>0) newDocument.ContentDocumentId__c=lstversion[0].ContentDocumentId;
                            newDocument.Document_Id__c=file.id;
                            newDocument.Document_Status__c=True;
                            newDocument.GNE_TISL_Script__c=contentScript;
                            newDocument.Number_Of_Version__c=1;   
                            insert newDocument;             
                            pageRef = new PageReference('/apex/TISL');              
                            pageRef.setRedirect(true);                  
                            return pageRef;
                        }    
                        else
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Document_Uploaded));
                        }
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoContent_Type));            
                    }
                }        
            }    
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }  
        return null; 
    }
    
    public PageReference uploadHelpMethod()
    {
        try
        {
            PageReference pageRef;
            if(docTitle == '')
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_File));
            }    
            else if(file== null || file.versionData == null)
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_File));
            }
            else
            {            
                List<GNE_TISL_Script_Document__c> testGTSD = [Select Id from GNE_TISL_Script_Document__c where name=:docTitle and Document_Status__c=:True and GNE_TISL_Script__r.name=:'GNE_TISL_Help'];
                if(testGTSD.size()>0)
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Duplicate Document Name in a Script folder'));
					return null; 
                }
                else
                {   
                    list<RecordType> rt = [SELECT id FROM RecordType where name= :'Corporate Contact Lists'];  
                    if( rt.size() > 0 )
                    {                       
                        List<ContentWorkspace> list_contentWorkSpace = [Select Id,Name,DefaultRecordTypeId,Description From ContentWorkspace where                                                                                       
                                                                                                    DefaultRecordTypeId =: rt[0].id ];
                        if( list_contentWorkSpace.size() > 0)
                        {
                            file.title = docTitle;  
                            file.RecordTypeId=rt[0].id;
                            file.FirstPublishLocationId=list_contentWorkSpace[0].id;                    
                            if((file.versionData).size()<=0)
                            {
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Incorrect File Size' ));
                                return null;    
                            }
                            else { insert file;    }
                            if(file.id != null)
                            {
                                newDocument= new GNE_TISL_Script_Document__c();
                                newDocument.Name=docTitle;
                                List<ContentVersion> lstversion = [Select Id,ContentDocumentId from ContentVersion where Id= :file.id];
                                if(lstversion.size()>0) newDocument.ContentDocumentId__c=lstversion[0].ContentDocumentId;
                                newDocument.Document_Id__c=file.id;
                                newDocument.Document_Status__c=True;
                                List<GNE_TISL_Script__c> gtScript = [select Id from GNE_TISL_Script__c where Name =:'GNE_TISL_Help' and Content_Type__c = :rt[0].id and Scripts_Status__c =:true];
                                If(gtScript.size()>0)
                                {
                                    newDocument.GNE_TISL_Script__c=gtScript[0].id;
                                }    
                                else
                                {                          
                                    newScripts = new GNE_TISL_Script__c();
                                    newScripts.Name='GNE_TISL_Help';
                                    newScripts.Content_Type__c = rt[0].id;
                                    newScripts.Scripts_Folder_Id__c=list_contentWorkSpace[0].id;
                                    newScripts.Scripts_Status__c=true;
                                    insert newScripts; 
                                    if(newScripts.id != null)
                                    newDocument.GNE_TISL_Script__c=newScripts.id;                     
                                }
                                newDocument.Number_Of_Version__c=1;   
                                insert newDocument;             
                                pageRef = new PageReference('/apex/TISL');              
                                pageRef.setRedirect(true);                  
                                return pageRef;
                            }    
                            else
                            {
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Document_Uploaded));
                            }
                        }
                        else
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Content_Header));//GNE_TISL_Content_Header                       
                        }   
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoContent_Type));            
                    }
                }
            }    
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }  
        return null; 
    }
    
    public PageReference uploadCCList()
    {
        try
        {
            PageReference pageRef;
            if(docTitle == '')
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_File));
            }    
            else if(file== null || file.versionData == null || contentFolder=='')
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_File));
            }
            else
            {
                List<GNE_TISL_Script_Document__c> testGTSD = [Select Id from GNE_TISL_Script_Document__c where name=:docTitle and Document_Status__c=:True and GNE_TISL_Script__r.name=:'Corporate Contact List'];
                if(testGTSD.size()>0)
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Duplicate Document Name in a Script folder'));    
					return null; 
                }
                else
                {            
                    list<RecordType> rt = [SELECT id FROM RecordType where name= :'Corporate Contact Lists'];  
                    if( rt.size() > 0 )
                    {        
                        file.title = docTitle;  
                        file.RecordTypeId=rt[0].id;
                        file.FirstPublishLocationId=contentFolder;                    
                        if((file.versionData).size()<=0)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Incorrect File Size' ));
                            return null;    
                        }
                        else { insert file;    }
                        if(file.id != null)
                        {
                            newDocument= new GNE_TISL_Script_Document__c();
                            newDocument.Name=docTitle;
                            List<ContentVersion> lstversion = [Select Id,ContentDocumentId from ContentVersion where Id= :file.id];
                            if(lstversion.size()>0) newDocument.ContentDocumentId__c=lstversion[0].ContentDocumentId;
                            newDocument.Document_Id__c=file.id;
                            newDocument.Document_Status__c=True;
                            List<GNE_TISL_Script__c> gtScript = [select Id from GNE_TISL_Script__c where Name =:'Corporate Contact List' and Content_Type__c = :rt[0].id and Scripts_Status__c =:true];
                            If(gtScript.size()>0)
                            {
                                newDocument.GNE_TISL_Script__c=gtScript[0].id;
                            }    
                            else
                            {
                                List<ContentWorkspace> list_contentWorkSpace = [Select Id From ContentWorkspace where Name =:'Corporate Contact List' and DefaultRecordTypeId =: rt[0].id ];
                                newScripts = new GNE_TISL_Script__c();
                                newScripts.Name='Corporate Contact List';
                                newScripts.Content_Type__c = rt[0].id;
                                newScripts.Scripts_Folder_Id__c=list_contentWorkSpace[0].id;
                                newScripts.Scripts_Status__c=true;
                                insert newScripts; 
                                if(newScripts.id != null)
                                newDocument.GNE_TISL_Script__c=newScripts.id;                     
                            }
                            newDocument.Number_Of_Version__c=1;   
                            insert newDocument;             
                            pageRef = new PageReference('/apex/TISL');              
                            pageRef.setRedirect(true);                  
                            return pageRef;
                        }    
                        else
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Document_Uploaded));
                        }
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoContent_Type));            
                    }
                }        
            }    
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }  
        return null; 
    }
    
    
    public PageReference show()
    {
        try{
            if(chooseOptions == 'New Script')
            {
                Script=False;
                Script1=True;
                Script2=False;
                Document1=False;
                Document2=False;
                Document5=false; 
                }
            else if(chooseOptions == 'New Document')
            {
                Script=False;
                Script1=False;
                Script2=False;
                Document1=True;
                Document2=False;
                Document4=True;
                Document5=false; 
                }
            else if(chooseOptions == 'Delete Script')
            {
                Script=False;
                Script1=False;
                Script2=True;
                Document1=False;
                Document2=False;
                Document5=false; 
                }
           }
           catch(Exception ex)
           {
               Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
           }  
        return null;
    }
    
    public PageReference deleteFileMethod()
    {
        try
        {
            PageReference pageRef;
            lstDoc = [Select Document_Status__c from GNE_TISL_Script_Document__c where ContentDocumentId__c=:docId and Document_Status__c=:true];
            for(i=0;i<lstDoc.size();i++)
            {
                lstDoc[i].Document_Status__c=false;
                update lstDoc;                
            }    
            pageRef = new PageReference('/apex/GNE_TISL_Edit_Home_Tab_Page');              
            pageRef.setRedirect(true);                  
            return pageRef;            
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }  
        return null;    
    }
    public PageReference DeleteHelpMethod()
    {
        try
        {
            PageReference pageRef;
            lstDoc = [Select Document_Status__c from GNE_TISL_Script_Document__c where id=:Helpcontent and Document_Status__c=:true];
            for(i=0;i<lstDoc.size();i++)
            {
                lstDoc[i].Document_Status__c=false;
                update lstDoc;                
            }    
            pageRef = new PageReference('/apex/GNE_TISL_Edit_Home_Tab_Page');              
            pageRef.setRedirect(true);                  
            return pageRef;            
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }  
        return null;
    }
    
    public PageReference DeleteMethod()
    {
        try
        {
            PageReference pageRef;
            lstScript = [Select Scripts_Status__c from GNE_TISL_Script__c where id=:contentScript and Scripts_Status__c=:true];
            if(lstScript.size()>0)
            {
                lstScript[0].Scripts_Status__c=false;
                update lstScript;                
            }    
            pageRef = new PageReference('/apex/GNE_TISL_Edit_Home_Tab_Page');              
            pageRef.setRedirect(true);                  
            return pageRef;            
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }  
        return null;
    }

}