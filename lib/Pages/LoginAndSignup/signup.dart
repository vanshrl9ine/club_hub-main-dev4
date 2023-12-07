import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_hub/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../services/auth.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  late ScaffoldMessengerState scaffoldMessenger;
  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 105, 104, 104),
                  Color.fromARGB(255, 62, 62, 62),
                  Colors.black
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[

                Row(
                  children: [
                    SizedBox(
                      width: size.width * 0.12,
                    ),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: size.width * 0.8,
                  height: 50,
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 150, 150, 150),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        )),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width * 0.8,
                  height: 50,
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 150, 150, 150),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        )),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width * 0.8,
                  height: 50,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 150, 150, 150),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        )),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text == '') {
                        scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Enter your name!')));
                      }
                      else {
                        // Check if email bar is empty
                        if(emailController.text.isEmpty)
                        {
                          scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Email field cannot be empty')));

                        }
                        // Check if the email is from lnmiit.ac.in
                        else if (!emailController.text.endsWith('@lnmiit.ac.in')) {
                          scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Sign up is only allowed with @lnmiit.ac.in email addresses')));
                        }
                        else if(passwordController.text.isEmpty)
                        {
                          scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Password field cannot be empty')));
                        }
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(child: CircularProgressIndicator());
                            },
                          );
                        }

                        String val = await Auth.signupUser(
                          emailController.text,
                          passwordController.text,
                          nameController.text,
                        );

                        if (context.mounted) Navigator.pop(context);

                        if (val == 'success') {
                          // Check if email is verified
                          User user = FirebaseAuth.instance.currentUser!;

                          if (user.emailVerified) {
                            // Automatically sign in the user
                            await Auth.signinUser(emailController.text, passwordController.text);

                            // Proceed to home page
                            String ptype = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get()
                                .then((value) => value.data()!['profileType'].toString());

                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(
                                    currentIndex: 1,
                                    profileType: ptype,
                                  ),
                                ),
                              );
                            }

                            val = 'Registration Successful';
                          } else {
                            // If email is not verified, show a message and sign out the user
                            val = 'Registration Successful. Please verify your email.';
                            await Auth.logout();
                            Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => LoginPage()),);
                          }
                        }
                        if(val.toString()=="[firebase_auth/email-already-in-use] The email address is already in use by another account.")
                        {
                          val = 'The email address is already in use by another account.';
                        }
                        else if(val.toString()=="[firebase_auth/channel-error] Unable to establish connection on channel.")
                        {
                          val = 'Unable to establish connection on channel.';
                        }
                        scaffoldMessenger.showSnackBar(SnackBar(content: Text(val.toString())));
                        // print(Text(val.toString()));
                        // print('***************************************************');
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),



                ),
                const SizedBox(
                  height: 20,
                ),

                SizedBox(height: size.height * 0.1),
                Container(
                  color: const Color.fromARGB(255, 62, 62, 62),
                  width: size.width,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Already have an account ?',
                        style: TextStyle(color: Colors.white,

                          fontSize: 18,),

                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }


}