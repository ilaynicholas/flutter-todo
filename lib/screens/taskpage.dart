import 'package:flutter/material.dart';
import 'package:to_do/models/task.dart';
import 'package:to_do/models/todo.dart';
import 'package:to_do/widgets.dart';

import '../database_helper.dart';

class Taskpage extends StatefulWidget {
  final Task?  task;
  const Taskpage({ Key? key, @required this.task}) : super(key: key);

  @override
  _TaskpageState createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int? _taskId = 0;
  String? _taskTitle = "";
  String? _taskDescription = "";

  late FocusNode _titleFocus;
  late FocusNode _descriptionFocus;
  late FocusNode _todoFocus;

  bool _contentVisible = false;

  @override
  void initState() {
    if(widget.task != null) {
      _contentVisible = true;

      _taskTitle = widget.task!.title;
      _taskDescription = widget.task!.description;
      _taskId = widget.task!.id;
    }

    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _todoFocus = FocusNode();

    super.initState();
  }

  @override
  // ignore: must_call_super
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _todoFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 6.0,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Image(
                            image: AssetImage(
                              'assets/images/back_arrow_icon.png'
                            )
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _titleFocus,
                          onSubmitted: (value) async {
                            if(value != "") {
                              if(widget.task == null) {
                                Task _newTask = Task(
                                  title: value
                                );

                                _taskId = await _dbHelper.insertTask(_newTask);
                                setState(() {
                                  _contentVisible = true;
                                  _taskTitle = value;
                                });
                              } else {
                                await _dbHelper.updateTaskTitle(_taskId!, value);
                              }

                              _descriptionFocus.requestFocus();   
                            }
                          },
                          controller: TextEditingController()..text = _taskTitle!,
                          decoration: const InputDecoration(
                            hintText: "Enter task title",
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF211551),
                          )
                        ),
                      )
                    ]
                  ),
                ),
                Visibility(
                  visible: _contentVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12.0,
                    ),
                    child: TextField(
                      focusNode: _descriptionFocus,
                      onSubmitted: (value) async {
                        if(value != "") {
                          if(_taskId != 0) {
                            await _dbHelper.updateTaskDescription(_taskId!, value);
                            _taskDescription = value;
                          }
                        }
                        _todoFocus.requestFocus();
                      },
                      controller: TextEditingController()..text = _taskDescription!,
                      decoration: const InputDecoration(
                        hintText: "Enter description for the task.",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 24.0,
                        )
                      )
                    ),
                  ),
                ),
                Visibility(
                  visible: _contentVisible,
                  child: FutureBuilder(
                    initialData: const [],
                    future: _dbHelper.getTodos(_taskId),
                    builder: (context, AsyncSnapshot snapshot) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                if(snapshot.data[index].isDone == 0) {
                                  await  _dbHelper.updateTodoDone(snapshot.data[index].id, 1);
                                } else {
                                  await _dbHelper.updateTodoDone(snapshot.data[index].id, 0);
                                }
                                setState(() {});
                              },
                              child: TodoWidget(
                                text: snapshot.data[index].title,
                                isDone: snapshot.data[index].isDone == 0 ? false: true
                              ),
                            );
                          },
                        ),
                      );
                    }
                  ),
                ),
                Visibility(
                  visible: _contentVisible,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20.0,
                          height: 20.0,
                          margin: const EdgeInsets.only(
                            right: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                              color: const Color(0xFF86829D),
                              width: 1.5
                            )
                          ),
                          child: const Image(
                            image: AssetImage(
                              'assets/images/check_icon.png'
                            )
                          )
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _todoFocus,
                            controller: TextEditingController()..text = "",
                            onSubmitted: (value) async {
                              if(value != "") {
                                if(_taskId != 0) {
                                  DatabaseHelper _dbHelper = DatabaseHelper();
                                  Todo _newTodo = Todo(
                                    title: value,
                                    isDone: 0,
                                    taskId: _taskId
                                  );
                
                                  await _dbHelper.insertTodo(_newTodo);
                                  setState(() {});
                                  _todoFocus.requestFocus();
                                }
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: "Enter todo item.",
                              border: InputBorder.none
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                )
              ]
            ),
            Visibility(
              visible: _contentVisible,
              child: Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: GestureDetector(
                    onTap: () async {
                      if(_taskId != 0) {
                        await _dbHelper.deleteTask(_taskId!);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE3572),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Image(
                        image: AssetImage(
                          'assets/images/delete_icon.png',
                        )
                      ),
                    ),
                  ),
                ),
            ),
          ],
        ),
      )
    );
  }
}