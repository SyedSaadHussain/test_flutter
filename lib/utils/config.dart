class TestDatabase{
  //Direct Links
  // static const String baseUrl = 'http://172.20.10.76:8069';
  // static const String database="moiastage";

  //  static const String baseUrl = 'http://172.20.10.75:8069';
  // static const String database="moia_live";

  //Proxy Links
  static const String baseUrl = 'http://172.20.21.162:8085';
  static const String database="moia_live";

  // static const String baseUrl = 'https://discovery.moia.gov.sa';
  // static const String database="moia_live";

  // static const String baseUrl = 'http://10.0.2.2:5140';
  // static const String database="moia_live";
}
class Config {
  static const bool isTestDb=true;

  static const String playStoreLink = 'https://shorturl.at/wmJzr';
  static const String appleStoreLink = 'https://shorturl.at/0DPwS';

 // static const String baseUrl = 'http://172.20.21.161:8085';
 //
 // static const String baseUrl = 'http://10.0.2.2:5140';
 // static const String database="moia_live";

 //  static const String baseUrl = 'http://172.20.10.75:8069';
 // static const String database="moia_live";

  // static const String baseUrl = 'https://masajidCRM.moia.gov.sa';


    static const String discoveryUrl = 'http://172.20.21.162:8085';
    //static const String discoveryUrl = 'https://discovery.moia.gov.sa';
    static const String discoveryApiToken = 'e2c3b5d7-84d4-44cb-b0f1-708c583be8c8';
    //static const String baseUrl = 'https://discovery.moia.gov.sa';
    //static const String database="moia_live";
}

class Model{
     static const String meter="meter.meter";
     static const String employee="hr.employee";
     static const String mosque="mosque.mosque";
     static const String visit="visit.visit";
}

class Language{
  static const String english="en_US";
  static const String arabic="ar_001";
}