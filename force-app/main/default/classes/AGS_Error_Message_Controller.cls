public class AGS_Error_Message_Controller {
    static String MSG_ID    = 'msgid';
    static String FRQ_USER_MSG = 'INFU_FRQ_MSG';
    static String SPENDUSER_NOT_EXIST = 'SPENDUSER_NOT_EXIST';
    
    public String MessageID{get;set;}
    public String Message{get;set;}
     public String Link{get;set;}
      public String LinkLabel{get;set;}
    
    public AGS_Error_Message_Controller(){ 
        
        MessageID = ApexPages.currentPage().getParameters().get(MSG_ID);
        
        
        if (MessageID == SPENDUSER_NOT_EXIST){
            Message = 'NO enough privilages to reopen the case action';           
        }
        
       
        
    }
    
    public PageReference submitMessage()
    {
        
        return null;
    }
    
    
    
}