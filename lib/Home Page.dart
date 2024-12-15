import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Constants
const mainColor = Color(0xff1c7c54);
const bgcolor = Color(0xff73e2a7);
const textColor1 = Color(0xffdef4c6);
const textColor2 = Color(0xff1c7c54);

// Collection reference
final machinesCollection = FirebaseFirestore.instance.collection('Machines');
final account_ur = FirebaseFirestore.instance.collection('users');

// Global variables
final TextEditingController emailTextField = TextEditingController();
final TextEditingController addMachineCode = TextEditingController();
TextEditingController passwordTextField = TextEditingController();
List<String> machineCodes = []; // Store machine codes




// Function to fetch user machines
Future<void> fetchUserMachines(BuildContext context, String email) async {
  try {
    // Query Firestore to find the document with matching email
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the first matching document
      final userDoc = querySnapshot.docs.first;

      // Extract the Machines list
      machineCodes =
          List<String>.from(userDoc.get('Machines') ?? []); // Ensure it's a list of strings

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please refresh the page. To see the latest updates.')),
      );
    } else {
      // No user found
      machineCodes.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user found with this email')),
      );
    }
  } catch (e) {
    // Error handling
    print('Error fetching user machines: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error retrieving machines')),
    );
  }
}

// Function to fetch machine data from Firestore
Future<Map<String, dynamic>> fetchMachineData(String machineCode) async {
  try {
    final docSnapshot = await machinesCollection.doc(machineCode).get();
    return docSnapshot.data() as Map<String, dynamic>;
  } catch (e) {
    print('Error fetching machine data: $e');
    
    return {}; // Return empty map on error
  }
}

// Function to fetch password of a user
Future<String?> getPasswordFromFirebase(String documentId) async {
  try {
    // Get reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the specific document in the 'users' collection
    DocumentSnapshot documentSnapshot = await firestore
        .collection('users')
        .doc(documentId)
        .get();

    // Check if the document exists
    if (documentSnapshot.exists) {
      // Retrieve the password field
      String? password = documentSnapshot.get('Password');
      
      // You might want to add additional null checks or error handling
      return password;
    } else {
      return null;
    }
  } catch (e) {
    // Handle any errors that occur during retrieval
    print('Error retrieving password: $e');
    return "There is an Error. Something wrong happened. Print try again.";
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GarbageSeparatorApp());
}

class GarbageSeparatorApp extends StatelessWidget {
  const GarbageSeparatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbage Separator',
      theme: ThemeData(
        primaryColor: mainColor,
        scaffoldBackgroundColor: bgcolor,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Automatically fetch machines when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserMachines(context, emailTextField.text); // Replace with your default email
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Garbage Separator",
            style: TextStyle(
              fontSize: 30,
              fontFamily: "Times New Roman",
              color: textColor1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: mainColor,
      ),
      body: Column(
        children: [
          // Refreshing application
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GarbageSeparatorApp()),);
            },
            child: const Text('Refresh'),
          ),
          /// New Machine Number Text field
              Container(
                height: 45,
                width: 410,
                color: Colors.white,
                margin: EdgeInsets.all(5),
                child: TextField(
                  controller: addMachineCode,
                  decoration: InputDecoration(
                    labelText: "Add a Machine Code", labelStyle: TextStyle(color: textColor2),
                    hintText: "*****", hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
              ),),
              TextButton(
                        onPressed: () {
                            machineCodes.insert(machineCodes.length-1,addMachineCode.text);
                            account_ur.doc(emailTextField.text).update({'Machines':machineCodes})
                            .then((value)  {
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Code added. Refresh the page to see changes'),
                                action: SnackBarAction(
                                  label: 'Refresh',
                                  onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GarbageSeparatorApp()),);},
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
                                    addMachineCode.clear();
                                  },
                                ),
                              ),
                            ));
                          
                        },
                        child: Text("Add Machine"),
                      ),

          // List of Machines
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: machineCodes.length,
                itemBuilder: (context, index) {
                  final machineCode = machineCodes[index];
                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchMachineData(machineCode),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final machineData = snapshot.data!;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.centerLeft,
                          height: 200,
                          width: 400,
                          color: textColor1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Machine Code: $machineCode",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Times New Roman",
                                  color: textColor2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Metal: ${machineData['Metal'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontFamily: "Times New Roman",
                                  color: textColor2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Organic: ${machineData['Organic'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontFamily: "Times New Roman",
                                  color: textColor2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Others: ${machineData['Others'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontFamily: "Times New Roman",
                                  color: textColor2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Plastic: ${machineData['Plastic'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontFamily: "Times New Roman",
                                  color: textColor2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Paper: ${machineData['Paper'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontFamily: "Times New Roman",
                                  color: textColor2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              ), 
          ),
        ],
      ),
    );
  }
}