global class GNE_CM_CommunityURLRewriter implements Site.UrlRewriter { 

	private final String UI_PAGE = '/_ui/search'; 
	private final String NOT_FOUND_PAGE = '/FileNotFound'; 

	global PageReference mapRequestUrl(PageReference myFriendlyUrl) { 
		if (!UserInfo.getUserType().equalsIgnoreCase('Standard')) {
            String url = myFriendlyUrl.getUrl(); 
          
            if (url.contains(UI_PAGE)) { 
                return new PageReference(NOT_FOUND_PAGE); 
            }
        }
		return null; 
	} 
    
    global System.PageReference[] generateUrlFor(System.PageReference[] salesforceUrls) {
        return null;
    }
}