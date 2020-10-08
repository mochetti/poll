import '../helper/helperfunctions.dart';
import '../helper/theme.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../views/forgot_password.dart';
import '../widget/widget.dart';
import '../views/menu.dart';
import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn(this.toggleView);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();

  AuthService authService = new AuthService();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  signIn(int method) async {
    setState(() {
      isLoading = true;
    });

    switch (method) {
      case 0: // email and password
        if (formKey.currentState.validate()) {
          await authService
              .signInWithEmailAndPassword(
                  emailEditingController.text, passwordEditingController.text)
              .then((result) async {
            if (result != null) {
              userQuery = await DatabaseMethods()
                  .getUserInfo(emailEditingController.text);

              // HelperFunctions.saveUserLoggedInSharedPreference(true);
              // HelperFunctions.saveUserNameSharedPreference(
              //     userInfoSnapshot.docs[0].data()["userName"]);
              // HelperFunctions.saveUserEmailSharedPreference(
              //     userInfoSnapshot.docs[0].data()["userEmail"]);

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Menu()));
            } else {
              setState(
                () {
                  isLoading = false;
                  //show snackbar
                },
              );
            }
          });
        }
        break;

      case 1: // facebook

        break;

      case 2: // google
        await authService.signInWithGoogle(context).then((result) async {
          if (result != null) {
            QuerySnapshot userInfoSnapshot = await DatabaseMethods()
                .getUserInfo(emailEditingController.text);
            // HelperFunctions.saveUserLoggedInSharedPreference(true);
            // HelperFunctions.saveUserNameSharedPreference(
            //     userInfoSnapshot.docs[0].data()["userName"]);
            // HelperFunctions.saveUserEmailSharedPreference(
            //     userInfoSnapshot.docs[0].data()["userEmail"]);

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Menu()));
          } else {
            setState(
              () {
                isLoading = false;
                //show snackbar
              },
            );
          }
        });
        break;

      case 3: // anonymously
        await authService.signInAnonymously().then((result) async {
          if (result != null) {
            QuerySnapshot userInfoSnapshot = await DatabaseMethods()
                .getUserInfo(emailEditingController.text);
            // HelperFunctions.saveUserLoggedInSharedPreference(true);
            // HelperFunctions.saveUserNameSharedPreference(
            //     userInfoSnapshot.docs[0].data()["userName"]);
            // HelperFunctions.saveUserEmailSharedPreference(
            //     userInfoSnapshot.docs[0].data()["userEmail"]);

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Menu()));
          } else {
            setState(
              () {
                isLoading = false;
                //show snackbar
              },
            );
          }
        });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Spacer(),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Please Enter Correct Email";
                          },
                          controller: emailEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("email"),
                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (val) {
                            return val.length > 6
                                ? null
                                : "Enter Password 6+ characters";
                          },
                          style: simpleTextStyle(),
                          controller: passwordEditingController,
                          decoration: textFieldInputDecoration("password"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()));
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "Forgot Password?",
                              style: simpleTextStyle(),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      signIn(0);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff007EF4),
                              const Color(0xff2A75BC)
                            ],
                          )),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Sign In",
                        style: biggerTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          signIn(1);
                        },
                        child: Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/logos/facebook.png'),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          signIn(2);
                        },
                        child: Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage('assets/images/logos/google.png'),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          signIn(3);
                        },
                        child: Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage('assets/images/anonymously.png'),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have account? ",
                        style: simpleTextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "Register now",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
    );
  }
}
