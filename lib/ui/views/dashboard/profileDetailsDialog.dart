
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';

class ProfileDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const ProfileDetailsDialog({Key? key, required this.profileData}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: kcPrimaryColor,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: (profileData['imageUrl'] != null && profileData['imageUrl'].isNotEmpty)
                    ? Image.network(
                  profileData['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                )
                    : _buildDefaultAvatar(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Profile Details',
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kcPrimaryColor,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.person,
                    label: 'Name',
                    value: profileData['name'],
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    icon: Icons.location_city,
                    label: 'Estate',
                    value: profileData['estate'],
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    icon: Icons.home,
                    label: 'House Number',
                    value: profileData['houseNumber'],
                  ),
                  if (profileData['userId'] != null) ...[
                    const SizedBox(height: 15),
                    _buildDetailRow(
                      icon: Icons.verified_user,
                      label: 'ID',
                      value: profileData['userId'],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: kcPrimaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}