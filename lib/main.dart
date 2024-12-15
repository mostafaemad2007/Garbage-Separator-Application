import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Home Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'sign_up.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,

);
  runApp(MyApp());
}


// Constants
const mainColor=Color(0xff1c7c54);
const bgcolor= Color(0xff73e2a7);
const textColor1= Color(0xffdef4c6);
const textColor2= Color(0xff1c7c54);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Sign_in());
  }
}


class Sign_in extends StatelessWidget {
  const Sign_in({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Garbage Separator',
      home: Scaffold(
        resizeToAvoidBottomInset : false,
        backgroundColor: bgcolor,
        // App Bar
        appBar: AppBar(
          title: const Center(child: Text(
            "Garbage Separator", 
            style: TextStyle(fontSize: 30,fontFamily: "Times New Roman", color: textColor1,fontWeight:FontWeight.bold),
          ),),
          backgroundColor: mainColor,
        ),
        // Body of the application
        body: Center(child: Column( children: [
              Container(
                child: Text("Sign in", 
                style: TextStyle(fontSize: 25,fontFamily: "Times New Roman",color: textColor2,fontWeight:FontWeight.bold),),
                margin: const EdgeInsets.all(5),
              ),
              // Application Logo
              Container(
                height: 326,
                width: 408,
                margin: const EdgeInsets.all(15),
                child: Image.asset('images/Logo.png'),
              ),
              
              // email text field
              Container(
                height: 45,
                width: 410,
                color: Colors.white,
                margin: EdgeInsets.all(5),
                child: TextField(
                  controller: emailTextField,
                  decoration: InputDecoration(
                    labelText: "Email", labelStyle: TextStyle(color: textColor2),
                    hintText: "*****@gmail.com", hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  
                ),),
              
              // Password text field
              Container(
                height: 45,
                width: 410,
                color: Colors.white,
                margin: EdgeInsets.all(5),
                child: TextField(
                  controller: passwordTextField,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Password", labelStyle: TextStyle(color: textColor2),
                    border: OutlineInputBorder(),
                  ),
                ),),
              // Sign in Button
              Container(
                child: Builder( builder: (BuildContext context) {
                  return TextButton(
                  onPressed: ()async{
                    String? account_pass= await getPasswordFromFirebase(emailTextField.text);
                    if (!isEmailValid(emailTextField.text))
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Invalid Email'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    emailTextField.clear();
                                    passwordTextField.clear();
                                  },
                                ),
                              ),
                            );
                    }
                    else if (account_pass==passwordTextField.text){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GarbageSeparatorApp()));
                    }
                    else if (account_pass== null)
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('This email does not exist. Please create an account.'),
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
                    else if (account_pass== "There is an Error. Something wrong happened. Print try again.")
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('An error happended. Please try again.'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    emailTextField.clear();
                                    passwordTextField.clear();
                                  },
                                ),
                              ),
                            );
                    }
                    else 
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Incorrect Password. Please try again.'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    passwordTextField.clear();
                                  },
                                ),
                              ),
                            );
                    }
                  },
                  child: Text("Sign in", style:TextStyle(color: mainColor,fontSize: 15,),) , 
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
                  ),
                );
                }
                )
              ),
              // Sign Up
              Container(
                margin: EdgeInsets.all(10),
                child: Row(children: [
                  Center(child: Row(children: [
                    Container(margin: EdgeInsets.all(5),child: Text("Don't have an account: ")),
                    Container(margin: EdgeInsets.all(5),
                    child: TextButton(child: Text("Create Account", style: TextStyle(color: mainColor,
                    fontSize: 15,decoration: TextDecoration. underline,),), 
                    style: TextButton.styleFrom(
                  ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddUser("","")),),
                    ))
                  ],)),
                  
                ],),
              ),
            ],
          ),),
        ),
    );
  }
}