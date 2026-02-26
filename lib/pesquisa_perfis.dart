import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perf_list/perfil_outros.dart';
import 'package:flutter/cupertino.dart';



class TelaPesquisar extends StatefulWidget{
  const TelaPesquisar({super.key});

  @override
  State<TelaPesquisar> createState() => _TelaPesquisarState();
}

class _TelaPesquisarState extends State<TelaPesquisar> {
  final db = FirebaseFirestore.instance;
  
  @override
  void initState() {
    
    _pesquisaController.addListener(_onSearchChanged);
    super.initState();
  }
  _onSearchChanged(){
    print(_pesquisaController.text);
    searchResultList();
  }
  List<Map<String, dynamic>> _allResults = [];
  List<Map<String, dynamic>> _resultList = [];
  DocumentSnapshot? _documentSnapshot;
  getClientStream() async{
    var data = await db.collection("users").orderBy('nickname').get();
    print('data: ${data.docs}');
    setState(() {
      _allResults = _allResults = data.docs.map((doc) => doc.data()).toList();
    });
    searchResultList();
  }
  

  final _pesquisaController = TextEditingController();

  @override
  void dispose() {
    _pesquisaController.removeListener(_onSearchChanged);
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    getClientStream();
    super.didChangeDependencies();
  }


  Future<void> _profile(uid) async {
    DocumentSnapshot userDoc = await db.collection('users').doc(uid).get();
    print(userDoc);
    setState(() {
      _documentSnapshot = userDoc;
    });
  }


  
  searchResultList(){
    var showResults = <Map<String, dynamic>>[];
    if(_pesquisaController.text != ""){
      for(var clientSnapshot in _allResults){
        var nome = clientSnapshot["nickname"].toString().toLowerCase();
        if(nome.contains(_pesquisaController.text.toLowerCase())){
          showResults.add(clientSnapshot);
        }
      }
    }
    else{
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultList =  showResults;
    });
  }
  @override
  Widget build(BuildContext context){
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").orderBy('nickname').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData){ return const Center(
            child: SizedBox(
              width: 50.0, // Defina a largura desejada
              height: 50.0, // Defina a altura desejada
              child: CircularProgressIndicator(strokeWidth: 4.0),
            ),
          );
        }
        //List<QueryDocumentSnapshot> allResults = snapshot.data!.docs;

    return LayoutBuilder(builder: ((context, constraints) {
      return Scaffold(
        appBar: AppBar(
          // backgroundColor: ,
          centerTitle: constraints.maxWidth >= 600,
          title: FractionallySizedBox(
            widthFactor: constraints.maxWidth >= 600 ? 0.6 : 0.9,
            child: CupertinoSearchTextField(
              controller: _pesquisaController,
              itemSize: 20.0,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.close),
              
            ),
          ),
        ),
        body: 
        
            Center(
              child: FractionallySizedBox(
                widthFactor: constraints.maxWidth >= 600 ? 0.6 : 0.9,
               child: 
                
                    Center(
                      child: Column(
                        children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Text("Usuários: ${_resultList.length}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),),
                        ),
                  
                          Flexible(
                            child: ListView.builder(
                                
                                itemCount: _resultList.length,
                                itemBuilder: (context, index){
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: SizedBox(
                                height: 100,
                                width: constraints.maxWidth,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(50.0), // Altere o valor conforme necessário
                                              child:
                                                _resultList[index].containsKey('profileImage') ?
                                                 Image.network(
                                                _resultList[index]['profileImage'] ?? '',
                                                width: 75,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ) : const Icon(Icons.person, size: 50)
                                               
                                            ),
                                            const SizedBox(width: 20,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                              Text("${_resultList[index]['nickname']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                                              Text("${_resultList[index]['genero']}"),
                                              //Text("Transporte: ${_resultList[index]['transporte']}"),
                                            
                                            ],),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                        
                                        
                                                                ]),
                                    )
                                
                                  ],
                                ),
                              ),
                              onPressed: () async {
                                await _profile(_resultList[index]['uid']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UserProfileDisplayScreen(userProfile: _documentSnapshot!,)),
                                );
                              },
                            ),
                            const SizedBox(height: 10,)
                                        /*ListTile(
                                          title: Text(_resultList[index]['nome']),
                                          subtitle: Text(_resultList[index]['apelido']),
                                          trailing: Text("Transporte: ${_resultList[index]['transporte']}"),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ClienteDetalhes(_resultList[index])),
                                            );
                                          },
                                        ),*/
                                      ],
                                    ),
                                  );
                                }
                                ),
                          ),
                        ],
                      ),
                    ),
                  
                ),
            ),
            
         
      );
    }));
  }
  );


  }

}

