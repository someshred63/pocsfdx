/************************************************************
*  @author: Kishore Chandolu, Genentech
*  Date: 2012-12-10
*  This is a Main Menu controller class
*
*  Modification History
*  Date        Name        Description
*************************************************************/
public class GNE_SFA2_Main_Menu_Ctrl {

    public static Integer MORE_MENU_COLUMN_SIZE {get; set;}
    public String errorMsg {get; set;}
    public List<List<GNE_SFA2_Dynamic_Comp_Bean>> myLinks {get; set;}
    public List<GNE_SFA2_Dynamic_Comp_Bean> menuList {get; set;}
    public String currentAppName { get; private set; }
    public Boolean mySetupAccess { get; private set; }
    public Boolean isMedAffairsUser {get; private set; }
    private Map<String, List<SFA2_User_Sales_Roster_gne__c>> salesRostersMap = new Map<String, List<SFA2_User_Sales_Roster_gne__c>>();

    public List<List<GNE_SFA2_Dynamic_Comp_Bean>> myLinksFirstColumn {get; set;}

    public String currentUser {get; set;}

    public GNE_SFA2_Main_Menu_Ctrl() {
        currentUser = JSON.serialize(new UserWrapper([SELECT Id, FirstName, LastName, Email, Phone, External_ID_gne__c, FullPhotoUrl, SmallPhotoUrl FROM User WHERE Id = : Userinfo.getUserId() LIMIT 1]));
        mySetupAccess = false;
        isMedAffairsUser = GNE_SFA2_Util.isMedAffairsUser();
        try {
            init();
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    private List<SFA2_User_Sales_Roster_gne__c> getUserSalesRostersForAvailableApps(Id userId) {
        return [ SELECT role_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, Sales_Roster_gne__r.type_gne__c, Sales_Roster_gne__r.Is_SFA2_Available_gne__c
                 FROM SFA2_User_Sales_Roster_gne__c WHERE User_gne__c = :userId AND Is_Active_gne__c = true AND Sales_Roster_gne__r.Is_SFA2_Available_gne__c = true
                         ORDER BY Sales_Roster_gne__r.type_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, role_gne__c ];
    }

    private void init () {
        // Get More Menu Popup Column Size From Custom Setting
        GNE_SFA2_Main_Menu_Settings__c settings = [SELECT More_Menu_Clumn_Size__c FROM GNE_SFA2_Main_Menu_Settings__c LIMIT 1];
        MORE_MENU_COLUMN_SIZE = Integer.valueOf(settings.More_Menu_Clumn_Size__c);

        myLinks = new List<List<GNE_SFA2_Dynamic_Comp_Bean>>();
        menuList = new List<GNE_SFA2_Dynamic_Comp_Bean>();
        List<SFA2_User_Sales_Roster_gne__c> userSalesRosterList = GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId());

        if (userSalesRosterList.size() == 0) {
            errorMsg = 'User Sales Roster Configuration is not valid.';
            System.debug(errorMsg);
        } else {
            for (SFA2_User_Sales_Roster_gne__c userSalesRosterItem : getUserSalesRostersForAvailableApps(UserInfo.getUserId())) {
                if (userSalesRosterItem.Sales_Roster_gne__r.Type_gne__c != GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c) {
                    if (salesRostersMap.get(userSalesRosterItem.Sales_Roster_gne__r.Type_gne__c) == null) {
                        salesRostersMap.put(userSalesRosterItem.Sales_Roster_gne__r.Type_gne__c, new List<SFA2_User_Sales_Roster_gne__c> { userSalesRosterItem });
                    } else {
                        salesRostersMap.get(userSalesRosterItem.Sales_Roster_gne__r.Type_gne__c).add(userSalesRosterItem);
                    }
                }
            }
            
            currentAppName = GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c;

            List<SFA2_Configuration_Object_gne__c> configObjectList =  [
                        SELECT Id, Name, Attributes_gne__c, (SELECT Id, Name, Label_gne__c, Attributes_gne__c, Order_gne__c, API_Name_gne__c FROM Configuration_Objects__r WHERE Is_Active_gne__c = true
                                AND Type_gne__c = 'Menu Item' Order BY Order_gne__c ASC) FROM SFA2_Configuration_Object_gne__c WHERE Role_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c AND Brand_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c
                                        AND Application_Type__c = :GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c AND Configuration_Type_gne__c = 'Menu Layout' AND Is_Active_gne__c = true ORDER BY order_gne__c ];

            Map<String, List<GNE_SFA2_Dynamic_Comp_Bean>> m_menuToMenuItemList = new Map<String, List<GNE_SFA2_Dynamic_Comp_Bean>>();

            for (SFA2_Configuration_Object_gne__c configObject : configObjectList) {
                // menu list
                GNE_SFA2_Dynamic_Comp_Bean menu = new GNE_SFA2_Dynamic_Comp_Bean();
                menu.strName = configobject.Name;
                if (configobject.Attributes_gne__c != null) {
                    List<String> attributes = (configobject.Attributes_gne__c).split(';');
                    if (attributes.size() > 0) {
                        menu.pageRef = attributes[0];
                    }
                    if (attributes.size() > 1) {
                        menu.imgSrc = attributes[1].trim();
                    }
                    if (attributes.size() > 2) {
                        menu.linkId = attributes[2];
                    }
                }
                menuList.add(menu);

                // menu item list (sub menu items)
                for (SFA2_Configuration_Object_Detail_gne__c configObjectDetail : configobject.Configuration_Objects__r) {
                    if(configObjectDetail.Label_gne__c == 'My Setup' && !mySetupAccess) {
                        mySetupAccess = true;
                    }

                    List<GNE_SFA2_Dynamic_Comp_Bean> menuItemList;
                    if (String.isNotEmpty(configObjectDetail.API_Name_gne__c) && configObjectDetail.API_Name_gne__c.equalsIgnoreCase('ApplicationsList')) {
                        for (String applicationType : salesRostersMap.keySet()) {
                            GNE_SFA2_Dynamic_Comp_Bean menuItem = new GNE_SFA2_Dynamic_Comp_Bean();
                            menuItem.strName = configObjectDetail.Name;
                            menuItem.apiName = configObjectDetail.API_Name_gne__c;
                            if (applicationType != GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c) {
                                if (applicationType.equalsIgnoreCase('SFA-US') && salesRostersMap.get(applicationType).size() > 1) {
                                    // multibrand scenario
                                    menuItem.strLabel = 'SFA 2.0';
                                    menuItem.pageRef = '/apex/GNE_SFA2_Application_Dispatcher?application=' + applicationType;
                                } else {
                                    if (salesRostersMap.get(applicationType)[0].Sales_Roster_gne__r.Brand_Name_gne__c == null) {
                                        menuItem.strLabel = salesRostersMap.get(applicationType)[0].Sales_Roster_gne__r.Type_gne__c;
                                    } else {
                                        menuItem.strLabel = salesRostersMap.get(applicationType)[0].Sales_Roster_gne__r.Type_gne__c + ' ' + salesRostersMap.get(applicationType)[0].Sales_Roster_gne__r.Brand_Name_gne__c;
                                    }
                                    menuItem.pageRef = '/apex/GNE_SFA2_Application_Dispatcher?application=' + applicationType;
                                }

                                menuItemList = m_menuToMenuItemList.get(configObjectDetail.Name);
                                if (menuItemList == null || menuItemList.size() == MORE_MENU_COLUMN_SIZE) {
                                    menuItemList = new List<GNE_SFA2_Dynamic_Comp_Bean>();
                                    m_menuToMenuItemList.put(configObjectDetail.Name, menuItemList);
                                    myLinks.add(menuItemList);
                                }
                                menuItemList.add(menuItem);
                            }
                        }
                    } else {
                        GNE_SFA2_Dynamic_Comp_Bean menuItem = new GNE_SFA2_Dynamic_Comp_Bean();
                        menuItem.strName = configObjectDetail.Name;
                        menuItem.strLabel = configObjectDetail.Label_gne__c;
                        if (configObjectDetail.Attributes_gne__c != null) {
                            menuItem.strAttribute = configObjectDetail.Attributes_gne__c;
                            List<String> strMenuItemArray = (menuItem.strAttribute).split(';');
                            if (strMenuItemArray.size() > 0) {
                                if (strMenuItemArray[0] == 'Revegy_Business_Planning') {
                                    menuItem.pageRef = GNE_SFA2_Revegy_Utils.getStandaloneUrl();
                                } else {
                                    menuItem.pageRef = strMenuItemArray[0];
                                }
                            }
                            if (strMenuItemArray.size() > 1) {
                                menuItem.imgSrc = strMenuItemArray[1].trim();
                            }
                            if (strMenuItemArray.size() > 2) {
                                menuItem.linkId = strMenuItemArray[2];
                            }
                        }
                        menuItemList = m_menuToMenuItemList.get(configObjectDetail.Name);
                        if (menuItemList == null || menuItemList.size() == MORE_MENU_COLUMN_SIZE) {
                            menuItemList = new List<GNE_SFA2_Dynamic_Comp_Bean>();
                            m_menuToMenuItemList.put(configObjectDetail.Name, menuItemList);
                            myLinks.add(menuItemList);
                        }
                        menuItemList.add(menuItem);
                    }
                }
            }
            if (GNE_SFA2_Util.isCanadaMSL()) {
	            GNE_SFA2_Dynamic_Comp_Bean synapseApp = new GNE_SFA2_Dynamic_Comp_Bean();
	            synapseApp.strName = 'External Links';
	            synapseApp.apiName = 'ApplicationsList';
	            synapseApp.strLabel = 'Synapse';
	            synapseApp.pageRef = GNE_SFA2_S2S_Config_Items_gne__c.getInstance('MABaseUrl').Value_gne__c;
            	myLinks.get(myLinks.size() -1).add(synapseApp);
            	
            	mySetupAccess = true;
            }
        }
    }

    public class UserWrapper {
        protected String fName;
        protected String lName;
        protected String email;
        protected String phone;
        protected String unixId;
        protected String photoUrl;

        public UserWrapper(User user) {
            this.fName = user.FirstName;
            this.lName = user.LastName;
            this.email = user.Email;
            this.phone = user.Phone;
            this.unixId = user.External_ID_gne__c;
            this.photoUrl = user.SmallPhotoUrl;
        }   

    }

    public class GNE_SFA2_Dynamic_Comp_Bean {
        public String strName { get; set; }
        public String apiName {get; set;}
        public String strLabel { get; set; }
        public String strAttribute { get; set; }
        public String pageRef { get; set; }
        public String linkId { get; set; }
        public String imgSrc { get; set; }
    }
}