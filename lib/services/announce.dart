import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:get/get.dart';

class Announce extends GetxController {
  final RxString title;
  final RxString description;
  final Rx<File?> image;
  final RxString createdBy;
  final Rx<DateTime> announcementDate;
  Announce({
    required String title,
    required String description,
    required File? image,
    required String createdBy,
    required DateTime announcementDate,
  })  : announcementDate = announcementDate.obs,
        title = title.obs,
        description = description.obs,
        image = image.obs,
        createdBy = createdBy.obs;

  void updateAnnouncement(
      String newTitle,
      String newDescription,
      String newImage,
      String newCreatedBy,
      DateTime selectedDate,
      ) {
    this.title.value = newTitle;
    this.description.value = newDescription;
    this.image.value = File(newImage);
    this.createdBy.value = newCreatedBy;
    this.announcementDate.value = selectedDate;
  }

  Future<String> createinFirestore(String url) async {
    try {
      final DateTime date = DateTime.now();
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': title.value,
        'description': description.value,
        'image': url,
        'date': announcementDate.value,
        'createdBy': createdBy.value,
        'uid': FirebaseAuth.instance.currentUser!.uid,
      });
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }


  Future<String> uploadToStorage() async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('Announcements')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child(title.value);
      UploadTask uploadTask = ref.putFile(
          image.value!,
          SettableMetadata(
            contentType: "image/jpeg",
          ));
      TaskSnapshot snap = await uploadTask;
      String url = await snap.ref.getDownloadURL();
      var result = await createinFirestore(url);
      return result;
    } catch (e) {
      return e.toString();
    }
  }
}
