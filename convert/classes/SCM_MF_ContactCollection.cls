// Created By:  Reji Joseph
// Data collection from Contact table 

public virtual class SCM_MF_ContactCollection extends SCM_MergeField{
        
    protected Contact Contacts;
    
    public SCM_MF_ContactCollection(String contactId)
    {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = true;
        className = 'SCM_MF_ContactCollection';
        key = 'ContactCollection';
        
        List<Contact> contactList = [Select c.FirstName From Contact c
                WHERE c.Id = :contactId  LIMIT 499];

        if(contactList.size() >= 1)
        {
            Contacts = contactList[0];                        
        }
        else
        {           
            Contacts = null;       
        }
    }

}