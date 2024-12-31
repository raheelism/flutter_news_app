//Please add your admin panel url here and make sure you do not add '/' at the end of the url

const String baseUrl = "enter_your_admin_panel_url_here";
const String databaseUrl = "$baseUrl/api/"; //Do not change

//Please add here your default country code
const String yourCountryCode = 'IN';

const int limitOfAPIData = 10;
const int limitOfStyle1 = 3;
const int limitOfAllOtherStyle = 20;

//Facebook Login enable/disable
const bool fblogInEnabled = false;
//Mobile Login enable/disable
const bool mobilelogInEnabled = false;

//set value for survey show after news data
const int surveyShow = 4;

//set value for native ads show after news data
const int nativeAdsIndex = 3;

//set value for interstitial ads show after news data
const int interstitialAdsIndex = 3;

//set value for reward ads show after news data
const int rewardAdsIndex = 4;

const String appName = 'News App';
const String packageName = 'YOUR_PACKAGE_NAME_HERE';
const String androidLink = 'https://play.google.com/store/apps/details?id=';
const String androidLbl = 'Android:';
const String iosLbl = 'iOS:';
const String iosPackage = 'YOUR_PACKAGE_NAME_HERE';
const String iosLink = ''; //'your ios app link here';
const String appStoreId = '9876543120';

//set your_deeplink_url @ AndroidManifest.xml File, without http Or https -> xxx.page.link
const String deepLinkUrlPrefix = 'your_deeplink_url'; //example - https://xxx.page.link - Your dynamic link from Firebase
const String deeplinkURL = 'your_domain_here'; //example - xxx.com - Your domain name