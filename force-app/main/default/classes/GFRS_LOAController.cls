/** 
* @Author ADMD Team
* @date 06/02/2014
* @description GFRS_LOAController class - controler class for GFRS_LOA
*/
public with sharing class GFRS_LOAController {
    /** The type of page this is **/
    public static final String CONTENT_TYPE = 'LOA';
    
    /** Page to display PODF version of LOA **/
    public static final String PDF_PAGE = '/apex/GFRS_LOA_PDF';
    public static final String PATH_LOA = '/apex/GFRS_LOA';
    /** Page to move to when moving 'back' **/
    public static final String PATH_HOME = '/apex/gFRS_Home';
    
    /** GET variable that defines the step in the LOA signature process **/
    public static final String PARAM_STEP = 'step';
    
    public static final String IMED_SIGNATURE_URL = 'images/IMED_Signature.png';
    public static final String EOP_SIGNATURE_URL = 'images/JGalperin_signature.png';
    public static final String CM_SIGNATURE_URL = 'images/JGalperin_signature.png';
    public static final String PHILANTHROPIC_SIGNATURE_URL = 'images/KReed_signature.png';
    public static final String HC_SIGNATURE_URL = 'images/KReed_signature.png';
    public static final String SCIENTIFIC_SIGNATURE_URL = 'images/KReed_signature.png';
    public static final String FELLOWSHIPS_SIGNATURE_URL = 'images/KReed_signature.png';
    public static final String FOUNDATION_SIGNATURE_URL ='images/LKaran_signature.png';
    
    public static final Map<Boolean, Map<String, String>> APPROVER_NAMES = new  Map<Boolean, Map<String, String>>{
        false => new Map<String, String>{
            gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME => Label.gFRS_LOASciPipelineApproverName,
            gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME => Label.gFRS_LOAScientificProjectApproverName,
            gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME => Label.gFRS_LOAFoundationApproverName,
            gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME => Label.gFRS_LOAExhibitsApproverName,
            gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME => Label.gFRS_LOACorporateApproverName,
            gFRS_Util.TYPE_PHILANTHROPIC_NAME => Label.gFRS_LOAPhilanthropicApproverName,
            gFRS_Util.TYPE_FELLOWSHIPS_NAME => Label.gFRS_LOAFellowshipsApproverName,
            gFRS_Util.TYPE_HC_CHAR_NAME => Label.gFRS_LOAHCCharApproverName,
            gFRS_Util.TYPE_IMED_NAME => Label.gFRS_LOAIMEDApproverName
        },
        true => new Map<String, String>{
            gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME => Label.gFRS_LOASciPipelineApproverName,
            gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME => Label.gFRS_LOAScientificProjectApproverName,
            gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME => Label.gFRS_LOAFoundationApproverName,
            gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME => Label.gFRS_LOAExhibitsApproverName,
            gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME => Label.gFRS_LOACorporateApproverName,
            gFRS_Util.TYPE_PHILANTHROPIC_NAME => Label.gFRS_LOAFoundationApproverName,
            gFRS_Util.TYPE_FELLOWSHIPS_NAME => Label.gFRS_LOAFoundationApproverName,
            gFRS_Util.TYPE_HC_CHAR_NAME => Label.gFRS_LOAFoundationApproverName,
            gFRS_Util.TYPE_IMED_NAME => Label.gFRS_LOAIMEDApproverName
        }
    };
    
    public static final String RELEASE_FAILED = 'SAP Release for Payment Failed';
    
    /** List of parameters **/
    public Map<String,String> pageParams;
                    
    /** List of translations **/
    public Map<String,String> contentItems { get; set; }
    
    /** Funding request context **/
    public GFRS_Funding_Request__c fundReq {get; set;}
    public GFRS_Program__c program {get; set;}
    public Attachment LoaDocument{get;set;}
    public String programName {get; set;}
    public String programStartDate {get; set;}
    public String programEndDate {get; set;}
    public String loaSignedDatePST {get; set;}
    public String pin {get; set;}
    public String signerName {get; set;}
    public String recordType {get; set;}
    public Boolean isScrollDown { get; set; }
    public Boolean isSigned {get; set;}
    public Boolean isAllowedToSign {get; set;}
    public String signatureUrl {get; set;}
    public List<programHelper> hcProgList{get;set;}
    
    /** current step within the LOA process **/
    public Integer pageStep;
    
    /** Whether the Pin is required **/
    public Boolean isPinRequired { get; set; }
    
    public Boolean isCMEOShown { get { return( gFRS_Util.isCMEOShown( this.fundReq )); }}
    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description GFRS_LOAController - class constructor
    */
    public GFRS_LOAController( ApexPages.StandardController std ){
        this.isScrollDown=false;
        PageReference pageRef= ApexPages.currentPage();
        
        String checkIfScrollDown=pageRef.getParameters().get('isSrollDown');
        if(checkIfScrollDown!=null && checkIfScrollDown=='true'){
            this.isScrollDown=true;
        }
        
        this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( CONTENT_TYPE, UserInfo.getLanguage() );
        
        this.fundReq = (GFRS_Funding_Request__c)std.getRecord();
        
        pageParams = ApexPages.currentPage().getParameters();
        
        this.pageStep = 1;
        if( pageParams.containsKey( PARAM_STEP ) ){
            try {
                this.pageStep = Integer.valueOf( pageParams.get( PARAM_STEP ));
            } catch ( Exception err ){
                System.debug( 'leave pageStep as default:' + err.getMessage() );
            }
        } else {
            //System.debug( 'no pageStep sent, so leave as default' );
        }
        
        System.debug( 'pageStep:' + pageStep );
        
        if( this.fundReq == null || this.fundReq.id == null ){
            ApexPages.addMessages( new CustomException( 'Funding request was not sent' ));
            return;
        }
        
        try {
            this.fundReq = [ select Id, Name, Foundation_Classified__c, LOA_Signer_Name__c, Organization__r.Name, Organization__r.Organization_Name__c, Organization__r.Authorized_Signer_Name__c, Used_this_year__c , Location__r.City__c, Location__r.State__c, Location__r.Address__c, Location__r.Zip__c, Authorized_Signer__r.Name, Signing_Authority_First_Name__c, Signing_Authority_Last_Name__c, Authorized_Signer__r.Security_PIN__c, LOA_Signed__c, Record_Type_Name__c, Benefits_Exchanged_for_Funding__c,  Event_Program_Title__c, Approved_Amount__c, IP_Address__c, LOA_Signed_Date__c,Status__c, Therapeutic_Area__c, Support_Purpose_Program_Description__c,Exhibits_or_Displays_Allowed__c, Location__r.Name, Location__r.Address_Line_1__c,  Location__r.Address_Line_2__c,   Location__r.Country_1__c, CreatedBy.Title, CreatedBy.FirstName, CreatedBy.LastName, CreatedBy.Email, CreatedBy.Phone, gCOI_Pending_Actions__c,Program_Start_Date_Min__c,Decision_Date__c,Organization_Name__c,LOA_PDF__c,Funding_Sub_Type__c   from GFRS_Funding_Request__c where id = :this.fundReq.id limit 1];
            
            system.debug(this.fundReq);
            this.recordType = this.fundReq.Record_Type_Name__c;
            program = [ select Name, Start_Date__c, End_Date__c from GFRS_Program__c where Funding_Request__c = :this.fundReq.id order by Start_Date__c asc limit 1];
            programName = this.program.Name;
            
            programStartDate = this.program.Start_Date__c != null ? this.program.Start_Date__c.format() : null;
            programEndDate = this.program.End_Date__c != null ? this.program.End_Date__c.format() : null;
            loaSignedDatePST = this.fundReq.LOA_Signed_Date__c != null ? this.fundReq.LOA_Signed_Date__c.format(System.Label.gFRS_PST_Date_Pattern, System.Label.gFRS_PST_Signature) : null; // conversion to PST time zone -  GFRS-14
            
            if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME || this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME ){
                this.hcProgList=assingProgramHelerList();
            }
            
            isSigned = fundReq.LOA_Signed__c == 'Yes' || pageParams.get('isSigned') == '1';
            
            try {
                final Boolean isFoundationClassified = fundReq.Foundation_Classified__c == 'TRUE';
                final String approverName = APPROVER_NAMES.get(isFoundationClassified).get(fundReq.Record_Type_Name__c);
                if (String.isNotBlank(approverName)) {
                    final String serverUrl = gFRS_Util.getCustomSettingStringValue('Server_URL');
                    signatureUrl = String.format('{0}/servlet/servlet.ImageServer?id={1}&oid={2}', new String[]{
                        String.isBlank(serverUrl) ? System.Label.GFRS_Server_URL : serverUrl.trim(), [
                            SELECT Id FROM Document WHERE Name = :approverName
                            AND Folder.DeveloperName = 'gFRS_Signatures' LIMIT 1
                        ].Id, [
                            SELECT Id FROM Organization LIMIT 1
                        ].Id
                    });
                }
            } catch (QueryException e) {
                if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){
                    signatureUrl = IMED_SIGNATURE_URL;
                } else if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME){
                    signatureUrl = EOP_SIGNATURE_URL;
                }else if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME){
                    signatureUrl = EOP_SIGNATURE_URL;
                } else if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME){
                    signatureUrl = CM_SIGNATURE_URL;
                } else if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME && this.fundReq.Foundation_Classified__c == 'FALSE'){
                    signatureUrl = PHILANTHROPIC_SIGNATURE_URL;
                } else if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME && this.fundReq.Foundation_Classified__c == 'FALSE'){
                    signatureUrl = HC_SIGNATURE_URL;
                } else if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
                    signatureUrl = SCIENTIFIC_SIGNATURE_URL;
                } else if(this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME && this.fundReq.Foundation_Classified__c == 'FALSE'){
                    signatureUrl = FELLOWSHIPS_SIGNATURE_URL;
                } else if(this.fundReq.Foundation_Classified__c == 'TRUE'){
                    signatureUrl = FOUNDATION_SIGNATURE_URL;
                }
            }
        } catch( Exception err ){
            System.debug( 'unable to load organization and funding request info:' + err.getMessage() );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the funding request' ));
            return;
        }
        
        this.isPinRequired = !( this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME );
        this.isAllowedToSign = Userinfo.getUserId() == this.fundReq.Authorized_Signer__c;
        //SFDC-1710 Checking if request have attachment with LOA.
        List<Attachment> tmpAtachmentLi=[select id, Name,body,Parent.id from Attachment where Name='LOADocument.pdf' and Parent.id=:this.fundReq.id];
        if(this.fundReq!=null && tmpAtachmentLi!=null && tmpAtachmentLi.size()>0){
            LoaDocument=tmpAtachmentLi[0];
        }else{
            LoaDocument=null;
        }
    }
    
    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description cancel method - handler method for 'Done' button from UI
    */
    public ApexPages.PageReference cancel(){
        return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_HOME, null, null ) ));
    }
    
    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description approve method - handler method for 'Approve' button from UI
    */
    public ApexPages.PageReference approve(){
        this.isScrollDown=true;
        if(this.validate()){
            try {
                system.debug('Pin ok');
                
                
                
                this.fundReq.LOA_Signer_Name__c = this.signerName;
                this.fundReq.LOA_Signed__c = gFRS_Util.YES;
                this.fundReq.IP_Address__c = ApexPages.CurrentPage().getHeaders().get('x-Salesforce-SIP');
                this.fundReq.LOA_Signed_Date__c = datetime.now();
                this.fundReq.Enter_PIN__c = null;
                
                if(gFRS_Util.isRequestFoundationType(this.fundReq.Id) && this.fundReq.Foundation_Classified__c == 'TRUE'){
                    //Foundation
                    this.fundReq.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_APPROVED;
                    this.fundReq.External_Sub_Status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;
                }else{
                    //Non-Foundation
                    this.fundReq.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_PAYMENT;
                    this.fundReq.External_Sub_Status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;
                }
                
                update this.fundReq;
                
                
                
            } catch( Exception err ){
                System.debug( 'unable to update funding request:' + err.getMessage() );
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ));
                return (null);
            }
            GFRS_Payment_History__c[] payments = [select SAP_Doc_ID__c from GFRS_Payment_History__c where Grant__c =: fundReq.Id];    
            system.debug(payments);
            if(payments.size() > 0){
                PageReference pageRef =  new ApexPages.Pagereference( Page.gFRS_LOA.getURL() + '?id=' + fundReq.Id + '&' + PARAM_STEP + '=2' );
                pageRef.getParameters().put('isSrollDown','true');
                pageRef.setRedirect(true);
                return pageRef;
            }
            PageReference pageRefToReturn = new ApexPages.PageReference( Page.gFRS_LOA.getURL() + '?id=' + fundReq.Id );
            pageRefToReturn.getParameters().put('isSrollDown','true');
            pageRefToReturn.getParameters().put(PARAM_STEP,'3');
            return pageRefToReturn.setRedirect(true );
            //return( new ApexPages.PageReference( Page.gFRS_LOA.getURL() + '?id=' + fundReq.Id+'?=' +true ).setRedirect(true ) );
        }
         
        system.debug('Pin not ok');
        return (null);
    }
    

    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description checkPageStep method - Method that checks if the LOA should proceed to step 2
    * @postcondition: if the fundReq.LOA_Signed__c = true, then the webservice is called
    * @postcondition: if the fundReq.LOA_Signed__c != true, then nothing happens
    */
    public  ApexPages.PageReference checkPageStep(){
        //-- assume that the controller has already run
        
        System.debug( 'pageStep in check:' + this.pageStep );
        
        if( this.pageStep == 2 &&
            ( Userinfo.getUserId() == this.fundReq.Authorized_Signer__c || gFRS_Util.isSystemAdministrator( UserInfo.getUserId() ) ) &&
            this.fundReq.LOA_Signed__c == gFRS_Util.YES
        ){
            return( this.approveStep2() );
        } else if(this.pageStep == 3){
            
            PageReference pageRefPdf =  new ApexPages.Pagereference( Page.gFRS_LOA_PDF.getURL());
            pageRefPdf.getParameters().put('id',fundReq.id);
            pageRefPdf.setRedirect(true);
            createLoaAttachment(pageRefPdf);

        }
        return( null );
    }


    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description approveStep2 method - method used to manage approval step 2
    */
    public  ApexPages.PageReference approveStep2(){
        System.debug( 'attempting step 2' );
        
        //-- get the last payment history available
        GFRS_Payment_History__c[] payments = [select SAP_Doc_ID__c, CreatedDate,Date__c from GFRS_Payment_History__c where Grant__c =: fundReq.Id and Payment_Type__c = 'Payment' and SAP_Doc_ID__c != null order by lastModifiedDate desc limit 1 ];
        gFRS_ReleaseInvoiceBlockWS.GneCOMM_Grants_SFDC_O_1Port0 sapReleaseInvoice = new gFRS_ReleaseInvoiceBlockWS.GneCOMM_Grants_SFDC_O_1Port0();
        sapReleaseInvoice.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
        
        if( payments != null && payments.size() > 0 ){
            gFRS_Payment_History__c p = payments[0];
            
            Date current = date.today();
            String fiscalYear = p != null ? String.valueOf( p.Date__c.year() ):null;
            try{
                gFRS_ReleaseInvoiceBlockSAP.releaseInvoiceBlockResponse_element response =  sapReleaseInvoice.releaseInvoiceBlock(p.SAP_Doc_ID__c, fiscalYear);                        
                system.debug(response);
                if( response.status != 'successful'){
                    System.debug( 'message was sent' );
                    gFRS_XmlErrorMessageReader errorReader = new gFRS_XmlErrorMessageReader();
    
                    XmlStreamReader reader = new XmlStreamReader(gFRS_Util.prepareXmlMessageToParse(response.message));
                    gFRS_XmlErrorMessageReader.Error[] errors = errorReader.parseErrors(reader);
                    for(gFRS_XmlErrorMessageReader.Error error : errors){
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, error.getMessage() ));
                    }
                    
                    releaseFailed();
                    
                    return null;
                }
            } catch (Exception e){
                String errMsg = gFRS_Util.getPrettyMessage(e);
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ) );
                
                releaseFailed();
                
                return (null);
            }
        }
        Pagereference pageRef=new ApexPages.PageReference( Page.gFRS_LOA.getURL() + '?id=' + fundReq.Id).setRedirect(true );
        pageRef.getParameters().put('isSrollDown','true');
        pageRef.getParameters().put(PARAM_STEP,'3');
        return pageRef;
    }
    
    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description releaseFailed method - method used to update FUnding Request after release fail.
    */
    public void releaseFailed(){
        //-- we no longer disable the request from being signed, so we add it to the list of gcoi actions
        
        gFRS_Funding_Request__c req = new gFRS_Funding_Request__c( id = this.fundReq.id );
        req.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, RELEASE_FAILED );
        
        update req;
    }


    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description back method - method returns 'Back' URL
    */
    public ApexPages.PageReference back(){
        return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_LOA, fundReq, null ) ));
    }

    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description validate method - method validates data while Approve of LOA
    */
    private Boolean validate(){
        Boolean isValid = true;
        system.debug(this.pin);
        system.debug(this.signerName);
        
        if(this.signerName == null || this.signerName==''){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Signer name is required.' ));
            isValid = false;
        }
        
        //System.debug( 'this.pin[' + this.pin + '], this.fundReq.EnterPin[' + this.fundReq.Enter_PIN__c + ']');
        if( !this.isPinRequired ){
            //-- pin is not required so does not need to be tested
        } else if(Userinfo.getUserId() != this.fundReq.Authorized_Signer__c){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You are not the authorized signer for this grant' ));
            isValid = false;
        } else if(this.pin == null || this.pin == ''){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'PIN is required.' ));
            isValid = false;
        } else if( this.pin != gFRS_Util_NoShare.getUserPIN(this.fundReq.Authorized_Signer__c)){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Invalid PIN.' ));
            isValid = false;
        }
        
        return isValid;
    }
    

    public String approvalMessage { get { 
        String contentName = fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME ? 'LOAImedText' : 'LOACommonText';
        if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME && fundReq.Funding_Sub_Type__c == gFRS_Util.Sub_Type_Exhibit_Booth){
            contentName='LOAExhibitBoothText';
        }
        
        String contentMsg = gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get(contentName));        

        if(fundReq.Record_Type_Name__c != gFRS_Util.TYPE_IMED_NAME){
            contentMsg = gFRS_Util.replaceContentVariable('__TYPE__', this.getTypeForLetter(String.valueOf(fundReq.Record_Type_Name__c)), contentMsg);
        }

        return contentMsg;
    }}
    
    public String introductionMessage { get { 
        String contentName = fundReq.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME ? 'LOAImedIntroduction' : 'LOACommonIntroduction';
        
        if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME && fundReq.Funding_Sub_Type__c == gFRS_Util.Sub_Type_Exhibit_Booth){
            contentName='LOACExhibitBoothCommonIntroduction';
        }else  if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME && fundReq.Funding_Sub_Type__c == gFRS_Util.Sub_Type_Sponsorship){
            contentName='ExhibitPromosPromSponsorshipIntroduction';
        }else if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME && fundReq.Funding_Sub_Type__c == gFRS_Util.Sub_Type_Exhibit_Booth){
            contentName='ScientificPipelineExhibitBoothIntroduction';
        }else  if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME && fundReq.Funding_Sub_Type__c == gFRS_Util.Sub_Type_Sponsorship){
            contentName='ScientificPipelineSponsorshipIntroduction';
        }else if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME){
            contentName='FellowshipsIntroduction';
        }else if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME){
            contentName='HcCharIntroduction';
        }else if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME){
            contentName='PhilanthropicIntroduction';
        }else if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
            contentName='ScientificProjectIntroduction';
        }else if(fundReq.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME){
            contentName='CorporateMembershipsIntroduction';
        }
        
       
        
        String contentMsg = gFRS_Util.replaceContentVariable('__RECIPIENT__', String.valueOf(this.fundReq.Organization__r.Organization_Name__c), this.contentItems.get(contentName));

        if(fundReq.Record_Type_Name__c != gFRS_Util.TYPE_IMED_NAME){
            contentMsg = gFRS_Util.replaceContentVariable('__TYPE__', this.getTypeForLetter(String.valueOf(fundReq.Record_Type_Name__c)), contentMsg);
        }
        
        return contentMsg;      
    }}
    
    public String commonText2 { get{ return( this.contentItems.get('LOACommonText2')); }}
    public String endingMessage { get { return( this.contentItems.get('LOACommonEnding')); }}
    
    public String statementMessage { get {return( gFRS_Util.replaceContentVariable('__RECIPIENT__', String.valueOf(this.fundReq.Organization__r.Organization_Name__c), this.contentItems.get('Statement')));}}
    
    public String reviewMessage { get { return( this.contentItems.get('Review')); }}
    
    public String charitableMessage { get { return( this.contentItems.get('LOACharitable')); }}
    public String otherPromotionsMessage { get { return( this.contentItems.get('LOAOtherPromotional')); }}
    public String fellowshipMessage { get { return( this.contentItems.get('LOAFellowship')); }}
    public String corporateMembershipMessage { get { return( this.contentItems.get('LOACorporateMembership')); }}
    public String corporateMembershipEOMessage { get { return( this.contentItems.get('LOACorporateMembershipEO')); }}
    public String scientificProjectMessage { get { return( this.contentItems.get('LOAScientificProject')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 10/07/2013
    * @description Property which returning content for LOA for Exhibit and Other Promoe(user choose on deciision page Exhibit Booth). 
    */
    public String exhibitAndOtherPromosExhibitBooth { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('ExhibitAndOtherPromosExhibitBooth')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 10/07/2013
    * @description Property which returning content for LOA for Exhibit and Other Promoe(user choose on deciision page Promotional Sponsorship). 
    */
    public String exhibitAndOtherPromosPromotionalSponsorship { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('ExhibitAndOtherPromosPromotionalSponsorship')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 12/08/2014
    * @description Property which returning content for LOA for Scientific/Pipeline Exhibits & Non-Promotional(user choose on deciision page Exhibit Booth). 
    */
    public String scientificPipelineExhibitBooth { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('ScientificPipelineExhibitBooth')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 12/08/2014
    * @description Property which returning content for LOA for Scientific/Pipeline Exhibits & Non-Promotional(user choose on deciision page Sponsorship). 
    */
    public String scientificPipelineSponsorship { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('ScientificPipelineSponsorship')); }}
    
     /**
    * @author GFRS Dev Team
    * @date 10/07/2013
    * @description Property which returning content for LOA for Corporate Membership. 
    */
    public String corporateMembershipsLOAContent { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('CorporateMembershipsLOAContent')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 11/07/2013
    * @description Property which returning content for LOA for Corporate Membership (user choose on deciision page Fellowship). 
    */
    public String fellowshipLOAContent { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('FellowshipLOAContent')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 11/07/2013
    * @description Property which returning content for LOA for Corporate Membership (user choose on deciision page HC Char funding type). 
    */
    public String hcCharLOAContent { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('HcCharLOAContent')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 11/07/2013
    * @description Property which returning LOA content for IMED. 
    */
    public String imedLOAContent { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('ImedLOAContent')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 11/07/2013
    * @description Property which returning LOA content for Scientific Project. 
    */
    public String scientificProjectLOAContent { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('ScientificProjectLOAContent')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 11/07/2013
    * @description Property which returning LOA content for Philanthropic. 
    */
    public String philanthropicLOAContent { get { return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('PhilanthropicLOAContent')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 12/03/2014
    * @description PProperty which returning LOA content for Foundation with Approved Ammount > 25 000. 
    */
    public String foundationLoaContentOver25k { get { 
            String properContent=this.contentItems.get('FoundationLoaContentOver25k');
            properContent= properContent.replace('__REQUESTPAYMENT__',getApprovedAmount());
            properContent= properContent.replace('__Organization_Name__',fundReq.Organization__r.Organization_Name__c);
            properContent= properContent.replace('__Event_Program_Name__',fundReq.Event_Program_Title__c == null?'':fundReq.Event_Program_Title__c);
            properContent= properContent.replace('__Request_ID__',fundReq.name);
            return properContent;
            //return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('FoundationLoaContentOver25k')); 
        }
    }
    
    /**
    * @author GFRS Dev Team
    * @date 12/03/2014
    * @description Property which returning LOA content for Foundation with Approved Ammount < 25 000 . 
    */
    public String foundationLoaContentUnder25k { get {
        String properContent=this.contentItems.get('FoundationLoaContentUnder25k');
        properContent= properContent.replace('__REQUESTPAYMENT__',getApprovedAmount());
        properContent= properContent.replace('__Organization_Name__',fundReq.Organization__r.Organization_Name__c);
        properContent= properContent.replace('__Event_Program_Name__',fundReq.Event_Program_Title__c == null?'':fundReq.Event_Program_Title__c);
        properContent= properContent.replace('__Request_ID__',fundReq.name); 
        return properContent;
        //return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), this.contentItems.get('FoundationLoaContentUnder25k')); 
        }
    }
    
    /**
    * @author GFRS Dev Team
    * @date 12/03/2014
    * @description Property which returning LOA Introduction content for Foundation with Approved Ammount < 25 000 . 
    */
    public String foundationLoaContentUnder25kIntroduction { get { return gFRS_Util.replaceContentVariable('__Organization_Name__', fundReq.Organization__r.Organization_Name__c, this.contentItems.get('FoundationLoaContentUnder25kIntroduction')); }}
    
    /**
    * @author GFRS Dev Team
    * @date 12/03/2014
    * @description PProperty which returning LOA content for Foundation with Approved Ammount > 25 000. 
    */
    public String foundationLoaContentOver25kIntroduction { get { return gFRS_Util.replaceContentVariable('__Organization_Name__', fundReq.Organization__r.Organization_Name__c, this.contentItems.get('FoundationLoaContentOver25kIntroduction')); }}
    
    
    
    /**
    * @author GFRS Dev Team
    * @date 11/07/2013
    * @description Property which returning LOA content for Field Exhibits. 
    */
    public String fieldExhibitsLOAContent { get {
             String tempContent=this.contentItems.get('FieldExhibitsLOAContent');
             //__FIRSNAME__ not used in actual content (gFRS 5.2)
             //tempContent=tempContent.replace('__FIRSNAME__',this.fundReq.Signing_Authority_First_Name__c == null ? '' : this.fundReq.Signing_Authority_First_Name__c).replace('__Last Name__',this.fundReq.Signing_Authority_Last_Name__c == null? '':this.fundReq.Signing_Authority_Last_Name__c);
             return gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', getApprovedAmount(), tempContent); 
         }
    }
    
    /**
    * @author GFRS Dev Team
    * @date 17/07/2013
    * @description Property which returning LOA introduction for Field Initited Exhibits. 
    */
    public String fieldExhibitsIntroduction { get {
             String tempContent=this.contentItems.get('FieldExhibitsIntroduction');
             //__RequestName__ not used in actual content (gFRS 5.2)
             //tempContent=tempContent.replace('__RequestName__',this.fundReq.Name == null ? '' : this.fundReq.Name);
             return tempContent.replace('__RECIPIENT__',this.fundReq.Organization__r.Organization_Name__c == null ? '' : String.valueOf(this.fundReq.Organization__r.Organization_Name__c)); 
         }
    }
    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description printToPdf method - returns page reference with URL to PDF page.
    */
    public ApexPages.PageReference printToPdf(){
        PageReference pdf= new PageReference('/apex/'+PDF_PAGE);
        pdf.getParameters().put('id',fundReq.id);
        pdf.setRedirect(true);
        
        return pdf;
        //return( new ApexPages.PageReference( gFRS_Util.initializeLink( PDF_PAGE, null, null ) ));
    }
    
    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description getTypeForLetter method - dictionary method for funding types
    */
    private String getTypeForLetter(String fundReqTypeName){
        if(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME == fundReqTypeName){
            return  String.valueOf(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_LETTER);
        } else if(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME == fundReqTypeName){
            return  String.valueOf(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_LETTER);
        } else if(gFRS_Util.TYPE_FELLOWSHIPS_NAME == fundReqTypeName){
            return  String.valueOf(gFRS_Util.TYPE_FELLOWSHIPS_LETTER);
        } else if(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME == fundReqTypeName){
            return  String.valueOf(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_LETTER);
        } else if(gFRS_Util.TYPE_HC_CHAR_NAME == fundReqTypeName){
            return  String.valueOf(gFRS_Util.TYPE_HC_CHAR_LETTER);
        } else if(gFRS_Util.TYPE_PHILANTHROPIC_NAME == fundReqTypeName){
            return  String.valueOf(gFRS_Util.TYPE_PHILANTHROPIC_LETTER);
        } else if(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME == fundReqTypeName){
            return  String.valueOf(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_LETTER);
        }
        
        return '';
    }
    
    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description createLoaAttachment method - creates LOA attachment
    * SFDC-1710 method which adding LOA PDF attachment and updating LOA_PDF__c field on Funding Request
    * SFDC-3748 - modify the existing implementation, so that PDF LOA is never deleted automatically
    */   
    public void createLoaAttachment( ApexPages.Pagereference pageRefPdf){
            
            Attachment newLOADocument = new Attachment( Name = 'LOADocument.pdf', body = pageRefPdf.getContent(), parentId = this.fundReq.Id );
            insert newLOADocument;
            this.LoaDocument = newLOADocument;
            this.fundReq.LOA_PDF__c = this.LoaDocument.Id;
            update this.fundReq;    
            
    }

    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description getApprovedAmount method - SFDC-1806 return string to appropriate currency format
    */  
    public String getApprovedAmount(){
        String approvedAmount='0.00';
        if(this.fundReq.Approved_Amount__c!=null){
            Decimal Amount=this.fundReq.Approved_Amount__c;
            Decimal dollars;
            Decimal cents;
            dollars = Amount.intValue();
            cents = Amount - Amount.intValue();
            cents = cents.setScale(2); 
            return dollars.format() + cents.toPlainString().substring(1);
        }else{
            return approvedAmount;
        }
    }
    
    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description assingProgramHelerList method - creates ProgramHelper list
    */  
    public List<programHelper> assingProgramHelerList(){
        List<programHelper> finalList=new List<programHelper>();
        List<GFRS_Program__c> porgramList = new List<GFRS_Program__c>();
        if(this.fundReq.Record_Type_Name__c == 'Exhibits & Other Promos' || this.fundReq.Record_Type_Name__c == 'Sci/Pipeline Exhibits & Other Non-Promo'){
            porgramList=[select End_Date__c, Venue_City__c, Name, Start_Date__c, Type__c from GFRS_Program__c where Funding_Request__r.Name=:this.fundReq.Name and Program_Status__c!='Canceled'];
        } else {
            porgramList=[select End_Date__c, Venue_City__c, Name, Start_Date__c, Type__c from GFRS_Program__c where Funding_Request__r.Name=:this.fundReq.Name and Program_Status__c='Confirmed'];
        }
        Integer iter=1;
        for(GFRS_Program__c item:porgramList){
            finalList.add(new programHelper(iter,item));
            iter++;
        }
        return finalList;
        
    }
    
    /** 
    * @Author ADMD Team
    * @date 06/02/2014
    * @description programHelper class - inner helper class
    */ 
    public class programHelper{
        public Integer rowNum{get;set;}
        public GFRS_Program__c programItem{get;set;}
        
        public  programHelper(Integer iter,GFRS_Program__c prog){
            this.rowNum=iter;
            this.programItem=prog;
        }
    }
    class CustomException extends Exception {}
}