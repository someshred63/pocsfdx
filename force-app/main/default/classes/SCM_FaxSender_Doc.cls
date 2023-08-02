public class SCM_FaxSender_Doc {    
        
        private String faxNum;
        private String docName;
        private Boolean faxNumberValid;
        private Boolean documentValid;
        
        public String Id {get; set;}
        public String Name {
            get {
                return docName;
            }
            set {
                docName = value;
                try
                {
                    String fileNameExtension = docName.substring(docName.lastIndexOf('.'));
                    if(fileNameExtension != '.doc' && fileNameExtension  != '.docx'){
                        IsDocumentValid = false;
                    }
                }
                catch(Exception ex)
                {
                    IsDocumentValid = false;
                }
            }
        }
        public String ParentFolderId {get; set;}
        public DateTime UpdatedDate {get; set;}
        public String getUpdatedDateFormatted() {
            if(UpdatedDate != null) {
                return UpdatedDate.format('MM/dd/yyyy hh:mm aaa');
            }
            else {
                return '';
            }
        }
        public String Description {get; set;}
        public String FileSize {get; set;}
        public String FileType {get; set;}
        public String DocumentType{get; set;}
        public String CompanyOfficeName {get; set;}
        public String Attention {get; set;}
        public String FaxNumber {
            get { return faxNum; }
            set { 
                    String phoneDigits = ExtractNumbers(value);

                    if (phoneDigits == '' ){
                        IsFaxNumberValid = false;
                        faxNum = '- NONE -';
                    }
                    else {                       
                        if (phoneDigits.Length() == 10) {
                            IsFaxNumberValid = true;
                            faxNum = value;
                            
                        }
                        else if (phoneDigits.Length() >= 11)
                        {
                            IsFaxNumberValid = true;
                            faxNum = value;
                        }

                        else
                        {                   
                            IsFaxNumberValid = false;
                            faxNum = value;
                        }
                    }
            }
        }
        
        public Boolean IsFaxNumberValid {
            get { return faxNumberValid; } 
            set { 
                if(value) {
                    faxNumberValid= true;
                }
                else {
                    faxNumberValid = false;
                    IsCoverSheetValid = false;
                }
            }
        }
        
        public Boolean IsDocumentValid {
            get { return documentValid; } 
            set { 
                if(value) {
                    documentValid= true;
                }
                else {
                    documentValid= false;
                    IsCoverSheetValid = false;
                }
            }
        }
        
        
        
        public Boolean IsCoverSheetValid {get; set;}
        
        public Boolean Selected {get; set;}
        public Boolean First{get; set;}
        public Boolean Last{get; set;}
        public Integer getSizeOfFile()
        {
            return Integer.valueOf(FileSize);
        } 
        
        public SCM_FaxSender_Doc() {
            IsFaxNumberValid = true;
            IsDocumentValid = true;
            IsCoverSheetValid = true;
        }
               
        public static SCM_FaxSender_Doc ToDoc(SCM_FaxSender_WebService.SCMFaxDocument faxDocument) {
            SCM_FaxSender_Doc doc = new SCM_FaxSender_Doc();
            
            //try
            //{
                doc.Id = faxDocument.Id;
                doc.Name = faxDocument.Filename;
                doc.ParentFolderId = faxDocument.ParentFolderId;
                //doc.UpdatedDate = DateTime.valueOf(document.UpdatedDate);
                doc.UpdatedDate = faxDocument.DateModified;
                //doc.Description = faxDocument.Description;
                doc.FileSize = faxDocument.FileSize;
                doc.CompanyOfficeName = faxDocument.CompanyOffice;
                doc.Attention = faxDocument.Attention;
                doc.FaxNumber = faxDocument.FaxNumber;
                doc.DocumentType = faxDocument.DocumentType;
                doc.FileType= faxDocument.FileType;

            //}
            //catch (Exception ex)
            //{
                // doc.Name = "Unknown";
            //}
            
            return doc;
        }

        
        public static DateTime GetADate(string aStringDate) {
            DateTime dateTimeX = null;
            try
            {
            dateTimeX = 
               datetime.newInstance(integer.valueof(aStringDate.substring(0,4)),
                                    integer.valueof(aStringDate.substring(5,7)),
                                    integer.valueof(aStringDate.substring(8,10)),
                                    integer.valueof(aStringDate.substring(11,13)),
                                    integer.valueof(aStringDate.substring(14,16)),
                                    integer.valueof(aStringDate.substring(17,19)));
            }
            catch(Exception ex)
            {
                dateTimeX = null;
            }
            return dateTimeX;
        }
        
          public static DateTime ConverDate(string aStringDate) {
            DateTime dateTimeX = null;
            try
            {
            dateTimeX = 
               datetime.newInstance(integer.valueof(aStringDate.substring(0,4)),
                                    integer.valueof(aStringDate.substring(5,7)),
                                    integer.valueof(aStringDate.substring(8,10))
                                    );
            }
            catch(Exception ex)
            {
                dateTimeX = null;
            }
            return dateTimeX;
        }

        public static List<SCM_FaxSender_Doc> ToSCMDocs(List<SCM_FaxSender_WebService.SCMFaxDocument> documents) {
            List<SCM_FaxSender_Doc> docs = new List<SCM_FaxSender_Doc>();
            
            if (documents != null) {
                for (SCM_FaxSender_WebService.SCMFaxDocument document : documents) {
                    docs.add(SCM_FaxSender_Doc.ToDoc(document));
                }
            }
            else
            {
                //TODO: Error occured
            }
            

            return docs;
        }
                
        public static string ExtractNumbers(string numberString) {
            String pureNumbers = '';
                
            Pattern pat = Pattern.compile('([^0-9])');
                
            String[] phoneDigits = pat.split(numberString);
                
            for (string digit : phoneDigits) {
                pureNumbers += digit;
            }
            return pureNumbers;
        }

}