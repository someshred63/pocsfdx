public class GNE_CM_LoginHistory
{
    @future public static void snapshot()
    {    
        
        //Environment variable modified by Malini becuase in Spring09  DESCRIPTION_NAME__C needs to be used instead of name.
        List<Environment_Variables__c> ev_obj  = new List<Environment_Variables__c>([select value__c from environment_variables__c where DESCRIPTION_NAME__C = 'UserLoginHistoryModificationInformation']);
        User_Login_History_gne__c[] insert_batch = new User_Login_History_gne__c[]{};        
        User[] hist = new User[]{};
        hist = [select Id, Username, LastLoginDate from User where LastLoginDate > :datetime.valueof(ev_obj[0].value__c)];
        Integer i=0;
        for(i=0; i<hist.size(); i++)
        {
            User_Login_History_gne__c u = new User_Login_History_gne__c();
            u.User_gne__c = hist[i].Id;
            u.Login_Date_gne__c = date.newinstance(hist[i].LastLoginDate.year(), hist[i].LastLoginDate.month(), hist[i].LastLoginDate.day());
            u.User_Login_History_Index_gne__c = u.User_gne__c+'-'+u.Login_Date_gne__c;
            insert_batch.add(u);
        }
        ev_obj[0].value__c = String.valueof(system.now());
        
        update ev_obj[0]; 
        
        Database.SaveResult[] insertResult = Database.insert(insert_batch, false);
        if (insertResult!= null){
        for (Database.SaveResult result : insertResult) {
            if (!result.isSuccess()) {
                Database.Error[] errs = result.getErrors();
                for(Database.Error err : errs)
                    System.debug(err.getStatusCode() + ' - ' + err.getMessage());
 
            }
        }
        }
        
        //insert insert_batch;
                
         
    }

}