class UrlUtils {
  static String baseUrl = "https://api.ex-nihilo.uk/zero/";
  static String baseUrlImageUrl = "https://api.ex-nihilo.uk/";
  static String baseUrlKYCUrl = "http://157.180.93.36:3005/";


  static String kycLoginUrl = "${baseUrlKYCUrl}api/auth/login";
  static String submitKycUrl = "${baseUrlKYCUrl}api/verify";
  static String kycStatusUrl = "${baseUrlKYCUrl}api/verify/status/";//api/verify/status/cb82814a-2817-4b93-8ad3-09a3127e8b09(job_id)


  static String appConfigUrl = "${baseUrl}api/app-config";
  static String imageUploadUrl = "${baseUrlImageUrl}fsapi/image-upload/single";
  static String imageDeleteUrl = "${baseUrlImageUrl}fsapi/image-upload/delete";


  static String loginUrl = "${baseUrl}api/login";
  static String registrationUrl = "${baseUrl}api/registration";
  static String profileUrl = "${baseUrl}api/profile";
  static String getCountryListUrl = "${baseUrl}api/getcountrylist";
  static String updateKycStatusUrl = "${baseUrl}api/updatekycstatus";

  static String createPropertyUrl = "${baseUrl}property";
  static String generatePdfUrl = "${baseUrl}zeroadmin/consent/generate-pdf";
  static String getPropertyDetailsUrl = "${baseUrl}property/";//property?id=267ac61b-f3af-47e4-a968-b88b64ed8214
  static String getPropertyListUrl = "${baseUrl}property";//property?city=London&propertytype=apartment&blockchainStatus=PENDING

}