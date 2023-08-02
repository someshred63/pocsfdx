/**
 *  Controller for the Error page.
 *  
 *  <p>This simply retrieves the error code sent to it, and renders the page accordingly.</p>
 **/
public with sharing class gFRS_ErrorController {
    
    //-- lookup constants
    public static final String CONTENT_TYPE = 'Errors';
    
    /** Blacklisted organization error message **/
    public static final String CODE_BLACKLIST = '201';
    public static final String CODE_BLACKLISTCopay = '201Copay';
    /** Translation key for Blacklisted Organization **/
    //public static final String KEY_BLACKLIST = 'BlackList';
    
    public static final String CODE_RECONCILIATION_DUE = '202A';
    /** Translation key for Reconcilation due **/
    //public static final String KEY_RECONCILIATION_DUE = 'WEB 202A External';
    
    public static final String CODE_REFUND_DUE = '202B';
    /** Translation key for Refund due **/
    //public static final String KEY_REFUND_DUE = 'WEB 202B External';
    
    public static final String CODE_SUNSHINE_DUE = '202C';
    public static final String CODE_EVALUATIONS_DUE = '202D';
    
    public static final String CODE_ANNUAL_EVALUATION_DUE = '202E';
    
    public static final String CODE_INV_ORG = '203';
    public static final String CODE_INV_ORGcopay = '203Copay';
    /** Translation key for Invalid Organization **/
    //public static final String KEY_INV_FUND = 'InvalidRequestType';
    
    /*
    public static final String CODE_BLACKLIST_INTERNAL = '501';
    public static final String KEY_BLACKLIST_INTERNAL = 'BlackList WEB201';
    */
    
    /** Invalid Fundign Request error message **/
    public static final String CODE_INV_FUND = '301';
    /** Translation key for Invalid Funding Request **/
    //public static final String KEY_INV_FUND = 'InvalidRequestType';
   
    /** Firewall error **/
    public static final String CODE_FIREWALL = '401';
    //public static final String KEY_FIREWALL = 'WEB 401 External';
    
    
    public static final String CODE_W9W8_MISSING ='1001';
    
    /** error code parameter **/
    public static final String PARAM_ERROR_CODE='code';
    
    //-- local variables
    /** error code sent **/
    public String errorCode { get; set; }
    
    /** the sidebar navigation location **/
    public String sidebarLocation { get; set; }
    
    /** The error message to provide **/
    public String errorMessage { get; set; }
    
    /** Translations **/
    public Map<String,String> translations;
    
    public gFRS_ErrorController(){
        Contact userContact = gFRS_Util_NoShare.getUserContact( UserInfo.getUserId() );
        Boolean isInternalUser = userContact == null;
        
        this.errorCode = null;
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if( params != null ){
            if( params.containsKey( PARAM_ERROR_CODE ) ) this.errorCode = String.valueOf( params.get( PARAM_ERROR_CODE ));
        }
        
        this.translations = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( CONTENT_TYPE, UserInfo.getLanguage() );
        
        this.sidebarLocation = '-1';
        this.errorMessage = null;
        
        System.debug( 'errorCode[' + errorCode + ']');
        if( CODE_BLACKLIST.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = ( isInternalUser ) ? this.translations.get( 'WEB 201 Internal' ) : this.translations.get( 'WEB 201 External' );
        } else if( CODE_BLACKLISTCopay.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = ( isInternalUser ) ? this.translations.get( 'WEB 201 Internal Copay' ) : this.translations.get( 'WEB 201 External Copay' );
        } else if( CODE_RECONCILIATION_DUE.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = this.translations.get( 'WEB 202A External' );
        } else if( CODE_REFUND_DUE.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = this.translations.get( 'WEB 202B External' );
        } else if( CODE_INV_ORG.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = ( isInternalUser ) ? this.translations.get( 'WEB 203 Internal' ) : this.translations.get( 'WEB 203 External' );
        } else if( CODE_INV_ORGcopay.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = ( isInternalUser ) ? this.translations.get( 'WEB 203 Internal Copay' ) : this.translations.get( 'WEB 203 External Copay' );
        }else if( CODE_INV_FUND.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = this.translations.get( 'WEB 301 External' );
        }else if( CODE_FIREWALL.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = this.translations.get( 'WEB 401 External' );
        }else if(CODE_W9W8_MISSING.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = System.Label.gFRS_MSG_W9W8_MISSING;    
        }else if(CODE_SUNSHINE_DUE.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = this.translations.get( 'WEB 202C External' );
        }else if(CODE_EVALUATIONS_DUE.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = this.translations.get( 'WEB 202D External' );
        }else if(CODE_ANNUAL_EVALUATION_DUE.equals( errorCode )){
            this.sidebarLocation = '2';
            this.errorMessage = ( isInternalUser ) ? this.translations.get( 'WEB 202E Internal' ) : this.translations.get( 'WEB 202E External' );
        }
        else {
            //-- ignore
            this.errorMessage = 'An error occurred. Please consult your administrator for more information.';
        }
    }
}