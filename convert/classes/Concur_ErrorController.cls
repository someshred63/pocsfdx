public without sharing class Concur_ErrorController {

    public string errorCode { get; set; }
    public Pagereference autorun()
    {
        errorCode = ApexPages.currentPage().getParameters().get('errorCode');
        return null;
    }
}