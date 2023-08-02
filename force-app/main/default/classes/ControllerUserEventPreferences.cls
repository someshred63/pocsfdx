/********************************************************************************************
Name   : ControllerUserEventPreferences
Usage  : Controller class of UserPreferences VF page.
Author : Vinod Koosam@Appirio
Date   : November 09, 2009
Date   : November 30, 2009
         Modified so that every "Brand" selected has its own record of user preferences.
         So, for example, if the user preference record used to have these values
         "Speaker Training;Speaker Program", "Avastin;Zolair",
         "0010500-ATLANTA-2233;0007089-SAN FRANCISCO-333"


         for Event type, brands and territories.  Instead of 1 record will will have multiple
         record, one each representing a brand separately.
         "Speaker Training;Speaker Program", "Avastin",
         "0010500-ATLANTA-2233;0007089-SAN FRANCISCO-333"

         and

         "Speaker Training;Speaker Program", "Zolair",
         "0010500-ATLANTA-2233;0007089-SAN FRANCISCO-333";
********************************************************************************************/

public class ControllerUserEventPreferences {
    public List<CheckboxOption> eventTypesList {get; private set;}
    public List<List<CheckboxOption>> brandRowsList {get; private set;}
    public List<List<UITerritory>> territoryRowsList {get; private set;}
    public Integer removeTerri {get; set;}
    public String addTerri {get; set;}
    public String territoryName {get; set;}
    public List<Territory2> searchResult {get; private set;}

    private final String DELIMITER;
    private UnifiedCalendarUserEventPreference_gne__c userEventPreference;
    //private UnifiedCalendarUserEventPreference_gne__c previousUserEventPreference;

    private List<String> eventTypeOptions;
    private List<String> brandOptions;
    private Map<String, CheckboxOption> eventTypeToCBOptionMap;
    private Map<String, CheckboxOption> brandToCBOptionMap;

    private Set<String> selectedBrands;
    private List<String> selectedTerritories = new List<String>();
    private List< UserTerritory2Association > defaultTerritories;
    private List<UnifiedCalendarUserEventPreference_gne__c> userEventPreferenceList = new List<UnifiedCalendarUserEventPreference_gne__c>();
    private Set<String> userDefaultTerritoryNamesSet = new Set<String>();
    public  String defaultBrandName {get;set;}
    Set<String> defaultSelectableBrands = new Set<String>();

    public String profileName = '';
    public String currentUserSecondarygCalId;
    public User currentUserRecord;

    public Boolean firstTimeUser = false; // this determines some of the defaulting rules
    private Map<String, String> brandNameExceptionMap = new Map<String, String>();

    private Map<String, String> reverseBrandNameExceptionMap = new Map<String, String>();

    public ControllerUserEventPreferences() {
        DELIMITER = ';';
        brandNameExceptionMap.put('Rituxan-Rheumatoid Arthritis', 'Rituxan RA');
        brandNameExceptionMap.put('Actemra-Rheumatoid Arthritis', 'Actemra');

        reverseBrandNameExceptionMap.put('Rituxan RA', 'Rituxan-Rheumatoid Arthritis');
        reverseBrandNameExceptionMap.put('Actemra',    'Actemra-Rheumatoid Arthritis');

        //prepareOptions(); // move this to the end of constructor, so options has all the information by then

        eventTypesList = new List<CheckboxOption>();
        brandRowsList = new List<List<CheckboxOption>>();
        territoryRowsList = new List<List<UITerritory>>();
        searchResult = new List<Territory2>();
        territoryName = addTerri = '';
        Set<String> selectedEventTypes = new Set<String>();

        // To Do : Select only required fields
        ID userId = UserInfo.getUserId();
        String userName = UserInfo.getUsername();
        currentUserRecord = [select u.Profile.Name, Secondary_gCal_ID_gne__c, Brand_name_gne__c from User u where u.id = :Userinfo.getUserId()];
        profileName       = currentUserRecord.Profile.Name;
        defaultBrandName  = currentUserRecord.Brand_Name_gne__c;

        prepareOptions();

        currentUserSecondarygCalId = currentUserRecord.Secondary_gCal_ID_gne__c;

        defaultTerritories = [Select u.Territory2Id, u.UserId from UserTerritory2Association u where u.UserId= :userId];
        List<Id> defaultTerritoryIds = new List<Id>();
        for(UserTerritory2Association dTerr : defaultTerritories){
             defaultTerritoryIds.add(dTerr.Territory2Id);
        }

        List<Territory2> defaultTerritoryNames = [SELECT name FROM Territory2 WHERE Id in : defaultTerritoryIds];

        for(Territory2 terr : defaultTerritoryNames){
            userDefaultTerritoryNamesSet.add(terr.Name);
        }

        userEventPreferenceList = [SELECT Id, Event_Type__c,
                level__c, brands__c, secondary_calendar_id__c, UserProfile_gne__c, territories__c
                FROM UnifiedCalendarUserEventPreference_gne__c WHERE OwnerId = :userId];

        if (userEventPreferenceList.size() > 1) {
            // this means user has more than one brand selected
            // get the first record to grab the event types and territories
            // remember, all records will have event types (same)
            userEventPreference = userEventPreferenceList[0];
            if (userEventPreference.Event_Type__c != null) {
                selectedEventTypes.addAll(userEventPreference.Event_Type__c.split(DELIMITER));
            }

        } else if (userEventPreferenceList.size() == 1) {
            userEventPreference = userEventPreferenceList[0];
            //previousUserEventPreference = userEventPreference.clone();

            if (userEventPreference.Event_Type__c != null) {
                selectedEventTypes.addAll(userEventPreference.Event_Type__c.split(DELIMITER));
            }
        } else {
            // this is first time user
            firstTimeUser = true;
            userEventPreference = new UnifiedCalendarUserEventPreference_gne__c();
            userEventPreference.OwnerId = userId;
            userEventPreference.secondary_calendar_id__c = currentUserSecondarygCalId;
            userEventPreference.UserProfile_gne__c = profileName;

            // now add the default event types
            String eventTypeField = '';
            for (String eventType : eventTypeOptions) {
                eventTypeField += eventType + DELIMITER;
            }
            selectedEventTypes.addAll(eventTypeField.split(DELIMITER));

            String territoryField = '';
            // List<Territory> defaultTerritoryNames = [SELECT name FROM Territory WHERE Id in : defaultTerritoryIds];

            for(Territory2 terr : defaultTerritoryNames){
                territoryField += terr.Name + DELIMITER;
            }

            userEventPreference.Event_Type__c = eventTypeField;
            userEventPreference.territories__c = territoryField;

            // now as far as the brands go, because this is a new user
            // grab the default list of brands, create a record for each and
            // stick it into the preference list to be use to "check" brands in the UI.
            // Remember, this can also be used to initialize the current user, by persisting them if
            // needed, so a first time user when opens the UI, gets default prefs created if they dont exist

            List<UnifiedCalendarUserEventPreference_gne__c> defaultingUserPrefsForFirstTimer = new List<UnifiedCalendarUserEventPreference_gne__c>();
            for(String bName : defaultSelectableBrands){
                UnifiedCalendarUserEventPreference_gne__c myTempPref = new UnifiedCalendarUserEventPreference_gne__c();
                myTempPref = userEventPreference.clone();
                myTempPref.brands__c = mapExceptionBrandName(bName);
                defaultingUserPrefsForFirstTimer.add(myTempPref);
            }

            userEventPreferenceList = defaultingUserPrefsForFirstTimer;
        }

        eventTypeToCBOptionMap = new Map<String, CheckboxOption>();
        for (String eventType : eventTypeOptions) {
            CheckboxOption cbOption = new CheckboxOption(eventType, selectedEventTypes.contains(eventType));
            eventTypesList.add(cbOption);
            eventTypeToCBOptionMap.put(eventType, cbOption);
        }

        prepareBrandRowsList();

        if (userEventPreference.territories__c != null) {
            selectedTerritories.addAll(userEventPreference.territories__c.split(DELIMITER));
        }

        prepareTerritoryRowsList();

    }

    public void initializePreferences() {
        if (firstTimeUser && userEventPreference.id == null) {
            try{
                if(userEventPreferenceList != null && userEventPreferenceList.size() > 0){
                    insert userEventPreferenceList;
                }
            }catch(Exception iEx){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error during initializing preferences.  Please try again.'));
            }
        }
    }

    public void addTerritory() {
        selectedTerritories.add(addTerri);
        selectedTerritoriesChanged();
    }

    public void removeTerritory() {
        selectedTerritories.remove(removeTerri);
        selectedTerritoriesChanged();
    }

    public void searchTerritory() {
        String profileType       = getProfileType();
        String profileTypeLike   = '%'+ profileType + '%';
        String territoryNameLike = '%' + territoryName + '%';

        // searchResult = [SELECT Name FROM Territory WHERE Name LIKE :territoryNameLike AND Name NOT IN :selectedTerritories ORDER BY Name LIMIT 10];
        if(profileType == null){
            searchResult = [SELECT Name FROM Territory2 WHERE Name LIKE :territoryNameLike AND Name NOT IN :selectedTerritories ORDER BY Name LIMIT 10];
        }else{
            searchResult = [SELECT Name FROM Territory2 WHERE Name LIKE :territoryNameLike AND (Name LIKE :profileTypeLike OR source_gne__c LIKE :profileTypeLike OR parent_external_id_gne__c LIKE :profileTypeLike ) AND Name NOT IN :selectedTerritories ORDER BY Name LIMIT 10];
        }
    }

    public PageReference save() {

        String eventTypeField = '';
        String brandField = '';
        String territoryField = '';

        Boolean hasError = false;

        UnifiedCalendarUserEventPreference_gne__c  newPrefs = new UnifiedCalendarUserEventPreference_gne__c ();

        for (String eventType : eventTypeOptions) {
            if (eventTypeToCBOptionMap.get(eventType).isSelected == true) {
                eventTypeField += eventType + DELIMITER;
            }
        }

        if(eventTypeField == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Select at least one Event Type.'));
            hasError = true;
        }

        for (String territoryStr : selectedTerritories) {
            territoryField += territoryStr + DELIMITER;
        }

        if(territoryField == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Select at least one User Territory2.'));
            hasError = true;
        }

        newPrefs.prev_eventtype__c = userEventPreference.Event_Type__c+'';
        newPrefs.prev_brands__c = userEventPreference.brands__c+'';
        newPrefs.prev_territories__c = userEventPreference.territories__c+'';

        newPrefs.Event_Type__c  = eventTypeField;
        newPrefs.territories__c = territoryField;
        newPrefs.brands__c      = '';

        // Modified - we no longer care about previous values
        // will handle it part of Release 2 (after this current deployment
        // so commenting this below line
        // populatePreviousPreferences(previousUserEventPreference, userEventPreference);

        // now create a separate user preference record for each brand selected
        // delete the existing records and insert the new ones
        list<String> creatableBrands = new List<String>();
        for (String brand : brandOptions) {
            // we really do not need to map exceptions here
            // but if for any reason, there are still renmants of brands
            // that need to be mapped, this is a good opportunity to do so
            // brand = mapExceptionBrandName(brand);
            if (brandToCBOptionMap.get(brand).isSelected == true) {
                brand = mapExceptionBrandName(brand);
                creatableBrands.add(brand);
            }
        }

        if(creatableBrands.size() <= 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Select at least one Brand/Indication'));
            hasError = true;
        }

        if(hasError){
            return null;
        }

        List<UnifiedCalendarUserEventPreference_gne__c> creatablePrefs = new List<UnifiedCalendarUserEventPreference_gne__c>();
        if(creatableBrands.size() > 0){
            for(String br : creatableBrands){
                UnifiedCalendarUserEventPreference_gne__c tmpBrandPref = newPrefs.clone();
                tmpBrandPref.brands__c = br+'';
                tmpBrandPref.UserProfile_gne__c = profileName;
                tmpBrandPref.secondary_calendar_id__c = currentUserSecondarygCalId;
                creatablePrefs.add(tmpBrandPref);
            }
        }

        // handle the case, if no brands were selected
        if(creatableBrands.size() == 0){
            creatablePrefs.add(newPrefs);
        }

        // delete existing prefs and insert the new ones
        Boolean saveError = false;
        try{
            // get the latest preferences the user has before save, in case if they coincidentally
            // opened another window and were creating it while this page (controller) was still up
            userEventPreferenceList = [SELECT Id FROM UnifiedCalendarUserEventPreference_gne__c WHERE OwnerId = :UserInfo.getUserId()];
            if(userEventPreferenceList != null && userEventPreferenceList.size() > 0){
                delete userEventPreferenceList;
            }

            insert creatablePrefs;
            userEventPreferenceList = creatablePrefs;

            if(userEventPreferenceList.size() > 0){
                userEventPreference     = userEventPreferenceList[0];
            }

        }catch(Exception diEx){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,
                    'Error during saving preferences.  Please try again'));
            saveError = true;
        }

        if(!saveError)
            return cancel();
        else
            return ApexPages.currentPage();
    }

    public PageReference cancel() {
        PageReference retPage = new PageReference('/apex/UserEventPreferencesConfirmClose');

        return retPage;
        //new PageReference('/home/home.jsp');
    }

    private void selectedTerritoriesChanged() {
        prepareTerritoryRowsList();
        searchTerritory();
    }

    private void prepareOptions() {
        // Add Event Types in alphabetical order
        eventTypeOptions = new List<String>();
        eventTypeOptions.add('Speaker Program');
        eventTypeOptions.add('Speaker Training');

        // Add brands in alphabetical order
        brandOptions = new List<String>();

        Map<String, String> brandCollection  = new Map<String, String>();

        for(Product_vod__c pName : [Select Id,name from product_vod__c where product_type_vod__c='Detail'  and (NOT name like '%obsolete%')  and ( NOT name like 'Inactive%') and (not name like '%Archieve%' ) and(name like '%-%')  order by name asc]){

            // now apply the execption list to the brand name
            // we have few breand/indications that need to be
            // mapped in order to match the Medical Events brand/indications
            // downstream in the external apps., like EII and ESB

            // VINOD: SPECIAL BRANDS FIX
            // String pNameConverted = mapExceptionBrandName(pName.name);

            String pNameConverted = pName.name;

            if(! brandCollection.containsKey(pNameConverted)){
                brandCollection.put(pNameConverted,pNameConverted);
                brandOptions.add(pNameConverted);

                if(defaultBrandName != null && pNameConverted.contains(defaultBrandName) ){
                     defaultSelectableBrands.add(pNameConverted);
                }
            }
        }

    }

    private void prepareBrandRowsList() {
        selectedBrands = new Set<String>();
        if(userEventPreferenceList.size() > 0){
            for(Integer i=0; i<userEventPreferenceList.size(); ++i){
                UnifiedCalendarUserEventPreference_gne__c uPref = userEventPreferenceList[i];
                if (uPref.brands__c != null) {
                    selectedBrands.add(uPref.brands__c);
                }
            }
        }

        Integer noOfBrandOptions = brandOptions.size();
        Integer secondColumnBase = Math.ceil(noOfBrandOptions / 3.0).intValue();
        Integer thirdColumnBase = secondColumnBase * 2;

        if (secondColumnBase != (noOfBrandOptions / 3)
                && Math.mod(noOfBrandOptions - secondColumnBase, 2) == 0) {
            thirdColumnBase--;
        }

        brandToCBOptionMap = new Map<String, CheckboxOption>();

        for (Integer index = 0; index < secondColumnBase; index++) {
            List<CheckboxOption> newRow = new List<CheckboxOption>();
            brandRowsList.add(newRow);

            addBrandOption(newRow, index);

            if ((index + secondColumnBase + 1) > noOfBrandOptions
                    || (index + secondColumnBase) == thirdColumnBase) {
                break;
            }

            addBrandOption(newRow, index + secondColumnBase);

            if ((index + thirdColumnBase + 1) > noOfBrandOptions) {
                break;
            }

            addBrandOption(newRow, index + thirdColumnBase);
        }
    }

    /**
     * save the preferences the user has before this edit
     * remember when user saves the prev_* fields will have
     * delta's between previous/current and new selections.
     */
    private UnifiedCalendarUserEventPreference_gne__c  populatePreviousPreferences(UnifiedCalendarUserEventPreference_gne__c prevPref, UnifiedCalendarUserEventPreference_gne__c latestPref ){

        // get difference of events and populate prev event types
        latestPref.prev_eventtype__c = selectionsDelta(prevPref.Event_Type__c, latestPref.Event_Type__c);

        // now get prev brands deltas
        latestPref.prev_brands__c  = selectionsDelta(prevPref.brands__c, latestPref.brands__c);

        // same for territories
        latestPref.prev_territories__c = selectionsDelta(prevPref.territories__c, latestPref.territories__c);

        return latestPref;
    }

    /**
     * A utility method to get the difference between 2 sets where
     * old set  = new selections - existing selections
     * for eample, if user had (old brands=) Avastin, Rituxan as existing brands
     * and if they selected unselected everything and now has
     * (new brands=) Xolair
     *
     * the difference OLD - NEW = (Avastin, Rituxan) - (Xolair) = (Avastin, Rituxan)
     */
    private String selectionsDelta(String oSelections, String nSelections){
        String delimitedDeltas = '';

        Set<String> oldSelections   = new Set<String>();
        Set<String> latestSelections= new Set<String>();

        System.debug('****************************************************************');
        System.debug('selectionsDelta(): oSelections = ' + oSelections + ' :: nSelections=' + nSelections);

        try{
            if(oSelections != null)
                oldSelections.addAll(oSelections.split(DELIMITER));
        }catch(Exception oE){
            // do nothing, this should not happen
            System.debug('ControllerUserEventPreferences.selectionsDelta : exception = ' + oE.getMessage());
        }

        try{
            if(nSelections != null)
                latestSelections.addAll(nSelections.split(DELIMITER));
        }catch(Exception nE){
            // do nothing, this should not happen
            System.debug('ControllerUserEventPreferences.selectionsDelta : exception = ' + nE.getMessage());
        }

        for(String oItem : oldSelections){
            if(! latestSelections.contains(oItem))
                delimitedDeltas += oItem + DELIMITER;
        }

        return delimitedDeltas;
    }

    private void addBrandOption(List<CheckboxOption> newRow, Integer index) {
        String brand = brandOptions[index];
        String brandToSavedName = mapExceptionBrandName(brand);
        CheckboxOption cbOption = new CheckboxOption(brand, selectedBrands.contains(brandToSavedName));
        brandToCBOptionMap.put(brand, cbOption);
        newRow.add(cbOption);
    }

    private String mapExceptionBrandName(String bName){
        if(bName != null && brandNameExceptionMap != null && brandNameExceptionMap.containsKey(bName))
            return brandNameExceptionMap.get(bName);
        else
            return bName;
    }

    private String mapReverseExceptionBrandName(String bName){
        if(bName != null && reverseBrandNameExceptionMap != null && reverseBrandNameExceptionMap.containsKey(bName))
            return reverseBrandNameExceptionMap.get(bName);
        else
            return bName;
    }


    private void prepareTerritoryRowsList() {
        selectedTerritories.sort();
        territoryRowsList = new List<List<UITerritory>>();

        Integer noOfTerritories = selectedTerritories.size();
        Integer secondColumnBase = Math.ceil(noOfTerritories / 2.0).intValue();
        Boolean isDefaultFlag = false;

        for (Integer index = 0; index < secondColumnBase; index++) {
            List<UITerritory> newRow = new List<UITerritory>();
            territoryRowsList.add(newRow);

            if(userDefaultTerritoryNamesSet.contains(selectedTerritories[index]))
                isDefaultFlag = true;
            else
                isDefaultFlag = false;

            newRow.add(new UITerritory(selectedTerritories[index], index, isDefaultFlag));

            if ((index + secondColumnBase + 1) > noOfTerritories) {
                break;
            }

            // if the territory being listed is one of users default territory
            // mark it as such so that the UI can disable the remove icon next to it
            if(userDefaultTerritoryNamesSet.contains(selectedTerritories[index + secondColumnBase]))
                isDefaultFlag = true;
            else
                isDefaultFlag = false;

            newRow.add(new UITerritory(selectedTerritories[index + secondColumnBase],
                    (index + secondColumnBase), isDefaultFlag));
        }
    }

    private class CheckboxOption {
        public final String LABEL {get; private set;}
        public Boolean isSelected {get; set;}

        private CheckboxOption(final String LABEL, Boolean isSelected) {
            this.LABEL = LABEL;
            this.isSelected = isSelected;
        }
    }

    private class UITerritory {
        public final String LABEL {get; private set;}
        public final Integer INDEX {get; private set;}
        public Boolean isDefault {get; set;}

        private UITerritory(final String LABEL, final Integer INDEX) {
            this.LABEL = LABEL;
            this.INDEX = INDEX;
        }

        private UITerritory(final String LABEL, final Integer INDEX, Boolean tf) {
            this.LABEL = LABEL;
            this.INDEX = INDEX;
            this.isDefault = tf;
        }
    }

    public String getProfileType(){
        String pType = null;

        if(profileName != null && profileName.contains('SFA') ){
            pType = 'SFA';
        }else if(profileName != null && profileName.contains('MCCO')){
            pType = 'MCCO';
        }else if(profileName != null && profileName.contains('TLS')){
            pType = 'TLS';
        }else{
            pType = null;
        }

        return pType;
    }

    public String getProfileName(){
        return profileName;
    }

    public Boolean getFirstTimeUser(){
        return firstTimeUser;
    }
}