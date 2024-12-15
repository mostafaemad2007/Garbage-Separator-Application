import 'package:application/main.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,

);
}

// Constants
const mainColor=Color(0xff1c7c54);
const bgcolor= Color(0xff73e2a7);
const textColor1= Color(0xffdef4c6);
const textColor2= Color(0xff1c7c54);

// Input Variables
TextEditingController newEmailTextField = TextEditingController();
TextEditingController newPasswordTextField = TextEditingController();
TextEditingController ConfirmPasswordTextField = TextEditingController();
TextEditingController newMachineNumber = TextEditingController();

/// Functions
bool isEmailValid(String s) {
  s = s.trim(); // Remove leading and trailing whitespaces
  if (s.length < 11) return false;
  return s.endsWith('@gmail.com');
}


class AddUser extends StatelessWidget {
  final String email;
  final String password;

  AddUser(this.email, this.password);

  @override
  Widget build(BuildContext context) {
    // Create a CollectionReference called users that references the firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset : false,
        backgroundColor: bgcolor,
        appBar: AppBar(
          title: const Center(child: Text(
            "Garbage Separator", style: TextStyle(fontSize: 30,fontFamily: "Times New Roman", color: textColor1,fontWeight:FontWeight.bold),
          ),),
          backgroundColor: mainColor,
        ),
        body: Center(child: Column( children: [
              Container(
                child: Text("Sign up", style: TextStyle(fontSize: 25,fontFamily: "Times New Roman",color: textColor2,fontWeight:FontWeight.bold),),
                margin: const EdgeInsets.all(5),
              ),
              // Application Logo
              Container(
                height: 326,
                width: 408,
                margin: const EdgeInsets.all(15),
                child: Image.asset('images/Logo.png'),
              ),
              /// Email Text Field
              Container(
                height: 45,
                width: 410,
                color: Colors.white,
                margin: EdgeInsets.all(5),
                child: TextField(
                  controller: newEmailTextField,
                  decoration: InputDecoration(
                    labelText: "Email", labelStyle: TextStyle(color: textColor2),
                    hintText: "*****@gmail.com", hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
              ),),
              /// Password Text Field
              Container(
                height: 45,
                width: 410,
                color: Colors.white,
                margin: EdgeInsets.all(5),
                child: TextField(
                  controller: newPasswordTextField,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Password", labelStyle: TextStyle(color: textColor2),
                    border: OutlineInputBorder(),
                    hintText: "It must be at least 8 characters. Make it a string password.", hintStyle: TextStyle(color: Colors.grey),
                  ),
              ),),
              /// Confirm Password Text Field
              Container(
                height: 45,
                width: 410,
                color: Colors.white,
                margin: EdgeInsets.all(5),
                child: TextField(
                  controller: ConfirmPasswordTextField,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Confirm Password", labelStyle: TextStyle(color: textColor2),
                    border: OutlineInputBorder(),
                  ),
              ),),
              /// Machine Number Text field
              Container(
                height: 45,
                width: 410,
                color: Colors.white,
                margin: EdgeInsets.all(5),
                child: TextField(
                  controller: newMachineNumber,
                  decoration: InputDecoration(
                    labelText: "The Code of one of your Machines", labelStyle: TextStyle(color: textColor2),
                    hintText: "*****", hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
              ),),
              /// Create account button
              Container(
                child: Builder(
                    builder: (BuildContext context) {
                      return TextButton(
                        onPressed: () {
                          if (!isEmailValid(newEmailTextField.text))
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Invalid Email'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    newEmailTextField.clear();
                                    newPasswordTextField.clear();
                                    ConfirmPasswordTextField.clear();
                                  },
                                ),
                              ),
                            );
                          }
                          else if (newPasswordTextField.text.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Your Password must be at least 8 Characters'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    newPasswordTextField.clear();
                                    ConfirmPasswordTextField.clear();
                                  },
                                ),
                              ),
                            );
                          }
                          else if (newPasswordTextField.text!= ConfirmPasswordTextField.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('The two passwords must be the same'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    newPasswordTextField.clear();
                                    ConfirmPasswordTextField.clear();
                                  },
                                ),
                              ),
                            );
                          }
                          else if (newMachineNumber.text== "")
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Machine Code Text Field must not be empty'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {},
                                ),
                              ),
                            );
                          }
                          else 
                          {
                            users.doc(newEmailTextField.text).set({'Email':newEmailTextField.text, 'Password':newPasswordTextField.text, 'Machines': [newMachineNumber.text]})
                            .then((value)  {
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Account Created Successfully. Wait for a minute and then sign in.'),
                                action: SnackBarAction(
                                  label: 'Sign in',
                                  onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));},
                                ),
                              ),
                            );
                            })
                            .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Something went wrong. Please try again.'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    newEmailTextField.clear();
                                    newPasswordTextField.clear();
                                    ConfirmPasswordTextField.clear();
                                    newMachineNumber.clear();
                                  },
                                ),
                              ),
                            ));
                          }
                        },
                        child: Text("Create the Account"),
                      );
                    },
                  ),
                )
        ]),
      ),
    ),
    );
  }
}