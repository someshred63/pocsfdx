public class SRW_PrescriberListController {
    public List<SRW_Prscr_or_Org_Location__c> prescribers;
    public Id selectedPrescriber {get; set;}
    public SRW_Prscr_or_Org_Location__c locationToDelete {get; set;}
    public SRW_Trading_Partner_Profile__c currentTradingPartner {get; set;}

    public String selectedFileFormat {get;set;}

    public Boolean isFOIM {get; set;}
    public Boolean noAccess {get; set;}

    public SRW_PrescriberListController(){
        List<Profile> FOIMs = [SELECT Name, Id FROM Profile WHERE (Id = :UserInfo.getProfileId() AND Name = 'GNE-GST-Partner-External')];
        isFOIM = FOIMs.isEmpty();
        
        User currentUser = [SELECT id, ContactId FROM User WHERE id = :UserInfo.getUserId()];
        if(!isFOIM)
            currentTradingPartner = [SELECT id FROM SRW_Trading_Partner_Profile__c WHERE Contact_gne__c = :currentUser.ContactId Limit 1];
        else {
            List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: currentUser.Id]; 
            if(!mimicData.isEmpty()) { 
                currentTradingPartner = [SELECT id FROM SRW_Trading_Partner_Profile__c WHERE Id =: mimicData.get(0).SRW_Trading_Partner_Profile_gne__c Limit 1];    
            }
        }
        System.debug('--- currentTradingPartner ' + currentTradingPartner);
        if(currentTradingPartner == null) 
            noAccess = true;
        else 
            noAccess = false;   

        locationToDelete = new SRW_Prscr_or_Org_Location__c();
    }

    public List<SRW_Prscr_or_Org_Location__c> getPrescribers(){
        return [SELECT id, Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,  Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,  Prescriber_or_Organization_gne__r.Organization_Name_gne__c, Unique_Identifier_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c, Street_Address_1_gne__c, Street_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Location_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE Prescriber_or_Organization_gne__r.Trading_Partner_gne__c = :currentTradingPartner.id AND isActive_gne__c = true ORDER BY Unique_Identifier_gne__c Asc];
    }

    public void prepareLocToDelete(){
        locationToDelete = [SELECT id, Unique_Identifier_gne__c, isActive_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE id = :selectedPrescriber LIMIT 1];
        System.debug(locationToDelete.Unique_Identifier_gne__c);
    }
    public void deletePrescriber(){
        locationToDelete.isActive_gne__c = false;
        try {
                update locationToDelete;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Customer deleted'));
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error'));
                system.debug(e.getMessage());
            }
    }
    public PageReference editPrescriber(){
        SRW_Prscr_or_Org_Location__c tempLoc = [SELECT id, Prescriber_or_Organization_gne__r.id, Prescriber_or_Organization_gne__r.Organization_Name_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE id = :selectedPrescriber];
        PageReference pr = new PageReference(Page.SRW_AddNewPrescriberOrOrganization.getURL());
        if(!String.isBlank(tempLoc.Prescriber_or_Organization_gne__r.Organization_Name_gne__c)){
            pr.getParameters().put('type', 'Organization');
        } else {
            pr.getParameters().put('type', 'Prescriber');
        }
        pr.getParameters().put('id', (String) tempLoc.Prescriber_or_Organization_gne__r.id);
        pr.setRedirect(true);
        return pr;
    }
    public List<SelectOption> getFileFormatOptions() {
        List<SelectOption> fileFormats = new List<SelectOption>();
        fileFormats.add(new Selectoption('pdf','pdf'));
        fileFormats.add(new Selectoption('csv','csv'));
        fileFormats.add(new Selectoption('xls','xls'));
        return fileFormats;
    }
    public PageReference exportDataToFile(){
        PageReference newPageRef ;
        if(selectedFileFormat == 'xls') {
            newPageRef = Page.SRW_Export_Excel;
            newPageRef.getParameters().put('mode', 'Prescribers');
            newPageRef.getParameters().put('csv', 'no');
            newPageRef.setRedirect(false);
          } else if (selectedFileFormat == 'pdf') {
            newPageRef = Page.SRW_Export_Pdf;
            newPageRef.getParameters().put('mode', 'Prescribers');
            newPageRef.getParameters().put('csv', 'no');
            newPageRef.setRedirect(true);
          } else {
            newPageRef = Page.SRW_Export_CSV;
            newPageRef.getParameters().put('mode', 'Prescribers');
            newPageRef.getParameters().put('csv', 'yes');
            newPageRef.setRedirect(true);
          }
        return newPageRef;
      }

    public PageReference printRedirect() {

        PageReference pr;
        if(isFOIM) 
            pr = new PageReference('/apex/SRW_Print_Preview');
        
        else 
            pr = new PageReference('/partner/SRW_Print_Preview');
        pr.getParameters().put('mode','Prescribers');
        pr.getParameters().put('csv','no');

        pr.setRedirect(true);
        return pr;
    }

}