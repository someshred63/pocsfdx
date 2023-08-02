public with sharing class GNE_TISL_GeoCode
{
    public static final string XML_STATUS = 'status'; 
    public static final string XML_REQ_STATUS = 'OK';
    public static final string XML_NAME = 'result';
    public static final string XML_GEOMETRY = 'geometry';
    public static final string XML_LOCATION = 'location';
    public static final string XML_LAT = 'lat';
    public static final string XML_LNG = 'lng';
    public static final string RESPONSE_STATUS_1 = 'Invalid address.';
    public static final string RESPONSE_STATUS_2 = 'Multiple locations found corresponding to the given address. Please be more specific.';
    public static final String API_KEY {
        get {
            return 'key=AIzaSyCZkYcDKPGwYpLl2vYZ4Kg5PcDIZoXvkXI';
        }
        private set;
    }
    
    public static string Status { get; set; }     

    public GNE_TISL_GeoCode(ApexPages.StandardController controller) {

    }

    public class GeocodeResponse
    {
      public double location_Lat {get; set; }
      public double location_Lng { get; set; }
      public string Reqstatus { get; set; }
    } 
     
    public static GeocodeResponse getCoords(string address)
    {
      GeocodeResponse gr = new GeocodeResponse(); 
      gr.Reqstatus       = RESPONSE_STATUS_1; 
       TISL_GenerateKey gen_key= new  TISL_GenerateKey();
       HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod('GET');
        String inputurl= 'https://maps.googleapis.com/maps/api/geocode/xml'
            + '?address=' + EncodingUtil.urlEncode(address,'UTF-8')
           + '&' + API_KEY;
            system.debug('url test '+inputurl);
          
      req.setEndpoint(inputurl);
      HTTPResponse resp = http.send(req);

     integer locationCounter = 0;
     string xmlString = resp.getBody();
     Dom.Document doc = new Dom.Document();
      doc.load(xmlString);
     Dom.Xmlnode root = doc.getRootElement();
        for(Dom.XMLNode level1 : root.getChildElements()) 
        {
        if (level1.getName() == XML_STATUS)
              gr.Reqstatus = level1.getText();
        if (gr.Reqstatus == XML_REQ_STATUS && level1.getName() == XML_NAME)
          for(Dom.XMLNode level2 : level1.getChildElements())
          {
              if (level2.getName() == XML_GEOMETRY)
              {
                for(Dom.XMLNode level3 : level2.getChildElements())
                {
                  if (level3.getName() == XML_LOCATION)
                  {
                    locationCounter++;
                    for(Dom.XMLNode level4 : level3.getChildElements())
                    {
                      if (level4.getName() == XML_LAT) 
                        gr.location_Lat = Double.valueOf(level4.getText());
                      if (level4.getName() == XML_LNG) 
                        gr.location_Lng = Double.valueOf(level4.getText());
                    }
                  }
                }
              }
          }
        }             
        if(locationCounter > 1)
        {
            gr.location_Lat  = 0.0;
            gr.location_Lng  = 0.0;
            gr.Reqstatus     = RESPONSE_STATUS_2;
        }
        return gr;
    }
}