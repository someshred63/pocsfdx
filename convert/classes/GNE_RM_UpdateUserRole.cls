global class GNE_RM_UpdateUserRole {


    @future
    public static void updateUserRole (List<Id> userIdList) {
    
        List<User> userList = [select id, business_role_gne__c, email from user where id in :userIdList];
        
        List<User_Business_Role_gne__c> ubrList =   
                                    [ select id, user_gne__c,Business_Role_gne__c from user_business_role_gne__c
                                      where user_gne__c in :userIdList 
                                      order by lastmodifieddate desc ] ;
    
        Map<Id, String> userRoleMap = new Map<Id,String>();
        
        for ( User_Business_role_gne__c ubr: ubrList ){
            if ( userRoleMap.get ( ubr.user_gne__c) == null ) {
                userRoleMap.put ( ubr.user_gne__c, ubr.business_role_gne__c );
            }
        }
        
        for (User u: userList ) {
            u.business_role_gne__C = userRoleMap.get (u.Id);            
            Integer i = u.email.lastIndexOf ('.com.');
            if ( i !=-1) 
                u.email = u.email.substring(0,i+4);
            
        }
        
        update userList;
    }

}