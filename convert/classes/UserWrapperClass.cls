Public class UserWrapperClass{

    /*Public String UserId {get;set;}
    Public String FullName {get;set;}
    Public String Title {get;set;}
    Public String Phone {get;set;}
    Public String Email {get;set;}
    Public String Role {get;set;}
    Public String Profile {get;set;}*/
    Public String TherapeuticArea {get;set;}
    //Public String State {get;set;}
    Public User userObj {get;set;}
    public String username {get;set;}

    
    //wrappervariable.add(new UserWrapperClass(userRepRoster.User_gne__c, userRepRoster.User_gne__r.Name, userRepRoster.User_gne__r.Title, userRepRoster.User_gne__r.Phone, userRepRoster.User_gne__r.Email, userRepRoster.User_gne__r.userrole.name, userRepRoster.User_gne__r.Profile_Name_gne__c, ''));
    
    
    /*Public UserWrapperClass(User userObject, String UserTherapeuticArea, String UserState)
    {
        userObj=userObject;
        
        TherapeuticArea = UserTherapeuticArea;
        State=UserState;
        //userObj=userObject;
        
    }*/
    Public UserWrapperClass(User userObject, String UserTherapeuticArea)
    {
        userObj=userObject;
        
        System.debug('### userObj.name'+userObj.name);
        if( userObj.name.contains('\''))
        {
            System.debug('### userObj.name=>'+userObj.name.replace('\'','\\\''));
            username=userObj.name.replace('\'','\\\'');
        }
        else
        {
            username=userObj.name;
        }
        System.debug('### userObj.name'+userObj.name);
        TherapeuticArea = UserTherapeuticArea;
        //State=UserState;
        //userObj=userObject;
        
    }
}