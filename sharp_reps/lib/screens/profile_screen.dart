import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late var imageUrl;
late var userfirstname;
late var userlastname;
late var useremail;
late var usergender;
late var usernumber;
late var username;

// import '../components/exercise_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final double coverHeight = 220;
  final double profileHeight = 120;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance
          .userChanges()
          .first, // On any user data changes rerun the builder and pull in the new data
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot userSnapshot) {
            imageUrl = userSnapshot.data?.data()?['image_url'];
            username = userSnapshot.data?.data()?['username'];
            useremail = userSnapshot.data?.data()?['email'];
            userfirstname = userSnapshot.data?.data()?['first name'];
            userlastname = userSnapshot.data?.data()?['last name'];
            usernumber = userSnapshot.data?.data()?['number'];
            usergender = userSnapshot.data?.data()?['gender'];

            if (userSnapshot.connectionState == ConnectionState.waiting ||
                imageUrl == '' ||
                userSnapshot.hasError)
              return const Center(
                child:
                    CircularProgressIndicator(), // show loading spinner when retrieving data
              );

            final top = coverHeight - profileHeight / 2;
            return Scaffold(
              // appBar: AppBar(
              //   title: Text("Profile"),
              //   actions: <Widget>[
              //     DropdownButton(
              //         underline: Container(),
              //         icon: Icon(
              //           Icons.more_vert,
              //           color: Theme.of(context).colorScheme.secondary,
              //         ),
              //         items: [
              //           DropdownMenuItem(
              //             value: 'logout',
              //             child: Row(
              //               children: <Widget>[
              //                 Icon(
              //                   Icons.exit_to_app,
              //                   color:
              //                       Theme.of(context).colorScheme.onSecondary,
              //                 ),
              //                 SizedBox(
              //                   width: 8,
              //                 ),
              //                 Text('Logout'),
              //               ],
              //             ),
              //           ),
              //         ],
              //         onChanged: (itemidentifier) {
              //           if (itemidentifier == 'logout') {
              //             FirebaseAuth.instance.signOut();
              //           }
              //         })
              //   ],
              // ),

              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 45,
                        left: 25,
                        right: 25,
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: profileHeight / 2.5,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            backgroundImage: AssetImage(
                              "assets/images/app_loading_icon.png",
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Profile',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 70,
                          ),
                          IconButton(
                            onPressed: () => FirebaseAuth.instance.signOut(),
                            icon: Icon(
                              Icons.exit_to_app,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stack(
                    //   alignment: Alignment.center,
                    //   clipBehavior: Clip.none,
                    //   children: [
                    // Container(
                    //   color: Colors.black,
                    //   child: Image.asset(
                    //     "assets/images/app_icon.png",
                    //     width: double.infinity,
                    //     height: coverHeight,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    // Positioned(
                    //   top: top,
                    //   child:
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                          radius: profileHeight / 2.5,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          backgroundImage: NetworkImage(imageUrl)),
                    ),
                    // ),
                    //   ],
                    // ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: profileHeight / 2 + 15,
                        left: 15,
                        right: 15,
                      ),
                      child: Card(
                        shape: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Username: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    '$username',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        left: 15,
                        right: 15,
                      ),
                      child: Card(
                        shape: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Email: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    '$useremail',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        left: 15,
                        right: 15,
                      ),
                      child: Card(
                        shape: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Number: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    '$usernumber',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        left: 15,
                        right: 15,
                      ),
                      child: Card(
                        shape: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'First Name: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    '$userfirstname',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        left: 15,
                        right: 15,
                      ),
                      child: Card(
                        shape: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Last Name: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    '$userlastname',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        left: 15,
                        right: 15,
                      ),
                      child: Card(
                        shape: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Gender: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    '$usergender',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Widget buildCoverImage() => Container(
      color: Colors.black,
      child: Column(
        children: [Image.network(imageUrl)],
      ),
      width: double.infinity,
      height: 60,
    );

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// final user = FirebaseAuth.instance.currentUser!;
// final db = FirebaseFirestore.instance;

// class ProfileScreen extends StatefulWidget {
//   ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {

//   Future<Query<Map<String, dynamic>>> getprofile() async {
//   var userCollection = await db.collection("users").where("id", isEqualTo: user);

//   return userCollection;
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.secondary,
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: <Widget>[
//           DropdownButton(
//               underline: Container(),
//               icon: Icon(
//                 Icons.more_vert,
//                 color: Theme.of(context).colorScheme.secondary,
//               ),
//               items: [
//                 DropdownMenuItem(
//                   value: 'logout',
//                   child: Row(
//                     children: <Widget>[
//                       Icon(
//                         Icons.exit_to_app,
//                         color: Theme.of(context).colorScheme.onSecondary,
//                       ),
//                       SizedBox(
//                         width: 8,
//                       ),
//                       Text('Logout'),
//                     ],
//                   ),
//                 ),
//               ],
//               onChanged: (itemidentifier) {
//                 if (itemidentifier == 'logout') {
//                   FirebaseAuth.instance.signOut();
//                 }
//               })
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           child: Text("$")
//                         ),
//                         SizedBox(
//                           width: 10,
//                           height: 20,
//                         ),
//                         Text('Username'),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     child: Text('Profile First Name'),
//                     height: 20,
//                     width: 200,
//                     color: Colors.amber,
//                     margin: EdgeInsets.all(5),
//                   ),
//                   Text('Profile Last Name'),
//                   Text('Username'),
//                   Text('email'),
//                   Text('number'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget buildCoverImage() => Container(
//   //       color: Theme.of(context).colorScheme.secondary,
//   //       child: Image.network(),
//   //     );
// }
