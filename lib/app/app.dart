import 'package:webrtc/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:webrtc/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:webrtc/ui/views/home/home_view.dart';
import 'package:webrtc/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webrtc/services/signalling_service.dart';
import 'package:webrtc/ui/views/callscreen/callscreen_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: CallscreenView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SignallingService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
