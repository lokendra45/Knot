import 'dart:io';
import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knot/Screens/home.dart';
import 'package:knot/models/users.dart';
import 'package:knot/widgets/progress_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final Users? currentUser;

  Upload({required this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File? _image;

  bool isUploading = false;
  String? postId = Uuid().v4();
  final _picker = ImagePicker();
  String? fileName;
  List<Filter> filters = presetFiltersList;
  dynamic _pickImageError;
  //

// function to handle camera photos
  Future handleTakePhoto() async {
    if (await Permission.camera.request().isGranted) {
      try {
        Navigator.pop(this.context);
        final pickedImage = await _picker.getImage(
          source: ImageSource.camera,
          maxHeight: 480,
          maxWidth: 640,
        );

        if (pickedImage != null) {
          setState(() {
            _cropImage(pickedImage);
          });
        }
      } catch (e) {}
      print(_pickImageError);
    }
  }

// function to handle gallery photos
  Future handleGalleryPhoto() async {
    try {
      Navigator.pop(this.context);
      final pickedImage = await _picker.getImage(
        source: ImageSource.gallery,
        maxHeight: 480,
        maxWidth: 640,
      );

      setState(() {
        if (pickedImage != null) {
          _cropImage(pickedImage);
        }
      });
    } catch (e) {
      setState(() {
        this._pickImageError = e;
        errorDialog(_pickImageError);
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        _pickImageError,
      ),
      backgroundColor: Colors.red,
    ));
    print(_image!.length());
  }

  _cropImage(filePath) async {
    File? _croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blue,
            toolbarTitle: 'Cropper',
            statusBarColor: Colors.orange,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false));
    setState(() {
      _image = File(_croppedImage!.path);
    });
  }

  // Dialog for Options for photos
  selectPhoto(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(
              "Create Post",
              style: TextStyle(fontSize: 18.0),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleGalleryPhoto,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

//upload screen view form
  Container _buildImageUploadScreen() {
    return Container(
      margin: EdgeInsets.only(left: 45.0),
      height: MediaQuery.of(this.context).size.height / 708,
      color: Colors.white54.withOpacity(0.6),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/Upload.svg',
              height: 200.0,
            ),
            Container(
              height: 50,
              width: 150,
              margin: EdgeInsets.only(top: 40, right: 60),
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.file_upload_outlined,
                  size: 30.0,
                  color: Colors.black,
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.indigo.shade200,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(9.0),
                    ),
                  ),
                ),
                onPressed: () => selectPhoto(context),
                label: Text(""),
              ),
            ),
          ],
        ),
      ),
      padding: EdgeInsets.only(
        left: 10,
      ),
    );
  }

// handling back function
  clearImage() {
    setState(() {
      _image = null;
    });
  }

  // creating post in firestore
  createPostInFireStore(
      {required String mediaUrl,
      required String location,
      required String description}) {
    postRef
        .doc(widget.currentUser!.id)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": widget.currentUser!.id,
      "username": widget.currentUser!.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timeStamp,
      "likes": {},
    });
  }

  // Compresing the image before sending to firebase
  Future _compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(_image!.readAsBytesSync());
    final compressImg = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(
        Im.encodeJpg(imageFile!, quality: 50),
      );
    setState(() {
      _image = compressImg;
    });
    print(_image!.hashCode);
  }

//Handling upload image
  Future<String> uploadImage(imagefile) async {
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imagefile);

    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  // handling submit button
  Future _handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    try {
      await _compressImage();
      String? mediaUrl = await uploadImage(_image);
      if (_image != null) {
        createPostInFireStore(
          mediaUrl: mediaUrl,
          location: locationController.text,
          description: captionController.text,
        );
        captionController.clear();
        locationController.clear();
        setState(() {
          _image = null;
          isUploading = false;
          postId = Uuid().v4();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Photo Uploaded",
          ),
          backgroundColor: Colors.green.shade600,
        ));
      } else if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Choose Some Images"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  //Function to get User Current Location
  Future getUserLocation() async {
    if (await Permission.location.request().isGranted ||
        await Permission.location.status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: 'en');
      Placemark placemark = placemarks[0];
      String completeAddress =
          '${placemark.subThoroughfare}${placemark.thoroughfare},${placemark.subLocality},${placemark.locality},${placemark.subAdministrativeArea},${placemark.administrativeArea},${placemark.postalCode},${placemark.country}';
      print(completeAddress);

      String formattedAddress = "${placemark.subLocality.toString()} ,"
          "${placemark.locality.toString()},"
          "${placemark.country.toString()}";
      locationController.text = formattedAddress;
      print(placemark.locality);
    } else if (await Permission.location.status.isDenied) {
      print("Permission Denied");
    } else if (await Permission.location.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

// Upload form view
  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          onPressed: clearImage,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black,
        ),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: isUploading ? null : () => _handleSubmit(),
            child: Text(
              "Post",
              style:
                  TextStyle(color: Colors.deepPurple.shade500, fontSize: 20.0),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgressBar() : Text(""),
          Container(
            height: 211.0,
            width: MediaQuery.of(this.context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(_image!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 11.0),
          ),
          ListTile(
            leading: CircleAvatar(),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                    hintText: "Write Description", border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop_outlined,
              color: Colors.blue.shade500,
              size: 38.0,
            ),
            title: Container(
              width: 260.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where this Photo Taken",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35.0),
                  )),
              onPressed: getUserLocation,
              icon: Icon(
                Icons.location_on_rounded,
                color: Colors.red.shade300,
              ),
              label: Text(
                "Use Current Location",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

//error function for imagepicker
  errorDialog(String error) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
              _pickImageError.toString(),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(this.context);
                },
                child: Text("Ok"),
              )
            ],
          );
        });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_image == null) {
      return _buildImageUploadScreen();
    } else {
      return buildUploadForm();
    }
  }
}
