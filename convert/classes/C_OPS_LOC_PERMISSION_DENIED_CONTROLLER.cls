public class C_OPS_LOC_PERMISSION_DENIED_CONTROLLER {
    
    private C_OPS_LOC_REQUEST__C myRequest;
    
    public C_OPS_LOC_PERMISSION_DENIED_CONTROLLER(ApexPages.StandardController stdController){
        
        myRequest = (C_OPS_LOC_REQUEST__C)stdController.getRecord();
    }
    
    public pageReference takeMeBack(){
        
        PageReference newPage = New PageReference('/' + myRequest.Id);
        newPage.setRedirect(true);
        return newPage;
    }
}