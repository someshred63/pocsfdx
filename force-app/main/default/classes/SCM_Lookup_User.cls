public class SCM_Lookup_User {
//First name to search
public string UserName {
      get { return UserName; }
      set { UserName = value; }
   }
    
   //array list of users
   public List<User> Results {
      get { return Results; }
      set { Results = value; }
   }
   
//Method to do search
    Public void Lookup() {
    List<User> Cas;
  //use these temporary strings so that the search boxes are not changed
    string fn; 
    //Convert string to be database frinedly 
     if (UserName != '') {
      fn = UserName.replace('*','%');}
     else {
      	//string is empty so it is set as a wild card
      	fn = '%';
    }
      
    
    Cas = [Select Username, Name, title, Phone,UserRole.Name,Email,firstname,lastname From User where name like :fn limit 20 ];
    
   
    Results =  Cas;
    
    }
  
public static testmethod void mytest() {
SCM_Lookup_User c = New SCM_Lookup_User();
c.UserName = '*';
c.lookup();
}
  }