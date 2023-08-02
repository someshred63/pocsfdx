public class GNE_AP_Error_Controller {
    public String exMessage {get; set;}
    public String unixId {get; set;}
    public Datetime currentDate {get; set;}
    public String developerMessage {get; set;}
    public String exUrl {get; set;}
    public Integer lineNumber {get; set;}
    public Boolean insufficientAccess {get;set;}
    
    public GNE_AP_Error_Controller(){
        exMessage = ApexPages.currentPage().getParameters().get('exMessage');
        developerMessage = Apexpages.currentPage().getParameters().get('lineNumber') + ': '+ Apexpages.currentPage().getParameters().get('developerMessage');
        unixId = getUnixId();
        currentDate = Datetime.now();
        exUrl = ApexPages.currentPage().getParameters().get('exUrl');
    }
    
    private String getUnixId(){
        List<User> users = [SELECT Username FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String unixId = users[0].Username.Substring(0, users[0].Username.indexOf('@'));
        return unixId;
    }
}