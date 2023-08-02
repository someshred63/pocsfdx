/**
 * A Commercial meeting
 */
public virtual class CMT_Meeting_Collections
{
    public CMT_Transportation_Group Transportation { get; private set; }
    public CMT_MeetGreen_Group MeetGreen { get; private set; }
    public CMT_Expo_Group Expo { get; private set; }
    public CMT_Exhibit_Group Exhibit { get; private set; }
    public CMT_Event_Group Event { get; private set; }
    public CMT_ContactCategory_Group Contact { get; private set; }
    public CMT_Agenda_Group Agenda { get; private set; }
    public CMT_Information_Group Information { get; private set; }
    public CMT_Hotel_Group Hotel { get; private set; }
    public CMT_Announcement_Group Announcement { get; private set; }
    public List<CMT_Attachment> Attachments { get; set; }
    public List<CMT_DeletedObject> DeletedObjects { get; set; }
    public List<CMT_ServerInfo> ServerInfo { get; private set; }
    
    public void setServerInfo (CMT_ServerInfo info)
    {
        if (ServerInfo == null)
        {
            ServerInfo = new List<CMT_ServerInfo>();
        }
        
        ServerInfo.clear();
        ServerInfo.add(info);
    }
    
    // The mobile app expects this element to have the name 'Abstract', however this is a reserved keyword and can't be used.
    // It will be replaced in the final JSON output before returning.
    public CMT_AbstractCategory_Group AbstractGroup { get; private set; }
    
    public CMT_Meeting_Collections (CMT_Meeting_gne__c meeting)
    {
        init(meeting, null);
    }
    
    public CMT_Meeting_Collections (CMT_Meeting_gne__c meeting, Datetime syncDate)
    {
        init(meeting, syncDate);
    }
    
    private void initDeletedObjects (Id meetingId, Datetime lastSyncDate)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        // always init this collection, even if no synchronization is perfomed
        this.DeletedObjects = new List<CMT_DeletedObject>();
        
        if (lastSyncDate == null)
        {
            return;
        }
        
        List<CMT_Deleted_Record_gne__c> objs = [SELECT Object_Id_gne__c, Object_Name_gne__c
                                                FROM CMT_Deleted_Record_gne__c
                                                WHERE Date_Deleted_gne__c >= :lastSyncDate AND Parent_Meeting_Id_gne__c = :meetingId];
                                                                    
        for (CMT_Deleted_Record_gne__c obj : objs)
        {
            this.DeletedObjects.add(new CMT_DeletedObject(obj));
        }     
    }
    
    /**
     * @param m - the meeting object
     */
    protected void init (CMT_Meeting_gne__c m, Datetime syncDate)
    {   
        // group attachments by parent ID
        Map<ID, List<CMT_Attachment>> groupedAttachments = CMT_JSONUtils.groupAttachments(m.Attachments__r);
        
        List<CMT_Attachment> allAttachments = groupedAttachments.get(m.Id);
        this.Attachments = new List<CMT_Attachment>();
        
        if (allAttachments != null)
        {
            // the meeting details object should not contain all of its attachments, only the background image
            for (CMT_Attachment a : allAttachments)
            {
                if (a.MeetingAttachmentType == 'Background')
                {
                    this.Attachments.add(a);
                    // don't look further
                    break;
                }
            }
        }
        
        // Make sure initDeletedObjects is called before initAgenda, because initAgenda requires the DeletedObjects collection to be set.
        // Also, make sure to always call initDeletedObjects, even if syncDate is null.
        initDeletedObjects(m.Id, syncDate);
        initTransportation(m, syncDate, groupedAttachments);
        initContactCategories(m, syncDate, groupedAttachments);
        initAbstractCategories(m, syncDate, groupedAttachments);
        initAgenda(m, syncDate, groupedAttachments);
        
        // init ordinary collections
        initMeetGreen(m, syncDate, groupedAttachments);
        initExpo(m, syncDate, groupedAttachments);
        initEvent(m, syncDate, groupedAttachments);
        initExhibit(m, syncDate, groupedAttachments);
        initHotel(m, syncDate, groupedAttachments);
        initInformation(m, syncDate, groupedAttachments);
        initAnnouncement(m, syncDate, groupedAttachments);
    }
    
    private void initMeetGreen (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Meet_Green_Groups__r != null && !m.Meet_Green_Groups__r.isEmpty())
        {
            CMT_Meet_Green_Group_gne__c mGroup = m.Meet_Green_Groups__r.get(0);
            
            MeetGreen = new CMT_MeetGreen_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
            
            List<CMT_Meet_Green_gne__c> objs = [SELECT Id, Name, Name_gne__c, LastModifiedDate
                                                FROM CMT_Meet_Green_gne__c
                                                WHERE Meet_Green_Group_gne__c = :mGroup.Id];// AND LastModifiedDate >= :syncDate];
            
            if (objs == null)
            {
                MeetGreen = null;
                return;
            }
                     
            for (CMT_Meet_Green_gne__c obj : objs)
            {
                // add hotel if it has changed or if its attachments have changed
                if (obj.LastModifiedDate >= syncDate || (groupedAttachments.get(obj.Id) != null && !groupedAttachments.get(obj.Id).isEmpty()))
                {
                    MeetGreen.add(new CMT_MeetGreen(obj, groupedAttachments.get(obj.Id)));
                }
            }
            
            // Changes in the group object itself are not taken into account in delta, so if the collections of changed attachments
            // and subobjects are empty, nothing has changed and the whole group is not returned                         
            if ((MeetGreen.MeetGreens == null || MeetGreen.MeetGreens.isEmpty()) && MeetGreen.Attachments.isEmpty())
            {
                MeetGreen = null;
                return;
            }
        }
    }
    
    private void initExpo (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Expo_Groups__r != null && !m.Expo_Groups__r.isEmpty())
        {
            CMT_Expo_Group_gne__c mGroup = m.Expo_Groups__r.get(0);
            
            Expo = new CMT_Expo_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
            
            List<CMT_Expo_gne__c> objs = [SELECT Id, Name, Description_gne__c, Location_gne__c
                                            FROM CMT_Expo_gne__c WHERE Group_gne__c = :mGroup.Id
                                                AND (LastModifiedDate >= :syncDate OR Id in :groupedAttachments.keySet())];
                                            
            // Changes in the group object itself are not taken into account in delta, so if the collections of changed attachments
            // and subobjects are empty, nothing has changed and the whole group is not returned                         
            if ((objs == null || objs.isEmpty()) && Expo.Attachments.isEmpty())
            {
                Expo = null;
                return;
            }
                                                
            for (CMT_Expo_gne__c obj : objs)
            {
                Expo.add(new CMT_Expo(obj, groupedAttachments.get(obj.Id)));
            }
        }
    }
    
    private void initAnnouncement (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Announcement_Groups__r != null && !m.Announcement_Groups__r.isEmpty())
        {
            CMT_Announcement_Group_gne__c mGroup = m.Announcement_Groups__r.get(0);
            
            Announcement = new CMT_Announcement_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
            
            List<CMT_Announcement_gne__c> objs = [SELECT Id, Name_gne__c, Description_gne__c, Record_Id_gne__c
                                            FROM CMT_Announcement_gne__c WHERE Group_gne__c = :mGroup.Id
                                                AND (LastModifiedDate >= :syncDate OR Id in :groupedAttachments.keySet())];
                                            
            // Changes in the group object itself are not taken into account in delta, so if the collections of changed attachments
            // and subobjects are empty, nothing has changed and the whole group is not returned                         
            if ((objs == null || objs.isEmpty()) && Announcement.Attachments.isEmpty())
            {
                Announcement = null;
                return;
            }
                                                
            for (CMT_Announcement_gne__c obj : objs)
            {
                Announcement.add(new CMT_Announcement(obj, groupedAttachments.get(obj.Id)));
            }
        }
    }
    
    private void initExhibit (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Exhibit_Groups__r != null && !m.Exhibit_Groups__r.isEmpty())
        {
            CMT_Exhibit_Group_gne__c mGroup = m.Exhibit_Groups__r.get(0);
            
            Exhibit = new CMT_Exhibit_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
            
            List<CMT_Exhibit_gne__c> objs = [SELECT Id, Name, Description_gne__c, Location_gne__c
                                            FROM CMT_Exhibit_gne__c WHERE Group_gne__c = :mGroup.Id
                                                AND (LastModifiedDate >= :syncDate OR Id in :groupedAttachments.keySet())];
                                            
            // Changes in the group object itself are not taken into account in delta, so if the collections of changed attachments
            // and subobjects are empty, nothing has changed and the whole group is not returned                         
            if ((objs == null || objs.isEmpty()) && Exhibit.Attachments.isEmpty())
            {
                Exhibit = null;
                return;
            }
                                                
            for (CMT_Exhibit_gne__c obj : objs)
            {
                Exhibit.add(new CMT_Exhibit(obj, groupedAttachments.get(obj.Id)));
            }
        }
    }
    
    private void initEvent (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Event_Groups__r != null && !m.Event_Groups__r.isEmpty())
        {
            CMT_Event_Group_gne__c mGroup = m.Event_Groups__r.get(0);
            
            Event = new CMT_Event_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
            
            List<CMT_Event_gne__c> objs = [SELECT Id, Name_gne__c, Event_Date_gne__c,Event_Time_gne__c
                                            FROM CMT_Event_gne__c WHERE Group_gne__c = :mGroup.Id
                                                AND (LastModifiedDate >= :syncDate OR Id in :groupedAttachments.keySet())];
                                            
            // Changes in the group object itself are not taken into account in delta, so if the collections of changed attachments
            // and subobjects are empty, nothing has changed and the whole group is not returned                         
            if ((objs == null || objs.isEmpty()) && Event.Attachments.isEmpty())
            {
                Event = null;
                return;
            }
                                                
            for (CMT_Event_gne__c obj : objs)
            {
                Event.add(new CMT_Event(obj, groupedAttachments.get(obj.Id)));
            }
        }
    }
    
    private void initInformation (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Information_Groups__r != null && !m.Information_Groups__r.isEmpty())
        {
            CMT_Information_Group_gne__c mGroup = m.Information_Groups__r.get(0);
            
            Information = new CMT_Information_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
            
            List<CMT_Information_gne__c> objs = [SELECT Id, Name, Description_gne__c, LastModifiedDate,
                                                        Yelp_Address_gne__r.Id, Yelp_Address_gne__r.Name, Yelp_Address_gne__r.City_gne__c, Yelp_Address_gne__r.Street_gne__c, 
                                                        Yelp_Address_gne__r.Zip_gne__c, Yelp_Address_gne__r.State_gne__c, Yelp_Address_gne__r.Phone_gne__c, Yelp_Address_gne__r.Yelp_gne__c,
                                                        Yelp_Address_gne__r.LastModifiedDate,
                                                        (SELECT Id, Name_gne__c, Longitude_gne__c, Latitude_gne__c, City_gne__c, Street_gne__c, Zip_gne__c, State_gne__c, Phone_gne__c, Yelp_gne__c FROM Addresses__r WHERE LastModifiedDate >= :syncDate)
                                                FROM CMT_Information_gne__c WHERE Group_gne__c = :mGroup.Id];
                                                
            for (CMT_Information_gne__c obj : objs)
            {
                if (obj.Yelp_Address_gne__r != null && obj.Yelp_Address_gne__r.LastModifiedDate < syncDate)
                {
                    obj.Yelp_Address_gne__r = null;
                }
                
                if (obj.LastModifiedDate >= syncDate || (obj.Addresses__r != null && !obj.Addresses__r.isEmpty()) || obj.Yelp_Address_gne__r != null || (groupedAttachments.get(obj.Id) != null && !groupedAttachments.get(obj.Id).isEmpty()))
                {
                    Information.add(new CMT_Information(obj, groupedAttachments.get(obj.Id)));
                }
            }
            
            // Changes in the group object itself are not taken into account in delta, so if the collections of changed attachments
            // and subobjects are empty, nothing has changed and the whole group is not returned                         
            if (Information.Infos.isEmpty() && Information.Attachments.isEmpty())
            {
                Information = null;
                return;
            }
        }
    }
    
    private void initHotel (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1970-01-01 00:00:00');
        
        if (m.Hotel_Groups__r != null && !m.Hotel_Groups__r.isEmpty())
        {
            CMT_Hotel_Group_gne__c mGroup = m.Hotel_Groups__r.get(0);
            
            Hotel = new CMT_Hotel_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
            
            List<CMT_Hotel_gne__c> objs = [SELECT Id, Name_gne__c, Description_gne__c, Website_gne__c, LastModifiedDate, Address_gne__r.LastModifiedDate,
                                                  Address_gne__r.Id, Address_gne__r.Name, Address_gne__r.City_gne__c, Address_gne__r.Street_gne__c, 
                                                  Address_gne__r.Zip_gne__c, Address_gne__r.State_gne__c, Address_gne__r.Phone_gne__c, Address_gne__r.Yelp_gne__c
                                            FROM CMT_Hotel_gne__c WHERE Group_gne__c = :mGroup.Id];// AND (LastModifiedDate >= :syncDate OR Address_gne__r.LastModifiedDate >= :syncDate)];
                                                
            for (CMT_Hotel_gne__c obj : objs)
            {
                if (obj.Address_gne__r.LastModifiedDate < syncDate)
                {
                    obj.Address_gne__r = null;
                }
                
                if (obj.Address_gne__r != null || obj.LastModifiedDate >= syncDate || (groupedAttachments.get(obj.Id) != null && !groupedAttachments.get(obj.Id).isEmpty()))
                {
                    Hotel.add(new CMT_Hotel(obj, groupedAttachments.get(obj.Id)));
                }
            }
            
            // Changes in the group object itself are not taken into account in delta, so if the collections of changed attachments
            // and subobjects are empty, nothing has changed and the whole group is not returned                         
            if (Hotel.Hotels.isEmpty() && Hotel.Attachments.isEmpty())
            {
                Hotel = null;
                return;
            }
        }
    }
    
    // Initializes collections of contact categories with subcolletions of contacts.
    // 
    // NOTE: this method has to have exactly the same logics/format as method initMethodAbstracts.
    private void initContactCategories (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Contact_Category_Groups__r != null && !m.Contact_Category_Groups__r.isEmpty())
        {
            CMT_Contact_Category_Group_gne__c mGroup = m.Contact_Category_Groups__r.get(0);
            
            this.Contact = new CMT_ContactCategory_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
            
            List<CMT_Contact_gne__c> contactItems = [SELECT Id, Category_gne__c, Title_gne__c, Phone_gne__c, Email_gne__c,
                                                     First_Name_gne__c, Last_Name_gne__c, Text_Number_gne__c, LastModifiedDate,
                                                     Category_gne__r.Id, Category_gne__r.Name, Category_gne__r.LastModifiedDate
                                                     FROM CMT_Contact_gne__c
                                                     WHERE Meeting_gne__c = :m.Id AND (LastModifiedDate >= :syncDate OR Category_gne__r.LastModifiedDate >= :syncDate)];
            
            Map<Id, CMT_ContactCategory> categoriesById = new Map<Id, CMT_ContactCategory>();
            
            boolean someCategoryHasAttachments = false;
            
            // group contacts by categories
            for (CMT_Contact_gne__c contactItem : contactItems)
            {
                // check if a category for this contact already exists on the list
                if (!categoriesById.containsKey(contactItem.Category_gne__c))
                {
                    categoriesById.put (contactItem.Category_gne__c, new CMT_ContactCategory(contactItem.Category_gne__r));
                }
                
                // if the contact itself hasn't changed, just its category, we don't add it to the collection
                if (contactItem.LastModifiedDate >= syncDate)
                {
                    //system.debug('attachments for contact ' + contactItem.Id + ' is ' + groupedAttachments.get(contactItem.Id));
                    categoriesById.get(contactItem.Category_gne__c).addContact(new CMT_Contact(contactItem, groupedAttachments.get(contactItem.Id)));
                }
            }
            
            // if there are no contacts, leave the contact entry uninitialized - but only if it contains no attachments to display
            if ((contactItems == null || contactItems.isEmpty()) && this.Contact.Attachments.isEmpty())
            {
                this.Contact = null;
                return;
            }
            
            this.Contact.ContactCategories = categoriesById.values();
        }
    }
    
    // Initializes collections of abstract categories with subcolletions of abstracts.
    // 
    // NOTE: this method has to have exactly the same logics/format as method initMethodCategories.
    private void initAbstractCategories (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Abstract_Category_Groups__r != null && !m.Abstract_Category_Groups__r.isEmpty())
        {
            CMT_Abstract_Category_Group_gne__c mGroup = m.Abstract_Category_Groups__r.get(0);
            
            this.AbstractGroup = new CMT_AbstractCategory_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
            
            List<CMT_Abstract_gne__c> abstractItems = [SELECT Id, Name, Category_gne__c, Item_gne__c, Title_gne__c, LastModifiedDate,
                                                     Category_gne__r.Id, Category_gne__r.Name, Category_gne__r.Category_Name_gne__c, Category_gne__r.LastModifiedDate
                                                     FROM CMT_Abstract_gne__c
                                                     WHERE Meeting_gne__c = :m.Id AND (LastModifiedDate >= :syncDate OR Category_gne__r.LastModifiedDate >= :syncDate OR Id in :groupedAttachments.keySet())];
            
            Map<Id, CMT_AbstractCategory> categoriesById = new Map<Id, CMT_AbstractCategory>();
            
            // if there are no abstracts, leave the contact entry uninitialized - but only if it contains no attachments to display
            if ((abstractItems == null || abstractItems.isEmpty()) && this.AbstractGroup.Attachments.isEmpty())
            {
                this.AbstractGroup = null;
                return;
            }
            
            // group abstracts by abstract
            for (CMT_Abstract_gne__c abstractItem : abstractItems)
            {
                // check if a category for this abstract already exists on the list
                if (!categoriesById.containsKey(abstractItem.Category_gne__c))
                {
                    categoriesById.put (abstractItem.Category_gne__c, new CMT_AbstractCategory(abstractItem.Category_gne__r));
                }
                
                List<CMT_Attachment> abstractAttachments = groupedAttachments.get(abstractItem.Id);
                
                // if the abstract itself hasn't changed, just its category, we don't add it to the collection
                if (abstractItem.LastModifiedDate >= syncDate || (abstractAttachments != null && !abstractAttachments.isEmpty()))
                {
                    categoriesById.get(abstractItem.Category_gne__c).addAbstract(new CMT_Abstract(abstractItem, abstractAttachments));
                }
            }
            
            this.AbstractGroup.AbstractCategories = categoriesById.values();
        }
    }
    
    private void initTransportation (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {   
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Transportation_Groups__r != null && !m.Transportation_Groups__r.isEmpty())
        {
            CMT_Transportation_Group_gne__c mGroup = m.Transportation_Groups__r.get(0);
            
            CMT_Transportation_gne__c obj = [SELECT Id, Name, Additional_Info_gne__c, LastModifiedDate,
                                                    (SELECT Id, Name, Description_gne__c, Type_gne__c FROM Shuttles__r WHERE LastModifiedDate >= :syncDate OR Id IN :groupedAttachments.keySet()),
                                                    (SELECT Id, Name, Company_Name_gne__c, Phone_gne__c FROM Taxi_Companies__r WHERE LastModifiedDate >= :syncDate OR Id IN :groupedAttachments.keySet()),
                                                    (SELECT Id, Name, Description_gne__c FROM Parkings__r WHERE LastModifiedDate >= :syncDate OR Id IN :groupedAttachments.keySet())
                                             FROM CMT_Transportation_gne__c
                                             WHERE Transportation_Group_gne__c = :mGroup.Id
                                             LIMIT 1];
            
            CMT_Transportation transportationObj = new CMT_Transportation(obj, groupedAttachments);
            
            // if all subcollections are empty and it was a delta query, then we return the main object only if it has changed since the delta date             
            if (lastSyncDate != null && obj.LastModifiedDate < lastSyncDate && 
                transportationObj.Shuttles.isEmpty() && 
                transportationObj.TaxiCompanies.isEmpty() &&
                transportationObj.Parkings.isEmpty())
            {
                transportationObj = null;
            }
            
            if (transportationObj != null)
            {
                Transportation = new CMT_Transportation_Group(mGroup.Id, mGroup.Name, groupedAttachments.get(mGroup.Id));
                Transportation.add(transportationObj);  
            }
        }
    }
    
    // Initializes agenda. If lastSyncDate is specified, only franchises or sessions that have changed are returned.
    private void initAgenda (CMT_Meeting_gne__c m, Datetime lastSyncDate, Map<ID, List<CMT_Attachment>> groupedAttachments)
    {   
        Datetime syncDate = lastSyncDate != null ? lastSyncDate : Datetime.valueOf('1900-01-01 00:00:00');
        
        if (m.Agendas__r == null || m.Agendas__r.isEmpty() || m.Commercial_Event_Sessions__r == null)
        {
            return;
        }
        
        CMT_Agenda_gne__c localAgenda = m.Agendas__r[0];
        
        List<CMT_FranchiseToSession_gne__c> franchisesToSession = [SELECT Id, Name,
                                                                          Session_gne__r.Id, Session_gne__r.Name, Session_gne__r.Description_gne__c,
                                                                          Session_gne__r.Start_Time_gne__c, Session_gne__r.End_Time_gne__c,
                                                                          Session_gne__r.Location_gne__c, Session_gne__r.Room_Name_gne__c, Session_gne__r.LastModifiedDate, 
                                                                          Franchise_gne__r.Id, Franchise_gne__r.Name, Franchise_gne__r.LastModifiedDate,
                                                                          CMT_Intermediate_Level_gne__r.Id, CMT_Intermediate_Level_gne__r.Name, CMT_Intermediate_Level_gne__r.Parent_Id_gne__c,
                                                                          CMT_Intermediate_Level_gne__r.Parent_Id_gne__r.Id, CMT_Intermediate_Level_gne__r.Parent_Id_gne__r.Name,
                                                                          CMT_Intermediate_Level_gne__r.Parent_Id_gne__r.Parent_Id_gne__c,LastModifiedDate
                                                                   FROM CMT_FranchiseToSession_gne__c
                                                                   WHERE Agenda_gne__c = :localAgenda.Id];             
                                                                   
        // create a new agenda (group)
        Agenda = new CMT_Agenda_Group(localAgenda.Id, localAgenda.Name, groupedAttachments.get(localAgenda.Id));
        
        if (groupedAttachments.get(localAgenda.Id) != null)
        {
            Agenda.Attachments = groupedAttachments.get(localAgenda.Id);
        }
        
        Map<ID, CMT_Session_gne__c> sessions = new Map<ID, CMT_Session_gne__c>();
        for (CMT_Session_gne__c session : m.Commercial_Event_Sessions__r)
        {
            sessions.put(session.Id, session);
        }
        
        Map<ID, List<CMT_DeletedObject>> deletedSessionsByFranchiseId = new Map<ID, List<CMT_DeletedObject>>();
        Map<ID, List<CMT_DeletedObject>> deletedIntermediateLevelsByFranchiseId = new Map<ID, List<CMT_DeletedObject>>();
		
        if (lastSyncDate != null)
        {
            deletedSessionsByFranchiseId = getDeletedSessionsByFranchiseId(m.Id, syncDate);
			deletedIntermediateLevelsByFranchiseId = getDeletedIntermediateLevelsByFranchiseId(m.Id, syncDate);
        }

        
        //System.debug('del = ' +deletedSessionsByFranchiseId);
        
        Map<Id, CMT_Franchise> franchisesById = new Map<Id, CMT_Franchise>();
        Map<Id, CMT_Intermediate_Level> intermediateLevelsById = new Map<Id, CMT_Intermediate_Level>();
        Map<Id,Map<Id,CMT_Intermediate_Level>> intermediateLevelsForFranchiseMap = new  Map<Id,Map<Id,CMT_Intermediate_Level>>();
        
        system.debug('------lastSyncDate'+lastSyncDate);
        system.debug('------deletedIntermediateLevelsByFranchiseId'+deletedIntermediateLevelsByFranchiseId);
        system.debug('-------------franchisesToSession'+franchisesToSession);
        
        for (CMT_FranchiseToSession_gne__c fts : franchisesToSession)
        {
            List<CMT_DeletedObject> deletedSessions = deletedSessionsByFranchiseId.get(fts.Franchise_gne__c);
			List<CMT_DeletedObject> deletedIntermediateLevels = deletedIntermediateLevelsByFranchiseId.get(fts.Franchise_gne__c);
            List<CMT_Attachment> franchiseAttachments = groupedAttachments.get(fts.Franchise_gne__c);
            List<CMT_Attachment> sessionAttachments = groupedAttachments.get(fts.Session_gne__c);
            
            // skip this entry if neither the session nor the franchise have changed, their attachments have not changed and no
            // sessions have been deleted from this franchise

            if (fts.Session_gne__r.LastModifiedDate < syncDate && fts.Franchise_gne__r.LastModifiedDate < syncDate
                && (deletedSessions == null || deletedSessions.isEmpty())
				&& (deletedIntermediateLevels == null || deletedIntermediateLevels.isEmpty())
                && (sessionAttachments == null || sessionAttachments.isEmpty())
                && (franchiseAttachments == null || franchiseAttachments.isEmpty()) )
            {
            	if(fts.LastModifiedDate < syncDate)
                	continue;
            }
            
            system.debug('----deletedIntermediateLevels'+deletedIntermediateLevels);
            if (!franchisesById.containsKey(fts.Franchise_gne__c))
            {   
                franchisesById.put (fts.Franchise_gne__c, new CMT_Franchise(fts.Franchise_gne__r, franchiseAttachments, deletedSessions, deletedIntermediateLevels));
            }
            
            // add this session only if it has been modified or contains new attachments
            if (fts.Session_gne__r.LastModifiedDate >= syncDate || (sessionAttachments != null && !sessionAttachments.isEmpty()))
            {
                franchisesById.get(fts.Franchise_gne__c).addSession(new CMT_Session(fts.Session_gne__r, sessionAttachments,fts.CMT_Intermediate_Level_gne__c));
            }
               
            if (!intermediateLevelsById.containsKey(fts.CMT_Intermediate_Level_gne__c) && fts.CMT_Intermediate_Level_gne__c != null)
            {   
                intermediateLevelsById.put(fts.CMT_Intermediate_Level_gne__c, new CMT_Intermediate_Level(fts.CMT_Intermediate_Level_gne__r));
            }
            
            if (fts.CMT_Intermediate_Level_gne__c != null)
            {
	            if(intermediateLevelsForFranchiseMap.containsKey(fts.Franchise_gne__c))
	        	{
	        		intermediateLevelsForFranchiseMap.get(fts.Franchise_gne__c).put(fts.CMT_Intermediate_Level_gne__c, new CMT_Intermediate_Level(fts.CMT_Intermediate_Level_gne__r));
	        		if(fts.CMT_Intermediate_Level_gne__r.Parent_Id_gne__c != null)
	        		{
	        			intermediateLevelsForFranchiseMap.get(fts.Franchise_gne__c).put(fts.CMT_Intermediate_Level_gne__r.Parent_Id_gne__c, new CMT_Intermediate_Level(fts.CMT_Intermediate_Level_gne__r.Parent_Id_gne__r));
	        		}
	        	}
	            else
	            { 
	            	Map<Id, CMT_Intermediate_Level> tempInerLevels = new Map<Id, CMT_Intermediate_Level>();
	            	tempInerLevels.put(fts.CMT_Intermediate_Level_gne__c, new CMT_Intermediate_Level(fts.CMT_Intermediate_Level_gne__r));
	            	if(fts.CMT_Intermediate_Level_gne__r.Parent_Id_gne__c != null)
	            	{
	            		tempInerLevels.put(fts.CMT_Intermediate_Level_gne__r.Parent_Id_gne__c, new CMT_Intermediate_Level(fts.CMT_Intermediate_Level_gne__r.Parent_Id_gne__r));
	            	}
	            	intermediateLevelsForFranchiseMap.put(fts.Franchise_gne__c,tempInerLevels);
	            }
            }
            system.debug('--------intermediateLevelsForFranchiseMap'+intermediateLevelsForFranchiseMap);
            
            if(intermediateLevelsForFranchiseMap.get(fts.Franchise_gne__c) != null)
            {
            	franchisesById.get(fts.Franchise_gne__c).IntermediateLevels = intermediateLevelsForFranchiseMap.get(fts.Franchise_gne__c).values().size() > 0? intermediateLevelsForFranchiseMap.get(fts.Franchise_gne__c).values(): new List<CMT_Intermediate_Level>();
            }
            
            //franchisesById.get(fts.Franchise_gne__c).IntermediateLevels = intermediateLevelsById.size() > 0? intermediateLevelsById.values(): new List<CMT_Intermediate_Level>();
        }
        
        Agenda.Franchises = franchisesById.values();
        
        // get empty franchises
        Agenda.Franchises.addAll(getEmptyFranchises(m.Id, franchisesById.keySet(), groupedAttachments, syncDate, deletedSessionsByFranchiseId,deletedIntermediateLevelsByFranchiseId));
        
        if ((Agenda.Franchises == null || Agenda.Franchises.isEmpty()) && Agenda.Attachments.isEmpty())
        {
            this.Agenda = null;
            return;
        }
    }
    
    // This method does the same as getEmptyFranchises and should be removed
    /*private List<CMT_FranchiseToSession_gne__c> addFranchisesWithoutSessions (List<CMT_FranchiseToSession_gne__c> franchisesToSession, Id meetingId)
    {
        // create a list of franchise IDs
        List<ID> franchiseIds = new List<ID>();
        
        for (CMT_FranchiseToSession_gne__c fts : franchisesToSession)
        {
            franchiseIds.add(fts.Franchise_gne__c);
        }
        
        // get all franchises for this meeting that have no session
        List<CMT_Franchise_gne__c> franchises = [SELECT Id, Name, LastModifiedDate FROM CMT_Franchise_gne__c WHERE Meeting_gne__c = :meetingId AND Id NOT IN :franchiseIds];
        
        // for each franchise, add a stub object with empty session to the fts list
        for (CMT_Franchise_gne__c franchise : franchises)
        {
            CMT_FranchiseToSession_gne__c fts = new CMT_FranchiseToSession_gne__c();
            fts.Franchise_gne__c = franchise.Id;
            fts.Meeting_gne__c = meetingId;
            
            franchisesToSession.add(fts);
        }
        
        return franchisesToSession;
    }*/
    
    private List<CMT_Franchise> getEmptyFranchises (Id meetingId, Set<Id> nonEmptyFranchiseIds, Map<ID, List<CMT_Attachment>> groupedAttachments, DateTime syncDate, Map<ID, List<CMT_DeletedObject>> deletedSessionsByFranchiseId, Map<ID, List<CMT_DeletedObject>> deletedIntermediateLevelsByFranchiseId)
    {
    	if (deletedSessionsByFranchiseId == null)
    	{
    		deletedSessionsByFranchiseId = new Map<ID, List<CMT_DeletedObject>>();
    	}
		
		if (deletedIntermediateLevelsByFranchiseId == null)
    	{
    		deletedIntermediateLevelsByFranchiseId = new Map<ID, List<CMT_DeletedObject>>();
    	}
    	
        List<CMT_Franchise_gne__c> franchises = [SELECT Id, Name FROM CMT_Franchise_gne__c WHERE Meeting_gne__c = :meetingId AND Id NOT IN :nonEmptyFranchiseIds AND (LastModifiedDate >= :syncDate OR Id IN :deletedSessionsByFranchiseId.keySet() OR Id IN :deletedIntermediateLevelsByFranchiseId.keySet())];
        
        List<CMT_Franchise> franchiseList = new List<CMT_Franchise>();
        
        for (CMT_Franchise_gne__c f : franchises)
        {
            List<CMT_DeletedObject> deletedSessions = deletedSessionsByFranchiseId != null ? deletedSessionsByFranchiseId.get(f.Id) : null;
			List<CMT_DeletedObject> deletedIntermediateLevels = deletedIntermediateLevelsByFranchiseId != null ? deletedIntermediateLevelsByFranchiseId.get(f.Id) : null;
            franchiseList.add(new CMT_Franchise(f, groupedAttachments.get(f.Id), deletedSessions,deletedIntermediateLevels)); 
        }
        
        return franchiseList;
    }
    
    // Gets the deleted sessions for each franchise
    private Map<ID, List<CMT_DeletedObject>> getDeletedSessionsByFranchiseId (ID meetingId, DateTime syncDate)
    {
        Map<ID, List<CMT_DeletedObject>> sessions = new Map<ID, List<CMT_DeletedObject>>();
        
        List<CMT_Deleted_Franchise_To_Session_gne__c> deletedObjs = [SELECT Session_gne__c, Franchise_gne__c
                                                                     FROM CMT_Deleted_Franchise_To_Session_gne__c
                                                                     WHERE Parent_Meeting_Id_gne__c = :meetingId AND Date_Deleted_gne__c >= :syncDate];
                                                                    
        for (CMT_Deleted_Franchise_To_Session_gne__c delObj : deletedObjs)
        {
            if (!sessions.containsKey(delObj.Franchise_gne__c))
            {
                sessions.put (delObj.Franchise_gne__c, new List<CMT_DeletedObject>());
            }
            
            sessions.get(delObj.Franchise_gne__c).add(new CMT_DeletedObject(delObj.Session_gne__c));
        }
        
        return sessions;
    }
	
	private Map<ID, List<CMT_DeletedObject>> getDeletedIntermediateLevelsByFranchiseId (ID meetingId, DateTime syncDate)
    {
        Map<ID, List<CMT_DeletedObject>> intermediateLevels = new Map<ID, List<CMT_DeletedObject>>();
        
        List<CMT_Deleted_Franchise_To_Session_gne__c> deletedObjs = [SELECT Franchise_gne__c,Intermediate_Level_gne__c
                                                                     FROM CMT_Deleted_Franchise_To_Session_gne__c
                                                                     WHERE Parent_Meeting_Id_gne__c = :meetingId AND Date_Deleted_gne__c >= :syncDate];
        Set<String> intermediateLevelsIds = new Set<String>(); 
        for(CMT_Deleted_Franchise_To_Session_gne__c delObj : deletedObjs)
        {
        	intermediateLevelsIds.add(delObj.Intermediate_Level_gne__c);
        } 
        List<CMT_Intermediate_Level_gne__c> intermediateLevelsDeleted = [Select id from CMT_Intermediate_Level_gne__c where id in :intermediateLevelsIds and isDeleted=true ALL ROWS];
        Set<ID> intermediateLevelsDeletedIds = new Set<ID>();  
        for(CMT_Intermediate_Level_gne__c im: intermediateLevelsDeleted)
        {
        	intermediateLevelsDeletedIds.add(im.id);
        }                                                          
        for (CMT_Deleted_Franchise_To_Session_gne__c delObj : deletedObjs)
        {
        	if(intermediateLevelsDeletedIds.contains(delObj.Intermediate_Level_gne__c))
        	{
	            if (!intermediateLevels.containsKey(delObj.Franchise_gne__c))
	            {
	                intermediateLevels.put (delObj.Franchise_gne__c, new List<CMT_DeletedObject>());
	            }
	            
	            intermediateLevels.get(delObj.Franchise_gne__c).add(new CMT_DeletedObject(delObj.Intermediate_Level_gne__c));
        	}
        }
        
        return intermediateLevels;
    }
    
    public static String convertSyncDateToOrgTimezone (Datetime syncDate)
    {
        DateTime notNullSyncTime = syncDate != null ? syncDate : Datetime.valueOf('1900-01-01 00:00:00');
        String syncTimeS = notNullSyncTime.format('yyyy-MM-dd hh:mm:ss', 'GMT');
   
        return syncTimeS;
        //return DateTime.valueOf(syncTimeS);
    }
}