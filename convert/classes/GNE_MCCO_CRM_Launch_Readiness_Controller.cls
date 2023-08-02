/* 
 * GNE_MCCO_CRM_Launch_Readiness_Controller
 *
 * Created By :     Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Created Date :   02/06/2015
 * 
 */
 public with sharing class GNE_MCCO_CRM_Launch_Readiness_Controller {
    
    public Boolean canEditPage { get; private set; }
    public Boolean canEditTargetCompletionDate { get; private set; }
    public String logoUrl { get; private set; }
    public List<GNE_MCCO_CRM_Launch_Readiness_Page__c> menuItems { get; private set; }
    public List<GNE_MCCO_CRM_Launch_Readiness_Page__c> launchReadinessItems { get; private set; }
    public List<GNE_MCCO_CRM_Launch_Readiness_Page__c> inlineBrandItems { get; private set; }
    public List<GNE_MCCO_CRM_Launch_Readiness_Page__c> marketingProgramItems { get; private set; }
    public List<GNE_MCCO_CRM_Launch_Readiness_Page__c> customerEngagementItems { get; private set; }
    public GNE_MCCO_CRM_Launch_Readiness_Page__c customerEngagementParent { get; private set; }
    private Map<String, GNE_MCCO_CRM_Launch_Readiness_Page__c> menuItemsMap { get; set; }
    public String menuItemsJson { get; private set; }
    public String menuItemsMapJson { get; private set; }
    public String userTimeZone { get; private set; }

    public GNE_MCCO_CRM_Launch_Readiness_Controller() {
        
        checkUserPermissionToEdit();
        logoUrl           = getACMLogoUrl();
        menuItems         = getMenuItems();
        menuItemsMap      = getMenuItemsMap();
        menuItemsJson     = JSON.serializePretty(menuItems);
        menuItemsMapJson  = JSON.serializePretty(menuItemsMap);
        userTimeZone      = String.valueOf(UserInfo.getTimeZone());
        setFilteredItems();        
    }
    
    private String getACMLogoUrl() {
        Document image = [SELECT ContentType, Body FROM Document WHERE DeveloperName = 'ACM_Logo' LIMIT 1][0];
        return 'data:' + image.ContentType + ';base64,' + EncodingUtil.base64Encode(image.Body);
    }
    
    private void checkUserPermissionToEdit() {
    	if (GNE_SFA2_Util.isBamCrmUser()){
    		GNE_BAM_CRM_Admin_Mode__c bamCRMAdminMode = GNE_BAM_CRM_Admin_Mode__c.getInstance();
        	canEditPage = bamCRMAdminMode != null && bamCRMAdminMode.Launch_Readiness_gne__c ? true : false;
        	canEditTargetCompletionDate = bamCRMAdminMode != null && bamCRMAdminMode.Target_Completion_Date_gne__c ? true : false;
    	} else {
        	GNE_MCCO_CRM_Admin_Mode__c mccoCRMAdminMode = GNE_MCCO_CRM_Admin_Mode__c.getInstance();
        	canEditPage = mccoCRMAdminMode != null && mccoCRMAdminMode.Launch_Readiness_gne__c ? true : false;
        	canEditTargetCompletionDate = mccoCRMAdminMode != null && mccoCRMAdminMode.Target_Completion_Date_gne__c ? true : false;
    	}
    }
    
    private List<GNE_MCCO_CRM_Launch_Readiness_Page__c> getMenuItems() {
        List<GNE_MCCO_CRM_Launch_Readiness_Page__c> result = new List<GNE_MCCO_CRM_Launch_Readiness_Page__c>();
        if(canEditPage) {
            result = [SELECT Id, Name, Title_gne__c, Active_gne__c, Banner_gne__c, Color_gne__c, Logo_gne__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate, Type_gne__c, Link_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Page__c ORDER BY Name];
        } else {
            result = [SELECT Id, Name, Title_gne__c, Active_gne__c, Banner_gne__c, Color_gne__c, Logo_gne__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate, Type_gne__c, Link_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Page__c WHERE Active_gne__c = true ORDER BY Name];
        }
        return result;
    }
    
    private Map<String, GNE_MCCO_CRM_Launch_Readiness_Page__c> getMenuItemsMap() {
        Map<String, GNE_MCCO_CRM_Launch_Readiness_Page__c> result = new Map<String, GNE_MCCO_CRM_Launch_Readiness_Page__c>();
        
        for(GNE_MCCO_CRM_Launch_Readiness_Page__c item : menuItems){ 
            result.put(item.Id, item);
        }
        
        return result;
    }

    private void setFilteredItems(){
        this.launchReadinessItems = new List<GNE_MCCO_CRM_Launch_Readiness_Page__c>();
        this.inlineBrandItems = new List<GNE_MCCO_CRM_Launch_Readiness_Page__c>();
        this.marketingProgramItems = new List<GNE_MCCO_CRM_Launch_Readiness_Page__c>();
        this.customerEngagementItems = new List<GNE_MCCO_CRM_Launch_Readiness_Page__c>();
        for(GNE_MCCO_CRM_Launch_Readiness_Page__c item: menuItems){
            if(item.Type_gne__c.equalsIgnoreCase('Launch Readiness')){
                this.launchReadinessItems.add(item);
            } else if(item.Type_gne__c.equalsIgnoreCase('Inline Brand')){
                this.inlineBrandItems.add(item);
            } else if(item.Type_gne__c.equalsIgnoreCase('Marketing Program')){
                this.marketingProgramItems.add(item);
            } else if(item.Type_gne__c.equalsIgnoreCase('Customer Engagement') && !item.Name.equalsIgnoreCase('Customer Engagement')){
                this.customerEngagementItems.add(item);
            } else if(item.Type_gne__c.equalsIgnoreCase('Customer Engagement') && item.Name.equalsIgnoreCase('Customer Engagement')){
                this.customerEngagementParent = item;
            }
        }
        this.customerEngagementItems = sortCustomerEngagementItems(this.customerEngagementItems);
    }

    private List<GNE_MCCO_CRM_Launch_Readiness_Page__c> sortCustomerEngagementItems(List<GNE_MCCO_CRM_Launch_Readiness_Page__c> engagementItems){
        Map<Integer, GNE_MCCO_CRM_Launch_Readiness_Page__c> orderedMap = new Map<Integer, GNE_MCCO_CRM_Launch_Readiness_Page__c>();
        Integer currentIndex = 2;
        for(GNE_MCCO_CRM_Launch_Readiness_Page__c lrp :engagementItems){
            if(lrp.Name.equalsIgnoreCase('Chapter Summary')){
                orderedMap.put(0, lrp);
            } else if(lrp.Name.equalsIgnoreCase('General Resources')){
                orderedMap.put(1, lrp);
            } else {
                orderedMap.put(currentIndex, lrp);
                currentIndex ++;
            }
        }
        List<GNE_MCCO_CRM_Launch_Readiness_Page__c> customerEngagementIt = new List<GNE_MCCO_CRM_Launch_Readiness_Page__c>();

        for(Integer i = 0; i < currentIndex; i++){
            customerEngagementIt.add(orderedMap.get(i));
        }
        return customerEngagementIt;
    }

    @RemoteAction
    @ReadOnly
    public static List<ContentWrapper> getContent(String pageId, Boolean canEditPage) {
        List<ContentWrapper> result = new List<ContentWrapper>();
        
        List<GNE_MCCO_CRM_Launch_Readiness_Content__c> launchReadinessContentList = new List<GNE_MCCO_CRM_Launch_Readiness_Content__c>();
        
        if(canEditPage) {
            launchReadinessContentList = [SELECT Id, Name, Active_gne__c, Content_gne__c, Target_Completion_Date_gne__c, Type_gne__c, Launch_Readiness_Page__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate FROM GNE_MCCO_CRM_Launch_Readiness_Content__c WHERE Launch_Readiness_Page__c = :pageId ORDER BY Order_gne__c];
        } else {
            launchReadinessContentList = [SELECT Id, Name, Active_gne__c, Content_gne__c, Target_Completion_Date_gne__c, Type_gne__c, Launch_Readiness_Page__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate FROM GNE_MCCO_CRM_Launch_Readiness_Content__c WHERE Launch_Readiness_Page__c = :pageId AND Active_gne__c = true ORDER BY Order_gne__c];
        }
        
        for(GNE_MCCO_CRM_Launch_Readiness_Content__c lrc : launchReadinessContentList) {
            String targetCompletionDate = '';
            if(lrc.Target_Completion_Date_gne__c != null) {
                String month = (String.valueOf(lrc.Target_Completion_Date_gne__c.month()).length() == 1 ? '0' : '') + lrc.Target_Completion_Date_gne__c.month();
                String day = (String.valueOf(lrc.Target_Completion_Date_gne__c.day()).length() == 1 ? '0' : '') + lrc.Target_Completion_Date_gne__c.day();
                String year = String.valueOf(lrc.Target_Completion_Date_gne__c.year());
                targetCompletionDate = month + '/' + day + '/' + year;
            }
            result.add(new ContentWrapper(lrc.Id, lrc.Launch_Readiness_Page__c, lrc.Name, lrc.Type_gne__c, lrc.Active_gne__c, lrc.Content_gne__c, targetCompletionDate, lrc.LastModifiedById, lrc.LastModifiedBy.Name, lrc.LastModifiedDate));
        }
        return result;
    }

    public class ContentWrapper {
        
        private Id id { get; set; }
        private Id parentId { get; set; }
        private String name { get; set; }
        private String type  {get; set; }
        private Boolean active { get; set; }
        private String content { get; set; }
        private String targetCompletionDate { get; set; }
        private Id lastModifiedById { get; set; }
        private String lastModifiedByName { get; set; }
        private DateTime lastModifiedDate { get; set; }

        public ContentWrapper(Id id, Id parentId, String name, String type, Boolean active, String content, String targetCompletionDate, Id lastModifiedById, String lastModifiedByName, DateTime lastModifiedDate) {
            this.id                     = id;
            this.parentId               = parentId;
            this.name                   = name;
            this.type                   = type;
            this.active                 = active;
            this.content                = content;
            this.targetCompletionDate   = targetCompletionDate;
            this.lastModifiedById       = lastModifiedById;
            this.lastModifiedByName     = lastModifiedByName;
            this.lastModifiedDate       = lastModifiedDate;
        }
    }
    
    @RemoteAction
    public static Map<String, Object> savePage(String id, String linkName, String name, String color, String banner, String logo, Boolean active, Boolean useDefaultTemplate, String copyId, String type, String link) {
        Map<String, Object> result = new Map<String, Object>();
        if(String.isNotBlank(link)){
            link = link.replace('&amp;','&').replace('&quot;','"');
        }
        try {
            GNE_MCCO_CRM_Launch_Readiness_Page__c pageToChange = new GNE_MCCO_CRM_Launch_Readiness_Page__c( Name = linkName, Title_gne__c = name, Color_gne__c = color, Banner_gne__c = banner, Logo_gne__c = logo, Active_gne__c = active, Type_gne__c = type, Link_gne__c = link); 
            
            result.put('action', 'new');
            
            if(!String.isEmpty(id)) {
                pageToChange.Id = id;
                result.put('action', 'edit');
            }
        
            upsert pageToChange;
            
            if(useDefaultTemplate || String.isNotBlank(copyId)) {
                createDefaultTemplateOrCopy(pageToChange.Id, copyId);
            }
            
            result.put('status', 'OK');
            result.put('name', pageToChange.Name);
            result.put('id', pageToChange.Id);
            result.put('record', [SELECT Id, Name, Title_gne__c, Active_gne__c, Banner_gne__c, Color_gne__c, Logo_gne__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate, Type_gne__c, Link_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Page__c WHERE Id = :pageToChange.Id][0]);
        } catch(Exception ex) {
            result.put('status', 'ERROR');
            result.put('errors', ex.getMessage());
        }
        
        return result;
    }
    
    private static Boolean createDefaultTemplateOrCopy(Id pageId, String copyId) {
        Boolean result = true;
        
        List<GNE_MCCO_CRM_Launch_Readiness_Content__c> sectionToInsert = new List<GNE_MCCO_CRM_Launch_Readiness_Content__c>();
        List<GNE_MCCO_CRM_Launch_Readiness_Content__c> sectionToCopy = new List<GNE_MCCO_CRM_Launch_Readiness_Content__c>();
        
        if(String.isNotBlank(copyId)) {
            sectionToCopy = [SELECT Id, Name, Active_gne__c, Content_gne__c, Order_gne__c, Launch_Readiness_Page__c, Target_Completion_Date_gne__c, Type_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Content__c WHERE Launch_Readiness_Page__c = :copyId];
        }
        
        try {
            
            Date dateToday = System.today();
            
            if(sectionToCopy.size() > 0) {
                
                // Copy existing section to new page
                for(GNE_MCCO_CRM_Launch_Readiness_Content__c section : sectionToCopy) {
                    
                    String content = (section.Type_gne__c == 'Page') ? section.Content_gne__c.replaceAll('href=\"[^\"]+\"', 'href="#"') : '#';
                    
                    sectionToInsert.add(new GNE_MCCO_CRM_Launch_Readiness_Content__c(
                        Name                            = section.Name, 
                        Active_gne__c                   = section.Active_gne__c, 
                        Content_gne__c                  = content, 
                        Launch_Readiness_Page__c        = pageId, 
                        Order_gne__c                    = section.Order_gne__c, 
                        Target_Completion_Date_gne__c   = section.Target_Completion_Date_gne__c, 
                        Type_gne__c                     = section.Type_gne__c
                    ));     
                    
                }
                
            } else {
    
                // Segmentation
                sectionToInsert.add(new GNE_MCCO_CRM_Launch_Readiness_Content__c(
                    Name                            = 'Segmentation', 
                    Active_gne__c                   = true, 
                    Content_gne__c                  = '<p>Instructions: Please review the segmentation of your account(s) by clicking the Account<br>Segmentation link below.</p><p><strong>Target completion date: </strong>{{ Target_Completion_Date }}</p><p><a href="#" target="_blank">Account Segmentation</a><br><a href="#" target="_blank">Request a Change</a></p>', 
                    Launch_Readiness_Page__c        = pageId, 
                    Order_gne__c                    = 0.0, 
                    Target_Completion_Date_gne__c   = dateToday, 
                    Type_gne__c                     = 'Page'
                ));     
                            
                // Launch Tracking
                sectionToInsert.add(new GNE_MCCO_CRM_Launch_Readiness_Content__c(
                    Name                            = 'Launch Tracking', 
                    Active_gne__c                   = true, 
                    Content_gne__c                  = '<p><strong>Background: </strong>The Launch Coverage Tracker is a simple way for Account Managers to review and validate third party data showing how accounts are covering our recent launches. The Tracker identifies and flags any access issues specific to payers and provides the opportunity to validate the coverage policy.</p><p><strong>Instructions: </strong>Once a month, Account Managers are asked to validate the product access data by payers to support launch tracking. Please follow the steps below to review the current policy by payer for a given product:</p><ol><li>Click on link below to access the Launch Coverage Tracker in OneSource</li><li>Login using your unix ID and password</li><li>Once logged in, please click on the file: <strong>OneSource-Dashboard.qvw</strong></li><li>Navigate to the "Launch Tracker" tab</li><li>Select product from the top drop-down box</li><li>Select your name from the lower drop-down box</li><li>Review product access information in the "Access / Parity" column and validate for accuracy</li><li>If the information is inaccurate, use the link provided at the bottom of the OneSource screen to submit a data inquiry</li><li>You will be contacted if clarity is needed and notified upon resolution</li></ol><p><strong>Target completion date: </strong>{{ Target_Completion_Date }}</p><p><a href="#" target="_blank">Launch Coverage Tracker</a></p>', 
                    Launch_Readiness_Page__c        = pageId, 
                    Order_gne__c                    = 1.0, 
                    Target_Completion_Date_gne__c   = dateToday, 
                    Type_gne__c                     = 'Page'
                ));     
                                        
                // Tools & Resources
                sectionToInsert.add(new GNE_MCCO_CRM_Launch_Readiness_Content__c(
                    Name                            = 'Tools & Resources', 
                    Active_gne__c                   = true, 
                    Content_gne__c                  = '#', 
                    Launch_Readiness_Page__c        = pageId, 
                    Order_gne__c                    = 2.0, 
                    Target_Completion_Date_gne__c   = dateToday, 
                    Type_gne__c                     = 'Link'
                ));
                
            }
            
            insert sectionToInsert;
            
        } catch (Exception ex) {
            result = false;
            System.debug(ex.getMessage());
        }
        
        return result;
    }
    
    @RemoteAction
    public static Map<String, Object> saveSection(String id, String pageId, String name, String type, String content, String order, Boolean active) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
        
            GNE_MCCO_CRM_Launch_Readiness_Content__c sectionToChange = new GNE_MCCO_CRM_Launch_Readiness_Content__c( Name = name, Content_gne__c = content, Active_gne__c = active, Type_gne__c = type); 
            
            if(!String.isEmpty(id)) {
                sectionToChange.Id = id;
            } else {
                sectionToChange.Launch_Readiness_Page__c = pageId;
                sectionToChange.Order_gne__c = Integer.valueOf(order);
            }

            upsert sectionToChange;
            
            GNE_MCCO_CRM_Launch_Readiness_Page__c page = updatePageAfterActionOnSection(pageId);
            
            result.put('name', sectionToChange.Name);
            result.put('id', sectionToChange.Id);
            result.put('pageId', pageId);
            result.put('LastModifiedDate', page.LastModifiedDate);
            result.put('LastModifiedById', page.LastModifiedById);
            result.put('LastModifiedByName', page.LastModifiedBy.Name);
            
            result.put('status', 'OK');
            
            
        } catch(Exception ex) {
            result.put('status', 'ERROR');
            result.put('errors', ex.getMessage());
        }
        
        return result;
    }
        
    @RemoteAction
    public static Map<String, String> saveTargetCompletionDate(String id, String targetCompletionDate) {
        Map<String, String> result = new Map<String, String>();
        
        try {
        
            GNE_MCCO_CRM_Launch_Readiness_Content__c sectionToUpdate = [SELECT Target_Completion_Date_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Content__c WHERE Id = :id LIMIT 1][0];
            
            List<String> dateExplode = targetCompletionDate.split('/', 0);
    
            sectionToUpdate.Target_Completion_Date_gne__c = date.parse(targetCompletionDate);
        
            update sectionToUpdate;
            result.put('status', 'OK');
            
        } catch(Exception ex) {
            result.put('status', 'ERROR');
            result.put('errors', ex.getMessage());
        }
        
        return result;
    }
            
    @RemoteAction
    public static Map<String, String> deletePage(String id) {
        Map<String, String> result = new Map<String, String>();

        try {
        
            GNE_MCCO_CRM_Launch_Readiness_Page__c pageToDelete = [SELECT Name FROM GNE_MCCO_CRM_Launch_Readiness_Page__c WHERE Id = :id];
            result.put('name', pageToDelete.Name);
            result.put('id', pageToDelete.Id);
            
            delete pageToDelete;
            result.put('status', 'OK');
            
        } catch(Exception ex) {
            result.put('status', 'ERROR');
            result.put('errors', ex.getMessage());
        }
        
        return result;
    }
                
    @RemoteAction
    public static Map<String, Object> deleteSection(String id) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            
            GNE_MCCO_CRM_Launch_Readiness_Content__c sectionToDelete = [SELECT Id, Name, Launch_Readiness_Page__c FROM GNE_MCCO_CRM_Launch_Readiness_Content__c WHERE Id = :id];

            result.put('name', sectionToDelete.Name);
            result.put('pageId', sectionToDelete.Launch_Readiness_Page__c);

            Id pageId = sectionToDelete.Launch_Readiness_Page__c;
            
            GNE_MCCO_CRM_Launch_Readiness_Page__c page = updatePageAfterActionOnSection(pageId);
            
            delete sectionToDelete;

            result.put('LastModifiedDate', page.LastModifiedDate);
            result.put('LastModifiedById', page.LastModifiedById);
            result.put('LastModifiedByName', page.LastModifiedBy.Name);
            
            result.put('status', 'OK');

        } catch(Exception ex) {
            result.put('status', 'ERROR');
            result.put('errors', ex.getMessage());
        }
        
        return result;
    }           
    
    @RemoteAction
    public static Map<String, Object> changeSectionOrder(String pageId, String orderObjectJson) {
        
        Map<String, Object> result = new Map<String, Object>();
        List<OrderWrapper> newSectionOrder = (List<OrderWrapper>)JSON.deserialize(orderObjectJson, List<OrderWrapper>.class);
        
        Map<String, Decimal> newSection = new Map<String, Decimal>();
        
        for(OrderWrapper sectionOrder : newSectionOrder) { 
            newSection.put(sectionOrder.id, Decimal.valueOf(sectionOrder.order));
        }

        try {
            
            List<GNE_MCCO_CRM_Launch_Readiness_Content__c> sections = [SELECT Id, Order_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Content__c WHERE Launch_Readiness_Page__c = :pageId];
            
            for(GNE_MCCO_CRM_Launch_Readiness_Content__c section : sections) {
                section.Order_gne__c = newSection.get(section.Id);
            }
            
            update sections;

            result.put('status', 'OK');

        } catch(Exception ex) {
            result.put('status', 'ERROR');
            result.put('errors', ex.getMessage());
        }
        
        return result;
    }
    
    @TestVisible
    private class OrderWrapper {
         
        public String id { get; set; }
        public Integer order { get; set; }
        
    }
    
    public static GNE_MCCO_CRM_Launch_Readiness_Page__c updatePageAfterActionOnSection(Id pageId) { 
        GNE_MCCO_CRM_Launch_Readiness_Page__c pageToUpdate = new GNE_MCCO_CRM_Launch_Readiness_Page__c(Id = pageId, Dummy_gne__c = generateRandomString(10));
        update pageToUpdate;
        return [SELECT LastModifiedDate, LastModifiedById, LastModifiedBy.Name, Dummy_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Page__c WHERE Id = :pageId];
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}