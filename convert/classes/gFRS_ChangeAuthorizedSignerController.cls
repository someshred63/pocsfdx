public with sharing class gFRS_ChangeAuthorizedSignerController {
    /** current funding Request **/
    
    public static final String SIGNER_DATA_EMPTY_ERROR = 'Please specify the authorized signer\'s data';
    public Boolean isVisible{get;set;}
    
    public GFRS_Funding_Request__c request { get; set; }
    
    public gFRS_ChangeAuthorizedSignerController( ApexPages.StandardController stdCtrlr ) {
        this.isVisible = true;
        this.request = (GFRS_Funding_Request__c) stdCtrlr.getRecord();
        try {
            this.request = [ SELECT Sub_Status__c, Signing_Authority_Email__c, Authorized_Signer__c,
                             Signing_Authority_First_Name__c, Signing_Authority_Last_Name__c, LOA_Signed__c
                             FROM GFRS_Funding_Request__c
                             WHERE id = :this.request.id ];
                
            if(this.request.LOA_Signed__c == 'Yes' || this.request.Sub_Status__c == 'Not Submitted'){
                this.isVisible=false;
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Authorized Signer cannot be modified after the LOA is signed or before the request is submitted.' ));
            }    
        }
        catch ( Exception ex ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find the external funding request' ));
            return;
        }
     }
     
     public ApexPages.PageReference save(){

        if(!this.isVisible){
            return( nextPage() );
        }
        
        if( !validateSave() ){
             return (null);
        }
        
        SavePoint sp = Database.setSavePoint();
        try{
            
            //assign authorized signer
            User[] potentialAuthorizedSigners = gFRS_Util_NoShare.userByEmail(this.request.Signing_Authority_Email__c);
               
            if (potentialAuthorizedSigners.size() > 0) {
                this.request.Authorized_Signer__c = potentialAuthorizedSigners[0].Id;
                //system.('new Authorized_Signer__c id set : ' + this.request.Authorized_Signer__c );
            }
            else {
                this.request.Authorized_Signer__c=null;
            }
            
            //-- share with the appropriate user
            //System.debug('preparing to share with other users if user was not found sharing rule not added');
            if(this.request.Authorized_Signer__c != null){
                if(!gFRS_Util_NoShare.applySharingRulesForSelectedUsers(this.request.Id, this.request.Signing_Authority_Email__c)){
                    System.debug( 'Could not share with other user:' + this.request.Signing_Authority_Email__c + ']' );
                }
            }
            //System.debug( 'SIGNING AUTHORITY EMAIL:' + this.request.Signing_Authority_Email__c );
            
            gFRS_Util_NoShare.saveLockedFundingRequest( this.request );
        }
        catch ( Exception err ) {
            Database.rollback(sp);
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
            return (null);
        }
        
        return( nextPage() );
        
    }
    
    public ApexPages.PageReference nextPage(){
        //check if user is an internal user
        String targetPath = '/'+this.request.Id;
        return( new ApexPages.PageReference( gFRS_Util.initializeLink( targetPath, null, null ) ));
    }
    
    /**
     *  Validates the page before submission
     *  @return (Boolean) - whether validation passed (True) or failed (false)
     **/
    public Boolean validateSave(){
        
        if (this.request.Signing_Authority_Email__c == null
                || this.request.Signing_Authority_First_Name__c == null
                || this.request.Signing_Authority_Last_Name__c == null) {

            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, SIGNER_DATA_EMPTY_ERROR )); 
            return( false );
        }
        
        if (this.request.Signing_Authority_Email__c != null
                && (
                    this.request.Signing_Authority_Email__c.containsIgnoreCase('@gene.com')
                    || this.request.Signing_Authority_Email__c.containsIgnoreCase('@roche.com')
                )
           ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ConfirmationError_UnauthorizedEmail )); 
            return( false );
        }
        
        //-- validate page
        return( true );
    }
}