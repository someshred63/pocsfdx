public class GNE_TISL_Announcement_Controller 
{  
   public GNE_TISL_Announcement__c tislAnn; 
   public List<GNE_TISL_Announcement__c> listAnn;
   public String annColor{get;set;}        
   public String annTitle {get;set;}
   public String annDescription{get;set;} 
   public Boolean checkProfile {get;set;}   
   public Boolean editMode;
    
   public GNE_TISL_Announcement_Controller() 
   {        
        try
        {   
            List<Profile> pList = [SELECT id FROM Profile WHERE name=: 'GNE_TISL_ADMIN' and id =: UserInfo.getProfileId()];             
       //     List<Profile> pList = [SELECT id FROM Profile WHERE id =: UserInfo.getProfileId()];             
            if(pList.size() > 0)
            {            
                listAnn = new List<GNE_TISL_Announcement__c>();
                listAnn = [Select Name,Announcement_Title__c,Announcement_Description__c,Announcement_Status__c,Announcement_color__c from GNE_TISL_Announcement__c where Announcement_Status__c=:true];               
                if(listAnn.size() >0)
                {
                    annTitle=listAnn[0].Announcement_Title__c;
                    annDescription=listAnn[0].Announcement_Description__c;
                    annColor=listAnn[0].Announcement_color__c;
                    editMode=false;
                } 
                else
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NoAnnouncement));
                }    
                checkProfile=true;
            }
            else
            {
                 checkProfile=false;
                 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Profile));
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
        options.add(new SelectOption('Red','Red'));
        options.add(new SelectOption('Blue','Blue'));
        options.add(new SelectOption('Green','Green'));
        options.add(new SelectOption('Yellow','Yellow'));
        options.add(new SelectOption('Orange','Orange'));
        options.add(new SelectOption('Violet','Violet'));
        options.add(new SelectOption('Gold','Gold'));
        options.add(new SelectOption('Silver','Silver'));            
        options.add(new SelectOption('Grey','Grey'));
        options.add(new SelectOption('Black','Black'));                                                                                    
        return options; 
    }
    
    public PageReference goBack()
    {        
       PageReference pageRef;
       pageRef = new PageReference('/apex/GNE_TISL_Edit_Home_Tab_Page');              
       pageRef.setRedirect(true);     
       return pageRef;
   }
    
 
    public PageReference save()
    {    
        PageReference pageRef; 
        if(annTitle == '' || annDescription == '')                              
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_Details));    
        }
        else
        {
            try
            {
                if(editMode==true)
                {     
                    if(listAnn.size() >0)
                    {       
                        for(integer i=0;listAnn.size()>i;i++)
                        {
                            listAnn[i].Announcement_Status__c=false;
                            update listAnn;
                        }    
                    }    
                    tislAnn = new GNE_TISL_Announcement__c();
                    tislAnn.Announcement_Title__c=annTitle;
                    tislAnn.Announcement_Description__c=annDescription;                    
                    tislAnn.Announcement_Status__c=true;
                    tislAnn.Announcement_color__c=annColor;                    
                    insert tislAnn;        
                    if(tislAnn.id !=null )    
                    {    
                        pageRef = new PageReference('/apex/TISL');              
                        pageRef.setRedirect(true);              
                        return pageRef;
                    }
                }
                else if(editMode==false)
                {
                    listAnn[0].Announcement_Title__c=annTitle;
                    listAnn[0].Announcement_Description__c=annDescription;
                    listAnn[0].Announcement_color__c=annColor;                    
                    update listAnn;                    
                    pageRef = new PageReference('/apex/TISL');              
                    pageRef.setRedirect(true);              
                    return pageRef;
                }
                else
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Please Click New Button for a new Announcment'));    
                }                
            }
            catch(Exception ex){
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
                    
            }                
        }                                        
        return null;
    }
    
    public void NewAnnouncement()
    {
        annTitle='';
        annDescription='';    
        annColor='Red';    
        editMode=true;        
    } 
 
}