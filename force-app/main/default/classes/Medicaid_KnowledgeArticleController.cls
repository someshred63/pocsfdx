public without sharing class Medicaid_KnowledgeArticleController {
    public static final String SYS_ADMIN_PROFILE = 'System Administrator';

    @AuraEnabled
    public static KnowledgeArticleResponse getKnowledgeArticleDetails(Id articleVersionId, String articleQuickAction) {
        KnowledgeArticleResponse response = new KnowledgeArticleResponse();
        List<Knowledge__kav> knowledgeArticle = new List<Knowledge__kav> ();
        List<Knowledge__kav> allKnowledgeArticles = new List<Knowledge__kav> ();
        List<PermissionSetAssignment> assignedPermissions = new List<PermissionSetAssignment>();
        List<String> permissionSetNames = new List<String>();
        Boolean isNoOnlineStatusExists = true;
        String loggedInUserName = UserInfo.getName();
        String loggedInUserProfile = '';
        String redirectId = Medicaid_Constants.BLANK_VALUE;
        String articleId = Medicaid_Constants.BLANK_VALUE;
        response.status = Medicaid_Constants.SUCCESS;
        response.message = Medicaid_Constants.BLANK_VALUE;
        response.isUserHasAccessToDelete = false;

        //Get user access details
        permissionSetNames = System.Label.Medicaid_Delete_Article_Permissionsets.split(',');
        loggedInUserProfile = [SELECT Id, Name From Profile WHERE Id = :UserInfo.getProfileId()]?.Name;
        assignedPermissions = [
            SELECT Id, PermissionSetId, AssigneeId, Assignee.Name 
              FROM PermissionSetAssignment 
             WHERE PermissionSet.Name IN :permissionSetNames AND Assignee.Name = :loggedInUserName
        ];

        System.debug('loggedInUserProfile: ' + loggedInUserProfile);
        System.debug('loggedInUserName: ' + loggedInUserName);
        System.debug('assignedPermissions: ' + assignedPermissions);

        if (assignedPermissions?.size() > 0 || (String.isNotBlank(loggedInUserProfile) && loggedInUserProfile.containsIgnoreCase(SYS_ADMIN_PROFILE))) {
            response.isUserHasAccessToDelete = true;
        }
        
        //Get the Knowledge Article 
        knowledgeArticle  = [
            SELECT Id, KnowledgeArticleId, PublishStatus, VersionNumber, Title, ArticleNumber 
            FROM Knowledge__kav 
            WHERE Id = :articleVersionId 
        ];

        System.debug('knowledgeArticles: ' + knowledgeArticle);
        //Get all the Knowledge Article Versions related to the Article Id
        if (knowledgeArticle?.size() > 0)
        {
            articleId = knowledgeArticle[0].KnowledgeArticleId;
            response.knowledgeArticleId = articleId;
            response.articleTitle = knowledgeArticle[0].Title;

            allKnowledgeArticles  = [
                SELECT Id, KnowledgeArticleId, PublishStatus, VersionNumber, Title, ArticleNumber 
                FROM Knowledge__kav 
                WHERE KnowledgeArticleId = :articleId 
                ORDER BY VersionNumber DESC
            ];

            System.debug('knowledgeArticles: ' + allKnowledgeArticles);
            if (allKnowledgeArticles?.size() > 0)
            { 
                for(Knowledge__kav kav: allKnowledgeArticles)
                {
                    if (String.isBlank(redirectId) && 
                       (kav.PublishStatus == Medicaid_Constants.STATUS_ONLINE ||
                        kav.PublishStatus == Medicaid_Constants.STATUS_ARCHIVED))
                    {
                        redirectId = kav.Id;
                        if (kav.PublishStatus == Medicaid_Constants.STATUS_ONLINE)
                        {
                            isNoOnlineStatusExists = false;
                        }
                    }
                } 

                response.knowledgeArticles = allKnowledgeArticles;
                response.redirectUrlId = redirectId;
            }

            if (articleQuickAction.containsIgnoreCase(Medicaid_Constants.ACTION_TYPE_ARCHIVE) && isNoOnlineStatusExists)
            {
                response.message = Medicaid_Constants.ARTICLE_ARCHIVE_PUBLISH_ERROR_MSG;
                response.status = Medicaid_Constants.ERROR;
            }
        }

        return response;
    }

    @AuraEnabled
    public static KnowledgeArticleResponse archiveKnowledgeArticle(Id articleId, List<Knowledge__kav> knowledgeArticles){
        System.debug('-------------------------------------------');
        System.debug('            Passing Parameters             ');
        System.debug('-------------------------------------------');
        System.debug('Knowledge KVA Id : ' + articleId);
        System.debug('knowledgeArticles: ' + knowledgeArticles);
        System.debug('-------------------------------------------');
        KnowledgeArticleResponse response = new KnowledgeArticleResponse();
        response.status = Medicaid_Constants.SUCCESS;
        response.message = Medicaid_Constants.ARTICLE_ARCHIVE_SUCCESS_MSG;
        Boolean isDraft = false;
        Boolean isOnline = false;
        Boolean isArchived = false;
        Datetime scheduledDate;
        try {
            if (knowledgeArticles?.size() > 0)
            {
                response.knowledgeArticleId = articleId;
                String status = Medicaid_Constants.BLANK_VALUE;
                for(Knowledge__kav kav: knowledgeArticles)
                {
                    status = kav.PublishStatus;
                    if (String.isNotBlank(status))
                    {
                        if (status.equalsIgnoreCase(Medicaid_Constants.STATUS_DRAFT)) 
                        {
                            isDraft = true;
                        } 
                        
                        if (status.equalsIgnoreCase(Medicaid_Constants.STATUS_ONLINE) || 
                            status.equalsIgnoreCase(Medicaid_Constants.STATUS_PUBLISHED)) 
                        {
                            response.redirectUrlId = kav.id;
                            isOnline = true;
                        }

                        if (status.equalsIgnoreCase(Medicaid_Constants.STATUS_ARCHIVED))
                        {
                            isArchived = true;
                        }
                    }
                }

                //Archive the Article
                System.debug('knowledgeArticles ID: ' + articleId);
                System.debug('isDraft: ' + isDraft);
                System.debug('isOnline: ' + isOnline);
                System.debug('isArchived: ' + isArchived);

                //Archive the knowledge article
                if (isDraft && isOnline)
                {
                    KbManagement.PublishingService.deleteDraftArticle(articleId);
                    KbManagement.PublishingService.archiveOnlineArticle(articleId, scheduledDate);
                } 
                else if (isOnline) 
                {
                    KbManagement.PublishingService.archiveOnlineArticle(articleId, scheduledDate);
                }else
                {
                    response.status = Medicaid_Constants.ERROR;
                    response.message = Medicaid_Constants.ARTICLE_ARCHIVE_ERROR_MSG;
                }
            }
        } catch (Exception e) {
            System.debug('Error Occoured: ' + e.getMessage());
            //throw new AuraHandledException(e.getMessage());
            response.status = Medicaid_Constants.ERROR;
            response.message = e.getMessage();
        }

        return response;
    }

    @AuraEnabled
    public static KnowledgeArticleResponse deleteKnowledgeArticle(Id articleId, List<Knowledge__kav> knowledgeArticles){
        System.debug('-------------------------------------------');
        System.debug('            Passing Parameters             ');
        System.debug('-------------------------------------------');
        System.debug('Knowledge KVA Id : ' + articleId);
        System.debug('knowledgeArticles: ' + knowledgeArticles);
        System.debug('-------------------------------------------');
        KnowledgeArticleResponse response = new KnowledgeArticleResponse();
        response.status = Medicaid_Constants.SUCCESS;
        response.message = Medicaid_Constants.ARTICLE_DELETE_SUCCESS_MSG;
        Boolean isDraft = false;
        Boolean isOnline = false;
        Boolean isArchived = false;
        Datetime scheduledDate;

        try {
            String status = Medicaid_Constants.BLANK_VALUE;
            if (knowledgeArticles?.size() > 0)
            {
                for(Knowledge__kav kav: knowledgeArticles)
                {
                    status = kav.PublishStatus;
                    if (String.isNotBlank(status))
                    {
                        if (status.equalsIgnoreCase(Medicaid_Constants.STATUS_DRAFT)) 
                        {
                            isDraft = true;
                        } 
                        
                        if (status.equalsIgnoreCase(Medicaid_Constants.STATUS_ONLINE) || 
                            status.equalsIgnoreCase(Medicaid_Constants.STATUS_PUBLISHED)) 
                        {
                            response.redirectUrlId = kav.id;
                            isOnline = true;
                        }

                        if (status.equalsIgnoreCase(Medicaid_Constants.STATUS_ARCHIVED))
                        {
                            isArchived = true;
                        }
                    }
                }

                System.debug('knowledgeArticles ID: ' + articleId);
                System.debug('isDraft: ' + isDraft);
                System.debug('isOnline: ' + isOnline);
                System.debug('isArchived: ' + isArchived);


                if (isDraft && isArchived)
                {
                    KbManagement.PublishingService.deleteDraftArticle(articleId);
                    KbManagement.PublishingService.deleteArchivedArticle(articleId);
                } 
                else if (isArchived) 
                {
                    KbManagement.PublishingService.deleteArchivedArticle(articleId);
                }
                else{
                    response.status = Medicaid_Constants.ERROR;
                    response.message = Medicaid_Constants.ARTICLE_DELETE_ERROR_MSG;
                }
            }
        } catch (Exception e) {
            System.debug('Error Occoured: ' + e.getMessage());
            //throw new AuraHandledException(e.getMessage());
            response.status = Medicaid_Constants.ERROR;
            response.message = e.getMessage();
        }

        System.debug('Return Response: ' + response);
        return response;
    }

    public class KnowledgeArticleResponse{
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public String articleTitle {get; set;}
        @AuraEnabled public String knowledgeArticleId {get; set;}
        @AuraEnabled public String redirectUrlId {get; set;}
        @AuraEnabled public Boolean isUserHasAccessToDelete {get;set;}
        @AuraEnabled public List<Knowledge__kav> knowledgeArticles {get; set;}

        public KnowledgeArticleResponse(){}
    }
}