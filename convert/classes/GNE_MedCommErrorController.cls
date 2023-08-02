public without sharing class GNE_MedCommErrorController {
    
    //public String ErrorMessage { get; set; }
    public static final String viewError = 'You are not authorised to view this page. Please contact your Administrator.';
    public static final String editError = 'A submitted Medical Referral cannot be edited.';
    public static final String deleteError = 'A submitted Medical Referral cannot be deleted.';
    
    Public String ErrorType = '';
    public GNE_MedCommErrorController(ApexPages.StandardController controller) {
        this.controller = controller;
        ErrorType = ApexPages.currentPage().getParameters().get('ErrorType');
        System.debug('ErrorType: --> ' +  ErrorType);
        
        if(ErrorType != null && ErrorType !='' && ErrorType == 'viewError'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,viewError));
        }else if(ErrorType != null && ErrorType !='' && ErrorType == 'editError'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,editError));
        }else if(ErrorType != null && ErrorType !='' && ErrorType == 'deleteError'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,deleteError));
        }else{
        }
    }
    
    private final ApexPages.StandardController controller;
 
}