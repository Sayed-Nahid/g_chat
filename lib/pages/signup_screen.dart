import 'package:flutter/material.dart';
import 'package:g_chat/pages/login_screen.dart';
import 'package:g_chat/pages/profile_set_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // [ALL YOUR EXISTING CODE REMAINS UNCHANGED]
  bool isPhoneSelected = true;
  String? selectedCountry;
  bool showSendButton = false;
  bool showVerificationField = false;

  final Map<String, String> countryCodes = {
    'Bangladesh': '+880',
    'Australia': '+61',
    'USA': '+1',
    'India': '+91',
    'UK': '+44',
  };

  // Minimum digits required after country code
  final Map<String, int> countryMinDigits = {
    'Bangladesh': 10,
    'Australia': 9,
    'USA': 10,
    'India': 10,
    'UK': 10,
  };

  late final TextEditingController phoneEmailController;
  late final TextEditingController verificationController;

  @override
  void initState() {
    super.initState();
    selectedCountry = 'Bangladesh';
    phoneEmailController = TextEditingController();
    verificationController = TextEditingController();

    // Set initial country code without triggering validation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPhoneSelected && selectedCountry != null && mounted) {
        final code = countryCodes[selectedCountry]!;
        phoneEmailController.text = code;
        phoneEmailController.selection = TextSelection.collapsed(offset: code.length);
      }
    });

    phoneEmailController.addListener(_handleInputChange);
  }

  bool _validatePhone(String phone) {
    // Must start with country code
    if (!phone.startsWith(countryCodes[selectedCountry]!)) {
      return false;
    }

    // Get digits after country code
    final digits = phone.substring(countryCodes[selectedCountry]!.length);

    // Must contain only numbers
    if (!RegExp(r'^\d+$').hasMatch(digits)) {
      return false;
    }

    // Must meet minimum length for country
    return digits.length >= (countryMinDigits[selectedCountry] ?? 8);
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleInputChange() {
    final input = phoneEmailController.text.trim();
    bool isValid;

    if (isPhoneSelected) {
      // For phone, require full valid number (country code + digits)
      isValid = _validatePhone(input) &&
          input.length > countryCodes[selectedCountry]!.length;
    } else {
      isValid = _validateEmail(input);
    }

    if (mounted) {
      setState(() {
        showSendButton = isValid;
        if (!showSendButton) showVerificationField = false;
      });
    }
  }

  void _onSendPressed() {
    if (mounted) {
      setState(() {
        showVerificationField = true;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onNextPressed() {
    final input = phoneEmailController.text.trim();

    if (isPhoneSelected) {
      if (!_validatePhone(input)) {
        _showError('Please enter a valid ${selectedCountry} phone number');
        return;
      }
    } else {
      if (!_validateEmail(input)) {
        _showError('Please enter a valid email address');
        return;
      }
    }

    if (showVerificationField && verificationController.text.isEmpty) {
      _showError('Please enter verification code');
      return;
    }

    // Proceed with signup
    print('Proceeding with: $input');
  }

  @override
  void dispose() {
    phoneEmailController.dispose();
    verificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelText = isPhoneSelected ? 'Phone Number' : 'Email Address';

    return Scaffold(
      backgroundColor: Colors.transparent, // CHANGE 1: Made transparent
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Kept transparent
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container( // CHANGE 2: Added gradient container
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF343434)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // [ALL YOUR EXISTING WIDGETS REMAIN UNCHANGED]
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ) ?? const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Country/Region Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCountry,
                  decoration: InputDecoration(
                    labelText: 'Country/Region',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  dropdownColor: Colors.grey[900],
                  iconEnabledColor: Colors.white,
                  items: countryCodes.keys.map((country) => DropdownMenuItem(
                    value: country,
                    child: Text(country, style: const TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() {
                        selectedCountry = value;
                        if (isPhoneSelected) {
                          phoneEmailController.text = countryCodes[value]!;
                          phoneEmailController.selection = TextSelection.collapsed(
                            offset: countryCodes[value]!.length,
                          );
                          _handleInputChange();
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: phoneEmailController,
                  keyboardType: isPhoneSelected ? TextInputType.phone : TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: labelText,
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                if (showSendButton)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _onSendPressed,
                      child: const Text(
                        'Send',
                        style: TextStyle(color: Colors.lightBlueAccent),
                      ),
                    ),
                  ),

                if (showVerificationField)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextFormField(
                      controller: verificationController,
                      decoration: InputDecoration(
                        labelText: 'Verification Code',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        isPhoneSelected = !isPhoneSelected;
                        phoneEmailController.clear();
                        verificationController.clear();
                        showSendButton = false;
                        showVerificationField = false;
                        if (isPhoneSelected && selectedCountry != null) {
                          phoneEmailController.text = countryCodes[selectedCountry]!;
                          phoneEmailController.selection = TextSelection.collapsed(
                            offset: countryCodes[selectedCountry]!.length,
                          );
                        }
                      });
                    }
                  },
                  child: Text(
                    isPhoneSelected ? 'Use Email Instead' : 'Use Phone Number Instead',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileSetScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 18),
                    backgroundColor: const Color(0xFF81D8D0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text( // CHANGE 3: Removed manual white color
                    'Next',
                    style: TextStyle(fontSize: 18), // Now uses theme's default
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}