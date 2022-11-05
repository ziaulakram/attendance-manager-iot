import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:email_validator/email_validator.dart';
import '../main.dart';
import '../utils.dart';

class SignUpWidget extends StatefulWidget {

  final VoidCallback onClickedSignIn;

  const SignUpWidget({Key? key, required this.onClickedSignIn}) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future signUp() async{

    final isValid = formKey.currentState!.validate();
    if(!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context)=> Center(child: CircularProgressIndicator(),),);
    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
      ).then((value) {

        FirebaseFirestore.instance.collection('users').doc(value.user!.uid).set({
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
        });
        throw 'Account created successfully';
      }
      );
      //print(userCredential);
    } on FirebaseAuthException catch (e) {
      //print(e);
      Utils.showSnackBar(e.message!);
    }
    navigatorKey.currentState!.popUntil((route)=>route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text('Register',style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold),),
              //child: Icon(Icons.person_add_alt_1_outlined, size: 100, color: Colors.blue,),
              padding: EdgeInsets.fromLTRB(0, 80, 0, 20),
            ),
            Container(
              // child: Text('Sign Up',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              child: Image.asset('assets/images/register.png', width: 260, height: 260,),
              //padding: EdgeInsets.fromLTRB(0, 120, 0, 20),
            ),
            const SizedBox(height: 20,),
            TextFormField(
              cursorColor: Colors.white,
              controller: usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: UnderlineInputBorder(),
                labelText: 'Name',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (username) {
                if (username == null || username.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              cursorColor: Colors.white,
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                border: UnderlineInputBorder(),
                labelText: 'Email',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) {
                if (email == null || email.isEmpty) {
                  return 'E-mail field cannot be empty';
                }
                if(!EmailValidator.validate(email)){
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              cursorColor: Colors.white,
              controller: passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                border: UnderlineInputBorder(),
                labelText: 'Password',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value)=> value!= null && value.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  //minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.arrow_circle_right_outlined,size: 32,),
                label: const Text('Sign Up',style: TextStyle(fontSize: 24),),
                onPressed: signUp,
              ),
            ),
            SizedBox(height: 60,),
            RichText(text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 20),
                text: 'Have an account? ',
                children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()..onTap = widget.onClickedSignIn,
                      text: 'Log In',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                  )
                ]
            ))
          ],
        ),
      ),
    );
  }
}
