import 'package:sixam_mart_delivery/data/model/response/language_model.dart';
import 'package:sixam_mart_delivery/util/images.dart';

class AppConstants {
  static const String appName = 'Aziz Food Delivery';
  static const double appVersion = 2.1;

  static const String baseUrl = 'https://azizfood.com';
  static const String configUri = '/api/v1/config';
  static const String forgetPasswordUri =
      '/api/v1/auth/delivery-man/forgot-password';
  static const String verifyTokenUri = '/api/v1/auth/delivery-man/verify-token';
  static const String resetPasswordUri =
      '/api/v1/auth/delivery-man/reset-password';
  static const String loginUri = '/api/v1/auth/delivery-man/login';
  static const String tokenUri = '/api/v1/delivery-man/update-fcm-token';
  static const String currentOrdersUri =
      '/api/v1/delivery-man/current-orders?token=';
  static const String allOrdersUri = '/api/v1/delivery-man/all-orders';
  static const String latestOrdersUri =
      '/api/v1/delivery-man/latest-orders?token=';
  static const String recordLocationUri =
      '/api/v1/delivery-man/record-location-data';
  static const String profileUri = '/api/v1/delivery-man/profile?token=';
  static const String updateOrderStatusUri =
      '/api/v1/delivery-man/update-order-status';
  static const String updatePaymentStatusUri =
      '/api/v1/delivery-man/update-payment-status';
  static const String orderDetailsUri =
      '/api/v1/delivery-man/order-details?token=';
  static const String acceptOrderUri = '/api/v1/delivery-man/accept-order';
  static const String activeStatusUri =
      '/api/v1/delivery-man/update-active-status';
  static const String updateProfileUri = '/api/v1/delivery-man/update-profile';
  static const String notificationUri =
      '/api/v1/delivery-man/notifications?token=';
  static const String aboutUsUri = '/about-us';
  static const String privacyPolicyUri = '/privacy-policy';
  static const String tramsAndConditionUri = '/terms-and-conditions';
  static const String driverRemoveUri =
      '/api/v1/delivery-man/remove-account?token=';
  static const String dmRegisterUri = '/api/v1/auth/delivery-man/store';
  static const String zoneListUri = '/api/v1/zone/list';
  static const String zoneUri = '/api/v1/config/get-zone-id';
  static const String currentOrderUri = '/api/v1/delivery-man/order?token=';
  static const String vehiclesUri = '/api/v1/get-vehicles';
  static const String orderCancellationUri =
      '/api/v1/customer/order/cancellation-reasons';

  //chat url
  static const String getConversationListUri =
      '/api/v1/delivery-man/message/list';
  static const String getMessageListUri =
      '/api/v1/delivery-man/message/details';
  static const String sendMessageUri = '/api/v1/delivery-man/message/send';
  static const String searchConversationListUri =
      '/api/v1/delivery-man/message/search-list';

  // Shared Key
  static const String theme = 'sixam_mart_delivery_theme';
  static const String token = 'sixam_mart_delivery_token';
  static const String countryCode = 'sixam_mart_delivery_country_code';
  static const String languageCode = 'sixam_mart_delivery_language_code';
  static const String userPassword = 'sixam_mart_delivery_user_password';
  static const String userAddress = 'sixam_mart_delivery_user_address';
  static const String userNumber = 'sixam_mart_delivery_user_number';
  static const String userCountryCode = 'sixam_mart_delivery_user_country_code';
  static const String notification = 'sixam_mart_delivery_notification';
  static const String notificationCount =
      'sixam_mart_delivery_notification_count';
  static const String ignoreList = 'sixam_mart_delivery_ignore_list';
  static const String topic = 'all_zone_delivery_man';
  static const String zoneTopic = 'zone_topic';
  static const String localizationKey = 'X-localization';
  static const String langIntro = 'language_intro';

  // Status
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String accepted = 'accepted';
  static const String processing = 'processing';
  static const String handover = 'handover';
  static const String pickedUp = 'picked_up';
  static const String delivered = 'delivered';
  static const String canceled = 'canceled';
  static const String failed = 'failed';
  static const String refunded = 'refunded';

  static List<LanguageModel> languages = [
    LanguageModel(
        imageUrl: Images.english,
        languageName: 'English',
        countryCode: 'US',
        languageCode: 'en'),
    LanguageModel(
        imageUrl: Images.arabic,
        languageName: 'Arabic',
        countryCode: 'SA',
        languageCode: 'ar'),
    LanguageModel(
        imageUrl: Images.arabic,
        languageName: 'Spanish',
        countryCode: 'ES',
        languageCode: 'es'),
  ];
}
