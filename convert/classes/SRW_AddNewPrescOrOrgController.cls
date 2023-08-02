public with sharing class SRW_AddNewPrescOrOrgController {
    public PrescriberOrOrgWrapper prescriberOrOrgData {get; set;}
    public List<PrescriberLocationWrapper> prescriberLocations {get; set;}
    public String prescOrOrg {get; set;}
    public String returnPage {get; set;}
    public String editOrNew {get; set;}
    public SRW_Trading_Partner_Profile__c currentTradingPartner {get; set;}
    public Integer locationToDelete {get; set;}

    public List<SelectOption> prescriberLocationTypeOfIdentifierOptions;
    public List<SelectOption> prescriberStateOptions;

    public Boolean noAccess {get; set;}

    public SRW_AddNewPrescOrOrgController() {
        prescriberOrOrgData = new PrescriberOrOrgWrapper();
        prescriberLocations = new List<PrescriberLocationWrapper>();
        PageReference currentPage = ApexPages.currentPage();
        system.debug('parameters: ' + currentPage.getParameters());
        prescOrOrg = currentPage.getParameters().get('type');
        returnPage = currentPage.getParameters().get('ret');
        Id prescriberToEdit = (Id) currentPage.getParameters().get('id');
        if(prescriberToEdit == null){
            editOrNew ='Add New ';  
            initNewPrescriber();
        }else{
            editOrNew = 'Edit ';
            SRW_Prescriber_or_Organization__c tempPresc = [SELECT id, Prescriber_First_Name_gne__c, Prescriber_Last_Name_gne__c, Organization_Name_gne__c, Type_gne__c FROM SRW_Prescriber_or_Organization__c WHERE id = :prescriberToEdit LIMIT 1];
            List<SRW_Prscr_or_Org_Location__c> tempLocations = [SELECT id, Type_of_Identifier_gne__c, Identifier_gne__c, Street_Address_1_gne__c, Street_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Location_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE Prescriber_or_Organization_gne__c = :prescriberToEdit AND isActive_gne__c = true ORDER BY CreatedDate Asc];
            if(!tempLocations.isEmpty()){
                prescriberOrOrgData = new PrescriberOrOrgWrapper(tempPresc, tempLocations[0]);
                tempLocations.remove(0);
                Integer position = 0;
                for(SRW_Prscr_or_Org_Location__c tempLocation : tempLocations){
                    prescriberLocations.add(new PrescriberLocationWrapper(position++, tempLocation));
                }   
            }
        }
        User currentUser = [SELECT id, ContactId FROM User WHERE id = :UserInfo.getUserId()];
        List<Profile> FOIMs = [SELECT Name, Id FROM Profile WHERE (Id = :UserInfo.getProfileId() AND Name = 'GNE-GST-Partner-External')];
        Boolean isFOIM = FOIMs.isEmpty();
        if(!isFOIM)    
              currentTradingPartner = [SELECT id FROM SRW_Trading_Partner_Profile__c WHERE Contact_gne__c = :currentUser.ContactId LIMIT 1];
        else {
            List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: currentUser.Id]; 
            if(!mimicData.isEmpty()) {        
                currentTradingPartner = [SELECT id FROM SRW_Trading_Partner_Profile__c WHERE Id = :mimicData.get(0).SRW_Trading_Partner_Profile_gne__c LIMIT 1];    
            }
        }
        if(currentTradingPartner == null) {
            noAccess = true;
            return;
        }
        else 
            noAccess = false;
        //at least there needs to be one location per prescriber
        //oldest one is 'defaut' one
    }

    public Boolean isIdentifierValid(SRW_Prscr_or_Org_Location__c loc){
        if('DEA'.equals(loc.Type_of_Identifier_gne__c)){
            Pattern dea = Pattern.compile('[a-zA-Z]{2}[0-9]{7}');
            Matcher deaMatcher = dea.matcher(loc.Identifier_gne__c);
            return deaMatcher.matches();
        }
        if ('HIN'.equals(loc.Type_of_Identifier_gne__c)){
            Pattern hin = Pattern.compile('[0-9]{7}[a-zA-Z]{2}');
            Matcher hinMatcher = hin.matcher(loc.Identifier_gne__c);
            return hinMatcher.matches();
        }
        if('NPI'.equals(loc.Type_of_Identifier_gne__c)){
            Pattern npi = Pattern.compile('[0-9]{10}');
            Matcher npiMatcher = npi.matcher(loc.Identifier_gne__c);
            return npiMatcher.matches();
        }
        return true;
    }

    public void initNewPrescriber(){
        if(editOrNew.equals('Add New ')){
            prescriberOrOrgData.prescOrOrg = new SRW_Prescriber_or_Organization__c(Type_gne__c = prescOrOrg);
            if('Prescriber'.equals(prescOrOrg)) prescriberOrOrgData.prescOrOrg.Prescriber_First_Name_gne__c = 'Dr. ';
            prescriberOrOrgData.location = new SRW_Prscr_or_Org_Location__c(Type_of_Identifier_gne__c = 'DEA', isActive_gne__c = true);
        }
    }

    public List<SelectOption> getPrescriberStateOptions(){
        Schema.DescribeFieldResult fieldResult = SRW_Prscr_or_Org_Location__c.State_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry ple : pickListEntry) {
            options.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }
        return options;
    }

    public List<SelectOption> getPrescriberLocationTypeOfIdentifierOptions(){
        Schema.DescribeFieldResult fieldResult = SRW_Prscr_or_Org_Location__c.Type_of_Identifier_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry ple : pickListEntry) {
            options.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }
        return options;
    }

    public void addLocation(){
        SRW_Prscr_or_Org_Location__c tempLoc = new SRW_Prscr_or_Org_Location__c(Prescriber_Identifier_Not_Found_gne__c = 'No', Type_of_Identifier_gne__c = 'DEA', isActive_gne__c = true);
        prescriberLocations.add(new PrescriberLocationWrapper(prescriberLocations.size(), tempLoc));
    }
    public void deleteLocation(){
        if(prescriberLocations[locationToDelete].location.id != null){
            SRW_Prscr_or_Org_Location__c tempLoc = [SELECT id, Identifier_gne__c, isActive_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE id = :prescriberLocations[locationToDelete].location.id];
            if(String.isBlank(tempLoc.Identifier_gne__c)){
                delete temploc;    
            }else{
                tempLoc.isActive_gne__c = false;
                update tempLoc;
            }
        }
        prescriberLocations.remove(locationToDelete);
        updateLocationsPosition();
    }

    public void updateLocationsPosition(){
        for(Integer i = 0; i < prescriberLocations.size(); i++){
            prescriberLocations[i].position = i;
        }
    }

    //duplicate criteria: type of Identifier, Identifier, Street Address 1, Street Address 2
    public List<SRW_Prscr_or_Org_Location__c> eliminateDuplicate(List<SRW_Prscr_or_Org_Location__c> locationsToAdd, SRW_Prescriber_or_Organization__c prescriber){
        List<SRW_Prscr_or_Org_Location__c> returnList = new List<SRW_Prscr_or_Org_Location__c>();
        Map<String, SRW_Prscr_or_Org_Location__c> checkerMap = new Map<String, SRW_Prscr_or_Org_Location__c>();
        for(Integer i = locationsToAdd.size()-1 ; i >= 0 ; i--){
            checkerMap.put(locationsToAdd[i].Type_of_Identifier_gne__c + locationsToAdd[i].Identifier_gne__c + locationsToAdd[i].Street_Address_1_gne__c + locationsToAdd[i].Street_Address_2_gne__c , locationsToAdd[i]);
        }
        returnList = checkerMap.values();
        return returnList;
    }

    public Boolean isPrescriberOrOrganizationValid(SRW_Prescriber_or_Organization__c customer){
        return customer.Type_gne__c.equals('Prescriber') ? (!String.isBlank(customer.Prescriber_First_Name_gne__c) && !String.isBlank(customer.Prescriber_Last_Name_gne__c)) : !String.isBlank(customer.Organization_Name_gne__c); 
    }
    public Boolean isPrescriberOrOrganizationLocationValid(SRW_Prscr_or_Org_Location__c location, boolean isMainLocation){
        return isMainLocation ? (!String.isBlank(location.Identifier_gne__c) && !String.isBlank(location.Street_Address_1_gne__c) && !String.isBlank(location.City_gne__c) && !String.isBlank(location.Zip_Code_gne__c)) : (!String.isBlank(location.Identifier_gne__c) && !String.isBlank(location.Street_Address_1_gne__c) && !String.isBlank(location.City_gne__c) && !String.isBlank(location.Zip_Code_gne__c) && !String.isBlank(location.Location_Identifier_gne__c));
    }
    public Boolean isZIPValid(String zip){
        Pattern zipPattern = Pattern.compile('[0-9]{5}');
        Matcher zipMatcher = zipPattern.matcher(zip);
        return zipMatcher.matches();
    }
    public PageReference generateReturnPageReference(){
        if(!String.isBlank(returnPage)){
            if(returnPage.equals('submitSalesData')){
                PageReference pr = new PageReference(Page.SRW_SubmitSalesData.getURL());
                return pr;
            }else{
                PageReference pr = new PageReference(Page.SRW_PrescriberList.getURL());
                return pr;
            }
        }else{
            PageReference pr = new PageReference(Page.SRW_PrescriberList.getURL());
            return pr;
        }
    }

    public PageReference submit(){
        prescriberOrOrgData.prescOrOrg.Trading_Partner_gne__c = currentTradingPartner.id;
        List<SRW_Prscr_or_Org_Location__c> locationsToAdd = new List<SRW_Prscr_or_Org_Location__c>();
        Savepoint sp = Database.setSavepoint();
        if (!isPrescriberOrOrganizationValid(prescriberOrOrgData.prescOrOrg)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill required fields.'));
            return null;
        }
        try{
            upsert prescriberOrOrgData.prescOrOrg;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save failed, please try again.'));
            return null;
        }
        prescriberOrOrgData.location.Prescriber_or_Organization_gne__c = prescriberOrOrgData.prescOrOrg.id;
        if (!isPrescriberOrOrganizationLocationValid(prescriberOrOrgData.location, true)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill required fields.'));
            Database.rollback(sp);
            prescriberOrOrgData.prescOrOrg.id = null;
            return null;
        }
        if (!isZIPValid(prescriberOrOrgData.location.Zip_Code_gne__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid ZIP Code.'));
            Database.rollback(sp);
            prescriberOrOrgData.prescOrOrg.id = null;
            return null;
        }
        if (!isIdentifierValid(prescriberOrOrgData.location)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid identifier format.'));
            Database.rollback(sp);
            prescriberOrOrgData.prescOrOrg.id = null;
            return null;
        }
        try {
            upsert prescriberOrOrgData.location;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save failed, please try again.'));
            Database.rollback(sp);
            prescriberOrOrgData.prescOrOrg.id = null;
            return null;
        }
        locationsToAdd.add(prescriberOrOrgData.location);
        system.debug('locations : ' + locationsToAdd);
        for(PrescriberLocationWrapper loc : prescriberLocations){
            loc.location.Prescriber_or_Organization_gne__c = prescriberOrOrgData.prescOrOrg.id;
            if (!isPrescriberOrOrganizationLocationValid(loc.location, false)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill required fields.'));
                Database.rollback(sp);
                prescriberOrOrgData.prescOrOrg.id = null;
                return null;
            }
            if (!isZIPValid(loc.location.Zip_Code_gne__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid ZIP Code.'));
                Database.rollback(sp);
                prescriberOrOrgData.prescOrOrg.id = null;
                return null;
            }
            if (!isIdentifierValid(loc.location)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid identifier format.'));
                Database.rollback(sp);
                prescriberOrOrgData.prescOrOrg.id = null;
                return null;
            }
            system.debug('adding location: ' + loc.location);
            locationsToAdd.add(loc.location);
        }
        List<SRW_Prscr_or_Org_Location__c> tempToAdd = eliminateDuplicate(locationsToAdd, prescriberOrOrgData.prescOrOrg);

        List<SRW_PO_Exception__c> exceptions = new List<SRW_PO_Exception__c>();
        List<SRW_PO_Exception__c> exceptionsToDelete = new List<SRW_PO_Exception__c>();

        for(SRW_Prscr_or_Org_Location__c temp : tempToAdd){
            List<SRW_Identifiers__c> tempIdentifierList = [SELECT Name, Identifier_Type_gne__c, id FROM SRW_Identifiers__c WHERE Name =:temp.Identifier_gne__c AND Identifier_Type_gne__c =:temp.Type_of_Identifier_gne__c];
            if (tempIdentifierList.isEmpty()){
                List<SRW_PO_Exception__c> tempPOexceptions = [SELECT id,Exception_Type_gne__c, Prscr_Or_Org_Location_gne__c FROM SRW_PO_Exception__c WHERE Prscr_Or_Org_Location_gne__c = :temp.id ];
                if(!tempPOexceptions.isEmpty())
                    exceptionsToDelete.addAll(tempPOexceptions);
                SRW_PO_Exception__c incorrectIdentifier = new SRW_PO_Exception__c();
                incorrectIdentifier.Exception_Type_gne__c = 'Location Identifier Not Found Exception';
                incorrectIdentifier.Prscr_Or_Org_Location_gne__c = temp.Id;
                temp.Prescriber_Identifier_Not_Found_gne__c = 'Yes';
                exceptions.add(incorrectIdentifier);
                sendExceptionEmail(temp, prescriberOrOrgData.prescOrOrg);
            }
        }
        if(!exceptionsToDelete.isEmpty()){
            try{    
                delete exceptionsToDelete;    
            } catch(Exception e){
                System.debug('exception: ' + e.getMessage());
                Database.rollback(sp);
                prescriberOrOrgData.prescOrOrg.id = null;
                return null;
            }
        }
        if(!exceptions.isEmpty()){

            try {
                insert exceptions;
            } catch(Exception e ){
                System.debug('exception: ' + e.getMessage());
                Database.rollback(sp);
                prescriberOrOrgData.prescOrOrg.id = null;
                return null;
            }
        }
        system.debug('locations after eliminate duplicates: ' + tempToAdd);
        try {
            upsert tempToAdd;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save failed, please try again.'));
            Database.rollback(sp);
            prescriberOrOrgData.prescOrOrg.id = null;
            prescriberOrOrgData.location.id = null;
            return null;
        }
        List<SRW_Prscr_or_Org_Location__c> duplicatesToDelete = [SELECT id FROM SRW_Prscr_or_Org_Location__c WHERE Prescriber_or_Organization_gne__c =:prescriberOrOrgData.prescOrOrg.id AND (Identifier_gne__c = null OR Street_Address_1_gne__c = null)];
        if(!duplicatesToDelete.isEmpty())
            delete duplicatesToDelete;
        return generateReturnPageReference();
    }

    public void sendExceptionEmail(SRW_Prscr_or_Org_Location__c loc, SRW_Prescriber_or_Organization__c customer){
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
        String htmlBody = 'Prescriber'.equals(customer.Type_gne__c) ? '<div>CUSTOMER: ' + customer.Prescriber_First_Name_gne__c + ' ' + customer.Prescriber_First_Name_gne__c +'</div>' : '<div>CUSTOMER: ' + customer.Organization_Name_gne__c  +'</div>';
        htmlBody += '<div>Identifier: ' + loc.Type_of_Identifier_gne__c + ' ' + loc.Identifier_gne__c + '</div>';
        String subject = 'CUSTOMER IDENTIFIER NOT MATCH';
        List<String> addresses = new List<String>();
        sem.setHtmlBody(htmlBody);
        sem.setSubject(subject);
        String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
        addresses.add(owea[0].Address);
        sem.setToAddresses(addresses);
        sem.setOrgWideEmailAddressId(owea[0].id);
        Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
    }

    public PageReference cancel(){
        return generateReturnPageReference();
        
    }

    public class PrescriberLocationWrapper{
        public Integer position {get; set;}
        public SRW_Prscr_or_Org_Location__c location {get; set;}

        public PrescriberLocationWrapper (Integer position, SRW_Prscr_or_Org_Location__c location){
            this.location = location;
            this.position = position;
        }
        public PrescriberLocationWrapper (){
            this.location = new SRW_Prscr_or_Org_Location__c(Type_of_Identifier_gne__c = 'DEA');
            this.position = 0;
        }
    }

    public class PrescriberOrOrgWrapper{
        public SRW_Prescriber_or_Organization__c prescOrOrg {get; set;}
        public SRW_Prscr_or_Org_Location__c location {get; set;}

        public PrescriberOrOrgWrapper(SRW_Prescriber_or_Organization__c prescOrOrg, SRW_Prscr_or_Org_Location__c location){
            this.prescOrOrg = prescOrOrg;
            this.location = location;
        }
        public PrescriberOrOrgWrapper(){
            this.prescOrOrg = new SRW_Prescriber_or_Organization__c();
            this.location = new SRW_Prscr_or_Org_Location__c(Type_of_Identifier_gne__c = 'DEA');
        }
    }
}