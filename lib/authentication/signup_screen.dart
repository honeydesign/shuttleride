import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shuttleride/pages/dashboard.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';
// import 'package:get/utils.dart';
// import 'package:shuttleride/authentication/login_screen.dart';
// import 'package:shuttleride/methods/common_methods.dart';
// import 'package:shuttleride/pages/dashboard.dart';
// import 'package:shuttleride/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}



class _SignUpScreenState extends State<SignUpScreen>
{
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController VehiclePlateNumberTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlOfUploadedImage = "";

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);
    
    if(imageFile != null) // image validation
      {
        uploadImageToStorage();
        signUpFormValidation();
      }
    else 
      {
        cMethods.displaySnackBar("Please choose an Image first.", context);
      }

  }
  
  uploadImageToStorage() async
  {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });

  }
  
  signUpFormValidation()
  {
    if(userNameTextEditingController.text.trim().length < 3)
    {
      cMethods.displaySnackBar("Your name must be at least 4 or more characters.", context);
    }
    else if(phoneNumberTextEditingController.text.trim().length < 11)
    {
      cMethods.displaySnackBar("Please write valid email.", context);
    }
    else if(!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Please write valid email.", context);
    }
    else if(passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("Your password must be at least 6 or more characters.", context);
    }
    else if(VehiclePlateNumberTextEditingController.text.isEmpty)
    {
      cMethods.displaySnackBar("Please write your plate number.", context);
    }
    else
    {
      uploadImageToStorage();
      registerNewUser();
    }
  }

  registerNewUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registering your account..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg)
        {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap =
    {
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    usersRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c)=> Dashboard()));

  }

  chooseImageFromGallery() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pickedFile!= null)
    {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }



  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20,90,20,20),
          child: Column(
            children: [

              const SizedBox(
                height: 60,
              ),

              imageFile == null ?
              CircleAvatar(
              backgroundImage: AssetImage("assets/images/avatarman.png"),
              radius: 66,
            ) : Container(
                width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: FileImage(
                        File(
                          imageFile!.path,
                        )
                      )
                    )
                  ),
              ),

              const SizedBox(
                height: 30,
              ),


                GestureDetector(
                  onTap: ()
                    {
                      chooseImageFromGallery();
                      },
                  child: const Text(
                  "Choose Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ),


              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        labelStyle: TextStyle(
                          fontSize: 14
                        ),

                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextFormField(
                        controller: phoneNumberTextEditingController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          // for below version 2 use this
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
// for version 2 and greater you-can also use this
                          FilteringTextInputFormatter.digitsOnly

                        ],
                        decoration: InputDecoration(
                            labelText: "Phone number",
                        )
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                            fontSize: 14
                        ),

                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Create Password",
                        labelStyle: TextStyle(
                            fontSize: 14
                        ),

                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: VehiclePlateNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Plate Number",
                        labelStyle: TextStyle(
                            fontSize: 14
                        ),

                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    ElevatedButton(
                      onPressed: ()
                      {
                        checkIfNetworkIsAvailable();
                        },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 80)
                      ),
                      child: const Text(
                        "Sign Up"
                      ),
                    ),

                  ],
                ),
              ),

              //textbutton
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
                child: const Text(
                  "Already have an Account? Login Here",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
