// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:inventory_management_system/services/database_helper.dart';
import 'package:inventory_management_system/views/register_screen.dart';
import 'package:inventory_management_system/widgets/custom_elevated_button.dart';
import 'package:crypto/crypto.dart'; // Add this to use sha256 for hashing
import 'dart:convert'; // for utf8 encoding

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscureText = true;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Password hashing function
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Function to handle login
  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      final user = await _dbHelper.queryUserByEmail(_email);

      if (user != null) {
        // Hash the entered password before comparison
        if (user['password'] == hashPassword(_password)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful!')),
          );
          // Navigate to dashboard or another screen
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid credentials')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _loginUi()),
    );
  }

  Widget _loginUi() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headingUi(),
            _loginFormUi(),
          ],
        ),
      ),
    );
  }

  Widget _headingUi() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 50.0),
        Text(
          "LOGIN",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Welcome to Inventory Management System",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  Widget _loginFormUi() {
    return Padding(
      padding: EdgeInsets.only(top: 60.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextFormField(
              initialValue: "annu@gmail.com",
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (value) => _email = value,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your email' : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black87,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black87,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black87,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              "Password",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextFormField(
              initialValue: "12345",
              obscureText: _obscureText,
              onChanged: (value) => _password = value,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your password' : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 40.0),
            _loginButton(),
            SizedBox(width: 30.0),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return RegisterScreen();
                }));
              },
              child: Text(
                "Not Registered | Create your account",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return CustomElevatedButton(
      buttonText: 'Login',
      onPressed: _loginUser,
    );
  }
}
