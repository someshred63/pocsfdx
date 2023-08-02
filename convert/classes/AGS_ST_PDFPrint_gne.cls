public without sharing class AGS_ST_PDFPrint_gne {
    public Boolean showFAQ { get; set; }
    public Boolean showAboutContent { get; set; }
    public List<AGS_ST_FAQ_DYK_gne__c> faqList  { get; set; }
    public String aboutText { get; set; }
    public Boolean pdfPrint { get; set; }
    public String renderAs { get; set; }
    
    public AGS_ST_PDFPrint_gne() {
        renderAs = 'html';
        showFAQ = false;
        showAboutContent = false;
        pdfPrint = false;
        faqList = new List<AGS_ST_FAQ_DYK_gne__c>();
        String contentParam = ApexPages.currentPage().getParameters().get('content');
        String pdfPrintParam = ApexPages.currentPage().getParameters().get('pdfprint');
        
        if(contentParam != null) {
            if('faq'.equals(contentParam))
                showFaq = true;
            else if('about'.equals(contentParam))
                showAboutContent = true;
        }
        if(pdfPrintParam != null) {
            if('1'.equals(pdfPrintParam)) {
                pdfPrint = true;            
                renderAs = 'pdf';
            }
        }
    
        if(showFaq) { 
            faqList = [select Question_number_gne__c,Answer_gne__c,Question_gne__c,TC_Description_Text_gne__c,Type_gne__c from AGS_ST_FAQ_DYK_gne__c where Type_gne__c='FAQ' Order by Question_number_gne__c asc];           
        }    
        else if(showAboutContent) {
            faqList = [select Question_number_gne__c,Answer_gne__c,Question_gne__c,TC_Description_Text_gne__c,Type_gne__c from AGS_ST_FAQ_DYK_gne__c where Type_gne__c='About Sunshine Act' Order by Question_number_gne__c asc];
            if(faqList != null && faqList.size() == 1) 
                aboutText = faqList.get(0).TC_Description_Text_gne__c;
       }
    }
}