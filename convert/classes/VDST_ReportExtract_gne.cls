global without sharing class VDST_ReportExtract_gne {
    public String                            yearOfFile        { get; set; }
    public String                            vendorType        { get; set; }
    //public VDST_EventDetailCommon            commonUtils       { get; set; }
    public List<VDST_EventProvider_gne__c>   vendorList        { 
        get {
            if('1'.equals(vendorType)) {
                return [SELECT VendorName_gne__c, IsPreferred_gne__c FROM VDST_EventProvider_gne__c 
                         WHERE IsPreferred_gne__c = true OR IsPrePreferred_gne__c = true 
                         ORDER BY IsPreferred_gne__c DESC];
            } else {
                return [SELECT VendorName_gne__c, IsPreferred_gne__c FROM VDST_EventProvider_gne__c 
                         WHERE IsNonPreferred_gne__c = true];
            }
        } 
        set;
    }

    public VDST_ReportExtract_gne(){
        //commonUtils = new VDST_EventDetailCommon();
        //vendorType = '1';
        //yearOfFile = '2014'; // TODO: modify this
    }
    
    public VDST_ReportExtract_gne(VDST_Users_Management controller) {
        vendorType = '1';
        yearOfFile = String.valueOf(Date.today().year());
    }

    public List<SelectOption> getListOfYears() {
        Date currentYear = Date.today();
        return new List<SelectOption>{
            new SelectOption( String.valueOf(currentYear.year()), String.valueOf(currentYear.year()) ),
            new SelectOption( String.valueOf(currentYear.addYears(-1).year()), String.valueOf(currentYear.addYears(-1).year())),
            new SelectOption( String.valueOf(currentYear.addYears(-2).year()), String.valueOf(currentYear.addYears(-2).year())),
            new SelectOption( String.valueOf(currentYear.addYears(-3).year()), String.valueOf(currentYear.addYears(-3).year()))
        };
    }

    public List<SelectOption> getVendorTypes() {
        return new List<SelectOption>{new SelectOption('1','Preferred / Previously Preferred') , new SelectOption('2','Non-Preferred')};
    }

    /*
    public List<SelectOption> getGroupItems() {
            List<SelectOption> groupItems = new List<SelectOption>{new SelectOption('', '-Select-')};
            for(VDST_EventProvider_gne__c provider : VDST_Utils.getEvProviderById(true, 'a0W7000000Q8mBpEAJ') ) {
                groupItems.add(new SelectOption(provider.Id, provider.VendorCode_gne__c + ' - ' + provider.VendorName_gne__c));
            }
            return groupItems;
  
     }
     */
     
    public PageReference updateVendorList() {
        return null;
    }
    
    @ReadOnly
    @RemoteAction
    global static List<EventObject> getDataMart(String quarter, Integer yearOfFileHolder, String vendorTypeHolder) {
        List<String> unixIdList = new List<String>();
        List<EventObject> eventList = new List<EventObject>();
        Date quarterStart;
        Date quarterEnd;
        if('Q1'.equals(quarter)) {
            quarterStart = Date.newInstance(yearOfFileHolder,01,01);
            quarterEnd = Date.newInstance(yearOfFileHolder,03,31);
        } else if('Q2'.equals(quarter)) {
            quarterStart = Date.newInstance(yearOfFileHolder,04,01);
            quarterEnd = Date.newInstance(yearOfFileHolder,06,30);
        } else if('Q3'.equals(quarter)) {
            quarterStart = Date.newInstance(yearOfFileHolder,07,01);
            quarterEnd = Date.newInstance(yearOfFileHolder,09,30);
        } else if('Q4'.equals(quarter)) {
            quarterStart = Date.newInstance(yearOfFileHolder,10,01);
            quarterEnd = Date.newInstance(yearOfFileHolder,12,31);
        }
        String dataQuery = 'SELECT Id, CreatedDate, VendorEventID_gne__c, CurrentStatus_gne__c, isBatch_gne__c, EventType_gne__c, ';
               dataQuery +=               'AccountableGNE_FirstName_gne__c, AccountableGNE_LastName_gne__c, AccountableGNE_UnixID_gne__c, ';
               dataQuery +=               'LogisticVendorName_gne__c, LogisticVendorCode_gne__c, ContentVendorName_gne__c, ';
               dataQuery +=               'EventEndDate_gne__c, EventMeetingName_gne__c, TotalEventSpend_gne__c, ';
               dataQuery +=               'LogisticVendor_gne__r.IsPreferred_gne__c, LogisticVendor_gne__r.IsPrePreferred_gne__c, LogisticVendor_gne__r.IsNonPreferred_gne__c, ';
               dataQuery +=            '(SELECT ParentId, OldValue, NewValue, CreatedDate FROM Histories ORDER BY CreatedDate) ';
               dataQuery +=        'FROM VDST_Event_gne__c ';
               dataQuery +=        'WHERE (CurrentStatus_gne__c = \'CLOSED\' OR CurrentStatus_gne__c = \'OCCURRED\') ';
               dataQuery +=            'AND EventEndDate_gne__c >= ' + String.valueOf(quarterStart) + ' AND EventEndDate_gne__c <= ' + String.valueOf(quarterEnd) + ' ';
           if('1'.equals(vendorTypeHolder)) {
               dataQuery +=            'AND (LogisticVendor_gne__r.IsPreferred_gne__c = true OR LogisticVendor_gne__r.IsPrePreferred_gne__c = true) ';
           } else {
               dataQuery +=            'AND LogisticVendor_gne__r.IsNonPreferred_gne__c = true ';
           
           }
               dataQuery +=        'ORDER BY LogisticVendor_gne__r.IsPreferred_gne__c DESC, LogisticVendorName_gne__c ASC ';
               //dataQuery +=        'LIMIT 10000'; // IN FUTURE UPDATE?
        System.debug(LoggingLevel.Info, dataQuery);
        for(VDST_Event_gne__c ev : Database.query(dataQuery) ) {
            if('OCCURRED'.equals(ev.CurrentStatus_gne__c) && !ev.isBatch_gne__c) {
                Boolean noClosedStatus = true;
                for(VDST_Event_gne__History evh : ev.Histories) {
                    if( 'CLOSED'.equals(evh.OldValue) || 'CLOSED'.equals(evh.NewValue) ) {
                        noClosedStatus = false;
                    }
                }
                if(noClosedStatus) {
                    continue;
                }
            }
            unixIdList.add(ev.AccountableGNE_UnixID_gne__c);
            eventList.add(new EventObject(ev));
        }
        Map<String, VDST_UserStagingTable_gne__c> userStagingMap = new Map<String, VDST_UserStagingTable_gne__c>();
        for(VDST_UserStagingTable_gne__c userStaging : [SELECT CostCenterNM_gne__c, DepartmentNBR_gne__c, UserId_gne__c FROM VDST_UserStagingTable_gne__c WHERE UserId_gne__c IN :unixIdList]) { // TODO: check if we need additional flow?
            userStagingMap.put(userStaging.UserId_gne__c.toLowerCase(), userStaging);
        }
        for(EventObject eo : eventList) {
            if(eo.unixId != null && userStagingMap.get(eo.unixId.toLowerCase()) != null) {
                eo.costCenter = userStagingMap.get(eo.unixId.toLowerCase()).CostCenterNM_gne__c;
                eo.depNum = userStagingMap.get(eo.unixId.toLowerCase()).DepartmentNBR_gne__c;
            }
        }
        
        return eventList;
    }

    global class EventObject {
        public String eventId;
        public String eventStatus;
        public String eventType;
        public String firstName;
        public String lastName;
        public String unixId;
        public String costCenter;
        public String depNum;
        public String logVenName;
        public String logVenCode;
        public String evEndDate;
        public String evMeetName;
        public String contVenName;
        public Double totEvSpend;
        public String masterDataDue;
        public String masterDataReceived;
        public Integer masterDataDays;
        public String transDataDue;
        public String transDataReceived;
        public Integer transDataDays;
        public String lastClosed;
        public Integer lastClosedDays;
        public Integer iterations;
        public Boolean isPreferred;
        public Boolean isPrePreferred;
        public Boolean isNonPreferred;
        
        public EventObject(VDST_Event_gne__c event) {
            System.debug(LoggingLevel.Info, event.Id);
            eventId = event.VendorEventID_gne__c;
            eventStatus = event.CurrentStatus_gne__c;
            eventType = event.EventType_gne__c;
            firstName = event.AccountableGNE_FirstName_gne__c;
            lastName = event.AccountableGNE_LastName_gne__c;
            unixId = event.AccountableGNE_UnixID_gne__c;
            logVenName = event.LogisticVendorName_gne__c;
            logVenCode = event.LogisticVendorCode_gne__c;
            evEndDate = event.EventEndDate_gne__c.format();
            evMeetName = event.EventMeetingName_gne__c;
            contVenName = event.ContentVendorName_gne__c;
            totEvSpend = event.TotalEventSpend_gne__c;
            isPreferred = event.LogisticVendor_gne__r.IsPreferred_gne__c;
            isPrePreferred = event.LogisticVendor_gne__r.IsPrePreferred_gne__c;
            isNonPreferred = event.LogisticVendor_gne__r.IsNonPreferred_gne__c;
            // Date data
            masterDataDue = event.EventEndDate_gne__c.addDays(7).format();
            transDataDue = event.EventEndDate_gne__c.addDays(45).format();
            Date firstOccurredDate;
            Date firstClosedDate;
            Date lastClosedDate = event.CreatedDate.date();
            iterations = 0;
            for(VDST_Event_gne__History evh : event.Histories) {
                if( 'PENDING'.equals(evh.OldValue) && 'OCCURRED'.equals(evh.NewValue) ) {
                    if(firstOccurredDate == null || firstOccurredDate > evh.CreatedDate) {
                        firstOccurredDate = evh.CreatedDate.date();
                    }
                }
                if( 'CLOSED'.equals(evh.NewValue) ) {
                    if(firstClosedDate == null || firstClosedDate > evh.CreatedDate) {
                        firstClosedDate = evh.CreatedDate.date();
                    }
                    if(lastClosedDate < evh.CreatedDate) {
                        lastClosedDate = evh.CreatedDate.date();
                    }
                }
                if( 'CLOSED'.equals(evh.OldValue) && 'OCCURRED'.equals(evh.NewValue) ) {
                    iterations++;
                }
            }
            if( 'CLOSED'.equals(event.CurrentStatus_gne__c) ) {
                iterations++;
            }
            if(event.isBatch_gne__c) {
                firstClosedDate = event.CreatedDate.date();
            }
            if(firstClosedDate != null) {
                transDataReceived = firstClosedDate.format();
                transDataDays = event.EventEndDate_gne__c.daysBetween(firstClosedDate);
            }
            if(firstOccurredDate != null) {
                masterDataReceived = firstOccurredDate.format();
                masterDataDays = event.EventEndDate_gne__c.daysBetween(firstOccurredDate);
            } else if(firstClosedDate != null) {
                masterDataReceived = firstClosedDate.format();
                masterDataDays = event.EventEndDate_gne__c.daysBetween(firstClosedDate);
            }
            if(lastClosedDate != null) {
                lastClosed = lastClosedDate.format();
                lastClosedDays = event.EventEndDate_gne__c.daysBetween(lastClosedDate);
            }
        }
    }
}