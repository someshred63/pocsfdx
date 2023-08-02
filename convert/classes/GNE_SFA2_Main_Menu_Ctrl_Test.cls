/* 
@isTest(SeeAllData=true)
public class GNE_SFA2_Main_Menu_Ctrl_Test {

    static testmethod void testGNE_SFA2_Main_Menu() {        
        Test.startTest();
        GNE_SFA2_Main_Menu_Ctrl objTst=new GNE_SFA2_Main_Menu_Ctrl();    
        IC_Calc_Sales_Roster_gne__c ob=new IC_Calc_Sales_Roster_gne__c();
        ob.Brand_Name_gne__c='Test';
        ob.User_Profile_gne__c='Test';
        Database.Insert(ob);
        
        SFA2_User_Sales_Roster_gne__c ob1=new SFA2_User_Sales_Roster_gne__c();
        ob1.Profile_Name_gne__c='Test';
        ob1.Role_gne__c='CS';
        ob1.User_gne__c=UserInfo.getUserId();
        ob1.Sales_Roster_gne__c=ob.Id;
        Database.Insert(ob1);  
        
        SFA2_Configuration_Object_gne__c ob2=new SFA2_Configuration_Object_gne__c();
        ob2.Name='Test';
        ob2.Attributes_gne__c='Test';
        Database.Insert(ob2);
        
        SFA2_Configuration_Object_Detail_gne__c ob3=new SFA2_Configuration_Object_Detail_gne__c();
        ob3.Name='Test';
        ob3.Label_gne__c='Test';
        ob3.Attributes_gne__c='Test';
        ob3.Configuration_Object_ref_gne__c=ob2.Id;
        Database.Insert(ob3);
        
        
        GNE_SFA2_Main_Menu_Comp.GNE_SFA2_Dynamic_Comp_Bean objTstBean=new GNE_SFA2_Main_Menu_Comp.GNE_SFA2_Dynamic_Comp_Bean();
        objTstBean.strName='Test';
        objTstBean.strLabel='Test';
        objTstBean.strAttribute='Test';

        Test.stopTest();
     }  

}
*/

// commented above test class is replaced w/ below test methods. feb 3 2013 guru k  
@isTest(SeeAllData=false)
public class GNE_SFA2_Main_Menu_Ctrl_Test {

    static IC_Calc_Sales_Roster_gne__c createApplication (String appType, String brandName, String profileName, String url) {    
        IC_Calc_Sales_Roster_gne__c app=new IC_Calc_Sales_Roster_gne__c(Type_gne__c = appType,
            Brand_Name_gne__c= brandName,            
            User_Profile_gne__c= profileName,
            app_url_gne__c = url );
        insert app;
        return app;     
    }
    
    static SFA2_Configuration_Object_gne__c createAppConfiguration (String name, String configType, String attributes,String brandName, String roleName) {
        SFA2_Configuration_Object_gne__c configObject=new SFA2_Configuration_Object_gne__c(
            Name= name, 
            Attributes_gne__c = attributes,
            configuration_type_gne__c = configType,
            brand_gne__c = brandName,
            Role_gne__c =  roleName);
        insert configObject;            
        
        SFA2_Configuration_Object_Detail_gne__c configObjectDetail=new SFA2_Configuration_Object_Detail_gne__c(
	        type_gne__c= 'Menu Item',
	        Label_gne__c='Test',
	        Attributes_gne__c='/home/home.jsp',
	        Configuration_Object_ref_gne__c= configObject.Id);        
        insert configObjectDetail;
    	
    	return configObject;
    }

    static testmethod void testGNE_SFA2_Main_Menu() {
        
        IC_Calc_Sales_Roster_gne__c app1= createApplication ('SFA-US', 'AVA', 'AVA Profile', 'www.gene.com/AVA');
        createAppConfiguration('SFA Links', 'Menu Layout', 'GNE_SFA2_MyAccounts;Accounts.png', 'AVA', 'CS');
        createAppConfiguration('SFA Links', 'Menu Layout', 'Calendar;Calendar.png', 'XOL','CS');
        IC_Calc_Sales_Roster_gne__c app2= createApplication ('SFA-US', 'XOL', 'XOL Profile', 'www.gene.com/XOL');
        
        List<SFA2_User_Sales_Roster_gne__c> userSalesRosterList = new List<SFA2_User_Sales_Roster_gne__c>();
        userSalesRosterList.add ( new SFA2_User_Sales_Roster_gne__c(
	        Profile_Name_gne__c= 'AVA Profile',
	        Role_gne__c='CS',
	        User_gne__c=UserInfo.getUserId(),
	        Sales_Roster_gne__c=app1.Id) );
        userSalesRosterList.add ( new SFA2_User_Sales_Roster_gne__c(
            Profile_Name_gne__c= 'XOL Profile',
            Role_gne__c='CS',
            User_gne__c=UserInfo.getUserId(),
            Sales_Roster_gne__c=app2.Id) );
        insert userSalesRosterList;
        
        Test.startTest();
            GNE_SFA2_Main_Menu_Ctrl mainMenuController=new GNE_SFA2_Main_Menu_Ctrl();  
        Test.stopTest();
     }  

}