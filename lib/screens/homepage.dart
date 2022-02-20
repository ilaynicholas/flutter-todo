import 'package:flutter/material.dart';
import 'package:to_do/database_helper.dart';
import 'package:to_do/models/task.dart';
import 'package:to_do/screens/taskpage.dart';
import 'package:to_do/widgets.dart';

class Homepage extends StatefulWidget {
  const Homepage({ Key? key }) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0
          ),
          color: const Color(0xFFF6F6F6),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 32.0,
                      bottom: 32.0,
                    ),
                    child: const Image(
                      image: AssetImage(
                        'assets/images/logo.png'
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: _dbHelper.getTasks(),
                      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
                        return ScrollConfiguration(
                          behavior: NoGlowBehavior(),
                          child: ListView.builder(
                            itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => Taskpage(
                                      task: snapshot.data![index]
                                    ),
                                    )
                                  ).then(
                                    (value) {
                                      setState(() {});
                                    }
                                  );
                                },
                                child: TaskCardWidget(
                                  title: snapshot.data![index].title,
                                  desc: snapshot.data![index].description
                                ),
                              );
                            },
                          ),
                        );
                      }
                    )
                  ),                 
                ],
              ),
              Positioned(
                bottom: 24.0,
                right: 0.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => const Taskpage(task: null)
                      )
                    ).then((value) {
                      setState(() {});
                    });
                  },
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7349FE), Color(0xFF643FDB)],
                        begin: Alignment(0.0, -1.0),
                        end: Alignment(0.0, 1.0)
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Image(
                      image: AssetImage(
                        'assets/images/add_icon.png',
                      )
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}