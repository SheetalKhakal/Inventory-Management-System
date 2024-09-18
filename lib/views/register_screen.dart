// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables, prefer_final_fields, unused_element

import 'package:flutter/material.dart';
import 'package:inventory_management_system/services/database_helper.dart';
import 'package:inventory_management_system/widgets/custom_elevated_button.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8 encoding

String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  String _password = '';
  String _confirmPassword = '';
  bool _obscureText = false;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final user = {
        'username': _name, // _name is from a TextFormField or controller
        'email': _email, // _email is from a TextFormField or controller
        'phone': _phone, // _phone is from a TextFormField or controller
        'password': hashPassword(_password), // Hash the password before storing
      };

      final id = await _dbHelper.insertUser(user);
      if (id != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _registerUi()),
    );
  }

  Widget _registerUi() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headingUi(),
            _registerFormUi(),
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
        SizedBox(
          height: 10.0,
        ),
        Text(
          "CREATE NEW ACCOUNT",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _registerFormUi() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Name",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextFormField(
                initialValue: "",
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _name = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
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
                "Email",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextFormField(
                initialValue: "",
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
                "Phone No.",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextFormField(
                initialValue: "",
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _phone = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your phone' : null,
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
                initialValue: "",
                obscureText: _obscureText,
                onChanged: (value) => _password = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a password' : null,
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
              SizedBox(height: 20.0),
              Text(
                "Confirm Password",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextFormField(
                initialValue: "",
                obscureText: _obscureText,
                onChanged: (value) => _confirmPassword = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please confirm your password' : null,
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
              SizedBox(height: 20.0),
              _registerButton(),
              SizedBox(
                width: 10.0,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  "Already registered | Login here",
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
      ),
    );
  }

  Widget _registerButton() {
    return CustomElevatedButton(
      buttonText: 'Register',
      onPressed: _registerUser,
    );
  }
}
