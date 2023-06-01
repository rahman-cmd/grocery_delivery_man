import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sixam_mart_delivery/controller/auth_controller.dart';
import 'package:sixam_mart_delivery/controller/localization_controller.dart';
import 'package:sixam_mart_delivery/controller/order_controller.dart';
import 'package:sixam_mart_delivery/controller/splash_controller.dart';
import 'package:sixam_mart_delivery/data/model/body/notification_body.dart';
import 'package:sixam_mart_delivery/data/model/response/conversation_model.dart';
import 'package:sixam_mart_delivery/data/model/response/order_model.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/view/base/confirmation_dialog.dart';
import 'package:sixam_mart_delivery/view/base/custom_app_bar.dart';
import 'package:sixam_mart_delivery/view/base/custom_button.dart';
import 'package:sixam_mart_delivery/view/base/custom_image.dart';
import 'package:sixam_mart_delivery/view/base/custom_snackbar.dart';
import 'package:sixam_mart_delivery/view/screens/order/widget/cancellation_dialogue.dart';
import 'package:sixam_mart_delivery/view/screens/order/widget/order_item_widget.dart';
import 'package:sixam_mart_delivery/view/screens/order/widget/verify_delivery_sheet.dart';
import 'package:sixam_mart_delivery/view/screens/order/widget/info_card.dart';
import 'package:sixam_mart_delivery/view/screens/order/widget/slider_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool? isRunningOrder;
  final int? orderIndex;
  final bool fromNotification;
  const OrderDetailsScreen({Key? key, required this.orderId, required this.isRunningOrder, required this.orderIndex, this.fromNotification = false}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Timer? _timer;

  void _startApiCalling(){
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getOrderWithId(Get.find<OrderController>().orderModel!.id);
    });
  }

  Future<void> _loadData() async {
    await Get.find<OrderController>().getOrderWithId(widget.orderId);
    Get.find<OrderController>().getOrderDetails(widget.orderId, Get.find<OrderController>().orderModel!.orderType == 'parcel');
  }

  @override
  void initState() {
    super.initState();

    _loadData();
    _startApiCalling();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {

    bool? cancelPermission = Get.find<SplashController>().configModel!.canceledByDeliveryman;
    bool selfDelivery = Get.find<AuthController>().profileModel!.type != 'zone_wise';

    return WillPopScope(
      onWillPop: () async{
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          return true;
        } else {
          Get.back();
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBar(title: 'order_details'.tr, onBackPressed: (){
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            Get.back();
          }
        }),
        body: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: GetBuilder<OrderController>(builder: (orderController) {

            OrderModel? controllerOrderModel = orderController.orderModel;

            bool restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';

            bool? parcel, processing, accepted, confirmed, handover, pickedUp, cod, wallet;

            late bool showBottomView;
            late bool showSlider;

            if(controllerOrderModel != null){
                 parcel = controllerOrderModel.orderType == 'parcel';
                 processing = controllerOrderModel.orderStatus == AppConstants.processing;
                 accepted = controllerOrderModel.orderStatus == AppConstants.accepted;
                 confirmed = controllerOrderModel.orderStatus == AppConstants.confirmed;
                 handover = controllerOrderModel.orderStatus == AppConstants.handover;
                 pickedUp = controllerOrderModel.orderStatus == AppConstants.pickedUp;
                 cod = controllerOrderModel.paymentMethod == 'cash_on_delivery';
                 wallet = controllerOrderModel.paymentMethod == 'wallet';

              bool restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';
              showBottomView = (parcel && accepted) || accepted || confirmed || processing || handover
                  || pickedUp || (widget.isRunningOrder ?? true);
              showSlider = (cod && accepted && !restConfModel && !selfDelivery) || handover || pickedUp
                  || (parcel && accepted);
            }

            return (orderController.orderDetailsModel != null && controllerOrderModel != null) ? Column(children: [

              Expanded(child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(children: [

                  Row(children: [
                    Text('${parcel! ? 'delivery_id'.tr : 'order_id'.tr}:', style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(controllerOrderModel.id.toString(), style: robotoMedium),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    const Expanded(child: SizedBox()),
                    Container(height: 7, width: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      controllerOrderModel.orderStatus!.tr,
                      style: robotoRegular,
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Row(children: [
                    Text('${parcel ? 'charge_payer'.tr : 'item'.tr}:', style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      parcel ? controllerOrderModel.chargePayer!.tr : orderController.orderDetailsModel!.length.toString(),
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                    ),
                    const Expanded(child: SizedBox()),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        cod! ? 'cod'.tr : wallet! ? 'wallet'.tr : 'digitally_paid'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ]),
                  const Divider(height: Dimensions.paddingSizeLarge),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  InfoCard(
                    title: parcel ? 'sender_details'.tr : 'store_details'.tr,
                    address: parcel ? controllerOrderModel.deliveryAddress : DeliveryAddress(address: controllerOrderModel.storeAddress),
                    image: parcel ? '' : '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${controllerOrderModel.storeLogo}',
                    name: parcel ? controllerOrderModel.deliveryAddress!.contactPersonName : controllerOrderModel.storeName,
                    phone: parcel ? controllerOrderModel.deliveryAddress!.contactPersonNumber : controllerOrderModel.storePhone,
                    latitude: parcel ? controllerOrderModel.deliveryAddress!.latitude : controllerOrderModel.storeLat,
                    longitude: parcel ? controllerOrderModel.deliveryAddress!.longitude : controllerOrderModel.storeLng,
                    showButton: (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                        && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded'),
                    isStore: true,
                    messageOnTap: () => Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBody(
                        orderId: controllerOrderModel.id, vendorId: controllerOrderModel.storeId,
                      ),
                      user: User(
                        id: controllerOrderModel.storeId, fName: controllerOrderModel.storeName,
                        image: controllerOrderModel.storeLogo,
                      ),
                    )),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  InfoCard(
                    title: parcel ? 'receiver_details'.tr : 'customer_contact_details'.tr,
                    address: parcel ? controllerOrderModel.receiverDetails : controllerOrderModel.deliveryAddress,
                    image: parcel ? '' : controllerOrderModel.customer != null ? '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${controllerOrderModel.customer!.image}' : '',
                    name: parcel ? controllerOrderModel.receiverDetails!.contactPersonName : controllerOrderModel.deliveryAddress!.contactPersonName,
                    phone: parcel ? controllerOrderModel.receiverDetails!.contactPersonNumber : controllerOrderModel.deliveryAddress!.contactPersonNumber,
                    latitude: parcel ? controllerOrderModel.receiverDetails!.latitude : controllerOrderModel.deliveryAddress!.latitude,
                    longitude: parcel ? controllerOrderModel.receiverDetails!.longitude : controllerOrderModel.deliveryAddress!.longitude,
                    showButton: controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                        && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded',
                    isStore: parcel ? false : true,
                    messageOnTap: () => Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBody(
                        orderId: controllerOrderModel.id, customerId: controllerOrderModel.customer!.id,
                      ),
                      user: User(
                        id: controllerOrderModel.customer!.id, fName: controllerOrderModel.customer!.fName,
                        lName: controllerOrderModel.customer!.lName, image: controllerOrderModel.customer!.image,
                      ),
                    )),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  parcel ? Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 200]!, spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: controllerOrderModel.parcelCategory != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('parcel_category'.tr, style: robotoRegular),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Row(children: [
                        ClipOval(child: CustomImage(
                          image: '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}/${controllerOrderModel.parcelCategory!.image}',
                          height: 35, width: 35, fit: BoxFit.cover,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            controllerOrderModel.parcelCategory!.name!, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                          Text(
                            controllerOrderModel.parcelCategory!.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                        ])),
                      ]),
                    ]) : SizedBox(
                      width: context.width,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('parcel_category'.tr, style: robotoRegular),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Text('no_parcel_category_data_found'.tr, style: robotoMedium),
                      ]),
                    ),
                  ) : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderController.orderDetailsModel!.length,
                    itemBuilder: (context, index) {
                      return OrderItemWidget(order: controllerOrderModel, orderDetails: orderController.orderDetailsModel![index]);
                    },
                  ),

                  (controllerOrderModel.orderNote  != null && controllerOrderModel.orderNote!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('additional_note'.tr, style: robotoRegular),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      width: 1170,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Theme.of(context).disabledColor),
                      ),
                      child: Text(
                        controllerOrderModel.orderNote!,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    (Get.find<SplashController>().getModule(controllerOrderModel.moduleType).orderAttachment!
                    && controllerOrderModel.orderAttachment != null && controllerOrderModel.orderAttachment!.isNotEmpty)
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('prescription'.tr, style: robotoRegular),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Center(child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: CustomImage(
                          image: '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${controllerOrderModel.orderAttachment}',
                          width: 200,
                        ),
                      )),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ]) : const SizedBox(),

                  ]) : const SizedBox(),

                ]),
              )),

              showBottomView ? ((accepted! && !parcel && (!cod || restConfModel || selfDelivery))
               || processing! || confirmed!) ? Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  processing! ? 'order_is_preparing'.tr : 'order_waiting_for_process'.tr,
                  style: robotoMedium,
                ),
              ) : showSlider ? ((cod && accepted && !restConfModel && cancelPermission! && !selfDelivery)
              || (parcel && accepted && cancelPermission!)) ? Row(children: [

                Expanded(child: TextButton(
                  onPressed: () {
                    orderController.setOrderCancelReason('');
                    Get.dialog(CancellationDialogue(orderId: widget.orderId));
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!),
                    ),
                  ),
                  child: Text('cancel'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontSize: Dimensions.fontSizeLarge,
                  )),
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: CustomButton(
                  buttonText: 'confirm'.tr, height: 40,
                  onPressed: () {
                    Get.dialog(ConfirmationDialog(
                      icon: Images.warning, title: 'are_you_sure_to_confirm'.tr,
                      description: parcel! ? 'you_want_to_confirm_this_delivery'.tr : 'you_want_to_confirm_this_order'.tr,
                      onYesPressed: () {
                        orderController.updateOrderStatus(
                          controllerOrderModel, parcel! ? AppConstants.handover : AppConstants.confirmed, back: true,
                        );
                      },
                    ), barrierDismissible: false);
                  },
                )),

              ]) : SliderButton(
                action: () {

                  if (kDebugMode) {
                    print('---1--> : ${(cod! && accepted! && !restConfModel && !selfDelivery) || (parcel! && accepted!)}');
                    print('---2--->  $pickedUp');
                    print('---2(1)--->  ${parcel! && cod && controllerOrderModel.chargePayer != 'sender'}');
                    print('---2(2)--->  ${(Get.find<SplashController>().configModel!.orderDeliveryVerification! || cod) && !parcel}');
                    print('---3--->  ${parcel && controllerOrderModel.chargePayer == 'sender' && cod}');
                    print('---4--->  $handover');
                  }
                  if((cod! && accepted! && !restConfModel && !selfDelivery) || (parcel! && accepted!)) {

                    if(orderController.isLoading){
                      orderController.initLoading();
                    }
                    Get.dialog(ConfirmationDialog(
                      icon: Images.warning, title: 'are_you_sure_to_confirm'.tr,
                      description: parcel! ? 'you_want_to_confirm_this_delivery'.tr : 'you_want_to_confirm_this_order'.tr,
                      onYesPressed: () {
                        orderController.updateOrderStatus(
                          controllerOrderModel, parcel! ? AppConstants.handover : AppConstants.confirmed, back: true,
                        );
                      },
                    ), barrierDismissible: false);
                  }

                  else if(pickedUp!) {
                    if(parcel && cod && controllerOrderModel.chargePayer != 'sender') {
                      Get.bottomSheet(VerifyDeliverySheet(
                        currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: controllerOrderModel.orderAmount, cod: cod,
                      ), isScrollControlled: true);
                    }
                    else if((Get.find<SplashController>().configModel!.orderDeliveryVerification! || cod) && !parcel){
                      Get.bottomSheet(VerifyDeliverySheet(
                        currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: controllerOrderModel.orderAmount, cod: cod,
                      ), isScrollControlled: true);
                    }
                    else if(!cod && parcel && controllerOrderModel.chargePayer == 'sender'){
                      Get.bottomSheet(VerifyDeliverySheet(
                        currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: controllerOrderModel.orderAmount, cod: cod,
                      ), isScrollControlled: true);
                    }
                    else {
                      Get.find<OrderController>().updateOrderStatus(controllerOrderModel, AppConstants.delivered);
                    }
                  }

                  else if(parcel && controllerOrderModel.chargePayer == 'sender' && cod){
                    Get.bottomSheet(VerifyDeliverySheet(
                      currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                      orderAmount: controllerOrderModel.orderAmount, cod: cod, isSenderPay: true, isParcel: parcel,
                    ), isScrollControlled: true);
                  }

                  else if(handover!) {
                    if(Get.find<AuthController>().profileModel!.active == 1) {
                      Get.find<OrderController>().updateOrderStatus(controllerOrderModel, AppConstants.pickedUp);
                    }else {
                      showCustomSnackBar('make_yourself_online_first'.tr);
                    }
                  }

                },
                label: Text(
                  (parcel && accepted) ? 'swipe_to_confirm_delivery'.tr
                      : (cod && accepted && !restConfModel && !selfDelivery) ? 'swipe_to_confirm_order'.tr
                      : pickedUp! ? parcel ? 'swipe_to_deliver_parcel'.tr
                      : 'swipe_to_deliver_order'.tr : handover! ? parcel ? 'swipe_to_pick_up_parcel'.tr
                      : 'swipe_to_pick_up_order'.tr : '',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),
                dismissThresholds: 0.5, dismissible: false, shimmer: true,
                width: 1170, height: 60, buttonSize: 50, radius: 10,
                icon: Center(child: Icon(
                  Get.find<LocalizationController>().isLtr ? Icons.double_arrow_sharp : Icons.keyboard_arrow_left,
                  color: Colors.white, size: 20.0,
                )),
                isLtr: Get.find<LocalizationController>().isLtr,
                boxShadow: const BoxShadow(blurRadius: 0),
                buttonColor: Theme.of(context).primaryColor,
                backgroundColor: const Color(0xffF4F7FC),
                baseColor: Theme.of(context).primaryColor,
              ) : const SizedBox() : const SizedBox(),

            ]) : const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }
}
