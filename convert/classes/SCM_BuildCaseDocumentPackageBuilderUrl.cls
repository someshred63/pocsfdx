public class SCM_BuildCaseDocumentPackageBuilderUrl
{
    public string relatedCaseUrl {get;set;}

    public SCM_BuildCaseDocumentPackageBuilderUrl(ApexPages.StandardController controller)
    {
        string caseId = ApexPages.currentPage().getParameters().get('id');
        relatedCaseUrl = buildRelatedCasesUrl(caseId);
    }
    
    public string buildRelatedCasesUrl(string caseId)
    {
        string url = '';
        List<sObject> cases = Database.query('SELECT Id, (Select Id, Product_gne__c, CaseNumber from Cases3__r)  FROM Case where Id =\'' +  caseId + '\'');
        if (cases.size() > 0)
        {
            integer i = 2; 
            Case parentCase = (Case)cases.get(0);
            SObject[] relatedCases = parentCase.getSObjects('Cases3__r');
            if (relatedCases != null)
            {
                for (SObject relatedCase : relatedCases)
                {
                    object sfaname = relatedCase.get('Product_gne__c');
                    object sfon = relatedCase.get('CaseNumber');
                    object id = relatedCase.get('Id');
                    url += '&[' + i + '].sfaname=' + sfaname + '&[' + i + '].sfaid=' + sfaname + '&[' + i  + '].sfot=Case&[' + i + '].sfon=' + sfon + '&[' +  i + '].sfoid=' + id;
                    i++;
                }
            } 
        }
        return url;
    }
}