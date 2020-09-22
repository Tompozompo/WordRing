import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotatingtest/factory/DatabasePuzzleFactory.dart';
import 'package:rotatingtest/pages/GamePage.dart';
import 'package:rotatingtest/routes/ScaleRoute.dart';

class PuzzleListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabasePuzzleFactory factory = new DatabasePuzzleFactory();
    return Scaffold(
      body: FutureBuilder<List>(
          future: factory.getPuzzleList(),
          initialData: List(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.separated(
                itemCount: snapshot.data.length,
                separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  var id = snapshot.data[index]["id"];
                  var center = snapshot.data[index]["center"];
                  var words = snapshot.data[index]["words"];
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            ScaleRoute(page: GamePage(id))
                          );
                      },
                      title: Text('id $id; center $center; words $words'),
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }
      ),
    );
  }
}