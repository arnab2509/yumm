import 'dart:io';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;
import 'package:yumm/widget/widget_support.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> fooditems = [
    'Biriyani',
    'Chicken',
    'Icecream',
    'Pizza',
    'Burger'
  ];
  String? value;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
  TextEditingController timecontroller=TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isUploading = false;

  static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    setState(() {});
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'food_items';
      String publicId = 'food_${randomAlphaNumeric(10)}';
      request.fields['public_id'] = publicId;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'];
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  uploadItem() async {
    if (selectedImage != null &&
        namecontroller.text != "" &&
        pricecontroller.text != "" &&
        detailcontroller.text != "" &&
        timecontroller.text !=""&&
        value != null) {

      setState(() {
        isUploading = true;
      });

      String? imageUrl = await uploadImageToCloudinary(selectedImage!);

      if (imageUrl != null) {
        Map<String, dynamic> addItem = {
          "Image": imageUrl,
          "Name": namecontroller.text,
          "Price": pricecontroller.text,
          "Detail": detailcontroller.text,
          "Time":timecontroller.text,
          "Category": value,
          "CreatedAt": FieldValue.serverTimestamp(),
        };

        await DatabaseMethods().addFoodItem(addItem, value!).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.transparent,
              // duration: Durations.,
              // content: Text(
              //   "Food Item has been added Successfully",
              //   style: TextStyle(fontSize: 18.0, color: Colors.white),
              // )
              content: AwesomeSnackbarContent(title: "Yess!!", message: ' Item  added Successfully', contentType: ContentType.success),
              ));

          namecontroller.clear();
          pricecontroller.clear();
          detailcontroller.clear();
          timecontroller.clear();
          selectedImage = null;
          this.value = null;
          setState(() {});
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Failed to upload image. Please try again.",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
      }

      setState(() {
        isUploading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Please fill all fields and select an image",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final width = mediaQuery.width;
    final height = mediaQuery.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: height * 0.12,
                  child: Lottie.network(
                    'https://lottie.host/cee22187-42f5-4d33-97c9-01b5f2a24152/QE10vvtA0u.json',
                  ),
                ),
              ),
              Center(
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(text: "Add  ", style: TextStyle(color: Colors.black, fontSize: width * 0.06)),
                    TextSpan(text: "Food ", style: AppWidget.getPlayLargeOrangeTextStyle()),
                    TextSpan(text: "Items !!", style: TextStyle(color: Colors.black, fontSize: width * 0.06)),
                  ]),
                ),
              ),
            
              SizedBox(height: height * 0.02),
              selectedImage == null
                  ? GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Center(
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: width * 0.4,
                            height: width * 0.4,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.deepOrange, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                    // color: const Color.fromARGB(255, 237, 237, 237),
                            
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, color: Colors.deepOrange),
                                  SizedBox(height: height * 0.03),
              Text("Select Item Image ",style: TextStyle(fontSize: 9,fontWeight:FontWeight.bold,color: Colors.deepOrange),overflow: TextOverflow.ellipsis,),
                              ],
                            )
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: width * 0.4,
                          height: width * 0.4,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(selectedImage!, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: height * 0.03),
              Material(
                elevation: 7,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(width * 0.025),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepOrange),
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 237, 237, 237),
                  ),
                  child: Column(
                    children: [
                      buildInputField("Item Name", namecontroller, 1, width),
                      buildInputField("Item Price", pricecontroller, 1, width),
                      buildInputField("Ready In (Minutes)", timecontroller, 1, width),

                      buildInputField("Item Detail", detailcontroller, 6, width),
                      buildDropdown(width),
                      SizedBox(height: height * 0.03),
                      buildSubmitButton(width, height)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller, int maxLines, double width) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 10.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepOrange)
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter $label",
              ),
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget buildDropdown(double width) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Category"),
          SizedBox(height: 20.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepOrange)

            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                items: fooditems.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Center(child: Text(item, style: TextStyle(fontSize: 18.0, color: Colors.black))),
                )).toList(),
                onChanged: ((val) => setState(() => value = val)),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(20),
                hint: Text("Select Category"),
                iconSize: 36,
                icon: Icon(Icons.arrow_drop_down, color: Colors.deepOrange),
                value: value,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildSubmitButton(double width, double height) {
    return GestureDetector(
      onTap: isUploading ? null : uploadItem,
      child: Center(
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: width * 0.5,
            padding: EdgeInsets.symmetric(vertical: height * 0.02),
            decoration: BoxDecoration(
              color: isUploading ? Colors.grey : Colors.deepOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isUploading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Uploading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.045,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rice_bowl, color: Colors.white),
                        Text(
                          '  Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.05,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class DatabaseMethods {
  addFoodItem(Map<String, dynamic> addItem, String name) async {
    return await FirebaseFirestore.instance.collection(name).add(addItem);
  }
}
