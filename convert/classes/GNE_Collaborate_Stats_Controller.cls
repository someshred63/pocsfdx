public without sharing class GNE_Collaborate_Stats_Controller {
    
    public String collGroupsJSON {get; private set;}
    // Export to CSV
    private final Date TODAY = Date.today();
    public String fileName { get; private set; }
    public List<String> groupsList { get; private set; }
    public Map<String, Integer> feedsCountExportToCsv { get; private set; }
    public Map<String, Map<String, Integer>> feedTypesCountExportToCsv { get; private set; }
    public Map<String, Map<String, Integer>> feedsTrendPerGroupExportToCsv { get; private set; }
    public Map<String, Map<String, Integer>> userActivityPerGroupExportToCsv { get; private set; }
    public Map<String, Map<String, Integer>> detailedUserActivityPerGroupExportToCsv { get; private set; }
    public Map<String, Map<String, Map<String, Decimal>>> userLinksCountExportToCsv { get; private set; }
    public Boolean feedsCountBoolen { get; private set; }
    public Boolean feedTypesCountBoolean { get; private set; }
    public Boolean feedsTrendPerGroupBoolean { get; private set; }
    public Boolean userActivityPerGroupBoolean { get; private set; }
    public Boolean userLinksCountBoolean { get; private set; }
    public Boolean isUserSelected { get; private set; }

    public GNE_Collaborate_Stats_Controller() {
        collGroupsJSON = buildJSONCollGroups();
    }

    private String buildJSONCollGroups() {
        Set<String> result = new Set<String>();
        for(FeedItem feed : [SELECT Parent.Name FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup)]) {
            result.add(feed.Parent.Name);
        }
        return JSON.serialize(result);
    }

    @RemoteAction 
    public static List<FeedsCount> getFeedsCount(String dateFrom, String dateTo, String groupsName) {
        List<FeedsCount> result = new List<FeedsCount>();
        Map<String, Integer> groupMap = new Map<String, Integer>();

        String query = 'SELECT Parent.Name FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, false);
        List<FeedItem> feedsList = Database.query(query);
        for(FeedItem feed : feedsList) {
            if(!groupMap.containsKey(feed.Parent.Name)) {
                groupMap.put(feed.Parent.Name, 1);
            } else {
                groupMap.put(feed.Parent.Name, groupMap.get(feed.Parent.Name) + 1);
            }
        }

        for(String groupName : groupMap.keySet()) {
            result.add(new FeedsCount(groupName, groupMap.get(groupName)));
        }
        
        result.sort();
        return result;
    }

    @RemoteAction
    public static List<FeedTypesCount> getFeedTypesCount(String dateFrom, String dateTo, String groupsName) {
        List<FeedTypesCount> result = new List<FeedTypesCount>();
        Map<String, Map<String, Integer>> groupMap = new Map<String, Map<String, Integer>>();

        String query = 'SELECT Type, Parent.Name, LikeCount FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, false);
        List<FeedItem> feedsList = Database.query(query);
        for(FeedItem feed : feedsList) {
            if(!groupMap.containsKey(feed.Parent.Name)) {
                groupMap.put(feed.Parent.Name, new Map<String, Integer>());
                groupMap.get(feed.Parent.Name).put(feed.Type, 1);
                groupMap.get(feed.Parent.Name).put('LikeCount', feed.LikeCount);
            } else {
                if(!groupMap.get(feed.Parent.Name).containsKey(feed.Type)) {
                    groupMap.get(feed.Parent.Name).put(feed.Type, 1);
                } else {
                    groupMap.get(feed.Parent.Name).put(feed.Type, groupMap.get(feed.Parent.Name).get(feed.Type) + 1);
                }
                groupMap.get(feed.Parent.Name).put('LikeCount', groupMap.get(feed.Parent.Name).get('LikeCount') + feed.LikeCount);
            }
        }

        for(String groupName : groupMap.keySet()) {
            result.add(new FeedTypesCount(groupName, groupMap.get(groupName)));
        }

        result.sort();
        return result;
    }

    @RemoteAction
    public static List<FeedsTrend> getFeedsTrend(String dateFrom, String dateTo, String groupsName) {
        List<FeedsTrend> result = new List<FeedsTrend>();
        Map<String, Map<String, Integer>> tempMap = new Map<String, Map<String, Integer>>();

        String query = 'SELECT CreatedDate, Parent.Name FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, false) + ' ORDER BY CreatedDate';
        List<FeedItem> feedsList = Database.query(query);

        for(FeedItem feed : feedsList) {
            if(!tempMap.containsKey(feed.Parent.Name)) {
                tempMap.put(feed.Parent.Name, new Map<String, Integer>());
                tempMap.get(feed.Parent.Name).put(feed.CreatedDate.format('MM-dd-yyyy'), 1);
            } else {
                if(!tempMap.get(feed.Parent.Name).containsKey(feed.CreatedDate.format('MM-dd-yyyy'))) {
                    tempMap.get(feed.Parent.Name).put(feed.CreatedDate.format('MM-dd-yyyy'), 1);
                } else {
                    tempMap.get(feed.Parent.Name).put(feed.CreatedDate.format('MM-dd-yyyy'), tempMap.get(feed.Parent.Name).get(feed.CreatedDate.format('MM-dd-yyyy')) + 1);
                }
            }
        }

        for(String groupName : tempMap.keySet()) {
                result.add(new FeedsTrend(groupName, tempMap.get(groupName)));
        }

        result.sort();
        return result;
    }

    @RemoteAction
    public static List<UserActivity> getUserActivityPerGroup(String dateFrom, String dateTo, String groupsName) {
        List<UserActivity> result = new List<UserActivity>();
        Map<String, Map<String, Integer>> tempMap = new Map<String, Map<String, Integer>>();

        String query = 'SELECT Createdby.Name, Parent.Name, (select CreatedBy.Name from FeedLikes) FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, false);
        List<FeedItem> feedsList = Database.query(query);
        for(FeedItem feed : feedsList) {
            if(!tempMap.containsKey(feed.Createdby.Name)) {
                tempMap.put(feed.Createdby.Name, new Map<String, Integer>());
                tempMap.get(feed.Createdby.Name).put(feed.Parent.Name, 1);
            } else {
                if(!tempMap.get(feed.Createdby.Name).containsKey(feed.Parent.Name)) {
                    tempMap.get(feed.Createdby.Name).put(feed.Parent.Name, 1);
                } else {
                    tempMap.get(feed.Createdby.Name).put(feed.Parent.Name, tempMap.get(feed.Createdby.Name).get(feed.Parent.Name) + 1);
                }
            }
        }

        for(FeedItem feed : feedsList) {
            for(FeedLike fLike :feed.FeedLikes){
                if(!tempMap.containsKey(fLike.Createdby.Name)) {
                    tempMap.put(fLike.Createdby.Name, new Map<String, Integer>());
                    tempMap.get(fLike.Createdby.Name).put(feed.Parent.Name, 1);
                } else {
                    if(!tempMap.get(fLike.Createdby.Name).containsKey(feed.Parent.Name)) {
                        tempMap.get(fLike.Createdby.Name).put(feed.Parent.Name, 1);
                    } else {
                        tempMap.get(fLike.Createdby.Name).put(feed.Parent.Name, tempMap.get(fLike.Createdby.Name).get(feed.Parent.Name) + 1);
                    }
                }
            }
        }

        Map<String, String> usersPhotoMap = new Map<String, String>();
        Map<String, String> usersId = new Map<String, String>();
        for(User u : [SELECT Id, Name, SmallPhotoUrl FROM User WHERE Name IN : tempMap.keySet()]) {
            usersPhotoMap.put(u.Name, u.SmallPhotoUrl);
            usersId.put(u.Name, u.Id);
        }

        for(String userName : tempMap.keySet()) {
            result.add(new UserActivity(usersId.get(userName), userName, usersPhotoMap.get(userName), tempMap.get(userName)));
        }
        
        result.sort();
        return result;
    }

    @RemoteAction
    public static List<FeedTypesCount> getFeedTypesCountForUser(String userId, String dateFrom, String dateTo, String groupsName) {
        List<FeedTypesCount> result = new List<FeedTypesCount>();
        Map<String, Map<String, Integer>> groupMap = new Map<String, Map<String, Integer>>();

        String query = 'SELECT Type, Parent.Name FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, false) + ' AND CreatedbyId = :userId';
        List<FeedItem> feedsList = Database.query(query);
        for(FeedItem feed : feedsList) {
            if(!groupMap.containsKey(feed.Parent.Name)) {
                groupMap.put(feed.Parent.Name, new Map<String, Integer>());
                groupMap.get(feed.Parent.Name).put(feed.Type, 1);
            } else {
                if(!groupMap.get(feed.Parent.Name).containsKey(feed.Type)) {
                    groupMap.get(feed.Parent.Name).put(feed.Type, 1);
                } else {
                    groupMap.get(feed.Parent.Name).put(feed.Type, groupMap.get(feed.Parent.Name).get(feed.Type) + 1);
                }
            }
        }


        String likequery = 'SELECT Type, Parent.Name, (select CreatedById from FeedLikes WHERE CreatedbyId = :userId) FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, false);
        List<FeedItem> feedsListWithLikes = Database.query(likequery);
        for(FeedItem feed : feedsListWithLikes) {
            if(feed.FeedLikes.size()>0){
                if(!groupMap.containsKey(feed.Parent.Name)) {
                    groupMap.put(feed.Parent.Name, new Map<String, Integer>());
                    groupMap.get(feed.Parent.Name).put('LikeCount', feed.FeedLikes.size());
                } else {
                    if(!groupMap.get(feed.Parent.Name).containsKey('LikeCount')) {
                       groupMap.get(feed.Parent.Name).put('LikeCount', feed.FeedLikes.size());
                    } else {
                        groupMap.get(feed.Parent.Name).put('LikeCount', groupMap.get(feed.Parent.Name).get('LikeCount') + feed.FeedLikes.size());
                    }
                }
            }
        }

        for(String groupName : groupMap.keySet()) {
            result.add(new FeedTypesCount(groupName, groupMap.get(groupName)));
        }

        result.sort();
        return result;
    }

    @RemoteAction
    public static LinkStat getUserLinksCount(String groupsName) {

        Map<String, Map<String, Map<String, Decimal>>> tempMap = new Map<String, Map<String, Map<String, Decimal>>>();

        String stringFromGroupIds = GNE_Collaborate_Stats_Controller.getStringFromGroupIds(groupsName);

        String query = 'SELECT CreatedBy.Name, Count_gne__c, Link_name_gne__c, GroupId_gne__c, Url_gne__c FROM GNE_Collaborate_Link_Stat__c WHERE GroupId_gne__c IN (' + stringFromGroupIds + ') OR GroupId_gne__c = null';
        
        List<GNE_Collaborate_Link_Stat__c> linkStatList = Database.query(query);

        Set<String> userNameSet = new Set<String>();
        Map<String, Map<String, String>> chatterGroupNameSet = new Map<String, Map<String, String>>();
        Map<String, String> groupNameMap = GNE_Collaborate_Stats_Controller.getMapFromGroupIds(groupsName);
        
        for(GNE_Collaborate_Link_Stat__c linkStat : linkStatList) {

            userNameSet.add(linkStat.CreatedBy.Name);

            if(!chatterGroupNameSet.containsKey(linkStat.GroupId_gne__c)) {
                chatterGroupNameSet.put(linkStat.GroupId_gne__c, new Map<String, String>());
                chatterGroupNameSet.get(linkStat.GroupId_gne__c).put(linkStat.Link_name_gne__c, linkStat.Url_gne__c);
            } else {
                chatterGroupNameSet.get(linkStat.GroupId_gne__c).put(linkStat.Link_name_gne__c, linkStat.Url_gne__c);
            }


            if(!tempMap.containsKey(linkStat.GroupId_gne__c)) {

                tempMap.put(linkStat.GroupId_gne__c, new Map<String, Map<String, Decimal>>());

                if(!tempMap.get(linkStat.GroupId_gne__c).containsKey(linkStat.CreatedBy.Name)) {
                    
                    tempMap.get(linkStat.GroupId_gne__c).put(linkStat.CreatedBy.Name, new Map<String, Decimal>());
                    tempMap.get(linkStat.GroupId_gne__c).get(linkStat.CreatedBy.Name).put(linkStat.Link_name_gne__c, linkStat.Count_gne__c);

                } else {

                    tempMap.get(linkStat.GroupId_gne__c).get(linkStat.CreatedBy.Name).put(linkStat.Link_name_gne__c, linkStat.Count_gne__c);

                }

            } else {

                if(!tempMap.get(linkStat.GroupId_gne__c).containsKey(linkStat.CreatedBy.Name)) {
                    
                    tempMap.get(linkStat.GroupId_gne__c).put(linkStat.CreatedBy.Name, new Map<String, Decimal>());
                    tempMap.get(linkStat.GroupId_gne__c).get(linkStat.CreatedBy.Name).put(linkStat.Link_name_gne__c, linkStat.Count_gne__c);

                } else {

                    tempMap.get(linkStat.GroupId_gne__c).get(linkStat.CreatedBy.Name).put(linkStat.Link_name_gne__c, linkStat.Count_gne__c);

                }

            }

        }

        Map<String, String> usersPhotoMap = new Map<String, String>();
        for(User u : [SELECT Name, SmallPhotoUrl FROM User WHERE Name IN : userNameSet]) {
            usersPhotoMap.put(u.Name, u.SmallPhotoUrl);
        }

        LinkStat result = new LinkStat(groupNameMap, chatterGroupNameSet, tempMap, usersPhotoMap);

        return result;
    }

    // WRAPPER CLASSES
    private class FeedsCount implements Comparable {
        private String groupName {get; set;}
        private Integer count {get; set;}

        public FeedsCount(String groupName, Integer count) {
            this.groupName = groupName;
            this.count = count;
        }

        public Integer compareTo(Object compareTo) {
            FeedsCount comparableData = (FeedsCount)compareTo;
            Integer result = 0;
            if (this.groupName == comparableData.groupName) {
                result = 0;
            } else if (this.groupName > comparableData.groupName) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }
    }

    private class FeedTypesCount implements Comparable {
        private String groupName {get; set;}
        private Map<String, Integer> count {get; set;}

        public FeedTypesCount (String groupName, Map<String, Integer> count) {
            this.groupName = groupName;
            this.count = count;
        }

        public Integer compareTo(Object compareTo) {
            FeedTypesCount comparableData = (FeedTypesCount)compareTo;
            Integer result = 0;
            if (this.groupName == comparableData.groupName) {
                result = 0;
            } else if (this.groupName > comparableData.groupName) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }
    }

    private class UserActivity implements Comparable {
        private String userId {get; set;}
        private String userName {get; set;}
        private String userPhotoUrl {get; set;}
        private Map<String, Integer> count {get; set;}

        public UserActivity (String userId, String userName, String userPhotoUrl, Map<String, Integer> count) {
            this.userId = userId;
            this.userName = userName;
            this.userPhotoUrl = userPhotoUrl;
            this.count = count;
        }

        public Integer compareTo(Object compareTo) {
            UserActivity comparableData = (UserActivity)compareTo;
            Integer result = 0;
            if (this.userName == comparableData.userName) {
                result = 0;
            } else if (this.userName > comparableData.userName) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }
    }

    private class FeedsTrend implements Comparable {
        private String groupName {get; set;}
        private Map<String, Integer> count {get; set;}

        public FeedsTrend (String groupName, Map<String, Integer> count) {
            this.groupName = groupName;
            this.count = count;
        }

        public Integer compareTo(Object compareTo) {
            FeedsTrend comparableData = (FeedsTrend)compareTo;
            Integer result = 0;
            if (this.groupName == comparableData.groupName) {
                result = 0;
            } else if (this.groupName > comparableData.groupName) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }
    }

    private class LinkStat {
        private Map<String, String> groupNames {get; set;}
        private Map<String, Map<String, String>> chatterGroupNames {get; set;}
        private Map<String, Map<String, Map<String, Decimal>>> items {get;set;}
        private Map<String, String> usersPhoto {get;set;}

        public LinkStat (Map<String, String> groupNames, Map<String, Map<String, String>> chatterGroupNames, Map<String, Map<String, Map<String, Decimal>>> items, Map<String, String> usersPhoto) {
            this.groupNames = groupNames;
            this.chatterGroupNames = chatterGroupNames;
            this.items = items;
            this.usersPhoto = usersPhoto;
        }

    }

    /*
     * public exportToCSV()
     *
     * Called from GNE_Collaborate_Stats_Export.page as Action with $_GET parameters: type, dateFrom, dateTo, groupsName
     *
     * return void
     */
    public void exportToCSV() {

        feedsCountBoolen = false;
        feedTypesCountBoolean = false;
        feedsTrendPerGroupBoolean = false;
        userActivityPerGroupBoolean = false;
        isUserSelected = false;


        String type, dateFrom, dateTo, groupsName, userId;

        // Get all parameters from URL, if not set default parameter
        type = (apexpages.currentpage().getparameters().get('type')!=null) ? apexpages.currentpage().getparameters().get('type') : 'feedsCount';
        dateFrom = (apexpages.currentpage().getparameters().get('dateFrom')!=null) ? apexpages.currentpage().getparameters().get('dateFrom') : TODAY.addMonths(-2).format();
        dateTo = (apexpages.currentpage().getparameters().get('dateTo')!=null) ? apexpages.currentpage().getparameters().get('dateTo') : TODAY.format();
        groupsName = (apexpages.currentpage().getparameters().get('groupsName')!=null) ? apexpages.currentpage().getparameters().get('groupsName') : GNE_Collaborate_Stats_Controller.getAllGroupsAsString();
        userId = (apexpages.currentpage().getparameters().get('userId')!=null) ? apexpages.currentpage().getparameters().get('userId') : null;

        this.groupsList = GNE_Collaborate_Stats_Controller.getAllGroupsAsString().split(', ');

        // Feeds Count
        if(type=='feedsCount') {
            fileName = this.getFilename('feeds_count_report');
            feedsCountBoolen = true;
            feedsCountExportToCsv = this.getFeedsCountForExport(dateFrom, dateTo, groupsName);
        // Feed Types Count
        } else if (type=='feedTypesCount') {
            fileName = this.getFilename('feed_types_count_report');
            feedTypesCountBoolean = true;
            feedTypesCountExportToCsv = this.getFeedTypesCountForExport(dateFrom, dateTo, groupsName);
        // Feeds Trend Per Group
        } else if (type=='feedsTrendPerGroup') {
            fileName = this.getFilename('feeds_trend_per_group_report');
            feedsTrendPerGroupBoolean = true;
            feedsTrendPerGroupExportToCsv = this.getFeedsTrendPerGroupExport(dateFrom, dateTo, groupsName);
        // User Activities Per Group
        } else if (type=='usersPerGroup') {
            fileName = this.getFilename('users_activity_per_group_report');
            userActivityPerGroupBoolean = true;
            userActivityPerGroupExportToCsv = this.getUserActivityPerGroupExport(dateFrom, dateTo, groupsName);
            if(String.isNotBlank(userId)){
                isUserSelected = true;
                detailedUserActivityPerGroupExportToCsv = this.getFeedTypesCountForUserExport(userId, dateFrom, dateTo, groupsName);
                String userNameForFileName = this.getUserNameForFileName(userId);
                fileName = this.getFileName('users_activity_per_group_report_with_detailed_report_for_' + userNameForFileName);
            }
        // User Activities Per Group
        } else if (type=='userLinksCount') {
            fileName = this.getFilename('user_links_count_report');
            userLinksCountBoolean = true;
            userLinksCountExportToCsv = this.getUserLinksCountExport(groupsName);
        // Default : Feeds Count
        } else {
            fileName = this.getFilename('feeds_count_report');
            feedsCountBoolen = true;
            feedsCountExportToCsv = this.getFeedsCountForExport(dateFrom, dateTo, groupsName);
        }

    }

    private String getUserNameForFileName(String userId){
        User u = [SELECT FirstName, LastName FROM User WHERE Id = :userId LIMIT 1];
        return u.FirstName + '_' + u.LastName;
    } 

    /*
     * private getFilename(String) 
     *
     * Generate Filename string with today date.
     *
     * return string
     */
    private String getFilename(String typeBegining) {
        return typeBegining + '_' + TODAY.year() + '_' + TODAY.day() + '_' + TODAY.month();
    }

    /*
     * private getStringFromDate(String, Boolean) 
     *
     * Generate String from given date.
     *
     * return string
     */
    public static String getStringFromDate(String dateString, Boolean dateFrom) {
        if(dateFrom) {
            return String.valueOf(Datetime.parse(dateString + ' 01:00 AM')).replace(' ', 'T') + 'Z';
        } else {
            return String.valueOf(Datetime.parse(dateString + ' 11:00 PM')).replace(' ', 'T') + 'Z';
        }
    }

    /*
     * private getStringFromGroups(String) 
     *
     * Generate String from given groups.
     *
     * return string
     */
    public static String getStringFromGroups(String groupsName) {
        List<String> groupsTmp =  groupsName.split(', ');
        String groups = '';
        for(String g : groupsTmp) {
            groups += '\'' + g + '\',';
        }
        groups = groups.removeEnd(',');
        return groups;
    }

    /*
     * private getStringFromGroupIds(String) 
     *
     * Generate String from given group Ids.
     *
     * return string
     */
    public static String getStringFromGroupIds(String groupsName) {
        String stringFromGroups = GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName);
        String stringFromGroupId = '';
        List<CollaborationGroup> cGroupList = Database.query('SELECT Id FROM CollaborationGroup WHERE Name IN (' + stringFromGroups + ')');
        for(CollaborationGroup cGroup : cGroupList) {
            stringFromGroupId += '\'' + cGroup.Id + '\',';
        }
        stringFromGroupId = stringFromGroupId.removeEnd(',');
        return stringFromGroupId;
    }

    /*
     * private getSetFromGroupIds(String) 
     *
     * Generate Set<String> from given group Ids.
     *
     * return string
     */
    public static Set<String> getSetFromGroupIds(String groupsName) {
        String stringFromGroups = GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName);
        Set<String> result = new Set<String>();
        List<CollaborationGroup> cGroupList = Database.query('SELECT Id FROM CollaborationGroup WHERE Name IN (' + stringFromGroups + ')');
        for(CollaborationGroup cGroup : cGroupList) {
            result.add(String.valueOf(cGroup.Id));
        }
        return result;
    }

    /*
     * private getMapFromGroupIds(String) 
     *
     * Generate Map<String, String> from given group Ids.
     *
     * return string
     */
    public static Map<String, String> getMapFromGroupIds(String groupsName) {
        String stringFromGroups = GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName);
        Map<String, String> result = new Map<String, String>();
        List<CollaborationGroup> cGroupList = Database.query('SELECT Id, Name FROM CollaborationGroup WHERE Name IN (' + stringFromGroups + ')');
        for(CollaborationGroup cGroup : cGroupList) {
            result.put(String.valueOf(cGroup.Id), cGroup.Name);
        }
        return result;
    }

    /*
     * private getAllGroupsAsString() 
     *
     * Get all Feed Group Names and serialize it into string.
     *
     * return string
     */
    public static String getAllGroupsAsString() {
        Set<String> setResult = new Set<String>();
        String result = '';
        for(FeedItem feed : [SELECT Parent.Name FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup)]) {
            setResult.add(feed.Parent.Name);
        }
        for(String name : setResult) {
            result += name + ', '; 
        }
        result = result.removeEnd(', ');
        return result;
    }

    /*
     * private getFeedsCountForExport(String, String, String)
     *
     * Count all Feeds for CSV export and return Map.
     *
     * return Map<String, Integer>
     */
    private Map<String, Integer> getFeedsCountForExport(String dateFrom, String dateTo, String groupsName) {
        Map<String, Integer> result = new Map<String, Integer>();

        String query = 'SELECT Parent.Name FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, true);
        List<FeedItem> feedsList = Database.query(query);
        for(FeedItem feed : feedsList) {
            if(!result.containsKey(feed.Parent.Name)) {
                result.put(feed.Parent.Name, 1);
            } else {
                result.put(feed.Parent.Name, result.get(feed.Parent.Name) + 1);
            }
        }

        return result;
    }

    /*
     * private getFeedTypesCountForExport(String, String) 
     *
     * Count all Feed Types for CSV export and return Map.
     *
     * return Map<String, Map<String, Integer>>
     */
    private Map<String, Map<String, Integer>> getFeedTypesCountForExport(String dateFrom, String dateTo, String groupsName) {
        Map<String, Map<String, Integer>> result = new Map<String, Map<String, Integer>>();

        String query = 'SELECT Type, Parent.Name, LikeCount FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, true);
        List<FeedItem> feedsList = Database.query(query);
        for(FeedItem feed : feedsList) {
            if(!result.containsKey(feed.Parent.Name)) {
                result.put(feed.Parent.Name, new Map<String, Integer>());
                result.get(feed.Parent.Name).put(feed.Type, 1);
                result.get(feed.Parent.Name).put('LikeCount', feed.LikeCount);
            } else {
                if(!result.get(feed.Parent.Name).containsKey(feed.Type)) {
                    result.get(feed.Parent.Name).put(feed.Type, 1);
                } else {
                    result.get(feed.Parent.Name).put(feed.Type, result.get(feed.Parent.Name).get(feed.Type) + 1);
                }
                result.get(feed.Parent.Name).put('LikeCount', result.get(feed.Parent.Name).get('LikeCount') + feed.LikeCount);
            }
        }

        // Complete blank groups with 0
        for(String groupName : result.keySet()) {
            if(!result.get(groupName).containsKey('TextPost')) {
                result.get(groupName).put('TextPost', 0);
            }
            if(!result.get(groupName).containsKey('LinkPost')) {
                result.get(groupName).put('LinkPost', 0);
            }
            if(!result.get(groupName).containsKey('ContentPost')) {
                result.get(groupName).put('ContentPost', 0);
            }
            if(!result.get(groupName).containsKey('PollPost')) {
                result.get(groupName).put('PollPost', 0);
            }
            if(!result.get(groupName).containsKey('LikeCount')) {
                result.get(groupName).put('LikeCount', 0);
            }
        }

        return result;
    }

    /*
     * private getFeedsTrendPerGroupExport(String, String) 
     *
     * Count all Feeds Trend per Group for CSV export and return Map.
     *
     * return Map<String, Map<String, Integer>>
     */
    private Map<String, Map<String, Integer>> getFeedsTrendPerGroupExport(String dateFrom, String dateTo, String groupsName) {
        Map<String, Map<String, Integer>> result = new Map<String, Map<String, Integer>>();

        String query = 'SELECT CreatedDate, Parent.Name FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, true) + ' ORDER BY CreatedDate';
        List<FeedItem> feedsList = Database.query(query);
        for(FeedItem feed : feedsList) {
            if(!result.containsKey(feed.Parent.Name)) {
                result.put(feed.Parent.Name, new Map<String, Integer>());
                result.get(feed.Parent.Name).put(feed.CreatedDate.format('MM-dd-yyyy'), 1);
            } else {
                if(!result.get(feed.Parent.Name).containsKey(feed.CreatedDate.format('MM-dd-yyyy'))) {
                    result.get(feed.Parent.Name).put(feed.CreatedDate.format('MM-dd-yyyy'), 1);
                } else {
                    result.get(feed.Parent.Name).put(feed.CreatedDate.format('MM-dd-yyyy'), result.get(feed.Parent.Name).get(feed.CreatedDate.format('MM-dd-yyyy')) + 1);
                }
            }
        }

        return result;
    }

        /*
     * private getFeedTypesCountForUserExport(String, String, String, String) 
     *
     * Count all Feed Types for specified user for CSV export and return Map.
     *
     * return Map<String, Map<String, Integer>>
     */
    private Map<String, Map<String, Integer>> getFeedTypesCountForUserExport(String userId, String dateFrom, String dateTo, String groupsName) {
        Map<String, Map<String, Integer>> result = new Map<String, Map<String, Integer>>();

        String query = 'SELECT Type, Parent.Name FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, true) + ' AND CreatedById = \'' + userId + '\'';
        List<FeedItem> feedsList = Database.query(query);
        for(FeedItem feed : feedsList) {
            if(!result.containsKey(feed.Parent.Name)) {
                result.put(feed.Parent.Name, new Map<String, Integer>());
                result.get(feed.Parent.Name).put(feed.Type, 1);
            } else {
                if(!result.get(feed.Parent.Name).containsKey(feed.Type)) {
                    result.get(feed.Parent.Name).put(feed.Type, 1);
                } else {
                    result.get(feed.Parent.Name).put(feed.Type, result.get(feed.Parent.Name).get(feed.Type) + 1);
                }
            }
        }

        String likequery = 'SELECT Type, Parent.Name, (select CreatedById from FeedLikes WHERE CreatedbyId = :userId) FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, false);
        List<FeedItem> feedsListWithLikes = Database.query(likequery);
        for(FeedItem feed : feedsListWithLikes) {
            if(feed.FeedLikes.size()>0){
                if(!result.containsKey(feed.Parent.Name)) {
                    result.put(feed.Parent.Name, new Map<String, Integer>());
                    result.get(feed.Parent.Name).put('LikeCount', feed.FeedLikes.size());
                } else {
                    if(!result.get(feed.Parent.Name).containsKey('LikeCount')) {
                        result.get(feed.Parent.Name).put('LikeCount', feed.FeedLikes.size());
                    } else {
                        result.get(feed.Parent.Name).put('LikeCount', result.get(feed.Parent.Name).get('LikeCount') + feed.FeedLikes.size());
                    }
                }
            }
        }

        // Complete blank groups with 0
        for(String groupName : result.keySet()) {
            if(!result.get(groupName).containsKey('TextPost')) {
                result.get(groupName).put('TextPost', 0);
            }
            if(!result.get(groupName).containsKey('LinkPost')) {
                result.get(groupName).put('LinkPost', 0);
            }
            if(!result.get(groupName).containsKey('ContentPost')) {
                result.get(groupName).put('ContentPost', 0);
            }
            if(!result.get(groupName).containsKey('PollPost')) {
                result.get(groupName).put('PollPost', 0);
            }
            if(!result.get(groupName).containsKey('LikeCount')) {
                result.get(groupName).put('LikeCount', 0);
            }
        }

        return result;
    }

    /*
     * private getUserActivityPerGroupExport(String, String) 
     *
     * Count all User activities per Group for CSV export and return Map.
     *
     * return Map<String, Map<String, Integer>>
     */
    private Map<String, Map<String, Integer>> getUserActivityPerGroupExport(String dateFrom, String dateTo, String groupsName) {
        Map<String, Map<String, Integer>> result = new Map<String, Map<String, Integer>>();

        String query = 'SELECT Createdby.Name, Parent.Name, (select CreatedBy.Name from FeedLikes) FROM FeedItem WHERE ParentId IN (Select Id from CollaborationGroup WHERE Name IN (' + GNE_Collaborate_Stats_Controller.getStringFromGroups(groupsName) + ')) AND CreatedDate >= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateFrom, true) + ' AND CreatedDate <= ' + GNE_Collaborate_Stats_Controller.getStringFromDate(dateTo, true);
        List<FeedItem> feedsList = Database.query(query);
        for(FeedItem feed : feedsList) {
            if(!result.containsKey(feed.Createdby.Name)) {
                result.put(feed.Createdby.Name, new Map<String, Integer>());
                result.get(feed.Createdby.Name).put(feed.Parent.Name, 1);
            } else {
                if(!result.get(feed.Createdby.Name).containsKey(feed.Parent.Name)) {
                    result.get(feed.Createdby.Name).put(feed.Parent.Name, 1);
                } else {
                    result.get(feed.Createdby.Name).put(feed.Parent.Name, result.get(feed.Createdby.Name).get(feed.Parent.Name) + 1);
                }
            }
        }

        for(FeedItem feed : feedsList) {
            for(FeedLike fLike :feed.FeedLikes){
                if(!result.containsKey(fLike.Createdby.Name)) {
                    result.put(fLike.Createdby.Name, new Map<String, Integer>());
                    result.get(fLike.Createdby.Name).put(feed.Parent.Name, 1);
                } else {
                    if(!result.get(fLike.Createdby.Name).containsKey(feed.Parent.Name)) {
                        result.get(fLike.Createdby.Name).put(feed.Parent.Name, 1);
                    } else {
                        result.get(fLike.Createdby.Name).put(feed.Parent.Name, result.get(fLike.Createdby.Name).get(feed.Parent.Name) + 1);
                    }
                }
            }
        }

        // Complete blank groups with 0
        for(String groupName : this.groupsList) {
            for(String name : result.keySet()) {
                if(!result.get(name).containsKey(groupName)) {
                    result.get(name).put(groupName, 0);
                }
            }
        }

        return result;
    }

    /*
     * private getUserLinksCountExport(String, String) 
     *
     * Count all User activities per Group for CSV export and return Map.
     *
     * return Map<String, Map<String, Integer>>
     */
    private Map<String, Map<String, Map<String, Decimal>>> getUserLinksCountExport(String groupsName) {
        Map<String, Map<String, Map<String, Decimal>>> tempMap = new Map<String, Map<String, Map<String, Decimal>>>();

        String stringFromGroupIds = GNE_Collaborate_Stats_Controller.getStringFromGroupIds(groupsName);

        String query = 'SELECT CreatedBy.Name, Count_gne__c, Link_name_gne__c, GroupId_gne__c, Url_gne__c FROM GNE_Collaborate_Link_Stat__c WHERE GroupId_gne__c IN (' + stringFromGroupIds + ') OR GroupId_gne__c = null';
        
        List<GNE_Collaborate_Link_Stat__c> linkStatList = Database.query(query);

        Set<String> userNameSet = new Set<String>();
        Map<String, Set<String>> chatterGroupNameSet = new Map<String, Set<String>>();
        Map<String, String> groupNameMap = GNE_Collaborate_Stats_Controller.getMapFromGroupIds(groupsName);

        for(GNE_Collaborate_Link_Stat__c linkStat : linkStatList) {

            if(!tempMap.containsKey(groupNameMap.get(linkStat.GroupId_gne__c))) {

                tempMap.put(groupNameMap.get(linkStat.GroupId_gne__c), new Map<String, Map<String, Decimal>>());

                if(!tempMap.get(groupNameMap.get(linkStat.GroupId_gne__c)).containsKey(linkStat.CreatedBy.Name)) {
                    
                    tempMap.get(groupNameMap.get(linkStat.GroupId_gne__c)).put(linkStat.CreatedBy.Name, new Map<String, Decimal>());
                    tempMap.get(groupNameMap.get(linkStat.GroupId_gne__c)).get(linkStat.CreatedBy.Name).put(linkStat.Link_name_gne__c, linkStat.Count_gne__c);

                } else {

                    tempMap.get(groupNameMap.get(linkStat.GroupId_gne__c)).get(linkStat.CreatedBy.Name).put(linkStat.Link_name_gne__c, linkStat.Count_gne__c);

                }

            } else {

                if(!tempMap.get(groupNameMap.get(linkStat.GroupId_gne__c)).containsKey(linkStat.CreatedBy.Name)) {
                    
                    tempMap.get(groupNameMap.get(linkStat.GroupId_gne__c)).put(linkStat.CreatedBy.Name, new Map<String, Decimal>());
                    tempMap.get(groupNameMap.get(linkStat.GroupId_gne__c)).get(linkStat.CreatedBy.Name).put(linkStat.Link_name_gne__c, linkStat.Count_gne__c);

                } else {

                    tempMap.get(groupNameMap.get(linkStat.GroupId_gne__c)).get(linkStat.CreatedBy.Name).put(linkStat.Link_name_gne__c, linkStat.Count_gne__c);

                }

            }

        }

        return tempMap;

    }


}