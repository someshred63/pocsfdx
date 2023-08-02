/**********************************************
@class Name : SCM_Save_to_Case
@created by : J.Pendergrass
@last Modified by/on : J.Pendergrass 12/30/2008
@last Tested by/on : J.Pendergrass 11/20/2008
**********************************************/
public class scm_save_to_case {
    //Case number to be set
    public string CaseNum {
        get {
            if (ApexPages.currentPage().getParameters().get('casenumber') != '')
            {
                if (CaseNum == '' || CaseNum == null){
                    return ApexPages.currentPage().getParameters().get('casenumber');
                }
            }
            
            return CaseNum; 
        }
        set { CaseNum = value; }
    } 
   
    //Assigned to in lastname, firstname format   
    public string AssignTo {
        get { return AssignTo; }
        set { AssignTo = value; }
    }
    
    public string ParentUrl {
        get { return ParentUrl; }
        set { ParentUrl = value; }
    }
       
    public string DocumentType {
        get { return DocumentType; }
        set { DocumentType = value; }
    } 
    
    public string Domain {
        get { return Domain; }
        set { Domain = value; }
    } 
    
    public string CheckFolder {
        get { 
            PageReference pageRef = ApexPages.currentPage();
            list<string> docs = parseSelection(pageRef.getParameters().get('selection'));
            
            return string.valueof(IsFolder); }
        set { CheckFolder = value; }
    } 

    //Varible to set when we are ready to close the window
    public string CloseWin {
        get { return CloseWin; }
        set { CloseWin= value; }
    }
    
    //Variable to hold the id of the user document is assigned to
    public string AssignToID{
        get { return AssignToID; }
        set { AssignToID= value; }
    }
    
    //sepecify save type
    public string SaveType{
        get { return SaveType; }
        set { SaveType= value; }
    }
    
    public string JobKey{
        get { return JobKey; }
        set { JobKey= value; }
    }
    //sepecify save type

    //Variable to find out if the user selected a folder
    public boolean IsFolder ;
    //Case id
    public string caseID;
    //string of documents for test method
    public string DocumentString;
    //User Key for test method
    public string UserKey;
    //User Email for test method
    public string UserEmail;    
    //user token so the test will authenticate properly
    public string UserToken;
    //check to see if it is a test
    public boolean istest = false;
    //the patient id to be set into 
    public string patientid;
    private list<task> tasks = new list<task>();
    private list<task> faxmettasks = new list<task>();

    //Verify save method 
    public list<SelectOption> getDoctypes() {
        list<SelectOption> values = new list<SelectOption>();
        PageReference pageRef = ApexPages.currentPage();
        string sel = null;
        
        if (this.DocumentString == null) {
            sel = (pageRef.getParameters().get('selection'));
            system.debug('######################' + sel);
        }
        else { //its a test method use test data
            sel = DocumentString;
        }
        
        list<string> docs = parseSelection(sel);

        if (IsFolder == true) {
            //is a folder return error message
            values.add(new SelectOption('IsFolder','IsFolder'));
            ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.FATAL, 'You cannot transfer a folder please close this window and select a document');
            ApexPages.addMessage(myMsg2);
        }
        
        system.debug('doc size = ' + docs.size());
        
        if (docs.size() == 2) {
            if (closewin != 'true') {
                SCM_WebServices.SpringCMServiceSoap SCMsvc2 = new SCM_WebServices.SpringCMServiceSoap();
                string Token;
                string ukey;
                string uemail;

                if (this.UserKey == null) {
                    ukey = pageRef.getParameters().get('userkey');
                }
                else { //testmethod use test data
                    ukey = this.UserKey;
                }
                
                if (this.UserEmail == null) {
                    uemail = pageRef.getParameters().get('uemail');
                }
                else { //testmethod use test data
                    uemail = this.UserEmail;
                }
                
                values.add(new SelectOption('CCP Request','CCP Request'));
                values.add(new SelectOption('Co-Pay Attestation Form','Co-Pay Attestation Form'));
                values.add(new SelectOption('Complete Fax','Complete Fax'));
                values.add(new SelectOption('Confirmation of Infusion','Confirmation of Infusion'));
                values.add(new SelectOption('Demographics','Demographics'));
                values.add(new SelectOption('EAP Form','EAP Form'));
                values.add(new SelectOption('Escalated Request Form','Escalated Request Form'));
                values.add(new SelectOption('Fax Cover','Fax Cover'));
                values.add(new SelectOption('Financial Attestation Form','Financial Attestation Form'));
                values.add(new SelectOption('Financial Documents','Financial Documents'));
                values.add(new SelectOption('Insurance Attestation Form','Insurance Attestation Form'));
                values.add(new SelectOption('Insurance Card','Insurance Card'));
                values.add(new SelectOption('Insurance Documents','Insurance Documents'));
                values.add(new SelectOption('Medical Documents','Medical Documents'));
                values.add(new SelectOption('PAN Form','PAN Form'));
                values.add(new SelectOption('Power of Attorney Form','Power of Attorney Form'));
                values.add(new SelectOption('Prescription or Serialized Prescription','Prescription or Serialized Prescription'));
                values.add(new SelectOption('Reverification Request','Reverification Request'));
                values.add(new SelectOption('Shipment Address','Shipment Address'));
                values.add(new SelectOption('Shipment Documents','Shipment Documents'));
                values.add(new SelectOption('SMN|Enrollment|Prescription Form','SMN|Enrollment|Prescription Form'));

    
                return values;          
            }    
        }   
        else {
            values.add(new SelectOption('no display','no display'));
        }
        
        values.add(new SelectOption('no display','no display'));
        
        return values;
    }

    public PageReference save() {
        system.debug(this.SaveType);
        list<Case> mycas = [select Casenumber,id,Patient_gne__r.Patient_ID_gne__c from Case where Casenumber = :this.CaseNum];
        
        //check to see if case exists
        if (mycas.size() == 0){
            // not found dispaly error message
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You have not entered a valid case number');
            ApexPages.addMessage(myMsg);
            return null;
        }
        else {
            caseid = mycas[0].id;
            patientid = mycas[0].Patient_gne__r.Patient_ID_gne__c; 
            system.debug('patientid=' + patientid);
            string FirstName;
            string LastName;
            
            try {
                if (this.SaveType == 'save') {
                    List<User> usr;
                    usr = [Select id, LastName, FirstName, Email From User where id = :assigntoid];
                    //check to see if user exists
                    if (usr.size() == 0){
                        //user does not exist set error message
                        ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.FATAL, 'You have not entered a valid user in the Assign to field' );
                        ApexPages.addMessage(myMsg2);
                        return null;
                    }  
                    //information is valid continue with save
                    else
                    {
                        //get the users id
                        AssignToID = usr[0].id;
                
                        //both fields are verified calling dosave to do actuall save
                        return dosave();
                    }
                }
                else {
                   return  dosave();
                }
            }
            catch(dmlexception ex) {
                //user does not exist
                ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.FATAL, 'You have not entered a user in the Assign to field');
                ApexPages.addMessage(myMsg2);
                return null;
            }
        }
    }

    private list<string> parseSelection(string selection) {
        list<string> docs = new list<string>();
        //check to see if user selected a folder
        if (selection.indexof('Folder') > -1 ) {
        
            IsFolder = true;
            //retun empty array
            return docs;
        }
        else {
            IsFolder = false;
            //Parse the document ids from the query string
            docs = selection.split(';',-2);
            //remove object type from string
            integer i;
            for (i =0; i < docs.size(); i++) {
                docs[i] = docs[i].replace('Document,','');
                //if (docs[i] == '') {
                //string blnk = docs.remove(i);
                //}
            }
            return docs;
        }
    }

    private PageReference dosave() {
        SCM_FaxSender_WebService.FaxSenderSoap fsws = new SCM_FaxSender_WebService.FaxSenderSoap();
        SCM_FaxSender_WebService.WebServiceCallInfo ws = new SCM_FaxSender_WebService.WebServiceCallInfo();
        PageReference pageRef = ApexPages.currentPage();
        ws.caseid = caseid; 
        ws.casenumber = casenum;
        fsws.Parameters.put('casenumber',ws.casenumber);
        ws.cmtask = scm_security.getEnvironmentVariable('cm task');
        fsws.Parameters.put('cmtask',ws.cmtask);
        ws.fromuserid = userinfo.getUserId();
        fsws.Parameters.put('fromuserid',ws.fromuserid);
        case mycase = [Select id,Product_gne__c From Case where casenumber = :Casenum limit 1];
        ws.patientid = patientid;
        fsws.Parameters.put('patientid',ws.patientid);
        ws.product = mycase.Product_gne__c;
        fsws.Parameters.put('product',ws.product);
        ws.selection = pageRef.getParameters().get('selection');
        fsws.Parameters.put('selection',ws.selection);
        ws.sessionid = userinfo.getSessionId();
        fsws.Parameters.put('sessionid',ws.sessionid);
        ws.touserid = assigntoid;
        fsws.Parameters.put('touserid',ws.touserid);
        ws.type_x = SaveType;
        fsws.Parameters.put('type_x',ws.type_x);
        ws.userEamil= pageRef.getParameters().get('uemail');
        fsws.Parameters.put('userEamil',ws.userEamil);
        ws.userkey = pageRef.getParameters().get('userkey');
        fsws.Parameters.put('userkey',ws.userkey);
        ws.usersname = userinfo.getName();
        fsws.Parameters.put('usersname',ws.usersname);
        ws.token = pageRef.getParameters().get('token');
        fsws.Parameters.put('token',ws.token);
        ws.Orgid = userinfo.getOrganizationId();
        fsws.Parameters.put('Orgid',ws.Orgid);
         
        if (DocumentType != 'no display') {
            ws.SaveFileTypemetadata = DocumentType;
            fsws.Parameters.put('SaveFileTypemetadata',ws.SaveFileTypemetadata); 
        }
        
        if (istest == false) {
            jobkey = fsws.CreateWebserviceJob(ws);
            SCM_WSLogger.InsertLog(fsws.log.MethodName__c,fsws.log.Parameters__c);
        }
        
        string sv = '';
        
        if (savetype == 'save') {
            sv = '&issave=true';
        }
             
        string up = '&isupload=false';
        
        if (pageRef.getParameters().get('token') != '' && pageRef.getParameters().get('token') != null){
            up='&isupload=true';  
        }
        
        string loc = SCM_Security.getEnvironmentVariable('SCM_URL');
        loc = loc.replace('FaxSender.asmx','');
        PageReference newpage = new PageReference(loc + 'savetocasepoll.aspx?jobkey='+ jobkey + '&dom=' + Domain + sv + up + '&redirurl=' + ParentUrl + '&savetype=' + SaveType);
        newpage.setRedirect(true);
   
        return newpage;
    }
}