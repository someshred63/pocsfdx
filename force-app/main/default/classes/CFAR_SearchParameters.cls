public class CFAR_SearchParameters{
    public Map<String,Object> andEqualsParameters {get;set;}
    public Map<String,Object> andNotEqualsParameters {get;set;}
    public Map<String,String> andLikeParameters {get;set;}
    public Map<String,String> andContainsParameters {get;set;}    
    public Map<String,String> andStartsWithParameters {get;set;}
    
    public Map<String,List<String>> andInParameters {get;set;}
    public Map<String,List<String>> andNOTInParameters {get;set;}
    
    public Map<String,List<String>> orEqualsParameters {get;set;}
    
    //public Map<String,String> orLikeParameters {get;set;}
    public Map<String,Map<String,String>> orLikeParameters {get;set;}
    
    public Map<String, List<String>> orGreaterParameters {get;set;}
    public Map<String, List<String>> orLesserParameters {get;set;}
    
    public Map<String, List<String>> orInMultipicklistParameters {get; set;}
    public Map<String, String> multipicklistFieldOrAndLogic {get; set;}
    
    public Map<String, List<String>> inJunctionOrAndParameters {get; set;}
    public Map<String, String> junctionOrAndLogic {get; set;}
    public Map<String, List<String>> includesAll {get; set;}
    public Map<String, List<String>> includesAny {get; set;}

    public String sortExpression {get;set;}     
    public String sortDirection {get;set;}
    
    public CFAR_SearchParameters(){
        andEqualsParameters = new Map<String,Object>();
        andNotEqualsParameters = new Map<String,Object>();
        andLikeParameters = new Map<String,String>();
        andContainsParameters = new Map<String,String>();        
        andStartsWithParameters = new Map<String,String>();
        
        andInParameters = new Map<String,List<String>>();
        andNOTInParameters = new Map<String,List<String>>();
        
        //orLikeParameters = new Map<String,String>();
        orLikeParameters = new Map<String,Map<String,String>>();
        orEqualsParameters = new Map<String,List<String>>();
        orLesserParameters = new Map<String,List<String>>();
        orGreaterParameters = new Map<String,List<String>>();
        
        orInMultipicklistParameters = new Map<String, List<String>>();
        multipicklistFieldOrAndLogic = new Map<String, String>();
        
       	inJunctionOrAndParameters = new Map<String, List<String>>();
   		junctionOrAndLogic = new Map<String, String>();

        includesAll = new Map<String, List<String>>();
        includesAny = new Map<String, List<String>>();
        
        sortExpression = '';
        sortDirection = '';
    }
    
    public Boolean isEmpty(){
        return  (
            andEqualsParameters.isEmpty()
            && andNotEqualsParameters.isEmpty()
            && andContainsParameters.isEmpty()
            && andLikeParameters.isEmpty()
            && andStartsWithParameters.isEmpty()

            && andInParameters.isEmpty()
            && andNOTInParameters.isEmpty()

            && orEqualsParameters.isEmpty()
            && orLikeParameters.isEmpty()

            && orLesserParameters.isEmpty()
            && orGreaterParameters.isEmpty()

            && orInMultipicklistParameters.isEmpty()

            && inJunctionOrAndParameters.isEmpty()

            && includesAll.isEmpty()
            && includesAny.isEmpty()
        );
    }
}