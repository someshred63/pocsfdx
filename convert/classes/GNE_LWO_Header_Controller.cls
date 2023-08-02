public without sharing class GNE_LWO_Header_Controller 
{
    
    public Boolean alertflag{get;set;}
    public String messageCount 
    {
        get
        {
            integer numberOfEmails = 0;
            if(accountIndicator == 'BTH')
            {
                numberOfEmails = [select count() From Order_Email__c o
                        Where o.CreatedDate = LAST_N_DAYS:210 and IsRead__c=false
                        AND Account_type_gne__c != ''
                          AND o.Account__c = :accountID];
            }
            else
            {
                numberOfEmails = [select count() From Order_Email__c o
                        Where o.CreatedDate = LAST_N_DAYS:210 
                          AND o.Account__c = :accountID and IsRead__c=false
                          AND Account_type_gne__c =: accountIndicator];
            }
            return String.valueOf(numberOfEmails);
        }
        private set;
    }
    public String accountId {get; set;}
    public String accountIndicator {get; set;}
    public Boolean getShownMC(){
    	if(GNE_LWO_Controller.getFPMUser()) return false;
    	else return true;
    }
    
    public GNE_LWO_Header_Controller()
    {
        //String esbURL = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().ESB_URL__c;
        /*String esbURL = ''; 
        MAP<String,GNE_LWO_Custom_Setting__c> domains = GNE_LWO_Custom_Setting__c.getAll();
        string env = getEnvironment();
        system.debug('----env'+env);
        for(GNE_LWO_Custom_Setting__c env_domain : domains.values())
        {
            system.debug('---------------------------------'+env_domain);
            if (env.toUpperCase() == env_domain.Name)
            {
                esbURL = env_domain.ESB_URL__c;
            }
        }*/
        //system.debug('---------------------------------'+esbURL);
        
       String currentURL = Apexpages.currentPage().getUrl();
       System.debug('currentURL: ' + currentURL);
       
       if(currentURL.contains('gne_lwo_submit')  || currentURL.contains('gne_lwo_review') || currentURL.contains('GNE_LWO_PaymentAdjustment')){
         alertflag = true;
         system.debug('alertflag'+alertflag);
         }else{
         alertflag = false;             
         }
       }
    
    public static String getEnvironment()
    {
        String env ='';
        String userName = Userinfo.getUsername();
        //Tested with 'maryarc@bellsouth.net.gene.dev';
        if(userName !='')
        {
            if(userName.indexOf('gene') > 0 && userName.indexOf('gene.') <0)
                env = 'prod';
            else if(userName.indexOf('gene.') >0)
                env = userName.substring(userName.indexOf('gene.')+5, userName.length());
        }
        return env;
    }
    
    public PageReference openMessageCenter()
    { 
        PageReference pr = new PageReference('/apex/LWO_Message_Center?accountID='+accountId+'&accountIndicator='+accountIndicator);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference contactUs() 
    {
        PageReference page = new PageReference('/apex/GNE_LWO_Contact?accountID='+accountId+'&accountIndicator='+accountIndicator);
        page.setRedirect(true);
        return page;
    }

    public PageReference getHelp() 
    {
        PageReference page;
        if (accountIndicator!=null && (accountIndicator=='SAM')) {
            page = new PageReference('/apex/GNE_LWO_SampleHelp?accountID='+accountId+'&accountIndicator='+accountIndicator);
        }
        else 
        {
            page = new PageReference('/apex/GNE_LWO_Help?accountID='+accountId+'&accountIndicator='+accountIndicator); 
        } 
        page.setRedirect(true);
        return page;
    }
    
    //wilczekk: implement this
    public PageReference goHome() 
    {
        PageReference page = new PageReference('/apex/GNE_LWO_Order');
        page.getParameters().put('accountId', accountId);
        page.getParameters().put('accountIndicator', accountIndicator);
        page.setRedirect(true);
        return page;
    }
    
     public PageReference goAccountProfile()
    {
        
        PageReference page;
        if (accountIndicator!=null && (accountIndicator=='SAM')){
        	page = new PageReference('/apex/GNE_LWO_AccountProfileSample?accountId='+accountId+'&accountIndicator='+accountIndicator);
        }
        else
        {
        	page = new PageReference('/apex/GNE_LWO_AccountProfile?accountId='+accountId+'&accountIndicator='+accountIndicator);
        }
            page.setRedirect(true);
        return page;
   }
    
}