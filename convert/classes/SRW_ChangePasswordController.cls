public class SRW_ChangePasswordController {

    public String oldPassword{set; get;}
    public String newPassword{set; get;}
    public String confirmPassword{set; get;}
    
    public SRW_ChangePasswordController (){}
    
    public PageReference changePassword(){
    	SRW_UserOperationUtils currentUser = new SRW_UserOperationUtils();
        return currentUser.changeCurrentUserPassword(newPassword, confirmPassword, oldPassword);
    }
    
    public PageReference returnToMainPage(){
        PageReference pr = Page.SRW_HomePageRouter;
        pr.setRedirect(true);
        return pr;
    }
   
}