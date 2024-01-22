import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mydictionary/api.dart';
import 'package:mydictionary/response_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool inProgress = false;
  ResponseModel? responseModel;
  String noDataText = "Welcome,Start Searching";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchWidget(),
              const SizedBox(
                height: 12,
              ),
              if (inProgress)
                const LinearProgressIndicator()
              else if (responseModel != null)
                _buildResponseWidget()
              else
                _noDataWidget(),
            ],
          ),
        ),
      ),
    );
  }

  _buildResponseWidget() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
          ),
          Text(
            responseModel!.word!,
            style: TextStyle(
              color: Colors.purple.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(responseModel!.phonetic ?? ""),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return _buildMeaningWidget(responseModel!.meanings![index]);
              },
              itemCount: responseModel!.meanings!.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningWidget(Meanings meanings) {
    if (meanings.definitions == null || meanings.partOfSpeech == null) {
      // Return some placeholder or empty widget
      return SizedBox.shrink(); // Empty container
    }

    String definitionList = "";
    meanings.definitions!.forEach((element) {
      int index = meanings.definitions!.indexOf(element);
      definitionList += "\n${index + 1}.${element.definition}\n";
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              meanings.partOfSpeech!,
              style: TextStyle(
                color: Colors.orange.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'definitions:',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(definitionList),
            _buildset("synonyms", meanings.synonyms),
            _buildset("Antonyms", meanings.antonyms),
          ],
        ),
      ),
    );
  }

  _buildset(String title, List<String>? setList) {
    if (setList?.isNotEmpty ?? false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title:",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(setList!
              .toSet()
              .toString()
              .replaceAll("{", "")
              .replaceAll("}", "")),
          const SizedBox(height: 10)
        ],
      );
    }
  }

  _noDataWidget() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          noDataText,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  _buildSearchWidget() {
    return SearchBar(
      hintText: 'Search word here',
      onSubmitted: (value) {
        _getMeaningFromApi(value);
      },
    );
  }

  _getMeaningFromApi(String word) async {
    setState(() {
      inProgress = true;
    });
    try {
      responseModel = await API.fetchMeaning(word);
      setState(() {});
    } catch (e) {
      responseModel = null;
      noDataText = "meaning cannot be fetched";
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
