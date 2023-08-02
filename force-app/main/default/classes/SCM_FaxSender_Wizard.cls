//
// FaxSenderWizard UI
// 

public class SCM_FaxSender_Wizard {

    private final string ERRMSG_NO_FAX_COVER = 'You must select a cover sheet to send a facsimile.';

    private Integer step;
    private List<String> title;
    private List<String> coverSheetTitle;
    private List<String> documentsTitle;
    private List<SCM_FaxSender_Doc> CachedCovers;
    private List<SCM_FaxSender_Doc> CachedDocs;
    private String CachedCoverSheetSelected;
    private List<String> CachedDocSelected = new List<String>();
    private List<String> CachedDocSorted = new List<String>();
    private String caseNo = '';
    private String product= '';
    private String sfoid = '';
    private String orgid = '';
    private String user = '';
    private string TrackingID = '';

    public String getStep() {
        return String.valueOf(step);
    }
    
    // Constructor
    public SCM_FaxSender_Wizard() {
        //Member initialization
        if (step == null) {
            step = 1;
            //CachedCovers = new List<SCM_FaxSender_Doc>();
            //CachedDocs = new List<SCM_FaxSender_Doc>();
            //CachedDocSelected = new List<Double>();
            //CachedDocSorted = new List<Double>();
            caseNo = '';
            sfoid = '';
            user = '';
            product = 'Case';

            title = new List<String>();
            title.Add('Facsimile Cover Sheet Selector');
            title.Add('Facsimile Document Selector');
            title.Add('Facsimile Document Sequencing');
            title.Add('Facsimile Outline');
            title.Add('');

            coverSheetTitle = new List<String>();
            coverSheetTitle.Add('Available Cover Sheets');
            coverSheetTitle.Add('Selected Cover Sheet');
            coverSheetTitle.Add('Selected Cover Sheet');
            coverSheetTitle.Add('');
            coverSheetTitle.Add('');
            
            documentsTitle = new List<String>();
            documentsTitle.Add('');
            documentsTitle.Add('Available Documents');
            documentsTitle.Add('Selected Documents');
            documentsTitle.Add('Confirmation');
            documentsTitle.Add('');
            
        }

        String aCaseNo = ApexPages.currentPage().getParameters().get('case');
        if (aCaseNo != ''){
            caseNo = aCaseNo;
        }

        String aProduct = ApexPages.currentPage().getParameters().get('prod');
        if (aProduct != ''){
            product = aProduct ;
        }
        
        String asfoid = ApexPages.currentPage().getParameters().get('sfoid');
        if (asfoid != ''){
            sfoid = asfoid;
        }
        
        String aorgid = ApexPages.currentPage().getParameters().get('orgid');
        if (aorgid != ''){
            orgid = aorgid;
        }
        
        String auser = ApexPages.currentPage().getParameters().get('user');
        if (auser != ''){
            user = auser;
        }
          String aTrackingID = ApexPages.currentPage().getParameters().get('TrackingID');
        if (aTrackingID != ''){
            TrackingID = aTrackingID;
         	 
        }
    }

    public PageReference next() {
        step ++;
        if (step > 4) {
            step = 4;
        }
        processForm();
        return null;
    }

    public PageReference previous() {
        step --;
        if (step < 1) {
            step = 1;
        }
        processForm();
        return null;
    }
    
    public PageReference reset() {
        if (step == 1) {
            SCM_FaxSender fs = new SCM_FaxSender();
            CachedCovers = fs.AvailableCoverSheets(caseNo, product, sfoid);
            CachedCoverSheetSelected = null;
            CachedDocs = null;
            HiddenAction = '';
        }
        if (step == 2) {
            SCM_FaxSender fs = new SCM_FaxSender();
            CachedDocs = fs.AvailableDocuments(sfoid, CachedCovers);
            CachedDocs = SCM_FaxSender.ClearSelectedDocuments(CachedDocs);
            showMessage(fs.UserMessage());
            processForm();
        }
        if (step == 3) {
            CachedDocSorted = SCM_FaxSender.SelectedDocuments(CachedDocs);
            processForm();
        }

        return null;
    }

    public PageReference sendFax() {
        //TODO: Implement fax sending stuff
        
        if(SendTheFax()) {
            step = 5;
        }
        else {
            step = 4;
        }

        return null;
    }

    private Boolean SendTheFax() {
        SCM_FaxSender_WebService fsws = new SCM_FaxSender_WebService();

        SCM_FaxSender fs = new SCM_FaxSender();
        
        Boolean sendOK = fs.SendFax(CachedDocSorted, CachedCoverSheetSelected, sfoid, user, caseNo,TrackingID);
        
        if (fs.UserMessage() != '')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, fs.UserMessage()));
        }
        
        return sendOK;
    }

    public PageReference moveUp() {
        if (HiddenValue != null)
        {
            Integer docLoc = SCM_FaxSender.Searcher(CachedDocSorted, HiddenValue);
            CachedDocSorted = SCM_FaxSender.MoveUp(CachedDocSorted, docLoc);
        }
        
        return null;
    }

    public PageReference moveDown() {
        if (HiddenValue != null)
        {
            Integer docLoc = SCM_FaxSender.Searcher(CachedDocSorted, HiddenValue);
            CachedDocSorted = SCM_FaxSender.MoveDown (CachedDocSorted, docLoc);
        }
        
        return null;
    }

    public String getTitle() {
        return title[step - 1];
    }

    public String getCoverSheetTitle() {
    	return coverSheetTitle[step - 1];
    }
    
    public String getDocumentsTitle() {
        return documentsTitle[step - 1];
    }
    
    public String getCoverSheetIndex() {
        
        Integer coverIndex = 0;
        if (CachedCovers != null) {
            coverIndex = SCM_FaxSender.Searcher(CachedCovers, CachedCoverSheetSelected);
        }

        return String.valueOf(coverIndex);
    }

    public String HiddenAction { get; set; }
    public String HiddenValue { get; set; }

    private void showMessage(String message, ApexPages.severity severityType){
        if (message != '')
        {
            ApexPages.addmessage(new ApexPages.message(severityType, message));
            
            if(severityType == ApexPages.severity.Warning)
            {
                SCM_LogError.sendEmail('Genentech warning message', message, true);
            }
        }
    }

    private void showMessage(String message){
        showMessage(message, ApexPages.severity.INFO);
    }

    public void processForm()
    {
    	
        //User Actions
        if(HiddenAction == 'SelectedCover'){
            try {
                CachedCoverSheetSelected = HiddenValue;

            }
            catch (Exception ex) {
                step = 1;
            }
        }
        
        //Post processing
        // If no cover sheet selected point user to the cover sheet selection page
        if (CachedCoverSheetSelected == null) {
            step = 1;
            showMessage(ERRMSG_NO_FAX_COVER);
        }
        
        if(step > 1) {
            SCM_FaxSender fs = new SCM_FaxSender();

            // Cache cover sheets
            if (CachedCovers == null) {
               CachedCovers = fs.AvailableCoverSheets(caseNo, product, sfoid);
            }
    
            // Get all other documents
            if (CachedDocs == null && CachedCovers != null && step != 1) {
               CachedDocs = fs.AvailableDocuments(sfoid, CachedCovers);
               step = 2;
            }

            showMessage(fs.UserMessage(), ApexPages.severity.Warning);
        }
        LogStep(TrackingID,string.ValueOf(Step),datetime.now());
    }

    public List<SCM_FaxSender_Doc> getCoverSheet() {    
        List<SCM_FaxSender_Doc> cover = new List<SCM_FaxSender_Doc>();
        SCM_FaxSender fs = new SCM_FaxSender();

        if (CachedCoverSheetSelected != null && step != 1) {
            List<String > tmpDocList = new List<String >();
            tmpDocList.Add(CachedCoverSheetSelected);
            cover = SCM_FaxSender.Sorter(CachedCovers, tmpDocList);
        }
        else {
            // Cache cover sheets
            if (CachedCovers == null && step == 1) {
               CachedCovers = fs.AvailableCoverSheets(caseNo, product, sfoid);
            }

            cover = CachedCovers;
        }

        if(cover == null){
            cover = new List<SCM_FaxSender_Doc>();
        }
		
        showMessage(fs.UserMessage(), ApexPages.severity.Warning);
		
        return cover;
    }
    
    @future
    public static void LogStep(string TrackingID,string CurrentStep,DateTime CurrentTime){
    	
    	if (SCM_Security.getEnvironmentVariable('SCM_Enable_FaxWizard_Log') == 'True'){
    		SCM_Fax_Wizard_Log__c log = new SCM_Fax_Wizard_Log__c();
    		log.TrackingID__c = TrackingID;
    		log.CurrentStep__c = CurrentStep;
    		log.ExecutedOn__c = CurrentTime;
    		
    		insert log;
    	}
    	
    	 
    }
    
    public static void LogStepsync(string TrackingID,string CurrentStep,DateTime CurrentTime){
    	
    	if (SCM_Security.getEnvironmentVariable('SCM_Enable_FaxWizard_Log') == 'True'){
    		SCM_Fax_Wizard_Log__c log = new SCM_Fax_Wizard_Log__c();
    		log.TrackingID__c = TrackingID;
    		log.CurrentStep__c = CurrentStep;
    		log.ExecutedOn__c = CurrentTime;
    		
    		insert log;
    	}
    	
    	 
    }
    

    public List<SCM_FaxSender_Doc> getDocuments() {
        List<SCM_FaxSender_Doc> Docs;
        
        if(step != 1) {
            SCM_FaxSender fs = new SCM_FaxSender();
            
            //***********************************
            //* Cache data
            //***********************************
    
            // Cache cover sheets
            if (CachedCovers == null) {
               CachedCovers = fs.AvailableCoverSheets(caseNo, product, sfoid);
            }
    
            // Get all other documents
            if (CachedDocs == null && CachedCovers != null && step != 1) {
                try
                {
                    CachedDocs = fs.AvailableDocuments(sfoid, CachedCovers);
                }
                catch (Exception ex)
                {
                    CachedDocs = new List<SCM_FaxSender_Doc>();
                }
            }
    
            // Determin which data to display
            if(step == 1) {
                Docs = new List<SCM_FaxSender_Doc>();
            }
    
            if(step == 2) {
                Docs = CachedDocs;
                CachedDocSorted = new List<String >();
            }
    
            if(step == 3) {
                //Docs = null; string x = Docs[0].Id; //Throw unhandled exception
                
                try
                {
                if (CachedDocSorted.size() == 0) {
                    CachedDocSorted = SCM_FaxSender.SelectedDocuments(CachedDocs);
                }
    
                Docs = SCM_FaxSender.Sorter(CachedDocs, CachedDocSorted);

                }
                catch(Exception ex)
                {
                    Docs = new List<SCM_FaxSender_Doc>();
                }

                //for (SCM_FaxSender_Doc doc : Docs )
                //{
                //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, doc.Id + ' ' + doc.Name + ' Modified ' + doc.UpdatedDate + ' File Size ' + doc.FileSize ));
                //}
            }
    
            if(step == 4) {
                try
                {
                    Docs = SCM_FaxSender.CompleteFax(CachedCovers, CachedDocs, CachedCoverSheetSelected, CachedDocSorted);
                }
                catch(Exception ex)
                {
                    Docs = new List<SCM_FaxSender_Doc>();
                }
            }

            showMessage(fs.UserMessage(), ApexPages.severity.Warning);
        }

        if(Docs == null){
            Docs = new List<SCM_FaxSender_Doc>();
        }
                
        return Docs;
    }
    
    public boolean getShowRadioButton() {
        if(step == 1) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowCheckbox() {
        if(step == 2) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowSequencingButtons() {
        if(step == 3) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowFaxCovers() {
        if(step == 1 || step == 2 || step == 3) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowDocuments() {
        if(step == 2 || step == 3 || step == 4) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowWizard() {
        if(step != 5) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowConfirmation() {
        if(step == 5) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowPreviousButton() {
        if(step == 2 || step == 3 || step == 4) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowNextButton() {
        if(step == 1 || step == 2 || step == 3) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowResetButton() {
        if(step == 1 || step == 2 || step == 3) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public boolean getShowSendFaxButton() {
        if(step == 4) {
            return true;
        }
        else {
            return false;
        }
    }

    public boolean getShowCancelButton() {
        if(step != 5) {
            return true;
        }
        else {
            return false;
        }
    }
    
    public String getFormType() {
        if (product != null)
        {
            if(product.startsWith('Hotline')) {
                return 'Hotline';
            }
            else {
                return 'Case';
            }
        }
        else {
            return 'Case';
        }
    }
}