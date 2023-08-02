public class GNE_TISL_Link_Controller 
{ 
    
    public List<GNE_TISL_Link__c> tislEditLinks;    
    public String linkId{get;set;}    
    public String linkTitle {get;set;}
    public String linkURL {get;set;}    
    public Boolean editMode{get;set;}
    public Boolean isLink{get;set;}    
    public Boolean checkProfile {get;set;}
   
    public GNE_TISL_Link_Controller() 
    {    
        try
        {   
            List<Profile> pList = [SELECT id FROM Profile WHERE name=: 'GNE_TISL_ADMIN' and id =: UserInfo.getProfileId()];             
            if(pList.size() > 0)
            {          
                isLink=false;
                checkProfile =true;
                linkId = ApexPages.currentPage().getParameters().get('id');        
                if(linkId != null)        
                {
                    isLink=true;
                    tislEditLinks = [Select Link_Title__c,URL__c from GNE_TISL_Link__c where id=:linkId and Link_Status__c=: true];
                    if(tislEditLinks.size() > 0)       
                    {
                        linkTitle = tislEditLinks[0].Link_Title__c;
                        linkURL = tislEditLinks[0].URL__c; 
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoLink));
                    }             
                }
            }
            else
            {
                checkProfile =false;
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Profile));
            }
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
    
    public PageReference removeLink()
    {        
        PageReference pageRef; 
        try
        {
            tislEditLinks = [Select id,Link_Status__c from GNE_TISL_Link__c where id=:linkId and Link_Status__c=: true];
            if(tislEditLinks.size() > 0)       
            {               
                tislEditLinks[0].Link_Status__c=false;
                update tislEditLinks;  
                pageRef = new PageReference('/apex/TISL');              
                pageRef.setRedirect(true);              
                return pageRef;            
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
    
    public PageReference saveMethod()    
    {                   
        PageReference pageRef;  
        try
        {  
            if(linkTitle == '')    
            {        
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Title)); 
                return null;
            }
            else if(linkURL == '')
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Url));  
                return null;
            }    
            else if((linkURL.left(8))!='https://' && ((linkURL.left(7))!='http://'))    
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_https)); 
                return null;
            }
            else if(linkId == null)
            {          
                GNE_TISL_Link__c tislLinks = new GNE_TISL_Link__c();
                tislLinks.Link_Title__c= linkTitle; 
                tislLinks.URL__c= linkURL;           
                insert tislLinks;        
                if(tislLinks.id !=null )    
                {    
                    pageRef = new PageReference('/apex/TISL');              
                    pageRef.setRedirect(true);              
                    return pageRef;
                }
            }    
            else
            {            
                tislEditLinks = [Select id,Link_Title__c,URL__c,Link_Status__c from GNE_TISL_Link__c where id=:linkId and Link_Status__c=: true];
                if(tislEditLinks.size() > 0)       
                {
                 /*   if(tislEditLinks[0].Link_Title__c != linkTitle) 
                    {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Title_Modify));
                        linkTitle = tislEditLinks[0].Link_Title__c;
                        return null;                        
                    }
                    else
                    {*/
						tislEditLinks[0].Link_Title__c = linkTitle;
                        tislEditLinks[0].URL__c= linkURL;
                        update tislEditLinks;
                        pageRef = new PageReference('/apex/TISL');              
                        pageRef.setRedirect(true);              
                        return pageRef;
                    //}    
                }
                else
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoLink));
                }     
            }
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }    
        return null;
    }       
}