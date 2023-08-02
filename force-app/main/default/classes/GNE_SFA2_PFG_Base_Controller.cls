public abstract class GNE_SFA2_PFG_Base_Controller {
    
    public static final String SAVE_ERROR_MESSAGE_PREFIX = System.Label.GNE_SFA2_PFG_ERROR_DURING_SAVE;
    public static final String PAGE_LOAD_ERROR_MESSAGE_PREFIX = System.Label.GNE_SFA2_PFG_ERROR_DURING_PAGE_LOAD;
    public static final String MISSING_REQUIRED_FIELD_VALUE = ': ' + System.Label.GNE_SFA2_PFG_ENTER_VALUE;
    public static final String MY_PFG_PAGE_NAME = System.Label.GNE_SFA2_PFG_MAIN_PAGE_NAME;
    public static final String VALUE_ALREADY_IN_USE_MSG = ' ' + System.Label.GNE_SFA2_PFG_VALUE_ALREADY_IN_USE;
    public static final String NO_MANAGER_FOR_CS_MSG = ' ' + System.Label.GNE_SFA2_PFG_NO_MANAGER_FOR_CS;
    public Boolean isCs { get { return GNE_SFA2_PFG_Util.checkIsUserCS(UserInfo.getUserId()); }}
    public Boolean isDm { get { return GNE_SFA2_PFG_Util.checkIsUserDM(UserInfo.getUserId()); }}
    public Boolean isRm { get { return GNE_SFA2_PFG_Util.checkIsUserRM(UserInfo.getUserId()); }}
    public Boolean isBrandManager { get { return GNE_SFA2_PFG_Util.checkIsUserBrandManager(UserInfo.getUserId()); }}
    public Boolean isManager { get { return GNE_SFA2_PFG_Util.checkIsUserManager(UserInfo.getUserId()); }}
    public Boolean hasActiveDtpBrands { get { return GNE_SFA2_PFG_Util.isDtpActiveForUser(UserInfo.getUserId()); }}
    public Boolean hasActiveHcBrands { get { return GNE_SFA2_PFG_Util.isHcActiveForUser(UserInfo.getUserId()); }}
    public String noPfgAccess { get { return System.Label.GNE_SFA2_PFG_NO_BRAND_IS_ACTIVE; }}
    public Boolean canCsUseHc { get { return GNE_SFA2_PFG_Util.canCsUseHc(UserInfo.getUserId()); }}
    public String csManagerNotDefined { get { return NO_MANAGER_FOR_CS_MSG; }}  
    
    private String productCatalogIdPrefix;
    
    public String getProductCatalogIdPrefix() {
    	if(productCatalogIdPrefix==null) {
    		productCatalogIdPrefix = Product_vod__c.sObjectType.getDescribe().getKeyPrefix();
    	}
    	
    	return productCatalogIdPrefix;
    }
    
    public static PageReference setErrorPageReference(Exception ex) {
        return setErrorPageReference(null,ex);
    }
    
    public static PageReference setErrorPageReference(String messagePrefix, Exception ex) {
    	return setErrorPageReference(messagePrefix, ex, ApexPages.currentPage());
    }
    
    public static PageReference setErrorPageReference(String messagePrefix, Exception ex, PageReference currentPageRef) {
    	PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
        pageref.setredirect(true);
        pageref.getParameters().put('exMessage', (messagePrefix!=null ? (messagePrefix + ': ') : '') + ex.getMessage());
        pageref.getParameters().put('exUrl', currentPageRef!=null ? currentPageRef.getUrl() : 'N/A');
        pageref.getParameters().put('developerMessage', ex.getStackTraceString());
        
        String pageName = currentPageRef!=null ? currentPageRef.getUrl().substringAfter('apex/').substringBefore('?') : null;
        
        if(pageName!=null) {
        	GNE_SFA2_PFG_Util.addSessionLabel(pageName);
        }
        
        if(messagePrefix!=null) {
        	GNE_SFA2_PFG_Util.addSessionLabel(messagePrefix);
        }
        
        GNE_SFA2_PFG_Util.handleException(ex);
        GNE_SFA2_PFG_Util.reportExceptions();
        return pageref;
    }
    
    public PageReference initController() {
        PageReference result = null;
        
        try {
            result = intInitCotroller();
        } catch(Exception ex) {
            result = setErrorPageReference(PAGE_LOAD_ERROR_MESSAGE_PREFIX, ex);
        }
        
        return result;
    }
    
    protected virtual PageReference intInitCotroller() {
        return null;
    }
    
    public static PageReference redirectToReturnUrl() {
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        
        if(String.isBlank(retUrl)) {
            retUrl = Page.GNE_SFA2_PFG_MyPFG.getUrl();
        }

        Pagereference pageref = new pagereference(retUrl);
        pageref.setredirect(true);
        return pageref;
    }
    
    public static PageReference cancel() {
        return redirectToReturnUrl();
    }
    
    public class InvalidInputValueException extends Exception {
        public List<String> errorMessages;
        public InvalidInputValueException(List<String> errorMsgs) {
            errorMessages = errorMsgs;
        }
    }
    
    public String getPfgActiveMenuItem() {
        return MY_PFG_PAGE_NAME;
    }
    
    public static Boolean validateIsInteger(Double value) {
    	return validateIsInteger(String.valueOf(value));
    }
    
    public static Boolean validateIsInteger(Decimal value) {
    	return validateIsInteger(String.valueOf(value));
    }
    
    public static Boolean validateIsInteger(String value) {
    	
    	Boolean isValid = true;
    	    
        try {
        	Integer intQty = Integer.valueOf(value);
        } catch(Exception ex) {
        	isValid = false;
        }
        
        return isValid;
    }
}