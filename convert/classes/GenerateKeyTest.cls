@isTest

private class GenerateKeyTest{

  public static testmethod void testdigsignature() {

  TISL_GenerateKey genkey= new  TISL_GenerateKey ();
  String signature=genkey.getSig('http://maps.googleapis.com/maps/api/geocode/xml?address=611+gateway+campus%2Csouth+sfo%2Cca%2C94080&sensor=false&client=gme-genentechinc');
  }
  
 }