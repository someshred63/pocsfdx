public without sharing class GNE_gCollaborate_RSS_Reader_Controller {

	public String rssUrl { get; private set; }
	private Boolean saltUrl = false;
	
	/*
	 * Constructor
	 */
	public GNE_gCollaborate_RSS_Reader_Controller() {
		/*
		 * Prevent Google Feed API to Cache Feeds.
		 * Google adds new Feeds with Cache enabled but it doesn't update older Feed if it have been changed.
		 */
		if(this.saltUrl) {
			rssUrl = (ApexPages.currentPage().getparameters().get('rssUrl')!=null) ? this.saltUrl(ApexPages.currentPage().getParameters().get('rssUrl')) : null;
		} else {
			rssUrl = (ApexPages.currentPage().getparameters().get('rssUrl')!=null) ? ApexPages.currentPage().getParameters().get('rssUrl') : null;
		}
	}

	/*
	 * private saltUrl(String)
	 * 
	 * It should prevent Google Feed Api from Cache feeds.
	 *
	 * return String
	 */
	private String saltUrl(String url) {
		return url + '#' + String.valueOf(Crypto.getRandomInteger());
	}

}