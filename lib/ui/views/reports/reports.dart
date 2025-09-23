import 'package:estate360Security/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import 'Reports_viewmodel.dart';
import '../../../core/data/models/notification_model.dart';
import '../../components/shimmer_widgets.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ViewModelBuilder<ReportsViewModel>.reactive(
        onViewModelReady: (model) => model.init(),
        viewModelBuilder: () => ReportsViewModel(),
        builder: (context, model, child) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text("All Notifications", style: GoogleFonts.redHatDisplay()),
                _buildSearchField(model),
                const SizedBox(height: 10),
                _buildNotificationList(model),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(ReportsViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: model.searchController,
              onChanged: model.searchNotifications,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Notifications',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          const SizedBox(width: 10),

          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onSelected: model.filterNotifications,
            itemBuilder: (context) => [
              const PopupMenuItem(value: "All", child: Text("All")),
              const PopupMenuItem(value: "EMERGENCY", child: Text("Emergency")),
              const PopupMenuItem(value: "GENERAL", child: Text("General")),
              const PopupMenuItem(value: "INFO", child: Text("Info")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(ReportsViewModel model) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async => await model.refreshNotifications(),
        displacement: 40,
      child: model.isBusy
          ? ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: 6,
                itemBuilder: (context, index) => ShimmerWidgets.notificationTileShimmer(context),
            )
          : model.filteredNotifications.isEmpty
              ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                          'No notifications found',
                          style: GoogleFonts.redHatDisplay(
                              fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  )
              : ListView.builder(
                  itemCount: model.filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = model.filteredNotifications[index];
                    return _buildNotificationCard(notification, model);
                  },
                ),
      ),
    );
  }

Widget _buildNotificationCard(NotificationModel notification, ReportsViewModel model) {
  return Card(
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  (notification.title).toLowerCase().contains('reject')
                      ? 'REJECTED'
                      : (notification.approvalStatus),
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (notification.title).toLowerCase().contains('reject')
                        ? Colors.red
                        : (notification.approvalStatus != 'APPROVED' ? Colors.orange : Colors.green),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notification.message,
            style: GoogleFonts.redHatDisplay(
                fontSize: 14, color: Colors.black87),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "From: ${notification.sentBy}",
                style: GoogleFonts.redHatDisplay(
                    fontSize: 12, color: Colors.grey),
              ),
              Text(
                notification.formattedSentAt.toString(),
                style: GoogleFonts.redHatDisplay(
                    fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          _buildEscalateButton(notification, model),
        ],
      ),
    ),
  );
}

Widget _buildEscalateButton(NotificationModel notification, ReportsViewModel model) {

  return Column(

    children: [
     if (notification.notificationType == "EMERGENCY" && notification.approvalStatus != "APPROVED") ...[

      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final res = await locator<DialogService>().showConfirmationDialog(
              title: "Are you sure you want to escalate this notification to all residents?",
              cancelTitle: "No",
              confirmationTitle: "Yes",
            );
            if (res?.confirmed == true) {
              await model.escalateNotifications(notification.notificationId);
            }
          },
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          label: const Text("Escalate", style: TextStyle(color: kcWhiteColor)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
     ],
    ],
  );
}



}
