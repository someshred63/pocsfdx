public class FCR_RedirectCtrl {
    private static final String EMPLO_LINK = 'itms-services://?action=download-manifest&url=https://appzone.gene.com/dispatch/plist/ITFemployee.plist';
    private static final String COACH_LINK = 'itms-services://?action=download-manifest&url=https://appzone.gene.com/dispatch/plist/ITFcoach.plist';
    private static final Map<String, String> urlsMap = new Map<String, String>{
        'coach' => COACH_LINK,
        'employee' => EMPLO_LINK
    };
                
    public String param { get; set; }
    public String retUrl { get; set; }

    
    public PageReference init() {
        
        param = ApexPages.currentPage().getParameters().get('appType');
        
        try {             
            if ( param != null ) {
                String redirUrl = urlsMap.get(param.toLowerCase()) != null ? urlsMap.get(param.toLowerCase()) : null;
                system.debug('redirUrl '+redirUrl);
                if(redirUrl != null) {
                    PageReference callPage = new PageReference (redirUrl);
                    callPage.setRedirect(true);
                    return callPage;                    
                }
            }    
        } catch (Exception e) {        
            ApexPages.addMessages(e);
        }
        
        return null;        
    }
    
}