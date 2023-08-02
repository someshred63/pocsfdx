/* 
*this class controls the threeSixtyDegreeReport
*It acts as a controlled nd all the Utility methods for the 360 degree report functionality are present 
* in this class
*/

public class ThreeSixtyDegreeController{
    
String accountID ='';
String userID ='';
Set<ID> contactAccountIDs = new Set<ID>();
public ThreeSixtyDegreeController(){
accountID = System.currentPageReference().getParameters().get('pv0');
userID = System.UserInfo.getUserId();
}

public void deleteOldReport(){
List<ThreeSixtyDegreeReport_gne__c> deletedList = new List<ThreeSixtyDegreeReport_gne__c>();
deletedList = [Select Id from ThreeSixtyDegreeReport_gne__c where UserId_gne__c =: userID.subString(0,15)];
delete deletedList;
}

public void  generateNewReport(String accountID){
List<ThreeSixtyDegreeReport_gne__c> threeSixtyDegreeReport_List = new List<ThreeSixtyDegreeReport_gne__c>();
List<Affiliation_vod__c> affiliationList = new List<Affiliation_vod__c>();
List<Call2_vod__c> interactionList = new List<Call2_vod__c>();
Set<ID> affiliationAccountIDs = new Set<ID>();
affiliationList = [Select a.Account_No_gne__c, a.CreatedById, a.CreatedDate, a.From_Account_vod__c, a.To_Account_vod__c ,a.Id from Affiliation_vod__c a where a.From_Account_vod__c =:accountID OR a.To_Account_vod__c =:accountID ];
for(Affiliation_vod__c affiliation: affiliationList){
affiliationAccountIDs.add(affiliation.From_Account_vod__c);
affiliationAccountIDs.add(affiliation.To_Account_vod__c);
//affiliationAccountIDs.add(accountID);
}
affiliationAccountIDs.add(accountID);
List<Contact> contactAccID_List = [Select AccountId from Contact where HCP_gne__c =:accountID];

for(Contact obj :contactAccID_List ){
affiliationAccountIDs.add(obj.AccountId);
}
//affiliationAccountIDs.add(contactAccountIDs);
System.debug('Number of accounts : '+affiliationAccountIDs.size()+' and accounts IDs: ' + affiliationAccountIDs);

interactionList = [Select Account_vod__c, CreatedById,CreatedDate,CreatedBy.Profile_Name_gne__c,Account_vod__r.Name,CreatedBy.Name, CreatedBy.ProfileId,Id,Call_Date_vod__c,Name from Call2_vod__c
    where Account_vod__c IN :affiliationAccountIDs and (Call_Date_vod__c = LAST_90_DAYS  OR Call_Date_vod__c = NEXT_90_DAYS ) and Account_vod__c!=null];

System.debug('interactionList: ' + interactionList);
for(Call2_vod__c interaction : interactionList ){
ThreeSixtyDegreeReport_gne__c obj360Report = new ThreeSixtyDegreeReport_gne__c();
obj360Report.Account_gne__c = interaction.Account_vod__c;
obj360Report.Interaction_Created_Date_gne__c = interaction.Call_Date_vod__c;
obj360Report.Interaction_gne__c = interaction.id;
obj360Report.User_Profile_Name_gne__c = interaction.CreatedBy.Name +' ( '+ interaction.CreatedBy.Profile_Name_gne__c+' ) ';
threeSixtyDegreeReport_List.add(obj360Report);
}
insert threeSixtyDegreeReport_List;
}
//Insert the records of the object ThreeSixtyDegreeReport_gne__c on click of the button Generate three Sixty Degree Report.
public Pagereference runReport(){
  System.debug('in runReport() method '+'accountID: '+ accountID);
 if(accountID != null || accountID !=''){
  System.debug('  before obj.generateNewReport(accountID); '+'accountID: '+ accountID);
 ThreeSixtyDegreeController obj = new ThreeSixtyDegreeController();
 obj.deleteOldReport();
 obj.generateNewReport(accountID);
 System.debug('after  obj.generateNewReport(accountID); '+'accountID: '+ accountID);
 }
   String rptURL ;
   //Environment_variables__c env_list = [select key__c, value__c from environment_variables__C
   //where key__c = 'reportIDFor360Degree'  ];
   //new code
   String env_list = Utilities.getGlobalVariable( 'reportIDFor360Degree' );
   //new code end
   rptURL = '//' + ApexPages.currentPage().getHeaders().get('Host') + '/' + env_list+ '?' +'pv0='+userID.subString(0,15);
   PageReference report = new PageReference(rptURL);
    return report ;
}
public Pagereference back(){
 Pagereference backPage = new Pagereference('/apex/threesixtydegreereport');
    return backPage ;
}

}