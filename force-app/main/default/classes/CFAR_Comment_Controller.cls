public with sharing class CFAR_Comment_Controller extends CFAR_TrialBaseController {
    final Integer pageSize = 10;
    transient List<CFAR_SObjectWrapper> objectListComment;
    public ApexPages.StandardSetController stdSetControllerComment;
    public CFAR_Comment_gne__c newComment {get; set;}
    public Boolean showNewCommentPopup {get; set;}
    
    private String oldTrialId = '';
    
    public Id commentId {get; set;}
    public Map<Id, CFAR_SObjectWrapper> commentsMap {get; set;}
    
    private List<SelectOption> wholeContactsSearchList;
    private transient List<SelectOption> contactSearchList1;
    private transient List<SelectOption> contactSearchList2;
    private transient List<SelectOption> contactSearchList3;
    private transient List<SelectOption> contactSearchList4;
    //private transient List<SelectOption> contactSearchList5;
    
    public CFAR_Comment_Controller (){
        super(true);
        //to clear message shown e.g after creating new trial (it doesn't work)
        //ApexPages.getMessages().clear();
        isError = false;
        showNewCommentPopup = false;
        errorMessage = '';
        if (trial != null && trial.Id != null) {
            oldTrialId = trial.Id;
        }
        setDefaultSortExpressionAndDirection();
        initAvailableContactsList();
    }
    
    /**
    public CFAR_Comment_Controller(final CFAR_Trial_Controller trialContr) {
        super(trialContr);
        //isError = false;
        //showNewCommentPopup = false;
        searchParam = new CFAR_SearchParameters();
        setDefaultSortExpressionAndDirection();
    }
    */
    
    public List<CFAR_SObjectWrapper> getobjectListComment() {
        initComments(); 
        fillComments();       
        return objectListComment;
    }
    
    private void initComments() {
        if (stdSetControllerComment == null || trialIdHasChanged(trial.Id != null ? trial.Id : '')) {
            getCommentsFromDB();
        }
    }
    
    private Boolean trialIdHasChanged(String newTrialId) {
        Boolean retval = false;
        if (!oldTrialId.equals(newTrialId)) {
            retval = true;
            oldTrialId = newTrialId;
        }
        return retval;
    }
    
    private void fillComments() {
        objectListComment = new List<CFAR_SObjectWrapper>();
        commentsMap = new Map<Id, CFAR_SObjectWrapper>();
        for(SObject s : stdSetControllerComment.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s);
            objectListComment.add(obj);
            commentsMap.put(s.Id, obj);
        }
    }
    
    public void sortComment() {
        searchParam.sortDirection = sortDirection;
        searchParam.sortExpression = sortExpression;
        getCommentsFromDB();
    }
    
    private void setDefaultSortExpressionAndDirection() {
        searchParam.sortExpression = 'Activity_Date_gne__c';
        searchParam.sortDirection = 'desc';
        //lines above are enough for proper query params for sorting, but for proper displaying of arrows lines below are needed
        sortExpression = 'Activity_Date_gne__c';
        sortDirection = 'desc';
    }
    
    
    public void createNewComment() {
        //newComment = new CFAR_Comment_gne__c(CFAR_Trial_ref_gne__c = trial.Id);
        //newComment = new CFAR_Comment_gne__c(CFAR_Trial_ref_gne__c = trial.Id, Created_By_SFDC_User_ref_gne__c = UserInfo.getUserId());
        
        //it's very slow, when this method is run for every creation of comment - let's add it to the end of class constructor
        //(will be fired every time, when user enters this tab (not while changing trial and staying on tab))
        //initAvailableContactsList();
        newComment = new CFAR_Comment_gne__c(CFAR_Trial_ref_gne__c = trial.Id, Created_By_CFAR_Contact_ref_gne__c = getContactIdForCurrentUser(), Activity_Date_gne__c = System.today());
        showNewCommentPopup = true;
        isError = false;
        errorMessage = '';
    }
    
    private String getContactIdForCurrentUser() {
        String userId = UserInfo.getUserId();
        String contactForCurrentUserId;
        List<CFAR_Contact_gne__c> CFARContactForCurrentUser = [select Id from CFAR_Contact_gne__c where User_ref_gne__c = :userId limit 1];
        if (CFARContactForCurrentUser != null && !CFARContactForCurrentUser.isEmpty()) {
            contactForCurrentUserId = CFARContactForCurrentUser[0].Id;
        }
        return contactForCurrentUserId;
    }
    
    private void initAvailableContactsList() {
        wholeContactsSearchList = new List<SelectOption>{new SelectOption('', '--None--')};
        for (CFAR_Contact_gne__c cnt : [select Id, Search_Name__c from CFAR_Contact_gne__c where Search_Name__c != null order by Search_Name__c limit 3999]) {
            wholeContactsSearchList.add(new SelectOption(cnt.Id, cnt.Search_Name__c));
        }
    }
    
    public List<SelectOption> getContactSearchList1() {
    	contactSearchList1 = CFAR_Utils.getContactSearchListPart1(wholeContactsSearchList);
        return contactSearchList1;
    }
    
    public List<SelectOption> getContactSearchList2() {
    	contactSearchList2 = CFAR_Utils.getContactSearchListPart2(wholeContactsSearchList);
        return contactSearchList2;
    }
    
    public List<SelectOption> getContactSearchList3() {
    	contactSearchList3 = CFAR_Utils.getContactSearchListPart3(wholeContactsSearchList);
        return contactSearchList3;
    }
    
    public List<SelectOption> getContactSearchList4() {
    	contactSearchList4 = CFAR_Utils.getContactSearchListPart4(wholeContactsSearchList);
        return contactSearchList4;
    }
    
    /**
    public List<SelectOption> getContactSearchList5() {
    	contactSearchList5 = CFAR_Utils.getContactSearchListPart5(wholeContactsSearchList);
        return contactSearchList5;
    }
    */
    
    /** After creating new comment, std. set controller won't be null, but we want to get it from DB.
     *  Method for saving new comment should call at the end: getCommentsFromDB(), because after that
     *  there'll be called getter method with init (which will skip getCommentsFromDB(), 'cause stdSetControllerComment != null)
     */
    
    public PageReference submitNewComment() {
        isError = false;
        errorMessage = '';
        System.Savepoint sp = Database.setSavepoint();
        try {
            if (newComment.Activity_Date_gne__c == null || newComment.Comments_gne__c == null || String.isBlank(String.valueOf(newComment.Created_By_CFAR_Contact_ref_gne__c))) {
                /**if (newComment.Activity_Date_gne__c == null) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Activity Date Required!'));
                    System.debug('Slawek DBG date req');
                }
                if (newComment.Comments_gne__c == null) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Comments Required!'));
                    System.debug('Slawek DBG comments req');
                }*/
                errorMessage = 'Please, fill in all required fields';
                isError = true;
                if (newComment.Id != null) {
                	getCommentsFromDB();
                }
                return null;
            }
            if (newComment.Activity_Date_gne__c != null && newComment.Activity_Date_gne__c > System.today()) {
            	errorMessage = 'Activity Date cannot be in the future';
                isError = true;
                if (newComment.Id != null) {
                	getCommentsFromDB();
                }
                return null;
            }
            System.debug('Slawek DBG tries to insert');
            //insert newComment;
            upsert newComment;
        }
        catch (Exception e) {
            System.debug('Slawek DBG in exc catch');
            Database.rollback(sp);
            //ApexPages.addMessages(e);
            errorMessage = e.getMessage();
            isError = true;
            //check if in case of error, wrong record won't be added to table!
            if (newComment.Id != null) {
            	getCommentsFromDB();
            }
            return null;
        }
        //zostawic na razie wczesniej wybrany sort order
        //setDefaultSortExpressionAndDirection();
        System.debug('Slawek DBG at the end');
        getCommentsFromDB();
        return null;    
    }
    
    public void cancelNewComment() {
        showNewCommentPopup = false;
        //in case of editing comment for cancel is needed new query (otherwise, row data will be changed despite cancelling!)
        if (newComment.Id != null) {
        	getCommentsFromDB();
        }
    }
    
    /** Pagination methods */
    
    private void getCommentsFromDB() {
        stdSetControllerComment = new ApexPages.StandardSetController(CFAR_DAO.getComments(searchParam, trial.Id));
        stdSetControllerComment.setPageSize(pageSize);
    }
    
    public void previousComment() {
        stdSetControllerComment.previous();
    }
    
    public void nextComment() {
        stdSetControllerComment.next();
    }
    
    public void firstComment() {
        stdSetControllerComment.first();
    }
    
    public void lastComment() {        
        stdSetControllerComment.last();
    }
    
    public Boolean hasNextComment {
        get {
            return stdSetControllerComment.getHasNext();
        }
        private set;
    }
    
    public Boolean hasPreviousComment {
        get {
            return stdSetControllerComment.getHasPrevious();
        }
        private set;
    }
    
    public PageReference deactivateComment() {
        System.Savepoint sp = Database.setSavepoint();
        try {
            //CFAR_Comment_gne__c comToDeact = [select Id, Active_gne__c from CFAR_Comment_gne__c where Id =: commentId limit 1][0];
            CFAR_Comment_gne__c comToDeact = (CFAR_Comment_gne__c)commentsMap.get(commentId).innerObject;
            comToDeact.Active_gne__c = false;
            CFAR_SecurityUtils.updateRecord(comToDeact);
        }
        catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        //success
        getCommentsFromDB();
        return null;
    }
    
    //newComment property is also used for edited comment
    public void editComment() {
    	newComment = (CFAR_Comment_gne__c)commentsMap.get(commentId).innerObject;
    	showNewCommentPopup = true;
        isError = false;
        errorMessage = '';
    }
    
}