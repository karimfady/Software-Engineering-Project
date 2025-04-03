class LoginLogic {
  void handleLogin(String email, String password) {
    // Here you can connect to an API, validate fields, etc.
    if (email.isEmpty || password.isEmpty) {
      print("Please fill in all fields.");
    } else {
      print("in loginhandle");
      // send query with name and password to the database if the username
      //doesnt exist print user doesnt exist if user exist but password is
      //incorrect print passwrod is incorrect
    }
  }

  void handleregisteration(
    String name,
    String email,
    String password,
  ) // add other parameters
  {
    if (email.isEmpty || password.isEmpty) {
      print("Please fill in all fields.");
    } else {
      // if send a query with the name and if it exists then say username is not
      // avaialbe if it doesnt exist then add the user to the database
    }
  }
}
