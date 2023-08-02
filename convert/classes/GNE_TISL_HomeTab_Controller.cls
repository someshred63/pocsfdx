public class GNE_TISL_HomeTab_Controller 
{ 
    public RSS.Channel RSSRoche {get; set;}      

    public List<GNE_TISL_Announcement__c> tislAnn {get; set;} 
    public List<GNE_TISL_Link__c> tislLinks {get; set;}

    public String rssQuery {get;set;}
    public String rssURL {get;set;}
    public String rssRocheURL {get;set;}

    Integer i=0,j=0;  

    public Boolean checkProfile{get;set;}  

    public List<GNE_TISL_Script> listScriptDisplay{get;set;}
    public List<GNE_TISL_Script> listContactDisplay {get;set;}
    public List<GNE_TISL_Script> listRecentDisplay {get;set;}
    public List<GNE_TISL_Script> listHelpDisplay {get;set;}
    public GNE_TISL_HomeTab_Controller() 
    {   
        try{
            List<Profile> pList = [SELECT id FROM Profile WHERE name=: 'GNE_TISL_ADMIN' and id =: UserInfo.getProfileId()];             
            if(pList.size() > 0)
            {checkProfile=true;}
            else
            {
                checkProfile=false;
            } 
                rssURL='https://clinicaltrials.gov/ct2/results/rss.xml?recr=Open&lead=Genentech&rcv_d=30&count=10';
                rssRocheURL='https://clinicaltrials.gov/ct2/results/rss.xml?recr=Open&lead=Roche&rcv_d=20&count=10';        

                listRecentDisplay = new List<GNE_TISL_Script>();            
                listScriptDisplay= new List<GNE_TISL_Script>();    
                listContactDisplay = new List<GNE_TISL_Script>();              
                listHelpDisplay = new List<GNE_TISL_Script>();
                
                getTislAnn();
                getTislLinks();

                loadScript('All Script','','GNE_TISL_Help', 3);
                loadScript('Corporate Contact Lists','','GNE_TISL_Help', 3);
                loadScript('Corporate Contact Lists','','', 3);
                loadScript('All Script','Recent','GNE_TISL_Help', 10);
        }    
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        } 
    }
       
     
    //Get Announcement
    public List<GNE_TISL_Announcement__c> getTislAnn() 
    {              
        try
        {
            tislAnn = new List<GNE_TISL_Announcement__c>();
            tislAnn = [Select Name,Announcement_Title__c,Announcement_Description__c,Announcement_Status__c,Announcement_color__c from GNE_TISL_Announcement__c where Announcement_Status__c=:true];               
            if(tislAnn.size()>0)
            {        
                return tislAnn;       
            }
            else
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoAnnouncement));    
            }
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }    
        return null;    
    }
    
    //Get Links
    public List<GNE_TISL_Link__c> getTislLinks() 
    {
        try
        {               
            tislLinks = new List<GNE_TISL_Link__c>(); 
            tislLinks = [Select id,Name,Link_Title__c, URL__c,Link_Status__c from GNE_TISL_Link__c where Link_Status__c=: true];
            if(tislLinks.size()>0)        
            {
                return tislLinks;
            }
            else
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoLink));    
            }
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }    
        return null;   
    }          
 
    //Get Image
    public String getMyimageurl() 
    {
        try
        {
            Document doc = [Select Name, Id, FolderId from Document where Document.FolderId IN(Select Id from Folder where Name = 'TISL Image')limit 1];
            string imageid = doc.id; 
            imageid = imageid.substring(0,15);
            return '/servlet/servlet.FileDownload?file=' + imageid;        
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }    
        return '';
    }


//Retrieve RSS Feed for Genentech Trials
    public RSS.channel getRSSFeed() {
        return RSS.getRSSData(rssURL);
       return null;
    }

//Retrieve RSS Feed for Roche Trials
    public RSS.channel getRSSRocheFeed() {
        return RSS.getRSSData(rssRocheURL);       
    }

//content Management
   
  
    public class GNE_TISL_Script
    {
        public String contentName { get; set; }         
        public String contentId { get; set; }         
        public List<GNE_TISL_Document> contentDocumentList{ get; set; }
        public Integer totalDocumentCount { get; set; }//this
    }
    
    public class GNE_TISL_Document
    {
        public String documentid { get; set; }
        public String documentTitle { get; set; }            
        public Boolean version{ get; set; } 
        public String documentDownloadId { get; set; }
        public List<GNE_TISL_Version> DocumentList{ get; set; }      
    }
    
    public class GNE_TISL_Version
    {
        public String versionId { get; set; }
        public String documentVersion { get; set; }
        public String commaValue { get; set;}
    }
        
public void loadScript(String rt_type,String param,String fname, Integer versionLimit)
{
    List<GNE_TISL_Script> lstTISLScript =new List<GNE_TISL_Script>(); 
    List<GNE_TISL_Version> lstVersion= new List<GNE_TISL_Version>();
    List<GNE_TISL_Document> lstDocScript= new List<GNE_TISL_Document>(); 
    List<GNE_TISL_Script_Document__c> lstDocument = new List<GNE_TISL_Script_Document__c>();
    List<GNE_TISL_Script__c> lstId= new List<GNE_TISL_Script__c>();
    List<String> listStr = new List<String>();
       
    try{
    
        integer folder=0;
        integer file=0;
        integer inst=0;         
        boolean first=false;
        Date cDate;
        
        if(param=='recent')
        {
            String startDate;
            Integer s_mon,e_mon;
            Integer s_day,e_day;
            Integer s_year,e_year;            

            e_mon=(system.Today()).month();
            e_day=(system.Today()).day();
            e_year=(system.Today()).year();
            if(e_mon==1) { s_mon=12; } else If(e_mon==2) { s_mon=11;   }  else { s_mon=e_mon-2; }
            if(e_mon==1 || e_mon==2) { s_year=e_year-1; } else { s_year=e_year; }
            s_day = e_day;
            startDate = s_mon + '-' + s_day + '-' + s_year + ' 00:00:00';
            cDate=date.valueOf(startDate);             
        }
        else
        { 
            cDate=date.valueOf('01-01-1900 00:00:00');  
        }
        
        List<RecordType> rt = [SELECT id FROM RecordType where name=: rt_type];       
        if(rt.size()>0)
        {   
            if(fname == 'GNE_TISL_Help')
            {
                lstId= [Select id from GNE_TISL_Script__c where Name !=:fname and Scripts_Status__c=true and Content_Type__c =: rt[0].id order by name];          
            }
            else
            {
                lstId= [Select id from GNE_TISL_Script__c where Name =:'GNE_TISL_Help' and Scripts_Status__c=true and Content_Type__c =: rt[0].id order by name];                          
            }      
            if(lstId.size()>0)
            {
                System.debug('----- script found ' + lstId.size()+ ' ' + rt_type+ ' ' +param+ ' ' +fname);
                List<ContentVersion> CVlist = [select ContentDocumentId from ContentVersion where RecordTypeId=:rt[0].id];
                System.debug('----- CVlist size ' + CVlist.size()); 
                if(CVlist.size()>0)
                {      
                    for(j=0;j<CVlist.size();j++)
                    {
                        listStr.add(String.valueOf(CVlist[j].ContentDocumentId));
                    }  
                    if(param=='recent')
                    {
                        lstDocument=[Select id,Name,GNE_TISL_Script__c,GNE_TISL_Script__r.name,ContentDocumentId__c,Document_Id__c,Number_Of_Version__c from GNE_TISL_Script_Document__c where GNE_TISL_Script__c in: lstId and ContentDocumentId__c in: listStr and Document_Status__c=:True and CreatedDate >= : cDate order by CreatedDate desc];                                                
                    }
                    else
                    {                       
                        lstDocument=[Select id,Name,GNE_TISL_Script__c,GNE_TISL_Script__r.name,ContentDocumentId__c,Document_Id__c,Number_Of_Version__c from GNE_TISL_Script_Document__c where GNE_TISL_Script__c in: lstId and ContentDocumentId__c in: listStr and Document_Status__c=:True and CreatedDate >= : cDate order by GNE_TISL_Script__r.name,Name,ContentDocumentId__c,Number_Of_Version__c desc];                                                                                                        
                    }
                    Integer versionCount = 0;                         
                    for(i=0;i<lstDocument.size();i++)
                    {
                        System.debug('------ versionCount ' + versionCount);
                        if((i+1)<lstDocument.size()) {
                            j=i+1;
                        } else {
                            j=i;
                            if(first==false)
                                file=-1;
                        }
                        if(((lstDocument[j].ContentDocumentId__c == lstDocument[i].ContentDocumentId__c || first==true) && (lstDocument.size()>1)) && file>=0)
                        { 
                            if(file==0)
                            { 
                                System.debug('----- first ten sam ' + versionCount + ' ' +rt_type);
                                versionCount = 0;
                                inst=i;
                                first=true;                           
                                file=1;
                            }
                            else
                            { 
                                versionCount++;
                                GNE_TISL_Version Version= new GNE_TISL_Version();                            
                                Version.versionId = lstDocument[i].Document_Id__c;
                                Version.documentVersion ='Ver' + Integer.valueOf(lstDocument[i].Number_Of_Version__c);                        
                                System.debug('----- ' + Version.documentVersion + ' XXX ' + versionCount);
                                if((i+1)<lstDocument.size()){
                                    file=i+1;
                                    folder=i+1;  
                                }else {
                                    file=i;
                                    folder=i;
                                }                      
                                if(lstDocument[file].ContentDocumentId__c!=lstDocument[i].ContentDocumentId__c || file==i)
                                {                                   
                                    file=0;
                                    Version.commaValue ='';  
                                    GNE_TISL_Document DocScript = new GNE_TISL_Document();                             
                                    DocScript.documentid=lstDocument[inst].ContentDocumentId__c;
                                    DocScript.documentTitle= lstDocument[inst].Name;                            
                                    DocScript.documentDownloadId=lstDocument[inst].Document_Id__c; 
                                    DocScript.version=true;
                                    if(versionCount <= versionLimit)                                        
                                        lstVersion.add(Version);                             
                                    DocScript.DocumentList = new List<GNE_TISL_Version>();
                                    DocScript.DocumentList.addAll(lstVersion);
                                    lstDocScript.add(DocScript);                               
                                    lstVersion.clear();
                                    first=false;
                                    if(lstDocument[folder].GNE_TISL_Script__c!=lstDocument[i].GNE_TISL_Script__c || folder==i) 
                                    {        
                                        folder=0;
                                        GNE_TISL_Script TISLScript =new GNE_TISL_Script();
                                        TISLScript.contentName=lstDocument[i].GNE_TISL_Script__r.name;   
                                        TISLScript.contentId=lstDocument[i].GNE_TISL_Script__c;                                         
                                        TISLScript.totalDocumentCount= lstDocScript.size();
                                        TISLScript.contentDocumentList = new List<GNE_TISL_Document>();
                                        TISLScript.contentDocumentList.addAll(lstDocScript);     
                                        
                                        lstTISLScript.add(TISLScript); 
                                        lstDocScript.clear();
                                        if(param=='recent' && lstTISLScript.size() >= 5)
                                            break;
                                    }
                                }
                                else
                                {       
                                    Version.commaValue =','; 
                                    if(versionCount <= versionLimit)
                                        lstVersion.add(Version);                               
                                }                   
                            }
                        } 
                        else if(lstDocument[j].ContentDocumentId__c != lstDocument[i].ContentDocumentId__c || i==0 || j==i)
                        {   
                            System.debug('----- first rozne ' + versionCount + ' ' +rt_type);
                                
                            versionCount = 0;
                            GNE_TISL_Document DocScript = new GNE_TISL_Document();                         
                            DocScript.documentid=lstDocument[i].ContentDocumentId__c;
                            DocScript.documentTitle= lstDocument[i].Name;                            
                            DocScript.documentDownloadId=lstDocument[i].Document_Id__c;   
                            DocScript.DocumentList = new List<GNE_TISL_Version>();
                            DocScript.version=false;
                            lstDocScript.add(DocScript);  
                            if((i+1)<lstDocument.size()){                           
                                folder=i+1;  
                            }else {                          
                                folder=i;
                            }       
                            if(lstDocument[folder].GNE_TISL_Script__c!=lstDocument[i].GNE_TISL_Script__c || folder==i) 
                            {          
                                folder=0;
                                GNE_TISL_Script TISLScript =new GNE_TISL_Script();
                                TISLScript.contentName=lstDocument[i].GNE_TISL_Script__r.name;       
                                TISLScript.contentId=lstDocument[i].GNE_TISL_Script__c;                                     
                                TISLScript.totalDocumentCount= lstDocScript.size();
                                TISLScript.contentDocumentList = new List<GNE_TISL_Document>();
                                TISLScript.contentDocumentList.addAll(lstDocScript);                                                                                                   
                                
                                lstTISLScript.add(TISLScript);                                                          
                                lstDocScript.clear();  
                                if(param=='recent' && lstTISLScript.size() >= 5)
                                    break;
                            }    
                        }
                    }
                    if(param=='recent') { listRecentDisplay = lstTISLScript;  }              
                    else if(rt_type=='All Script') { listScriptDisplay = lstTISLScript; }
                    else if(fname!='GNE_TISL_Help') {listHelpDisplay = lstTISLScript; }
                    else { listContactDisplay = lstTISLScript;              }
                  }      
              }
        }                   
    }    catch(Exception ex)
    {Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
    }
}

    public PageReference redirectToSearchPageForMSL() {
        PageReference pRef;
        if (!GNE_TISL_Utils.isCurrentUserMSLForTISL())
            return pRef;
        else {
            pRef = Page.GNE_TISL_Search_Page;
            pRef.setRedirect(true);
        }
        return pRef;
    }
}