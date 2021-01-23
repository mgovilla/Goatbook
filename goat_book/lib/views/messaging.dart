import 'package:flutter/cupertino.dart';

/*/**Widget Build in MessageView Class still need to be worked on and put together
 * I put some comments there if any of you would like to finish it. Thank you!
 */
void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    Widget usernameSection = Container( //Display user's profile pic and name
      child: Row(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(20),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(),//User's profile pic
                  fit: BoxFit.fill
                  ),
                  ),
                  ),
                  Text("Username",
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                  ),
          ],          
    ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: <Widget> [
          IconButton(icon: Icon(Icons.search),
          onPressed: ()) {
            showSearch(context: context, delegate: DataSearch(listWords));
          })
        ],
      ),
      drawer: Drawer(),
      );
  }
}

class DataSearch extends SearchDelegate<String>{
  final List<ListWords> listWords;

  DataSearch(this.listWords);

  @override 
  List<Widget> buildAction(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPress:(){
      query = '';
    })];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icon on the left of the app bar
    return IconButton(
        icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on the selection
    return Center(
      child: Text(query),

    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final suggestionList = query.isEmpty
        ? listWords
        : listWords.where((p) => p.startsWith(query)).toList();
        
        return ListView.builder(itemBuilder: (context, index) => ListTile(
      onTap: () {
        showResults(context);
      },
      trailing: Icon(Icons.remove_red_eye),
      title: RichText(
        text: TextSpan(
            text: suggestionList[index].titlelist.substring(0, query.length),
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: suggestionList[index].titlelist.substring(query.length),
                  style: TextStyle(color: Colors.grey))
            ]),
      ),
    ),
      itemCount: suggestionList.length,
    );
  }
}

class MessagingView extends StatefulWidget {
  const MessagingView();

  @override
  _MessagingViewState createState() => _MessagingViewState();
}

class _MessagingViewState extends State<MessagingView> {

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(
          title: Text ("Message"),
        ),
        body: ListView(
          children: [
            usernameSection, // need to put all this together
            searchSection, // need to put all this together
            messageSection, // still needs to work on this
          ],
        ),
    );
  }

}
*/

class MessagingView extends StatefulWidget {
  const MessagingView();

  @override
  _MessagingViewState createState() => _MessagingViewState();
}

class _MessagingViewState extends State<MessagingView> {
  @override
  Widget build(BuildContext ctx) {
    return Text("Messaging");
  }
}
