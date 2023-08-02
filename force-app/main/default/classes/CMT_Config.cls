/**
 * Contains a collection of system configuration variables.
 */
public class CMT_Config
{
    // The email to which system error notifications are sent
    public static final String ERROR_NOTIFICATION_EMAIL = 'radoslaw.krawiec@roche.com';
    
    // Tells if new customer portal users can be created
    public static final Boolean CUSTOMER_PORTAL_REGISTRATION_ENABLED = true;
    
    // In case new customer portal user registration is disabled, all new users will default to this email address
    public static final String DEFAULT_NEW_CUSTOMER_PORTAL_USER = 'radoslaw.krawiec@roche.com.dev';
    
    public static final String DEFAULT_MEETING_ATTACHMENT_TYPE = 'Non-meeting attachment';
    
    public static final String MEETING_SOBJECT_NAME = 'CMT_Meeting_gne__c';
    
    public static final String NEW_HOTEL_PAGE = 'CMT_New_Hotel_Page';
    public static final String NEW_CONTACT_CATEGORY_PAGE = 'CMT_Contact_Category_Add';
    public static final String CONTACT_CATEGORY_VIEW = 'CMT_Contact_Category_View';
    public static final String NEW_CONTACT_PAGE = 'CMT_New_Contact_Page';
    public static final String NEW_ABSTRACT_PAGE = 'CMT_Abstract_Add';
    public static final String NEW_ABSTRACT_CATEGORY_PAGE = 'CMT_Abstract_Category_Add';
    public static final String ABSTRACT_CATEGORY_VIEW = 'CMT_Abstract_Category_View';
    public static final String SHUTTLE_VIEW = 'CMT_Shuttle_View';
    public static final String PARKING_VIEW = 'CMT_Parking_View';
    public static final String TAXI_COMPANY_VIEW = 'CMT_Taxi_Company_View';
    public static final String NEW_EVENT_PAGE = 'CMT_New_Hotel_Page';
    public static final String NEW_EXPO_PAGE = 'CMT_New_Hotel_Page';
    public static final String NEW_EXHIBIT_PAGE = 'CMT_New_Hotel_Page';
    public static final String NEW_MEET_GREEN_PAGE = 'CMT_New_Hotel_Page';
    
    // list pages
    public static final String PARKING_LIST = 'CMT_Parking_List';
    public static final String SHUTTLE_LIST = 'CMT_Shuttle_List';
    public static final String TAXI_COMPANY_LIST = 'CMT_Taxi_Company_List';
    public static final String HOTEL_LIST = 'CMT_Hotel_List';
    public static final String MEET_GREEN_LIST = 'CMT_MeetGreen_List';
    public static final String EXPO_LIST = 'CMT_Expo_List';
    public static final String EXHIBIT_LIST = 'CMT_Exhibit_List';
    public static final String EVENT_LIST = 'CMT_Event_List';
    public static final String INFORMATION_LIST = 'CMT_Information_List';
    public static final String ABSTRACT_CATEGORY_LIST = 'CMT_AbstractCategory_List';
    public static final String CONTACT_CATEGORY_LIST = 'CMT_ContactCategory_List';
    public static final String ANNOUNCEMENT_LIST = 'CMT_Announcement_List';
    
    // menu items, i.e. <Entity>_Group.Name properties
    public static final String ABSTRACT_GROUP_NAME = 'Abstracts';
    public static final String CONTACT_GROUP_NAME = 'Contacts';
    public static final String INFORMATION_GROUP_NAME = 'Information';
    public static final String MEET_GREEN_GROUP_NAME = 'Meet greens';
    public static final String TRANSPORTATION_GROUP_NAME = 'Transportation';
    public static final String HOTEL_GROUP_NAME = 'Hotels';
    public static final String ANNOUNCEMENT_GROUP_NAME = 'Announcements';
    public static final String EXHIBIT_GROUP_NAME = 'Exhibits';
    public static final String EVENT_GROUP_NAME = 'Events';
    public static final String EXPO_GROUP_NAME = 'Expos';
    public static final String AGENDA_GROUP_NAME = 'Agenda';
    
    public static final String AGENDA_VIEW_PAGE = 'CMT_Agenda_View';
    
    // The organization ID used to log in to the customer portal
    //public static final String ORG_ID = '00DQ0000000C2IJ';
    
    // The customer portal ID
    //public static final String PORTAL_ID = '060Q00000008onH';
}