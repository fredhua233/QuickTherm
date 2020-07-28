import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicktherm/Pages/StartUp/ChooseIdentityPage.dart';
import 'package:quicktherm/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

enum Language { EN, CN_S, CN_T, CN_Y, AR, SP, RU }

class ChooseLanguagePage extends StatefulWidget {
  @override
  ChooseLanguagePageState createState() => ChooseLanguagePageState();
}

class ChooseLanguagePageState extends State<ChooseLanguagePage> {
  Language _lang = Language.EN;
  bool acceptedTerms = false;
  Utils _utils = new Utils();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Column(
        children: <Widget>[
          Text("Choose language/请选择语言/Elige lengua/Выберите язык/اختر اللغة", textAlign: TextAlign.center,),
          RadioListTile<Language>(
            title: const Text('English'),
            value: Language.EN,
            groupValue: _lang,
            onChanged: (Language lang) {
              setState(() {
                _lang = lang;
              });
            },
          ),
          RadioListTile<Language>(
            title: const Text('中文（简）'),
            value: Language.CN_S,
            groupValue: _lang,
            onChanged: (Language lang) {
              setState(() {
                _lang = lang;
              });
            },
          ),
          RadioListTile<Language>(
            title: const Text('粤语（繁）'),
            value: Language.CN_Y,
            groupValue: _lang,
            onChanged: (Language lang) {
              setState(() {
                _lang = lang;
              });
            },
          ),
          RadioListTile<Language>(
            title: const Text('國語（繁）'),
            value: Language.CN_T,
            groupValue: _lang,
            onChanged: (Language lang) {
              setState(() {
                _lang = lang;
              });
            },
          ),
          RadioListTile<Language>(
            title: const Text('español'),
            value: Language.SP,
            groupValue: _lang,
            onChanged: (Language lang) {
              setState(() {
                _lang = lang;
              });
            },
          ),
          RadioListTile<Language>(
            title: const Text('русский'),
            value: Language.RU,
            groupValue: _lang,
            onChanged: (Language lang) {
              setState(() {
                _lang = lang;
              });
            },
          ),
          RadioListTile<Language>(
            title: const Text('عربى'),
            value: Language.AR,
            groupValue: _lang,
            onChanged: (Language lang) {
              setState(() {
                _lang = lang;
              });
            },
          ),
          RaisedButton(
              onPressed: () async {
                LANG = _lang.toString().substring(9).toLowerCase();
                await _utils.load();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: new Text(_utils.translate("Permissions Requested")),
                      content: new SingleChildScrollView(
                        child: Text(_utils.translate("Privacy Message"))
//                            "By clicking on continue you agree to share the following: \n\n"
//                                "- Name, address and age  \n"
//                                "- Contact Information \n"
//                                "- Previous health history and conditions \n"
//                                "- Current health conditions and statistics \n\n"
//                                "to your residential supervisors/your nurses and their supervisors and the developers.\n"
//                                "The developers DOES NOT AND WILL NOT use your personal info for purposes other than the purposes required by this app. \n"
//                                "If you agree and wish to proceed, please tap on 'Agree' and then tap 'Continue'. Thank you!"),
                      ),
                      actions: <Widget>[
                        // usually buttons at the bottom of the dialog
                        new FlatButton(
                          child: new Text(_utils.translate("Agree")),
                          onPressed: () {
                            setState(() {
                              acceptedTerms = true;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: new Text(_utils.translate("Disagree")),
                          onPressed: () {
                            setState(() {
                              acceptedTerms = false;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                if (acceptedTerms) {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => ChooseIdentityPage()));
                }
              },
              child: Text("Continue/继续/繼續/Продолжать/Seguir/استمر")
          ),
        ],
      ),
    );

  }
}
