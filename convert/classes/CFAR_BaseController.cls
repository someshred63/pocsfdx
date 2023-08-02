public virtual class CFAR_BaseController{
    final static String EDIT_MODE_PARAM = 'editMode';
    private String retPageURL;  /*this variable can be overwritten from subclasses and used for redirecting  - if it's set, than by default rediraction takes place to pointed URL*/ 
    
    public Boolean isError {get; set;}
    public String errorMessage {get; set;}
    //refrerence to current checked SObject
    public String currentObjectRefId {get;set;}
    private final String currentUserProfileName;
    
    public String sortExpression {get; 
        set {
            sortExpression = value;
            if(sortFieldOld == null) sortFieldOld = sortExpression;
            if(sortFieldOld == sortExpression) {
                if(sortDirection == 'desc') sortDirection = 'asc';
                else sortDirection = 'desc';
            } else {
                sortDirection = 'desc';
                sortFieldOld = sortExpression;
            }
        }
    }
    protected String sortFieldOld;
    public String sortDirection {get; set;}
    
    public CFAR_SearchParameters searchParam {get; set;}
    
    private Boolean isMSLUser;
    
    public CFAR_BaseController() {
        isError = false;
        currentUserProfileName = CFAR_Utils.currentUser.Profile.Name;
        isMSLUser = CFAR_Utils.hasCFARPermissionSet();
        searchParam = new CFAR_SearchParameters();
    }
    
    public Boolean getIsITAdministrator() {
        return currentUserProfileName == 'GNE-CFAR-IT-Admin-New';
    }
    
    public Boolean getIsSFDCSystemAdministrator() {
        return currentUserProfileName == 'System Administrator';
    }
    
    public Boolean getisITAdminOrSFDCAdmin(){
    	return getIsITAdministrator() || getIsSFDCSystemAdministrator();
    }
    
    public Boolean getIsSystemAdministrator() {
        return currentUserProfileName == 'GNE-CFAR-Admin-New';
    }
    
    public Boolean getIsGNEMASupport() {
        return currentUserProfileName == 'GNE-MA-Support';
    }
    
    public Boolean getIsReadOnly() {
        return currentUserProfileName == 'GNE-CFAR-ReadOnlyUser-New' || isMSLUser;
    }
    
    public Boolean getIsAverageUser() {
        return currentUserProfileName == 'GNE-CFAR-User-New';
    }
    
    public Boolean getCurrentUserIsAdmin(){
        return getIsITAdministrator() || getIsSystemAdministrator() || getIsSFDCSystemAdministrator() || getIsGNEMASupport();
    }
    
    public Boolean editMode{public get{
        if (editMode==null){
            String editModeParam = ApexPages.currentPage().getParameters().get(EDIT_MODE_PARAM);
            editMode = editModeParam == null ? false : Boolean.valueOf(editModeParam);
        }
        return editMode;     
    } 
        protected set;
    }
    
    
    protected Map<String, String> getCurrentPageParameters(){
        return ApexPages.currentPage().getParameters();
    }

    
    protected String getCurrentPageParameter(String parameterName){
        return getCurrentPageParameters().get(parameterName); 
    }
    
    public PageReference getReturnPage(){
        String retUrlParam = ApexPages.currentPage().getParameters().get('retURL'); 
        String retURL = String.isBlank(retPageURL) ? retUrlParam : retPageURL; 
        PageReference retPage = String.isBlank(retPageURL) ? Page.CFAR_HOME : new PageReference(retPageURL);    
        retPage.setRedirect(true); 
        return retPage;
        
    }
    
    public virtual PageReference cancel(){
        //String retUrlParam = ApexPages.currentPage().getParameters().get('retURL'); 
        //this.retPage = String.isBlank(retUrlParam) ? Page.CFAR_HOME : new PageReference(retUrlParam);    
        return getReturnPage(); 
    }

    public void addErrorMessage(String message){
                addErrorMessages(new List<String>{message}); 
    }

    public void addErrorMessages(List<String> messages){
            for(String message: messages){
                System.debug('MARCIN '+message);
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, message ));
            }
    }
    
    public void logMessage() {
        //errorMessage = '';
        if(String.isBlank(errorMessage)) errorMessage = '';
        for(ApexPages.Message m : ApexPages.getMessages()) {
            errorMessage += m.getDetail();
        }
    }
    
    public void resetError() {
        errorMessage = '';
        isError = false;
    }

}