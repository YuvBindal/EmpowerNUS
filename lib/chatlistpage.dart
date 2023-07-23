import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'homePage.dart';
import 'education.dart';

class ChatPage extends StatefulWidget {
  final String username;

  const ChatPage({Key? key, required this.username}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Future<void> callback() async {
    if (messageController.text.length > 0) {
      await FirebaseFirestore.instance.collection('messages').add({
        'text': messageController.text,
        'from': FirebaseAuth.instance.currentUser?.email,
        'to': widget.username,
        'time': FieldValue.serverTimestamp(),
      });
      messageController.clear();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where('to', isEqualTo: widget.username)
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    List<DocumentSnapshot> docs = snapshot.data!.docs;
                    List<Widget> messages = docs
                        .map((doc) => Message(
                      from: doc['from'],
                      text: doc['text'],
                      me: FirebaseAuth.instance.currentUser?.email ==
                          doc['from'],
                    ))
                        .toList();

                    return ListView(
                      controller: scrollController,
                      children: <Widget>[
                        ...messages,
                      ],
                    );
                  }
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) => callback(),
                      decoration: InputDecoration(
                        hintText: "Enter a Message...",
                        border: const OutlineInputBorder(),
                      ),
                      controller: messageController,
                    ),
                  ),
                  SendButton(
                    text: "Send",
                    callback: callback,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            ScreenSize * .02, ScreenHeight * .02, ScreenSize * .02, 0),
        child: FractionallySizedBox(
          widthFactor: 1.2,
          child: Container(
            color: Colors.grey[300],
            height: ScreenHeight * .08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ChatPage(username: widget.username)),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => education_Page()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({required this.text, required this.callback});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.send),
      onPressed: callback,
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;
  final bool me;

  const Message({required this.from, required this.text, required this.me});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
        me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(from),
          Material(
            color: me ? Colors.teal : Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            elevation: 6.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(text),
            ),
          )
        ],
      ),
    );
  }
}

class Chat {
  final String username;
  final String lastMessage;
  final String avatarUrl;

  Chat({
    required this.username,
    required this.lastMessage,
    required this.avatarUrl,
  });
}

List<Chat> chats = [
  Chat(
      username: 'John',
      lastMessage: 'Hello!',
      avatarUrl: 'assets/images/user.png'),
  Chat(
      username: 'Ben',
      lastMessage: 'How are you?',
      avatarUrl: 'assets/images/user.png'),
];

class ChatListPage extends StatelessWidget {
  final List<Chat> chats;

  ChatListPage({required this.chats});

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: // AppBar in ChatListPage:

      AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_comment),
            tooltip: 'New Message',
            onPressed: () {
              // Navigate to the NewMessageScreen1 when this button is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewMessageScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person_search),
            tooltip: 'Add Friends',
            onPressed: () {
              // Navigate to the AddFriendsScreen when this button is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFriendsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            tooltip: 'Friend Requests',
            onPressed: () {
              // Navigate to the AddFriendsScreen when this button is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendRequestsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.people_alt),
            tooltip: 'Friend Requests',
            onPressed: () {
              // Navigate to the AddFriendsScreen when this button is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendListScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(chats[index].avatarUrl),
              ),
              title: Text(chats[index].username),
              subtitle: Text(chats[index].lastMessage),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to chat page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatPage(username: chats[index].username),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            ScreenSize * .02, ScreenHeight * .02, ScreenSize * .02, 0),
        child: FractionallySizedBox(
          widthFactor: 1.2, // Take up the full available width
          child: Container(
            color: Colors.grey[300],
            height: ScreenHeight * .08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ChatListPage(
                            chats: [chats[0], chats[1]],
                          )),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => education_Page()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddFriendsScreen extends StatefulWidget {
  AddFriendsScreen({Key? key}) : super(key: key);

  @override
  _AddFriendsScreenState createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUser = FirebaseAuth.instance.currentUser!.uid;
  String _email = '';

  Future<bool> areAlreadyFriends(String userId1, String userId2) async {
    final querySnapshot = await _firestore
        .collection('friends')
        .where('user1', whereIn: [userId1, userId2]).get();

    final isAlreadyFriend = querySnapshot.docs.any((doc) {
      final user1 = doc['user1'] as String;
      final user2 = doc['user2'] as String;
      return (user1 == userId1 && user2 == userId2) ||
          (user1 == userId2 && user2 == userId1);
    });

    return isAlreadyFriend;
  }

// Sends a friend request
  Future<void> sendFriendRequest(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    print('Query results: ${querySnapshot.docs}');

    if (querySnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user found with that username')),
      );
      return;
    }

    final userDoc = querySnapshot.docs.first;
    final receiverId = userDoc.id;

    if (await areAlreadyFriends(_currentUser, receiverId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are already friends with this user')),
      );
      return;
    }

    // Check if a friend request has already been sent or received
    final friendRequestCheckSent = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: _currentUser)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    final friendRequestCheckReceived = await _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: _currentUser)
        .where('senderId', isEqualTo: receiverId)
        .get();

    if (friendRequestCheckSent.docs.isNotEmpty) {
      final requestStatus = friendRequestCheckSent.docs.first['status'];
      if (requestStatus == 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request already sent!')),
        );
        return;
      }
    }

    if (friendRequestCheckReceived.docs.isNotEmpty) {
      final requestStatus = friendRequestCheckReceived.docs.first['status'];
      if (requestStatus == 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('You have a pending friend request from this user')),
        );
        return;
      }
    }

    await _firestore.collection('friend_requests').add({
      'senderId': _currentUser,
      'receiverId': receiverId,
      'status': 'pending',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friends'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Enter username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    _email = value!;
                  });
                },
              ),
              ElevatedButton(
                child: Text('Add Friend'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Now you can use _email to add the friend
                    sendFriendRequest(_email);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            ScreenSize * .02, ScreenHeight * .02, ScreenSize * .02, 0),
        child: FractionallySizedBox(
          widthFactor: 1.2, // Take up the full available width
          child: Container(
            color: Colors.grey[300],
            height: ScreenHeight * .08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ChatListPage(
                            chats: [chats[0], chats[1]],
                          )),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => education_Page()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUser = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final querySnapshot = await _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: _currentUser)
        .where('status', isEqualTo: 'pending')
        .get();

    final requests = querySnapshot.docs;

    // Fetch each sender's username and add it to the request data
    return Future.wait(requests.map((request) async {
      final senderId = request.data()['senderId'];
      final senderDoc =
      await _firestore.collection('users').doc(senderId).get();

      return {
        ...request.data(),
        'senderUsername': senderDoc.data()?['username'],
        'requestId': request.id,
      };
    }).toList());
  }

  // Function to accept friend request
  Future<void> acceptFriendRequest(String senderId, String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).delete();

    // Add a document to 'friends' collection
    await _firestore.collection('friends').doc().set({
      'user1': _currentUser,
      'user2': senderId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request accepted!')),
    );

    // This will rebuild the widget and refresh the list
    setState(() {});
  }

  // Function to decline friend request
  Future<void> declineFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request declined!')),
    );

    // This will rebuild the widget and refresh the list
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getFriendRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.error != null) {
              return Center(child: Text('Error fetching friend requests'));
            }

            if (snapshot.data!.isEmpty) {
              return Center(child: Text('No friend requests'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final request = snapshot.data![index];

                return ListTile(
                  title:
                  Text('Friend request from ${request['senderUsername']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextButton(
                        child: Text(
                          'Accept',
                          selectionColor: Colors.black,
                        ),
                        onPressed: () {
                          acceptFriendRequest(
                              request['senderId'], request['requestId']);
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Decline',
                          selectionColor: Colors.black,
                        ),
                        onPressed: () {
                          declineFriendRequest(request['requestId']);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            ScreenSize * .02, ScreenHeight * .02, ScreenSize * .02, 0),
        child: FractionallySizedBox(
          widthFactor: 1.2, // Take up the full available width
          child: Container(
            color: Colors.grey[300],
            height: ScreenHeight * .08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ChatListPage(
                            chats: [chats[0], chats[1]],
                          )),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => education_Page()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FriendListScreen extends StatefulWidget {
  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUser = FirebaseAuth.instance.currentUser!.uid;

  Future<List<DocumentSnapshot>> fetchFriends() async {
    List<DocumentSnapshot> friends = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection('friends')
        .where('user1', isEqualTo: _currentUser)
        .get();

    for (var doc in querySnapshot.docs) {
      QuerySnapshot reverseCheck = await _firestore
          .collection('friends')
          .where('user1', isEqualTo: doc['user2'])
          .where('user2', isEqualTo: _currentUser)
          .get();

      if (reverseCheck.docs.isNotEmpty) {
        DocumentSnapshot friendDoc =
        await _firestore.collection('users').doc(doc['user2']).get();
        friends.add(friendDoc);
      }
    }

    return friends;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchFriends(),
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index][
                'username']), // replace 'username' with the field name in your users collection
              );
            },
          );
        },
      ),
    );
  }
}

class NewMessageScreen extends StatefulWidget {
  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final messageController = TextEditingController();
  String dropdownValue = 'Friend 1'; // Initialize to first friend

  Future<void> sendMessage() async {
    if (messageController.text.length > 0) {
      // Implement your message sending logic here.
    }
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Message'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButton<String>(
                value: dropdownValue,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Friend 1', 'Friend 2', 'Friend 3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Enter your message here",
                ),
              ),
              ElevatedButton(
                onPressed: sendMessage,
                child: Text('Send Message'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            ScreenSize * .02, ScreenHeight * .02, ScreenSize * .02, 0),
        child: FractionallySizedBox(
          widthFactor: 1.2, // Take up the full available width
          child: Container(
            color: Colors.grey[300],
            height: ScreenHeight * .08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ChatListPage(
                            chats: [], // Pass the chat list
                          )),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => education_Page()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: ScreenSize * .1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}