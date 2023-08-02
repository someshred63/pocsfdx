@RestResource(urlMapping='/ImageService/*')
global with sharing class CHV_ImageDataGetter {
	
	global class CHV_ImageWrapper{
		public String encodedImage;
		
		global CHV_ImageWrapper(String encodedImage){
			this.encodedImage = encodedImage;
		}
	}
	
	@HttpGet
	global static CHV_ImageWrapper getImageService() {
		RestRequest req = RestContext.request;
		String imageId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		return new CHV_ImageWrapper(CHV_Utils.getEncodedImageById(imageId));
	}
}