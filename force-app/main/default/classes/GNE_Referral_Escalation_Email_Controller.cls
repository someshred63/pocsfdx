/*
* Class: GNE_Referral_Escalation_Email_Controller
* Author: Saama
* Date:   5 Sep 2011
* Description: This class is run to fetch all the Assigned Referrals to send escalation emails
* Requirement gMARS Phase 2 dev
*     -Revision-
      version 1.1 : Release: 1
*/
public class GNE_Referral_Escalation_Email_Controller {

    public String strReferralAssignmentID;
    //public String strReferralAssignmentNAME{get;set;}
    
    public String strReferralLink{get;set;}
    public String strReferralAssignmentPriority;
    public String showOnlyLink;
    public String showReferralLinkLabel{get;set;}
    public String showReferralLink{get;set;}
    public integer iReferralAssignmentDays{get;set;}
    public integer strReferralAssignmentDays{get;set;}
    public String strReferral{get;set;}
    public String strReferralStatusDate;
    public String strReferralStatusDate1{get;set;}
    public String strSpace{get;set;}
    public Referral_Assignment_gne__c referralAssignmentObj;
    public Datetime raAssignedDate;
    public static final String strGMTFormat = 'yyyy-MM-dd';
    public static final String strPST = 'PST';
    
    
    public GNE_Referral_Escalation_Email_Controller () { 
        System.debug('##### inside the controller constructor');
        strSpace = ' ';
        showReferralLink = '';
        showReferralLinkLabel = '';        
       
    }  

    /*public  getNumberOfDays()
    {
        
    }*/
    
    public void setshowOnlyLink (String s) {
        showOnlyLink = s;
        System.debug('##### showOnlyLink: ' + showOnlyLink);
        if(showOnlyLink!=null && showOnlyLink=='true')
        {
            showReferralLink=System.Label.GNE_Referral_Guide_Link;
            showReferralLinkLabel = 'online training guide';
        }
        else{
            showReferralLink = '';
            showReferralLinkLabel = '';
        }
        //strReferralAssignmentDays=' '+(String)iReferralAssignmentDays+' ';
    }
    public String getshowOnlyLink() {
        if(showReferralLink != '')
            return showReferralLink;
        else
            return '';
    }
    
    
    public String controllerValue;
    public void setstrReferralAssignmentPriority (String s) {
        strReferralAssignmentPriority = s;
        if(strReferralAssignmentPriority!=null)
        {
            iReferralAssignmentDays=GNE_Referral_Utils.getIntAddDay(strReferralAssignmentPriority);
        }
        //strReferralAssignmentDays=' '+(String)iReferralAssignmentDays+' ';
    }
    public integer getstrReferralAssignmentPriority() {
        return iReferralAssignmentDays;
    }
    
    public void setstrReferralAssignmentID (String s) {
        strReferralAssignmentID = s;
        if(strReferralAssignmentID!=null)
        {
            strReferralLink=' '+GNE_Referral_Utils.serverURL + '/' + strReferralAssignmentID+' ';
        }
    }
    public string getstrReferralAssignmentID() {
        return strReferralLink;
    }
    
    public void setstrReferralStatusDate (String s) {
        strReferralStatusDate=s;
        /*Datetime dtStatusReferral=GNE_Referral_Utils.getReferralAssignmentStatusDate(s);
         if(dtStatusReferral!=null)
        {
            strReferralStatusDate=dtStatusReferral.format(strGMTFormat,strPST);
        }*/
        //System.debug('##### inside the date method');
        if(strReferralStatusDate!=null)
        strReferralStatusDate1=GNE_Referral_Utils.getReferralAssignmentStatusDate(strReferralStatusDate);
        //strReferralStatusDate1=strReferralStatusDate;
        //strReferralAssignmentID=s;
        //referralAssignmentObj = [select id,Status_Referral_Date_gne__c from Referral_Assignment_gne__c where id=: strReferralStatusDate];
        
        /*if(referralAssignmentObj!=null)
        {
            raAssignedDate=referralAssignmentObj.Status_Referral_Date_gne__c.date();
            strReferralStatusDate=strReferralStatusDate+raAssignedDate.format(strGMTFormat,strPST);
        }*/
        
        
    }
    public string getstrReferralStatusDate() {
        
        return strReferralStatusDate1;
        //return 'test';
    }
    
     /*public void setstrReferralAssignmentNAME (String s) {
        //datetime myDate = datetime.newInstance(d);
        strReferralAssignmentNAME=' '+s+' ';
        //dtReferralStatusDate = myDate.date();
        
    }
    public String getstrReferralAssignmentNAME() {
        return strReferralAssignmentNAME;
    }*/
    
   
    
    
}