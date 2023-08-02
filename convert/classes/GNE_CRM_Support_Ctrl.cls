public with sharing class GNE_CRM_Support_Ctrl{
    public String tibcoUrl {get; private set;}
    public String regId {get; private set;}
    public String unixId {get; private set;}
    public String assignmentGroup {get; private set;}
    public String serviceId {get; private set;}
    public String iconBase64 { get; private set; }
    public Boolean hasViews { get; private set; }
    public String settingsJson { get; private set; }
    public String preferencesJson { get; private set; }
    public String viewsJson { get; private set; }
    public String userTimeZone { get; private set; }
    public String territoriesList { get; private set; }

    // ONBOARDING
    public String topic { get; private set; }
    public RequestWrapper request {get; set;}
    public Boolean hasProducts {get; private set;}
    public String webBrowser { get; set; }
    
    private static Boolean isSandbox;
    
    static {
        isSandbox = isSandboxEnv();
    }

    public GNE_CRM_Support_Ctrl() {
        //Map<String, GNE_SFA2_HPSM_Config__c> hpsmConfig = GNE_SFA2_HPSM_Config__c.getAll();
        //tibcoUrl = String.valueOf(hpsmConfig.get('TibcoUrlForIncidents').Configuration_Value_gne__c);
        //regId = String.valueOf(hpsmConfig.get('HPSMRegistrationId').Configuration_Value_gne__c);
        unixId = [SELECT External_ID_gne__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].External_ID_gne__c;
        //assignmentGroup = String.valueOf(hpsmConfig.get('IncidentDefaultAssignmentGroup').Configuration_Value_gne__c);
        //serviceId = String.valueOf(hpsmConfig.get('serviceId').Configuration_Value_gne__c);
        iconBase64  = GNE_MCCO_CRM_Util.getDocumentBase64('Interaction_Tab_Icon');
        hasViews = true;
        territoriesList = getUserTerritories();
        topic = ApexPages.currentPage().getParameters().get('topic');

        if(topic == 'accessIssue') {
            request = new RequestWrapper([SELECT Id, FirstName, LastName, Email, Phone, External_ID_gne__c FROM User WHERE Id = : Userinfo.getUserId() LIMIT 1]);
            onboardingVariablesInit();
        }
    }

    private String getUserTerritories(){
        String userTerritories = '';
        for(Territory2 terr :[SELECT Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId())]){
            if(userTerritories != ''){
                userTerritories += ', ';
            }
            userTerritories += terr.Name;
        }
        return userTerritories;
    }

    @RemoteAction
    public static Id createIncident(Map<String, String> params, String webBrowser, String phoneNumber){
        //Map<String, String> params = new Map<String, String>{'tibcoUrl' => tibcoUrl, 'regId' => regId, 'unixId' => unixId, 'assignmentGroup' => assignmentGroup, 'title' => title, 'description' => description};
        system.debug(params);
        Long start = DateTime.now().getTime();
        GNE_CRM_HPSM_Incident__c incident = new GNE_CRM_HPSM_Incident__c();
        incident.Details_gne__c = params.get('description');
        incident.Origin_gne__c = 'CRM';
        incident.Phone_Number_gne__c = phoneNumber;
        incident.Status_gne__c = 'Assigned';
        incident.Summary_gne__c = params.get('title');
        incident.Web_Browser_gne__c = webBrowser;
        incident.Unix_Id_gne__c = params.get('unixId');
        insert incident;
        //sendIncidentToHPSM(params, incident.Id);
        sendEmail(incident);
        Long length = DateTime.now().getTime() - start;
        system.debug('Create Incident Local Stop: ' + length);
        return incident.Id;
    }
    
    public static void sendEmail(GNE_CRM_HPSM_Incident__c incident) {
        List<String> toAddresses = createRecipients();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(incident.Summary_gne__c);
        email.setHtmlBody(createEmailBody(incident));
        email.setToAddresses(toAddresses);
        if(toAddresses != null) Messaging.sendEmail(new List<Messaging.SingleEmailMessage >{email});               
    }
    
    private static String createEmailBody(GNE_CRM_HPSM_Incident__c incident) {
        String orgUrl = 'https://'+URL.getSalesforceBaseUrl().getHost()+'/';
        String href = '<a href="'+orgUrl+incident.Id+'">Clik to open record in CRM </a>';
        String tableHtml = '<TABLE style="border: 1px solid #000000;">'+
            '<TR style="border: 1px solid black;"><TD style="border: 1px solid black;">Summary</TD><TD style="border: 1px solid black;">' + incident.Summary_gne__c + '</TD></TR>'+
            '<TR style="border: 1px solid black;"><TD style="border: 1px solid black;">Description</TD><TD style="border: 1px solid black;">' + incident.Details_gne__c + '</TD></TR>'+
            '<TR style="border: 1px solid black;"><TD style="border: 1px solid black;">Phone Number</TD><TD style="border: 1px solid black;">'+ incident.Phone_Number_gne__c +'</TD></TR>'+
            '<TR style="border: 1px solid black;"><TD style="border: 1px solid black;">Unix Id</TD><TD style="border: 1px solid black;">'+ incident.Unix_Id_gne__c +'</TD></TR>'+
            '<TR style="border: 1px solid black;"><TD style="border: 1px solid black;">Link to CRM</TD><TD style="border: 1px solid black;">' + href + '</TD></TR>'+
            '<TR style="border: 1px solid black;"><TD style="border: 1px solid black;">Origin</TD><TD style="border: 1px solid black;">'+ incident.Origin_gne__c + '</TD></TR>';
        return tableHtml;
    }
    
    private static List<string> createRecipients() {
        List<String> toAddresses;
        //	comm-sfa-ops-d@gene.com;sfa-ops-off-d@gene.com
        String adds = GNE_Foun_Misc_Config_Items_gne__c.getValues('HPSM_Email_Notification')?.Configuration_Value_gne__c;
        if(adds != null /*&& !isSandboxEnv()*/) { //NOT isSandboxEnv()
            toAddresses = adds.split(';');
        }

        return toAddresses;
    }
    
    private static Boolean isSandboxEnv() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    

    @Future(callout=true)
    public static void sendIncidentToHPSM(Map<String, String> params, Id incidentId){
        try{
            Map<String, String> result = (new GNE_SFA2_HPSMEngine()).executeHPSMRequest('DoCreateIncident', params)[0];
            GNE_CRM_HPSM_Incident__c incident = [SELECT Id, Incident_Id_gne__c FROM GNE_CRM_HPSM_Incident__c WHERE Id = :incidentId LIMIT 1];
            if(String.isNotBlank(result.get('returnIncidentId'))){
                incident.Incident_Id_gne__c = result.get('returnIncidentId');
                update incident;
            } else {
                system.debug(result.get('errorCode') + ' ' + result.get('description'));
            }

        } catch (Exception ex){
            system.debug(ex);
        }
    }

    @RemoteAction
    public static List<IncidentDetailsWrapper> getIncidentsList(Map<String, String> params){
        system.debug(params);
        List<IncidentDetailsWrapper> results = new List<IncidentDetailsWrapper>();
        String searchValue = params.get('searchString');
        String query = 'SELECT Id, Name, Closed_Date_gne__c, Details_gne__c, Incident_Id_gne__c, Opened_Date_gne__c, Priority_gne__c, Priority_frm_gne__c, Resolution_Code_gne__c, Resolution_gne__c, ';
        query += 'Resolved_Date_gne__c, Status_gne__c, Summary_gne__c, Unix_Id_gne__c FROM GNE_CRM_HPSM_Incident__c ';
        query += 'WHERE Unix_Id_gne__c = \'' + params.get('unixId') + '\' ';
        if(String.isNotBlank(searchValue)){
            query += 'AND (Incident_Id_gne__c LIKE \'%' + searchValue + '%\' OR Summary_gne__c LIKE \'%' + searchValue + '%\' OR Status_gne__c LIKE \'%' + searchValue + '%\') ';
        }
        if(Boolean.valueOf(params.get('filterNeeded'))){
            query += 'AND Status_gne__c != \'Closed\' ';
        }
        query += 'ORDER BY ' + params.get('sortColumn');
        query += ' ' + params.get('sortDirection');
        List<GNE_CRM_HPSM_Incident__c> incidents = (List<GNE_CRM_HPSM_Incident__c>)Database.query(query);
        for(GNE_CRM_HPSM_Incident__c incident :incidents){
            results.add(new IncidentDetailsWrapper(incident));
        }
        return results;
    }

    @RemoteAction
    public static IncidentDetailsWrapper getIncidentsDetails(String incidentId){
        system.debug(incidentId);
        if(String.isBlank(incidentId)){
            return null;
        }
        try{
            GNE_CRM_HPSM_Incident__c incident = [SELECT Id, Name, Closed_Date_gne__c, Details_gne__c, Incident_Id_gne__c, Opened_Date_gne__c, Priority_gne__c, Priority_frm_gne__c, Resolution_Code_gne__c, Resolution_gne__c, Resolved_Date_gne__c, Status_gne__c, Summary_gne__c, Unix_Id_gne__c FROM GNE_CRM_HPSM_Incident__c WHERE Id = :incidentId LIMIT 1];
            return new IncidentDetailsWrapper(incident);
        } catch (Exception ex){
            system.debug('Incident ' + incidentId + ' not found. ' + ex);
            return null;
        }
    }

    public class IncidentDetailsWrapper{
        public GNE_CRM_HPSM_Incident__c incident;
        public String closeDate;
        public String openDate;
        public String resolveDate;

        public IncidentDetailsWrapper(GNE_CRM_HPSM_Incident__c inc){
            this.incident = inc;
            this.closeDate = parseDate(inc.Closed_Date_gne__c);
            this.openDate = parseDate(inc.Opened_Date_gne__c);
            this.resolveDate = parseDate(inc.Resolved_Date_gne__c);
        }

        private String parseDate(DateTime dt){
            String result = null;
            if(dt != null){
                system.debug(dt);
                Integer hour = dt.hour();
                String ampm = 'AM';
                if(hour > 12){
                    ampm = 'PM';
                    hour -= 12;
                } else if (hour == 12){
                    ampm = 'PM';
                }
                result = (dt.month() < 10 ? '0' : '') + dt.month() + '/' + (dt.day() < 10 ? '0' : '') + dt.day() + '/' + dt.year() + ' ' + (hour < 10 ? '0' : '') + hour + ':' + (dt.minute() < 10 ? '0' : '') + dt.minute() + ':' + (dt.second() < 10 ? '0' : '') + dt.second() + ' ' + ampm;
                system.debug(result);
                return result;
            }
            return result;
        }
    }

    @RemoteAction
    public static List<Map<String, String>> sortList(String sortDirection, String sortColumn, List<Map<String, String>> listToSort){
        system.debug(listToSort);
        List<IncidentWrapper> wrappers = new List<IncidentWrapper>();
        for(Map<String, String> incident :listToSort){
            wrappers.add(new IncidentWrapper(incident, sortDirection, sortColumn));
        }
        system.debug(wrappers);
        wrappers.sort();
        system.debug(wrappers);
        List<Map<String, String>> listToReturn = new List<Map<String, String>>();
        for(Integer i = 0; i<wrappers.size(); i++){
            listToReturn.add(wrappers[i].getValues());
        }
        system.debug(listToReturn);
        return listToReturn;
    }

    public static String parseDate(String receivedDateStr){
        receivedDateStr = receivedDateStr.replace('T', ' ').replace('Z', '');
        DateTime dtgmt = DateTime.valueOfGmt(receivedDateStr);
        system.debug(dtgmt);
        Integer hour = dtgmt.hour();
        String ampm = 'AM';
        if(hour > 12){
            ampm = 'PM';
            hour -= 12;
        } else if (hour == 12){
            ampm = 'PM';
        }
        String result = (dtgmt.month() < 10 ? '0' : '') + dtgmt.month() + '/' + (dtgmt.day() < 10 ? '0' : '') + dtgmt.day() + '/' + dtgmt.year() + ' ' + (hour < 10 ? '0' : '') + hour + ':' + (dtgmt.minute() < 10 ? '0' : '') + dtgmt.minute() + ':' + (dtgmt.second() < 10 ? '0' : '') + dtgmt.second() + ' ' + ampm;
        system.debug(result);
        return result;
    }

    public class IncidentWrapper implements Comparable{
        Map<String, String> values;
        String sortOrder;
        String sortColumn;

        public IncidentWrapper(Map<String, String> values, String sortOrder, String sortColumn){
            this.values = values;
            this.sortOrder = sortOrder;
            this.sortColumn = sortColumn;
        }

        public Integer compareTo(Object compareTo) {
            String thisValue = this.values.get(this.sortColumn);
            String otherValue = ((IncidentWrapper)compareTo).values.get(this.sortColumn);
            Integer comparisionResult;
            if(thisValue < otherValue){
                comparisionResult = -1;
            } else if(thisValue > otherValue){
                comparisionResult = 1;
            } else {
                comparisionResult = 0;
            }
            if(this.sortOrder.equalsIgnoreCase('DESC')){
                return -comparisionResult;
            }
            return comparisionResult;
        }

        public Map<String, String> getValues(){
            if(String.isNotBlank(values.get('opentime'))){
                values.put('opentime', parseDate(values.get('opentime')));
            }
            if(String.isNotBlank(values.get('resolvedTime'))){
                values.put('resolvedTime', parseDate(values.get('resolvedTime')));
            }
            if(String.isNotBlank(values.get('closeTime'))){
                values.put('closeTime', parseDate(values.get('closeTime')));
            }
            return this.values;
        }

    }

    /**
     *  ONBOARDING PROCCESS LOGIC
     */

    private void onboardingVariablesInit() {
        hasProducts = ([SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = : UserInfo.getUserId()]).size() > 0 ? true : false;
    }

    public List<SelectOption> getTopics() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Access Issue','Access Issue'));
        return options;
    }

    public List<SelectOption> getTerritories() {
        List<SelectOption> options = new List<SelectOption>();
        for(Territory2 terr : [SELECT Id, Name, External_id_gne__c FROM Territory2 WHERE External_id_gne__c Like 'GNE-US;SFA%' AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%') ORDER BY External_id_gne__c LIMIT 200]) {
            options.add(new SelectOption(terr.Id,terr.Name));
        }
        return options;
    }

    public List<SelectOption> getProducts() {
        List<SelectOption> options = new List<SelectOption>();

        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        Integer userRegionCode = 0;

        if(!profileName.contains('Canada')) {
            userRegionCode = 1;
        } else {
            userRegionCode = 2;
        }

        Map<String, GNE_SFA2_TheraDisease_Users__c> profilesMap = GNE_SFA2_TheraDisease_Users__c.getAll();
        List<Product_vod__c> products = new List<Product_vod__c>();

        if(profilesMap.containsKey(profileName)){
            products = [SELECT Id, Name
                        FROM Product_vod__c
                        WHERE Product_Type_vod__c = 'Detail'
                        AND (Detail_Product_Subtype_Code_gne__c = 'TheraDisease' OR Detail_Product_Subtype_Code_gne__c = 'Molecule')
                        AND Region_Code_gne__c =: userRegionCode
                        ORDER BY Name
                       ];
        } else {
            products = [SELECT Id, Name
                        FROM Product_vod__c
                        WHERE Product_Type_vod__c = 'Detail'
                        AND (Detail_Product_Subtype_Code_gne__c != 'Molecule' AND Detail_Product_Subtype_Code_gne__c != 'TheraDisease')
                        AND Region_Code_gne__c =: userRegionCode
                        ORDER BY Name
                       ];
        }

        for(Product_vod__c product : products) {
            options.add(new SelectOption(product.Id,product.Name.normalizeSpace()));
        }
        return options;
    }

    public class OnboardingWrapper {

        public OnboardingWrapper() {}


    }

    public class RequestWrapper {
        public String userId {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String email {get; set;}
        public String phone {get; set;}
        public String unixId {get; set;}
        public String topic {get; set;}
        public String territory {get; set;}
        public String products {get; set;}

        public RequestWrapper(User user) {
            this.userId = user.Id;
            this.firstName = user.FirstName;
            this.lastName = user.LastName;
            this.email = user.Email;
            this.phone = user.Phone;
            this.unixId = user.External_ID_gne__c;
            this.topic = 'Access Issue';
        }
    }

    public PageReference submitTicket() {
        GNE_CRM_HPSM_Incident__c incident = new GNE_CRM_HPSM_Incident__c();
        incident.Details_gne__c = prepareAccessIssueDescription();
        incident.Origin_gne__c = 'CRM';
        incident.Phone_Number_gne__c = request.phone;
        incident.Status_gne__c = 'Assigned';
        incident.Summary_gne__c = request.topic;
        incident.Web_Browser_gne__c = webBrowser;
        incident.Unix_Id_gne__c = request.unixId;
        insert incident;
        Database.executeBatch(new GNE_CRM_HPSM_Create_Incident_Batch(), 200);

        User currentUser = [SELECT Id, Phone FROM User where Id =: UserInfo.getUserId() LIMIT 1];
        if(String.isBlank(currentUser.Phone)) {
            currentUser.Phone = request.phone;
            try {
                update currentUser;
            } catch (Exception ex) {
                System.debug(ex);
            }
        }

        PageReference pr = new PageReference('/apex/GNE_MCCO_CRM_Tools_And_Resources');
        pr.setRedirect(true);
        return pr;
    }

    private String prepareAccessIssueDescription() {
        String result = '';
        result += 'Territory: ' + request.territory;
        if(String.isNotBlank(request.products)) {
            result += '\n\nProduct(s): ';
            List<String> productsIds = request.products.split(', ');
            for(Product_vod__c p : [SELECT Id, Name FROM Product_vod__c where Id IN : productsIds]) {
                result += '\n' + p.Name + ' (' + p.Id + ')';
            }        }

        result += '\n\nExtended Information:';
        result += '\nContact Phone Number: ' + request.phone;
        result += '\nUser Profile: ' + GNE_SFA2_Util.getCurrentUserProfileName();
        result += '\nWeb Browser: ' + webBrowser;

        return result;
    }
}