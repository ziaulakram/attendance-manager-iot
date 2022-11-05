import 'package:attendance/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:email_validator/email_validator.dart';
import 'package:attendance/screen/forgotpassword.dart';
import 'package:attendance/utils.dart';
import '../main.dart';

class LoginWidget extends StatefulWidget {

  final VoidCallback onClickedSignUp;

  const LoginWidget({Key? key, required this.onClickedSignUp}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future signIn() async{

    final isValid = formKey.currentState!.validate();
    if(!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context)=> Center(child: CircularProgressIndicator(),),);
    try{

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );
      //print(userCredential);
    } on FirebaseAuthException catch (e) {
      // var errorMessage = e.message;
      // var snackBar = SnackBar(content: Text(errorMessage!),backgroundColor: Colors.red,);
      // return ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              child: Text(
                'Attendance Manager',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              padding: EdgeInsets.fromLTRB(0, 80, 0, 40),
            ),
            Container(
              child: Image.asset('assets/images/login.png', width: 260, height: 260,),
              //padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            ),
            const SizedBox(height: 20,),
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
                  return 'Please enter some text';
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
                prefixIcon: Icon(Icons.lock_outline),
                border: UnderlineInputBorder(),
                labelText: 'Password',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value)=> value!= null && value.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  //minimumSize: const Size.fromHeight(50),

                ),

                icon: const Icon(Icons.lock_open,size: 32,),
                label: const Text('Sign In',style: TextStyle(fontSize: 24),),
                onPressed: signIn,
              ),
            ),
            SizedBox(height: 60,),
            GestureDetector(
              child: Text('Forgot Password?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                decoration: TextDecoration.underline,
                fontSize: 20,
              ),
              ),
              onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ForgotPasswordPage())),
            ),
            SizedBox(height: 14,),
            RichText(text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 20),
              text: 'Don\'t have an account? ',
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()..onTap = widget.onClickedSignUp,
                  text: 'Sign Up',
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
