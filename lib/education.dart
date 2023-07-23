import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'homePage.dart';


class education_Page extends StatefulWidget {
  @override
  State<education_Page> createState() => _education_PageState();
}

class _education_PageState extends State<education_Page> {
  String? _selectedCategory = 'All';

  Map<String, List<Map<String, String>>> resources = {
    'All': [],
    'Assault': [
      {
        'title': 'Preventing Assault',
        'url': 'https://www.fairview.org/patient-education/116405EN'
      },
      {
        'title': 'Safety and Self-Defence',
        'url':
        'https://www.corporatewellnessmagazine.com/article/smart-safe-self-defense'
      },
    ],
    'Burglary/Robbery/Theft': [
      {
        'title': 'Prevent Home Burglary',
        'url':
        'https://www.safewise.com/home-security-faq/how-to-prevent-burglary/'
      },
      {
        'title': 'Prevent Car Theft',
        'url': 'https://www.nhtsa.gov/road-safety/vehicle-theft-prevention'
      },
    ],
    'Vandalism': [
      {
        'title': 'Prevent Vandalism',
        'url':
        'https://www.ncpc.org/resources/home-property-crime/prevent-auto-theft/'
      },
      {
        'title': 'Vandalism Facts',
        'url':
        'https://www.conserve-energy-future.com/various-vandalism-facts.php'
      },
    ],
    'Fraud': [
      {
        'title': 'Prevent Fraud',
        'url':
        'https://www.ftc.gov/faq/consumer-protection/defend-against-identity-theft'
      },
      {
        'title': 'Understanding Fraud',
        'url':
        'https://www.aarp.org/money/scams-fraud/info-2019/fraud-types.html'
      },
    ],
    'Harassment': [
      {'title': 'Prevent Harassment', 'url': 'https://www.eeoc.gov/harassment'},
      {
        'title': 'Understanding Harassment',
        'url': 'https://www.stopbullying.gov/cyberbullying/what-is-it'
      },
    ],
    'Drug Abuse': [
      {
        'title': 'Understanding Drug Abuse',
        'url':
        'https://www.drugabuse.gov/publications/drugs-brains-behavior-science-addiction/drug-abuse-addiction'
      },
      {
        'title': 'Prevent Drug Abuse',
        'url': 'https://www.cdc.gov/drugoverdose/prevention/index.html'
      },
    ],
    'Others': [
      {
        'title': 'General Safety Tips',
        'url': 'https://www.ready.gov/be-informed'
      },
      {
        'title': 'Preventing Crime',
        'url': 'https://www.crimesolutions.gov/TopicDetails.aspx?ID=63'
      },
    ],
  };

  void launchURL(String urlString) async {
    Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenFont = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
        ),
        title: Text("Education Resources"),
        backgroundColor: Colors.teal,
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: screenHeight * .01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: resources.keys.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
            Container(
              height: screenHeight * 0.7,
              child: ListView.builder(
                itemCount: resources[_selectedCategory!]?.length ?? 0,
                itemBuilder: (context, index) {
                  if (_selectedCategory == 'All') {
                    return ListTile(
                      title: Text(
                          resources[_selectedCategory!]?[index]['title'] ?? ''),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => (resources == null)
                              ? Center(child: CircularProgressIndicator())
                              : SubCategoryPage(
                            category: resources.keys.toList()[index],
                            resources: resources,
                            launchURL: (url) => launchURL(url),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return ListTile(
                      title: Text(
                          resources[_selectedCategory!]?[index]['title'] ?? ''),
                      onTap: () => launchURL(
                          resources[_selectedCategory!]?[index]['url'] ?? ''),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPage(
                category: _selectedCategory!,
                questions: quizQuestions[_selectedCategory!]!,
              ),
            ),
          );
        },
        child: Icon(Icons.quiz_rounded),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class SubCategoryPage extends StatelessWidget {
  final String category;
  final Map<String, List<Map<String, String>>> resources;
  final Function launchURL;

  SubCategoryPage(
      {required this.category,
        required this.resources,
        required this.launchURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: resources[category]?.length ?? 0,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(resources[category]?[index]['title'] ?? ''),
            onTap: () => launchURL(resources[category]?[index]['url'] ?? ''),
          );
        },
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion(
      {required this.question,
        required this.options,
        required this.correctAnswer});
}

Map<String, List<QuizQuestion>> quizQuestions = {
  'Assault': [
    QuizQuestion(
      question: 'What should you do if you are assaulted?',
      options: [
        'Get to a safe place and call 911',
        'Ignore it',
        'Fight back',
        'Reason with the assaulter',
      ],
      correctAnswer: 'Get to a safe place and call 911',
    ),
    QuizQuestion(
      question: 'What is one recommended self-defense method?',
      options: [
        'Trust your instincts and use your voice',
        'Reason with the attacker',
        'Retaliate physically',
        'Run towards secluded areas'
      ],
      correctAnswer: 'Trust your instincts and use your voice',
    ),
    QuizQuestion(
      question: 'What are some preventive measures against assault?',
      options: [
        'Awareness, assertiveness, avoiding risk situations',
        'Taking self-defense classes',
        'Always carry a weapon',
        'Avoid going out'
      ],
      correctAnswer: 'Awareness, assertiveness, avoiding risk situations',
    ),
    QuizQuestion(
      question: 'Should you try to reason with an attacker?',
      options: [
        'Yes',
        'No',
        'Only if you know them',
        'Only if they are unarmed'
      ],
      correctAnswer: 'No',
    ),
    QuizQuestion(
      question: 'True or False: It is recommended to walk alone at night.',
      options: [
        'True',
        'False',
        'Only in well-lit areas',
        'Only in your neighborhood'
      ],
      correctAnswer: 'False',
    ),
  ],
  'Burglary/Robbery/Theft': [
    QuizQuestion(
      question: 'What is an effective way to discourage home burglary?',
      options: [
        'Installing a home security system',
        'Leaving lights on',
        'Putting a "Beware of Dog" sign',
        'Leaving the doors open'
      ],
      correctAnswer: 'Installing a home security system',
    ),
    QuizQuestion(
      question: 'What should you do if your house has been burglarized?',
      options: [
        'Investigate yourself',
        'Clean up the mess',
        'Leave immediately and call the police',
        'Wait for the burglar to return'
      ],
      correctAnswer: 'Leave immediately and call the police',
    ),
    QuizQuestion(
      question: 'How can you help prevent car theft?',
      options: [
        'Leave windows open',
        'Always lock your doors and never leave your car running unattended',
        'Leave car keys in the ignition',
        'Park in dark areas'
      ],
      correctAnswer:
      'Always lock your doors and never leave your car running unattended',
    ),
    QuizQuestion(
      question: 'What can you do to protect yourself from pickpockets?',
      options: [
        'Carry your wallet in your hand',
        'Keep your wallet in a front pocket',
        'Leave your bag open',
        'Flaunt expensive items'
      ],
      correctAnswer: 'Keep your wallet in a front pocket',
    ),
    QuizQuestion(
      question:
      'What is an effective way to protect your personal belongings in a public place?',
      options: [
        'Leave them unattended',
        'Hide them under your chair',
        'Lend them to strangers',
        'Keep your belongings in sight at all times'
      ],
      correctAnswer: 'Keep your belongings in sight at all times',
    ),
  ],
  'Vandalism': [
    QuizQuestion(
      question: 'What should you do if you witness vandalism?',
      options: [
        'Join in',
        'Ignore it',
        'Record it and post it online',
        'Report it to the police'
      ],
      correctAnswer: 'Report it to the police',
    ),
    QuizQuestion(
      question: 'What is a common cause of school vandalism?',
      options: [
        'Peer pressure',
        'Too much homework',
        'Poor cafeteria food',
        'Lack of sports activities'
      ],
      correctAnswer: 'Peer pressure',
    ),
    QuizQuestion(
      question: 'How can community involvement help to reduce vandalism?',
      options: [
        'By fostering a sense of responsibility and belonging',
        'By ignoring the problem',
        'By encouraging competitive vandalism',
        'By blaming outsiders'
      ],
      correctAnswer: 'By fostering a sense of responsibility and belonging',
    ),
    QuizQuestion(
      question:
      'True or False: Cleaning up vandalism promptly can help to deter further vandalism.',
      options: ['True', 'False', 'Sometimes', 'Only on Tuesdays'],
      correctAnswer: 'True',
    ),
    QuizQuestion(
      question: 'How can you help to prevent vandalism in your neighborhood?',
      options: [
        'By reporting suspicious activities to the police',
        'By turning a blind eye',
        'By moving to another neighborhood',
        'By organizing a vandalism party'
      ],
      correctAnswer: 'By reporting suspicious activities to the police',
    ),
  ],
  'Fraud': [
    QuizQuestion(
      question:
      'What is one common method fraudsters use to steal personal information?',
      options: [
        'Phishing',
        'Writing a book',
        'Making a documentary',
        'Hosting a TV show'
      ],
      correctAnswer: 'Phishing',
    ),
    QuizQuestion(
      question: 'What is a good preventative measure against identity theft?',
      options: [
        'Share your passwords',
        'Post your credit card numbers online',
        'Regularly review your credit reports',
        'Use simple passwords'
      ],
      correctAnswer: 'Regularly review your credit reports',
    ),
    QuizQuestion(
      question: 'What should you do if you become a victim of fraud?',
      options: [
        'Report it to the local authorities and your bank',
        'Celebrate',
        'Tell your friends on social media',
        'Do nothing'
      ],
      correctAnswer: 'Report it to the local authorities and your bank',
    ),
    QuizQuestion(
      question:
      'True or False: You should give out personal information over the phone if the caller claims to be from your bank.',
      options: ['True', 'False', 'Maybe', 'Only if they sound friendly'],
      correctAnswer: 'False',
    ),
    QuizQuestion(
      question: 'How can you protect yourself from online scams?',
      options: [
        'Share your passwords with trusted friends',
        'Always click on links in emails',
        'Be cautious of unsolicited communications and deals that seem too good to be true',
        'Buy everything you see online'
      ],
      correctAnswer:
      'Be cautious of unsolicited communications and deals that seem too good to be true',
    ),
  ],
  'Harassment': [
    QuizQuestion(
      question: 'What is a common form of workplace harassment?',
      options: [
        'Free lunch',
        'Unwelcome comments or jokes',
        'Positive feedback',
        'Team building exercises'
      ],
      correctAnswer: 'Unwelcome comments or jokes',
    ),
    QuizQuestion(
      question: 'What should you do if you are being harassed?',
      options: [
        'Laugh it off',
        'Ignore it',
        'Document the incidents and report them',
        'Encourage the harasser'
      ],
      correctAnswer: 'Document the incidents and report them',
    ),
    QuizQuestion(
      question: 'True or False: Cyberbullying is a form of harassment.',
      options: ['True', 'False', 'Maybe', 'It depends'],
      correctAnswer: 'True',
    ),
    QuizQuestion(
      question: 'How can you help to prevent harassment in the workplace?',
      options: [
        'Promote a positive, respectful work environment',
        'Spread rumors',
        'Make unwelcome jokes',
        'Exclude certain people from team activities'
      ],
      correctAnswer: 'Promote a positive, respectful work environment',
    ),
    QuizQuestion(
      question:
      'What action should a company take if an employee reports harassment?',
      options: [
        'Ignore the report',
        'Laugh it off',
        'Blame the victim',
        'Investigate the claim promptly and thoroughly'
      ],
      correctAnswer: 'Investigate the claim promptly and thoroughly',
    ),
  ],
  'Drug Abuse': [
    QuizQuestion(
      question: 'What are some common signs of drug abuse?',
      options: [
        'Change in behavior, neglecting responsibilities, health issues',
        'Increased appetite, more physical activity, better sleep',
        'Increased productivity, better relationships, improved health',
        'Improved mood, higher energy levels, better concentration'
      ],
      correctAnswer:
      'Change in behavior, neglecting responsibilities, health issues',
    ),
    QuizQuestion(
      question:
      'What should you do if you suspect a loved one is abusing drugs?',
      options: [
        'Join them',
        'Ignore the problem',
        'Express your concerns in a supportive way and encourage them to seek help',
        'Blame them for their problems'
      ],
      correctAnswer:
      'Express your concerns in a supportive way and encourage them to seek help',
    ),
    QuizQuestion(
      question: 'True or False: Prescription medications cannot be addictive.',
      options: ['True', 'False', 'Maybe', 'It depends'],
      correctAnswer: 'False',
    ),
    QuizQuestion(
      question: 'What is a common consequence of drug abuse?',
      options: [
        'Physical health problems',
        'Improved mental health',
        'Better relationships',
        'Increased productivity'
      ],
      correctAnswer: 'Physical health problems',
    ),
    QuizQuestion(
      question:
      'What is one effective approach to preventing drug abuse in youth?',
      options: [
        'Ignore the problem',
        'Make drugs more accessible',
        'Glamorize drug use',
        'Education and open communication'
      ],
      correctAnswer: 'Education and open communication',
    ),
  ],
};

class QuizPage extends StatefulWidget {
  final String category;
  final List<QuizQuestion> questions;

  QuizPage({required this.category, required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _finished = false;
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: screenHeight * .01),
            _finished
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quiz Finished',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your score: $_score/${widget.questions.length}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
                : Column(
              children: <Widget>[
                LinearProgressIndicator(
                  value: _currentQuestionIndex / widget.questions.length,
                ),
                SizedBox(height: 20),
                Text(
                  widget.questions[_currentQuestionIndex].question,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Column(
                  children: widget
                      .questions[_currentQuestionIndex].options
                      .map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value;
                          if (_selectedOption ==
                              widget.questions[_currentQuestionIndex]
                                  .correctAnswer) {
                            _score++;
                          }
                          if (_currentQuestionIndex <
                              widget.questions.length - 1) {
                            _currentQuestionIndex++;
                          } else {
                            _finished = true;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            screenSize * .02, screenHeight * .02, screenSize * .02, 0),
        child: FractionallySizedBox(
          widthFactor: 1.2,
          child: Container(
            color: Colors.grey[300],
            height: screenHeight * .08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}