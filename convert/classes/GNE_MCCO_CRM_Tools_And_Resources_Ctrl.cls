/*
 * GNE_MCCO_CRM_Tools_And_Resources_Ctrl
 *
 * Created By : 		Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last modified by: Lukasz Kozminski (lukasz.kozminski@contractors.roche.com)
 */
public with sharing class GNE_MCCO_CRM_Tools_And_Resources_Ctrl {

    public Boolean hasChatterPermissionSet { get; private set; }
    public Boolean hasTerritories { get; private set; }
    public Boolean hasUserPermissionsSFContentUser { get; private set; }
    public static Boolean toolsAndResourcesAdminMode { get; private set; }
    public final Map<Id, String> libraryNamesMap { get; private set; }
    private Set<String> possibleTerritorySalesforceCodes;
    public Boolean foimRequestExist { get; private set; }

    /*
     * Constructor
     */
    public GNE_MCCO_CRM_Tools_And_Resources_Ctrl() {
   		hasTerritories 					= checkTerritories();
        foimRequestExist                = checkIfRequestExist();
    	hasChatterPermissionSet 		= checkChatterPermissionSet();
    	hasUserPermissionsSFContentUser = (checkUserPermissionsSFContentUser()) ? true : false;
    	libraryNamesMap 				= getLibraryNamesMap();

    	if (GNE_SFA2_Util.isBamCrmUser()){
    		toolsAndResourcesAdminMode      = GNE_BAM_CRM_Admin_Mode__c.getInstance() != null && GNE_BAM_CRM_Admin_Mode__c.getInstance().Tools_And_Resources_gne__c ? true : false;
    	} else {
    		toolsAndResourcesAdminMode      = GNE_MCCO_CRM_Admin_Mode__c.getInstance() != null && GNE_MCCO_CRM_Admin_Mode__c.getInstance().Tools_And_Resources_gne__c ? true : false;
    	}
    }

    private Boolean checkIfRequestExist() {
        List<GNE_CRM_HPSM_Incident__c> inc = [Select Id FROM GNE_CRM_HPSM_Incident__c WHERE CreatedById =: UserInfo.getUserId() AND Summary_gne__c = 'Access Issue' AND Closed_Date_gne__c = null];
        if(inc.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }

    public PageReference redirectToAccountsHomePage() {
        if (GNE_SFA2_Util.isEsbrietCrmUser() || GNE_SFA2_Util.isCrmFrmUser()) {
			return new PageReference('/apex/GNE_MCCO_CRM_MyAccounts?sfdc.tabName=01r70000000AnUG');
		}
		return null;
    }

    /*
     * Check if User has any Territories and Accounts
     *
     * Return Boolean
     */
    private Boolean checkTerritories() {
		if(getUserAccounts(1, 0, '', '').size() > 0) {
    		return true;
    	} else {
    		return false;
    	}
    }

    public Set<String> getPossibleTerritorySalesforceCodes(){
        if(possibleTerritorySalesforceCodes == null){
            possibleTerritorySalesforceCodes = new Set<String>();
            for(AggregateResult ar :[SELECT Salesforce_Code_gne__c FROM Territory2 WHERE external_id_gne__c LIKE 'GNE-US;SFA;0B5-BAM%' OR (External_id_gne__c Like 'GNE-US;MCCO%' AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%')) GROUP BY Salesforce_Code_gne__c ]){
                String sfdcCode = String.valueOf(ar.get('Salesforce_Code_gne__c'));
                if(String.isNotBlank(sfdcCode)){
                    possibleTerritorySalesforceCodes.add(sfdcCode);
                }
            }
        }
        return possibleTerritorySalesforceCodes;
    }

    /*
     * Check if User has Chatter Permission Set
     *
     * Return Boolean
     */
    private Boolean checkChatterPermissionSet() {
    	try {
    		List<PermissionSetAssignment> permSetCheck = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'GNE_Chatter_Permission_Set' AND AssigneeId = :UserInfo.getUserId()];
    		String userProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1][0].Name;
    		if(permSetCheck.size() > 0 || GNE_SFA2_Util.isMccoCrmUser() || GNE_SFA2_Util.isBamCrmUser() || GNE_SFA2_Util.isFrmUser() || GNE_SFA2_Util.isCCCrmUser() ) {
    			return true;
    		} else {
    			return false;
    		}
    	} catch (QueryException ex) {
    		System.debug(ex);
    		return false;
    	}
    }

    /*
     * Return Map for Libraries Names
     *
     * Return Map<Id, String>
     */
    private Map<Id, String> getLibraryNamesMap() {
    	Map<Id, String> libMap = new Map<Id, String>();
    	for(ContentWorkspace workSpace : [SELECT Id, Name FROM ContentWorkspace LIMIT 5000]) {
    		libMap.put(workSpace.Id, workSpace.Name);
    	}
        return libMap;
    }

    /*
     * Check if User has Salesforce Content Permission
     *
     * Return Boolean
     */
    private Boolean checkUserPermissionsSFContentUser() {
    	// Commented because we don't want to show Library Widget on home page layout
    	return false;
    	//return [SELECT UserPermissionsSFContentUser FROM User WHERE Id = :UserInfo.getUserId()][0].UserPermissionsSFContentUser;
    }

    /*
     * Return List of Chatter Groups Names for JS feedWidget (AJAX)
     *
     * return List<CollaborationGroupMember>
     */
    @RemoteAction
    @ReadOnly
    public static List<CollaborationGroupMember> getChatterGroupList() {
        return [SELECT CollaborationGroup.Name FROM CollaborationGroupMember WHERE MemberId = : UserInfo.getUserId()];
    }

    /*
     * Return List of links for JS linksAndResourcesWidget (AJAX)
     *
     * return List<GNE_MCCO_CRM_Link__c>
     */
    @RemoteAction
    @ReadOnly
    public static List<GNE_MCCO_CRM_Link__c> getLinkList(Boolean adminMode) {
        if(adminMode) {
            return GNE_MCCO_CRM_Util.getSubsetOfLinks([SELECT Id, Link_Name_gne__c, gConnect_Required_gne__c, Link_Url_gne__c, Is_Application_gne__c, Available_for_Salesforce1_gne__c, Available_for_gne__c FROM GNE_MCCO_CRM_Link__c WHERE Link_Name_gne__c != null ORDER BY Link_Name_gne__c ASC]);
        } else {
        	Set<String> uniqueURLs = new Set<String>();
        	List<GNE_MCCO_CRM_Link__c> result = new List<GNE_MCCO_CRM_Link__c>();
        	for(GNE_MCCO_CRM_Link__c link : GNE_MCCO_CRM_Util.getSubsetOfLinks([SELECT Id, Link_Name_gne__c, gConnect_Required_gne__c, Link_Url_gne__c, Is_Application_gne__c, Available_for_Salesforce1_gne__c, Available_for_gne__c FROM GNE_MCCO_CRM_Link__c WHERE (Is_Application_gne__c = true AND Link_Name_gne__c IN :getAvailableApps()) OR (Link_Name_gne__c != null AND Is_Application_gne__c = false) ORDER BY Link_Name_gne__c ASC])) {
				if(uniqueURLs.add(link.Link_Url_gne__c)){
					result.add(link);
				}
        	}
        	return result;
        }
    }

    @RemoteAction
    @ReadOnly
    public static List<SF1LinksWrapper> getSF1LinkList() {
        List<SF1LinksWrapper> wrappers = new List<SF1LinksWrapper>();
        Integer counter = 0;
        for(GNE_MCCO_CRM_Link__c link :GNE_MCCO_CRM_Util.getSubsetOfLinks([SELECT Id, Link_Name_gne__c, gConnect_Required_gne__c, Link_Url_gne__c, Is_Application_gne__c, Available_for_Salesforce1_gne__c, Available_for_gne__c FROM GNE_MCCO_CRM_Link__c WHERE Available_for_Salesforce1_gne__c = true ORDER BY Link_Name_gne__c ASC])){
            wrappers.add(new SF1LinksWrapper(link, counter));
            counter ++;
        }
        return wrappers;
    }

    class SF1LinksWrapper{
        public Boolean isOdd {get; private set;}
        public String url {get; private set;}
        public Boolean isWorkspace {get; private set;}
        public String urlName {get; private set;}
        public String className {get; private set;}

        SF1LinksWrapper(GNE_MCCO_CRM_Link__c link, Integer elementNumber){
            isOdd = Math.mod(elementNumber,2) == 1;
            className = isOdd ? 'odd' : 'even';
            urlName = link.Link_Name_gne__c;
            isWorkspace = link.Link_Url_gne__c.containsIgnoreCase('sfc/#search');
            if(isWorkspace){

                url = '/apex/GNE_MCCO_CRM_SF1_ViewLib' + (link.Link_Url_gne__c.split('/sfc/#search').size() > 1 ? link.Link_Url_gne__c.split('/sfc/#search')[1] : '');
            } else {
                url = link.Link_Url_gne__c;
            }
        }
    }

    @RemoteAction
    public static List<Database.DeleteResult> deleteLink(String linkId) {
        List<GNE_MCCO_CRM_Link__c> link = [SELECT Id FROM GNE_MCCO_CRM_Link__c WHERE Id =: linkId LIMIT 1];
        return Database.delete(link);
    }

    @RemoteAction
    public static Database.SaveResult addLink(Map<String, String> params) {
        String recordName = params.get('linkName').length() > 80 ? params.get('linkName').substring(0,79) : params.get('linkName');
        GNE_MCCO_CRM_Link__c link = new GNE_MCCO_CRM_Link__c(
            Name = recordName,
            Link_Name_gne__c = params.get('linkName'),
            Link_Url_gne__c = params.get('linkUrl'),
            Is_Application_gne__c = Boolean.valueOf(params.get('isApp')),
            Available_for_Salesforce1_gne__c = Boolean.valueOf(params.get('sf1')),
            gConnect_Required_gne__c = Boolean.valueOf(params.get('gConnect')),
            Available_for_gne__c = String.valueOf(params.get('availableFor'))
        );

        return Database.insert(link);
    }

    @RemoteAction
    public static Database.SaveResult updateLink(Map<String, String> params) {
        String recordName = params.get('linkName').length() > 80 ? params.get('linkName').substring(0,79) : params.get('linkName');
        GNE_MCCO_CRM_Link__c link = [SELECT Id, Name, Link_Name_gne__c, Link_Url_gne__c, Is_Application_gne__c, gConnect_Required_gne__c FROM GNE_MCCO_CRM_Link__c WHERE Id =: params.get('id')];
        link.Name = recordName;
        link.Link_Name_gne__c = params.get('linkName');
        link.Link_Url_gne__c = params.get('linkUrl');
        link.Is_Application_gne__c = Boolean.valueOf(params.get('isApp'));
        link.Available_for_Salesforce1_gne__c = Boolean.valueOf(params.get('sf1'));
        link.gConnect_Required_gne__c = Boolean.valueOf(params.get('gConnect'));
        link.Available_for_gne__c = String.valueOf(params.get('availableFor'));

        return Database.update(link);
    }

    /*
     * Return List of Available Apps (String) for getLinkList method
     *
     * return List<String>
     */
    public static List<String> getAvailableApps() {
        List<String> avaibleAppsList = new List<String>();
        for (Schema.DescribeTabSetResult sch : Schema.describeTabs()) {
            avaibleAppsList.add(sch.getLabel());
        }
        return avaibleAppsList;
    }

    /*
     * Return List of wrapper class ChatterFeedItem for chatterWidget (AJAX)
     *
     * return List<ChatterFeedItem>
     */
    @RemoteAction
    @ReadOnly
    public static List<ChatterFeedItem> getFeedItems() {
        return getFeedItemsList();
    }

    /*
     * Return List of wrapper class ChatterFeedItem for getFeedItems() method
     *
     * return List<ChatterFeedItem>
     */
    public static List<ChatterFeedItem> getFeedItemsList() {
        ConnectApi.FeedElementPage feedPage = getNewsFeed();
        List<ChatterFeedItem> result = new List<ChatterFeedItem>();

        for (ConnectApi.FeedElement element : feedPage.elements) {
            if (element instanceof ConnectApi.FeedItem) {
                result.add(new ChatterFeedItem(element));
            }
        }

		result.sort();

        return result;
    }

    /*
     * Return ConnectApi.FeedElementPage for getFeedItemsList() method
     *
     * return ConnectApi.FeedElementPage
     */
    public static ConnectApi.FeedElementPage getNewsFeed() {
        return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(null, ConnectApi.FeedType.News, 'me');
    }

    /*
     * Return List of Account for JS accountWidget (AJAX)
     *
     * return List<Account>
     */
    @RemoteAction
	@ReadOnly
    public static List<Account> getUserAccounts(Integer displayLength, Integer displayStart, String search, String firstLetter) {
        List<String> territoriesNames = new List<String>();
        List<String> accountIds = new List<String>();

        for (Territory2 ter : GNE_SFA2_Util.getUserTerritories( UserInfo.getUserId() )) {
            territoriesNames.add(ter.Name);
        }

        for (TSF_vod__c tsfVod : getTSFForTerritoriesName(territoriesNames)) {
            accountIds.add(tsfVod.Account_vod__c);
        }
        String query = 'SELECT Id, Name FROM Account WHERE Id IN : accountIds';

        if(!String.isEmpty(search)) {
            query += ' AND Name Like \'%' + search + '%\'';
        }
        if(String.isNotEmpty(firstLetter)){
            query += ' AND Name LIKE \'' + firstLetter + '%\'';
        }
        query += ' ORDER BY Name ASC';
        query += ' LIMIT ' +  displayLength;
        if (displayStart > 0) {
            query += ' OFFSET ' + displayStart;
        }
        return Database.query(query);
    }

    /*
     * Return List of TSF_vod__c for getUserAccounts() method
     *
     * return List<TSF_vod__c>
     */
    public static List<TSF_vod__c> getTSFForTerritoriesName(List<String> territoriesName) {
        User user = [SELECT Profile_Name_gne__c FROM User WHERE Id = : UserInfo.getUserId() ];

        String query = 'SELECT Id, Account_vod__c ' +
                       'FROM TSF_vod__c ' +
                       'WHERE Territory_vod__c in :territoriesName ' +
                       'AND Address_vod__c != null ' +
                       'AND External_Id_vod__c != null ';

        if (GNE_SFA2_Util.isMccoCrmUser() || GNE_SFA2_Util.isBamCrmUser() || GNE_SFA2_Util.isFrmUser()) {
            query += 'AND Account_vod__r.IsPersonAccount = false ';
        }

        query += ' LIMIT 49000';

        return Database.query(query);
    }

	/*
	 * Return Account JS modalWiget (AJAX)
	 *
	 * return Account
	 */
    @RemoteAction
    @ReadOnly
    public static Account getUserAccountDetails(String accountId) {
        return [SELECT Id, Name, Target__c, Account_Type_gne__c, Account_Manager_gne__r.Name, Account_Manager_gne__r.Id, Account_Level_gne__c, Website, Website_gne__pc, MDMID_gne__c, Parent.Name, Parent.Id FROM Account WHERE Id = :accountId LIMIT 1];
    }

 	/*
   	 * Return List of wrapper class Library for JS libraryWidget (AJAX)
   	 *
   	 * return List<Library>
   	 */
    @RemoteAction
    @ReadOnly
    public static List<Library> getUserLibraries() {
    	List<Library> librariesList = new List<Library>();
    	for(ContentWorkspace workSpace : [SELECT Id, Name, CreatedBy.Name, CreatedBy.Id FROM ContentWorkspace LIMIT 5000]) {
    		librariesList.add(new Library (workSpace.Id, workSpace.Name, workSpace.CreatedBy.Name, workSpace.CreatedBy.Id ));
    	}
    	librariesList.add(new Library ('', 'My Personal Content', null, null ));
    	librariesList.sort();
        return librariesList;
    }

    /*
     * Return List of wrapper class LibraryContent for JS libraryWidget (AJAX)
     *
     * return List<LibraryContent>
     */
    @RemoteAction
    @ReadOnly
    public static List<LibraryContent> getUserLibraryContent(String libId, Integer displayLength, Integer displayStart, String search) {
    	List<LibraryContent> result = new List<LibraryContent>();

        String query = 'SELECT Id, LatestPublishedVersionId, FileType, ContentModifiedDate, ContentSize, Description, FileExtension, Owner.Id, Owner.Name, Title, ParentId FROM ContentDocument ';

        if(!String.isEmpty(libId)) {
        	query += ' WHERE ParentId = :libId ';
        } else {
        	query += ' WHERE PublishStatus = \'R\' ';
        }

        if(!String.isEmpty(search)) {
        	query += ' AND Title Like \'%' + search + '%\'';
        }
        query += ' ORDER BY Title ASC';
        query += ' LIMIT ' +  displayLength;
        if (displayStart > 0) {
        	query += ' OFFSET ' + displayStart;
        }

        System.debug(query);
        System.debug(Database.query(query));

		for(ContentDocument doc : Database.query(query)) {
			result.add(
				new LibraryContent(	doc.Id, doc.LatestPublishedVersionId, doc.FileType, doc.ContentModifiedDate, doc.ContentSize, doc.Description, doc.FileExtension, doc.Owner.Id, doc.Owner.Name, doc.Title, doc.ParentId, null )
			);
		}

        return result;
    }

    /*
     * Return wrapper class LibraryContent for JS modalWidget (AJAX)
     *
     * return LibraryContent
     */
    @RemoteAction
    @ReadOnly
    public static LibraryContent getLibraryDetails(String contentId) {
        ContentDocument doc = [SELECT Id, LatestPublishedVersionId, FileType, ParentId, ContentModifiedDate, ContentSize, Description, FileExtension, Owner.Id, Owner.Name, Title, (SELECT Id, CreatedBy.Name, CreatedBy.Id, CreatedDate, FileType, FileExtension, ContentModifiedDate, Description, LastModifiedDate, ReasonForChange, ContentSize, Title, VersionNumber, PublishStatus FROM ContentVersions WHERE IsLatest = false ORDER BY VersionNumber DESC LIMIT 4) FROM ContentDocument WHERE LatestPublishedVersionId = :contentId LIMIT 1][0];
        List<LibraryVersion> libVer = new List<LibraryVersion>();
        for(ContentVersion ver : doc.ContentVersions) {
        	libVer.add( new LibraryVersion(	ver.Id, ver.CreatedBy.Name, ver.CreatedBy.Id, ver.CreatedDate, ver.FileType, ver.FileExtension, ver.ContentModifiedDate, ver.Description, ver.LastModifiedDate, ver.ReasonForChange, ver.ContentSize, ver.Title, ver.VersionNumber, ver.PublishStatus ) );
        }
        LibraryContent result = new LibraryContent( doc.Id, doc.LatestPublishedVersionId, doc.FileType, doc.ContentModifiedDate, doc.ContentSize, doc.Description, doc.FileExtension, doc.Owner.Id, doc.Owner.Name, doc.Title, doc.ParentId, libVer );
        return result;
    }

    /*
     * Wrapper Class
     *
     * ChatterFeedItem
     */
    @TestVisible
    public class ChatterFeedItem extends FileIcons implements Comparable {

        public ChatterFeedItem(ConnectApi.FeedElement element) {

            ConnectApi.FeedItem item = (ConnectApi.FeedItem)element;

            this.id         	= item.id;
            this.body       	= getFeedBody(item.body);
            this.createdDate 	= item.createdDate;
            this.modifiedDate 	= item.modifiedDate;
            this.type       	= getFeedType(item.capabilities);
            this.title      	= getFeedTitle(item.capabilities);
            this.url        	= getFeedUrl(item.capabilities);
            this.likeCount     	= getFeedLikesCount(item.capabilities);
            this.commentCount   = getFeedCommentsCount(item.capabilities);
            this.content     	= getFeedAttachments(item.capabilities);
            this.feedGroup     	= getFeedGroup(item.parent);
            this.feedUser    	= getFeedUser(item.actor);
            this.comments    	= getFeedComments(item.capabilities);
            this.trackedChanges = getFeedTrackedChanges(item.capabilities);
            this.feedPoll     	= getFeedPoll(item.capabilities);

        }

        public Id id { get; private set; }
        public String body { get; private set; }
        public Datetime createdDate { get; private set; }
        public Datetime modifiedDate { get; private set; }
        public String type { get; private set; }
        public String title { get; private set; }
        public String url { get; private set; }
        public Integer likeCount { get; private set; }
        public Integer commentCount { get; private set; }
        public ChatterFeedItemContent content { get; private set; }
        public ChatterFeedItemGroup feedGroup { get; private set; }
        public ChatterFeedItemUser feedUser { get; private set; }
        public List<ChatterFeedItemComment> comments { get; private set; }
        public String trackedChanges { get; private set; }
        public ChatterFeedItemPoll feedPoll { get; private set; }

        private String getFeedBody(ConnectApi.FeedBody body) {
            String formattedText = '';
            for (ConnectApi.MessageSegment seg : body.messageSegments) {
                if (seg instanceof ConnectApi.MentionSegment) {
                    ConnectApi.MentionSegment mention = (ConnectApi.MentionSegment)seg;
                    formattedText += '<span style=\"color:#015ba7\"><a href="/' + mention.record.id + '">@' + mention.record.name + '</a></span>';
                } else if (seg instanceof ConnectApi.HashtagSegment) {
                    ConnectApi.HashtagSegment hashtag = (ConnectApi.HashtagSegment)seg;
                    formattedText += '<span style=\"color:#015ba7\"><a href="/_ui/core/chatter/topics/TopicPage?name=' + hashtag.tag + '&ref=hash_mention">#' + hashtag.tag + '</a></span>';
                } else if (seg instanceof ConnectApi.LinkSegment) {
                    ConnectApi.LinkSegment link = (ConnectApi.LinkSegment)seg;
                    formattedText += '<a href=\"' + link.url + '\">' + link.url + '</a>';

                } else {
                    formattedText += seg.text;
                }
            }
            return formattedText.replaceAll('<a href="https://'+ System.URL.getSalesforceBaseUrl().getHost(), '<a href="/apex/GNE_gCollaborate_Check_Context?url=https://' + System.URL.getSalesforceBaseUrl().getHost());
        }

        private String getFeedType(ConnectApi.FeedElementCapabilities capabilities) {
            String result = null;

            if (capabilities.link != null) {
                result = 'Link';
            } else if (capabilities.poll != null) {
                result = 'Poll';
            } else if (capabilities.trackedChanges != null) {
                result = 'TrackedChanges';
            } else if (capabilities.content != null) {
                result = 'Content';
            } else {
                result = 'Text';
            }

            return result;
        }

        private String getFeedTitle(ConnectApi.FeedElementCapabilities capabilities) {
            String result = null;

            if (capabilities.link != null) {
                result = capabilities.link.urlName;
            }

            return result;
        }

        private String getFeedUrl(ConnectApi.FeedElementCapabilities capabilities) {
            String result = null;

            if (capabilities.link != null) {
                result = capabilities.link.url;
            }

            return result;
        }

        private Integer getFeedLikesCount(ConnectApi.FeedElementCapabilities capabilities) {
            Integer result = null;

            if (capabilities.chatterLikes.page.items != null) {
                result = capabilities.chatterLikes.page.items.size();
            } else {
                result = 0;
            }

            return result;
        }

        private Integer getFeedCommentsCount(ConnectApi.FeedElementCapabilities capabilities) {
            Integer result = null;

            if (capabilities.comments.page.items != null) {
                result = capabilities.comments.page.items.size();
            } else {
                result = 0;
            }

            return result;
        }

        private List<ChatterFeedItemComment> getFeedComments(ConnectApi.FeedElementCapabilities capabilities) {
            List<ChatterFeedItemComment> result = new List<ChatterFeedItemComment>();

            if (capabilities.comments.page.items != null) {
                for (ConnectApi.Comment comment : capabilities.comments.page.items) {
                    ChatterFeedItemComment feedItemComment = new ChatterFeedItemComment();

                    feedItemComment.id      	= comment.id;
                    feedItemComment.body     	= getFeedBody(comment.body);
                    feedItemComment.createdDate = comment.createdDate;
                    feedItemComment.feedUser  	= getFeedUser(comment.user);

                    result.add(feedItemComment);
                }
            } else {
                result = null;
            }

			result.sort();
            return result;
        }

        private ChatterFeedItemUser getFeedUser(ConnectApi.Actor actor) {
            ChatterFeedItemUser userInfo = new ChatterFeedItemUser();
            ConnectApi.UserSummary userSummary = (ConnectApi.UserSummary)actor;

            userInfo.id   = userSummary.id;
            userInfo.name = userSummary.displayName;
            userInfo.photo = userSummary.photo.smallPhotoUrl;

            return userInfo;
        }

        private ChatterFeedItemGroup getFeedGroup(ConnectApi.ActorWithId parent) {
            ChatterFeedItemGroup groupInfo = new ChatterFeedItemGroup();

            if (parent instanceof ConnectApi.ChatterGroupSummary) {
                ConnectApi.ChatterGroupSummary chatterGroupSummary = (ConnectApi.ChatterGroupSummary)parent;

                groupInfo.id     	= chatterGroupSummary.id;
                groupInfo.name     	= chatterGroupSummary.name;
                groupInfo.isPrivate = (String.valueOf(chatterGroupSummary.visibility) == 'PrivateAccess') ? true : false;
            }

            return groupInfo;
        }

        private ChatterFeedItemContent getFeedAttachments(ConnectApi.FeedElementCapabilities capabilities) {
            ChatterFeedItemContent content = new ChatterFeedItemContent();

            if (capabilities.content != null) {
                content.id       		= capabilities.content.id;
                content.size     		= capabilities.content.fileSize;
                content.fileName 		= capabilities.content.title;
                content.type     		= capabilities.content.mimeType;
                content.fileExtension 	= capabilities.content.fileExtension;

                if(capabilities.content.renditionUrl240By180 != null) {
                	content.thumbUrl  = capabilities.content.renditionUrl240By180;
                } else {
            		content.thumbUrl = '/sfc/images/docicons/' + getBigIcon(capabilities.content.fileTypeEnumName);
                }

                content.downUrl  = capabilities.content.downloadUrl;
            } else {
                content = null;
            }

            return content;
        }

        private String getFeedTrackedChanges(ConnectApi.FeedElementCapabilities capabilities) {
            String result = null;

            if (capabilities.trackedChanges != null) {
                Boolean isAnd = false;
                for (ConnectApi.TrackedChangeItem change : capabilities.trackedChanges.changes) {
                    if (isAnd) {
                        result = ' and ';
                    }
                    result = ' changed ' + change.fieldName;
                    if (change.oldValue != null) {
                        result += ' from ' + change.oldValue ;
                    }
                    if (change.newValue != null) {
                        result += ' from ' + change.newValue ;
                    }
                    isAnd = true;
                }
                result += '.';
            }

            return result;
        }

        private ChatterFeedItemPoll getFeedPoll(ConnectApi.FeedElementCapabilities capabilities) {
            ChatterFeedItemPoll poll = new ChatterFeedItemPoll();

            if (capabilities.poll != null) {
                poll.totalVotes = capabilities.poll.totalVoteCount;
                List<ChatterFeedItemPollChoice> pollChoiceList = new List<ChatterFeedItemPollChoice>();
                for (ConnectApi.FeedPollChoice choice : capabilities.poll.choices) {
                    ChatterFeedItemPollChoice pollChoice = new ChatterFeedItemPollChoice();
                    pollChoice.text = choice.text;
                    pollChoice.votes = choice.voteCount;
                    pollChoiceList.add(pollChoice);
                }
                poll.choices = pollChoiceList;
            } else {
                poll = null;
            }

            return poll;
        }

        public Integer compareTo(Object compareTo) {
            ChatterFeedItem comparableData = (ChatterFeedItem)compareTo;
            Integer result = 0;
            if (this.modifiedDate == comparableData.modifiedDate) {
                result = 0;
            } else if (this.modifiedDate < comparableData.modifiedDate) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }
    }

    /*
     * Wrapper Class
     *
     * ChatterFeedItemContent
     */
    public class ChatterFeedItemContent {
        public Id id { get; private set; }
        public String size { get; private set; }
        public String fileName { get; private set; }
        public String type { get; private set; }
        public String thumbUrl { get; private set; }
        public String downUrl { get; private set; }
        public String fileExtension { get; private set; }
    }

    /*
     * Wrapper Class
     *
     * ChatterFeedItemGroup
     */
    public class ChatterFeedItemGroup {
        public Id id { get; private set; }
        public String name { get; private set; }
        public Boolean isPrivate { get; private set; }
    }

    /*
     * Wrapper Class
     *
     * ChatterFeedItemUser
     */
    public class ChatterFeedItemUser {
        public String id { get; private set; }
        public String name { get; private set; }
        public String photo { get; private set; }
    }

    /*
     * Wrapper Class
     *
     * ChatterFeedItemComment
     */
    public class ChatterFeedItemComment implements Comparable {
        public Id id { get; private set; }
        public String body { get; private set; }
        public Datetime createdDate { get; private set; }
        public ChatterFeedItemUser feedUser { get; private set; }

        public Integer compareTo(Object compareTo) {
            ChatterFeedItemComment comparableData = (ChatterFeedItemComment)compareTo;
            Integer result = 0;
            if (this.createdDate == comparableData.createdDate) {
                result = 0;
            } else if (this.createdDate > comparableData.createdDate) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }
    }

    /*
     * Wrapper Class
     *
     * ChatterFeedItemPoll
     */
    public class ChatterFeedItemPoll {
        public Integer totalVotes { get; private set; }
        public List<ChatterFeedItemPollChoice> choices { get; private set; }
    }

    /*
     * Wrapper Class
     *
     * ChatterFeedItemPollChoice
     */
    public class ChatterFeedItemPollChoice {
        public String text { get; private set; }
        public Integer votes { get; private set; }
    }

    /*
     * Wrapper Class
     *
     * LibraryContent
     */
    public class LibraryContent extends FileIcons {

    	public Id Id { get; private set; }
    	public Id LatestPublishedVersionId { get; private set; }
    	public String FileType { get; private set; }
    	public DateTime ContentModifiedDate { get; private set; }
    	public Integer ContentSize { get; private set; }
    	public String Description { get; private set; }
    	public String FileExtension { get; private set; }
    	public Id OwnerId { get; private set; }
    	public String OwnerName { get; private set; }
    	public String Title { get; private set; }
    	public Id ParentId { get; private set; }
    	public String Icon { get; private set; }
    	public String IconSmall { get; private set; }
    	public List<LibraryVersion> ContentVersions { get; private set; }

	   	public LibraryContent(Id Id, Id LatestPublishedVersionId, String FileType, DateTime ContentModifiedDate, Integer ContentSize, String Description, String FileExtension, Id OwnerId, String OwnerName, String Title, Id ParentId, List<LibraryVersion> versions) {
	   		this.Id 						= Id;
	   		this.LatestPublishedVersionId 	= LatestPublishedVersionId;
	   		this.FileType 					= FileType;
	   		this.ContentModifiedDate 		= ContentModifiedDate;
	   		this.ContentSize 				= ContentSize;
	   		this.Description 				= Description;
	   		this.FileExtension 				= FileExtension;
	   		this.OwnerId 					= OwnerId;
	   		this.OwnerName 					= OwnerName;
	   		this.Title 						= Title;
	   		this.ParentId 					= ParentId;
	   		this.Icon 						= getMediumIcon(FileType);
	   		this.IconSmall 					= getSmallIcon(FileType);
	   		this.ContentVersions			= versions;
	   	}

    }

    /*
     * Wrapper Class
     *
     * LibraryVersion
     */
    public class LibraryVersion  {

    	public Id Id { get; private set; }
    	public String CreatedByName { get; private set; }
    	public Id CreatedById { get; private set; }
    	public DateTime CreatedDate { get; private set; }
    	public String FileType { get; private set; }
    	public String FileExtension { get; private set; }
    	public DateTime ContentModifiedDate { get; private set; }
    	public String Description { get; private set; }
    	public DateTime LastModifiedDate { get; private set; }
    	public String ReasonForChange { get; private set; }
    	public Integer ContentSize { get; private set; }
    	public String Title { get; private set; }
    	public String VersionNumber { get; private set; }
    	public String PublishStatus { get; private set; }

    	public LibraryVersion(Id Id, String CreatedByName, Id CreatedById, DateTime CreatedDate, String FileType, String FileExtension, DateTime ContentModifiedDate, String Description, DateTime LastModifiedDate, String ReasonForChange, Integer ContentSize, String Title, String VersionNumber, String PublishStatus) {
    		this.Id 					= Id;
    		this.CreatedByName 			= CreatedByName;
    		this.CreatedById 			= CreatedById;
    		this.CreatedDate 			= CreatedDate;
    		this.FileType		 		= FileType;
    		this.FileExtension 			= FileExtension;
    		this.ContentModifiedDate 	= ContentModifiedDate;
    		this.Description 			= Description;
    		this.LastModifiedDate 		= LastModifiedDate;
    		this.ReasonForChange 		= ReasonForChange;
    		this.ContentSize 			= ContentSize;
    		this.Title 					= Title;
    		this.VersionNumber 			= VersionNumber;
    		this.PublishStatus 			= PublishStatus;
    	}
    }

    /*
     * Wrapper Class
     *
     * Library
     */
    public class Library implements Comparable  {

    	public String Id { get; private set; }
    	public String Name { get; private set; }
    	public String CreatedByName { get; private set; }
    	public String CreatedById { get; private set; }

    	public Library(String Id, String Name, String CreatedByName, String CreatedById) {
    		this.Id 			= Id;
    		this.Name 			= Name;
    		this.CreatedByName 	= CreatedByName;
    		this.CreatedById 	= CreatedById;
    	}

        public Integer compareTo(Object compareTo) {
            Library comparableData = (Library)compareTo;
            Integer result = 0;
            if (this.Name == comparableData.Name) {
                result = 0;
            } else if (this.Name > comparableData.Name) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }

    }

    /*
     * Wrapper Virtual Class
     *
     * FileIcons
     */
     public virtual class FileIcons {

		private final Map<String, String> iconsMap = new Map<String, String> {
		    'BMP' => 'doctype_image_',
		    'CSV' => 'doctype_csv_',
		    'EXCEL' => 'doctype_excel_',
		    'EXCEL_X' => 'doctype_excel_',
		    'EXE' => 'doctype_exe_',
		    'GIF' => 'doctype_image_',
		    'HTML' => 'doctype_html_',
		    'JPG' => 'doctype_image_',
		    'MOV' => 'doctype_video_',
		    'WMV' => 'doctype_video_',
		    'MP4' => 'doctype_mp4_',
		    'MP3' => 'doctype_audio_',
		    'PDF' => 'doctype_pdf_',
		    'PNG' => 'doctype_image_',
		    'POWER_POINT' => 'doctype_ppt_',
		    'POWER_POINT_X' => 'doctype_ppt_',
		    'TEXT' => 'doctype_txt_',
		    'UNKNOWN' => 'doctype_unknown_',
		    'WORD' => 'doctype_word_',
		    'WORD_X' => 'doctype_word_',
		    'XML' => 'doctype_xml_',
		    'ZIP' => 'doctype_zip_',
		    'PACK' => 'doctype_pack_'
	   	};

	   	protected String getSmallIcon(String fileType) {
	   		String icon = iconsMap.get(fileType);
	   		if(!String.isEmpty(icon)) {
	   			return icon + '16.png';
	   		} else {
	   			return 'doctype_unknown_16.png';
	   		}
	   	}

	   	protected String getMediumIcon(String fileType) {
	   		String icon = iconsMap.get(fileType);
	   		if(!String.isEmpty(icon)) {
	   			return icon + '32.png';
	   		} else {
	   			return 'doctype_unknown_32.png';
	   		}
	   	}

	   	protected String getBigIcon(String fileType) {
	   		String icon = iconsMap.get(fileType);
	   		if(!String.isEmpty(icon)) {
	   			return icon + '48.png';
	   		} else {
	   			return 'doctype_unknown_48.png';
	   		}
	   	}

     }

}