public class gFRS_EmailAmendmentController{
public List<Selectoption> folderNames {set; get;}
public List<Selectoption> emailTemplates {set; get;}
public string Selected {set; get;}
public string SelectedEmail {set; get;}
public boolean showEtemp {set; get;}
public boolean disableSaveBtn {set; get;}
public emailTemplate etRec {set; get;}
public string etSubject {set; get;}
public string etBody {set; get;}
public user user {set; get;}

public gFRS_EmailAmendmentController(){
    folderNames = new List<Selectoption>();
    emailTemplates = new List<SelectOption>();
    user = new user();
    folderNames.add(new SelectOption('NONE', ' - please select a Folder -'));
    folderNames.add(new SelectOption('gFRS_Templates', 'gFRS Templates'));
    folderNames.add(new SelectOption('gFRS_RFI_Templates', 'gFRS RFI Templates')); 
    folderNames.add(new SelectOption('gFRS_Close_Request_Templates', 'gFRS Close Request Templates'));    
    emailTemplates.add(new SelectOption('None', ' - None - '));
    showEtemp = false;
    disableSaveBtn = true;
}

public void generateEmailTemplates(){
    List<emailTemplate> et = [SELECT Subject, Name, Id, Description, Body,DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :Selected];
    emailTemplates = new List<SelectOption>();
    emailTemplates.add(new SelectOption('None', ' - None - '));
    
    for(emailTemplate etemp : et){
        emailTemplates.add(new SelectOption(etemp.DeveloperName, etemp.name));
    }
    etRec = new emailTemplate();
    showEtemp = true;
}

public void generateEmailTemplateDetail(){
    etRec = [SELECT Subject, Name, Id, Description, Body, HTMLValue, DeveloperName FROM EmailTemplate WHERE DeveloperName = :SelectedEmail];
    disableSaveBtn = false;
}

public ApexPages.PageReference saveTemplate(){
    update etRec;
    etRec = new emailTemplate();
    emailTemplates = new List<SelectOption>();
    folderNames = new List<Selectoption>();
    
    /*folderNames.add(new SelectOption('NONE', ' - please select a Folder -'));
    folderNames.add(new SelectOption('gFRS_Templates', 'gFRS Templates'));
    folderNames.add(new SelectOption('gFRS_RFI_Templates', 'gFRS RFI Templates'));  */
    
    return( new ApexPages.PageReference( '/apex/gFRS_Email_Amendment').setRedirect(true));
}

}