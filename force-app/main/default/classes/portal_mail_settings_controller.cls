public class portal_mail_settings_controller 
{
    public user usr;
    public contact con;
    public string email_alerts;
    public string feature_alerts;
    
    public portal_mail_settings_controller()
    {
        try
        {
            string userid = userinfo.getuserid();
            this.usr = [select external_id_gne__c, contactid, contact.Receive_email_alerts_for_new_feature_gne__c,
                    Contact.Receive_emails_Patient_Cases_gne__c from user where id =:userid];
           if(usr.contactid == null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No Contact associated with this User. Please login with a Portal user to update Email alerts settings. '));
        }
        catch(Exception e) 
        {
            ApexPages.addMessages(e);
        }
    }
    public user getUserDet()
    {
        return usr;
    }    
    
    public List<SelectOption> getReceiveemailalerts()      
    {              
    List<SelectOption> optionList = new List<SelectOption>(); 
    if(usr.contactid !=null)
    { 
        if(usr.contact.Receive_emails_Patient_Cases_gne__c =='Yes' )
        {
            optionList.add(new SelectOption('Yes','Yes'));
            optionList.add(new SelectOption('No','No'));
         }
         else if(usr.contact.Receive_emails_Patient_Cases_gne__c ==null || usr.contact.Receive_emails_Patient_Cases_gne__c =='No' )
         {
             optionList.add(new SelectOption('No','No'));
             optionList.add(new SelectOption('Yes','Yes'));
         }
    }
      
    return optionList;      
    } 
    public void setemail_alerts(string s)      
    {      
        email_alerts  = s;
    }
    public void setfeature_alerts(string s)      
    {         
    this.feature_alerts  = s;
    }
    public List<SelectOption> getReceiveemailalertsfeatures()      
    {              
        List<SelectOption> optionList = new List<SelectOption>();      
        if(usr.contactid !=null)
        { 
            if(usr.contact.Receive_email_alerts_for_new_feature_gne__c =='Yes')
            {
                optionList.add(new SelectOption('Yes','Yes'));
                optionList.add(new SelectOption('No','No'));
             }
             else if(usr.contact.Receive_email_alerts_for_new_feature_gne__c ==null || usr.contact.Receive_email_alerts_for_new_feature_gne__c =='No')
             {
                 optionList.add(new SelectOption('No','No'));
                 optionList.add(new SelectOption('Yes','Yes'));
             }
        }
        return optionList;      
    } 
    public string getemail_alerts()      
    {              
        return email_alerts;      
    } 
    public string getfeature_alerts()      
    {              
        return feature_alerts;      
    } 
    public pagereference savecontact()
    {
        try
        {
            system.debug(email_alerts +'-'+feature_alerts);            
            Account a =[select Receive_email_alerts_for_new_feature_gne__pc, Receive_emails_Patient_Cases_gne__pc 
                        from account where personcontactid =: usr.contactid limit 1];
            if(email_alerts !=NULL)
            //a.Receive_emails_Patient_Cases_gne__pc = usr.contact.Receive_emails_Patient_Cases_gne__c;
            a.Receive_emails_Patient_Cases_gne__pc = email_alerts;

            if(feature_alerts !=NULL)
            //a.Receive_email_alerts_for_new_feature_gne__pc = usr.contact.Receive_email_alerts_for_new_feature_gne__c;
            a.Receive_email_alerts_for_new_feature_gne__pc = feature_alerts;

                        
            update(a);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Settings Updated successfully'));
            return null;
        }
        catch(DMLException e) 
        {
            ApexPages.addMessages(e);
            return null;
        }
        catch(Exception e) 
        {
            ApexPages.addMessages(e);
            return null;
        }
        
    }
        

}